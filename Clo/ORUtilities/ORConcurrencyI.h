/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORUtilities/ORConcurrency.h"
#import "ORUtilities/ORTypes.h"

@interface ORBarrierI : NSObject<ORBarrier> {
    ORInt _nb;
    ORInt _count;
    NSCondition* _condition; 
}
-(id<ORBarrier>) initORBarrierI: (ORInt) nb;
-(void) join;
-(void) wait;
@end

@class OREventQueue;

@interface OREventList : NSObject {
   OREventQueue* _queue;
}
-(OREventList*) initOREventList;
-(void) addEvent: (id) closure;
-(void) dealloc;
-(void) execute;
@end

@interface ORThread : NSThread {
    ORInt _value;
    ORBarrierI* _barrier;
    ORInt2Void _closure;
}
-(ORThread*) initORThread: (ORInt) v barrier: (ORBarrierI*) barrier closure: (ORInt2Void) closure;
-(void) main;
@end

@interface ORInformerI : NSObject<ORVoidInformer,ORIntInformer,ORIdxIntInformer> {
    NSLock* _lock;
    NSMutableArray* _whenList;
    NSMutableArray* _wheneverList;
    NSMutableArray* _sleeperList;
}
-(ORInformerI*) initORInformerI;
-(void) whenNotifiedDo: (id) closure;
-(void) wheneverNotifiedDo: (id) closure;
-(void) sleepUntilNotified;
-(void) notify;
-(void) notifyWith:(int)a0;
-(void) notifyWith:(id)a0 andInt:(ORInt)v;
@end


@interface ORConcurrency (Internals)
+(OREventList*) eventList;
@end

