/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSPropagator.h"
#import <ORUtilities/ORPQueue.h>
#import "LSVar.h"
#import "LSIntVar.h"
#import "LSFactory.h"
#import "LSCount.h"

// [pvh]: Not clue what this guy does and what it is used for

@implementation LSBlock
-(id)initWith:(id<LSEngine>)engine block:(ORClosure)block atPriority:(id<LSPriority>)p
{
   self = [super initWith:engine];
   _block  = [block copy];
   _rank   = [p retain];
   return self;
}
-(void)dealloc
{
   [_block release];
   [_rank release];
   [super dealloc];
}
-(void)define
{
}
-(void)post
{
}
-(void)execute
{
   _block();
}
-(id<LSPriority>)rank
{
   return _rank;
}
-(void)setRank:(id<LSPriority>)rank
{
   [_rank release];
   _rank = [rank retain];
}
@end

@implementation LSPropagator
-(id)initWith:(LSEngineI*)engine
{
   self = [super init];
   _engine = engine;
   _inbound = [[NSMutableSet alloc] initWithCapacity:2];
   _rank = [[[engine space] nifty] retain];    
   _inQueue = NO;
   return self;
}
-(void)post
{
}
-(void)define
{
   NSLog(@"Warning: define of abstract LSPropagator called");
}
-(void)addTrigger:(id)link
{
   [_inbound addObject:link];
}
-(id<LSPriority>)rank
{
   return _rank;
}
-(void)setRank:(id<LSPriority>)r
{
   [_rank release];
   _rank = [r retain];
}
-(NSUInteger)inDegree
{
   return [_inbound count];
}
-(id<NSFastEnumeration>)inbound
{
   return _inbound;
}
-(void)execute
{
}
@end

// ==============================================================
// Core Views

@interface LSViewPropagator : LSPropagator {
   id _target;
}
-(id)initWith:(id<LSEngine>)engine src:(NSArray*)src trg:(id)var;
-(void)post;
-(void)define;
-(void)execute;
@end

@implementation LSViewPropagator
-(id)initWith:(id<LSEngine>)engine src:(NSArray*)src trg:(id)var;
{
   self = [super initWith:engine];
   _target = var;
   for(id<LSVar> sv in src)
      [self addTrigger:[sv addListener:self]];
   [_engine trackObject:self];
   [_engine add:self];
   return self;
}
-(void)post
{
}
-(void)define
{
}
-(void)execute
{
   [_engine notify:_target];
}
-(id<NSFastEnumeration>)outbound
{
   return [NSSet setWithObject:_target];
}
@end


// [pvh] This guy is a variable: This is not a propagator

@implementation LSCoreView
-(id)initWith:(LSEngineI*)engine  domain:(id<ORIntRange>)d src:(NSArray*)src
{
   self = [super init];
   _engine = engine;
   _dom = d;
   _src = src;
   LSViewPropagator* vp = [[LSViewPropagator alloc] initWith:_engine src:src trg:self];
   // [pvh]: most likely a bunch of propagator (to be confirmed)
   _outbound = [[NSMutableSet alloc] initWithCapacity:2];
   // [pvh]: the inbound is the propagator
   _inbound  = [[NSMutableSet alloc] initWithObjects:vp, nil];
   _closures  = [[NSMutableArray alloc] initWithCapacity:2];
   [_engine trackVariable:self];
   _rank    = [[[engine space] nifty] retain];
   return self;
}
-(void)dealloc
{
   [_src release];
   [_closures release];
   [_outbound release];
   [_inbound release];
   [super dealloc];
}
-(NSArray*)sourceVars
{
   return _src;
}
-(LSEngineI*)engine
{
   return _engine;
}
-(id<ORIntRange>)domain
{
   return _dom;
}
-(void)setValue:(ORInt)v
{
   assert(NO);
}
// [pvh] I really do not like this
-(id)addListener:(id)p
{
   [_outbound addObject:p];
   return self;
}
-(id)addListener:(id)p with:(ORClosure)block
{
   [_outbound addObject:p];
   [_closures addObject:[block copy]];
   return self;
}
-(id)addDefiner:(id)p
{
   assert(NO);
   return p;
}
-(NSUInteger)inDegree
{
   return 1;
}
-(id<NSFastEnumeration>)outbound
{
   return _outbound;
}
-(id<NSFastEnumeration>)inbound
{
   return _inbound;
}
-(id<LSPriority>)rank
{
   return _rank;
}
-(void)setRank:(id<LSPriority>)r
{
   [_rank release];
   _rank = [r retain];
}
-(void)enumerateOutbound:(void(^)(id))block
{
   for(id<LSPropagator> lnk in _outbound)
      block(lnk);
}
-(void)scheduleOutbound:(LSEngineI*)engine
{
   for(void(^closure)() in _closures)
      closure();
   for(id lnk in _outbound)
      [engine schedule:lnk];
}
-(LSGradient)decrease:(id<LSIntVar>)x
{
   assert(NO);
   LSGradient rv;
   return rv;
}
-(LSGradient)increase:(id<LSIntVar>)x
{
   assert(NO);
   LSGradient rv;
   return rv;
}
@end
// ========================================================================================
// Int Views

@implementation LSIntVarView
-(id)initWithEngine:(LSEngineI*)engine domain:(id<ORIntRange>)d fun:(ORInt(^)())fun src:(NSArray*)src
{
   self = [super initWith:engine domain:d src:src];
   _fun = [fun copy];
   return self;
}
-(void)dealloc
{
   [_fun release];
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"view<LS>(%p,%d,%@) = %d",self,_name,_rank,_fun()];
   return buf;
}
-(ORInt)value
{
   return _fun();
}
@end
// ==============================================================

@implementation LSEQLitView
-(id)initWithEngine:(LSEngineI*)engine on:(id<LSIntVar>)x eqLit:(ORInt)c
{
   self = [super initWith:engine domain:RANGE(engine,0,1) src:@[x]];
   _x   = x;
   _lit = c;
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"EQLitView<LS>(%p,%d,%@) %p == %d",self,_name,_rank,_x,_lit];
   return buf;
}
-(ORInt)value
{
   return _x.value == _lit;
}
-(LSGradient)decrease:(id<LSIntVar>)x
{
   LSGradient rv;
   if (getId(_x) == getId(x)) {
      rv._gt = LSGVar;
      rv._vg = self;
   } else {
      rv._gt = LSGCst;
      rv._cg = 0;
   }
   return rv;
}
-(LSGradient)increase:(id<LSIntVar>)x
{
   LSGradient rv;
   if (getId(_x) == getId(x)) {
      rv._gt = LSGVar;
      rv._vg = [LSFactory intVar:_engine domain:_dom];
      [_engine add:[LSFactory inv:rv._vg equal:^ORInt{
         return 1 - self.value;
      } vars:@[self]]];
   } else {
      rv._gt = LSGCst;
      rv._cg = 0;
   }
   return rv;
}
@end

// ==============================================================
@implementation PStore

-(id)initPStore:(LSEngineI*)engine
{
   self = [super init];
   _engine = engine;
   _marks  = NULL;
   _low = _up = 0;
   return self;
}
-(BOOL)closed:(id<ORObject>)v
{
   return YES;
}
-(BOOL)finalNotice:(id<ORObject>)v
{
   return YES;
}
-(BOOL)lastTime:(id<ORObject>)v
{
   return YES;
}

-(id<LSPriority>)maxWithRank:(id<LSPriority>)p
{
   return p;
}

-(void)prioritize
{
   @autoreleasepool {
      ORPQueue* pq = [[ORPQueue alloc] init:^BOOL(NSNumber* a,NSNumber* b) {
         return [a intValue] < [b intValue];
      }];
      ORUInt nbo = [_engine nbObjects];
      id<ORLocator>* loc = malloc(sizeof(id<ORLocator>)*nbo);
      memset(loc,0,sizeof(id)*nbo);
      for(id<LSVar> v in [_engine variables])
         loc[v.getId] = [pq addObject:v forKey:@([v inDegree])];
      for(LSPropagator* v in [_engine invariants])
         loc[v.getId] = [pq addObject:v forKey:@([v inDegree])];
      [pq buildHeap];
      LSPrioritySpace* space = [_engine space];
      while (![pq empty]) {
         id node = [pq extractBest];
         id<LSPriority> cur = [space nifty];
         for(id<LSObject> x in [node inbound]) {
            //NSLog(@"Got a predecessor %@",x);
            cur = maxPriority(cur, [x rank]);
         }
         cur = priorityAfter(space, cur);
         [node setRank:cur];
         for(ORObject* x in [node outbound]) {
            //NSLog(@"OUT FROM(%@) is %@",node,x);
            [pq update:loc[x.getId] toKey:@([loc[x.getId].key intValue] - 1)];
         }
      }
      free(loc);
      [pq release];
   }
   for(id<LSPropagator> v in [_engine invariants])
      [v post];
//   for(id<LSVar> v in [_engine variables])
//      NSLog(@"%@",v);
//   for(id<LSPropagator> v in [_engine invariants])
//      NSLog(@"%@",v);
}

@end