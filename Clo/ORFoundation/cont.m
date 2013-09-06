/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "cont.h"
#import "context.h"
#import "pthread.h"
#import <stdlib.h>

// [ldm] The routine is meant to operate over 32-bit words (4-bytes at a time) or 64-bit wide 
// datum. dest / src must be increased by the data item size.
static inline void fastmemcpy(register ORUInt* dest,register ORUInt* src,register size_t len)
{
   while (len) {
      *dest++ = *src++;
      len -= sizeof(ORUInt);
   }
}

@implementation NSCont
-init 
{
   self = [super init];
   _used   = 0;
   _start  = 0;
   _cnt    = 1;
   return self;
}

-(void)saveStack:(size_t)len startAt:(void*)s 
{
   if (_length!=len) {
      if (_length!=0) free(_data);
      _data = malloc(len);
   }
   fastmemcpy((ORUInt*)_data,(ORUInt*)s,len);
   _length = len;
   _start  = s;
}

-(ORInt) nbCalls { return _used;}

-(void)call 
{
#if defined(__x86_64__)
   register struct Ctx64* ctx = &_target;
   ctx->rax = (long)self;
   restoreCtx(ctx,_start,_data,_length);
#else
   _used++;
   _longjmp(_target,(long)self); // dot not save signal mask --> overhead   
#endif
}

+(NSCont*)takeContinuation 
{
   NSCont* k = [NSCont new];
#if defined(__x86_64__)
   struct Ctx64* ctx = &k->_target;
   register __strong NSCont* resume = saveCtx(ctx,k);
   if (resume != 0) {
      resume->_used++;
      return resume;      
   } else return k;
#else
   int len = getContBase() - (char*)&k;
   [k saveStack:len startAt:&k];
   register NSCont* jmpval = (NSCont*)_setjmp(k->_target);   
   if (jmpval != 0) {
      fastmemcpy(jmpval->_start,(ORUInt*)jmpval->_data,jmpval->_length);
      return jmpval;
   } else 
      return k;   
#endif
}

inline static ContPool* instancePool()
{
   static __thread ContPool* pool = 0;
   if (!pool) {
      pool = malloc(sizeof(ContPool));
      pool->low = pool->high = pool->nbCont = 0;
      pool->poolClass = nil;
   }
   return pool;
}

+(void)shutdown
{
   ContPool* pool = instancePool();
   if (pool) {
      ORInt nb=0;
      for(ORInt k=pool->low;k != pool->high;) {
#if defined(__APPLE__) || !defined(__x86_64__)
         [pool->pool[k] release];
#else
	 NSCont* ptr = pool->pool[k];
	 free(ptr->_data);
	 char* adr = ((char*)ptr) - 16;
	 free(adr);
#endif
         k = (k+1) % pool->sz;
         nb++;
      }
      pool->low = pool->high = 0;
      NSLog(@"released %d continuations out of %d...",nb,pool->nbCont);
   }
}

+(id)new 
{
   ContPool* pool = instancePool();
   if (!pool->poolClass) {
      pool->poolClass = self;
      pool->sz = 1000;
      pool->pool = malloc(sizeof(id)*pool->sz);
   } else {
      if (pool->poolClass != self)
         [NSException raise:NSGenericException
                     format:@"the pool we got is for the wrong class!"];
   }
   NSCont* rv = nil;
   if (pool->low == pool->high) {
      pool->nbCont += 1;
#if defined(__APPLE__) 
      rv = NSAllocateObject(self, 0, NULL);
      rv->_data = 0;
      rv->_length = 0;
      rv->field = 0;
      rv->fieldId = nil;
#else
      // THis is the allocation for Linux 64 where alignments are not
      // respected by GNUstep.
      void* ptr = NULL;
      size_t sz = class_getInstanceSize(self) + 16; // add 16 bytes
      int err = posix_memalign(&ptr,16,sz);
      memset(ptr,0,sz);
      rv = (id)(((char*)ptr)+16);
      object_setClass(rv,self);
#endif
   } else {
      rv = pool->pool[pool->low];
      pool->low = (pool->low+1) % pool->sz;
   }   
   rv->_used   = 0;
   rv->_start  = 0;
   rv->_cnt = 1;
   return rv;
}

- (void)dealloc
{
   free(_data);
   [super dealloc];
}

-(NSCont*)grab
{
   ++_cnt;
   return self;
}

-(void)letgo 
{
   assert(_cnt > 0);
   if (--_cnt == 0) {
      ContPool* pool = instancePool();
      ORUInt next = (pool->high + 1) % pool->sz;
      if (next == pool->low) {
         free(_data);
         pool->nbCont -= 1;
#if defined(__APPLE__) || !defined(__x86_64__)
         NSDeallocateObject(self);
#else
	 char* ptr = self;
	 ptr = ptr - 16;
	 free(ptr);
#endif
         return;
      }
      pool->pool[pool->high] = self;
      pool->high = next;      
   }
}

@synthesize field;
@synthesize fieldId;

@end
