//
//  LPRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import "LPRunnable.h"
#import "LPSolver.h"

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

-(void) injectColumn: (id<LPColumn>) col
{
    [_program addColumn: col];
}

-(void) run
{
    NSLog(@"Running LP runnable(%p)...", _program);
    [_program solve];
    NSLog(@"Finishing LP runnable(%p)...", _program);
}

@end

