//
//  MIPRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import "MIPRunnable.h"
#import <objmp/MIPSolverI.h>
#import "ORProgramFactory.h"
#import <ORProgram/ORSolution.h>
#import <ORScheduler/ORScheduler.h>
//#import <ORSchedulingProgram/ORSchedulingProgram.h>

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

-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt)nth
{
    if((self = [super initWithModel:m]) != nil) {
        _model = [m retain];
        _sig = nil;
        _program = [ORFactory createMIPProgram: _model];
        MIPSolverI* solver = (MIPSolverI*)[_program engine];
        [solver setIntParameter: "Threads" val: nth];
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
        //_sig = [ORFactory createSignature: @"complete.upperStreamIn.upperStreamOut.lowerStreamIn.lowerStreamOut.solutionStreamIn"];
        ORMutableSignatureI* sig = [[ORMutableSignatureI alloc] init];
        [sig complete];
        [sig lowerStreamIn];
        [sig lowerStreamOut];
        [sig upperStreamIn];
        [sig upperStreamOut];
        [sig solutionStreamIn];
        [sig solutionStreamOut];
        _sig = sig;
    }
    return _sig;
}
-(void) addCuts: (id<ORConstraintSet>) cuts
{
    [cuts enumerateWith:^(id<ORConstraint> c) {
        [_model add: c];
    }];
    [_program release];
    _program = [ORFactory createMIPProgram: _model];
}

-(void) run
{
   NSLog(@"Running MIP runnable(%p)...", _program);
   ORLong cpu0 = [ORRuntimeMonitor wctime];
    [self doStart];
   [[[_program solver] boundInformer] wheneverNotifiedDo: ^(ORDouble bnd) { [self notifyUpperBound: (ORInt)bnd]; }];
   [_program solve];
   ORLong cpu1 = [ORRuntimeMonitor wctime];
   NSLog(@"Finishing MIP runnable(%p)... TTLMIP = %lld", _program,cpu1-cpu0);
}

-(void) cancelSearch {
    [[_program solver] cancel];
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
    static __thread int bndCount = 0;
    NSLog(@"MIPRunnable(%p): received bound(%i): %i inside: %p", self, ++bndCount, bound,[NSThread currentThread]);
    [[_program solver] tightenBound: bound];
}

-(void) receiveLowerBound:(ORDouble)bound
{
    //MIPSolverI* mipSolver = [[self solver] solver];
    //MIPVariableI* objVar = [[((ORObjectiveFunctionExprI*)[[self model] objective]) expr] dereference];
    //MIPVariableI* varArr[] = {objVar};
    //ORFloat coefArr[] = {1.0};
    //MIPConstraintI* c = [mipSolver createLEQ: 1 var: varArr coef: coefArr rhs: bound];
    //[mipSolver postConstraint: c];
}

-(void) receiveSolution:(id<ORSolution,ORSchedulerSolution>)sol
{
   ORTimeval cpu0 = [ORRuntimeMonitor now];
   static int solCount = 0;
   id<ORModel> theModel = [[sol model] rootModel];
   NSArray* modelVars = [theModel variables];
   NSMutableArray* vars = [[NSMutableArray alloc] init];
   NSMutableArray* vals = [[NSMutableArray alloc] init];
   for(id<ORVar> v in modelVars) {
      if([v conformsToProtocol: @protocol(ORTaskVar)]) {
         id<ORTaskVar> t = (id<ORTaskVar>)v;
         MIPVariableI* x = [_program concretize: [t getStartVar]];
         [vars addObject: x];
         //[vals addObject: @((ORInt)[[sol value: t] est])];
         [vals addObject: @([sol est:t])];
      } else if ([v conformsToProtocol:@protocol(ORIntVar)]) {
         id<ORIntVar> t = (id<ORIntVar>)v;
         MIPVariableI* x = [_program concretize:t];
         if (x!=nil) {
            [vars addObject: x];
            [vals addObject: @([sol intValue:t])];
         }
      }
   }
   
   NSLog(@"MIPRunnable(%p): received solution(%i): %p  (%@)", self, ++solCount, sol,sol.objectiveValue);
   [[_program solver] injectSolution: vars values: vals size: (ORInt)[vars count]];
   static ORLong ttlMIPIN = 0;
   ORTimeval cpu1 = [ORRuntimeMonitor elapsedSince:cpu0];
   ttlMIPIN += (ORLong)cpu1.tv_sec * 1000000 + cpu1.tv_usec;
   assert(ttlMIPIN >= 0);
   NSLog(@"TTL MIP: %lld",ttlMIPIN);
}

@end

