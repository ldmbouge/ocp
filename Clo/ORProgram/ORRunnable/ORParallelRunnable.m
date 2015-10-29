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
#import <ORProgram/ORSolution.h>

@implementation ORCompleteParallelRunnableI {
    id<ORRunnable> _r0;
    id<ORRunnable> _r1;
    id<ORSolutionPool> _solutionPool;
    NSThread* _t0;
    NSThread* _t1;
    ORDouble _bestBound;
    id<ORRunnable> _solvedRunnable;
}

-(id) initWithPrimary: (id<ORRunnable>)r0 secondary: (id<ORRunnable>)r1 {
    if((self = [super initWithModel: [r0 model]]) != nil) {
        _r0 = r0;
        _r1 = r1;
        _t0 = nil;
        _t1 = nil;
        _solutionPool = [[ORSolutionPool alloc] init];
        _bestBound = -DBL_MAX;
        _solvedRunnable = nil;
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

-(ORDouble) bestBound {
    return _bestBound;
}

-(void) setTimeLimit:(ORFloat)secs {
    [_r0 setTimeLimit: secs];
    [_r1 setTimeLimit: secs];
}

-(id<ORSolution>) bestSolution {
    if(_solvedRunnable) return [_solvedRunnable bestSolution];
    return nil;
}

-(id<ORRunnable>) solvedRunnable {
    return  _solvedRunnable;
}

-(void) run {
    
//    [_r0 onExit: ^() { [(CPRunnableI*)_r0 restore: [_solutionPool best]]; }];
//    [_r1 onExit: ^() { [(CPRunnableI*)_r1 restore: [_solutionPool best]]; }];
   
    _t0 = [[NSThread alloc] initWithTarget: _r0 selector: @selector(start) object: nil];
    _t1 = [[NSThread alloc] initWithTarget: _r1 selector: @selector(start) object: nil];
    [_t1 start];
    //[NSThread sleepForTimeInterval:0.5]; //so MIP doesn't receive bounds before it starts
    [_t0 start];
    
    // Wait for the runnables to finish
    while([_t0 isExecuting] && [_t1 isExecuting]) {
        [NSThread sleepForTimeInterval: 0.25];
        //NSLog(@"r2 bound: %@", [[[_r1 model] objective] description]);
        //[ORConcurrency pumpEvents];
    }
    [_t0 cancel];
    [_t1 cancel];
    id<ORSolution> s0 = [_r0 bestSolution];
    id<ORSolution> s1 = [_r1 bestSolution];
    if(s0 && s1) {        
        _solvedRunnable = ([[s0 objectiveValue] dblValue] <= [[s1 objectiveValue] dblValue]) ? _r0 : _r1;
        _bestBound = MIN([[s0 objectiveValue] dblValue], [[s1 objectiveValue] dblValue]);
    }
    else if(s0) { _bestBound = [[s0 objectiveValue] dblValue]; _solvedRunnable = _r0; }
    else if(s1) { _bestBound = [[s1 objectiveValue] dblValue]; _solvedRunnable = _r1; }
}

-(id<ORRunnable>) primaryRunnable { return _r0; }
-(id<ORRunnable>) secondaryRunnable { return _r1; }

-(void) receiveSolution:(id<ORSolution>)sol {
    NSLog(@"Sol: %@", [sol description]);
    [_solutionPool addSolution: sol];
}

@end

