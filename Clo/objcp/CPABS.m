/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPABS.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPStatisticsMonitor.h"
#import "ORTracer.h"


@interface ABSBinding : NSObject {
   ORInt _var;
   ORInt _val;
}
-(id)initABSBinding:(id<ORVar>)var value:(ORInt)val;
-(ORInt)variable;
-(ORInt)value;
@end

@interface ABSProbe : NSObject {
   ORInt*            _tab;
   int                _sz;
   int               _low;
   NSMutableSet* _inProbe;
}
-(ABSProbe*)initABSProbe:(id<ORVarArray>)vars;
-(void)dealloc;
-(void)addVar:(id<ORVar>)var;
-(void)scanProbe:(void(^)(ORInt varID,ORInt activity))block;
@end

@interface ABSProbeAggregator : NSObject {
   ORInt*            _sum;
   ORInt*          _sumsq;
   int                _sz;
   int               _low;
   NSMutableSet* _inProbe;
   ORInt        _nbProbes;
}
-(ABSProbeAggregator*)initABSProbeAggregator:(id<ORVarArray>)vars;
-(void)dealloc;
-(void)addProbe:(ABSProbe*)p;
-(ORInt)nbProbes;
-(ORFloat)avgActivity:(id<ORVar>)x;
-(ORFloat)avgSQActivity:(id<ORVar>)x;
-(NSSet*)variableIDs;
@end

@interface ABSVariableActivity : NSObject {
   @package
   id        _theVar;
   ORFloat _activity;
}
-(id)initABSVariableActivity:(id)var activity:(ORFloat)initial;
-(void)dealloc;
-(void)aging:(ORFloat)rate;
-(ORFloat)activity;
-(void)increase;
@end

@interface ABSValueActivity : NSObject {
   id<ORVar>             _theVar;
   NSMutableDictionary*  _values;
}
-(id)initABSActivity:(id<ORVar>)var;
-(void)dealloc;
-(void)setActivity:(ORFloat)a forValue:(ORInt)v;
-(void)addActivity:(ORFloat)a forValue:(ORInt)v;
-(ORFloat)activityForValue:(ORInt)v;
-(NSSet*)valuesWithActivities;
-(NSString*)description;
@end

@implementation ABSProbeAggregator
-(ABSProbeAggregator*)initABSProbeAggregator:(id<ORVarArray>)vars
{
   self = [super init];
   _sz  = (ORInt)[vars count];
   _low = [vars low];
   _sum   = malloc(sizeof(ORInt)*_sz);
   _sumsq = malloc(sizeof(ORInt)*_sz);
   memset(_sum,0,sizeof(ORInt)*_sz);
   memset(_sumsq,0,sizeof(ORInt)*_sz);
   _sum -= _low;
   _sumsq -= _low;
   _inProbe = [[NSMutableSet alloc] initWithCapacity:32];
   _nbProbes = 0;
   return self;
}
-(void)dealloc
{
   _sum += _low;
   _sumsq += _low;
   free(_sum);
   free(_sumsq);
   [_inProbe release];
   [super dealloc];
}
-(void)addProbe:(ABSProbe*)p
{
   [p scanProbe:^(ORInt varID, ORInt activity) {
      NSNumber* key = [[NSNumber alloc] initWithInt:varID];
      [_inProbe addObject:key];
      [key release];
      _sum[varID - _low]   += activity;
      _sumsq[varID - _low] += activity * activity;
   }];
   _nbProbes++;
}
-(ORInt)nbProbes
{
   return _nbProbes;
}
-(ORFloat)avgActivity:(id<ORVar>)x
{
   return ((ORFloat)_sum[[x getId] - _low]) / _nbProbes;
}
-(ORFloat)avgSQActivity:(id<ORVar>)x
{
   return ((ORFloat)_sumsq[[x getId] - _low]) / _nbProbes;
   
}
-(NSSet*)variableIDs
{
   return _inProbe;
}
@end

@implementation ABSBinding
-(id)initABSBinding:(id<ORVar>)var value:(ORInt)val
{
   self = [super init];
   _var = [var getId];
   _val = val;
   return self;
}
-(ORInt)variable
{
   return _var;
}
-(ORInt)value
{
   return _val;
}
@end

@implementation ABSProbe
-(ABSProbe*)initABSProbe:(id<ORVarArray>)vars
{
   self = [super init];
   _sz  = (ORInt)[vars count];
   _low = [vars low];
   _tab = malloc(sizeof(ORInt)*_sz);
   memset(_tab,0,sizeof(ORInt)*_sz);
   _tab -= _low;
   _inProbe = [[NSMutableSet alloc] initWithCapacity:32];
   return self;
}
-(void)dealloc
{
   _tab -= _low;
   free(_tab);
   [_inProbe release];
   [super dealloc];
}
-(void)addVar:(id<ORVar>)var
{
   ORInt idx = [var getId];
   NSNumber* vid = [[NSNumber alloc]  initWithInt:idx];
   [_inProbe addObject:vid];
   [vid release];
   _tab[idx - _low] += 1;
}
-(void)scanProbe:(void(^)(ORInt varID,ORInt activity))block
{
   for(NSNumber* key in _inProbe)
      block([key intValue],_tab[[key intValue] - _low]);
}
@end

@implementation ABSVariableActivity
-(id)initABSVariableActivity:(id)var activity:(ORFloat)initial
{
   self = [super init];
   _theVar = var;
   _activity = 0;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void)aging:(ORFloat)rate
{
   _activity *= rate;
}
-(ORFloat)activity
{
   return _activity;
}
-(void)increase
{
   _activity += 1;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var (%d) activity: %f",[_theVar getId],_activity];
   return buf;
}
@end

@implementation ABSValueActivity
-(id)initABSActivity:(id)var
{
   self = [super init];
   _theVar = var;
   _values = [[NSMutableDictionary alloc] initWithCapacity:32];
   return self;
}
-(void)dealloc
{
   [_values release];
   [super dealloc];
}
-(void)setActivity:(ORFloat)a forValue:(ORInt)v
{
   NSNumber* key = [[NSNumber alloc] initWithInt:v];
   id valAct = [_values objectForKey:key];
   assert(valAct == nil);
   [_values setObject:[[NSNumber alloc] initWithFloat:a] forKey:key];
   [key release];
}
-(void)addActivity:(ORFloat)a forValue:(ORInt)v
{
   NSNumber* key = [[NSNumber alloc] initWithInt:v];
   NSNumber* valAct = [_values objectForKey:key];
   if (valAct==nil) {
      [_values setObject:[[NSNumber alloc] initWithFloat:a] forKey:key];
   } else {
      ORFloat nv = (([valAct floatValue]  * (ALPHA - 1)) + a)/ ALPHA;
      [_values setObject:[[NSNumber alloc] initWithFloat:nv] forKey:key];
   }
   [key release];
}
-(ORFloat)activityForValue:(ORInt)v
{
   NSNumber* key = [[NSNumber alloc] initWithInt:v];
   NSNumber* valAct = [_values objectForKey:key];
   [key release];
   return [valAct floatValue];
}

-(NSSet*)valuesWithActivities
{
   return [_values keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
      return YES;
   }];
}
-(NSString*)description
{
   return [_values description];
}
@end

@implementation CPABS {
   CPEngineI*               _solver;
   CPStatisticsMonitor*    _monitor;
   ORULong                     _nbv;
   NSMutableDictionary*       _varActivity;
   NSMutableDictionary*       _valActivity;
   ORFloat                      _agingRate;
}
-(id)initCPABS:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _solver = (CPEngineI*)[cp engine];
   _monitor = nil;
   _vars = nil;
   _rvars = rvars;
   _agingRate = 0.999;
   [cp addHeuristic:self];
   return self;
}
-(void)dealloc
{
   [_varActivity release];
   [_valActivity release];
   [super dealloc];
}
-(float)varOrdering:(id<ORIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   ABSVariableActivity* varAct  = [_varActivity objectForKey:key];
   ORFloat rv = [varAct activity];
   [key release];
   return rv / [x domsize];
}
-(float)valOrdering:(int)v forVar:(id<ORIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   ABSValueActivity* vAct = [_valActivity objectForKey:key];
   ORFloat rv = [vAct activityForValue:v];
   [key release];
   return - rv;
}
-(void)updateActivities:(id<ORVar>)forVar andVal:(ORInt)val
{
   [_varActivity enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, ABSVariableActivity* act, BOOL *stop) {
      if (![act->_theVar bound]) {
         [act aging:_agingRate];
      }
   }];
   __block int nbActive = 0;
   [_monitor scanActive:^(CPVarInfo *vInfo) {
      NSNumber* key = [[NSNumber alloc] initWithInt:[vInfo getVarID]];
      ABSVariableActivity* va = [_varActivity objectForKey:key];
      if (!va) {
         va = [[ABSVariableActivity alloc] initABSVariableActivity:[vInfo getVar] activity:0];
         [_varActivity setObject:va forKey:key];
         [va release];
      }
      [key release];
      [va increase];
      ++nbActive;
   }];
   NSNumber* key = [[NSNumber alloc] initWithInt:[forVar getId]];
   ABSValueActivity* valAct = [_valActivity objectForKey:key];
   if (!valAct) {
      valAct = [[ABSValueActivity alloc] initABSActivity:forVar];
      [_valActivity setObject:valAct forKey:key];
      [valAct release];
   }
   [valAct addActivity:nbActive forValue:val];
   [key release];
}
-(void)initInternal:(id<ORVarArray>)t
{
   _vars = t;
   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:_cp vars:_vars];
   _nbv = [_vars count];
   [_solver post:_monitor];
   _varActivity = [[NSMutableDictionary alloc] initWithCapacity:32];
   _valActivity = [[NSMutableDictionary alloc] initWithCapacity:32];
   
   //[self initActivities];
   
   [[[_cp portal] retLabel] wheneverNotifiedDo:^void(id<ORVar> var,ORInt val) {
      [self updateActivities:var andVal:val];
   }];
   [[[_cp portal] failLabel] wheneverNotifiedDo:^void(id<ORVar> var,ORInt val) {
      [self updateActivities:var andVal:val];
   }];
   
   [[_cp engine] clearStatus];
   NSLog(@"ABS ready...");
}
-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}


-(void)initActivities
{
   const ORInt nbInRound = 10;
   const ORInt probeDepth = (ORInt) [_vars count];
   float mxp = 0;
   for(ORInt i = [_vars low];i <= [_vars up];i++) {
      if ([_vars[i] bound]) continue;
      mxp += log([(id)_vars[i] domsize]);
   }
   const int maxProbes = (int)10 * mxp;
   int   cntProbes = 0;
   BOOL  carryOn = YES;
   do {
      NSMutableSet* killSet = [[NSMutableSet alloc] initWithCapacity:32];

      
      
      [killSet release];
   } while (carryOn && cntProbes < maxProbes);
   
   
}
@end
