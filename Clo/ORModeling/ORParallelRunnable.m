//
//  ORParallelRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import "ORParallelRunnable.h"

@implementation ORParallelRunnableI {
    id<ORRunnable> _r0;
    id<ORRunnable> _r1;
    id<ORSignature> _sig;
    NSThread* _t0;
    NSThread* _t1;
}

-(id) initWithPrimary: (id<ORRunnable>)r0 secondary: (id<ORRunnable>)r1 {
    if((self = [super init]) != nil) {
        _r0 = r0;
        _r1 = r1;
        _t0 = nil;
        _t1 = nil;
    }
    return self;
}

-(void) dealloc {
    [_r0 release];
    [_r1 release];
    [_t0 release];
    [_t1 release];
    [super dealloc];
}

-(id<ORSignature>) signature {
    if(_sig == nil) {
        _sig = [[ORSignatureI alloc] init];
    }
    return _sig;
}

-(void) run {    
    if([[_r0 signature] providesUpperBoundStream] && [[_r1 signature] acceptsUpperBoundStream])
        [((id<ORUpperBoundStreamProvider>)_r0) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)_r1];
    if([[_r1 signature] providesUpperBoundStream] && [[_r0 signature] acceptsUpperBoundStream])
        [((id<ORUpperBoundStreamProvider>)_r1) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)_r0];
        
    _t0 = [[NSThread alloc] initWithTarget: _r0 selector: @selector(run) object: nil];
    [_t0 start];
    
    _t1 = [[NSThread alloc] initWithTarget: _r1 selector: @selector(run) object: nil];
    [_t1 start];
    
    while([_t0 isExecuting] || [_t1 isExecuting]) [NSThread sleepForTimeInterval: 0.25];
}

-(id<ORRunnable>) primaryRunnable { return _r0; }
-(id<ORRunnable>) secondaryRunnable { return _r1; }

@end

@implementation ORParallelRunnableTransform

-(id<ORRunnable>) apply:(id<ORRunnable>)r0 and:(id<ORRunnable>)r1 {
    return [[[ORParallelRunnableI alloc] initWithPrimary: r0 secondary: r1] autorelease];
}

@end