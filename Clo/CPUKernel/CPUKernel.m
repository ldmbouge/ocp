/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPClosureEvent.h>
#import <CPUKernel/CPGroup.h>
#import "CPEngineI.h"
#import "CPLearningEngineI.h"

@implementation CPFactory
+(id<CPEngine>) engine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt
{
   return [[CPEngineI alloc] initEngine: trail memory:mt];
}
+(id<CPEngine>) learningEngine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt tracer:(id<ORTracer>)tr
{
   return [[CPLearningEngineI alloc] initEngine: trail memory:mt tracer:tr];
}
+(id<CPGroup>)group:(id<CPEngine>)engine
{
   id<CPGroup> g = [[CPGroup alloc] init:engine];
   [engine trackMutable:g];
   return g;
}
+(id<CPGroup>) bergeGroup: (id<CPEngine>) engine
{
   id<CPGroup> g = [[CPBergeGroup alloc] init:engine];
   [engine trackMutable:g];
   return g;
}
@end


@implementation CPClosureList
-(id)initCPEventNode:(ORClosure)t
                cstr:(id<CPConstraint>)c
                  at:(ORInt)prio
               trail:(id<ORTrail>)trail
{
   self = [super init];
   _node = makeTRId(trail, nil);
   _prev = makeTRId(trail, nil);
   _list = nil;
   _trigger = [t copy];
   _cstr = c;
   _priority = prio;
   return self;
}

-(void)dealloc
{
   //NSLog(@"CPClosureList::dealloc] %p\n",self);
   [_trigger release];
   [_node release];
   [super dealloc];
}
-(ORBool)vertical
{
   return NO;
}
-(ORClosure) trigger
{
   return _trigger;
}
-(id<CPClosureList>) next
{
   return _node;
}
-(id<CPClosureList>) pred
{
   return _prev;
}

-(void)scanWithBlock:(void(^)(id))block
{
   CPClosureList* cur = self;
   while(cur) {
      block(cur->_trigger);
      cur = cur->_node;
   }
}
-(void)scanCstrWithBlock:(void(^)(id))block
{
   CPClosureList* cur = self;
   while(cur) {
      block(cur->_cstr);
      cur = cur->_node;
   }
}

void scanListWithBlock(CPClosureList* cur,ORID2Void block)
{
   while(cur) {
      block(cur->_trigger);
      cur = cur->_node;
   }
}

void collectList(CPClosureList* list,NSMutableSet* rv)
{
   while(list) {
      CPClosureList* next = list->_node;
      [rv addObject:list->_cstr];
      list = next;
   }
}

void freeList(CPClosureList* list)
{
   while (list) {
      CPClosureList* next = list->_node;
      [list release];
      list = next;
   }
}

id<CPClosureList> hookupEvent(id<CPEngine> engine,TRId* evtList,id todo,CPCoreConstraint* c,ORInt priority)
{
   id<ORTrail> trail = [engine trail];
   CPClosureList* evt = [[CPClosureList alloc] initCPEventNode:todo
                                                      cstr:c
                                                        at:priority
                                                     trail:trail];
   evt->_list = evtList;
   evt->_trail = trail;
   [engine trackMutable: evt];
   if (*evtList == nil) {
      assignTRId(&evtList[0], evt, trail);
      assignTRId(&evtList[1], evt, trail);
   } else {
      CPClosureList* second = evtList[0];
      assignTRId(&evt->_node, second, trail);
      assignTRId(&second->_prev,evt,trail);
      assignTRId(&evtList[0],evt,trail);
   }
   return evt;
}
-(void)retract
{
   CPClosureList* p = self->_prev;
   CPClosureList* s = self->_node;
   if (p != nil)
      assignTRId(&p->_node, s, _trail);
   else assignTRId(_list,s,_trail);
   if (s != nil)
      assignTRId(&s->_prev,p,_trail);
   else assignTRId(_list+1,p,_trail);
}

void retract(id<CPClosureList> list)
{
   CPClosureList* me = list;
   CPClosureList* p = me->_prev;
   CPClosureList* s = me->_node;
   if (p != nil)
      assignTRIdNC(&p->_node, s, me->_trail);
   else assignTRIdNC(me->_list,s,me->_trail);
   if (s != nil)
      assignTRIdNC(&s->_prev,p,me->_trail);
   else assignTRIdNC(me->_list+1,p,me->_trail);
}

@end
