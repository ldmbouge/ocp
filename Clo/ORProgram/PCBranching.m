//
//  PCBranching.m
//  Clo
//
//  Created by Laurent Michel on 4/12/16.
//
//

#import "PCBranching.h"
#include <math.h>

#import <CPUKernel/CPEngineI.h>


#define ALPHAVALUE 2.0

@interface FracVars : NSObject<NSFastEnumeration> {
   struct VarPack {
      id<ORIntVar> _x;
      double    _frac;
   };
   id<ORRelaxation> _relax;
   struct VarPack* _pack;
   NSUInteger _mxs;
   NSUInteger _sz;
}
+(FracVars*)extractFractionalVariables:(id<ORRelaxation>)relax from:(id<ORIntVarArray>)x;
-(id)init:(NSUInteger)capacity forRelaxation:(id<ORRelaxation>)relax;
-(void)addVariable:(id<ORIntVar>)x withKey:(ORDouble)f;
-(NSUInteger)count;
-(id<ORIntVar>)extractLeastFractional;
-(id<ORIntVar>)extractMostFractional;
-(id<ORIntVar>)extractMinLock;
@end


@interface VStat : NSObject {
   double _down;
   double _up;
   double _nbl,_nbu;
}
-(id)init;
-(id)initLow:(double)d up:(double)u;
-(void)recordLow:(double)d up:(double)u;
-(void)recordLow:(double)d;
-(void)recordUp:(double)u;
-(double)pseudoDown;
-(double)pseudoUp;
-(double)scoreWn:(double)wn Wp:(double)wp;
@end

@interface VRunningMean : NSObject {
   ORDouble _ttl;
   ORDouble _nb;
}
-(id)init;
-(void)recordSample:(ORDouble)v;
-(ORDouble)value;
@end

@implementation VRunningMean
-(id)init
{
   self = [super init];
   _nb = 0;
   _ttl = 0;
   return self;
}
-(void)recordSample:(ORDouble)v
{
   _ttl += v;
   _nb += 1.0;
}
-(ORDouble)value
{
   return _ttl / _nb;
}
@end

@implementation FracVars
+(FracVars*)extractFractionalVariables:(id<ORRelaxation>)relax from:(id<ORIntVarArray>)x
{
   FracVars* rv = [[FracVars alloc] init:8 forRelaxation:relax];
   for(id<ORIntVar> xi in x) {
      ORDouble r = [relax value:xi];
      ORDouble iv;
      ORDouble fv = modf(r,&iv);
      if (fv != 0) {
         ORDouble fractional = fabs(r - floor(r + 0.5));
         [rv addVariable:xi withKey:fractional];
      }
   }
   return rv;
}
-(id)init:(NSUInteger)capacity forRelaxation:(id<ORRelaxation>)relax
{
   self = [super init];
   _mxs = capacity;
   _relax = relax;
   _pack = calloc(_mxs,sizeof(struct VarPack));
   _sz  = 0;
   return self;
}
-(void)dealloc
{
   free(_pack);
   [super dealloc];
}
-(void)addVariable:(id<ORIntVar>)x withKey:(ORDouble)f
{
   for(NSUInteger i=0;i < _sz;i++)
      if (_pack[i]._x == x)
         return;
   if (_sz == _mxs)
      _pack = realloc(_pack,(_mxs <<= 1)*sizeof(struct VarPack));
   _pack[_sz]._x = x;
   _pack[_sz]._frac = f;
   _sz++;
}
-(NSUInteger)count
{
   return _sz;
}
-(id<ORIntVar>)extractLeastFractional
{
   ORInt    sd  = FDMAXINT;
   ORDouble lfv = 1.0;
   NSInteger k = -1;
   for(NSInteger i=0;i < _sz;i++) {
      ORInt vdsz = [[_pack[i]._x domain] size];
      if ((vdsz < sd) || (vdsz == sd &&  _pack[i]._frac < lfv)) {
         k = i;
         lfv = _pack[i]._frac;
      }
   }
   if (k >= 0) {
      id<ORIntVar> rv = _pack[k]._x;
      _pack[k] = _pack[--_sz];
      return rv;
   } else
      return nil;
}
-(id<ORIntVar>)extractMostFractional
{
   ORDouble mfv = 0.0;
   NSInteger k = -1;
   for(NSInteger i=0;i < _sz;i++) {
      if (_pack[i]._frac > mfv) {
         k = i;
         mfv = _pack[i]._frac;
      }
   }
   if (k >= 0) {
      id<ORIntVar> rv = _pack[k]._x;
      _pack[k] = _pack[--_sz];
      return rv;
   } else
      return nil;
}
-(id<ORIntVar>)extractMinLock
{
   ORDouble lfv = 1.0;
   ORInt nbLocks = FDMAXINT;
   NSInteger k = -1;
   for(NSInteger i=0;i < _sz;i++) {
      ORInt xiL = [_relax nbLocks:_pack[i]._x];
      if (xiL < nbLocks) {
         k = i;
         nbLocks = xiL;
         lfv = _pack[i]._frac;
      } else if (xiL == nbLocks && _pack[i]._frac < lfv) {
         k = i;
         lfv = _pack[i]._frac;
      }
   }
   if (k >= 0) {
      id<ORIntVar> rv = _pack[k]._x;
      _pack[k] = _pack[--_sz];
      return rv;
   } else
      return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
{
   NSUInteger from;
   if (state->state == 0)
      from = 0;
   else
      from = state->state;
   NSUInteger batch = 0;
   while (from < _sz && batch < len) {
      stackbuf[batch] = _pack[from]._x;
      ++from;
      ++batch;
   }
   state->state = from;
   state->itemsPtr = stackbuf;
   state->mutationsPtr = (unsigned long*)self;
   return batch;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"[%lu]{",(unsigned long)_sz];
   for(NSUInteger i = 0;i < _sz;i++) {
      [buf appendFormat:@"%@ [%f]%c",_pack[i]._x,_pack[i]._frac,i < _sz - 1 ? ',' : ' '];
   }
   [buf appendString:@"}"];
   return buf;
}
@end

@implementation VStat
-(id)init
{
   self = [super init];
   _nbl = _nbu = 0;
   return self;
}
-(id)initLow:(double)d up:(double)u
{
   self = [super init];
   _down = d;
   _up   = u;
   _nbl = _nbu = 1;
   assert(!isnan(_down));
   assert(!isnan(_up));
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<VStat(%3.0f,%3.0f) :: %f,%f  AVG: %f,%f>",_nbl,_nbu,_down,_up,self.pseudoDown,self.pseudoUp];
   return buf;
}
-(void)recordLow:(double)d up:(double)u
{
   _nbl++;_nbu++;
   _down = (_down * (ALPHAVALUE - 1.0) + d) / ALPHAVALUE;
   _up   = (_up   * (ALPHAVALUE - 1.0) + u) / ALPHAVALUE;
   assert(!isnan(_down));
   assert(!isnan(_up));
}
-(void)recordLow:(double)d
{
   if (_nbl==0)
      _down = d;
   else
      _down = (_down * (ALPHAVALUE - 1.0) + d) / ALPHAVALUE;
   _nbl++;
   assert(!isnan(_down));
}
-(void)recordUp:(double)u
{
   if (_nbu == 0)
      _up = u;
   else
      _up   = (_up   * (ALPHAVALUE - 1.0) + u) / ALPHAVALUE;
   _nbu++;
   assert(!isnan(_up));
}

-(double)pseudoDown
{
   return _nbl > 0 ? _down  : 0;
}
-(double)pseudoUp
{
   return _nbu > 0 ? _up  : 0;
}
static inline ORDouble minDbl(ORDouble a,ORDouble b) { return a < b ? a : b;}
static inline ORDouble maxDbl(ORDouble a,ORDouble b) { return a > b ? a : b;}
-(double)scoreWn:(double)wn Wp:(double)wp
{
   static const double mu = 1.0 / 6.0;
   double qn = wn * [self pseudoDown];
   double qp = wp * [self pseudoUp];
//   return maxDbl(qn,1.0e-16)*maxDbl(qp,1.0e-16);
   return (1 - mu) * minDbl(qn,qp) + mu * maxDbl(qn,qp);
}
@end

@implementation Branching {
   @protected
   id<CPCommonProgram>    _p;
   id<ORRelaxation>   _relax;
   id<ORRealVarArray>  _realVars;
}
-(id)init:(id<CPCommonProgram>)p relax:(id<ORRelaxation>)relax
{
   self = [super init];
   _p = p;
   _relax = relax;
   _realVars = [[[_p source] rootModel] realVars];
   return self;
}
-(ORBool)selectVar:(id<ORIntVarArray>)x index:(ORInt*)k  value:(ORDouble*)rv
{
   return false;
}
-(void)initState
{}
-(void)theSearch:(id<ORIntVarArray>)x
{
   while (![_p allBound:x]) {
      ORDouble fv;
      ORInt    bi;
      ORBool ok = [self selectVar:x index:&bi value:&fv];
      if (ok) {
         ORInt im = floor(fv);
         [_p try:^{
            [_p lthen:x[bi] with:im+1];
         } alt:^{
            [_p gthen:x[bi] with:im];
         }];
      } else {
         [self fixAndDive:x];
         [[_p explorer] fail];
         break;
      }
   }
}
-(void)fractionalDive:(id<ORIntVarArray>)x
{
   id<ORCheckpoint> start = [[_p tracer] captureCheckpoint];
   FracVars* I = [FracVars extractFractionalVariables:_relax from:x];
   id<ORObjectiveValue> primal = [[_p objective] primalBound];
   id<ORObjectiveValue> fCur   = [_relax objectiveValue];
   ORInt i = 0;
   bool diveDead = false;
   while ([I count] > 0 && [fCur compare:primal]==NSOrderedAscending) {
      i++;
      id<ORIntVar> sx = [I extractLeastFractional];
      ORDouble sxv = [_relax value:sx];
      ORDouble ni = floor(sxv + 0.5);
      ORBool bindDown = floor(sxv) == ni;
      ORStatus ok = [[_p engine] atomic:^{
         if (bindDown)
            [_p lthen:sx with:ni + 1];
         else
            [_p gthen:sx with:ni - 1];
      }];
      if (ok == ORFailure) {
         diveDead = true;
         break;
      }
      [I release];
      I = [FracVars extractFractionalVariables:_relax from:x];
      NSUInteger nbtr = 0;
      for(id<ORIntVar> xi in I) {
         ORBool tr = [_relax triviallyRoundable:xi];
         if (!tr) break;
         nbtr = nbtr + tr;
      }
      if (nbtr == [I count]) {
         NSLog(@"About to round %lu easy guys",(unsigned long)nbtr);
         //ORStatus ok =
         [[_p engine] atomic:^{
            for(id<ORIntVar> xi in I) {
               if ([_relax trivialDownRoundable:xi]) {
                  [_p lthen:xi with:[xi low] + 1];
               } else {
                  assert([_relax trivialUpRoundable:xi]);
                  [_p gthen:xi with:[xi up] - 1];
               }
            }
         }];
         //assert(ok != ORFailure);
      }
      fCur   = [_relax objectiveValue];
   }
   [I release];
   if (!diveDead)
      [self fixAndDive:x];
   [[_p tracer] restoreCheckpoint:start inSolver:[_p engine] model:nil];
}

-(void)coefficientDive:(id<ORIntVarArray>)x
{
   id<ORCheckpoint> start = [[_p tracer] captureCheckpoint];
   FracVars* I = [FracVars extractFractionalVariables:_relax from:x];
   id<ORObjectiveValue> primal = [[_p objective] primalBound];
   id<ORObjectiveValue> fCur   = [_relax objectiveValue];
   ORInt i = 0;
   bool diveDead = false;
   while ([I count] > 0 && [fCur compare:primal]==NSOrderedAscending) {
      i++;
      id<ORIntVar> sx = [I extractMinLock];
      ORDouble sxv = [_relax value:sx];
      ORDouble ni = floor(sxv);
      ORBool bindDown = [_relax minLockDown:sx];
      ORStatus ok = [[_p engine] atomic:^{
         if (bindDown)
            [_p lthen:sx with:ni + 1];
         else
            [_p gthen:sx with:ni];
      }];
      if (ok == ORFailure) {
         diveDead = true;
         break;
      }
      [I release];
      I = [FracVars extractFractionalVariables:_relax from:x];
      NSUInteger nbtr = 0;
      for(id<ORIntVar> xi in I) {
         ORBool tr = [_relax triviallyRoundable:xi];
         if (!tr) break;
         nbtr = nbtr + tr;
      }
      if (nbtr == [I count]) {
         NSLog(@"About to round %lu easy guys",(unsigned long)nbtr);
         //ORStatus ok =
         [[_p engine] atomic:^{
            for(id<ORIntVar> xi in I) {
               //ORDouble sxv = [_relax value:sx];
               //ORDouble ni = floor(sxv + 0.5);
               if ([_relax trivialDownRoundable:xi]) {
                  [_p lthen:xi with:[xi low] + 1];
               } else {
                  assert([_relax trivialUpRoundable:xi]);
                  [_p gthen:xi with:[xi up] - 1];
               }
            }
         }];
         //assert(ok != ORFailure);
      }
      fCur   = [_relax objectiveValue];
   }
   [I release];
   if (!diveDead)
      [self fixAndDive:x];
   [[_p tracer] restoreCheckpoint:start inSolver:[_p engine] model:nil];
}


-(void)wrapSearch:(ORClosure)body
{
   id<ORPost> pItf = [[CPINCModel alloc] init:_p];
   [_p nestedOptimize:body
           onSolution:nil
               onExit:nil
              control:[[ORSemDFSController alloc] initTheController:[_p tracer] engine:[_p engine] posting:pItf]];
}
-(void)branchOn:(id<ORIntVarArray>)x
{
   id<ORObjectiveValue> fStar = nil;
   id<ORObjectiveValue> cur = [[_p objective] primalBound];
//   do {
//      fStar = cur;
//      [self wrapSearch:^{ [self coefficientDive:x];}];
//      [self wrapSearch:^{ [self fractionalDive:x];}];
//      cur =  [[_p objective] primalBound];
//   } while ([cur compare:fStar] == NSOrderedAscending);
   //[self initState];

   cur = [[_p objective] primalBound];
   do {
      fStar = cur;
      [self wrapSearch:^{ [self coefficientDive:x];}];
      [self wrapSearch:^{ [self fractionalDive:x];}];
      cur =  [[_p objective] primalBound];
   } while ([cur compare:fStar] == NSOrderedAscending);

   [self mainSearch:x];
}
-(void)dfsProbe:(id<ORIntVarArray>)x
{
   [self wrapSearch:^{
      [_p limitTime:1000 in:^{
         [self theSearch:x];
         NSLog(@"Reached here...");
         ORStatus ok = [[_p engine] atomic:^{
            for(id<ORRealVar>  rvk in _realVars) {
               ORDouble vinRelax = [_relax value:rvk];
               [_p assignRelaxationValue:vinRelax to:rvk];
               [_p realGthen:rvk with:vinRelax - 0.000001];
               [_p realLthen:rvk with:vinRelax + 0.000001];
            }
         }];
         if (ok==ORFailure)
            [[_p explorer] fail];
         [[_p objective] updatePrimalBound];
         NSLog(@"full solution! %@",[_p objectiveValue]);
         [_p doOnSolution];
         [[_p explorer] fail];
      }];
      NSLog(@"Back from limit...");
   }];
}


-(void)pureDFS:(id<ORIntVarArray>)x
{
   //id<ORRealVarArray> rv = [[[_p source] rootModel] realVars];
   id<ORPost> pItf = [[CPINCModel alloc] init:_p];
   [_p nestedOptimize:^{
      [self theSearch:x];
      NSLog(@"pureDFS Reached here...");
      ORStatus ok = [[_p engine] atomic:^{
         for(id<ORRealVar>  rvk in _realVars) {
            ORDouble vinRelax = [_relax value:rvk];
            [_p assignRelaxationValue:vinRelax to:rvk];
            [_p realGthen:rvk with:vinRelax - 0.000001];
            [_p realLthen:rvk with:vinRelax + 0.000001];
         }
      }];
      if (ok==ORFailure)
         [[_p explorer] fail];
      [[_p objective] updatePrimalBound];
      NSLog(@"pureDFS full solution! %@",[_p objectiveValue]);
      [_p doOnSolution];
      [[_p explorer] fail];
   } onSolution: nil
               onExit: nil
              control:[[ORDFSController alloc] initTheController:[_p tracer] engine:[_p engine] posting:pItf]];
}

-(void)mainSearch:(id<ORIntVarArray>)x
{
   id<ORPost> pItf = [[CPINCModel alloc] init:_p];
   [_p nestedOptimize:^{
      [_p switchOnDepth:^{
         [self theSearch:x];
         NSLog(@"Reached here...");
         ORStatus ok = [[_p engine] atomic:^{
            for(id<ORRealVar>  rvk in _realVars) {
               ORDouble vinRelax = [_relax value:rvk];
               [_p assignRelaxationValue:vinRelax to:rvk];
               [_p realGthen:rvk with:vinRelax - 0.000001];
               [_p realLthen:rvk with:vinRelax + 0.000001];
            }
         }];
         if (ok==ORFailure)
            [[_p explorer] fail];
         [[_p objective] updatePrimalBound];
         NSLog(@"MAIN: full solution! %@",[_p objectiveValue]);
         [_p doOnSolution];
         [[_p explorer] fail];
      } to:^{
         [self pureDFS:x];
         [[_p explorer] fail];
      } limit:14];
   } onSolution: nil
               onExit:nil
              control:[[ORSemBFSController alloc] initTheController:[_p tracer] engine:[_p engine] posting:pItf]];
}
-(void)fixAndDive:(id<ORIntVarArray>)x
{
   [_p nestedOptimize: ^{
      [_p once:^{
         __block ORInt reached = x.range.low - 1;

         [_p try:^{

            ORStatus ok = [[_p engine] atomic:^{
               for(ORInt i=x.range.low; i <= x.range.up;i++) {
                  if ([_p bound:x[i]])
                     continue;
                  ORInt rv = rint([_relax value:x[i]]);
                  [_p label:x[i] with:rv];
                  reached = i;
               }
               for(id<ORRealVar>  rvk in _realVars) {
                  ORDouble vinRelax = [_relax value:rvk];
                  [_p assignRelaxationValue:vinRelax to:rvk];
                  [_p realGthen:rvk with:vinRelax - 0.000001];
                  [_p realLthen:rvk with:vinRelax + 0.000001];
               }
            }];

            if (ok==ORFailure)
               [[_p explorer] fail];
         
            [[_p objective] updatePrimalBound];
            NSLog(@"dive successful! %@",[_p objectiveValue]);
         } alt:^{
            NSLog(@"dive probe failed... Reached [%d]",reached);
         }];
      }];
   } onSolution:^{
      [_p doOnSolution];
   } onExit:nil
    control: [[ORSemDFSController alloc] initTheController:[_p tracer] engine:[_p engine] posting:nil]
    ];
   NSLog(@"BACK at END of fixAndDive...");
}

@end

@implementation PCBranching {
   id<ORIntVarArray>   _vars;
   NSMutableDictionary*  _pc;
   ORDouble            _flip;
   VRunningMean*    _overallDown;
   VRunningMean*    _overallUp;
}
-(id)init:(id<ORRelaxation>)relax over:(id<ORIntVarArray>)vars program:(id<CPCommonProgram>)p
{
   self =  [super init:p relax:relax];
   _vars  = vars;
   _flip = [[_p objective] isMinimization] ? 1.0 : -1.0;
   _overallDown = [[VRunningMean alloc] init];
   _overallUp   = [[VRunningMean alloc] init];
   _pc    = [[NSMutableDictionary alloc] init];
   return self;
}
-(void)initState
{
   [[_p explorer] applyController:[[ORSemDFSController alloc] initTheController:[_p tracer] engine:[_p engine] posting:nil]
                              in:^{
                                 double io = [_relax objective];
                                 for(ORInt i=_vars.range.low;i <= _vars.range.up;i++) {
                                    id<ORIntVar> vi = _vars[i];
                                    double vir = [_relax value:vi];
                                    //NSLog(@"x[%3d]  [%d,%d] ~= %4.20f",i,[_p min:vi],[_p max:vi],vir);
                                    double g   = 0;
                                    double f   = modf(vir,&g);
                                    if (f != 0) {
                                       double dm  = f,um  = 1.0 - f;
                                       double roDown=0.0,roUp=0.0;
                                       ORBool hasDown,hasUp;
                                       __block ORDouble downRate = 0;
                                       __block ORDouble upRate   = 0;
                                       double lb = [_relax lowerBound:vi];
                                       double ub = [_relax upperBound:vi];
                                       [_relax updateUpperBound:vi with:g];
                                       OROutcome sLow = [_relax solve];
                                       hasDown = sLow == ORoptimal;
                                       switch(sLow) {
                                          case ORoptimal:
                                             roDown = [_relax objective];
                                             downRate = _flip * (roDown - io) / dm;
                                             break;
                                          case ORinfeasible:
                                             [_relax updateUpperBound:vi with:ub];
                                             [_p gthen:vi with:g];
                                             lb = g + 1;
                                             break;
                                          default:break;
                                       }
                                       [_relax updateUpperBound:vi with:ub];
                                       [_relax updateLowerBound:vi with:g+1];
                                       OROutcome sUp = [_relax solve];
                                       hasUp = sUp == ORoptimal;
                                       switch(sUp) {
                                          case ORoptimal:
                                             roUp = [_relax objective];
                                             upRate = _flip * (roUp - io) / um;
                                             break;
                                          case ORinfeasible:
                                             [_relax updateLowerBound:vi with:lb];
                                             [_p lthen:vi with:g+1];
                                             ub = g;
                                             break;
                                          default:
                                             break;
                                       }
                                       [_relax updateLowerBound:vi with:lb];
                                       [_relax solve];
                                       if (sLow == ORinfeasible && sUp == ORinfeasible)
                                          [[_p explorer] fail];
                                       if (sLow == ORinfeasible || sUp == ORinfeasible) {
                                          i -= 1;
                                          continue;
                                       }
                                       //assert(fok != ORinfeasible);
                                       //printf("DOWN/UP(%d) [%f]  = %f,%f\n",vi.getId,vir,downRate,upRate);
                                       VStat* vs = [_pc objectForKey:@(vi.getId)];
                                       if (vs==nil) {
                                          vs = [[VStat alloc] init];
                                          [_pc setObject:vs forKey:@(vi.getId)];
                                          [vs release];
                                       }
                                       if (hasDown) [vs recordLow:downRate];
                                       if (hasUp)   [vs recordUp:upRate];
                                       if (hasDown) [_overallDown recordSample:downRate];
                                       if (hasUp)   [_overallUp recordSample:upRate];
                                    }
                                 }
                              }];
}

-(void)dealloc
{
   [_pc release];
   [_overallDown release];
   [_overallUp release];
   [super dealloc];
}
-(VStat*)pCost:(id<ORVar>)x
{
   NSNumber* key = [NSNumber numberWithInt:x.getId];
   VStat* vs = [_pc objectForKey:key];
   [key release];
   return vs;
}
-(ORBool)selectVar:(id<ORIntVarArray>)x index:(ORInt*)k  value:(ORDouble*)rv
{
//   OROutcome oc = [_relax solve];
//   if (oc == ORinfeasible)
//       [[_p explorer] fail];
   ORInt  bk = _vars.range.low - 1;
   __block ORBool   found = NO;
   ORDouble BSF =  - MAXDBL;
   ORInt    BDS = FDMININT;
   ORDouble brk = 0.0;
   //ORInt nbVars = x.range.size;
   ORInt nbFree = 0;
   ORInt nbCand = 0;
   //NSLog(@"PCBranching:");
   ORDouble q;
   //const ORDouble MU = 0.6;
   for(ORInt i=x.range.low;i <= x.range.up;i++) {
      if ([_p bound:x[i]])
         continue;
      nbFree += 1;
      double vir = [_relax value:x[i]];
      double g   = 0;
      double f   = modf(vir,&g);
      if (f == 0) continue;
      ORInt dsz = [_p domsize:x[i]];
      nbCand++;
      double fn  = f, fp = 1.0 - f;
      VStat* pc = [self pCost:x[i]];
      if (!pc) {
         ORDouble dm = f,um = 1.0 - f;
         ORDouble io = [_relax objective];
         ORDouble roDown,downRate,roUp,upRate;
         id<ORIntVar> vi = x[i];
         double lb = [_relax lowerBound:vi],ub = [_relax upperBound:vi];
         [_relax updateUpperBound:vi with:g];
         OROutcome sLow = [_relax solve];
         switch(sLow) {
            case ORoptimal:
               roDown = [_relax objective];
               downRate = _flip * fabs(roDown - io) / dm;
               break;
            default:break;
         }
         [_relax updateUpperBound:vi with:ub];
         [_relax updateLowerBound:vi with:g+1];
         OROutcome sUp = [_relax solve];
         switch(sUp) {
            case ORoptimal:
               roUp = [_relax objective];
               upRate = _flip * fabs(roUp - io) / um;
               break;
            default:
               break;
         }
         [_relax updateLowerBound:vi with:lb];
         [_relax solve];
         //assert(back == ORoptimal); // back is return value from [_relax solve];

         if (sLow == ORinfeasible && sUp == ORinfeasible)
            [[_p explorer] fail];
         if (sLow == ORoptimal) [self recordVar:x[i] low:downRate];
         if (sUp == ORoptimal)  [self recordVar:x[i] up:upRate];
         pc = [self pCost:x[i]];
      }
      q = [pc scoreWn:fn Wp:fp];
      
      if (q > BSF) {
         bk = i;
         brk = vir;
         found = YES;
         BSF = q;
         BDS = dsz;
      }
   }
   if (found) {
      *k = bk;
      *rv = brk;
   }
   //NSLog(@"PCBranching: #vars(%d) BEST(%d) : %f",nbCand,bk,BSF);
   //NSLog(@"Overall: %@ | %@",_overallDown,_overallUp);
   return found;
}

-(void)theSearch:(id<ORIntVarArray>)x
{
   while (![_p allBound:x]) {
      ORDouble fv;
      ORInt    bi;
      ORBool ok = [self selectVar:x index:&bi value:&fv];
      if (ok) {
         ORInt im = floor(fv);
         [_p try:^{
            [self measureDown:x[bi] relaxedValue:fv for: ^{
               [_p lthen:x[bi] with:im+1];
            }];
         } alt:^{
            [self measureUp:x[bi] relaxedValue:fv for:^{
               [_p gthen:x[bi] with:im];
            }];
         }];
      } else {
         // Not everyone is bound, but everyone looks integral.
         // Try to bind them via probing.
         [self fixAndDive:_vars];
         [[_p explorer] fail];
         break;
      }
   }
}
-(void)recordVar:(id<ORVar>)x low:(double)low
{
   VStat* vs = [_pc objectForKey:@(x.getId)];
   if (vs==nil) {
      vs = [[VStat alloc] init];
      [_pc setObject:vs forKey:@(x.getId)];
      [vs release];
   }
   [vs recordLow:low];
   [_overallDown recordSample:low];
}
-(void)recordVar:(id<ORVar>)x up:(double)up
{
   VStat* vs = [_pc objectForKey:@(x.getId)];
   if (vs==nil) {
      vs = [[VStat alloc] init];
      [_pc setObject:vs forKey:@(x.getId)];
      [vs release];
   }
   [vs recordUp:up];
   [_overallUp recordSample:up];
}
static long nbCall = 0;
-(void)measureDown:(id<ORVar>)x relaxedValue:(ORDouble)xv  for:(ORClosure)cl
{
   double xi = 0;
   double xf = modf(xv,&xi);
   double m  = xf;
   double f0 = [_relax objective];
   cl();
   double f1 = [_relax objective];
//   assert(f1 - f0 >= -0.0000001);
   if (++nbCall % 1000 == 0)
      NSLog(@"↓ relax: %f",f1);
   double df = _flip * (f1 - f0);
   double downRate = df / m;
   assert(!isnan(downRate));
//   if (fabs(df) > 0.001)
   [self recordVar:x low:downRate];
}
-(void)measureUp:(id<ORVar>)x relaxedValue:(ORDouble)xv for:(ORClosure)cl
{
   double xi = 0;
   double xf = modf(xv,&xi);
   double m  = 1.0 - xf;
   double f0 = [_relax objective];
   cl();
   double f1 = [_relax objective];
//   assert(f1 - f0 >= -0.0000001);
   if (++nbCall % 1000 == 0)
      NSLog(@"↑ relax: %f",f1);
   double df = _flip * (f1 - f0);
   double upRate = df / m;
   assert(!isnan(upRate));
//   if (fabs(df) > 0.001)
   [self recordVar:x up:upRate];
}
@end

@implementation FSBranching {
   id<ORIntVarArray>   _vars;
   ORDouble            _flip;
}
-(id)init:(id<ORRelaxation>)relax over:(id<ORIntVarArray>)vars program:(id<CPCommonProgram>)p
{
   self =  [super init:p relax:relax];
   _vars  = vars;
   _flip = [[_p objective] isMinimization] ? 1.0 : -1.0;
   return self;
}
-(ORBool)selectVar:(id<ORIntVarArray>)x index:(ORInt*)k  value:(ORDouble*)rv
{
   const NSUInteger vsz = [x count];
   int low  = x.range.low;
   double vr[vsz];
   int nbFrac = 0;
   ORDouble io = [_relax objective];
   for(ORInt i=low;i <= x.range.up;i++) {
      double xr,xi;
      vr[i - low] = xr = [_relax value:x[i]];
      double xf = modf(xr,&xi);
      nbFrac += (xf != 0);
   }
   if (nbFrac == 0) {
      return NO;
   } else {
      int idx[nbFrac];
      ORDouble cup[nbFrac];
      ORDouble cdw[nbFrac];
      ORDouble roDown,roUp;
      ORDouble downRate,upRate;
      int lastX = 0;
      for(ORInt i=low;i <= x.range.up;i++) {
         double xi;
         double xf = modf(vr[i-low],&xi);
         ORDouble dm = xf, um = 1.0 - xf;
         if (xf != 0) {
            id<ORIntVar> vi = x[i];
            idx[lastX] = i;
            double lb = [_relax lowerBound:vi];
            double ub = [_relax upperBound:vi];
            [_relax updateUpperBound:vi with:xi];
            OROutcome sLow = [_relax solve];
            switch(sLow) {
               case ORoptimal:
                  roDown = [_relax objective];
                  downRate = _flip * fabs(roDown - io) / dm;
                  break;
               case ORinfeasible:
                  [_relax updateUpperBound:vi with:ub];
                  //[_relax updateLowerBound:vi with:xi+1];
                  [_p gthen:vi with:xi];
                  lb = xi + 1;
                  break;
               default:break;
            }
            [_relax updateUpperBound:vi with:ub];
            [_relax updateLowerBound:vi with:xi+1];
            OROutcome sUp = [_relax solve];
            switch(sUp) {
               case ORoptimal:
                  roUp = [_relax objective];
                  upRate = _flip * fabs(roUp - io) / um;
                  break;
               case ORinfeasible:
                  [_relax updateLowerBound:vi with:lb];
                  //[_relax updateUpperBound:vi with:xi];
                  [_p lthen:vi with:xi+1];
                  ub = xi;
                  break;
               default:
                  break;
            }
            [_relax updateLowerBound:vi with:lb];
            if (sLow == ORinfeasible && sUp == ORinfeasible)
               [[_p explorer] fail];
            [_relax solve]; // OROutcome back =
            //assert(back == ORoptimal);
            double finalOBJ = [_relax objective];
            io = finalOBJ;
            //assert(fabs(finalOBJ - io) <= 0.000001);
            if (sLow == ORinfeasible || sUp == ORinfeasible) {
               vr[i - low] = [_relax value:x[i]];  // refresh relaxation
               i -= 1; // redo the same var.
               continue;
            }
            cup[lastX] = upRate;
            cdw[lastX] = downRate;
            lastX++;
            //printf("DOWN/UP(%d) [%f]  = %f,%f\n",vi.getId,vr[i-low],downRate,upRate);
         }
      }
      ORInt bi = 0;
      ORDouble best = - DBL_MAX;
      ORDouble mf   = 1.0;
      NSLog(@"FSBranching: #vars to consider: %d",lastX);
      for(ORInt i=0;i<lastX;i++) {
         //ORDouble rx = vr[idx[i] - low];
         //ORDouble xi;
         //ORDouble xf = modf(rx,&xi);
         //ORDouble wn = xf,wp = 1.0 - xf;
         //static const double mu = 1.0 / 6.0;
         //double qn = wn * cdw[i];
         //double qp = wp * cup[i];
         //ORDouble wi0 = (1 - mu) * minDbl(qn,qp) + mu * maxDbl(qn,qp);
         ORDouble wi = maxDbl(cdw[i],1.0e-16) * maxDbl(cup[i],1.0e-16);
         
         //ORDouble wi = minDbl(cup[i],cdw[i]);

         NSLog(@"\tSB(%d) %3.15f : cdw/cup = %3.15f | %3.15f",idx[i],wi,cdw[i],cup[i]);
         
         if (wi > best) {
            best = wi;
            bi   = idx[i];
            mf   = 1.0;
         } else if (wi == best) {
            ORDouble ip;
            ORDouble fv = vr[idx[i] - low];
            ORDouble fp = modf(fv,&ip);
            ORDouble fc = fabs(fp - 0.5);
            if (fc < mf) {
               mf = fc;
               best = wi;
               bi = idx[i];
            }
         }
      }
      *k = bi;
      *rv = vr[bi - low];
      NSLog(@"FSBranching: #vars(%d) BEST(%d): %f",lastX,bi,best);
      return TRUE;
   }
}
@end
