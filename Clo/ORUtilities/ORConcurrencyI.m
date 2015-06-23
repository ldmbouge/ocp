/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/NSThread.h>
#import <ORUtilities/ORConcurrency.h>
#import <ORUtilities/ORCrFactory.h>

#import "ORConcurrencyI.h"
#import "pthread.h"

@interface OREventQueue : NSObject {
   @package
   ORInt      _mxs;
   id*            _tab;
   ORInt    _enter;
   ORInt     _exit;
   ORInt     _mask;
}
-(id)initOREventQueue:(ORInt)sz;
-(void)dealloc;
-(id)deQueue;
-(void)enQueue:(id)cb;
-(void)reset;
@end

@implementation OREventQueue 
-(id) initOREventQueue: (ORInt) sz
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
inline static void EvtenQueue(OREventQueue* q,id cb)
{
   ORInt nb = (q->_mxs + q->_enter - q->_exit)  & q->_mask;
   if (nb == q->_mxs-1) 
      [q resize];   
   q->_tab[q->_enter] = [cb retain];  // will be released once executed.
   q->_enter = (q->_enter+1) & q->_mask;
}
inline static id EvtdeQueue(OREventQueue* q)
{
   if (q->_enter != q->_exit) {
      id cb = q->_tab[q->_exit];
      q->_exit = (q->_exit+1) & q->_mask;
      [cb release];
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

@protocol ORExecuteEventI<NSObject>
-(void) execute;
@end

typedef void (^ORIdxInt2Void)(id,ORInt);

@interface ORExecuteClosureEventI : NSObject<ORExecuteEventI> {
   ORClosure _closure;
}
-(id<ORExecuteEventI>) initORExecuteClosureEventI: (ORClosure) closure;
-(void) dealloc;
@end

@implementation ORInterruptI 
-(ORInterruptI*) initORInterruptI
{
    self = [super init];
    return self;
}
@end

@implementation ORExecuteClosureEventI
-(id<ORExecuteEventI>) initORExecuteClosureEventI: (ORClosure) closure
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

@implementation OREventList
-(OREventList*) initOREventList 
{
    self = [super init];
   _queue = [[OREventQueue alloc] initOREventQueue:32];
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
      ORClosure cl = nil;
      while ((cl = EvtdeQueue(_queue)) != (ORClosure)nil) {
         cl();
         Block_release(cl);      
      }
   }
}
@end

@interface ORInformerEventI : NSObject {
   OREventList* _eventList;
   ORClosure _closure;
}
-(ORInformerEventI*) initORInformerEventI: (OREventList*) eventList closure: (ORClosure) closure;
-(void) dispatch;
@end

@implementation ORInformerEventI
-(ORInformerEventI*) initORInformerEventI: (OREventList*) eventList closure: (ORClosure) closure
{
    self = [super init];
    _eventList = [eventList retain];
    _closure = [closure copy];
    return self;
}
-(void)dealloc
{
   Block_release(_closure);
   [_eventList release];
   [super dealloc];
}
-(void) dispatch
{
   [_eventList addEvent:[_closure retain]];
}
-(void) dispatchWith:(int)a0
{
   ORInt2Void tClo = (ORInt2Void)_closure;
   ORClosure wrap = ^{
      tClo(a0);
   };
   [_eventList addEvent:[wrap copy]];
}
-(void) dispatchWith:(id)a0 andInt:(ORInt)a1
{
   ORIdxInt2Void tClo = (ORIdxInt2Void)_closure;
   ORClosure wrap = ^{
      tClo(a0,a1);
   };
   [_eventList addEvent:[wrap copy]];
}
-(void) dispatchWithObject:(id)obj
{
   ORId2Void tClo = (ORId2Void)_closure;
   ORClosure wrap = ^{
      tClo(obj);
   };
   [_eventList addEvent:[wrap copy]];
}
-(void) dispatchWithSolution:(id<ORSolution>)s
{
    ORSolution2Void tClo = (ORSolution2Void)_closure;
    ORClosure wrap = ^{
        tClo(s);
    };
    [_eventList addEvent:[wrap copy]];
}
-(void) dispatchWithConstraint:(id<ORConstraint>)s
{
    ORConstraint2Void tClo = (ORConstraint2Void)_closure;
    ORClosure wrap = ^{
        tClo(s);
    };
    [_eventList addEvent:[wrap copy]];
}
-(void) dispatchWithIntArray:(id<ORIntArray>)arr
{
    ORIntArray2Void tClo = (ORIntArray2Void)_closure;
    ORClosure wrap = ^{
        tClo(arr);
    };
    [_eventList addEvent:[wrap copy]];
}
-(void) dispatchWithFloatArray:(id<ORFloatArray>)arr
{
    ORFloatArray2Void tClo = (ORFloatArray2Void)_closure;
    ORClosure wrap = ^{
        tClo(arr);
    };
    [_eventList addEvent:[wrap copy]];
}
-(void) dispatchWithConstraintSet:(id<ORConstraintSet>)set
{
    ORConstraintSet2Void tClo = (ORConstraintSet2Void)_closure;
    ORClosure wrap = ^{
        tClo(set);
    };
    [_eventList addEvent:[wrap copy]];
}
@end

@implementation ORInformer
-(ORInformer*) initORInformer
{
   self = [super init];
   _lock = [[NSLock alloc] init];
   _whenList = [[NSMutableArray alloc] init];
   _wheneverList = [[NSMutableArray alloc] init];
   _sleeperList = [[NSMutableArray alloc] init];
   return self;
}
-(void) dealloc
{
   NSLog(@"informer release %p",self);
   @synchronized(self) {
      for(ORBarrier* barrier in _sleeperList)
         [barrier join];
      [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
   }
   [_whenList release];     // [ldm] this deallocates the whenList and sends release messages to all objects embedded in it. No need to deallocate
   [_wheneverList release]; // [ldm] this deallocates the wheneverList ands sends release messages to all objects embedded inside.
   [_sleeperList release];
   [_lock release];
   [super dealloc];
}

-(void) whenNotifiedDo: (id) closure
{
   ORInformerEventI* event = [[ORInformerEventI alloc] initORInformerEventI: [ORConcurrency eventList] closure: closure];
   @synchronized(self) {
      [_whenList addObject: event];
      [event release];  // event is now owned by the whenList.
   }
}

-(void) wheneverNotifiedDo: (id) closure
{
   ORInformerEventI* event = [[ORInformerEventI alloc] initORInformerEventI: [ORConcurrency eventList] closure: closure];
   @synchronized(self) {
      [_wheneverList addObject: event];
      [event release];  // even is now owned (exclusively) by the wheneverList
   }
}

-(void) sleepUntilNotified
{
   ORBarrier* barrier = [ORConcurrency barrier: 1];
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
      for(ORBarrier* barrier in _sleeperList)
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
      for(ORBarrier* barrier in _sleeperList)
         [barrier join]; 
      [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
   }
}

-(void) notifyWithObject:(id)a0
{
   @synchronized(self) {
      for(id event in _whenList)
         [event dispatchWithObject:a0];
      [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
      for(id event in _wheneverList)
         [event dispatchWithObject:a0];
      for(ORBarrier* barrier in _sleeperList)
         [barrier join];
      [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
   }
}

-(void) notifyWith:(id)a0 andInt:(ORInt)a1
{
   @synchronized(self) {
      for(id event in _whenList) 
         [event dispatchWith:a0 andInt:a1];    
      [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
      for(id event in _wheneverList) 
         [event dispatchWith:a0 andInt:a1];    
      for(ORBarrier* barrier in _sleeperList)
         [barrier join]; 
      [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
   }
}

-(void) notifyWithSolution:(id<ORSolution>)s
{
    @synchronized(self) {
        for(id event in _whenList)
            [event dispatchWithSolution: s];
        [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
        for(id event in _wheneverList)
            [event dispatchWithSolution: s];
        for(ORBarrier* barrier in _sleeperList)
            [barrier join];
        [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
    }
}

-(void) notifyWithConstraint:(id<ORConstraint>)c
{
    @synchronized(self) {
        for(id event in _whenList)
            [event dispatchWithConstraint: c];
        [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
        for(id event in _wheneverList)
            [event dispatchWithConstraint: c];
        for(ORBarrier* barrier in _sleeperList)
            [barrier join];
        [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
    }
}

-(void) notifyWithIntArray:(id<ORIntArray>)arr
{
    @synchronized(self) {
        for(id event in _whenList)
            [event dispatchWithIntArray: arr];
        [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
        for(id event in _wheneverList)
            [event dispatchWithIntArray: arr];
        for(ORBarrier* barrier in _sleeperList)
            [barrier join];
        [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
    }
}

-(void) notifyWithFloatArray:(id<ORFloatArray>)arr
{
    @synchronized(self) {
        for(id event in _whenList)
            [event dispatchWithFloatArray: arr];
        [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
        for(id event in _wheneverList)
            [event dispatchWithFloatArray: arr];
        for(ORBarrier* barrier in _sleeperList)
            [barrier join];
        [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
    }
}

-(void) notifyWithConstraintSet:(id<ORConstraintSet>)s
{
    @synchronized(self) {
        for(id event in _whenList)
            [event dispatchWithConstraintSet: s];
        [_whenList removeAllObjects];  // [ldm] this *automatically* sends a release to all the objects. No need to release before!
        for(id event in _wheneverList)
            [event dispatchWithConstraintSet: s];
        for(ORBarrier* barrier in _sleeperList)
            [barrier join];
        [_sleeperList removeAllObjects]; // [ldm] this *automatically* sends a release to all the objects in the sleeperList.
    }
}

@end

@implementation ORConcurrency
+(void) parall: (ORRange) R do: (ORInt2Void) closure
{
    ORInt low = R.low;
    ORInt up = R.up;
    ORInt size = up - low + 1;
    ORBarrier* barrier = [[ORBarrier alloc] initORBarrierI: size];
    for(ORInt i = low; i <= up; i++) {
        ORThread* t = [[ORThread alloc] initORThread: i barrier: barrier closure: closure];
        [t start];
    }
    [barrier wait];
    [barrier release];
}
+(id<ORIntInformer>) intInformer
{
    return [[ORInformer alloc] initORInformer];
}
+(id<ORSolutionInformer>) solutionInformer
{
   return [[ORInformer alloc] initORInformer];
}
+(id<ORInformer>) idInformer
{
   return [[ORInformer alloc] initORInformer];
}
+(id<ORVoidInformer>) voidInformer
{
   return [[ORInformer alloc] initORInformer];
}
+(id<ORIdxIntInformer>) idxIntInformer
{
   return [[ORInformer alloc] initORInformer];
}
+(id<ORBarrier>)  barrier: (ORInt) nb
{
    return [[ORBarrier alloc] initORBarrierI: nb];
}
+(void) pumpEvents
{
    OREventList* list = [ORConcurrency eventList];
    [list execute];
}
@end


@implementation ORBarrier
-(id) initORBarrierI: (ORInt) nb
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


@implementation ORThread 
-(ORThread*) initORThread: (ORInt) v barrier: (ORBarrier*) barrier closure: (ORInt2Void) closure
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
   [[ORConcurrency eventList] release];
   [_barrier release];
   [_closure release];
}
@end

@implementation ORConcurrency (Internals)

+(OREventList*) eventList  // Returns *the* event list in TLS (for the invoking thread)
{
   static __thread OREventList* eventlist = NULL;
   if (!eventlist)
      eventlist = [[OREventList alloc] initOREventList];
   return eventlist;
}
@end

@implementation NSThread (ORData)

static ORInt __thread tidTLS = 0;

+(void)setThreadID:(ORInt)tid
{
   tidTLS = tid;
}
+(ORInt)threadID
{
   return tidTLS;
}
@end
