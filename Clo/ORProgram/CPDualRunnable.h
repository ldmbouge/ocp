//
//  CPDualRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 12/7/16.
//
//

#import <Foundation/Foundation.h>
#import <ORProgram/ORRunnablePiping.h>
#import <ORProgram/CPProgram.h>

@protocol CPDualRunnable <ORUpperBoundStreamConsumer, ORLowerBoundStreamProducer,
ORLowerBoundStreamConsumer, ORSolutionStreamConsumer, ORRunnable>
-(id<CPProgram>) solver;
@end

@interface CPDualRunnableI : ORPipedRunnable<CPDualRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id) initWithModel: (id<ORModel>)m search: (void(^)(id<CPCommonProgram>))search;
-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt) nt;
-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt) nt search: (void(^)(id<CPCommonProgram>))search;
@end