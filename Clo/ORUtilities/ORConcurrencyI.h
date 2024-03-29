/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORConcurrency.h>
#import <ORUtilities/ORTypes.h>

@interface ORBarrier : NSObject<ORBarrier> {
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
    ORBarrier* _barrier;
    ORInt2Void _closure;
}
-(ORThread*) initORThread: (ORInt) v barrier: (ORBarrier*) barrier closure: (ORInt2Void) closure;
-(void) main;
@end

@interface ORInformer : NSObject<ORVoidInformer,ORIntInformer,ORIdxIntInformer,ORDoubleInformer,
    ORSolutionInformer, ORConstraintInformer, ORIntArrayInformer, ORDoubleArrayInformer, ORConstraintSetInformer> {
    NSLock* _lock;
    NSMutableArray* _whenList;
    NSMutableArray* _wheneverList;
    NSMutableArray* _sleeperList;
}
-(ORInformer*) initORInformer;
-(void) whenNotifiedDo: (id) closure;
-(void) sleepUntilNotified;
-(void) notify;
-(void) notifyWith:(int)a0;
-(void) notifyWithFloat:(double)a0;
-(void) notifyWith:(id)a0 andInt:(ORInt)v;
-(void) notifyWithSolution:(id<ORSolution>)s;
@end


@interface ORConcurrency (Internals)
+(OREventList*) eventList;
@end

