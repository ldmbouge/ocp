//
//  ORParallelRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORRunnable.h"

@protocol ORParallelRunnable<ORRunnable>
-(id<ORSignature>) signature;
-(void) run;
-(id<ORRunnable>) primaryRunnable;
-(id<ORRunnable>) secondaryRunnable;
@end

@interface ORParallelRunnableI : NSObject<ORParallelRunnable>
-(id) initWithPrimary: (id<ORRunnable>)r0 secondary: (id<ORRunnable>)r1;
-(id<ORSignature>) signature;
-(void) run;
-(id<ORRunnable>) primaryRunnable;
-(id<ORRunnable>) secondaryRunnable;
@end

@interface ORParallelRunnableTransform : NSObject<ORRunnableBinaryTransform>
-(id<ORRunnable>) apply:(id<ORRunnable>)r0 and:(id<ORRunnable>)r1;
@end