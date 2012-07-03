/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPData.h"
#import "CPCrFactory.h"
#import "CPError.h"
#import "CPConcurrency.h"
#import "CPConcurrencyI.h"
#import "pthread.h"
#import <Foundation/NSThread.h>


@interface CPEventQueue : NSObject {
   @package
   CPInt      _mxs;
   id*            _tab;
   CPInt    _enter;
   CPInt     _exit;
   CPInt     _mask;
}
-(id)initCPEventQueue:(CPInt)sz;
-(void)dealloc;
-(id)deQueue;
-(void)enQueue:(id)cb;
-(void)reset;
@end

@implementation CPEventQueue 
-(id) initCPEventQueue: (CPInt) sz
{
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
   _enter = _exit = 0;
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
inline static void EvtenQueue(CPEventQueue* q,id cb)
{
   CPInt nb = (q->_mxs + q->_enter - q->_exit)  & q->_mask;
   if (nb == q->_mxs-1) 
      [q resize];   
   q->_tab[q->_enter] = [cb retain];  // will be released once executed.
   q->_enter = (q->_enter+1) & q->_mask;
}
inline static id EvtdeQueue(CPEventQueue* q)
{
   if (q->_enter != q->_exit) {
      id cb = q->_tab[q->_exit];
      q->_exit = (q->_exit+1) & q->_mask;
      return cb;
   } 
   else 
      return nil;   
}
-(void)enQueue:(id)cb
{
   EvtenQueue(self, cb);
}
-(id)deQueue
{
   return EvtdeQueue(self);
}
@end


@protocol CPExecuteEventI<NSObject>
-(void) execute;
@end

typedef void (^CPIdxInt2Void)(id,CPInt);

@interface CPExecuteClosureEventI : NSObject<CPExecuteEventI> {
   CPClosure _closure;
}
-(id<CPExecuteEventI>) initCPExecuteClosureEventI: (CPClosure) closure;
-(void) dealloc;
@end

@implementation CPInterruptI 
-(CPInterruptI*) initCPInterruptI
{
    self = [super init];
    return self;
}
@end

@implementation CPExecuteClosureEventI
-(id<CPExecuteEventI>) initCPExecuteClosureEventI: (CPClosure) closure
{
    self = [super init];
    _closure = [closure retain];
    return self;
}
-(void) execute
{
    _closure();
}
-(void) dealloc
{
    [_closure release];
    [super dealloc];
}
@end

@implementation CPEventList
-(CPEventList*) initCPEventList 
{
    self = [super init];
   _queue = [[CPEventQueue alloc] initCPEventQueue:32];
    return self;
}
-(void) dealloc
{
   NSLog(@"Event List dealloc %p",self);
   id cl = nil;
   while ((cl = EvtdeQueue(_queue)) != nil)
      [cl release];
   [_queue release];
   [super dealloc];
}
-(void) addEvent: (id) closure
{
   @synchronized(self) {
      EvtenQueue(_queue, closure);
   }
}
-(void) execute
{
   @synchronized(self) {
      CPClosure cl = nil;
      while ((cl = EvtdeQueue(_queue)) != nil) {
         cl();
         [cl release];
      }
   }
}
@end

@interface CPInformerEventI : NSObject {
   CPEventList* _eventList;
   CPClosure _closure;
}
-(CPInformerEventI*) initCPInformerEventI: (CPEventList*) eventList closure: (CPClosure) closure;
-(void) dispatch;
@end

@implementation CPInformerEventI
-(CPInformerEventI*) initCPInformerEventI: (CPEventList*) eventList closure: (CPClosure) closure
{
    self = [super init];
    _eventList = [eventList retain];
    _closure = [closure copy];
    return self;
}
-(void)dealloc
{
   [_closure release];
   [_eventList release];
   [super dealloc];
}
-(void) dispatch
{
   [_eventList addEvent:_closure];
}
-(void) dispatchWith:(int)a0
{
   CPInt2Void tClo = (CPInt2Void)_closure;
   CPClosure wrap = ^{
      tClo(a0);
   };
   [_eventList addEvent:[wrap copy]];
}
-(void) dispatchWith:(id)a0 andInt:(CPInt)a1
{
   CPIdxInt2Void tClo = (CPIdxInt2Void)_closure;
   CPClosure wrap = ^{
      tClo(a0,a1);
   };
   [_eventList addEvent:[wrap copy]];
}
@end

@implementation CPInformerI 
-(CPInformerI*) initCPInformerI
{
   self = [super init];
   _lock = [[NSLock alloc] init];
   _whenList = [[NSMutableArray alloc] init];
   _wheneverList = [[NSMutableArray alloc] init];
   _sleeperList = [[NSMutableArray alloc] init];
   return self;
}
-(void) whenNotifiedDo: (id) closure
{
   CPInformerEventI* event = [[CPInformerEventI alloc] initCPInformerEventI: [CPConcurrency eventList] closure: closure];
   @synchronized(self) {
      [_whenList addObject: event];
      [event release];  // event is now owned by the whenList.
   }
}
-(void) wheneverNotifiedDo: (id) closure
{
   CPInformerEventI* event = [[CPInformerEventI alloc] initCPInformerEventI: [CPConcurrency eventList] closure: closure];
   @synchronized(self) {
      [_wheneverList addObject: event];
      [event release];  // even is now owned (exclusively) by the wheneverList
   }
}

-(void) sleepUntilNotified
{
   CPBarrierI* barrier = [CPConcurrency barrier: 1];
   @synchronized(self) {
      [_sleeperList addObject: barrier];
   }
   [barrier wait];
   [barrier release];
}
-(void) notify
{
   @synchronized(self) {
      for(id event in _whenList) 
         [event dispatch];    
      [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
      for(id event in _wheneverList) 
         [event dispatch];    
      for(CPBarrierI* barrier in _sleeperList)
         [barrier join]; 
      [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
   }
}
-(void) notifyWith:(int)a0
{
   @synchronized(self) {
      for(id event in _whenList) 
         [event dispatchWith:a0];    
      [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
      for(id event in _wheneverList) 
         [event dispatchWith:a0];    
      for(CPBarrierI* barrier in _sleeperList)
         [barrier join]; 
      [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
   }
}

-(void) notifyWith:(id)a0 andInt:(CPInt)a1
{
   @synchronized(self) {
      for(id event in _whenList) 
         [event dispatchWith:a0 andInt:a1];    
      [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
      for(id event in _wheneverList) 
         [event dispatchWith:a0 andInt:a1];    
      for(CPBarrierI* barrier in _sleeperList)
         [barrier join]; 
      [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
   }
}

-(void) dealloc 
{
   NSLog(@"informer release %p",self);
   @synchronized(self) {
      for(CPBarrierI* barrier in _sleeperList)
         [barrier join]; 
      [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.   
   }
   [_whenList release];     // [ldm] this deallocates the whenList and sends release messages to all objects embedded in it. No need to deallocate
   [_wheneverList release]; // [ldm] this deallocates the wheneverList ands sends release messages to all objects embedded inside. 
   [_sleeperList release];
   [super dealloc];
}
@end

static pthread_key_t eventlist;
static void init_eventlist() 
{
    pthread_key_create(&eventlist,NULL);  
}

@implementation CPConcurrency
+(void) parall: (CPRange) R do: (CPInt2Void) closure
{
    CPInt low = R.low;
    CPInt up = R.up;
    CPInt size = up - low + 1;
    CPBarrierI* barrier = [[CPBarrierI alloc] initCPBarrierI: size];
    for(CPInt i = low; i <= up; i++) {
        CPThread* t = [[CPThread alloc] initCPThread: i barrier: barrier closure: closure];
        [t start];
    }
    [barrier wait];
    [barrier release];
}
+(void) parall: (CPRange) R do: (CPInt2Void) closure untilNotifiedBy: (id<CPInformer>) informer
{
    CPInt2Void clo = [closure copy];
    id<CPInteger> done = [CPCrFactory integer: 0];
    [CPConcurrency parall: R
                       do: ^void(CPInt i) { 
                           [informer whenNotifiedDo: ^(void) { 
                               printf("Notification\n"); [done setValue: 1]; @throw [[CPInterruptI alloc] initCPInterruptI]; }];
                           if ([done value] == 0) {
                               @try {
                                   clo(i);
                               }
                               @catch (CPInterruptI* e) {
                                   [e release];
                               }
                           }
                       }
     ];
    [done release];
    [clo release];
}
+(id<CPIntInformer>) intInformer
{
    return [[CPInformerI alloc] initCPInformerI];
}
+(id<CPVoidInformer>) voidInformer
{
   return [[CPInformerI alloc] initCPInformerI];
}
+(id<CPIdxIntInformer>) idxIntInformer
{
   return [[CPInformerI alloc] initCPInformerI];
}
+(id<CPBarrier>)  barrier: (CPInt) nb
{
    return [[CPBarrierI alloc] initCPBarrierI: nb];
}
+(void) pumpEvents
{
    CPEventList* list = [CPConcurrency eventList];
    [list execute];
}
@end


@implementation CPBarrierI
-(id<CPBarrier>) initCPBarrierI: (CPInt) nb
{
   self = [super init];
   _count = 0;
   _nb = nb;
   _condition = [[NSCondition alloc] init];
   return self;
}
-(void) join 
{
   [_condition lock];
   _count++;
   if (_count == _nb)
      [_condition signal];
   [_condition unlock];
}
-(void) wait
{
   [_condition lock];
   while (_count < _nb)
      [_condition wait];
   [_condition unlock];
}
-(void) dealloc
{
   NSLog(@"Releasing the barrier \n");
   [_condition release];
   [super dealloc];
}
@end;


@implementation CPThread 
-(CPThread*) initCPThread: (CPInt) v barrier: (CPBarrierI*) barrier closure: (CPInt2Void) closure
{
   self = [super init];
   _value = v;
   _barrier = [barrier retain];
   _closure = [closure copy];
   return self;
}
-(void) main 
{
   _closure(_value);   
   [_barrier join];
   [[CPConcurrency eventList] release];
   [_barrier release];
   [_closure release];
}
@end

@implementation CPConcurrency (Internals)

+(CPEventList*) eventList  // Returns *the* event list in TLS (for the invoking thread)
{
    static pthread_once_t block = PTHREAD_ONCE_INIT;
    pthread_once(&block,init_eventlist);
    CPEventList* a = pthread_getspecific(eventlist);
    if (!a) {
        a = [[CPEventList alloc] initCPEventList];
        pthread_setspecific(eventlist,a);
    }
    return a;
}
@end
