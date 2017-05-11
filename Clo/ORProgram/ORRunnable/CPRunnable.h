//
//  CPRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import <Foundation/Foundation.h>
#import <ORProgram/ORRunnablePiping.h>
#import <ORProgram/CPProgram.h>

@protocol CPRunnable <ORUpperBoundStreamConsumer, ORUpperBoundStreamProducer,
                      ORLowerBoundStreamConsumer, ORSolutionStreamConsumer,
                      ORSolutionStreamProducer, ORRunnable>
-(id<CPProgram>) solver;
@end

@interface CPRunnableI : ORPipedRunnable<CPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id) initWithModel: (id<ORModel>)m search: (void(^)(id<CPCommonProgram>))search;
-(id) initWithModel: (id<ORModel>)m willSearch: (CPRunnableSearch(^)(id<CPCommonProgram>))willSearch;
-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt) nt;
-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt) nt search: (void(^)(id<CPCommonProgram>))search;
-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt) nt willSearch: (CPRunnableSearch(^)(id<CPCommonProgram>))willSearch;
-(id) initWithModel: (id<ORModel>)m
     withRelaxation:(id<ORRelaxation>)relax
             search: (void(^)(id<CPCommonProgram>))search;
-(id) initWithModel: (id<ORModel>)m
     withRelaxation:(id<ORRelaxation>)relax
             search: (void(^)(id<CPCommonProgram>))search
         controller: (id<ORSearchController>)proto;
-(id) initWithModel: (id<ORModel>)m
     withRelaxation:(id<ORRelaxation>)relax
         numThreads: (ORInt) nth
             search: (void(^)(id<CPCommonProgram>))search;
@end

