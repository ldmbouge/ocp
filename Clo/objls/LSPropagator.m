/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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

@implementation LSBlock
-(id)initWith:(id<LSEngine>)engine block:(void(^)())block atPriority:(id<LSPriority>)p
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
{}
-(void)post
{}
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
{}
-(void)define
{
   NSLog(@"Warning: define of abstract LSPropagator called");
}
-(void)addTrigger:(LSLink*)link
{
   [_inbound addObject:link];
}
-(void)prioritize:(PStore*)p
{
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
   return [[[LSInbound alloc] initWith:_inbound] autorelease];
}
-(void)execute
{
}
@end

@implementation LSPseudoPropagator
-(id)initWith:(LSEngineI*)engine
{
   self = [super init];
   _engine = engine;
   _inbound  = [[NSMutableSet alloc] initWithCapacity:2];
   _outbound = [[NSMutableSet alloc] initWithCapacity:2];
   _rank = [[[engine space] nifty] retain];
   return self;
}
-(void)post
{
   NSLog(@"Warning: define of LSPseudoPropagator called");
}
-(void)define
{
   NSLog(@"Warning: define of LSPseudoPropagator called");
}
-(void)addTrigger:(LSLink*)link
{
   [_inbound addObject:link];
}
-(void)prioritize:(PStore*)p
{
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
   return [[[LSInbound alloc] initWith:_inbound] autorelease];
}
-(id<NSFastEnumeration>)outbound
{
   return [[[LSOutbound alloc] initWith:_outbound] autorelease];
}
-(void)execute
{
}
-(id)addListener:(id)p
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p type:LSPropagate];
   [_outbound addObject:obj];
   return obj;
}
-(id)addLogicalListener:(id)p
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p type:LSLogical];
   [_outbound addObject:obj];
   return obj;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSPseudo(%p) : %d,%@>",self,_name,_rank];
   return buf;
}
@end
// ==============================================================
// Core Views

@implementation LSCoreView
-(id)initWith:(LSEngineI*)engine  domain:(id<ORIntRange>)d src:(NSArray*)src
{
   self = [super init];
   _engine = engine;
   _dom = d;
   _src = src;
   _outbound = [[NSMutableSet alloc] initWithCapacity:2];
   _pullers  = [[NSMutableArray alloc] initWithCapacity:2];
   [_engine trackVariable:self];
   _rank = [[[engine space] nifty] retain];
   
   NSMutableArray* vSrc = [[NSMutableArray alloc] initWithCapacity:[src count]];
   for(id sk in src) {
      if ([sk conformsToProtocol:@protocol(ORIdArray)])
         [vSrc addObject:[_engine pseudoForArray:sk]];
      else [vSrc addObject:sk];
   }
   _inbound = [[NSMutableSet alloc] initWithCapacity:8];
   for(id sk in vSrc) {
      LSLink* link = [sk addListener:self];
      [_inbound addObject:link];
   }
   [vSrc release];
   return self;
}
-(void)dealloc
{
   [_src release];
   [_pullers release];
   [_outbound release];
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
-(id)addLogicalListener:(id)p
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p type:LSLogical];
   [_outbound addObject:obj];
   return obj;
}
-(id)addListener:(id)p
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p type:LSPropagate];
   [_outbound addObject:obj];
   return obj;
}
-(id)addListener:(id)p with:(void(^)())block
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p type:LSPropagate];
   [_outbound addObject:obj];
   [_pullers addObject:[block copy]];
   return obj;
}
-(id)addDefiner:(id)p
{
   assert(NO);
   return nil;
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
   return _inbound ? [_inbound count] : 0;
}
-(id<NSFastEnumeration>)outbound
{
   return [[[LSOutbound alloc] initWith:_outbound] autorelease];
}
-(id<NSFastEnumeration>)inbound
{
   return [[[LSInbound alloc] initWith:_inbound] autorelease];
}
-(void)enumerateOutbound:(void(^)(id))block
{
   for(LSLink* lnk in _outbound)
      block(lnk.target);
}
-(void)scheduleOutbound:(LSEngineI*)engine
{
   for(void(^puller)() in _pullers)
      puller();
   for(LSLink* lnk in _outbound) {
      if (lnk->_t == LSPropagate)
         [engine schedule:lnk->_trg];
   }
}
-(void)execute
{
   [_engine notify:self];
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