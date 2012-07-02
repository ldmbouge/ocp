/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPConcurrency.h"
#import "CPData.h"

@interface CPBarrierI : NSObject<CPBarrier> {
    CPInt _nb;
    CPInt _count;
    NSCondition* _condition; 
}
-(id<CPBarrier>) initCPBarrierI: (CPInt) nb;
-(void) join;
-(void) wait;
@end

@class CPEventQueue;

@interface CPEventList : NSObject {
   CPEventQueue* _queue;
}
-(CPEventList*) initCPEventList;
-(void) addEvent: (id) closure;
-(void) dealloc;
-(void) execute;
@end

@interface CPThread : NSThread {
    CPInt _value;
    CPBarrierI* _barrier;
    CPInt2Void _closure;
}
-(CPThread*) initCPThread: (CPInt) v barrier: (CPBarrierI*) barrier closure: (CPInt2Void) closure;
-(void) main;
@end

@interface CPInformerI : NSObject<CPVoidInformer,CPIntInformer,CPIdxIntInformer> {
    NSLock* _lock;
    NSMutableArray* _whenList;
    NSMutableArray* _wheneverList;
    NSMutableArray* _sleeperList;
}
-(CPInformerI*) initCPInformerI;
-(void) whenNotifiedDo: (id) closure;
-(void) wheneverNotifiedDo: (id) closure;
-(void) sleepUntilNotified;
-(void) notify;
-(void) notifyWith:(int)a0;
-(void) notifyWith:(id)a0 andInt:(CPInt)v;
@end


@interface CPConcurrency (Internals)
+(CPEventList*) eventList;
@end

@interface CPInterruptI : NSObject 
-(CPInterruptI*) initCPInterruptI;
@end

