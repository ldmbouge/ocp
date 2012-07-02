/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "CPIBS.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPMonitor.h"
#import "CPTracer.h"

@interface CPKillRange : NSObject {
@package
   CPInt _low;
   CPInt _up;
   CPUInt _nbKilled;
}
-(id)initCPKillRange:(CPInt)f to:(CPInt)to size:(CPUInt)sz;
-(void)dealloc;
-(BOOL)isEqual:(CPKillRange*)kr;
@end

@implementation CPKillRange 
-(id)initCPKillRange:(CPInt)f to:(CPInt)to  size:(CPUInt)sz
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

@interface CPValueImpact : NSObject {
   id<CPIntVar>  _var;
   double*      _imps;
   CPUInt _nbVals;
   CPBounds      _dom;
   double*        _mu;
   double*      _vari;
   CPUInt*   _cnts;
}
-(CPValueImpact*)initCPValueImpact:(id<CPIntVar>)theVar;
-(void)dealloc;
-(void)addImpact:(double)i forValue:(CPInt)val;
-(void)setImpact:(double)i forValue:(CPInt)val;
-(double)getImpactForValue:(CPInt)val;
// pvh: variable impact?
-(double)getImpact;
@end

@implementation CPValueImpact
-(CPValueImpact*)initCPValueImpact:(id<CPIntVar>)theVar
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
-(void)addImpact:(double)i forValue:(CPInt)val
{
   if (_imps) {
      _imps[val] = (_imps[val] * (ALPHA - 1.0) + i) / ALPHA;
      double oldMu = _mu[val];
      _mu[val] = (_cnts[val] * _mu[val] + i)/(_cnts[val]+1);
      _vari[val] = _vari[val] + (i - _mu[val]) * (i - oldMu);
      _cnts[val] = _cnts[val] + 1;
   }
}
-(void)setImpact:(double)i forValue:(CPInt)val
{
   if (_imps) {
      _imps[val] = i;
      _mu[val]   = i;
      _vari[val] = 0.0;
      _cnts[val] = 1;
   }
}

-(double)getImpactForValue:(CPInt)val
{
   return _imps != NULL ? _imps[val] : 0.0;
}
-(double)getImpact
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

@implementation CPIBS

-(id)initCPIBS:(id<CP>)cp
{
   self = [super init];
   _cp = cp;
   _solver = (CPSolverI*)[cp solver];
   _monitor = nil;
   [cp addHeuristic:self];
   return self;
}
-(void)dealloc
{
   [_vars release];
   [_impacts release];
   [super dealloc];
}
-(float)varOrdering:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
   double rv = [[_impacts objectForKey:key] getImpact];
   [key release];
   return rv;
}
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
   double rv = [[_impacts objectForKey:key] getImpactForValue:v];
   [key release];
   return rv;
}
// pvh: this dictionary business seems pretty heavy; lots of memory allocation
-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)len
{
   _vars = [[NSMutableArray alloc] initWithCapacity:len];
   for(CPUInt i=0;i<len;i++)
      [_vars addObject:t[i]];
   _monitor = [[CPMonitor alloc] initCPMonitor:_solver vars:_vars];
   _nbv = len;
    // pvh: why is it times 3?
   _impacts = [[NSMutableDictionary alloc] initWithCapacity:_nbv];
   for(CPUInt i=0;i<len;i++) {
      CPValueImpact* assigns = [[CPValueImpact alloc] initCPValueImpact:t[i]];
      [_impacts setObject:assigns forKey:[NSNumber numberWithInteger:[t[i] getId]]];
      [assigns release];  // [ldm] the assignment impacts for t[i] is now in the dico with a refcnt==1
   }
   [_solver post:_monitor];
   [self initImpacts];       // [ldm] init called _after_ adding the monitor so that the reduction is tracked (but before watching label)
   [[_cp retLabel] wheneverNotifiedDo:^void(id var,CPInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      [[_impacts objectForKey:key] addImpact:1.0 - [_monitor reduction] forValue:val];
      [key release];      
   }];
   [[_cp failLabel] wheneverNotifiedDo:^void(id var,CPInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      [[_impacts objectForKey:key] addImpact: 1.0 forValue:val];
      [key release];
   }];
}

-(id<CPIntVarArray>)allIntVars
{
   id<CPIntVarArray> rv = [CPFactory intVarArray:_cp range:(CPRange){0,_nbv-1} with:^id<CPIntVar>(CPInt i) {
      return (id<CPIntVar>)[_vars objectAtIndex:i];
   }];
   return rv;   
}

-(void)addKillSetFrom:(CPInt)from to:(CPInt)to size:(CPUInt)sz into:(NSMutableSet*)set
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

-(void)dichotomize:(id<CPIntVar>)x from:(CPInt)low to:(CPInt)up block:(CPInt)b sac:(NSMutableSet*)set 
{
   if (up - low + 1 <= b) {
      double ir = 1.0 - [_monitor reductionFromRoot];
      NSNumber* key = [[NSNumber alloc] initWithInteger:[x getId]];
      //NSLog(@"base: %ld - %ld impact (%@) = %lf",low,up,key,ir);
      CPValueImpact* vImpact = [_impacts objectForKey:key];
      for(CPInt c = low ; c <= up;c++) {
         [vImpact setImpact:ir forValue:c];
      }
      [key release];
   } else {
      CPInt mid = low + (up - low)/2;
      id<CPTracer> tracer = [_cp tracer];
      [tracer pushNode];
      CPStatus s1 = [_solver lthen:x with:mid+1];
      [CPConcurrency pumpEvents];
      if (s1!=CPFailure) {
         [self dichotomize:x from:low to:mid block:b sac:set];
      } else { 
         // [ldm] We know that x IN [l..mid] leads to an inconsistency. -> record a SAC.
         [self addKillSetFrom:low to:mid size:[x countFrom:low to:mid] into:set];          
      }
      [tracer popNode];
      [tracer pushNode];
      CPStatus s2 = [_solver gthen:x with:mid];
      [CPConcurrency pumpEvents];
      if (s2!=CPFailure) {
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
   for(id<CPIntVar> v in _vars) {
      CPBounds vb;
      [v bounds: &vb];
      [self dichotomize:v from:vb.min to:vb.max block:blockWidth sac:sacs];
   }
}
@end
