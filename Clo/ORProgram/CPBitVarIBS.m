/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPBitVarIBS.h"
#import <ORFoundation/ORTracer.h>
#import <CPUKernel/CPUKernel.h>
#import <objcp/CPStatisticsMonitor.h>
#import <objcp/CPVar.h>
#import <objcp/CPBitVar.h>
#import "CPConcretizer.h"
#import <ORFoundation/ORFactory.h>
#import <ORProgram.h>
#import <objcp/CPBitVarI.h>


#if defined(__linux__)
#import <values.h>
#endif

@interface CPBitVarKillRange : NSObject {
   @package
   ORInt _low;
   ORInt _up;
   ORUInt _nbKilled;
}
-(id)initCPBitVarKillRange:(ORInt)f to:(ORInt)to size:(ORUInt)sz;
-(void)dealloc;
-(BOOL)isEqual:(CPBitVarKillRange*)kr;
-(ORInt) low;
-(ORInt) up;
-(ORInt) killed;
@end

@implementation CPBitVarKillRange
-(id)initCPBitVarKillRange:(ORInt)f to:(ORInt)to  size:(ORUInt)sz
{
   self = [super init];
   _low = f;
   _up  = to;
   _nbKilled = sz;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(BOOL)isEqual:(CPBitVarKillRange*)kr
{
   return (_low == kr->_low && _up == kr->_up);
}
-(ORInt) low
{
   return _low;
}
-(ORInt) up
{
   return _up;
}
-(ORInt) killed
{
   return _nbKilled;
}
@end

@interface CPBitVarAssignImpact : NSObject {
   id<CPBitVar>  _var;
   double**     _imps;
   ORUInt     _nbVals;
   ORBounds      _dom;
   double*        _mu;
   double*      _vari;
   ORUInt*      _cnts;
}
-(CPBitVarAssignImpact*)initCPBitVarAssignImpact:(id<CPBitVar>)theVar;
-(void)dealloc;
-(void)addImpact:(double)i forValue:(ORBool)val atIndex:(ORUInt)idx;
-(void)setImpact:(double)i forValue:(ORBool)val atIndex:(ORUInt)idx;
-(double)impactForValue:(ORBool)val atIndex:(ORUInt)idx;
-(double)impactForVariable;
@end

@implementation CPBitVarAssignImpact
-(CPBitVarAssignImpact*)initCPBitVarAssignImpact:(id<CPBitVar>)theVar
{
   self = [super init];
//   NSAssert([theVar isKindOfClass:[CPBitVarI class]], @"%@ should be kind of class %@", theVar, [[CPBitVarI class] description]);
   _var = theVar;
   _dom.min = [theVar lsFreeBit];
   _dom.max = [theVar msFreeBit];
   _nbVals = [theVar bitLength];
   _imps = (double**)malloc(sizeof(double*)*_nbVals);
   
   for(int i=0;i<_nbVals;i++)
      _imps[i] = malloc((sizeof(double))*2);

   _mu = malloc(sizeof(double)*_nbVals);
   //_mu -= _dom.min;
   _vari = malloc(sizeof(double)*_nbVals);
   //_vari -= _dom.min;
   _cnts = malloc(sizeof(ORUInt)*_nbVals);
   //_cnts -= _dom.min;
   for(ORUInt k=_dom.min;k<=_dom.max;k++) {
      _cnts[k] = 0;
      _mu[k] = _vari[k] = 0.0;
      for(ORUInt j=0; j<2;j++)
      _imps[k][j] = 0.0;
      }
   return self;
}
-(void)dealloc
{
   
   if (_imps) {
      for(int i=0;i<_nbVals;i++)
         free(_imps[i]);
      free(_imps);
      free(_mu);
      free(_vari);
      free(_cnts);
   }
   [super dealloc];
}
-(void)addImpact:(double)i forValue:(ORBool)val atIndex:(ORUInt)idx
{
   ORUInt vIndex;
   
   if (val)
      vIndex = 0;
   else
      vIndex = 1;

   if (_imps) {
      _imps[idx][vIndex] = (_imps[idx][vIndex] * (ALPHA - 1.0) + i) / ALPHA;
      double oldMu = _mu[idx];
      _mu[idx] = (_cnts[idx] * _mu[idx] + i)/(_cnts[idx]+1);
      _vari[idx] = _vari[idx] + (i - _mu[idx]) * (i - oldMu);
      _cnts[idx] = _cnts[idx] + 1;
   }
}
-(void)setImpact:(double)i forValue:(ORBool)val atIndex:(ORUInt)idx
{
   ORUInt vIndex;
   
   if (val)
      vIndex = 0;
   else
      vIndex = 1;

   if (_imps) {
      _imps[idx][vIndex] = i;
      _mu[idx]   = i;
      _vari[idx] = 0.0;
      _cnts[idx] = 1;
   }
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"impact[%3d] = %f",[_var getId],[self impactForVariable]];
   return buf;
}
-(double)impactForValue:(ORBool)val atIndex:(ORUInt)idx
{
   ORUInt vIndex;
   
   if (val)
      vIndex = 0;
   else
      vIndex = 1;

   return _imps != NULL ? _imps[idx][vIndex] : 0.0;
}
-(double)impactForVariable
{
   
   if (_imps) {
      ORBounds cb;
      cb.min = [_var lsFreeBit];
      cb.max = [_var msFreeBit];
      double rv = 0.0;
      for(ORInt i = cb.min;i <= cb.max;i++) {
         if (![_var member:(unsigned int*)&i]) continue;
         rv += 1.0 - _imps[i][0];
         rv += 1.0 - _imps[i][1];
      }
      return - rv;
   } else return - MAXFLOAT;
}
@end

@implementation CPBitVarIBS {
   id<CPEngine>             _engine;
   CPStatisticsMonitor*    _monitor;
   ORULong                     _nbv;
   NSMutableDictionary*    _impacts;
}

-(id)initCPBitVarIBS:(id<CPCommonProgram>)cp restricted:(id<ORBitVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _engine = [cp engine];
   _monitor = nil;
   _vars = nil;
   _rvars = rvars;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPBitVarIBS* cp = [[CPBitVarIBS alloc] initCPBitVarIBS:_cp restricted:_rvars];
   return cp;
}
-(void)dealloc
{
   [_impacts release];
   [super dealloc];
}
-(id<CPCommonProgram>)solver
{
   return _cp;
}

-(ORDouble)varOrdering:(id<CPBitVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
   double rv = [[_impacts objectForKey:key] impactForVariable];
   [key release];
   return rv;
}
-(ORDouble)valOrdering:(ORBool)v forVar:(id<CPBitVar>)x atIndex:(ORUInt)idx
{
   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
   double rv = [[_impacts objectForKey:key] impactForValue:v atIndex:idx];
   [key release];
   return rv;
}
// pvh: this dictionary business seems pretty heavy; lots of memory allocation
-(void)initInternal:(id<ORBitVarArray>)t and:(id<CPBitVarArray>)cvs
{
   id* gamma = [_cp gamma];
   _vars = t;
   NSArray* allvars = [[_engine model] variables];
   id<ORIdArray> o = [ORFactory idArray:_engine range:[[ORIntRangeI alloc] initORIntRangeI:0 up:(ORUInt)[allvars count]]];
   for(int i=0; i< [allvars count];i++)
      [o set:allvars[i] at:i];

   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:[_cp engine] vars:(id<ORVarArray>)o];
   
   _nbv = [_rvars count];
   _impacts = [[NSMutableDictionary alloc] initWithCapacity:_nbv];
   
   
   for(ORUInt i=0;i< _nbv; i++) {
      if ([gamma[_rvars[i].getId] bound])
         continue;
      NSLog(@"impacting: %@",[t at:i]);
      CPBitVarAssignImpact* assigns = [[CPBitVarAssignImpact alloc] initCPBitVarAssignImpact:gamma[_rvars[i].getId]];
      [_impacts setObject:assigns forKey:[NSNumber numberWithInteger:[[t at:i] getId]]];
      [assigns release];  // [ldm] the assignment impacts for t[i] is now in the dico with a refcnt==1
   }
   [_engine post:_monitor];
   [self initImpacts];       // [ldm] init called _after_ adding the monitor so that the reduction is tracked (but before watching label)
   [[[_cp portal] retLabel] wheneverNotifiedDo:^void(id var, ORUInt idx, ORInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      [[_impacts objectForKey:key] addImpact:1.0 - [_monitor reduction] forValue:val atIndex:idx];
      [key release];
   }];
   [[[_cp portal] failLabel] wheneverNotifiedDo:^void(id var, ORUInt idx, ORInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      [[_impacts objectForKey:key] addImpact: 1.0 forValue:val atIndex:idx];
      [key release];
   }];
//   [[_cp engine] clearStatus];
   [[_cp engine] enforceObjective];
   if ([[_cp engine] objective] != NULL)
      NSLog(@"BitVar IBS ready... %@",[[_cp engine] objective]);
   else
      NSLog(@"BitVarIBS ready... ");
}

-(id<ORBitVarArray>)allBitVars
{
   return (id<ORBitVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(void)addKillSetFrom:(ORInt)from to:(ORInt)to size:(ORUInt)sz into:(NSMutableSet*)set
{
   for(CPBitVarKillRange* kr in set) {
      if (to+1 == kr->_low) {
         CPBitVarKillRange* newRange = [[CPBitVarKillRange alloc] initCPBitVarKillRange:from to:kr->_up size:kr->_nbKilled + sz];
         [set addObject:newRange];
         [newRange release];
         [set removeObject:kr];
         return;
      } else if (kr->_up + 1 == from) {
         CPBitVarKillRange* newRange = [[CPBitVarKillRange alloc] initCPBitVarKillRange:kr->_low to:to size:kr->_nbKilled + sz];
         [set addObject:newRange];
         [newRange release];
         [set removeObject:kr];
         return;
      }
   }
   CPBitVarKillRange* newRange = [[CPBitVarKillRange alloc] initCPBitVarKillRange:from to:to size:sz];
   [set addObject:newRange];
   [newRange release];
   return;
}

-(void)dichotomize:(id<CPBitVar>)x from:(ORInt)low to:(ORInt)up block:(ORInt)b sac:(NSMutableSet*)set
{
//   if (up - low + 1 <= b) {
//      float ks = 0.0;
//      for(CPBitVarKillRange* kr in set)
//         ks += [kr killed];
//      
//      double ir = 1.0 - [_monitor reductionFromRootForVar:x extraLosses:ks];
//      NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
//      //NSLog(@"base: [%d .. %d]impact (%@) = %lf",low,up,key,ir);
//      CPBitVarAssignImpact* vImpact = [_impacts objectForKey:key];
//      for(ORInt c = low ; c <= up;c++) {
//         [vImpact setImpact:ir forValue:false atIndex:c];
//         [vImpact setImpact:ir forValue:true atIndex:c];
//      }
//      [key release];
//   } else {
//      ORInt mid = low + (up - low)/2;
//      id<ORTracer> tracer = [_cp tracer];
//      [tracer pushNode];
//      ORStatus s1 = [_engine enforce:^{  [x updateMax:mid];}]; //  lthen:x with:mid+1];
//      [ORConcurrency pumpEvents];
//      if (s1!=ORFailure) {
//         [self dichotomize:x from:low to:mid block:b sac:set];
//      } else {
//         // [ldm] We know that x IN [l..mid] leads to an inconsistency. -> record a SAC.
//         [self addKillSetFrom:low to:mid size:[x countFrom:low to:mid] into:set];
//      }
//      [tracer popNode];
//      [tracer pushNode];
//      ORStatus s2 = [_engine enforce: ^void { [x updateMin:mid+1];}];// gthen:x with:mid];
//      [ORConcurrency pumpEvents];
//      if (s2!=ORFailure) {
//         [self dichotomize:x from:mid+1 to:up block:b sac:set];
//      } else {
//         // [ldm] We know that x IN [mid+1..up] leads to an inconsistency. -> record a SAC.
//         [self addKillSetFrom:mid+1 to:up size:[x countFrom:mid+1 to:up] into:set];
//      }
//      [tracer popNode];
//   }
}
-(void) computeBitVarImpacts:(id<CPBitVar>)x sac:(NSMutableSet*)set{
//
//   id<ORTracer> tracer = [_cp tracer];
//   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
//
//
//   for(int b=0; b < [x bitLength]; b++){
//      float ks = 0.0;
//      for(CPBitVarKillRange* kr in set)
//         ks += [kr killed];
//      
//      CPBitVarAssignImpact* vImpact = [_impacts objectForKey:key];
//
//
//      if ([x isFree:b]){
//      //cout << "var:" << x.getId() << ",bit:" << b  << endl;
//         [tracer pushNode];
//         ORStatus oc = [_engine enforce:^void{ [x bind:b to:true];}];
//         [ORConcurrency pumpEvents];
//         if (oc != ORFailure) {
//            double ir = 1.0 - [_monitor reductionFromRootForVar:x extraLosses:ks];
//            [vImpact setImpact:ir forValue:true atIndex:b];
////            _bstat[x.getId()].setImpact(b,true,ix0);
//            //cout << "RATIO:" << ix0 << "\tNBA:" << _nbA << endl;
//         }
//         
//         [tracer popNode];
//         if (oc == ORFailure) {
//            NSLog(@"FAILED impactBit(%@, %i to true )", x, b);
//            [x bind:b to:false];
//            
//         }
//         if (![x isFree:b]) continue;
//         [tracer pushNode];
//         oc = [_engine enforce:^void{ [x bind:b to:false];}];
//         [ORConcurrency pumpEvents];
//         if (oc!=ORFailure) {
//            double ir = 1.0 - [_monitor reductionFromRootForVar:x extraLosses:ks];
//            [vImpact setImpact:ir forValue:false atIndex:b];
//         }
//         [tracer popNode];
//         if (oc==ORFailure) {
//            NSLog(@"FAILED impactBit(%@, %i to false )", x, b);
//            [x bind:b to:true];
//         }
//      }
//   }
//   [key release];
}
-(void) impBitVar:(id<CPBitVar>) x sac:(NSMutableSet*)set {
   [self computeBitVarImpacts:x sac:set];
}

-(void)initImpacts
{
//   ORInt blockWidth = 1;
   id<CPBitVarArray> av = [self allBitVars];

   
   for(ORInt k=0; k <[av count];k++) {
      NSMutableSet* sacs = [[NSMutableSet alloc] initWithCapacity:2];   //TODO: currently sacs are not recorded separately
      id<CPBitVar> v = (id<CPBitVar>)[_cp gamma][av[k].getId];
      if ([v bound]) continue;
//      ORBounds vb = [v bounds];
//      [_monitor rootRefresh];
      //[self dichotomize:v from:vb.min to:vb.max block:blockWidth sac:sacs];
      [self impBitVar:v sac:sacs];
      NSLog(@"%lu SACs",(unsigned long)[sacs count]);
      ORInt rank = 0;
      ORInt lastRank = (ORInt)[sacs count]-1;
      for(CPBitVarKillRange* kr in sacs) {
         if (rank == 0 && [kr low] == [v min]) {
            [_engine enforce: ^void  {[v lsFreeBit];}];  // gthen:v with:[kr up]];
         } else if (rank == lastRank && [kr up] == [v max]) {
            [_engine enforce: ^void { [v msFreeBit];}]; // lthen:v with:[kr low]];
         } else {
            for(ORInt i=[kr low];i <= [kr up];i++)
               [_engine enforce: ^void { [v remove:i];}];// diff:v with:i];
         }
         rank++;
      }
      [sacs release];
      //NSLog(@"ROUND(X) : %@  impact: %f",v,[self varOrdering:v]);
   }
   NSLog(@"VARS AT END OF INIT:%@ ",av);
}
@end
