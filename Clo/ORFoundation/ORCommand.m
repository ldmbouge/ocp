/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORCommand.h"
#import <pthread.h>

typedef struct {
   Class  _poolClass;
   ORUInt _low;
   ORUInt  _high;
   ORUInt  _mxs;
   ORUInt  _sz;
   id*     _pool;
} ComListPool;


@implementation ORCommandList

static __thread ComListPool* pool = NULL;

+(ComListPool*)instancePool
{
   if (!pool) {
      pool = malloc(sizeof(ComListPool));
      pool->_low = pool->_high = pool->_sz = 0;
      pool->_mxs = 8192;
      pool->_poolClass = self;
      pool->_pool = malloc(sizeof(id)*pool->_mxs);
   }
   return pool;
}

+(id)newCommandList:(ORInt)node memory:(ORInt)mh
{
   ComListPool* p = [self instancePool];
   ORCommandList* rv = NULL;
   if (p->_low == p->_high) {
      rv = NSAllocateObject(self, 0, NULL);
      [rv initCPCommandList:node memory:mh];
   } else {
      rv = p->_pool[p->_low];
      p->_low = (p->_low + 1) % p->_mxs;
      p->_sz--;
      rv->_cnt = 1;
      rv->_ndId = node;
      rv->_mh   = mh;
   }
   return rv;
}
-(id)grab
{
   ++_cnt;
   return self;
}
-(void)letgo
{
   assert(_cnt > 0);
   if (--_cnt == 0) {
      while (_head) {
         struct CNode* nxt = _head->_next;
         CFRelease(_head->_c);//[_head->_c release];
         free(_head);
         _head = nxt;
      }
      _ndId = -1;
      ComListPool* p = [isa instancePool];
      ORUInt next = (p->_high + 1) % p->_mxs;
      if (next == p->_low) {
         [self release];
      } else {
         p->_pool[p->_high] = self;
         p->_sz++;
         p->_high = next;
      }
   }
}
-(ORCommandList*) initCPCommandList: (ORInt) node memory:(ORInt)mh
{
   self = [super init];
   _head = NULL;
   _ndId = node;
   _mh   = mh;
   _cnt  = 1;
   return self;
}
-(void)dealloc
{
   NSLog(@"dealloc on CPCommandList %d\n",_ndId);
   while (_head) {
      struct CNode* nxt = _head->_next;
      CFRelease(_head->_c);//[_head->_c release];
      free(_head);
      _head = nxt;
   }
   [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
   ORCommandList* nList = [ORCommandList newCommandList:_ndId memory:_mh];
   //[[ORCommandList alloc] initCPCommandList:_ndId];
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
   struct CNode* new = malloc(sizeof(struct CNode));
   new->_c = c;
   new->_next = _head;
   _head = new;
}
-(ORInt)length
{
   ORInt nb = 0;
   struct CNode* cur = _head;
   while (cur) {
      nb++;
      cur = cur->_next;
   }
   return nb;
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
   [str appendFormat:@" [%d | %d]:{",_ndId,_mh];
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
-(ORBool)equalTo:(ORCommandList*)cList
{
   return _ndId == cList->_ndId;
}
-(ORInt) memory
{
   return _mh;
}
-(void) setNodeId:(ORInt)nid
{
   _ndId = nid;
}
-(ORInt) getNodeId
{
   return _ndId;
}
-(ORBool)apply:(BOOL(^)(id<ORCommand>))clo
{
   struct CNode* cur = self->_head;
   BOOL ok = YES;
   while (cur && ok) {
      ok = clo(cur->_c);
      cur = cur->_next;
   }
   return YES;
}
-(ORBool)empty
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
   _cnt = 1;
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
