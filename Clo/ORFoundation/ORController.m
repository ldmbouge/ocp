/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/cont.h>

@implementation ORHeist
-(ORHeist*)init:(NSCont*)c from:(id<ORCheckpoint>)cp oValue:(id<ORObjectiveValue>)ov;
{
   self = [super init];
   _cont = [c grab];
   _theCP = [cp grab];
   _oValue = [ov retain];
   return self;
}
-(void)dealloc
{
   [_cont letgo];
   [_theCP letgo];
   [_oValue release];
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
-(ORInt)sizeEstimate
{
   return [_theCP sizeEstimate];
}
-(id<ORObjectiveValue>)oValue
{
   return _oValue;
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
   //NSLog(@"ORDefaultController %p dealloc called...\n",self);
   [_controller release];
   [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
   ORDefaultController* ctrl = [[[self class] allocWithZone:zone] initORDefaultController];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
-(id<ORSearchController>)clone
{
   ORDefaultController* c = [[ORDefaultController alloc] initORDefaultController];
   c->_controller = _controller;
   return c;
}
-(id<ORSearchController>)tuneWith:(id<ORTracer>)tracer engine:(id<OREngine>)engine pItf:(id<ORPost>)pItf
{
   return self;
}
-(id<ORSearchController>) controller
{
   return _controller;
}
-(void) setController: (id<ORSearchController,ORStealing>) controller
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
-(void) fail: (ORBool) pruned
{
   if (_controller)
      [_controller fail: pruned];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "Call to Default Search Controller for method fail/1"];
}
-(void) succeeds
{
   [_controller succeeds]; // failAll is meant to be handled by the first controller in the chain. (The actual policy)
}
-(void) abort
{
   [_controller abort];
}
-(ORBool) isFinitelyFailed
{
   return [_controller isFinitelyFailed];
}
-(ORBool) isAborted
{
   return [_controller isAborted];
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
   BOOL                   _isAborted;
}
-(id)init:(id<ORSearchController>)chain parent:(id<ORSearchController>)par
{
   self = [super initORDefaultController];
   [self setController:chain];
   _parent = [par retain];
   _isFF = NO;
   _isAborted = NO;
   return self;
}
-(void)dealloc
{
   //NSLog(@"ORNestedController %p dealloc called...\n",self);
   [_parent release];
   [super dealloc];
}
-(id<ORSearchController>)clone
{
   ORNestedController* c = [[ORNestedController alloc] init:_controller parent:_parent];
   return c;
}
-(id<ORSearchController>)tuneWith:(id<ORTracer>)tracer engine:(id<OREngine>)engine pItf:(id<ORPost>)pItf
{
   return self;
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
-(void) fail: (ORBool) pruned
{
   [_controller fail: pruned];      // if we ever come back, the controller nodes supply is exhausted -> finitelyFailed.
   [self finitelyFailed];
}

-(void) succeeds
{
   _isFF = NO;
   [_controller cleanup];
   [_parent fail];
}
-(void) abort
{
   _isAborted = YES;
   [_controller cleanup];
   [_parent fail];
}
-(void) finitelyFailed
{
   _isFF = YES;
   //[_controller cleanup];
   [_parent fail];
}
-(ORBool) isFinitelyFailed
{
   return _isFF;
}
-(ORBool) isAborted
{
   return _isAborted;
}
@end

@implementation ORDFSController
{
   NSCont**          _tab;
   ORInt              _sz;
   ORInt              _mx;
   id<ORTracer>   _tracer;
   ORInt          _atRoot;
}
+(id<ORSearchController>)proto
{
   return [[ORDFSController alloc] initTheControllerWithTracer:nil];
}
-(id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model
{
   self = [super initORDefaultController];
   _tracer = tracer ? [tracer retain] : nil;
   _mx  = 100;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _sz  = 0;
   _atRoot = 0;
   [model release]; // not needed
   return self;
}

- (id) initTheControllerWithTracer:(id<ORTracer>)tracer
{
   self = [super initORDefaultController];
   _tracer = tracer ? [tracer retain] : nil;
   _mx  = 100;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _sz  = 0;
   _atRoot = 0;
   return self;
}
- (void) dealloc
{
   //NSLog(@"DFSController dealloc called...\n");
   if (_tracer)
      [_tracer release];
   free(_tab);
   [super dealloc];
}
-(id<ORSearchController>)clone
{
   ORDFSController* c = [[ORDFSController alloc] initTheController:_tracer engine:nil posting:nil];
   free(c->_tab);
   c->_tab = malloc(sizeof(NSCont*)*_mx);
   for(ORInt k=0;k<_sz;k++) {
      c->_tab[k] = _tab[k];
   }
   c->_sz = _sz;
   c->_mx = _mx;
   return c;
}
-(id<ORSearchController>)tuneWith:(id<ORTracer>)tracer engine:(id<OREngine>)engine pItf:(id<ORPost>)pItf
{
   [_tracer release];
   _tracer = [tracer retain];
   return self;
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
-(void) fail: (ORBool) pruned
{
   [self fail];
}
-(void) fail
{
   ORInt ofs = _sz-1;
   if (ofs >= 0) {
      [[_tracer popNode] letgo];
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
   ORDFSController* ctrl = [[[self class] allocWithZone:zone] initTheControllerWithTracer:_tracer];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

