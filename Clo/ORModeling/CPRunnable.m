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
}

-(id) initWithModel: (id<ORModel>)m
{
    if((self = [super initWithModel: m children: nil]) != nil) {
        _program = [ORFactory createCPProgram: m];
    }
    return self;
}

-(void) dealloc
{
    [_program release];
    [super dealloc];
}

-(id<CPProgram>) solver { return _program; }

-(void) connectPiping:(NSArray *)runnables {
    [self useUpperBoundStreamInformer];
    [self useSolutionStreamInformer];

    // Connect inputs
    for(id<ORRunnable> r in runnables) {
        if(r == self) continue;
        if([[r signature] providesUpperBound]) {
            id<ORUpperBoundStreamProducer> producer = (id<ORUpperBoundStreamProducer>)r;
            [producer addBoundStreamConsumer: self];
        }
    }
}

-(void) receiveUpperBound:(ORInt)bound
{
    NSLog(@"(%p) recieved upper bound: %i", self, bound);
    [[_program objective] tightenPrimalBound:
        [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: bound minimize: YES]];
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

