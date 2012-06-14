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

#import "CPError.h"
#import "DFSController.h"
#import "CPTrail.h"
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

-(id) initCPLimitDiscrepancies: (CPInt) maxDiscrepancies withTrail: (CPTrail*) trail
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






