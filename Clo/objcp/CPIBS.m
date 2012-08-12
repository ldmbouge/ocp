/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <CPIBS.h>
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPMonitor.h"
#import "ORTracer.h"

@interface CPKillRange : NSObject {
@package
   CPInt _low;
   CPInt _up;
   CPUInt _nbKilled;
}
-(id)initCPKillRange:(ORInt)f to:(ORInt)to size:(CPUInt)sz;
-(void)dealloc;
-(BOOL)isEqual:(CPKillRange*)kr;
@end

@implementation CPKillRange 
-(id)initCPKillRange:(ORInt)f to:(ORInt)to  size:(CPUInt)sz
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
-(BOOL)isEqual:(CPKillRange*)kr
{
   return (_low == kr->_low && _up == kr->_up);
}
@end

@interface CPAssignImpact : NSObject {
   id<ORIntVar>  _var;
   double*      _imps;
   CPUInt _nbVals;
   CPBounds      _dom;
   double*        _mu;
   double*      _vari;
   CPUInt*   _cnts;
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
   [theVar bounds:&_dom];
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
      _cnts = malloc(sizeof(CPUInt)*_nbVals);
      _cnts -= _dom.min;
      for(CPUInt k=_dom.min;k<=_dom.max;k++) {
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

-(double)impactForValue:(ORInt)val
{
   return _imps != NULL ? _imps[val] : 0.0;
}
-(double)impactForVariable
{
   if (_imps) {
      CPBounds cb;
      [_var bounds:&cb];
      double rv = 0.0;
      for(CPInt i = cb.min;i <= cb.max;i++) {
         if (![_var member:i]) continue;
         rv += 1.0 - _imps[i];
      }
      return - rv;
   } else return - MAXFLOAT;
}
@end

@implementation CPIBS {
   CPEngineI*     _solver;
   CPMonitor*    _monitor;
   CPULong           _nbv;
   NSMutableDictionary*  _impacts;
}

-(id)initCPIBS:(id<CPSolver>)cp restricted:(id<CPVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _solver = (CPEngineI*)[cp engine];
   _monitor = nil;
   _vars = nil;
   _rvars = rvars;
   [cp addHeuristic:self];
   return self;
}
-(void)dealloc
{
   [_impacts release];
   [super dealloc];
}
-(float)varOrdering:(id<ORIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
   double rv = [[_impacts objectForKey:key] impactForVariable];
   [key release];
   return rv;
}
-(float)valOrdering:(int)v forVar:(id<ORIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
   double rv = [[_impacts objectForKey:key] impactForValue:v];
   [key release];
   return rv;
}
// pvh: this dictionary business seems pretty heavy; lots of memory allocation
-(void)initInternal:(id<CPVarArray>)t
{
   _vars = t;   
   _monitor = [[CPMonitor alloc] initCPMonitor:_cp vars:_vars];
   _nbv = [_vars count];
   _impacts = [[NSMutableDictionary alloc] initWithCapacity:_nbv];
   CPInt low = [_vars low],up = [_vars up];
   for(CPUInt i=low;i<=up;i++) {
      //NSLog(@"impacting: %@",[_vars at:i]);
      CPAssignImpact* assigns = [[CPAssignImpact alloc] initCPAssignImpact:(id<ORIntVar>)[_vars at:i]];
      [_impacts setObject:assigns forKey:[NSNumber numberWithInteger:[[_vars at:i] getId]]];
      [assigns release];  // [ldm] the assignment impacts for t[i] is now in the dico with a refcnt==1
   }
   [_solver post:_monitor];
   [self initImpacts];       // [ldm] init called _after_ adding the monitor so that the reduction is tracked (but before watching label)
   [[[_cp portal] retLabel] wheneverNotifiedDo:^void(id var,CPInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      [[_impacts objectForKey:key] addImpact:1.0 - [_monitor reduction] forValue:val];
      [key release];      
   }];
   [[[_cp portal] failLabel] wheneverNotifiedDo:^void(id var,CPInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      [[_impacts objectForKey:key] addImpact: 1.0 forValue:val];
      [key release];
   }];
   NSLog(@"IBS ready...");
}

-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(void)addKillSetFrom:(ORInt)from to:(ORInt)to size:(CPUInt)sz into:(NSMutableSet*)set
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

-(void)dichotomize:(id<ORIntVar>)x from:(ORInt)low to:(ORInt)up block:(ORInt)b sac:(NSMutableSet*)set 
{
   if (up - low + 1 <= b) {
      double ir = 1.0 - [_monitor reductionFromRoot];
      NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
      //NSLog(@"base: %ld - %ld impact (%@) = %lf",low,up,key,ir);
      CPAssignImpact* vImpact = [_impacts objectForKey:key];
      for(CPInt c = low ; c <= up;c++) {
         [vImpact setImpact:ir forValue:c];
      }
      [key release];
   } else {
      CPInt mid = low + (up - low)/2;
      id<ORTracer> tracer = [_cp tracer];
      [tracer pushNode];
      ORStatus s1 = [_solver lthen:x with:mid+1];
      [ORConcurrency pumpEvents];
      if (s1!=ORFailure) {
         [self dichotomize:x from:low to:mid block:b sac:set];
      } else { 
         // [ldm] We know that x IN [l..mid] leads to an inconsistency. -> record a SAC.
         [self addKillSetFrom:low to:mid size:[x countFrom:low to:mid] into:set];          
      }
      [tracer popNode];
      [tracer pushNode];
      ORStatus s2 = [_solver gthen:x with:mid];
      [ORConcurrency pumpEvents];
      if (s2!=ORFailure) {
         [self dichotomize:x from:mid+1 to:up block:b sac:set];
      } else {
         // [ldm] We know that x IN [mid+1..up] leads to an inconsistency. -> record a SAC.
         [self addKillSetFrom:mid+1 to:up size:[x countFrom:low to:mid] into:set];          
      }      
      [tracer popNode];      
   }
}
-(void)initImpacts
{
   CPInt blockWidth = 1;
   NSMutableSet* sacs = nil;
   CPInt low = [_vars low],up = [_vars up];
   for(CPInt k=low; k <= up;k++) {
      id<ORIntVar> v = (id<ORIntVar>)[_vars at:k];
      CPBounds vb;
      [v bounds: &vb];
      [self dichotomize:v from:vb.min to:vb.max block:blockWidth sac:sacs];
   }
}
@end
