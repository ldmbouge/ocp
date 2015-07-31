/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORCommand.h>
#import <ORFoundation/ORConstraint.h>
#import <pthread.h>
#import <objc/runtime.h>
#import <Foundation/NSThread.h>

typedef struct {
   Class  _poolClass;
   ORUInt _low;
   ORUInt  _high;
   ORUInt  _mxs;
   ORUInt  _sz;
   id*     _pool;
} ComListPool;


@implementation ORCommandList

struct CNode {
   id<ORConstraint>    _c;
   struct CNode*    _next;
};

#if TARGET_OS_IPHONE
+(ComListPool*)instancePool
{
   NSMutableDictionary* mt = NSThread.currentThread.threadDictionary;
   NSValue* pool =[mt objectForKey:@(1)];
   if (!pool) {
      ComListPool* poolPtr = malloc(sizeof(ComListPool));
      poolPtr->_low = poolPtr->_high = poolPtr->_sz = 0;
      poolPtr->_mxs = 8192;
      poolPtr->_poolClass = self;
      poolPtr->_pool = malloc(sizeof(id)*poolPtr->_mxs);
      pool = [NSValue valueWithPointer:poolPtr];
      [mt setObject:pool forKey:@(1)];
   }
   return (ComListPool*)[pool pointerValue];
}
#else
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
#endif


+(id)newCommandList:(ORInt)node from:(ORInt)fh to:(ORInt)th
{
   ComListPool* p = [self instancePool];
   ORCommandList* rv = NULL;
   if (p->_low == p->_high) {
      rv = NSAllocateObject(self, 0, NULL);
      [rv initCPCommandList:node from:fh to:th];
   } else {
      rv = p->_pool[p->_low];
      p->_low = (p->_low + 1) % p->_mxs;
      p->_sz--;
      rv->_cnt = 1;
      rv->_ndId = node;
      rv->_fh   = fh;
      rv->_th   = th;
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
         [_head->_c release];
         free(_head);
         _head = nxt;
      }
      _ndId = -1;
      ComListPool* p = [object_getClass(self) instancePool];
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
-(ORCommandList*) initCPCommandList: (ORInt) node from:(ORInt)fh to:(ORInt)th
{
   self = [super init];
   _head = NULL;
   _ndId = node;
   _fh   = fh;
   _th   = th;
   _cnt  = 1;
   return self;
}
-(void)dealloc
{
   NSLog(@"dealloc on CPCommandList %d\n",_ndId);
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
   ORCommandList* nList = [ORCommandList newCommandList:_ndId from:_fh to:_th];
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
-(void)setMemoryTo:(ORInt)ml
{
   _th = ml;
}

-(void)insert:(id<ORConstraint>)c
{
   struct CNode* new = malloc(sizeof(struct CNode));
   new->_c = [c retain];
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
-(id<ORConstraint>)removeFirst
{
   struct CNode* leave = _head;
   _head = _head->_next;
   id<ORConstraint> rv = leave->_c;
   free(leave);
   return rv;
}
-(NSString*)description
{
   NSMutableString* str = [NSMutableString stringWithCapacity:512];
   [str appendFormat:@" [%d | %d - %d]:{",_ndId,_fh,_th];
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
-(ORInt) memoryFrom
{
   return _fh;
}
-(ORInt) memoryTo
{
   return _th;
}
-(void) setNodeId:(ORInt)nid
{
   _ndId = nid;
}
-(ORInt) getNodeId
{
   return _ndId;
}
-(ORBool)apply:(BOOL(^)(id<ORConstraint>))clo
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
      id<ORConstraint> com = [[aDecoder decodeObject] retain];
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
