/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPError.h"
#import "DFSController.h"
#import "ORTrail.h"
#import "CPLimit.h"

@implementation CPLimitSolutions

-(id)   initCPLimitSolutions: (CPInt) maxSolutions
{
  self = [super initCPDefaultController];
  _nbSolutions = 0;
  _maxSolutions = maxSolutions;
  return self;
}
-(void) dealloc
{
   NSLog(@"CPLimitSolution dealloc called...\n");
   [super dealloc];
}
-(CPInt) addChoice: (NSCont*) k
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
   CPLimitSolutions* ctrl = [[[self class] allocWithZone:zone] initCPLimitSolutions:_maxSolutions];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

@implementation CPLimitDiscrepancies

-(id) initCPLimitDiscrepancies: (CPInt) maxDiscrepancies withTrail: (ORTrail*) trail
{
  self = [super initCPDefaultController];
  _trail = trail;
  _nbDiscrepancies = makeTRInt(_trail,0);  
  _maxDiscrepancies = maxDiscrepancies;
  return self;
}
-(void) dealloc
{
   NSLog(@"CPLimitSolution dealloc called...\n");
   [super dealloc];
}
-(CPInt) addChoice: (NSCont*) k
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
   CPLimitDiscrepancies* ctrl = [[[self class] allocWithZone:zone] initCPLimitDiscrepancies:_maxDiscrepancies withTrail:_trail];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

@end

@implementation CPLimitFailures

-(id) initCPLimitFailures: (CPInt) maxFailures
{
   self = [super initCPDefaultController];
   _nbFailures = 0;
   _maxFailures = maxFailures;
   return self;
}
-(void) dealloc
{
   NSLog(@"CPLimitFailures dealloc called...\n");
   [super dealloc];
}
-(CPInt) addChoice: (NSCont*) k
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
   CPLimitFailures* ctrl = [[[self class] allocWithZone:zone] initCPLimitFailures:_maxFailures];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

@implementation CPLimitTime

-(id) initCPLimitTime: (CPLong) maxTime
{
   self = [super initCPDefaultController];
   _startTime = [CPRuntimeMonitor cputime];
   _maxTime = _startTime + maxTime;
   return self;
}
-(void) dealloc
{
   NSLog(@"CPLimitTime dealloc called...\n");
   [super dealloc];
}
-(CPInt) addChoice: (NSCont*) k
{
   return [_controller addChoice: k];
}
-(void) fail
{
   [_controller fail];
}
-(void) startTryLeft
{
   CPLong currentTime = [CPRuntimeMonitor cputime];
   if (currentTime < _maxTime)
      [_controller fail];
   else
      [_controller startTryLeft];
}
-(void) startTryRight
{
   CPLong currentTime = [CPRuntimeMonitor cputime];
   if (currentTime < _maxTime)
      [_controller fail];
   else
      [_controller startTryRight];
}
-(void) startTryallOnFailure
{
   CPLong currentTime = [CPRuntimeMonitor cputime];
   if (currentTime < _maxTime)
      [_controller fail];
   else
      [_controller startTryallOnFailure];
}
- (id)copyWithZone:(NSZone *)zone
{
   CPLimitTime* ctrl = [[[self class] allocWithZone:zone] initCPLimitTime:_maxTime];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

@implementation CPOptimizationController

-(id) initCPOptimizationController: (Void2ORStatus) canImprove
{
  self = [super initCPDefaultController];
  _canImprove = [canImprove copy];
  return self;
}
-(void) dealloc
{
   NSLog(@"CPOptimizationController dealloc called...\n");
   [_canImprove release];
   [super dealloc];
}
-(CPInt) addChoice: (NSCont*) k
{
   if (_canImprove() == ORFailure)
      [_controller fail];
   return [_controller addChoice: k];
}
-(void) fail
{
  [_controller fail];
}
-(void) startTryLeft
{
   if (_canImprove() == ORFailure)
      [_controller fail];
   else
      [_controller startTryLeft];  
}
-(void) startTryRight
{
   if (_canImprove() == ORFailure)
      [_controller fail];
   else
      [_controller startTryRight];
}
-(void) startTryallOnFailure
{
   if (_canImprove() == ORFailure)
      [_controller fail];
   else
      [_controller startTryallOnFailure];
}
- (id)copyWithZone:(NSZone *)zone
{
   CPOptimizationController* ctrl = [[[self class] allocWithZone:zone] initCPOptimizationController:_canImprove];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end


@implementation CPLimitCondition
-(id) initCPLimitCondition: (CPVoid2Bool) condition
{
   self = [super initCPDefaultController];
   _condition = [condition copy];
   return self;
}
-(void) dealloc
{
   NSLog(@"CPOptimizationController dealloc called...\n");
   [_condition release];
   [super dealloc];
}
-(CPInt) addChoice:(NSCont*) k
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




