/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>

@implementation ORHeist
-(ORHeist*)initORHeist:(NSCont*)c from:(id<ORCheckpoint>)cp
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
-(id<ORCheckpoint>)theCP
{
   return _theCP;
}
@end



@implementation ORDefaultController
- (id) initORDefaultController
{
   self = [super init];
   _controller = nil;
   return self;
}

-(void) dealloc
{
   [_controller release];
   //NSLog(@"ORDefaultController %p dealloc called...\n",self);
   [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
   ORDefaultController* ctrl = [[[self class] allocWithZone:zone] initORDefaultController];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

-(id<ORSearchController>) controller
{
   return _controller;
}
-(void) setController: (id<ORSearchController>) controller
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
      @throw [[ORExecutionError alloc] initORExecutionError: "Call to Default Search Controller for method trust"];
}

-(ORInt) addChoice: (NSCont*) k
{
   if (_controller)
      return [_controller addChoice: k];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "Call to Default Search Controller for method addChoice:"];
   return -1;
}
-(void) fail
{
   if (_controller)
      [_controller fail];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "Call to Default Search Controller for method fail"];
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

@implementation ORNestedController
{
   id<ORSearchController> _parent;        // This is not a mistake. Delegation chain for NESTED controllers (fail).
   BOOL                   _isFF;
}
-(id)initORNestedController:(id<ORSearchController>)chain
{
   self = [super initORDefaultController];
   id<ORSearchController> theClone = [chain copy];
   [self setController:theClone]; // pvh: Why is this done???
   _parent = [chain retain];
   [theClone release]; // We have a reference to it already. Caller does *NOT* keep track of it.
   _isFF = NO;
   return self;
}
-(void)dealloc
{
   //NSLog(@"ORNestedController %p dealloc called...\n",self);
   [_parent release];
   [super dealloc];
}
-(void) setParent:(id<ORSearchController>) controller
{
   [_parent release];
   _parent = [controller retain];
}
-(void) fail
{
   [_controller fail];      // if we ever come back, the controller nodes supply is exhausted -> finitelyFailed.
   [self finitelyFailed];
}

-(void) succeeds
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

@implementation ORDFSController

- (id) initDFSController:(id<ORTracer>)tracer;
{
   self = [super initORDefaultController];
   _tracer = [tracer retain];
   _mx  = 100;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _sz  = 0;
   _atRoot = 0;
   return self;
}

- (void) dealloc
{
   NSLog(@"DFSController dealloc called...\n");
   [_tracer release];
   free(_tab);
   [super dealloc];
}

-(void)setup
{
   if (_atRoot==0)
      _atRoot = [_tracer pushNode];
}

-(void) cleanup
{
   while (_sz > 0)
      [_tab[--_sz] letgo];
   [_tracer popToNode:_atRoot];
}

-(ORInt) addChoice: (NSCont*)k
{
   if (_sz >= _mx) {
      NSCont** nt = malloc(sizeof(NSCont*)*_mx*2);
      for(ORInt i=0;i<_mx;i++)
         nt[i] = _tab[i];
      free(_tab);
      _tab = nt;
      _mx <<= 1;
   }
   _tab[_sz++] = k;
   return [_tracer pushNode];
}

-(void) trust
{
   [_tracer trust];
}

-(void) fail
{
   ORInt ofs = _sz-1;
   if (ofs >= 0) {
      [_tracer popNode];
      NSCont* k = _tab[ofs];
      _tab[ofs] = 0;
      --_sz;
      if (k!=NULL)
         [k call];
      else {
      	@throw [[ORExecutionError alloc] initORExecutionError: "Empty Continuation in backtracking"];
      }
   }
}
- (id) copyWithZone: (NSZone*) zone
{
   ORDFSController* ctrl = [[[self class] allocWithZone:zone] initDFSController:_tracer];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

