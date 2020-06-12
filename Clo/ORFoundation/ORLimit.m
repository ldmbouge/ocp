/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
   //NSLog(@"ORLimitSolution dealloc called...\n");
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   if (_nbSolutions >= _maxSolutions)
      [_controller fail: true];
   return [_controller addChoice: k];
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
   //NSLog(@"ORLimitSolution dealloc called...\n");
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   if (_nbDiscrepancies._val < _maxDiscrepancies)
      return [_controller addChoice: k];
   else
      return -1;
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
   //NSLog(@"ORLimitFailures dealloc called...");
   [super dealloc];
}

//-(id)retain
//{
//   return [super retain];
//}
//-(NSUInteger)retainCount
//{
//   return [super retainCount];
//}
//-(oneway void)release
//{
//   [super release];
//}
-(ORInt) addChoice: (NSCont*) k
{
   return [_controller addChoice: k];
}
-(void) startTryLeft
{
   if (_nbFailures >= _maxFailures) {
      [_controller fail: true];
   }
   else
      [_controller startTryLeft];
}
-(void) startTryRight
{
   _nbFailures++;
   if (_nbFailures >= _maxFailures) {
      [_controller fail: true];
   }
   else
      [_controller startTryRight];
}
-(void) startTryallOnFailure
{
   _nbFailures++;
   if (_nbFailures >= _maxFailures) {
      [_controller fail: true];
   }
   else
      [_controller startTryallOnFailure];
}
- (id)copyWithZone:(NSZone *)zone
{
   ORLimitFailures* ctrl = [[[self class] allocWithZone:zone] initORLimitFailures:_maxFailures];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
-(void) succeeds
{
   //   NSLog(@"succeeds");
   //printf(".");
   _nbFailures = 0;
}
@end

@implementation ORLimitTime{
   ORBool _failed;
}

-(id) initORLimitTime: (ORLong) maxTime
{
   self = [super initORDefaultController];
   _startTime = [ORRuntimeMonitor cputime];
   _maxTime = _startTime + maxTime;
   _failed = NO;
   return self;
}
-(void) dealloc
{
   if(_failed)
      NSLog(@"Failed because of Timeout\n");
   NSLog(@"ORLimitTime dealloc called...\n");
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   // Checking in addChoice is necessary since some combinators (e.g., repeat)
   // do not rely on the try combinator but directly use addChoice.
   // Without it, the repeat can proceed and fail on the first branching decision
   // which sends it back to the onRepeat and into an infinite loop (calling onRepeat
   // forever).
   ORLong currentTime = [ORRuntimeMonitor cputime];
   if (currentTime > _maxTime) {
      _failed = YES;
      [_controller fail: true];
      return 0;
   } else
      return [_controller addChoice: k];
}
-(void) startTryLeft
{
   ORLong currentTime = [ORRuntimeMonitor cputime];
   if (currentTime > _maxTime){
      _failed = YES;
      [_controller fail: true];
   }else{
      [_controller startTryLeft];
   }
}
-(void) startTryRight
{
   ORLong currentTime = [ORRuntimeMonitor cputime];
   if (currentTime > _maxTime){
      _failed = YES;
      [_controller fail: true];
   }else{
      [_controller startTryRight];
   }
}
-(void) startTryallOnFailure
{
   ORLong currentTime = [ORRuntimeMonitor cputime];
   if (currentTime > _maxTime){
      _failed = YES;
      [_controller fail: true];
   }else{
      [_controller startTryallOnFailure];
   }
}
- (id)copyWithZone:(NSZone *)zone
{
   ORLimitTime* ctrl = [[[self class] allocWithZone:zone] initORLimitTime:_maxTime];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
-(void) fail
{
//   NSLog(@"fail");
   [super fail];
}

@end

@implementation OROptimizationController

-(id) initOROptimizationController: (Void2ORStatus) canImprove
{
   self = [super initORDefaultController];
   _canImprove = [canImprove copy];
   return self;
}
-(void) dealloc
{
   //NSLog(@"OROptimizationController dealloc called...\n");
   [_canImprove release];
   [super dealloc];
}
-(ORInt) addChoice: (NSCont*) k
{
   if (_canImprove() == ORFailure)
      [_controller fail];
   return [_controller addChoice: k];
}
-(void) startTryLeft
{
   if (_canImprove() == ORFailure) {
      [_controller fail];
   }else
      [_controller startTryLeft];
}
-(void) startTryRight
{
   if (_canImprove() == ORFailure) {
      [_controller fail];
   } else
      [_controller startTryRight];
}
-(void) startTryallBody
{
   if (_canImprove() == ORFailure) {
      [_controller fail];
   } else
      [_controller startTryallBody];
}
-(void) startTryallOnFailure
{
   if (_canImprove() == ORFailure) {
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
   NSLog(@"ORLimitCondition dealloc called...\n");
   [_condition release];
   [super dealloc];
}
-(ORInt) addChoice:(NSCont*) k
{
   if (_condition())
      [_controller fail: true];
   return [_controller addChoice: k];
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

@implementation ORLimitMonitor
{
   ORBool _pruned;
}
-(id) initORLimitMonitor
{
   self = [super initORDefaultController];
   _pruned = false;
   return self;
}
-(void) dealloc
{
   NSLog(@"ORLimitMonitor dealloc called...\n");
   [super dealloc];
}
-(void) fail: (ORBool) pruned
{
   if (pruned)
      _pruned = pruned;
   [self fail];
}
-(ORBool) isPruned
{
   return _pruned;
}
@end

@implementation ORSwitchOnDepth
{
   id<ORTrail>  _trail;
   ORInt        _limit;
   NSCont*      _next;
   TRInt        _depth;
   
}
-(id) initORSwitchOnDepth: (ORInt) limit next: (NSCont*) next withTrail: (id<ORTrail>) trail;
{
   self = [super initORDefaultController];
   _trail = trail;
   _limit = limit;
   _next  = [next retain];
   _depth = makeTRInt(_trail,0);
   return self;
}
-(void) dealloc
{
   [_next letgo];
   [super dealloc];
}
-(void) startTry
{
   assignTRInt(&_depth,_depth._val + 1,_trail);
   if (_depth._val > _limit)
      [_next call];
   else
      [_controller startTry];
}
-(void)trust
{
   assignTRInt(&_depth,_depth._val + 1,_trail);
   [super trust];
}
@end

@implementation ORTrackDepth
{
   id<ORTrail>  _trail;
   ORMutableIntegerI *_mDepth;
   TRInt        _depth;
   
}
-(id) initORTrackDepth:(id<ORTrail>) trail tracker:(id<ORTracker>)track;
{
   self = [super initORDefaultController];
   _trail = trail;
   _depth = makeTRInt(_trail,0);
   _mDepth = [ORFactory mutable:track value:0];
   return self;
}
-(id) initORTrackDepth:(id<ORTrail>) trail  with:(ORMutableIntegerI*)mdepth;
{
   self = [super initORDefaultController];
   _trail = trail;
   _depth = makeTRInt(_trail,0);
   _mDepth = mdepth;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(void) startTry
{
   assignTRInt(&_depth,_depth._val + 1,_trail);
   [_mDepth setValue:max(_mDepth.intValue, _depth._val)];
   [_controller startTry];
}
-(void) startTryall
{
   assignTRInt(&_depth,_depth._val + 1,_trail);
   [_mDepth setValue:max(_mDepth.intValue, _depth._val)];
   [_controller startTryall];
}
-(void)trust
{
//   assignTRInt(&_depth,_depth._val + 1,_trail);
//   [_mDepth setValue:max(_mDepth.intValue, _depth._val)];
   [super trust];
}
-(ORUInt)maxDepth
{
   return _mDepth.intValue;
}
-(ORUInt)depth
{
   return _depth._val;
}
-(void) reset
{
   _depth = makeTRInt(_trail,0);
   _mDepth = 0;
}
@end

