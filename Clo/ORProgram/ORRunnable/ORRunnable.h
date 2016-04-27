//
//  ORRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORProgram/ORProgram.h>
#import <ORProgram/ORSignature.h>
#import <ORProgram/ORParallelCombinator.h>

//Forward Declarations
@protocol ORModel;
@protocol ORRunnable<NSObject>
-(id<ORModel>) model;
-(id<ORSignature>) signature;
-(id<ORASolver>) solver;
-(void) start;
-(void) run;
-(void) setTimeLimit: (ORDouble) secs;
-(ORDouble) bestBound;
-(id<ORSolution>) bestSolution;
-(void)cancelSearch;
@end

@interface ORAbstractRunnableI : NSObject<ORRunnable> {
@protected
    id<ORModel> _model;
    ORClosure _exitBlock;
    ORClosure _startBlock;
}
@property(readwrite, retain) NSArray* siblings;
-(id) initWithModel: (id<ORModel>)m;
-(void) performOnStart: (ORClosure)c;
-(void) performOnExit: (ORClosure)c;
-(id<ORASolver>) solver;
-(void) setTimeLimit: (ORDouble) secs;
@end

@interface ORFactory(ORRunnable)
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m numThreads: (ORInt)nth;
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m solve: (void(^)(id<CPCommonProgram>))body;
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m numThreads: (ORInt)nth solve: (void(^)(id<CPCommonProgram>))body;
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m withRelaxation:(id<ORRelaxation>)relax solve: (void(^)(id<CPCommonProgram>))body;
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m
              withRelaxation: (id<ORRelaxation>)relax
                  controller: (id<ORSearchController>)proto
                       solve: (void(^)(id<CPCommonProgram>))body;
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m
              withRelaxation: (id<ORRelaxation>)relax
                  numThreads: (ORInt)nth
                       solve: (void(^)(id<CPCommonProgram>))body;
+(id<ORRunnable>) LPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) MIPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) MIPRunnable: (id<ORModel>)m numThreads: (ORInt)nth;
@end
