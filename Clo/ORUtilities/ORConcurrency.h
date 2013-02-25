/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORUtilities/ORTypes.h"
#import "ORSolution.h"

@protocol ORInformer<NSObject>
-(void) whenNotifiedDo: (id) closure;
-(void) wheneverNotifiedDo: (id) closure;
-(void) sleepUntilNotified;
@end

@protocol ORVoidInformer<ORInformer>
-(void) notify;
@end

@protocol ORIntInformer<ORInformer>
-(void) notifyWith:(int)a0;
@end

@protocol ORIdxIntInformer<ORInformer>
-(void) notifyWith:(id)a0 andInt:(ORInt)v;
@end

@protocol ORSolutionInformer<ORInformer>
-(void) notifyWithSolution: (id<ORSolution>)s;
@end

@protocol ORBarrier<NSObject> 
-(void) join;
-(void) wait;
@end

@interface ORInterruptI : NSObject
-(ORInterruptI*) initORInterruptI;
@end

@interface ORConcurrency : NSObject 
+(void) parall: (ORRange) R do: (ORInt2Void) closure;
+(id<ORIntInformer>) intInformer;
+(id<ORVoidInformer>) voidInformer;
+(id<ORIdxIntInformer>) idxIntInformer;
+(id<ORBarrier>)  barrier: (ORInt) nb;
+(void) pumpEvents;
@end

@interface NSThread (ORData)
+(void) setThreadID:(ORInt)tid;
+(ORInt) threadID;
@end
