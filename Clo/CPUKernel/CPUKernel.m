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

void hookupEvent(id<CPEngine> engine,TRId* evtList,id todo,CPCoreConstraint* c,ORInt priority)
{
   id<ORTrail> trail = [engine trail];
   CPClosureList* evt = [[CPClosureList alloc] initCPEventNode:todo
                                                      cstr:c
                                                        at:priority
                                                     trail:trail];
   [engine trackMutable: evt];
   if (*evtList == nil) {
      assignTRId(&evtList[0], evt, trail);
      assignTRId(&evtList[1], evt, trail);
   } else {
      assignTRId(&evt->_node, evtList[0], trail);
      assignTRId(&evtList[0],evt,trail);
   }
//
//    // [ldm] insert at end version!
//   if (evtList->_val == nil) {
//      assignTRId(&evtList[0], evt, trail);
//      assignTRId(&evtList[1], evt, trail);
//   } else {
//      CPClosureList* lastNode = evtList[1]._val;
//      assignTRId(&lastNode->_node, evt, trail);
//      assignTRId(&evtList[1], evt, trail);
//   }
//
}
@end
