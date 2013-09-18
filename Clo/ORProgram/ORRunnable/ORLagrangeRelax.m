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

@interface ORLagrangeRelax(Private)
-(void) lagrangianRelaxWithLambdas: (id<ORFloatArray>)lambda;
-(ORFloat) lagrangianProblemSolveWithUpperBound: (ORFloat)ub;
@end

@implementation ORLagrangeRelax {
@protected
    id<ORModel> _srcModel;
    id<ORModel> _relaxedModel;
    NSArray* _relaxedConstraints;
    NSMutableArray* _subgradients;
    ORFloat _bestBound;
    id<ORSignature> _sig;
}

-(id) initWithModel: (id<ORModel>)m
{
    return [self initWithModel: m relax: [m constraints]];
}

-(id) initWithModel: (id<ORModel>)m relax: (NSArray*)cstrs
{
    self = [super init];
    if(self) {
        _srcModel = m;
        _relaxedConstraints = cstrs;
        _relaxedModel = nil;
        _subgradients = nil;
        _sig = nil;
        _bestBound = DBL_MIN;
    }
    return self;
}

-(void) lagrangianRelaxWithLambdas: (id<ORFloatArray>)lambdas {
    _relaxedModel = [_srcModel relaxConstraints: _relaxedConstraints];
    _subgradients = [[NSMutableArray alloc] initWithCapacity: _relaxedConstraints.count];
    id<ORExpr> cstrsSum = [ORFactory sum: _relaxedModel over: [lambdas range] suchThat: nil of: ^id<ORExpr>(ORInt e) {
        id<ORConstraint> c = [_relaxedConstraints objectAtIndex: e];
        if(![c conformsToProtocol: @protocol(ORAlgebraicConstraint)])
            [NSException raise: NSGenericException format: @"ORLagrangianRelax: relaxed constraints must conform to ORAlgebraicConstraint!"];
        id<ORAlgebraicConstraint> a = (id<ORAlgebraicConstraint>)c;
        if(![[a expr] conformsToProtocol: @protocol(ORRelation)])
            [NSException raise: NSGenericException format: @"ORLagrangianRelax: relaxed constraints must conform to ORRelation!"];

        id<ORRelation> rel = (id<ORRelation>)[a expr];
        ORExprBinaryI* binexpr = (ORExprBinaryI*)rel;
        id<ORExpr> subgradient = nil;
        ORFloat lambda = [lambdas at: e];
        switch ([rel type]) {
            case ORRLEq: subgradient = [[[binexpr right] mul: @(-1) track: _relaxedModel] plus: [binexpr left] track: _relaxedModel]; break;
            case ORRGEq: subgradient = [[binexpr right] sub: [binexpr left] track: _relaxedModel]; break;
            default:
                [NSException raise: NSGenericException format: @"ORLagrangianRelax: relaxed constraints not supported in Lagrangian Relaxation!"];
                break;
        }
        ORFloat(^clo)(id<ORASolver>) = ^ORFloat(id<ORASolver> solver) { return [solver floatExprValue: subgradient]; };
        [_subgradients addObject: [clo copy]];
        return [subgradient mul: @(lambda) track: _relaxedModel];
    }];
    id<ORExpr> prevObjective = [((id<ORObjectiveFunctionExpr>)[_relaxedModel objective]) expr];
    [_relaxedModel minimize: [prevObjective plus: cstrsSum track: _relaxedModel]];
}

-(ORFloat) lagrangianProblemSolveWithUpperBound: (ORFloat)ub {
    ORFloat pi = 2.0f;
    ORFloat best = DBL_MIN;
    id<ORIntRange> lambdaRange = [ORFactory intRange: _srcModel low: 0 up: (ORInt)_relaxedConstraints.count-1];
    id<ORFloatArray> lambdaValues = [ORFactory floatArray: _srcModel range: lambdaRange value: 0.0];
    ORFloat cutoff = 0.005;
    
    ORInt noImproveLimit = 30;
    ORInt noImprove = 0;
    
    while(pi > cutoff) {
        [self lagrangianRelaxWithLambdas: lambdaValues];
        id<MIPRunnable> mip = (id<MIPRunnable>)[ORFactory MIPRunnable: _relaxedModel];
        [mip run];
        id<ORFloatArray> subgradientValues =
            [ORFactory floatArray: _relaxedModel range: lambdaRange with: ^ORFloat(ORInt e) {
                ORFloat(^clo)(id<ORASolver>)  = [_subgradients objectAtIndex: e];
                return clo([mip solver]);
            }];
        id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[[[[mip solver] solutionPool] best] objectiveValue];
        ORFloat stepSize = pi * (ub - [objValue value]) /
            [subgradientValues sumWith:^ORFloat(ORFloat x, int idx) { return x * x; }];
        [lambdaRange enumerateWithBlock: ^(ORInt i) {
            ORFloat lambda = [lambdaValues at: i];
            ORFloat newLambda = MAX(0, lambda + stepSize * [subgradientValues at: i]);
            [lambdaValues set: newLambda at: i];
        }];
        
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
        if(fabs(ub -[objValue value]) < 1.0e-5) break;
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
    return _srcModel;
}

-(void) run
{
    _bestBound = [self lagrangianProblemSolveWithUpperBound: 10];
}

-(ORFloat) bestBound { return _bestBound; }

@end
