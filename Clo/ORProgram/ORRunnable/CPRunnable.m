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
#import <ORProgram/ORSolution.h>

@implementation CPRunnableI {
    id<CPProgram> _program;
    id<ORSignature> _sig;
    void(^_search)(id<CPCommonProgram>);
}

-(id) initWithModel: (id<ORModel>)m
{
    if((self = [super initWithModel: m]) != nil) {
        _program = [ORFactory createCPProgram: m];
        _sig = nil;
        _search = nil;
    }
    return self;
}

-(id) initWithModel: (id<ORModel>)m search: (void(^)(id<CPCommonProgram>))search
{
    if((self = [super initWithModel: m]) != nil) {
        _program = [ORFactory createCPProgram: m];
        _sig = nil;
        _search = [search retain];
    }
    return self;
}

-(id) initWithModel: (id<ORModel>)m willSearch: (CPRunnableSearch(^)(id<CPCommonProgram>))willSearch {
    if((self = [super initWithModel: m]) != nil) {
        _program = [ORFactory createCPProgram: m];
        _sig = nil;
        void(^searchBlock)(id<CPCommonProgram>) = willSearch(_program);
        _search = [searchBlock retain];
    }
    return self;
}

-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt) nth
{
    if((self = [super initWithModel: m]) != nil) {
        _program = (id)[ORFactory createCPParProgram: m
                                                  nb: nth
                                          annotation: [ORFactory annotation]
                                                with: [ORSemDFSController proto]];
        _sig = nil;
        _search = nil;
    }
    return self;
}

-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt) nth search: (void(^)(id<CPCommonProgram>))search
{
    if((self = [super initWithModel: m]) != nil) {
        _program = (id)[ORFactory createCPParProgram: m
                                                  nb: nth
                                          annotation: [ORFactory annotation]
                                                with: [ORSemDFSController proto]];
        _sig = nil;
        _search = [search retain];
    }
    return self;
}

-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt) nth willSearch: (CPRunnableSearch(^)(id<CPCommonProgram>))willSearch {
    if((self = [super initWithModel: m]) != nil) {
        _program = (id)[ORFactory createCPParProgram: m
                                                  nb: nth
                                          annotation: [ORFactory annotation]
                                                with: [ORSemDFSController proto]];
        _sig = nil;
        void(^searchBlock)(id<CPCommonProgram>) = willSearch(_program);
        _search = [searchBlock retain];
    }
    return self;
}

-(id) initWithModel: (id<ORModel>)m
     withRelaxation:(id<ORRelaxation>)relax
             search: (void(^)(id<CPCommonProgram>))search
{
   if((self = [super initWithModel: m]) != nil) {
      _program = [ORFactory createCPProgram: m  withRelaxation:relax];
      _sig = nil;
      _search = [search retain];
   }
   return self;
}

-(id) initWithModel: (id<ORModel>)m
     withRelaxation:(id<ORRelaxation>)relax
             search: (void(^)(id<CPCommonProgram>))search
         controller: (id<ORSearchController>)proto
{
   if((self = [super initWithModel: m]) != nil) {
      id<ORAnnotation> notes = [ORFactory annotation];
      _program = [ORFactory createCPProgram: m  withRelaxation:relax annotation:notes with:proto];
      _sig = nil;
      _search = [search retain];
   }
   return self;
}

-(id) initWithModel: (id<ORModel>)m
     withRelaxation:(id<ORRelaxation>)relax
         numThreads: (ORInt) nth
             search: (void(^)(id<CPCommonProgram>))search
{
   assert(0); // we are missing the relaxation!
   if((self = [super initWithModel: m]) != nil) {
      _program = (id)[ORFactory createCPParProgram: m
                                                nb: nth
                                        annotation: [ORFactory annotation]
                                              with: [ORSemDFSController proto]];
      _sig = nil;
      _search = [search retain];
   }
   return self;
}


-(void) dealloc
{
    [_program release];
    [_search release];
    [super dealloc];
}

-(id<ORSignature>) signature
{
    if(_sig == nil) {
        //_sig = [ORFactory createSignature: @"complete.upperStreamIn.upperStreamOut.lowerStreamIn.lowerStreamOut.solutionStreamOut"];
        ORMutableSignatureI* sig = [[ORMutableSignatureI alloc] init];
        [sig complete];
        [sig upperStreamIn];
        [sig upperStreamOut];
        [sig lowerStreamIn];
        [sig solutionStreamOut];
        _sig = [sig retain];
    }
    return _sig;
}

-(id<CPProgram>) solver { return _program; }

-(void) receiveUpperBound: (ORInt)bound
{
    static __thread int bndCount = 0;
    id<ORObjectiveValue> pb = [[_program objective] primalBound];
    NSLog(@"CPRunnable(%p): received bound(%i): %i  PRIMAL WAS: %@ inside: %p", self, ++bndCount, bound,pb,[NSThread currentThread]);
   id<ORObjectiveValue> nb = [ORFactory objectiveValueInt:bound minimize:YES];
   [[_program objective] tightenPrimalBound:nb];
   [nb release];
}

-(void) receiveLowerBound:(ORDouble)bound
{
    NSLog(@"(%p) received lower bound(%p): %f", self, [NSThread currentThread],bound);
    id<ORObjectiveValue> nb = [ORFactory objectiveValueInt:bound minimize:YES];
    [[_program objective] tightenDualBound:nb];
    [nb release];
}

-(void) receiveSolution:(id<ORSolution>)sol {
    NSLog(@"Got Sol!");
}

-(void) run
{
   NSLog(@"Running CP runnable(%p)...", _program);
   ORLong cpu0 = [ORRuntimeMonitor wctime];
   [_program onStartup:^{
      [self doStart];
   }];
    // When a solution is found, pass the objective value to consumers.
    [_program onSolution:^{
        id<ORSolution> s = [_program captureSolution];
        [self notifySolution: s];
        id<ORObjectiveValueInt> objectiveValue = (id<ORObjectiveValueInt>)[s objectiveValue];
        //NSLog(@"Sending solution: %p  -- %@",[NSThread currentThread],objectiveValue);
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
//        id<ORSolution> best = [[_program solutionPool] best];
//        NSLog(@"best: %@", best);
    }];
    
    if(_search) {
        [_program solveOn: _search];
    }
    else {
        id<CPHeuristic> h = [_program createFF];
        [_program solve:
         ^() {
             NSLog(@"Solving CP program...");
             NSIndexSet* intVarSet = [[_model variables] indexesOfObjectsPassingTest: ^BOOL(id obj, NSUInteger i, BOOL* stop) {
                 return [obj conformsToProtocol: @protocol(ORIntVar)];
             }];
             NSArray* intVarArray = [[_model variables] objectsAtIndexes: intVarSet];
             id<ORIntVarArray> intVars = [ORFactory intVarArray: _program range: RANGE(_program, 0, (ORInt)intVarArray.count-1) with: ^id<ORIntVar>(ORInt i) {
                 return [intVarArray objectAtIndex: i];
             }];
             [_program labelHeuristic: h restricted: intVars];
         }];
    }
    ORLong cpu1 = [ORRuntimeMonitor wctime];
    NSLog(@"status: %@", _program);
    NSLog(@"Finishing CP runnable(%p)...  time=%lld", _program,cpu1-cpu0);
}

-(id<ORSolution>) bestSolution
{
    return [[_program solutionPool] best];
}

-(ORDouble) bestBound
{
    return [[[[_program solutionPool] best] objectiveValue] doubleValue];
}

-(void)cancelSearch
{
    [[[_program explorer] controller] abort];
}

//-(void) restore: (id<ORSolution>)s {
//    [[_program engine] enforce: ^ORStatus() {
//        [_model restore: s];
//        return ORSuccess;
//    }];
//
//}

@end

