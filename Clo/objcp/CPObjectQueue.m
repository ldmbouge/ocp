/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/


#import "objcp/CPObjectQueue.h"

@implementation CPObjectQueue 
-(id) initEvtQueue: (CPInt) sz {   
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
-(bool)empty
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
   CPInt cur = _exit;
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
      CPInt nb = (_mxs + _enter - _exit)  & _mask;
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

@implementation PCObjectQueue 
-(id) initPCQueue: (CPInt) sz nbWorkers:(CPInt)nbw
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
   return self;
}
-(void) dealloc
{
   //NSLog(@"PCObjectQueue deallocated: %ld (%ld:%ld)",_nbUsed,_enter,_exit);
   free(_tab);
   [_avail dealloc];
   [super dealloc];
}
-(void) reset
{
   [_avail lock];
   _enter = _exit = 0;
   [_avail unlock];
}
-(bool)empty
{
   bool rv;
   @synchronized(self) {
      rv = (_nbUsed == 0);
   }
   return rv;
}
-(void) resize
{
   id* nt = malloc(sizeof(id)*_mxs*2);
   id* ptr = nt;
   CPInt cur = _exit;
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
-(void)safeEnQueue:(id)obj
{
   bool full;
   @synchronized(self) {
      full = _mxs == _nbUsed;
   }
   if (full) 
      [self resize];   
   _tab[_enter] = [obj retain];
   _enter = (_enter+1) & _mask;
   @synchronized(self) {
      _nbUsed++;   
   }
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
   @synchronized(self) {
      loop = _nbUsed == 0;
   }
   while (loop) {
      _nbWWaiting++;
      if (_nbWWaiting == _nbWorkers) {
         for(CPInt k=0;k < _nbWorkers;k++) 
            [self safeEnQueue:nil];
      } else       
         [_avail wait];
      _nbWWaiting--;
      @synchronized(self) {
         loop = _nbUsed == 0;
      }
   }
   assert(_enter != _exit);
   id rv = _tab[_exit];
   _exit = (_exit+1) & _mask;
   @synchronized(self) {
      _nbUsed--;
   }
   [rv release];
   //NSLog(@"DEQUEUE: %16p by %16p",rv,[NSThread currentThread]);
   [_avail unlock];
   return rv;
}   
@end
