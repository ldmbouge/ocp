//
//  MIPRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import "MIPRunnable.h"
#import "ORProgramFactory.h"

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

