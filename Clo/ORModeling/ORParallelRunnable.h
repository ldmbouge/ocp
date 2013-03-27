//
//  ORParallelRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORRunnable.h"

@protocol ORParallelRunnable<ORUpperBoundedRunnable>
-(id<ORRunnable>) primaryRunnable;
-(id<ORRunnable>) secondaryRunnable;
@end

@interface ORParallelRunnableI : ORUpperBoundedRunnableI
-(id) initWithPrimary: (id<ORRunnable>)r0 secondary: (id<ORRunnable>)r1;
-(void) run;
-(id<ORModel>) model;
-(id<ORRunnable>) primaryRunnable;
-(id<ORRunnable>) secondaryRunnable;
@end

@interface ORParallelRunnableTransform : NSObject<ORRunnableBinaryTransform>
-(id<ORRunnable>) apply:(id<ORRunnable>)r0 and:(id<ORRunnable>)r1;
@end

@interface ORFactory(ORParallelRunnable)
+(id<ORParallelRunnable>) parallelRunnable: (id<ORRunnable>)r0 with: (id<ORRunnable>)r1;
@end
