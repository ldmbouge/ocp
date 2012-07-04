/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>

@protocol CPInformer<NSObject>
-(void) whenNotifiedDo: (id) closure;
-(void) wheneverNotifiedDo: (id) closure;
-(void) sleepUntilNotified;
@end

@protocol CPVoidInformer<CPInformer>
-(void) notify;
@end

@protocol CPIntInformer<CPInformer>
-(void) notifyWith:(int)a0;
@end

@protocol CPIdxIntInformer<CPInformer>
-(void) notifyWith:(id)a0 andInt:(CPInt)v;
@end

@protocol CPBarrier<NSObject> 
-(void) join;
-(void) wait;
@end

@interface CPConcurrency : NSObject {
    
}
+(void) parall: (CPRange) R do: (ORInt2Void) closure;
+(void) parall: (CPRange) R do: (CPInt2Void) closure untilNotifiedBy: (id<CPInformer>) informer;
+(id<CPIntInformer>) intInformer;
+(id<CPVoidInformer>) voidInformer;
+(id<CPIdxIntInformer>) idxIntInformer;
+(id<CPBarrier>)  barrier: (CPInt) nb;
+(void) pumpEvents;
@end
