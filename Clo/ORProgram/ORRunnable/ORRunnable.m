//
//  ORRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <ORProgram/ORRunnable.h>
#import <ORFoundation/ORFactory.h>
#import <ORProgram/ORProgramFactory.h>
#import "ORConcurrencyI.h"
#import "CPRunnable.h"
#import "LPRunnable.h"
#import "MIPRunnable.h"

@implementation ORAbstractRunnableI

-(id) initWithModel: (id<ORModel>)m
{
    self = [super init];
    _model = m;
    _startBlock = nil;
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
-(id<ORASolver>) solver
{
   return nil;
}
-(id<ORSignature>) signature
{
    return nil;
}
-(void) start
{
    if(_startBlock) _startBlock();
    [self run];
    if(_exitBlock) _exitBlock();
}

-(void) run
{
    [NSException raise: @"ORAbstractRunnableI" format: @"called abstract method: run"];
}

-(ORDouble) bestBound
{
    [NSException raise: @"ORAbstractRunnableI" format: @"called abstract method: bestBound"];
    return 0;
}

-(id<ORSolution>) bestSolution
{
    [NSException raise: @"ORAbstractRunnableI" format: @"called abstract method: bestSolution"];
    return nil;
}


-(void) setTimeLimit: (ORDouble) secs {
    [NSException raise: @"ORAbstractRunnableI" format: @"called abstract method: setTimeLimit"];
}

-(void) performOnStart: (ORClosure)c
{
    _startBlock = [c copy];
}

-(void) performOnExit: (ORClosure)c
{
    _exitBlock = [c copy];
}

@end


@implementation ORFactory(ORRunnable)
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m
{
    id<CPRunnable> r = [[CPRunnableI alloc] initWithModel: m];
    return r;
}
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m solve: (void(^)(id<CPCommonProgram>))body
{
    id<CPRunnable> r = [[CPRunnableI alloc] initWithModel: m search: body];
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
