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
-(ORFloat) lagrangianSubgradientSolve: (ORFloat)ub;
@end

@implementation ORLagrangeRelax {
@protected
    id<ORParameterizedModel> _model;
    ORFloat _bestBound;
    id<ORSignature> _sig;
}

-(id) initWithModel: (id<ORParameterizedModel>)m
{
    self = [super init];
    if(self) {
        _model = m;
        _sig = nil;
        _bestBound = DBL_MIN;
    }
    return self;
}

-(ORFloat) lagrangianSubgradientSolve: (ORFloat)ub {
    ORFloat pi = 2.0f;
    ORFloat best = DBL_MIN;

    NSArray* softCstrs = [_model softConstraints];
    id<ORIntRange> slackRange = RANGE(_model, 0, (ORInt)softCstrs.count-1);
    id<ORIdArray> slacks = [ORFactory idArray: _model range: slackRange with: ^id(ORInt i) {
        id<ORSoftConstraint> c = [softCstrs objectAtIndex: i];
        return [c slack];
    }];
    id<ORIdArray> lambdas = [ORFactory idArray: _model range: slackRange with: ^id(ORInt i) {
        id<ORVar> slack = [slacks at: i];
        id<ORWeightedVar> w = [_model parameterization: slack];
        return [w weight];
    }];
    
    //id<MIPProgram> program = [ORFactory createMIPProgram: _model];
    id<CPProgram> program = [ORFactory createCPProgram: _model];
    ORFloat cutoff = 0.005;
    
    ORInt noImproveLimit = 30;
    ORInt noImprove = 0;
    
    while(pi > cutoff) {
        [[program solutionPool] emptyPool];
        //[program solve];
        //id<CPHeuristic> h = [program createFF];
        [program solve: ^{
            //[program labelHeuristic: h];
            [program labelArray:[_model intVars]];
        } ];
        id<ORSolution> bs = [[program solutionPool] best];
        NSLog(@"BEST is: %@",bs);
        id<ORSolution> sol = [[program solutionPool] best];
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
        }];
        
        NSLog(@"objective: %f", [objValue value]);
        
        // Check for improvement
        if([objValue value] > best) {
            best = [objValue value];
            noImprove = 0;
        }
        else if(++noImprove > noImproveLimit) {
            pi /= 2.0;
            noImprove = 0;
        }
        
        // Check if done
        if(fabs(slackSum) < 1.0e-5) break;
    }
    return best;
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
    _bestBound = [self lagrangianSubgradientSolve: 10];
}

-(ORFloat) bestBound { return _bestBound; }

@end
