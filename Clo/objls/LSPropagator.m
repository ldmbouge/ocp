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

@implementation LSPropagator

-(id)initWith:(LSEngineI*)engine
{
   self = [super init];
   _engine = engine;
   _inbound = [[NSMutableSet alloc] initWithCapacity:2];
   _rank = [[[engine space] nifty] retain];
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
   
   for(id<LSVar> v in [_engine variables])
      NSLog(@"%@",v);
   for(id<LSPropagator> v in [_engine invariants])
      NSLog(@"%@",v);
}

@end