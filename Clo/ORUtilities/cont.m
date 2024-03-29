/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORUtilities/cont.h>
#import <ORUtilities/context.h>
#import "pthread.h"
#import <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct  {
   Class poolClass;
   ORUInt low;
   ORUInt high;
   ORUInt sz;
   ORUInt nbCont;
   id*          pool;
} ContPool;

// [ldm] The routine is meant to operate over 32-bit words (4-bytes at a time) or 64-bit wide 
// datum. dest / src must be increased by the data item size.
static inline void fastmemcpy(register ORUInt* dest,register ORUInt* src,register size_t len)
{
   while (len) {
      *dest++ = *src++;
      len -= sizeof(ORUInt);
   }
}

@implementation NSCont {
@private
#if defined(__x86_64__)
   struct Ctx64   _target __attribute__ ((aligned(16)));
#else
   jmp_buf _target;
#endif
   size_t _length;
   void* _start;
   char* _data;
   int _used;
   ORInt field;  // a stored property
   ORBool admin; // a stored property
   id  fieldId;
   ORInt _cnt;   
}
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
//<<<<<<< HEAD:Clo/ORFoundation/cont.m
//=======
//
//>>>>>>> master:Clo/ORUtilities/cont.m
-(void)callInvisible
{
#if defined(__x86_64__)
   register struct Ctx64* ctx = &_target;
   self->_used--;
   ctx->rax = (long)self;
   restoreCtx(ctx,_start,_data,_length);
#else
   _longjmp(_target,(long)self); // dot not save signal mask --> overhead
#endif
}
//<<<<<<< HEAD:Clo/ORFoundation/cont.m
//=======
//
//>>>>>>> master:Clo/ORUtilities/cont.m
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

#if TARGET_OS_IPHONE==1
static __declspec(thread) ContPool* _thePool = 0;
#else
static __thread ContPool* _thePool = 0;
#endif

void contCleanup()
{
  [NSCont shutdown];
}

inline static ContPool* instancePool()
{
   if (!_thePool) {
      _thePool = malloc(sizeof(ContPool));
      _thePool->low = _thePool->high = _thePool->nbCont = 0;
      _thePool->poolClass = [NSCont self];
      _thePool->sz = 1000;
      _thePool->pool = malloc(sizeof(id)*_thePool->sz);
#if defined(__APPLE__)
      atexit_b(^{
         [NSCont shutdown];
      });
#else
      atexit(contCleanup);
#endif
   }
   return _thePool;
}

inline static void freePool()
{
   _thePool = NULL;
}

+(void)shutdown
{
   ContPool* pool = _thePool;
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
      ORUInt nbCont = pool->nbCont;
      pool->low = pool->high = 0;
      free(pool->pool);
      free(pool);
      freePool(pool);
      NSLog(@"released %d continuations out of %d...",nb,nbCont);
   }
}

+(id)new 
{
   ContPool* pool = instancePool();
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
      posix_memalign(&ptr,16,sz);
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
   rv->_cnt    = 1;
   rv->admin   = NO;
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
   letgo(self);
}

void letgo(NSCont* c)
{
   assert(c->_cnt > 0);
   if (--c->_cnt == 0) {
      ContPool* pool = instancePool();
      ORUInt next = (pool->high + 1) % pool->sz;
      if (next == pool->low) {
         free(c->_data);
         pool->nbCont -= 1;
#if defined(__APPLE__) || !defined(__x86_64__)
         NSDeallocateObject(c);
#else
         char* ptr = (char*)c;
         ptr = ptr - 16;
         free(ptr);
#endif
         return;
      }
      pool->pool[pool->high] = c;
      pool->high = next;
   }
}


@synthesize field;
@synthesize admin;
@synthesize fieldId;

@end
