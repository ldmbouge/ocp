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

@interface ABSActivity : NSObject {
   id                    _theVar;
   NSMutableDictionary*  _values;
}
-(id)initABSActivity:(id)var;
-(void)dealloc;
-(void)setActivity:(ORFloat)a forValue:(ORInt)v;
-(void)addActivity:(ORFloat)a forValue:(ORInt)v;
-(ORFloat)activityForValue:(ORInt)v;
-(NSSet*)valuesWithActivities;
-(NSString*)description;
@end

@implementation ABSActivity
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
   ORFloat nv = (([valAct floatValue]  * (ALPHA - 1)) + a)/ ALPHA;
   [_values setObject:[[NSNumber alloc] initWithFloat:nv] forKey:key];
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
}
-(id)initCPABS:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars
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
   [_varActivity release];
   [_valActivity release];
   [super dealloc];
}
-(float)varOrdering:(id<ORIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   NSNumber* va  = [_varActivity objectForKey:key];
   ORFloat rv = [va floatValue];
   [key release];
   return rv / [x domsize];
}
-(float)valOrdering:(int)v forVar:(id<ORIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   ABSActivity* vAct = [_valActivity objectForKey:key];
   ORFloat rv = [vAct activityForValue:v];
   [key release];
   return - rv;
}
-(void)initInternal:(id<ORVarArray>)t
{
   _vars = t;
   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:_cp vars:_vars];
   _nbv = [_vars count];
   [_solver post:_monitor];
   _varActivity = [[NSMutableDictionary alloc] initWithCapacity:32];
   _valActivity = [[NSMutableDictionary alloc] initWithCapacity:32];
   
   
   [[_cp engine] clearStatus];
   NSLog(@"ABS ready...");
}
-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}
@end
