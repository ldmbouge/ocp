//
//  CPRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import "CPRunnable.h"
#import "ORRunnablePiping.h"
#import "ORProgramFactory.h"


@implementation CPRunnableI {
    id<CPProgram> _program;
    id<ORSignature> _sig;
}

-(id) initWithModel: (id<ORModel>)m
{
    if((self = [super initWithModel: m]) != nil) {
        _program = [ORFactory createCPProgram: m];
        _sig = nil;
    }
    return self;
}

-(void) dealloc
{
    [_program release];
    [super dealloc];
}

-(id<ORSignature>) signature
{
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.upperStreamIn.upperStreamOut.lowerStreamIn.lowerStreamOut.solutionStreamIn.solutionStreamOut"];
    }
    return _sig;
}

-(id<CPProgram>) solver { return _program; }

-(void) receiveUpperBound:(ORInt)bound
{
    NSLog(@"(%p) recieved upper bound: %i", self, bound);
    [[_program objective] tightenPrimalBound:[ORFactory objectiveValueInt:bound minimize:YES]];
}

-(void) receiveLowerBound:(ORInt)bound
{
    NSLog(@"(%p) recieved lower bound: %i", self, bound);
}

-(void) receiveSolution:(id<ORSolution>)sol {
    NSLog(@"Got Sol!");
}

-(void) run
{
    NSLog(@"Running CP runnable(%p)...", _program);
    id<CPHeuristic> h = [_program createFF];
    // When a solution is found, pass the objective value to consumers.
    [_program onSolution:^{
        id<ORSolution> s = [_program captureSolution];
        [self notifySolution: s];
        id<ORObjectiveValueInt> objectiveValue = (id<ORObjectiveValueInt>)[s objectiveValue];
        [self notifyUpperBound: [objectiveValue value]];
    }];
    
    [_program onExit: ^ {
        //id<ORObjectiveValueInt> objectiveValue = [[(id<ORObjectiveValueInt>)[[self solver] solutionPool] best] objectiveValue];
        //[self notifyLowerBound: [objectiveValue value]];
        [self doExit];
        //else {
        //    id<ORSolution> best = [[_program solutionPool] best];
            //            [_model restore:best];
            //[best release];
        //}
        id<ORSolution> best = [[_program solutionPool] best];
        NSLog(@"best: %@", best);
    }];
    
    [_program solve:
     ^() {
         NSLog(@"Solving CP program...");
         NSIndexSet* intVarSet = [[_model variables] indexesOfObjectsPassingTest: ^BOOL(id obj, NSUInteger i, BOOL* stop) {
             return [obj conformsToProtocol: @protocol(ORIntVar)];
         }];
         NSArray* intVarArray = [[_model variables] objectsAtIndexes: intVarSet];
         id<ORIntVarArray> intVars = [ORFactory intVarArray: _program range: RANGE(_program, 0, intVarArray.count-1) with: ^id<ORIntVar>(ORInt i) {
             return [intVarArray objectAtIndex: i];
         }];
         [_program labelHeuristic: h restricted: intVars];
     }];
    NSLog(@"status: %@", _program);
    NSLog(@"Finishing CP runnable(%p)...", _program);
}

//-(void) restore: (id<ORSolution>)s {
//    [[_program engine] enforce: ^ORStatus() {
//        [_model restore: s];
//        return ORSuccess;
//    }];
//
//}

@end

