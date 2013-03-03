/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORCommand.h"

@implementation ORCommandList
-(ORCommandList*)initCPCommandList
{
   self = [super init];
   _head = NULL;
   _ndId = -1; // undefined
   return self;
}
-(ORCommandList*) initCPCommandList: (ORInt) node
{
   self = [super init];
   _head = NULL;
   _ndId = node;
   return self;
}
-(void)dealloc
{
   //NSLog(@"dealloc on CPCommandList %ld\n",_ndId);
   while (_head) {
      struct CNode* nxt = _head->_next;
      [_head->_c release];
      free(_head);
      _head = nxt;
   }
   [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
   ORCommandList* nList = [[ORCommandList alloc] initCPCommandList:_ndId];
   struct CNode* cur = _head;
   struct CNode* first = NULL;
   struct CNode* last  = NULL;
   while (cur) {
      struct CNode* cpy = malloc(sizeof(struct CNode));
      cpy->_next = NULL;
      cpy->_c = [cur->_c retain];
      if (last) {
         last->_next = cpy;
         last = cpy;
      } else
         first = last = cpy;
      cur = cur->_next;
   }
   nList->_head = first;
   return nList;
}

-(void)insert:(id<ORCommand>)c
{
   struct CNode* new = malloc(sizeof(struct CNode*));
   new->_c = c;
   new->_next = _head;
   _head = new;
}
-(id<ORCommand>)removeFirst
{
   struct CNode* leave = _head;
   _head = _head->_next;
   id<ORCommand> rv = leave->_c;
   free(leave);
   return rv;
}
-(NSString*)description
{
   NSMutableString* str = [NSMutableString stringWithCapacity:512];
   [str appendFormat:@" [%d]:{",_ndId];
   struct CNode* cur = _head;
   while (cur) {
      [str appendString:[cur->_c description]];
      cur = cur->_next;
      if (cur != NULL)
         [str appendString:@","];
   }
   [str appendString:@"}"];
   return str;
}
-(bool)equalTo:(ORCommandList*)cList
{
   return _ndId == cList->_ndId;
}
-(void) setNodeId:(ORInt)nid
{
   _ndId = nid;
}
-(ORInt) getNodeId
{
   return _ndId;
}
-(bool)apply:(bool(^)(id<ORCommand>))clo
{
   struct CNode* cur = _head;
   while (cur) {
      bool ok = clo(cur->_c);
      if (!ok)
         return false;
      cur = cur->_next;
   }
   return true;
}
-(bool)empty
{
   return _head==0;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
   ORUInt cnt = 0;
   struct CNode* cur = _head;
   while (cur) {
      cur = cur->_next;
      ++cnt;
   }
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_ndId];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&cnt];
   cur = _head;
   while (cur) {
      [aCoder encodeObject:cur->_c];
      cur = cur->_next;
   }
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   ORUInt cnt = 0;
   _head = 0;
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_ndId];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&cnt];
   ORUInt i = 0;
   struct CNode* tail = 0;
   while (i < cnt) {
      id<ORCommand> com = [[aDecoder decodeObject] retain];
      struct CNode* nn = malloc(sizeof(struct CNode));
      nn->_next = 0;
      nn->_c = com;
      if (tail == 0)
         _head = tail = nn;
      else tail->_next = nn;
      tail = nn;
      i++;
   }
   return self;
}
@end
