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
static inline void fastmemcpy(register CPUInt* dest,register CPUInt* src,register size_t len)
{
   while (len) {
      *dest++ = *src++;
      len -= sizeof(CPUInt);
   }
}

@implementation NSCont
-init {
   self = [super init];
   _used   = 0;
   _start  = 0;
   _cnt    = 1;
   return self;
}

-(void)saveStack:(size_t)len startAt:(void*)s {
   if (_length!=len) {
      if (_length!=0) free(_data);
      _data = malloc(len);
   }
   fastmemcpy((CPUInt*)_data,(CPUInt*)s,len);
   _length = len;
   _start  = s;
}

-(CPInt) nbCalls { return _used;}

-(void)call {
#if defined(__x86_64__)
   register struct Ctx64* ctx = &_target;
   ctx->rax = (long)self;
   restoreCtx(ctx,_start,_data,_length);
#else
   _used++;
   _longjmp(_target,(long)self); // dot not save signal mask --> overhead   
#endif
}

+(NSCont*)takeContinuation {
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
      fastmemcpy(jmpval->_start,(CPUInt*)jmpval->_data,jmpval->_length);
      return jmpval;
   } else 
      return k;   
#endif
}

static pthread_key_t pkey;
static void init_pthreads() 
{
   pthread_key_create(&pkey,NULL);   
}

+(ContPool*)instancePool
{
   if ([NSThread isMainThread]) {
      static ContPool myPool = {0,0,0,0,0};
      return &myPool;
   } else {
      static pthread_once_t block = PTHREAD_ONCE_INIT;
      pthread_once(&block,init_pthreads);
      ContPool* pool = pthread_getspecific(pkey);
      if (!pool) {
         pool = malloc(sizeof(ContPool));
         pthread_setspecific(pkey,pool);
         pool->low = pool->high = pool->nbCont = 0;
         pool->poolClass = nil;
      }
      return pool;
      
   }
}

+(void)shutdown
{
   ContPool* pool = [self instancePool];
   if (pool) {
      CPInt nb=0;
      for(CPInt k=pool->low;k != pool->high;) {
         [pool->pool[k] release];
         k = (k+1) % pool->sz;
         nb++;
      }
      pool->low = pool->high = 0;
      NSLog(@"released %d continuations out of %d...",nb,pool->nbCont);
   }
}

+(id)new {
   ContPool* pool = [self instancePool];
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
      rv = NSAllocateObject(self, 0, NULL);
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

-(void)grab
{
   ++_cnt;
}

-(void)letgo 
{
   if (--_cnt == 0) {
      ContPool* pool = [isa instancePool];
      CPUInt next = (pool->high + 1) % pool->sz;
      if (next == pool->low) {
         free(_data);
         pool->nbCont -= 1;
         NSDeallocateObject(self);
         return;
      }
      pool->pool[pool->high] = self;
      pool->high = next;      
   }
}

@synthesize field;
@synthesize fieldId;

@end
