/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPFDS.h>
#import <ORFoundation/ORTracer.h>
#import <CPUKernel/CPUKernel.h>
#import <ORPRogram/CPConcretizer.h>
#import <objcp/CPStatisticsMonitor.h>
#import <objcp/CPVar.h>
#import <objcp/CPFactory.h>

#if defined(__linux__)
#import <values.h>
#endif

/*
@interface CPAssignImpact : NSObject {
   id<CPIntVar>  _var;
   double*       _imps;
   ORUInt        _nbVals;
   ORBounds      _dom;
   double*       _mu;
   double*       _vari;
   ORUInt*       _cnts;
}
-(CPAssignImpact*)initCPAssignImpact:(id<ORIntVar>)theVar;
-(void)dealloc;
-(void)addImpact:(double)i forValue:(ORInt)val;
-(void)setImpact:(double)i forValue:(ORInt)val;
-(double)impactForValue:(ORInt)val;
-(double)impactForVariable;
@end

@implementation CPAssignImpact
-(CPAssignImpact*)initCPAssignImpact:(id<CPIntVar>)theVar
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
   } else return - MAXDBL;
}
@end
*/

@implementation CPFDS {
   id<CPEngine>             _engine;
   CPStatisticsMonitor*    _monitor;
   ORULong                     _nbv;
   NSMutableDictionary*    _impacts;
}

-(id)initCPFDS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars
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
   return [[CPFDS alloc] initCPFDS:_cp restricted:_rvars];
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

-(ORDouble)varOrdering:(id<CPIntVar>)x
{
   return 0.0;
}
-(ORDouble)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   return 0.0;
}
// pvh: this dictionary business seems pretty heavy; lots of memory allocation
-(void)initInternal:(id<ORVarArray>)t with:(id<CPVarArray>)cvs
{
   _vars = t;
   _cvs  = cvs;
   id<ORIntVarArray> av = [self allIntVars];
   id* gamma = [_cp gamma];
   id<CPIntVarArray> cav = [CPFactory intVarArray:_cp range:av.range with:^id<CPIntVar>(ORInt i) {
      return gamma[av[i].getId];
   }];
   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:[_cp engine] vars:cav];
   _nbv = [_cvs count];
   [_engine post:_monitor];
   
//   [self initImpacts];       // [ldm] init called _after_ adding the monitor so that the reduction is tracked (but before watching label)

   [[[_cp portal] retLabel] wheneverNotifiedDo:^void(id var,ORInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      //[[_impacts objectForKey:key] addImpact:1.0 - [_monitor reduction] forValue:val];
      [key release];
   }];
   [[[_cp portal] failLabel] wheneverNotifiedDo:^void(id var,ORInt val) {
      NSNumber* key = [[NSNumber alloc] initWithInteger:[var getId]];
      //[[_impacts objectForKey:key] addImpact: 1.0 forValue:val];
      [key release];
   }];
   [[_cp engine] tryEnforceObjective];
   if ([[_cp engine] objective] != NULL)
      NSLog(@"FDS ready... %@",[[_cp engine] objective]);
   else
      NSLog(@"FDS ready... ");
}

-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}
/*
-(void)initImpacts
{
   ORInt blockWidth = 1;
   id<ORIntVarArray> mav = [self allIntVars];
   id* gamma = [_cp gamma];
   id<CPIntVarArray> av = [CPFactory intVarArray:_cp range:mav.range with:^id<CPIntVar>(ORInt i) {
      return gamma[mav[i].getId];
   }];
   ORInt low = [av low],up = [av up];
   for(ORInt k=low; k <= up;k++) {
      NSMutableSet* sacs = [[NSMutableSet alloc] initWithCapacity:2];
      id<CPIntVar> v = av[k];
      ORBounds vb = [v bounds];
      [_monitor rootRefresh];
      [self dichotomize:v from:vb.min to:vb.max block:blockWidth sac:sacs];
      ORInt rank = 0;
      ORInt lastRank = (ORInt)[sacs count]-1;
      ORStatus status = ORSuspend;
      for(CPKillRange* kr in sacs) {
         if (rank == 0 && [kr low] == [v min]) {
            if ([_engine enforce: ^{ [v updateMin:[kr up]+1];}] == ORFailure)   // gthen:v with:[kr up]];
               status = ORFailure;
         }
         else if (rank == lastRank && [kr up] == [v max]) {
            if ([_engine enforce: ^{ [v updateMax:[kr low]-1];}] == ORFailure) // lthen:v with:[kr low]];
               status = ORFailure;
         }
         else {
            for(ORInt i=[kr low];i <= [kr up];i++)
               if ([_engine enforce: ^{ [v remove:i];}] == ORFailure) // diff:v with:i];
                  status = ORFailure;
         }
         rank++;
      }
      [sacs release];
      if (status == ORFailure)
         failNow();
   }
}
 */
@end
