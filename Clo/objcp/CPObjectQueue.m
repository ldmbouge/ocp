/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <objcp/CPObjectQueue.h>

#if defined(__APPLE__)
//#include <libkern/OSAtomic.h>
#include <os/lock.h>
#endif

#define SPINLOCK 1

@implementation CPObjectQueue  {
   @package
   ORInt      _mxs;
   id*        _tab;
   ORInt    _enter;
   ORInt     _exit;
   ORInt     _mask;
}
-(id) initEvtQueue: (ORInt) sz {   
   self = [super init];
   _mxs = sz;
   _mask = _mxs - 1;
   _tab = malloc(sizeof(id)*_mxs);
   _enter = _exit = 0;
   return self;
}
-(void) dealloc
{
   free(_tab);
   [super dealloc];
}
-(void) reset
{
   @synchronized(self) {
      _enter = _exit = 0;
   }
}
-(ORBool)empty
{
   bool rv = false;
   @synchronized(self) {
    rv = (_enter == _exit);
   }
   return rv;
}
-(void) resize
{
   id* nt = malloc(sizeof(id)*_mxs*2);
   id* ptr = nt;
   ORInt cur = _exit;
   do {
      *ptr++ = _tab[cur];
      cur = (cur+1) & _mask;
   } 
   while (cur != _enter);
   free(_tab);
   _tab = nt;
   _exit = 0;
   _enter = _mxs-1;
   _mxs <<= 1;
   _mask = _mxs - 1;
}
-(void)enQueue:(id)obj
{
   @synchronized(self) {
      ORInt nb = (_mxs + _enter - _exit)  & _mask;
      if (nb == _mxs-1) 
         [self resize];   
      _tab[_enter] = [obj retain];
      _enter = (_enter+1) & _mask;
   }
}
-(id)deQueue
{
   @synchronized(self) {
      if (_enter != _exit) {
         id rv = _tab[_exit];
         _exit = (_exit+1) & _mask;
         [rv release];
         return rv;
      } 
      else 
         return nil;
   }
}   
@end

@implementation PCObjectQueue {
   ORInt           _mxs;
   id*             _tab;
   ORInt         _enter;
   ORInt          _exit;
   ORInt          _mask;
   ORInt        _nbUsed;
   ORInt     _nbWorkers;
   ORInt    _nbWWaiting;
   NSCondition*  _avail;
#if defined(__APPLE__)
   os_unfair_lock    _slock;
#endif
   BOOL _pretend;
}
-(id) initPCQueue: (ORInt) sz nbWorkers:(ORInt)nbw
{   
   self = [super init];
   _mxs = sz;
   _mask = _mxs - 1;
   _tab = malloc(sizeof(id)*_mxs);
   _enter = _exit = 0;
   _nbUsed = 0;
   _nbWorkers = nbw;
   _nbWWaiting = 0;
   _avail = [[NSCondition alloc] init];
#if defined(__APPLE__) && defined(SPINLOCK)
   _slock = (os_unfair_lock){0};
#endif
   _pretend = NO;
   return self;
}
-(void) dealloc
{
   //NSLog(@"PCObjectQueue deallocated: %ld (%ld:%ld)",_nbUsed,_enter,_exit);
   free(_tab);
   [_avail dealloc];
   [super dealloc];
}
-(void) pretendFull:(BOOL)isFull
{
   _pretend = _pretend || isFull;
}
-(void) reset
{
   [_avail lock];
   _enter = _exit = 0;
   [_avail unlock];
}
-(ORBool)empty
{
   bool rv;
#if defined(__APPLE__) && defined(SPINLOCK)
   os_unfair_lock_lock(&_slock);
#else
   @synchronized(self) {
#endif
      rv = (_nbUsed == 0) && !_pretend;
#if !(defined(__APPLE__) && defined(SPINLOCK))
   }
#else
   os_unfair_lock_unlock(&_slock);
#endif
   return rv;
}
-(ORInt)size
{
   ORInt rv = 0;
#if defined(__APPLE__) && defined(SPINLOCK)
   os_unfair_lock_lock(&_slock);
#else
   @synchronized(self) {
#endif
      rv = _nbUsed;
#if !(defined(__APPLE__) && defined(SPINLOCK))
   }
#else
   os_unfair_lock_unlock(&_slock);
#endif
   return rv;
}
-(void) resize
{
   id* nt = calloc(_mxs*2,sizeof(id));
   id* ptr = nt;
   ORInt cur = _exit;
   do {
      *ptr++ = _tab[cur];
      cur = (cur+1) & _mask;
   } 
   while (cur != _enter);
   free(_tab);
   _tab = nt;
   _exit = 0;
   _enter = _mxs;
   _mxs <<= 1;
   _mask = _mxs - 1;
}
-(void)safeEnQueue:(id)obj
{
   //NSLog(@"ENQUEUE: %16p by %16p",obj,[NSThread currentThread]);
   bool full;
#if defined(__APPLE__) && defined(SPINLOCK)
   os_unfair_lock_lock(&_slock);
#else
   @synchronized(self) {
#endif
      full = _mxs == _nbUsed;
#if !(defined(__APPLE__) && defined(SPINLOCK))
   }
#else
   os_unfair_lock_unlock(&_slock);
#endif
   if (full) 
      [self resize];   
   _tab[_enter] = [obj retain];
   _enter = (_enter+1) & _mask;
#if defined(__APPLE__) && defined(SPINLOCK)
   os_unfair_lock_lock(&_slock);
#else
   @synchronized(self) {
#endif
      _nbUsed++;   
#if !(defined(__APPLE__) && defined(SPINLOCK))
   }
#else
   os_unfair_lock_unlock(&_slock);
#endif
   [_avail signal];
}
-(void)enQueue:(id)obj
{   
   [_avail lock];
   [self safeEnQueue:obj];
   [_avail unlock];
}
-(id)deQueue
{
   [_avail lock];
   bool loop;
#if defined(__APPLE__) && defined(SPINLOCK)
   os_unfair_lock_lock(&_slock);
#else
   @synchronized(self) {
#endif
      loop = _nbUsed == 0;
#if !(defined(__APPLE__) && defined(SPINLOCK))
   }
#else
   os_unfair_lock_unlock(&_slock);
#endif
   while (loop) {
      _nbWWaiting++;
      if (_nbWWaiting == _nbWorkers) {
         for(ORInt k=0;k < _nbWorkers;k++) 
            [self safeEnQueue:nil];
      } else       
         [_avail wait];
      _nbWWaiting--;
#if defined(__APPLE__) && defined(SPINLOCK)
      os_unfair_lock_lock(&_slock);
#else
      @synchronized(self) {
#endif
         loop = _nbUsed == 0;
#if !(defined(__APPLE__) && defined(SPINLOCK))
      }
#else
      os_unfair_lock_unlock(&_slock);
#endif
   }
   assert(_enter != _exit);
   id rv = _tab[_exit];
   _exit = (_exit+1) & _mask;
#if defined(__APPLE__) && defined(SPINLOCK)
   os_unfair_lock_lock(&_slock);
#else
   @synchronized(self) {
#endif
      _nbUsed--;
#if !(defined(__APPLE__) && defined(SPINLOCK))
   }
#else
   os_unfair_lock_unlock(&_slock);
#endif
   [rv release];
   //NSLog(@"DEQUEUE: %16p by %16p",rv,[NSThread currentThread]);
   [_avail unlock];
   return rv;
}   
@end
