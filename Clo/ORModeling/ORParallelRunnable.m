//
//  ORParallelRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import "ORParallelRunnable.h"
#import "ORModelI.h"
#import "ORConcurrencyI.h"

@interface ORParallelRunnableI(Private)
-(void) connectRunnables;
@end

@implementation ORParallelRunnableI {
    id<ORRunnable> _r0;
    id<ORRunnable> _r1;
    id<ORSolutionPool> _solutionPool;
    NSThread* _t0;
    NSThread* _t1;
}

-(id) initWithPrimary: (id<ORRunnable>)r0 secondary: (id<ORRunnable>)r1 {
    if((self = [super initWithModel: [r0 model]]) != nil) {
        _r0 = [r0 retain];
        _r1 = [r1 retain];
        _t0 = nil;
        _t1 = nil;
        _solutionPool = [[ORSolutionPoolI alloc] init];
    }
    return self;
}

-(void) dealloc {
    [_r0 release];
    [_r1 release];
    [_t0 release];
    [_t1 release];
    [_solutionPool release];
    [super dealloc];
}

-(void) connectRunnables {
    if([[_r0 signature] providesUpperBoundStream] && [[_r1 signature] acceptsUpperBoundStream])
        [((id<ORUpperBoundStreamProvider>)_r0) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)_r1];
    if([[_r1 signature] providesUpperBoundStream] && [[_r0 signature] acceptsUpperBoundStream])
        [((id<ORUpperBoundStreamProvider>)_r1) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)_r0];
    
    if([[_r0 signature] providesSolutionStream]) [(id<ORSolutionStreamProvider>)_r0 addSolutionStreamConsumer: self];
    if([[_r1 signature] providesSolutionStream]) [(id<ORSolutionStreamProvider>)_r1 addSolutionStreamConsumer: self];
}

-(void) run {    
    [self connectRunnables];
    
    /*
    [[_solutionPool solutionAdded] wheneverNotifiedDo: ^(id<ORSolution>s) {
        for(id<ORUpperBoundStreamConsumer> c in _upperBoundStreamConsumers) {
            [[c upperBoundStreamInformer] notifyWith: (ORInt)[[s objectiveValue] key]];
        }
    }];
    */
    
    [_solutionStreamInformer wheneverNotifiedDo: ^(id<ORSolution>s) {
        [_solutionPool addSolution: s];
    }];
    
    [_r0 onExit: ^() { [(CPRunnableI*)_r0 restore: [_solutionPool best]]; }];
    [_r1 onExit: ^() { [(CPRunnableI*)_r1 restore: [_solutionPool best]]; }];
    
    _t0 = [[NSThread alloc] initWithTarget: _r0 selector: @selector(run) object: nil];
    [_t0 start];
    _t1 = [[NSThread alloc] initWithTarget: _r1 selector: @selector(run) object: nil];
    [_t1 start];
    
    // Wait for the runnables to finish
    while([_t0 isExecuting] || [_t1 isExecuting]) {
        //[NSThread sleepForTimeInterval: 0.25];
        [ORConcurrency pumpEvents];
    }
}

-(id<ORRunnable>) primaryRunnable { return _r0; }
-(id<ORRunnable>) secondaryRunnable { return _r1; }

@end

@implementation ORParallelRunnableTransform
-(id<ORRunnable>) apply:(id<ORRunnable>)r0 and:(id<ORRunnable>)r1 {
    return [[[ORParallelRunnableI alloc] initWithPrimary: r0 secondary: r1] autorelease];
}
@end

@implementation ORFactory(ORParallelRunnable)
+(id<ORParallelRunnable>) parallelRunnable: (id<ORRunnable>)r0 with: (id<ORRunnable>)r1 {
    ORParallelRunnableTransform* t = [[ORParallelRunnableTransform alloc] init];
    id<ORParallelRunnable> par = (id<ORParallelRunnable>)[t apply: r0 and: r1];
    [t release];
    return par;
}
@end
