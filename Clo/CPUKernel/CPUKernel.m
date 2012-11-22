/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import "CPEngineI.h"

@implementation CPFactory
+(id<CPEngine>) engine: (id<ORTrail>) trail
{
   return [[CPEngineI alloc] initEngine: trail];
}
@end


@implementation VarEventNode
-(VarEventNode*)initVarEventNode:(VarEventNode*)next trigger:(id)t cstr:(CPCoreConstraint*)c at:(ORInt)prio
{
   self = [super init];
   _node = [next retain];
   _trigger = [t copy];
   _cstr = c;
   _priority = prio;
   return self;
}
-(void)dealloc
{
   //NSLog(@"VarEventNode::dealloc] %p\n",self);
   [_trigger release];
   [_node release];
   [super dealloc];
}

void collectList(VarEventNode* list,NSMutableSet* rv)
{
   while(list) {
      VarEventNode* next = list->_node;
      [rv addObject:list->_cstr];
      list = next;
   }
}

void freeList(VarEventNode* list)
{
   while (list) {
      VarEventNode* next = list->_node;
      [list release];
      list = next;
   }
}
@end