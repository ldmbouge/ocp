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
  //printf("startTryRight: %d \n",_nbDiscrepancies._val);
  assignTRInt(&_nbDiscrepancies,_nbDiscrepancies._val + 1,_trail);  
}
- (id)copyWithZone:(NSZone *)zone
{
   CPOptimizationController* ctrl = [[[self class] allocWithZone:zone] initCPLimitDiscrepancies:_maxDiscrepancies withTrail:_trail];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

@end


@implementation CPOptimizationController

-(id) initCPOptimizationController: (CPVoid2CPStatus) canImprove
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
  return [_controller addChoice: k];
}
-(void) fail
{
  [_controller fail];
}
-(void) startTryRight
{
  if (_canImprove() == CPFailure)
    [_controller fail];
}
-(void) startTryallOnFailure
{
  if (_canImprove() == CPFailure)
    [_controller fail];
}
- (id)copyWithZone:(NSZone *)zone
{
   CPOptimizationController* ctrl = [[[self class] allocWithZone:zone] initCPOptimizationController:_canImprove];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end






