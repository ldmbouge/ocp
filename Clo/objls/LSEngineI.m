/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSEngineI.h"
#import "LSPriority.h"
#import "LSPropagator.h"
#import "LSIntVar.h"
#import "LSConstraint.h"
#import <ORUtilities/ORPQueue.h>

@interface LSRQueue : ORPQueue {
   LSEngineI* _engine;
}
-(id)init:(LSEngineI*)engine;
-(void)enQueue:(id<LSPropagator>)x atPriority:(id<LSPriority>)p;
-(id<LSPropagator>)deQueue;
@end

@implementation LSRQueue
-(id)init:(LSEngineI*)engine
{
   self = [super init:^BOOL(NSNumber* a,NSNumber* b) {
      return a.intValue < b.intValue;
   }];
   _engine = engine;
   return self;
}
-(void)enQueue:(LSPropagator*)x atPriority:(LSPriority*)p
{
   if (!x->_inQueue) {
      [self insertObject:x withKey:@([p getId])];
      x->_inQueue = YES;
   }
}
-(id<LSPropagator>)deQueue
{
   LSPropagator* p = [self extractBest];
   p->_inQueue = NO;
   return p;
}
@end

@implementation LSEngineI

-(LSEngineI*)initEngine
{
   self = [super init];
   _vars = [[NSMutableArray alloc] initWithCapacity:64];
   _objs = [[NSMutableArray alloc] initWithCapacity:64];
   _cstr = [[NSMutableArray alloc] initWithCapacity:64];
   _invs = [[NSMutableArray alloc] initWithCapacity:64];
   _pSpace = [[LSPrioritySpace alloc] init];
   _queue = [[LSRQueue alloc] init:self];
   _nbObjects = 0;
   _atomic  = NO;
   return self;
}
-(void)dealloc
{
   [_queue release];
   [_vars release];
   [_objs release];
   [_cstr release];
   [_invs release];
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSEngineI: %p>",self];
   return buf;
}
-(id<ORTracker>) tracker
{
   return self;
}
-(id) inCache:(id)obj
{
   return nil;
}
-(id) addToCache:(id)obj
{
   return obj;
}
-(id) trackVariable: (id) var
{
   [var setId:_nbObjects++];
   [_vars addObject:var];
   return var;
}
-(id) trackMutable:(id)obj
{
   [obj setId:_nbObjects++];
   [_objs addObject:obj];
   return obj;
}
-(id) trackObject: (id) obj
{
   [obj setId:_nbObjects++];
   [_objs addObject:obj];
   return obj;
}
-(id) trackImmutable: (id) obj
{
   return obj;
}
-(id) trackObjective:(id) obj
{
   return obj;
}
-(id) trackConstraintInGroup:(id) obj
{
   return obj;
}
-(LSPrioritySpace*)space
{
   return _pSpace;
}
-(ORStatus) close
{
   if (_mode == LSIncremental) return ORSuspend;
   _mode = LSClosing;
   for(id<LSConstraint> c in _cstr)
      [c post];
   for(id<LSPropagator> p in _invs)
      [p define];
   PStore* store = [[PStore alloc] initPStore:self];
   [store prioritize];
   [store release];
   _mode = LSIncremental;
   return ORSuspend;
}
-(ORBool) closed
{
   return _mode == LSIncremental;
}
-(ORUInt)nbObjects
{
   return _nbObjects;
}
-(NSMutableArray*) variables
{
   return _vars;
}
-(NSMutableArray*)invariants
{
   return _invs;
}
-(id<ORTrail>) trail
{
   return nil;
}
-(ORStatus)enforceObjective
{
   return ORSuspend;
}

-(void)clearStatus
{
}
-(void)add:(LSPropagator*)i
{
   [_invs addObject:i];
}
-(id<LSConstraint>)addConstraint:(id<LSConstraint>)cstr
{
   [_cstr addObject:cstr];
   return cstr;
}
-(void)atomic:(void(^)())block
{
   _atomic = YES;
   block();
   _atomic = NO;
   [self propagate];
}
-(void)notify:(id<LSVar>)x
{
   if (_mode <= LSClosing)
      return;
   if (_atomic) {
      LSBlock* b = [[LSBlock alloc] initWith:self block:^{
         [x enumerateOutbound:^(id<LSPropagator,LSPull> p,ORInt k) {
            [p pull:k];
            [self schedule:p];
         }];
      } atPriority:x.rank];
      [_queue enQueue:b atPriority:x.rank];
   } else {
      [x enumerateOutbound:^(id<LSPropagator> p,ORInt k) {
         BOOL canPull = [p conformsToProtocol:@protocol(LSPull)];
         if (canPull)
            [(id<LSPull>)p pull:k];
         [self schedule:p];
      }];
   }
}
-(void)schedule:(id<LSPropagator>)x
{
   [_queue enQueue:x atPriority:x.rank];
}
-(ORStatus)propagate
{
   if (_atomic) return ORSkip;
   @autoreleasepool {
      while (![_queue empty]) {
         id<LSPropagator> p = [_queue deQueue];
         [p execute];
      }
   }
   return ORSuspend;
}
-(void)label:(LSIntVar*)x with:(ORInt)v
{
   [x setValue: v];
   [self propagate];
}
@end
