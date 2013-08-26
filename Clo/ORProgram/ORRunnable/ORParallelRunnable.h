//
//  ORParallelRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORRunnable.h"
#import "ORRunnablePiping.h"

@protocol ORCompleteParallelRunnable<ORUpperBoundStreamProducer, ORUpperBoundStreamConsumer,
                                     ORSolutionStreamProducer, ORSolutionStreamConsumer,
                                     ORLowerBoundStreamConsumer>
-(id<ORRunnable>) primaryRunnable;
-(id<ORRunnable>) secondaryRunnable;
@end

@interface ORCompleteParallelRunnableI : ORPipedRunnable<ORCompleteParallelRunnable>

-(id) initWithPrimary: (id<ORRunnable>)r0 secondary: (id<ORRunnable>)r1;
-(void) run;
-(id<ORModel>) model;
-(id<ORRunnable>) primaryRunnable;
-(id<ORRunnable>) secondaryRunnable;
@end

