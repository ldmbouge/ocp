//
//  PCBranching.m
//  Clo
//
//  Created by Laurent Michel on 4/12/16.
//
//

#import "PCBranching.h"
#include <math.h>

#define ALPHAVALUE 2.0

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
   _nbl++;
   _down = (_down * (ALPHAVALUE - 1.0) + d) / ALPHAVALUE;
   assert(!isnan(_down));
}
-(void)recordUp:(double)u
{
   _nbu++;
   _up   = (_up   * (ALPHAVALUE - 1.0) + u) / ALPHAVALUE;
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
   return (1 - mu) * minDbl(qn,qp) + mu * maxDbl(qn,qp);
}
@end

@implementation PCBranching {
   id<ORRelaxation>   _relax;
   id<ORIntVarArray>   _vars;
   id<CPCommonProgram>    _p;
   NSMutableDictionary*  _pc;
   ORDouble            _flip;
   VStat*           _overall;
}
-(id)init:(id<ORRelaxation>)relax over:(id<ORIntVarArray>)vars program:(id<CPCommonProgram>)p
{
   self =  [super init];
   _relax = relax;
   _vars  = vars;
   _p     = p;
   _flip = [[_p objective] isMinimization] ? 1.0 : -1.0;
   _overall = [[VStat alloc] init];
   _pc    = [[NSMutableDictionary alloc] init];
   [[p explorer] applyController:[[ORSemDFSController alloc] initTheController:[p tracer] engine:[p engine] posting:nil]
   in:^{
      double io = [relax objective];
      for(ORInt i=_vars.range.low;i <= _vars.range.up;i++) {
         id<ORIntVar> vi = _vars[i];
         double vir = [_relax value:vi];
         NSLog(@"x[%3d]  [%d,%d] ~= %4.20f",i,[_p min:vi],[_p max:vi],vir);
         double g   = 0;
         double f   = modf(vir,&g);
         if (f != 0) {
            double dm  = f,um  = 1.0 - f;
            double roDown=0.0,roUp=0.0;
            ORBool hasDown,hasUp;
            __block ORDouble downRate = 0;
            __block ORDouble upRate   = 0;
            double lb = [relax lowerBound:vi];
            double ub = [relax upperBound:vi];
            [relax updateUpperBound:vi with:g];
            OROutcome sLow = [relax solve];
            hasDown = sLow == ORoptimal;
            switch(sLow) {
               case ORoptimal:
                  roDown = [relax objective];
                  downRate = _flip * (roDown - io) / dm;
                  break;
               case ORinfeasible:
                  break;
               default:break;
            }
            [relax updateUpperBound:vi with:ub];
            [relax updateLowerBound:vi with:g+1];
            OROutcome sUp = [relax solve];
            hasUp = sUp == ORoptimal;
            switch(sUp) {
               case ORoptimal:
                  roUp = [relax objective];
                  upRate = _flip * (roUp - io) / um;
                  break;
               case ORinfeasible:
                  break;
               default:
                  break;
            }
            [relax updateLowerBound:vi with:lb];
//            OROutcome back = [relax solve];
//            assert(back == ORoptimal);
//            double finalOBJ = [relax objective];
//            assert(finalOBJ==io);
            printf("DOWN/UP(%d) [%f]  = %f,%f\n",vi.getId,vir,roDown,roUp);
            VStat* vs = [_pc objectForKey:@(vi.getId)];
            if (vs==nil) {
               vs = [[VStat alloc] init];
               [_pc setObject:vs forKey:@(vi.getId)];
               [vs release];
            }
            if (hasDown) [vs recordLow:downRate];
            if (hasUp)   [vs recordUp:upRate];
            if (hasDown) [_overall recordLow:downRate];
            if (hasUp)   [_overall recordUp:upRate];
         }
      }
   }];
   return self;
}
-(void)dealloc
{
   [_pc release];
   [_overall release];
   [super dealloc];
}
-(VStat*)pCost:(id<ORVar>)x
{
   NSNumber* key = [NSNumber numberWithInt:x.getId];
   VStat* vs = [_pc objectForKey:key];
   [key release];
   return vs ? vs : _overall;
}
-(ORBool)selectVar:(id<ORIntVarArray>)x index:(ORInt*)k  value:(ORDouble*)rv
{
   OROutcome oc = [_relax solve];
   if (oc == ORinfeasible)
       [[_p explorer] fail];
//   for(ORInt i=x.range.low;i <= x.range.up;i++) {
//      NSLog(@"SVAR: x[%d] ~= %f",i,[_relax value:x[i]]);
//   }
   ORInt  bk = _vars.range.low - 1;
   __block ORBool   found = NO;
   ORDouble BSF =  - MAXDBL;
   ORDouble brk = 0.0;
   for(ORInt i=x.range.low;i <= x.range.up;i++) {
      if ([_p bound:x[i]])
         continue;
/*
      ORInt xisz = [_p domsize:x[i]];
      ORInt xiSpan = [_p max:x[i]] - [_p min:x[i]] + 1;
      ORBool gap   = xisz != xiSpan;
      if (gap) {
         ORInt ub= [_p max:x[i]];
         for(ORInt d = [_p min:x[i]]; d <= ub;d++) {
            if (![_p member:d in:x[i]]) {
               *k = i;
               *rv = (ORDouble)d;
               return YES;
            }
         }
      }
      */
      
      double vir = [_relax value:x[i]];
      double g   = 0;
      double f   = modf(vir,&g);
      if (f == 0) continue;
      double fn  = f, fp = 1.0 - f;
      VStat* pc = [self pCost:x[i]];
      assert(pc != nil);
      double q = [pc scoreWn:fn Wp:fp];
      //NSLog(@"VAR[%d] pCost = %@\t relax=%f \t score = %f",i,pc,vir,q);
      if (q > BSF) {
         bk = i;
         brk = vir;
         found = YES;
         BSF = q;
      }
   }
   if (found) {
      *k = bk;
      *rv = brk;
      return found;
   } else {
      [self probe:_vars];
//      [_p select:_vars minimizing:^ORDouble(ORInt i) { return [_p domsize:x[i]];}
//              in:^void(ORInt i) {
//                 ORInt min = [_p min:x[i]],max = [_p max:x[i]];
//                 ORInt mid = min + (max-min)/2;
//                 *k = i;
//                 *rv = mid;
//                 found =  YES;
//              }];
      return found;
   }
}
-(void)branchOn:(id<ORIntVarArray>)x
{
   while (![_p allBound:x]) {
      ORDouble fv;
      ORInt    bi;
      ORBool ok = [self selectVar:x index:&bi value:&fv];
      if (ok) {
         ORInt im = floor(fv);
         [_p try:^{
            [self measureUp:x[bi] relaxedValue:fv for:^{
               [_p gthen:x[bi] with:im];
            }];
         } alt:^{
            [self measureDown:x[bi] relaxedValue:fv for: ^{
               [_p lthen:x[bi] with:im+1];
            }];
         }];
      } else {
         NSLog(@"Found nothing to branch on?");
         break;
      }
   }
}
-(void)probe:(id<ORIntVarArray>)x
{
   [_p nestedSolve:^{
      [_p once:^{
         __block ORInt reached = x.range.low - 1;
         [_p try:^{
            for(ORInt i=x.range.low; i <= x.range.up;i++) {
               if ([_p bound:x[i]])
                  continue;
               ORInt rv = rint([_relax value:x[i]]);
               [_p label:x[i] with:rv];
               reached = i;
            }
            [[_p objective] updatePrimalBound];
            NSLog(@"Probe successful! %@",[_p objectiveValue]);
         } alt:^{
            NSLog(@"Rounding probe failed... Reached [%d]",reached);
         }];
      }];
   } onSolution:^{
      [_p doOnSolution];
      NSLog(@"inside nested onSolution");
   } onExit:nil
    control:  [[ORSemDFSController proto] clone]
   ];
   NSLog(@"BACK FROM nestedSolve...");
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
   [_overall recordLow:low];
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
   [_overall recordUp:up];
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
   if (++nbCall % 100 == 0)
      NSLog(@"↓ relax: %f",f1);
   double df = _flip * (f1 - f0);
   double downRate = df / m;
   assert(!isnan(downRate));
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
   if (++nbCall % 100 == 0)
      NSLog(@"↑ relax: %f",f1);
   double df = _flip * (f1 - f0);
   double upRate = df / m;
   assert(!isnan(upRate));
   [self recordVar:x up:upRate];
}
@end
