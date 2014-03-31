//
//  ORLagrangeRelax.m
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import "ORLagrangeRelax.h"
#import "ORExprI.h"
#import "ORModelI.h"
#import "MIPRunnable.h"
#import "MIPProgram.h"
#import "MIPSolverI.h"
#import "CPFactory.h"
#import "ORConstraintI.h"
#import <ORFoundation/ORVisit.h>

@interface ORTermCollector : ORNOopVisit<NSObject> {
    NSMutableArray* _terms;
}
-(id)init;
-(NSArray*)doIt:(id<ORExpr>)e;
// Variables
-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
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
-(id)init
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
-(void) visitFloatVar: (id<ORFloatVar>) v
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


@interface ORLagrangeRelax(Private)
-(NSArray*) constraintsForPartition: (NSUInteger) splitIdx;
-(id<ORSolution>) lagrangianSubgradientSolve: (ORFloat)ub;
-(id<ORSolution>) lagrangianSurrogateSolve: (ORFloat)ub;
-(id<ORWeightedVar>) weightedVarForSlack: (id<ORVar>)slack;
@end

@implementation ORLagrangeRelax {
@protected
    id<ORParameterizedModel> _model;
    id<ORSolution> _bestSolution;
    id<ORSignature> _sig;
    
    // Surrogate
    BOOL _isSurrogate;
    NSMutableArray* _split;
    NSMutableSet* _surrogateBranchVars;
    NSMapTable* _lambdaMap;
}

-(id) initWithModel: (id<ORParameterizedModel>)m
{
    self = [super init];
    if(self) {
        _model = m;
        _sig = nil;
        _bestSolution = nil;
        _isSurrogate = NO;
        _split = nil;
    }
    return self;
}

-(id) initWithModel:(id<ORParameterizedModel>)m withSurrogateSplit: (NSArray*)split {
    self = [self initWithModel: m];
    _isSurrogate = YES;
    _split = [split mutableCopy];
    _surrogateBranchVars = [[NSMutableSet alloc] initWithCapacity: 256];
    for(NSSet* s in _split) [_surrogateBranchVars unionSet: s];
    _lambdaMap = [[NSMapTable alloc] init];
    return self;
}

-(id<ORSolution>) lagrangianSubgradientSolve: (ORFloat)ub {
    ORFloat pi = 2.0f;
    ORFloat bestBound = -DBL_MAX;
    ORFloat bestSlack = DBL_MAX;
    id<ORSolution> bestSol = nil;
    
    NSArray* softCstrs = [_model softConstraints];
    id<ORIntRange> slackRange = RANGE(_model, 0, (ORInt)softCstrs.count-1);
    id<ORIdArray> slacks = [ORFactory idArray: _model range: slackRange with: ^id(ORInt i) {
        id<ORSoftConstraint> c = [softCstrs objectAtIndex: i];
        return [c slack];
    }];
    
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
    
    id<MIPProgram> program = [ORFactory createMIPProgram: _model];
    [program close];
//    id<CPProgram> program = [ORFactory createCPProgram: _model];
//    id<CPHeuristic> h = [program createFF];
    
    ORFloat cutoff = 0.005;
    ORInt noImproveLimit = 3;//30;
    ORInt noImprove = 0;
    ORFloat timeLimit = 2.0;
    
    while(pi > cutoff) {
        [[program solutionPool] emptyPool];
        [program setTimeLimit: timeLimit];
        [program solve];
        
//        [program solve: ^{
//            [program labelHeuristic: h];
//            NSLog(@"Got an improvement... %@",[[program objective] value]);
//        } ];

        id<ORSolution> sol = [[program solutionPool] best];
        NSLog(@"BEST is: %@",sol);
        id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[sol objectiveValue];
        ORFloat bound = [program bestObjectiveBound];
        
        __block ORFloat slackSum = 0.0;
        [slacks enumerateWith:^(id<ORFloatVar> obj, ORInt idx) {
            double s = [sol floatValue: obj];
            slackSum += s * s;
        }];
        
        ORFloat stepSize = pi * (ub - [objValue value]) / slackSum;
        
        [lambdas enumerateWith:^(id obj, ORInt idx) {
            id<ORFloatParam> lambda = obj;
            ORFloat value = [sol paramFloatValue: lambda];
            id<ORFloatVar> slack = [slacks at: idx];
            ORFloat newValue = MAX(0, value + stepSize * [sol floatValue: slack]);
            [program paramFloat: lambda setValue: newValue];
            NSLog(@"New lambda is[%i]: %lf", idx, newValue);
        }];
        
        NSLog(@"objective: %f", [objValue value]);
        NSLog(@"slack: %f", slackSum);
        
        // Check for improvement
        NSLog(@"obj: %@, %f", objValue, bestBound);
        if(bound > bestBound) {//if([objValue floatValue] > bestBound) {
            bestBound = bound;//[objValue floatValue];
            bestSol = sol;
            bestSlack = slackSum;
            noImprove = 0;
            //if(timeLimit > 2) timeLimit /= 2;
        }
        else if(++noImprove > noImproveLimit) {
            pi /= 2.0;
            noImprove = 0;
        }
        else {
            timeLimit *= 2;
        }
        
        // Check if done
        NSLog(@"slack sum: %f", slackSum);
        if(fabs(slackSum) < 1.0e-3) break;
    }
    return bestSol;
}

-(NSSet*) updateLambdas: (id<ORIdArray>) lambdas
                  values: (NSMapTable*)values
              withSlacks: (id<ORIdArray>)slacks
             solution: (id<ORSolution>)sol
                bound: (ORFloat)bound
                   pi: (ORFloat)pi {
    NSMutableSet* modifiedProblems = [[NSMutableSet alloc] init];
    __block ORFloat slackSum = 0.0;
    [slacks enumerateWith:^(id<ORFloatVar> obj, ORInt idx) {
        double val = [sol floatValue: obj];
        slackSum += val * val;
        NSLog(@"slack: %f", [sol floatValue: obj]);
    }];
    
    id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[sol objectiveValue];
    ORFloat stepSize = pi * (bound - [objValue value]) / slackSum;
    
    [lambdas enumerateWith:^(id obj, ORInt idx) {
        id<ORFloatParam> lambda = obj;
        ORFloat value = [sol paramFloatValue: lambda];
        if(value != DBL_MAX) {
            id<ORFloatVar> slack = [slacks at: idx];
            ORFloat newValue = MAX(0, value + stepSize * [sol floatValue: slack]);
            
            if(newValue != value) {
                [values setObject: @(newValue) forKey: lambda];
                NSLog(@"New lambda[%i]: %lf -- pi: %f slack: %f, obj: %f", idx, newValue, pi, slackSum, [objValue floatValue]);
                NSArray* lambdaProbs = [_lambdaMap objectForKey: obj];
                if(lambdaProbs != nil) [modifiedProblems addObjectsFromArray: lambdaProbs];
            }
        }
    }];
    return modifiedProblems;
}

-(id<ORSolution>) runAllProblems: (id<ORParameterizedModel>)m solver: (id<MIPProgram>)program withIncumbents: (NSMapTable*)incumbents {
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
    id<ORSolution> sol = [[program solutionPool] best];
    id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[sol objectiveValue];
    NSLog(@"objective: %f", [objValue value]);
    return sol;
}

-(id<ORSolution>) lagrangianSurrogateSolve: (ORFloat)ub {
    NSMapTable* incumbents = [[NSMapTable alloc] init];
    NSMapTable* lambdaValues = [[NSMapTable alloc] init];
    
    // Build Subproblems
    ORInt subprobCount = (ORInt)_split.count;
    NSMutableArray* subproblems = [[NSMutableArray alloc] initWithCapacity: subprobCount];
    for(NSUInteger i = 0; i < _split.count; i++) {
        id<ORModel> m = [self subproblemForPartition: i];
        [subproblems addObject: m];
    }
    
    ORFloat bestSlackSum = DBL_MAX;
    ORFloat pi = 1.0f;
    ORFloat bestBound = -DBL_MAX;
    ORFloat bestSlack = DBL_MAX;
    id<ORSolution> bestSol = nil;

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
    for(id<ORFloatParam> p in [_model parameters]) [lambdaValues setObject: @([p initialValue]) forKey: p];
    
    // Step 0: solve all subproblems
    id<MIPProgram> program = [ORFactory createMIPProgram: _model];
    id<ORSolution> allsol = [self runAllProblems: _model solver: program withIncumbents: incumbents];
    for(id<ORIntVar> x in _surrogateBranchVars) [incumbents setObject: @([allsol intValue: x]) forKey: x];
    
    ORFloat cutoff = 0.005;
    ORInt noImproveLimit = 10;
    ORInt noImprove = 0;
    //NSMutableArray* subprobQueue = [[NSMutableArray alloc] init];
    id<ORParameterizedModel> subproblem = nil;
    
    while(1) {
        
        // Step 1: update lambdas, lambda^(k+1), x^k
        NSSet* probIndexes = [self updateLambdas: lambdas values: lambdaValues withSlacks: slacks solution: allsol bound: ub pi: pi];
        //for(NSNumber* idx in probIndexes)
        //    if(![subprobQueue containsObject: idx]) [subprobQueue addObject: idx];
        
        id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[allsol objectiveValue];
        if([objValue floatValue] > bestBound) {
            bestBound = [objValue floatValue];
            bestSol = allsol;
            noImprove = 0;
        }
        else if(++noImprove > noImproveLimit) {
            pi /= 2.0;
            noImprove = 0;
        }
        
        program = [ORFactory createMIPProgram: _model];
        [[program solver] close];
        for(id<ORFloatParam> p in [_model parameters]) [program paramFloat: p setValue: [(NSNumber*)[lambdaValues objectForKey: p] floatValue]];
        id<ORSolution> sol1 = [self runAllProblems: _model solver: program withIncumbents: incumbents];
        
        // Step 2: solve subproblem
        NSMapTable* candidIncumbents = [incumbents copy];
        
        ////////// Solve subproblem ///////////
        int r = arc4random() % [probIndexes count];
        NSNumber* n = [[probIndexes allObjects] objectAtIndex: r];
        //[subprobQueue removeObjectAtIndex: 0];
        int probIdx = [n intValue];//[[[probIndexes allObjects] objectAtIndex: r] intValue];
        
        subproblem = [subproblems objectAtIndex: probIdx];
        id<MIPProgram> subproblemSolver = [ORFactory createMIPProgram: subproblem];
        [[subproblemSolver solver] close];
        
        for(id<ORVar> x in [subproblem variables]) {
            NSSet* vset = [_split objectAtIndex: probIdx];
            if(![vset member: x]) {
                if([x vtype] == ORTInt)
                    [subproblemSolver setIntVar: (id<ORIntVar>)x value: [[candidIncumbents objectForKey: x] intValue]];
            }
        }
        for(id<ORFloatParam> p in [subproblem parameters]) {
            ORFloat value = [(NSNumber*)[lambdaValues objectForKey: p] floatValue];
            [subproblemSolver paramFloat: p setValue: value];
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
        for(id<ORFloatParam> p in [_model parameters]) [program paramFloat: p setValue: [(NSNumber*)[lambdaValues objectForKey: p] floatValue]];
        id<ORSolution> sol0 = [self runAllProblems: _model solver: program withIncumbents: candidIncumbents];
        
        if([[sol0 objectiveValue] floatValue] < [[sol1 objectiveValue] floatValue]) {
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
    return bestSol;
}

-(id<ORModel>) subproblemForPartition: (NSUInteger) splitIdx {
    id<ORParameterizedModel> m = [[ORParameterizedModelI alloc] initWithModel: (ORModelI*)_model relax: [_model constraints]];
    NSArray* cstrs = [self constraintsForPartition: splitIdx];
    NSSet* vars = [_split objectAtIndex: splitIdx];
    for(id<ORConstraint> c in cstrs) {
        [m add: c];
        // Create the lambda map
        if([c conformsToProtocol: @protocol(ORSoftConstraint)]) {
            // Add problem index to lambda map
            ORSoftAlgebraicConstraintI* softCstr = (ORSoftAlgebraicConstraintI*)c;
            id<ORWeightedVar> wv = [self weightedVarForSlack: [softCstr slack]];
            NSMutableArray* arr = [_lambdaMap objectForKey: [wv weight]];
            if(arr == nil) {
                arr = [[NSMutableArray alloc] initWithCapacity: 8];
                [_lambdaMap setObject: arr forKey: [wv weight]];
            }
            [arr addObject: @(splitIdx)];
            
            // Add lambda to model
            [(ORParameterizedModelI*)m addParameter: [wv weight]];
        }
    }
    //for (id<ORParameter> p in [_model parameters]) [(ORParameterizedModelI*)m addParameter: p];
    
    // Add objective
    if([[_model objective] conformsToProtocol: @protocol(ORObjectiveFunctionExpr)]) {
        id<ORExpr> objExpr = [(id<ORObjectiveFunctionExpr>)[_model objective] expr];
        ORTermCollector* collector = [[ORTermCollector alloc] init];
        NSArray* objTerms = [collector doIt: objExpr];
        [collector release];
        id<ORExpr> subproblemObj = [ORFactory sum: m over: RANGE(m, 0, (ORInt)objTerms.count-1)
                                         suchThat: ^bool(ORInt i) { return [vars intersectsSet: [objTerms[i] allVars]]; }
                                               of: ^id<ORExpr>(ORInt i) { return objTerms[i]; }];
        // FIX
        [m minimize: subproblemObj];
    }
    
    return m;
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

-(NSArray*) constraintsForPartition: (NSUInteger) splitIdx {
    NSMutableSet* vars = [[_split objectAtIndex: splitIdx] mutableCopy];
    NSMutableSet* cstrs = [[NSMutableSet alloc] initWithCapacity: 16];
    for(id<ORConstraint> c in [_model constraints]) {
        NSSet* cstrVars =[c allVars];
        if([cstrVars intersectsSet: vars]) {
            if([c conformsToProtocol: @protocol(ORSoftConstraint)]) {
                ORSoftAlgebraicConstraintI* softCstr = (ORSoftAlgebraicConstraintI*)c;
                id<ORWeightedVar> wv = [self weightedVarForSlack: [softCstr slack]];
                [cstrs addObject: wv];
                [vars addObject: [wv x]];
                [vars addObject: [wv z]];
                [cstrs addObject: softCstr];
            }
            else [cstrs addObject: c];
        }
    }
    [_split replaceObjectAtIndex: splitIdx withObject: vars];
    return [cstrs allObjects];
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
    int bound = 635;
    _bestSolution = _isSurrogate ? [self lagrangianSurrogateSolve: bound]  : [self lagrangianSubgradientSolve: bound];
}

-(ORFloat) bestBound
{
    if(!_bestSolution) return DBL_MIN;
    id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[_bestSolution objectiveValue];
    return [objValue floatValue];
}

-(id<ORSolution>) bestSolution
{
    return _bestSolution;
}

@end
