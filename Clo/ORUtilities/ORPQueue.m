/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORPQueue.h"

@interface ORPQLocator : NSObject<ORLocator> {
   id _key;
   id _object;
   @package
   ORInt _ofs;
}
-(id)initWithObject:(id)obj andKey:(id)key;
-(id)key;
-(id)object;
-(void)updateKey:(id)k;
@end

@implementation ORPQLocator
-(id)initWithObject:(id)obj andKey:(id)key
{
   self = [super init];
   _key    = [key retain];
   _object = [obj retain];
   return self;
}
-(void)dealloc
{
   //NSLog(@"Deallocating(%p): %@",self,self);
   [_key release];
   [_object release];
   [super dealloc];
}
-(id)key
{
   return _key;
}
-(id)object
{
   return _object;
}
-(void)updateKey:(id)k
{
   [_key release];
   _key = [k retain];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ -> %@>",[_key description],[_object description]];
   return buf;
}
@end

@implementation ORPQueue {
   BOOL (^better)(id,id);
   ORInt  _mxs;
   ORInt  _sz;
   ORPQLocator** _tab;
}
static inline ORInt parent(ORInt i) { return (i-1) / 2;}
static inline ORInt left(ORInt i)   { return i * 2 + 1;}
static inline ORInt right(ORInt i)  { return i * 2 + 2;}
static void heapify(ORPQueue* pq,ORInt i)
{
   do {
      const ORInt l = left(i);
      const ORInt r = right(i);
      ORInt m;
      if (l < pq->_sz && pq->better(pq->_tab[l].key,pq->_tab[i].key))
         m = l;
      else m = i;
      if (r < pq->_sz && pq->better(pq->_tab[r].key,pq->_tab[m].key))
         m = r;
      if (i != m) {
         ORPQLocator* x = pq->_tab[i];
         pq->_tab[i] = pq->_tab[m];
         pq->_tab[m] = x;
         pq->_tab[i]->_ofs = i;
         pq->_tab[m]->_ofs = m;
         i = m;
      } else break;
   } while(TRUE);
}
-(ORPQueue*)init:(BOOL(^)(id,id))cmp
{
   self = [super init];
   better = [cmp copy];
   _mxs   = 32;
   _sz    = 0;
   _tab   = malloc(sizeof(ORPQLocator*)*_mxs);
   return self;
}
-(void)dealloc
{
   [better release];
   for(ORInt i=0;i<_sz;i++)
      [_tab[i] release];
   free(_tab);
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(ORInt i=0;i<_sz;i++)
      [buf appendFormat:@"%2d : %@\n",i,[_tab[i] description]];
   return buf;
}
-(void)buildHeap
{
   for(ORInt i=_sz /2 ;i >= 0;--i)
      heapify(self, i);
}
-(void)resize
{
   ORPQLocator** new = malloc(sizeof(ORPQLocator*)*_mxs * 2);
   for(ORInt i=0;i<_mxs;i++)
      new[i] = _tab[i];
   _mxs <<= 1;
   free(_tab);
   _tab = new;
}
-(id<ORLocator>)addObject:(id)obj forKey:(id)key
{
   if (_sz >= _mxs - 1)
      [self resize];
   id<ORLocator> rv = _tab[_sz] = [[ORPQLocator alloc] initWithObject:obj andKey:key];
   _tab[_sz++]->_ofs = _sz;
   return rv;
}
-(id<ORLocator>)insertObject:(id)obj withKey:(id)key
{
   if (_sz >= _mxs - 1)
      [self resize];
   ORPQLocator* toInsert = [[ORPQLocator alloc] initWithObject:obj andKey:key];
   ORInt i = _sz++;
   while(i>=0 && better(key,_tab[parent(i)].key)) {
      _tab[i] = _tab[parent(i)];
      _tab[i]->_ofs = i;
      i = parent(i);
   }
   _tab[i] = toInsert;
   _tab[i]->_ofs = i;
   return toInsert;
}
-(void)update:(ORPQLocator*)loc toKey:(id)key
{
   if (better(key,loc.key)) {
      ORInt i = loc->_ofs;
      while(i > 0 && better(key,_tab[parent(i)].key)) {
         _tab[i] = _tab[parent(i)];
         _tab[i]->_ofs = i;
         i = parent(i);
      }
      _tab[i] = loc;
      _tab[i]->_ofs = i;
   } else
      heapify(self,loc->_ofs);
   [loc updateKey:key];
}
-(id)peekAtKey
{
   return _tab[0].key;
}
-(id)peekAtObject
{
   return _tab[0].object;
}
-(id)extractBest
{
   ORPQLocator* t = _tab[0];
   _tab[0] = _tab[--_sz];
   _tab[0]->_ofs = 0;
   heapify(self, 0);
   id rv = [t object];
   [t release];
   return rv;
}
-(ORInt)size
{
   return _sz;
}
-(BOOL)empty
{
   return _sz==0;
}
@end
