/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPError.h"
#import "CPController.h"
#import "ORTrail.h"

@implementation CPHeist
-(CPHeist*)initCPProblem:(NSCont*)c from:(Checkpoint*)cp
{
   self = [super init];
   _cont = [c retain];
   _theCP = [cp retain];
   return self;
}
-(void)dealloc
{
   [_cont letgo];
   [_theCP release];
   [super dealloc];
}
-(NSCont*)cont
{
   return _cont;
}
-(Checkpoint*)theCP
{
   return _theCP;
}
@end

@implementation CPDefaultController 
- (id) initCPDefaultController
{
   self = [super init];
   _controller = nil;
   return self;
}

-(void) dealloc
{
   [_controller release];
   //NSLog(@"CPDefaultController %p dealloc called...\n",self);
   [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
   CPDefaultController* ctrl = [[[self class] allocWithZone:zone] initCPDefaultController];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

-(id<CPSearchController>) controller
{
  return _controller;
}
-(void) setController: (id<CPSearchController>) controller
{
   _controller = [controller retain];
}
-(void) setup
{
   [_controller setup];
}
-(void) cleanup
{
   [_controller cleanup];
}
-(void)       trust
{
   if (_controller)
      [_controller trust];
   else
      @throw [[CPSearchError alloc] initCPSearchError: "Call to Default Search Controller for method trust"];
}

-(CPInt) addChoice: (NSCont*) k
{
  if (_controller)
    return [_controller addChoice: k];
  else
    @throw [[CPSearchError alloc] initCPSearchError: "Call to Default Search Controller for method addChoice:"];  
  return -1;
}
-(void) fail
{
  if (_controller)
    [_controller fail];
  else
    @throw [[CPSearchError alloc] initCPSearchError: "Call to Default Search Controller for method fail"];  
}

-(void) succeeds
{
   [_controller succeeds]; // failAll is meant to be handled by the first controller in the chain. (The actual policy)
}
-(BOOL) isFinitelyFailed
{
   return [_controller isFinitelyFailed];
}
-(void) startTry
{
   [_controller startTry];    
}
-(void) startTryLeft
{
   [_controller startTryLeft];    
}
-(void) exitTryLeft
{
   [_controller exitTryLeft];    
}
-(void) startTryRight
{
   [_controller startTryRight];    
}
-(void) exitTryRight
{
   [_controller exitTryRight];    
}
-(void) exitTry
{
   [_controller exitTry];    
}
-(void) startTryall
{
   [_controller startTryall];    
}
-(void) startTryallBody
{
   [_controller startTryallBody];    
}
-(void) exitTryallBody
{
   [_controller exitTryallBody];    
}
-(void) startTryallOnFailure
{
   [_controller startTryallOnFailure];    
}
-(void) exitTryallOnFailure
{
   [_controller exitTryallOnFailure];    
}
-(void) exitTryall
{
   [_controller exitTryall];    
}
@end

@implementation CPNestedController

-(id)initCPNestedController:(id<CPSearchController>)chain
{
   self = [super initCPDefaultController];
   id<CPSearchController> theClone = [chain copy];
   [self setController:theClone];
   _parent = [chain retain];
   [theClone release]; // We have a reference to it already. Caller does *NOT* keep track of it. 
   _isFF = NO;
   return self;
}
-(void)dealloc
{
   //NSLog(@"CPNestedController %p dealloc called...\n",self);
   [_parent release];
   [super dealloc];
}
-(void) setParent:(id<CPSearchController>) controller
{
   [_parent release];
   _parent = [controller retain];
}
-(void) fail
{
   [_controller fail];      // if we ever come back, the controller nodes supply is exhausted -> finitelyFailed.
   [self finitelyFailed];
}

-(void)succeeds 
{
   _isFF = NO;
   [_controller cleanup];
   [_parent fail];
}
-(void) finitelyFailed
{
   _isFF = YES;
   [_controller cleanup];
   [_parent fail];
}
-(BOOL) isFinitelyFailed
{
   return _isFF;
}
@end
