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

@implementation ORCompleteParallelRunnableI {
    id<ORRunnable> _r0;
    id<ORRunnable> _r1;
    id<ORSolutionPool> _solutionPool;
    NSThread* _t0;
    NSThread* _t1;
}

-(id) initWithPrimary: (id<ORRunnable>)r0 secondary: (id<ORRunnable>)r1 {
    if((self = [super initWithModel: [r0 model]]) != nil) {
        _r0 = r0;
        _r1 = r1;
        _t0 = nil;
        _t1 = nil;
        _solutionPool = [[ORSolutionPoolI alloc] init];
    }
    return self;
}

-(void) dealloc {
    [_t0 cancel];
    [_t1 cancel];
    [_r0 release];
    [_r1 release];
    [_t0 release];
    [_t1 release];
    [_solutionPool release];
    [super dealloc];
}

-(id<ORModel>) model {
    return [_r0 model];
}

-(void) connectPiping:(NSArray *)runnables {
    // Set siblings for internal piping
    [_r0 setSiblings: [NSArray arrayWithObject: _r1]];
    [_r1 setSiblings: [NSArray arrayWithObject: _r0]];
}

-(void) run {
    
//    [_r0 onExit: ^() { [(CPRunnableI*)_r0 restore: [_solutionPool best]]; }];
//    [_r1 onExit: ^() { [(CPRunnableI*)_r1 restore: [_solutionPool best]]; }];
   
    _t0 = [[NSThread alloc] initWithTarget: _r0 selector: @selector(start) object: nil];
    _t1 = [[NSThread alloc] initWithTarget: _r1 selector: @selector(start) object: nil];
    [_t1 start];
    [NSThread sleepForTimeInterval:0.5]; //so MIP doesn't receive bounds before it starts
    [_t0 start];

    
    // Wait for the runnables to finish
    while([_t0 isExecuting] || [_t1 isExecuting]) {
        //[NSThread sleepForTimeInterval: 0.25];
        //NSLog(@"r2 bound: %@", [[[_r1 model] objective] description]);
        [ORConcurrency pumpEvents];
    }
}

-(id<ORRunnable>) primaryRunnable { return _r0; }
-(id<ORRunnable>) secondaryRunnable { return _r1; }

-(void) receiveSolution:(id<ORSolution>)sol {
    [_solutionPool addSolution: sol];
}

@end

