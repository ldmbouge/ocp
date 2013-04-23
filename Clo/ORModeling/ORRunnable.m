//
//  ORRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import "ORRunnable.h"
#import "ORFactory.h"
#import "ORProgramFactory.h"
#import "ORConcurrencyI.h"
#import <objmp/LPSolverI.h>
#import "CPRunnable.h"

@implementation ORAbstractRunnableI

-(id) initWithModel: (id<ORModel>)m children:(NSArray *)child
{
    self = [super init];
    _model = m;
    _child = child;
    _exitBlock = nil;
    return self;
}

-(void) dealloc {
    if(_exitBlock) [_exitBlock release];
    [super dealloc];
}

-(id<ORModel>) model
{
    return _model;
}

-(id<ORSignature>) signature
{
    return nil;
}
-(void) start
{
    if(_child != nil) [self connectPiping: _child];
    [self run];
}

-(void) run
{
    if(_exitBlock) _exitBlock();
}

-(NSArray*) children
{
    return _child;
}

-(void) onExit: (ORClosure)block
{
    _exitBlock = [block copy];
}

-(void) connectPiping: (NSArray*)runnables {}

@end

@implementation LPRunnableI {
    id<ORModel> _model;
    id<ORSignature> _sig;
    id<LPProgram> _program;
}

-(id) initWithModel: (id<ORModel>)m
{
    if((self = [super init]) != nil) {
        _model = [m retain];
        _sig = nil;
        _program = [ORFactory createLPProgram: _model];
    }
    return self;
}

-(void) dealloc
{
    [_model release];
    [_program release];
    [super dealloc];
}

-(id<ORModel>) model { return _model; }

-(id<ORSignature>) signature
{
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete"];
    }
    return _sig;
}

-(id<LPProgram>) solver { return _program; }

-(id<ORFloatArray>) duals
{
    return [[_program solver] duals];
}

-(void) injectColumn: (id<ORFloatArray>) col
{    
}

-(void) run
{
    NSLog(@"Running LP runnable(%p)...", _program);
    [_program solve];
    NSLog(@"Finishing LP runnable(%p)...", _program);
}

-(void) onExit: (ORClosure)block {}

@end


@implementation MIPRunnableI {
    id<ORModel> _model;
    id<ORSignature> _sig;
    id<MIPProgram> _program;
}

-(id) initWithModel: (id<ORModel>)m
{
    if((self = [super init]) != nil) {
        _model = [m retain];
        _sig = nil;
        _program = [ORFactory createMIPProgram: _model];
    }
    return self;
}

-(void) dealloc
{
    [_model release];
    [_program release];
    [super dealloc];
}

-(id<ORModel>) model { return _model; }

-(id<ORSignature>) signature
{
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete"];
    }
    return _sig;
}

-(id<MIPProgram>) solver { return _program; }

-(id<ORFloatArray>) duals
{
    return [[_program solver] duals];
}

-(void) injectColumn: (id<ORFloatArray>) col
{
}

-(void) run
{
    NSLog(@"Running MIP runnable(%p)...", _program);
    [_program solve];
    NSLog(@"Finishing MIP runnable(%p)...", _program);
}

-(void) onExit: (ORClosure)block {}

@end


@implementation ORFactory(ORRunnable)
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m
{
    id<ORRunnable> r = [[CPRunnableI alloc] initWithModel: m];
    return r;
}
+(id<ORRunnable>) LPRunnable: (id<ORModel>)m
{
    id<ORRunnable> r = [[LPRunnableI alloc] initWithModel: m];
    return r;
}
+(id<ORRunnable>) MIPRunnable: (id<ORModel>)m
{
    id<ORRunnable> r = [[MIPRunnableI alloc] initWithModel: m];
    return r;
}
@end
