//
//  MIPRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import "MIPRunnable.h"
#import "MIPSolverI.h"
#import "ORProgramFactory.h"

@implementation MIPRunnableI {
    id<ORModel> _model;
    id<ORSignature> _sig;
    id<MIPProgram> _program;
}

-(id) initWithModel: (id<ORModel>)m
{
    if((self = [super initWithModel:m]) != nil) {
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
        _sig = [ORFactory createSignature: @"complete.upperStreamIn.upperStreamOut"];
    }
    return _sig;
}

-(id<MIPProgram>) solver { return _program; }

-(void) connectPiping:(NSArray *)runnables {
    [self useUpperBoundStreamInformer];
    [self useSolutionStreamInformer];
    
    // Connect inputs
    for(id<ORRunnable> r in runnables) {
        if([[r signature] providesUpperBoundStream]) {
            id<ORUpperBoundStreamProducer> producer = (id<ORUpperBoundStreamProducer>)r;
            [producer addUpperBoundStreamConsumer: self];
        }
    }
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

-(void) receivedUpperBound:(ORInt)bound
{
    NSLog(@"(%p) recieved upper bound: %i", self, bound);
    MIPSolverI* mipSolver = [[self solver] solver];
    MIPVariableI* objVar = [[((ORObjectiveFunctionExprI*)[[self model] objective]) expr] dereference];
    MIPVariableI* varArr[] = {objVar};
    ORFloat coefArr[] = {1.0};
    MIPConstraintI* c = [mipSolver createLEQ: 1 var: varArr coef: coefArr rhs: bound];
    [mipSolver postConstraint: c];
}

@end

