//
//  ORLagrangeRelax.m
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import "ORLagrangeRelax.h"
#import "ORExprI.h"
#import "MIPRunnable.h"
#import "MIPSolverI.h"
#import "CPFactory.h"

@interface ORLagrangeRelax(Private)
-(id<ORSolution>) lagrangianSubgradientSolve: (ORFloat)ub;
@end

@implementation ORLagrangeRelax {
@protected
    id<ORParameterizedModel> _model;
    id<ORSolution> _bestSolution;
    id<ORSignature> _sig;
}

-(id) initWithModel: (id<ORParameterizedModel>)m
{
    self = [super init];
    if(self) {
        _model = m;
        _sig = nil;
        _bestSolution = nil;
    }
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
    
//    id<MIPProgram> program = [ORFactory createMIPProgram: _model];
    id<CPProgram> program = [ORFactory createCPProgram: _model];
    ORFloat cutoff = 0.005;
    
    ORInt noImproveLimit = 30;
    ORInt noImprove = 0;
    
    id<CPHeuristic> h = [program createABS];
    while(pi > cutoff) {
        [[program solutionPool] emptyPool];
//        [program solve];
        
        [program solve: ^{
            //[program labelHeuristic: h];
            [program labelHeuristic: h];
           NSLog(@"Got an improvement... %@",[[program objective] value]);
        } ];
       
        id<ORSolution> sol = [[program solutionPool] best];
        NSLog(@"BEST is: %@",sol);
        id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[sol objectiveValue];
        
        __block ORFloat slackSum = 0.0;
        [slacks enumerateWith:^(id<ORFloatVar> obj, ORInt idx) {
            slackSum += [sol floatValue: obj];
        }];
        
        ORFloat stepSize = pi * (ub - [objValue value]) / slackSum;
        
        [lambdas enumerateWith:^(id obj, ORInt idx) {
            id<ORFloatParam> lambda = obj;
            ORFloat value = [sol paramFloatValue: lambda];
            id<ORFloatVar> slack = [slacks at: idx];
            ORFloat newValue = MAX(0, value + stepSize * [sol floatValue: slack]);
            [program paramFloat: lambda setValue: newValue];
            NSLog(@"New lambda is: %lf",newValue);
        }];
        
        NSLog(@"objective: %f", [objValue value]);
        NSLog(@"slack: %f", slackSum);
        
        // Check for improvement
        if([objValue floatValue] > bestBound ||
            (fabs([objValue floatValue] - bestBound) < 1e-5 && slackSum < bestSlack)) {
            bestBound = [objValue floatValue];
            bestSol = sol;
            bestSlack = slackSum;
            noImprove = 0;
        }
        else if(++noImprove > noImproveLimit) {
            pi /= 2.0;
            noImprove = 0;
        }
        
        // Check if done
        NSLog(@"slack sum: %f", slackSum);
        if(fabs(slackSum) < 1.0e-5) break;
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
    _bestSolution = [self lagrangianSubgradientSolve: 80];
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
