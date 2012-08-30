/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORLimit.h"

@implementation ORLimitSolutions

-(id)   initORLimitSolutions: (ORInt) maxSolutions
{
   self = [super initORDefaultController];
   _nbSolutions = 0;
   _maxSolutions = maxSolutions;
   return self;
}
-(void) dealloc
{
   NSLog(@"ORLimitSolution dealloc called...\n");
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   if (_nbSolutions >= _maxSolutions)
      [_controller fail];
   return [_controller addChoice: k];
}
-(void) fail
{
   [_controller fail];
}
-(void) succeeds
{
   _nbSolutions++;
}
- (id)copyWithZone:(NSZone *)zone
{
   ORLimitSolutions* ctrl = [[[self class] allocWithZone:zone] initORLimitSolutions:_maxSolutions];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

@implementation ORLimitDiscrepancies

-(id) initORLimitDiscrepancies: (ORInt) maxDiscrepancies withTrail: (id<ORTrail>) trail
{
   self = [super initORDefaultController];
   _trail = trail;
   _nbDiscrepancies = makeTRInt(_trail,0);
   _maxDiscrepancies = maxDiscrepancies;
   return self;
}
-(void) dealloc
{
   NSLog(@"ORLimitSolution dealloc called...\n");
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   if (_nbDiscrepancies._val < _maxDiscrepancies)
      return [_controller addChoice: k];
   else
      return -1;
}
-(void) fail
{
   [_controller fail];
}
-(void) startTryRight
{
   assignTRInt(&_nbDiscrepancies,_nbDiscrepancies._val + 1,_trail);
}
- (id)copyWithZone:(NSZone *)zone
{
   ORLimitDiscrepancies* ctrl = [[[self class] allocWithZone:zone] initORLimitDiscrepancies:_maxDiscrepancies withTrail:_trail];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

@end

@implementation ORLimitFailures

-(id) initORLimitFailures: (ORInt) maxFailures
{
   self = [super initORDefaultController];
   _nbFailures = 0;
   _maxFailures = maxFailures;
   return self;
}
-(void) dealloc
{
   NSLog(@"ORLimitFailures dealloc called...\n");
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   return [_controller addChoice: k];
}
-(void) fail
{
   [_controller fail];
}
-(void) startTryLeft
{
   if (_nbFailures >= _maxFailures)
      [_controller fail];
   else
      [_controller startTryLeft];
}
-(void) startTryRight
{
   _nbFailures++;
   if (_nbFailures >= _maxFailures)
      [_controller fail];
   else
      [_controller startTryRight];
}
-(void) startTryallOnFailure
{
   _nbFailures++;
   if (_nbFailures >= _maxFailures)
      [_controller fail];
   else
      [_controller startTryallOnFailure];
}
- (id)copyWithZone:(NSZone *)zone
{
   ORLimitFailures* ctrl = [[[self class] allocWithZone:zone] initORLimitFailures:_maxFailures];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

@implementation ORLimitTime

-(id) initORLimitTime: (ORLong) maxTime
{
   self = [super initORDefaultController];
   _startTime = [ORRuntimeMonitor cputime];
   _maxTime = _startTime + maxTime;
   return self;
}
-(void) dealloc
{
   NSLog(@"ORLimitTime dealloc called...\n");
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   return [_controller addChoice: k];
}
-(void) fail
{
   [_controller fail];
}
-(void) startTryLeft
{
   ORLong currentTime = [ORRuntimeMonitor cputime];
   if (currentTime < _maxTime)
      [_controller fail];
   else
      [_controller startTryLeft];
}
-(void) startTryRight
{
   ORLong currentTime = [ORRuntimeMonitor cputime];
   if (currentTime < _maxTime)
      [_controller fail];
   else
      [_controller startTryRight];
}
-(void) startTryallOnFailure
{
   ORLong currentTime = [ORRuntimeMonitor cputime];
   if (currentTime < _maxTime)
      [_controller fail];
   else
      [_controller startTryallOnFailure];
}
- (id)copyWithZone:(NSZone *)zone
{
   ORLimitTime* ctrl = [[[self class] allocWithZone:zone] initORLimitTime:_maxTime];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

@interface NSThread (ORData)
+(ORInt)threadID;
@end

static BOOL __isGenerating[2] = {NO,NO};

extern void startGenerating()
{
   __isGenerating[[NSThread threadID]] = YES;
}
extern void stopGenerating()
{
   __isGenerating[[NSThread threadID]] = NO;
}
extern BOOL isGenerating()
{
   return __isGenerating[[NSThread threadID]];
}

@implementation OROptimizationController

-(id) initOROptimizationController: (Void2ORStatus) canImprove
{
   self = [super initORDefaultController];
   _canImprove = [canImprove copy];
   return self;
}
-(void) dealloc
{
   NSLog(@"OROptimizationController dealloc called...\n");
   [_canImprove release];
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   if (_canImprove() == ORFailure)
      [_controller fail];
   return [_controller addChoice: k];
}
-(void) fail
{
   assert(!isGenerating());
   [_controller fail];
}
-(void) startTryLeft
{
   if (_canImprove() == ORFailure) {
      assert(!isGenerating());
      [_controller fail];
   }else
      [_controller startTryLeft];
}
-(void) startTryRight
{
   if (_canImprove() == ORFailure) {
      assert(!isGenerating());
      [_controller fail];
   } else
      [_controller startTryRight];
}
-(void) startTryallOnFailure
{
   if (_canImprove() == ORFailure) {
      assert(!isGenerating());
      [_controller fail];
   }   else
      [_controller startTryallOnFailure];
}
- (id)copyWithZone:(NSZone *)zone
{
   OROptimizationController* ctrl = [[[self class] allocWithZone:zone] initOROptimizationController:_canImprove];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end


@implementation ORLimitCondition
-(id) initORLimitCondition: (ORVoid2Bool) condition
{
   self = [super initORDefaultController];
   _condition = [condition copy];
   return self;
}
-(void) dealloc
{
   NSLog(@"OROptimizationController dealloc called...\n");
   [_condition release];
   [super dealloc];
}
-(ORInt) addChoice:(NSCont*) k
{
   if (_condition())
      [_controller fail];
   return [_controller addChoice: k];
}
-(void) fail
{
   [_controller fail];
}
-(void) startTryLeft
{
   if (_condition())
      [_controller fail];
   else
      [_controller startTryLeft];
}
-(void) startTryRight
{
   if (_condition())
      [_controller fail];
   else
      [_controller startTryRight];
}
@end




