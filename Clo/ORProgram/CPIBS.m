/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPIBS.h"
#import <ORFoundation/ORTracer.h>
#import <CPUKernel/CPUKernel.h>
#import <objcp/CPStatisticsMonitor.h>
#import <objcp/CPVar.h>
#import "CPConcretizer.h"

#if defined(__linux__)
#import <values.h>
#endif

@interface CPKillRange : NSObject {
@package
   ORInt _low;
   ORInt _up;
   ORUInt _nbKilled;
}
-(id)initCPKillRange:(ORInt)f to:(ORInt)to size:(ORUInt)sz;
-(void)dealloc;
-(ORBool)isEqual:(CPKillRange*)kr;
-(ORInt) low;
-(ORInt) up;
-(ORInt) killed;
@end

@implementation CPKillRange 
-(id)initCPKillRange:(ORInt)f to:(ORInt)to  size:(ORUInt)sz
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
-(ORBool)isEqual:(CPKillRange*)kr
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

@interface CPAssignImpact : NSObject {
   id<ORIntVar>  _var;
   double*      _imps;
   ORUInt _nbVals;
   ORBounds      _dom;
   double*        _mu;
   double*      _vari;
   ORUInt*   _cnts;
}
-(CPAssignImpact*)initCPAssignImpact:(id<ORIntVar>)theVar;
-(void)dealloc;
-(void)addImpact:(double)i forValue:(ORInt)val;
-(void)setImpact:(double)i forValue:(ORInt)val;
-(double)impactForValue:(ORInt)val;
-(double)impactForVariable;
@end

@implementation CPAssignImpact
-(CPAssignImpact*)initCPAssignImpact:(id<ORIntVar>)theVar
{
   self = [super init];
   _var = theVar;
   _dom = [theVar bounds];
   _nbVals = _dom.max - _dom.min + 1;
   if (_nbVals >= 8192) {
      _imps = _mu = _vari = NULL;
      _cnts = NULL;
   } else {
      _imps = malloc(sizeof(double)*_nbVals);
      _imps -= _dom.min;
      _mu = malloc(sizeof(double)*_nbVals);
      _mu -= _dom.min;
      _vari = malloc(sizeof(double)*_nbVals);
      _vari -= _dom.min;
      _cnts = malloc(sizeof(ORUInt)*_nbVals);
      _cnts -= _dom.min;
      for(ORUInt k=_dom.min;k<=_dom.max;k++) {
         _cnts[k] = 0;
         _imps[k] = _mu[k] = _vari[k] = 0.0;
      }
   }
   return self;
}
-(void)dealloc
{
   if (_imps) {
      _imps += _dom.min;
      _mu += _dom.min;
      _vari += _dom.min;
      _cnts += _dom.min;
      free(_imps);
      free(_mu);
      free(_vari);
      free(_cnts);
   }
   [super dealloc];
}
-(void)addImpact:(double)i forValue:(ORInt)val
{
   if (_imps) {
      _imps[val] = (_imps[val] * (ALPHA - 1.0) + i) / ALPHA;
      double oldMu = _mu[val];
      _mu[val] = (_cnts[val] * _mu[val] + i)/(_cnts[val]+1);
      _vari[val] = _vari[val] + (i - _mu[val]) * (i - oldMu);
      _cnts[val] = _cnts[val] + 1;
   }
}
-(void)setImpact:(double)i forValue:(ORInt)val
{
   if (_imps) {
      _imps[val] = i;
      _mu[val]   = i;
      _vari[val] = 0.0;
      _cnts[val] = 1;
   }
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"impact[%3d] = %f",[_var getId],[self impactForVariable]];   
   return buf;
}
-(double)impactForValue:(ORInt)val
{
   return _imps != NULL ? _imps[val] : 0.0;
}
-(double)impactForVariable
{
   if (_imps) {
      ORBounds cb = [_var bounds];
      double rv = 0.0;
      for(ORInt i = cb.min;i <= cb.max;i++) {
         if (![_var member:i]) continue;
         rv += 1.0 - _imps[i];
      }
      return - rv;
   } else return - MAXFLOAT;
}
@end

@implementation CPIBS {
   id<CPEngine>             _engine;
   CPStatisticsMonitor*    _monitor;
   ORULong                     _nbv;
   NSMutableDictionary*    _impacts;
}

-(id)initCPIBS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars
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
   CPIBS* cp = [[CPIBS alloc] initCPIBS:_cp restricted:_rvars];
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

-(ORFloat)varOrdering:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
   double rv = [[_impacts objectForKey:key] impactForVariable];
   [key release];
   return rv;
}
-(ORFloat)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
   double rv = [[_impacts objectForKey:key] impactForValue:v];
   [key release];
   return rv;
}
// pvh: this dictionary business seems pretty heavy; lots of memory allocation
-(void)initInternal:(id<ORVarArray>)t
{
   _vars = t;   
   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:[_cp engine] vars:[self allIntVars]];
   _nbv = [_vars count];
   _impacts = [[NSMutableDictionary alloc] initWithCapacity:_nbv];
   ORInt low = [_vars low],up = [_vars up];
   for(ORUInt i=low;i<=up;i++) {
      //NSLog(@"impacting: %@",[_vars at:i]);
      CPAssignImpact* assigns = [[CPAssignImpact alloc] initCPAssignImpact:(id<ORIntVar>)[_vars at:i]];
      [_impacts setObject:assigns forKey:[NSNumber numberWithInteger:[[_vars at:i] getId]]];
      [assigns release];  // [ldm] the assignment impacts for t[i] is now in the dico with a refcnt==1
   }
   [_engine post:_monitor];
   [self initImpacts];       // [ldm] init called _after_ adding the monitor so that the reduction is tracked (but before watching label)
   [[[_cp portal] retLabel] wheneverNotifiedDo:^void(id var,ORInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      [[_impacts objectForKey:key] addImpact:1.0 - [_monitor reduction] forValue:val];
      [key release];      
   }];
   [[[_cp portal] failLabel] wheneverNotifiedDo:^void(id var,ORInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      [[_impacts objectForKey:key] addImpact: 1.0 forValue:val];
      [key release];
   }];
   [[_cp engine] clearStatus];
   [[_cp engine] enforceObjective];
   if ([[_cp engine] objective] != NULL)
      NSLog(@"IBS ready... %@",[[_cp engine] objective]);
   else
      NSLog(@"IBS ready... ");
}

-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(void)addKillSetFrom:(ORInt)from to:(ORInt)to size:(ORUInt)sz into:(NSMutableSet*)set
{
   for(CPKillRange* kr in set) {
      if (to+1 == kr->_low) {
         CPKillRange* newRange = [[CPKillRange alloc] initCPKillRange:from to:kr->_up size:kr->_nbKilled + sz];
         [set addObject:newRange];
         [newRange release];
         [set removeObject:kr];
         return;
      } else if (kr->_up + 1 == from) {
         CPKillRange* newRange = [[CPKillRange alloc] initCPKillRange:kr->_low to:to size:kr->_nbKilled + sz];
         [set addObject:newRange];
         [newRange release];
         [set removeObject:kr];
         return;         
      }
   }
   CPKillRange* newRange = [[CPKillRange alloc] initCPKillRange:from to:to size:sz];
   [set addObject:newRange];
   [newRange release];
   return;
}

-(void)dichotomize:(id<CPIntVar>)x from:(ORInt)low to:(ORInt)up block:(ORInt)b sac:(NSMutableSet*)set
{
   if (up - low + 1 <= b) {
      float ks = 0.0;
      for(CPKillRange* kr in set)
         ks += [kr killed];
      
      double ir = 1.0 - [_monitor reductionFromRootForVar:x extraLosses:ks];
      NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
      //NSLog(@"base: [%d .. %d]impact (%@) = %lf",low,up,key,ir);
      CPAssignImpact* vImpact = [_impacts objectForKey:key];
      for(ORInt c = low ; c <= up;c++) {
         [vImpact setImpact:ir forValue:c];
      }
      [key release];
   } else {
      ORInt mid = low + (up - low)/2;
      id<ORTracer> tracer = [_cp tracer];
      [tracer pushNode];
      ORStatus s1 = [_engine enforce:^ORStatus { return [x updateMax:mid];}]; //  lthen:x with:mid+1];
      [ORConcurrency pumpEvents];
      if (s1!=ORFailure) {
         [self dichotomize:x from:low to:mid block:b sac:set];
      } else { 
         // [ldm] We know that x IN [l..mid] leads to an inconsistency. -> record a SAC.
         [self addKillSetFrom:low to:mid size:[x countFrom:low to:mid] into:set];          
      }
      [tracer popNode];
      [tracer pushNode];
      ORStatus s2 = [_engine enforce: ^ORStatus { return [x updateMin:mid+1];}];// gthen:x with:mid];
      [ORConcurrency pumpEvents];
      if (s2!=ORFailure) {
         [self dichotomize:x from:mid+1 to:up block:b sac:set];
      } else {
         // [ldm] We know that x IN [mid+1..up] leads to an inconsistency. -> record a SAC.
         [self addKillSetFrom:mid+1 to:up size:[x countFrom:mid+1 to:up] into:set];
      }      
      [tracer popNode];      
   }
}
-(void)initImpacts
{
   ORInt blockWidth = 1;
   id<CPIntVarArray> av = [self allIntVars];
   ORInt low = [av low],up = [av up];
   for(ORInt k=low; k <= up;k++) {
      NSMutableSet* sacs = [[NSMutableSet alloc] initWithCapacity:2];
      id<CPIntVar> v = (id<CPIntVar>)_vars[k];
      ORBounds vb = [v bounds];
      [_monitor rootRefresh];
      [self dichotomize:v from:vb.min to:vb.max block:blockWidth sac:sacs];
      ORInt rank = 0;
      ORInt lastRank = (ORInt)[sacs count]-1;
      for(CPKillRange* kr in sacs) {
         if (rank == 0 && [kr low] == [v min]) {
            [_engine enforce: ^ORStatus { return [v updateMin:[kr up]+1];}];  // gthen:v with:[kr up]];
         } else if (rank == lastRank && [kr up] == [v max]) {
            [_engine enforce: ^ORStatus { return [v updateMax:[kr low]-1];}]; // lthen:v with:[kr low]];
         } else {
            for(ORInt i=[kr low];i <= [kr up];i++)
               [_engine enforce: ^ORStatus { return [v remove:i];}];// diff:v with:i];
         }
         rank++;
      }
      [sacs release];
      //NSLog(@"ROUND(X) : %@  impact: %f",v,[self varOrdering:v]);
   }
   //NSLog(@"VARS AT END OF INIT:%@ ",av);
}
@end
