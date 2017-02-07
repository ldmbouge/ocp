//
//  ORLagrangeRelax.m
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import <ORModeling/ORModeling.h>
#import <ORProgram/ORLagrangeRelax.h>
#import <ORFoundation/ORExpr.h>
#import <ORProgram/MIPProgram.h>
#import <objmp/MIPSolverI.h>
#import <objcp/CPFactory.h>
#import <ORFoundation/ORVisit.h>
#import <ORProgram/ORSolution.h>
#import <ORProgram/ORProgramFactory.h>
#import "MIPRunnable.h"

@interface ORTermCollector : ORNOopVisit<NSObject> {
    NSMutableArray* _terms;
}
-(ORTermCollector*)init;
-(NSArray*)doIt:(id<ORExpr>)e;
// Variables
-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitRealVar: (id<ORRealVar>) v;
-(void) visitIntVarLitEQView:(id<ORIntVar>)v;
-(void) visitAffineVar:(id<ORIntVar>) v;
// Expressions
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprMinusI: (id<ORExpr>) e;
-(void) visitExprMulI: (id<ORExpr>) e;
-(void) visitExprDivI: (id<ORExpr>) e;
-(void) visitExprModI: (id<ORExpr>) e;
-(void) visitExprEqualI: (id<ORExpr>) e;
-(void) visitExprNEqualI: (id<ORExpr>) e;
-(void) visitExprLEqualI: (id<ORExpr>) e;
-(void) visitExprGEqualI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprProdI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprSquareI:(id<ORExpr>) e;
-(void) visitExprNegateI:(id<ORExpr>)e;
@end

@implementation ORTermCollector
-(ORTermCollector*)init
{
    self = [super init];
    _terms = NULL;
    return self;
}
-(NSArray*)doIt:(id<ORExpr>)e
{
    _terms = [[[NSMutableArray alloc] initWithCapacity:8] autorelease];
    [e visit:self];
    return _terms;
}
// Variables
-(void) visitIntVar: (id<ORIntVar>) v
{
    [_terms addObject:v];
}
-(void) visitBitVar: (id<ORBitVar>) v
{
    [_terms addObject:v];
}
-(void) visitRealVar:(id<ORRealVar>)v
{
    [_terms addObject:v];
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
    [_terms addObject:v];
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
    [_terms addObject:v];
}
// Expressions
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
    [[e left] visit:self];
    [[e right] visit:self];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    [[e left] visit:self];
    [[e right] visit:self];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    [_terms addObject:e];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    [_terms addObject:e];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    [_terms addObject:e];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    [[e left] visit:self];
    [[e right] visit:self];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    [[e left] visit:self];
    [[e right] visit:self];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    [[e left] visit:self];
    [[e right] visit:self];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    [[e left] visit:self];
    [[e right] visit:self];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
    [[e expr] visit:self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
    [_terms addObject: e];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
    [_terms addObject:e];
}
-(void) visitExprSquareI:(ORExprSquareI*) e
{
    [_terms addObject:e];
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
    ORTermCollector* c = [[ORTermCollector alloc] init];
    NSArray* t = [c doIt: [e operand]];
    [c release];
    for(id<ORExpr> e in t) {
        [_terms addObject: [e neg]];
    }
}
@end


@interface ORSubgradientTemplate(Private)
-(id) solverForModel: (id<ORModel>)m;
-(void) solveIt: (id)solver;
@end

@implementation ORSubgradientTemplate {
@protected
    id<ORParameterizedModel> _model;
    id<ORParameterizedSolution> _bestSolution;
    ORDouble _bestBound;
    ORDouble _ub;
    id<ORSignature> _sig;
    ORDouble _solverTimeLimit;
    ORDouble _subgradientTimeLimit;
    ORInt _iters;
    ORDouble _agility;
    ORDouble _runtime;
}

-(id) initSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat) ub
{
    self = [super initWithModel: m];
    if(self) {
        _model = m;
        _sig = nil;
        _ub = ub;
        _bestSolution = nil;
        _bestBound = -DBL_MAX;
        _solverTimeLimit = -DBL_MAX;
        _subgradientTimeLimit = -DBL_MAX;
        _iters = 0;
        _agility = 2.0;
        _runtime = 0;
    }
    return self;
}

-(void) setSolverTimeLimit: (ORFloat)limit {
    _solverTimeLimit = limit;
    if(_solverTimeLimit <= 0) _solverTimeLimit = -DBL_MAX;
}

-(void) setTimeLimit:(ORFloat)secs {
    _subgradientTimeLimit = secs;
    if(_subgradientTimeLimit <= 0) _subgradientTimeLimit = -DBL_MAX;
}

-(ORInt) iterations {
    return _iters;
}

-(ORFloat) runtime {
    return _runtime;
}

-(id) solverForModel: (id<ORModel>)m {
    [NSException raise: @"Abstract Method" format: @"Tried to call an abstract method"];
    return nil;
}

-(void) solveIt: (id)solver {
    [NSException raise: @"Abstract Method" format: @"Tried to call an abstract method"];
}

-(id<ORSolution>) lagrangianSubgradientSolve {
    ORFloat pi = _agility;
    __block ORFloat slackSum = 0.0;
    id<ORParameterizedSolution> bestSol = nil;
    
    id<ORVarArray> slacks = [_model slacks];
    id<ORIntRange> slackRange = [slacks range];
    ORInt branchCount = (ORInt)[[_model intVars] count] - (ORInt)[slacks count];
    id<ORIdArray> branchVars = [ORFactory idArray: _model range: RANGE(_model, 0, branchCount-1)];
    __block ORInt k = 0;
    [[_model intVars] enumerateWith: ^(id obj, ORInt idx) {
        if(![slacks contains: obj]) [branchVars set: obj at: k++];
    }];
    
    id<ORIdArray> lambdas = [ORFactory idArray: _model range: slackRange with: ^id(ORInt i) {
        id<ORVar> slack = [slacks at: i];
        id<ORWeightedVar> w = [_model parameterization: slack];
        return [w weight];
    }];
    
    id<ORASolver> program = [self solverForModel: _model];
    [program close];
    ORFloat cutoff = 0.0005;
    ORInt noImproveLimit = 30;
    ORInt noImprove = 0;
    ORInt timeIncrease = 0;
    NSTimeInterval remainingTime = 0;
    NSDate* t0 = [NSDate date];
    
    _iters = 0;
    while(pi > cutoff) {
        NSDate* t1 = [NSDate date];
        [[program solutionPool] emptyPool];
        if([program respondsToSelector: @selector(setTimeLimit:)]) [program setTimeLimit: 5.0];
        [self solveIt: program];
        _iters++;
        
//        [lambdas enumerateWith:^(id obj, ORInt idx) {
//            id<ORRealParam> lambda = obj;
//            ORDouble val = [(id<MIPProgram>)program paramValue: lambda];
//            NSLog(@"lambda[%i] value: %lf", idx, val);
//        }];
        
        id<ORParameterizedSolution> sol = (id<ORParameterizedSolution>)[[program solutionPool] best];
        id<ORObjectiveValue> objValue = (id<ORObjectiveValue>)[sol objectiveValue];
        ORDouble bound = ([program respondsToSelector: @selector(bestObjectiveBound)]) ? [(id<MIPProgram>)program bestObjectiveBound] : [objValue doubleValue];
        
        __block BOOL satisfied = YES;
        slackSum = 0.0;
        [slacks enumerateWith:^(id<ORVar> obj, ORInt idx) {
            ORDouble s = [obj conformsToProtocol: @protocol(ORIntVar)] ?
                [sol intValue: (id<ORIntVar>)obj] : [sol doubleValue: (id<ORRealVar>)obj];
            slackSum += s * s;
            if(s > 0) satisfied = NO;
        }];
        NSLog(@"slack sum: %f", slackSum);
        
        // Check for improvement
        if(bound > _bestBound) {//if([objValue floatValue] > bestBound) {
            _bestBound = bound;
            bestSol = sol;
            noImprove = 0;
            [self notifyLowerBound: _bestBound];
            [ORConcurrency pumpEvents];
            NSLog(@"new bound: %f", _bestBound);
//            if(satisfied &&
//               [[bestSol objectiveValue] doubleValue] == _bestBound &&
//               [program respondsToSelector: @selector(bestObjectiveBound)]) break;
        }
        else if(++noImprove > noImproveLimit) { pi /= 2.0; noImprove = 0; }
        
        if(_bestSolution == nil) _bestSolution = sol;
        
        //if(satisfied && [program dualityGap] == 0.0) break;
        
        ORFloat stepSize = pi * (_ub - bound) / slackSum;
        
        [lambdas enumerateWith:^(id obj, ORInt idx) {
            id<ORRealParam> lambda = obj;
            ORDouble value = [sol paramValue: lambda];
            id<ORVar> slack = [slacks at: idx];
            ORDouble slackVal = [slack conformsToProtocol: @protocol(ORIntVar)] ?
                [sol intValue: (id<ORIntVar>)slack] : [sol doubleValue: (id<ORRealVar>)slack];
            ORDouble newValue = MAX(0, value + stepSize * slackVal);
            [program param: lambda setValue: newValue];
            NSLog(@"New lambda is[%i]: %lf -- slack: %f", idx, newValue, slackVal);
        }];
        
        // Check if done
        if(satisfied) break;
    }
    return bestSol;
}

-(id<ORSignature>) signature
{
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.columnIn"];
    }
    return _sig;
}

-(id<ORModel>) model
{
    return _model;
}

-(void) run
{
    _bestSolution = (id<ORParameterizedSolution>)[self lagrangianSubgradientSolve];
}

-(ORFloat) bestBound
{
    return _bestBound;
}

-(id<ORSolution>) bestSolution
{
    return _bestSolution;
}

-(void) setAgility: (ORFloat)val {
    _agility = val;
}

-(void) setUpperBound: (ORFloat)upperBound
{
    _ub = upperBound;
}

-(ORFloat) upperBound
{
    return _ub;
}

+(NSMutableArray*) autosplitVariables: (NSArray*)vars constraints: (NSArray*)cstrs {
    if([vars count] <= 2) return [NSMutableArray arrayWithObject: [NSSet setWithArray: vars]];
    
    // Partition variables
    NSSet* allVars = [NSSet setWithArray: vars];
    NSMutableSet* splitSet = [NSMutableSet setWithObject: [vars firstObject]];
    BOOL changed = YES;
    while (changed) {
        changed = NO;
        for(id<ORConstraint> c in cstrs) {
            NSMutableSet* cstrVars = [[c allVars] mutableCopy];
            [cstrVars intersectSet: allVars];
            if([splitSet intersectsSet: cstrVars]) {
                NSInteger oldCount = [splitSet count];
                NSArray* varArray = [cstrVars allObjects];
                [splitSet addObjectsFromArray: varArray];
                [varArray release];
                if([splitSet count] > oldCount) changed = YES;
            }
        }
    }
    
    // Partition failed, return everything
    if([vars count] - [splitSet count] <= 1) {
        [splitSet release];
        return [NSMutableArray arrayWithObject: [NSSet setWithArray: vars]];
    }
    
    // Recursively partition
    NSArray* split0 = [splitSet allObjects];
    NSMutableArray* split1 = [vars mutableCopy];
    [split1 removeObjectsInArray: split0];
    [splitSet release];
    
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity: 32];
    NSMutableArray* r0 = [self autosplitVariables: split0 constraints: cstrs];
    [res addObjectsFromArray: r0];
    [r0 release];
    NSMutableArray* r1 = [self autosplitVariables: split1 constraints: cstrs];
    [res addObjectsFromArray: r1];
    [r1 release];
    
    return res;
}

@end

@interface ORSurrogateTemplate(Private)
-(NSMutableArray*) autosplitVariables: (NSArray*)vars constraints: (NSArray*)cstrs;
-(NSArray*) constraintsForPartition: (NSUInteger) splitIdx;
-(id<ORSolution>) lagrangianSubgradientSolve: (ORFloat)ub;
-(id<ORSolution>) lagrangianSurrogateSolve: (ORFloat)ub;
-(id<ORWeightedVar>) weightedVarForSlack: (id<ORVar>)slack;
@end

@implementation ORSurrogateTemplate {
@protected
    NSMutableArray* _split;
    NSSet* _surrogateBranchVars;
    NSMapTable* _lambdaMap;
}

-(id) initWithSurrogate:(id<ORParameterizedModel>)m bound: (ORFloat) ub
{
    self = [self initSubgradient: m bound: ub];
    _surrogateBranchVars = [[self computeBranchVars] mutableCopy];
    _split = [ORSubgradientTemplate autosplitVariables: [_surrogateBranchVars allObjects] constraints: [m hardConstraints]];
    _lambdaMap = [[NSMapTable alloc] init];
    return self;
}

-(NSSet*) updateLambdas: (id<ORIdArray>) lambdas
                 values: (NSMapTable*)values
                withSlacks: (id<ORIdArray>)slacks
               solution: (id<ORParameterizedSolution>)sol
                  bound: (ORFloat)bound
                     pi: (ORFloat)pi {
    NSMutableSet* modifiedProblems = [[NSMutableSet alloc] init];
    __block ORFloat slackSum = 0.0;
    [slacks enumerateWith:^(id<ORRealVar> obj, ORInt idx) {
        double val = [sol doubleValue: obj];
        slackSum += val * val;
        NSLog(@"slack: %f", [sol doubleValue: obj]);
    }];
    
    id<ORObjectiveValueReal> objValue = (id<ORObjectiveValueReal>)[sol objectiveValue];
    ORDouble stepSize = pi * (bound - [objValue value]) / slackSum;
    
    __block BOOL satisfied = YES;
    [lambdas enumerateWith:^(id obj, ORInt idx) {
        id<ORRealParam> lambda = obj;
        ORDouble value = [sol paramValue: lambda];
        if(value != DBL_MAX) {
            id<ORRealVar> slack = [slacks at: idx];
            ORDouble newValue = MAX(0, value + stepSize * [sol doubleValue: slack]);
            
            if(newValue != value) {
                [values setObject: @(newValue) forKey: lambda];
                //NSLog(@"New lambda[%i]: %lf -- pi: %f slack: %f, obj: %f", idx, newValue, pi, slackSum, [objValue floatValue]);
                NSArray* lambdaProbs = [_lambdaMap objectForKey: obj];
                if(lambdaProbs != nil) [modifiedProblems addObjectsFromArray: lambdaProbs];
            }
            if(newValue != 0.0)
                satisfied = NO;
        }
    }];
    if(satisfied) return nil;
    return modifiedProblems;
}
    
-(id<ORParameterizedSolution>) runAllProblems: (id<ORParameterizedModel>)m solver: (id<MIPProgram>)program withIncumbents: (NSMapTable*)incumbents {
    for(id<ORIntVar> v in _surrogateBranchVars) {
        NSNumber* value = [incumbents objectForKey: v];
        if(value) [program setIntVar: v value: [value intValue]];
    }
    [[program solutionPool] emptyPool];
    [program solve];
    if([[program solver] status] == MIPinfeasible) {
        NSLog(@"infeasible...");
        return nil;
    }
    id<ORParameterizedSolution> sol = (id<ORParameterizedSolution>)[[program solutionPool] best];
    id<ORObjectiveValueReal> objValue = (id<ORObjectiveValueReal>)[sol objectiveValue];
    NSLog(@"objective: %f", [objValue value]);
    return sol;
}

-(id<ORSolution>) lagrangianSurrogateSolve {
    NSMapTable* incumbents = [[NSMapTable alloc] init];
    NSMapTable* lambdaValues = [[NSMapTable alloc] init];
    
    // Build Subproblems
    ORInt subprobCount = (ORInt)_split.count;
    NSMutableArray* subproblems = [[NSMutableArray alloc] initWithCapacity: subprobCount];
    for(NSUInteger i = 0; i < _split.count; i++) {
        id<ORModel> m = [self subproblemForPartition: i];
        [subproblems addObject: m];
    }
    
    ORFloat pi = 1.0f;
    _bestBound = -DBL_MAX;
    _bestSolution = nil;
    
    // Get slacks
    NSArray* softCstrs = [_model softConstraints];
    id<ORIntRange> slackRange = RANGE(_model, 0, (ORInt)softCstrs.count-1);
    id<ORIdArray> slacks = [ORFactory idArray: _model range: slackRange with: ^id(ORInt i) {
        id<ORSoftConstraint> c = [softCstrs objectAtIndex: i];
        return [c slack];
    }];
    
    // Get Lambdas
    id<ORIdArray> lambdas = [ORFactory idArray: _model range: slackRange with: ^id(ORInt i) {
        id<ORVar> slack = [slacks at: i];
        id<ORWeightedVar> w = [_model parameterization: slack];
        return [w weight];
    }];
    for(id<ORRealParam> p in [_model parameters]) [lambdaValues setObject: @([p initialValue]) forKey: p];
    
    // Step 0: solve all subproblems
    id<MIPProgram> program = [ORFactory createMIPProgram: _model];
    id<ORParameterizedSolution> allsol = [self runAllProblems: _model solver: program withIncumbents: incumbents];
    for(id<ORIntVar> x in _surrogateBranchVars) [incumbents setObject: @([allsol intValue: x]) forKey: x];
    
    //ORFloat cutoff = 0.005;
    ORInt noImproveLimit = 10;
    ORInt noImprove = 0;
    id<ORParameterizedModel> subproblem = nil;
    
    while(1) {
        
        // Step 1: update lambdas, lambda^(k+1), x^k
        NSSet* probIndexes = [self updateLambdas: lambdas values: lambdaValues withSlacks: slacks solution: allsol bound: _ub pi: pi];
        //for(NSNumber* idx in probIndexes)
        //    if(![subprobQueue containsObject: idx]) [subprobQueue addObject: idx];
        
        if(probIndexes == nil) {
            NSLog(@"Done");
            break;
        }
        
        id<ORObjectiveValueReal> objValue = (id<ORObjectiveValueReal>)[allsol objectiveValue];
        if([objValue value] > _bestBound) {
            _bestBound = [objValue value];
            _bestSolution = allsol;
            noImprove = 0;
        }
        else if(++noImprove > noImproveLimit) {
            pi /= 2.0;
            noImprove = 0;
        }
        
        program = [ORFactory createMIPProgram: _model];
        [[program solver] close];
        for(id<ORRealParam> p in [_model parameters]) [program param: p setValue: [(NSNumber*)[lambdaValues objectForKey: p] floatValue]];
        id<ORSolution> sol1 = [self runAllProblems: _model solver: program withIncumbents: incumbents];
        
        // Step 2: solve subproblem
        NSMapTable* candidIncumbents = [incumbents copy];
        
        ////////// Solve subproblem ///////////
        NSUInteger r = ((unsigned long)random()) % [probIndexes count];
        NSNumber* n = [[probIndexes allObjects] objectAtIndex: r];
        //[subprobQueue removeObjectAtIndex: 0];
        int probIdx = [n intValue];//[[[probIndexes allObjects] objectAtIndex: r] intValue];
        
        subproblem = [subproblems objectAtIndex: probIdx];
        id<MIPProgram> subproblemSolver = [ORFactory createMIPProgram: subproblem];
        [[subproblemSolver solver] close];
        
        for(id<ORExprVar> x in [subproblem variables]) {
            NSSet* vset = [_split objectAtIndex: probIdx];
            if(![vset member: x]) {
                if([x vtype] == ORTInt)
                    [subproblemSolver setIntVar: (id<ORIntVar>)x value: [[candidIncumbents objectForKey: x] intValue]];
            }
        }
        for(id<ORRealParam> p in [subproblem parameters]) {
            ORDouble value = [(NSNumber*)[lambdaValues objectForKey: p] floatValue];
            [subproblemSolver param: p setValue: value];
        }
        
        [subproblemSolver solve];
        id<ORSolution> sol = [[subproblemSolver solutionPool] best];
        NSSet* subproblemVars = _split[probIdx];
        for(id<ORIntVar> x in [_model variables]) {
            if([_surrogateBranchVars member: x] && [subproblemVars member: x])
                [candidIncumbents setObject: @([sol intValue: x]) forKey: x];
        }
        ////////// End solve subproblem ///////////
        
        program = [ORFactory createMIPProgram: _model];
        [[program solver] close];
        for(id<ORRealParam> p in [_model parameters]) [program param: p setValue: [(NSNumber*)[lambdaValues objectForKey: p] floatValue]];
        id<ORParameterizedSolution> sol0 = [self runAllProblems: _model solver: program withIncumbents: candidIncumbents];
        
        if([[sol0 objectiveValue] doubleValue] < [[sol1 objectiveValue] doubleValue]) {
            allsol = sol0;
            [incumbents release];
            incumbents = candidIncumbents;
        }
        else {
            //allsol = sol1;
            [candidIncumbents release];
        }
    }
    NSLog(@"Done");
    return _bestSolution;
}

-(id<ORModel>) subproblemForPartition: (NSUInteger) splitIdx
{
    id<ORParameterizedModel> m = [ORFactory createParametricModel:_model relax:[_model constraints]];
    NSArray* cstrs = [self constraintsForPartition: splitIdx];
    NSSet* vars = [_split objectAtIndex: splitIdx];
    NSDictionary* scd = [self makeWeightedMap];
    for(id<ORConstraint> c in cstrs) {
        [m add: c];
        // Create the lambda map
        if([c conformsToProtocol: @protocol(ORSoftConstraint)]) {
            // Add problem index to lambda map
            id<ORSoftConstraint> softCstr = (id<ORSoftConstraint>)c;
           id<ORWeightedVar> wv = [scd objectForKey:@(getId([softCstr slack]))];
           assert(wv != nil);
            //id<ORWeightedVar> wv = [self weightedVarForSlack: [softCstr slack]];
            NSMutableArray* arr = [_lambdaMap objectForKey: [wv weight]];
            if(arr == nil) {
                arr = [[NSMutableArray alloc] initWithCapacity: 8];
                [_lambdaMap setObject: arr forKey: [wv weight]];
            }
            [arr addObject: @(splitIdx)];
            
            // Add lambda to model
            [m addParameter: [wv weight]];
        }
    }
    //for (id<ORParameter> p in [_model parameters]) [(ORParameterizedModelI*)m addParameter: p];
   [scd release];
    // Add objective
    if([[_model objective] conformsToProtocol: @protocol(ORObjectiveFunctionExpr)]) {
        id<ORExpr> objExpr = [(id<ORObjectiveFunctionExpr>)[_model objective] expr];
        ORTermCollector* collector = [[ORTermCollector alloc] init];
        NSArray* objTerms = [collector doIt: objExpr];
        [collector release];
        id<ORExpr> subproblemObj = [ORFactory sum: m over: RANGE(m, 0, (ORInt)objTerms.count-1)
                                         suchThat: ^ORBool(ORInt i) { return [vars intersectsSet: [objTerms[i] allVars]]; }
                                               of: ^id<ORExpr>(ORInt i) { return objTerms[i]; }];
        // FIX
        [m minimize: subproblemObj];
    }
    
    return m;
}

-(NSSet*) computeBranchVars {
    NSMutableSet* allvars = [[[NSMutableSet alloc] initWithCapacity: 256] autorelease];
    // Get slacks
    NSArray* softCstrs = [_model softConstraints];
    id<ORIntRange> slackRange = RANGE(_model, 0, (ORInt)softCstrs.count-1);
    id<ORIdArray> slacks = [ORFactory idArray: _model range: slackRange with: ^id(ORInt i) {
        id<ORSoftConstraint> c = [softCstrs objectAtIndex: i];
        return [c slack];
    }];
    for(id<ORVar> x in [_model variables]) {
        if([x conformsToProtocol: @protocol(ORIntVar)] && ![slacks contains: x])
            [allvars addObject: x];
    }
    return allvars;
}

-(id<ORWeightedVar>) weightedVarForSlack: (id<ORVar>)slack {
    for(id<ORConstraint> c in [_model constraints]) {
        if([c conformsToProtocol: @protocol(ORWeightedVar)]) {
            id<ORWeightedVar> wv = (id<ORWeightedVar>)c;
            if([wv x] == slack) return wv;
        }
    }
    return nil;
}

-(NSDictionary*)makeWeightedMap
{
   NSMutableDictionary* scd = [[NSMutableDictionary alloc] initWithCapacity:64];
   for(id<ORConstraint> c in [_model constraints]) {
      if ([c conformsToProtocol:@protocol(ORWeightedVar)]) {
         id<ORWeightedVar> wv = (id<ORWeightedVar>)c;
         id<ORVar> slack = [wv x];
         [scd setObject:wv forKey:@(getId(slack))];
      }
   }
   return scd;
}
-(NSArray*) constraintsForPartition: (NSUInteger) splitIdx {
   NSMutableSet* vars = [[_split objectAtIndex: splitIdx] mutableCopy];
   NSMutableSet* cstrs = [[NSMutableSet alloc] initWithCapacity: 16];
   NSDictionary* scd = [self makeWeightedMap];

   for(id<ORConstraint> c in [_model constraints]) {
      NSSet* cstrVars =[c allVars];
      if([cstrVars intersectsSet: vars]) {
         if([c conformsToProtocol: @protocol(ORSoftConstraint)]) {
            id<ORSoftConstraint> softCstr = (id<ORSoftConstraint>)c;
            id<ORWeightedVar> wv = [scd objectForKey:@(getId([softCstr slack]))];
            //id<ORWeightedVar> wv = [self weightedVarForSlack: [softCstr slack]];
            [cstrs addObject: wv];
            [vars addObject: [wv x]];
            [vars addObject: [wv z]];
            [cstrs addObject: softCstr];
         }
         else [cstrs addObject: c];
      }
   }
   [_split replaceObjectAtIndex: splitIdx withObject: vars];
   [scd release];
   return [cstrs allObjects];
}

-(void) run
{
    _bestSolution = (id<ORParameterizedSolution>)[self lagrangianSurrogateSolve];
}

@end

@implementation MIPSubgradient
-(id) solverForModel: (id<ORModel>)m {
    id<MIPProgram> program = [ORFactory createMIPProgram: _model];
    [program close];
    return program;
}

-(void) solveIt: (id)solver {
    id<MIPProgram> program = (id<MIPProgram>)solver;
    [program solve];
}
@end

@implementation CPSubgradient
-(id) initSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat) ub search: (void(^)(id<CPCommonProgram>))search {
    self = [super initSubgradient: m bound: ub];
    _search = [search copy];
    return self;
}

-(id) solverForModel: (id<ORModel>)m {
    id<CPProgram> program = [ORFactory createCPProgram: _model];
    return program;
}

-(void) solveIt: (id)solver {
    id<CPProgram> program = (id<CPProgram>)solver;
    NSLog(@"Solving...");
    [program solveOn: _search withTimeLimit: _subgradientTimeLimit];
}
@end

@implementation MIPSurrogate
-(id) solverForModel: (id<ORModel>)m {
    id<MIPProgram> program = [ORFactory createMIPProgram: _model];
    [program close];
    return program;
}

-(void) solveIt: (id)solver {
    id<MIPProgram> program = (id<MIPProgram>)solver;
    [program solve];
}
@end

@implementation ORFactory(ORLagrangeRelax)
+(id<ORLagrangeRelax>) MIPSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat)ub {
    return [[MIPSubgradient alloc] initSubgradient: m bound: ub];
}
+(id<ORLagrangeRelax>) CPSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat)ub search: (void(^)(id<CPCommonProgram>))search {
    return [[CPSubgradient alloc] initSubgradient: m bound: ub search: search];
}
+(id<ORLagrangeRelax>) MIPSurrogate: (id<ORParameterizedModel>)m bound: (ORFloat)ub {
    return [[MIPSurrogate alloc] initWithSurrogate: m bound: ub];
}
@end

