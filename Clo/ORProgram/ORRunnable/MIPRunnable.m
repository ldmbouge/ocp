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
#import <ORScheduler/ORScheduler.h>

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
        _sig = [ORFactory createSignature: @"complete.upperStreamIn.upperStreamOut.lowerStreamIn.lowerStreamOut.solutionStreamIn"];
    }
    return _sig;
}
-(void) injectColumn: (id<ORDoubleArray>) col
{
}

-(void) run
{
    NSLog(@"Running MIP runnable(%p)...", _program);
    [[[_program solver] boundInformer] wheneverNotifiedDo: ^(ORDouble bnd) { [self notifyUpperBound: (ORInt)bnd]; }];
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

-(void) receiveUpperBound: (ORInt)bound
{
    NSLog(@"MIPRunnable(%p): recieved upper bound: %i", self, bound);
    [[_program solver] tightenBound: bound];
}

-(void) receiveLowerBound:(ORDouble)bound
{
    NSLog(@"(%p) recieved upper bound: %f", self, bound);
    //MIPSolverI* mipSolver = [[self solver] solver];
    //MIPVariableI* objVar = [[((ORObjectiveFunctionExprI*)[[self model] objective]) expr] dereference];
    //MIPVariableI* varArr[] = {objVar};
    //ORFloat coefArr[] = {1.0};
    //MIPConstraintI* c = [mipSolver createLEQ: 1 var: varArr coef: coefArr rhs: bound];
    //[mipSolver postConstraint: c];
}

-(void) receiveSolution:(id<ORSolution>)sol
{
    NSArray* modelVars = [[sol model] variables];
    NSMutableArray* vars = [[NSMutableArray alloc] init];
    NSMutableArray* vals = [[NSMutableArray alloc] init];
    for(id<ORVar> v in modelVars) {
        if([v conformsToProtocol: @protocol(ORTaskVar)]) {
            id<ORTaskVar> t = (id<ORTaskVar>)v;
            MIPVariableI* x = [_program concretize: [t getStartVar]];
            [vars addObject: x];
            [vals addObject: @((ORInt)[[sol value: t] est])];
        }
    }
    
    
//    id<ORIntVarArray> modelVars = [[sol model] intVars];
//    NSMutableArray* vars = [[NSMutableArray alloc] init];
//    NSMutableArray* vals = [[NSMutableArray alloc] init];
//    [modelVars enumerateWith: ^(id<ORIntVar> v, ORInt idx) {
//        MIPVariableI* x = [_program concretize: v];
//        if(x != nil) {
//            [vars addObject: x];
//            [vals addObject: @([sol intValue: v])];
//        }
//    }];
    
    NSLog(@"MIPRunnable(%p): recieved solution: %p", self, sol);
    [[_program solver] injectSolution: vars values: vals size: (ORInt)[vars count]];
}

@end

