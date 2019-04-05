//
//  ORSequentialRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 12/4/16.
//
//

#import <Foundation/Foundation.h>
#import <ORProgram/ORRunnable.h>
#import <ORProgram/ORRunnablePiping.h>

@protocol ORSequentialRunnable<ORUpperBoundStreamProducer, ORUpperBoundStreamConsumer,
                               ORSolutionStreamProducer, ORSolutionStreamConsumer>
-(id<ORRunnable>) boundingRunnable;
-(id<ORRunnable>) primaryRunnable;
@end

@interface ORSequentialRunnableI : ORPipedRunnable<ORSequentialRunnable>

-(id) initWithPrimaryRunnable: (id<ORRunnable>)r0 boundingRunnable: (id<ORRunnable>)r1;
-(void) run;
-(id<ORModel>) model;
-(id<ORRunnable>) primaryRunnable;
-(id<ORRunnable>) boundingRunnable;
-(ORDouble) bestBound;
-(void) setTimeLimit:(ORFloat)secs;
-(id<ORSolution>) bestSolution;
@end

