//
//  CPRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import "CPRunnable.h"
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

-(void) connectPiping:(NSArray *)runnables {
    [self useUpperBoundStreamInformer];
    [self useLowerBoundStreamInformer];
    [self useSolutionStreamInformer];

    // Connect inputs
    for(id<ORRunnable> r in runnables) {
        if([[r signature] providesUpperBoundStream]) {
            id<ORUpperBoundStreamProducer> producer = (id<ORUpperBoundStreamProducer>)r;
            [producer addUpperBoundStreamConsumer: self];
        }
        if([[r signature] providesLowerBoundStream]) {
            id<ORLowerBoundStreamProducer> producer = (id<ORLowerBoundStreamProducer>)r;
            [producer addLowerBoundStreamConsumer: self];
        }
    }
}

-(void) receivedUpperBound:(ORInt)bound
{
    NSLog(@"(%p) recieved upper bound: %i", self, bound);
    [[_program objective] tightenPrimalBound:
        [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: bound minimize: YES]];
}

-(void) receivedLowerBound:(ORInt)bound
{
    NSLog(@"(%p) recieved lower bound: %i", self, bound);
    [[_program objective] tightenPrimalBound:
     [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: bound minimize: NO]];
    NSLog(@"obj: %@", [[[self model] objective] description]);
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
    }];
    
    [_program solve:
     ^() {
         NSLog(@"Solving CP program...");
         [_program labelHeuristic: h];
     }];
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

