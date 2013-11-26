/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import "CPEngineI.h"
#import "CPAC3Event.h"
#import "CPGroup.h"

@implementation CPFactory
+(id<CPEngine>) engine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt
{
   return [[CPEngineI alloc] initEngine: trail memory:mt];
}
+(id<CPGroup>)group:(id<CPEngine>)engine
{
   id<CPGroup> g = [[CPGroup alloc] init:engine];
   [engine trackMutable:g];
   return g;
}
+(id<CPGroup>)bergeGroup:(id<CPEngine>)engine
{
   id<CPGroup> g = [[CPBergeGroup alloc] init:engine];
   [engine trackMutable:g];
   return g;
}
@end


@implementation CPEventNode
-(id)initCPEventNode:(CPEventNode*)next
             trigger:(id)t
                cstr:(CPCoreConstraint*)c
                  at:(ORInt)prio
               trail:(id<ORTrail>)trail
{
   self = [super init];
   _node = makeTRId(trail, [next retain]);
   _trigger = [t copy];
   _cstr = c;
   _priority = prio;
   return self;
}

-(void)dealloc
{
   //NSLog(@"CPEventNode::dealloc] %p\n",self);
   [_trigger release];
   [_node._val release];
   [super dealloc];
}

-(id)trigger
{
   return _trigger;
}
-(id<CPEventNode>)next
{
   return _node._val;
}

-(void)scanWithBlock:(void(^)(id))block
{
   CPEventNode* cur = self;
   while(cur) {
      block(cur->_trigger);
      cur = cur->_node._val;
   }
}

void scanListWithBlock(CPEventNode* cur,ORID2Void block)
{
   while(cur) {
      block(cur->_trigger);
      cur = cur->_node._val;
   }
}

void collectList(CPEventNode* list,NSMutableSet* rv)
{
   while(list) {
      CPEventNode* next = list->_node._val;
      [rv addObject:list->_cstr];
      list = next;
   }
}

void freeList(CPEventNode* list)
{
   while (list) {
      CPEventNode* next = list->_node._val;
      [list release];
      list = next;
   }
}

void hookupEvent(id<CPEngine> engine,TRId* evtList,id todo,CPCoreConstraint* c,ORInt priority)
{
   id evt = [[CPEventNode alloc] initCPEventNode:evtList->_val
                                          trigger:todo
                                             cstr:c
                                               at:priority
                                           trail:[engine trail]];
   if (evtList->_val == nil) {
      assignTRId(evtList, evt, [engine trail]);
      assignTRId(evtList, evt, [engine trail]);
   } else {
      
   }
      assignTRId(
   assignTRId(evtList, evt, [engine trail]);
   [evt release];
}
@end
