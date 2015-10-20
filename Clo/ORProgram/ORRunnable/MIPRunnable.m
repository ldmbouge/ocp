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
#import <ORProgram/ORSolution.h>

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

-(id<ORModel>) model {
   return _model;
}
-(id<ORASolver>) solver
{
   return _program;
}
-(id<ORSignature>) signature
{
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.upperStreamIn.upperStreamOut"];
    }
    return _sig;
}
-(void) injectColumn: (id<ORDoubleArray>) col
{
}

-(void) run
{
    NSLog(@"Running MIP runnable(%p)...", _program);
    [_program solve];
    NSLog(@"Finishing MIP runnable(%p)...", _program);
}

-(void) setTimeLimit: (ORDouble) secs
{
    assert(NO);
   //[_program setTimeLimit: secs];
}

-(ORDouble) bestBound {
   return [_program bestObjectiveBound];
}

-(id<ORSolution>) bestSolution {
   return [[_program solutionPool] best];
}

-(void) receivedUpperBound:(ORInt)bound
{
    NSLog(@"(%p) recieved upper bound: %i", self, bound);
    //MIPSolverI* mipSolver = [[self solver] solver];
    //MIPVariableI* objVar = [[((ORObjectiveFunctionExprI*)[[self model] objective]) expr] dereference];
    //MIPVariableI* varArr[] = {objVar};
    //ORFloat coefArr[] = {1.0};
    //MIPConstraintI* c = [mipSolver createLEQ: 1 var: varArr coef: coefArr rhs: bound];
    //[mipSolver postConstraint: c];
}

@end

