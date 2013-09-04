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
-(id<ORModel>) lagrangianRelax: (id<ORModel>)m constraints: (NSArray*)cstrs;
-(void) subgradientSolve: (ORInt)ub;
@end

@implementation ORLagrangeRelax {
@protected
    id<ORModel> _srcModel;
    id<ORModel> _relaxModel;
    NSArray* _relaxedConstraints;
    id<ORFloatVarArray> _lambdas;
    id<ORIdArray> _subgradients;
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
        _relaxModel = [self lagrangianRelax: m constraints: cstrs];
        _relaxedConstraints = cstrs;
        _sig = nil;
    }
    return self;
}

-(id<ORModel>) lagrangianRelax: (id<ORModel>)m constraints: (NSArray*)cstrs {
    id<ORModel> relaxation = [m relaxConstraints: cstrs];
    id<ORIntRange> lambdasRange = RANGE(relaxation, 0, (ORInt)cstrs.count-1);
    _lambdas = [ORFactory floatVarArray: relaxation range: lambdasRange];
    _subgradients = [ORFactory idArray: relaxation range: lambdasRange];
    
    id<ORExpr> cstrsSum =
        [ORFactory sum: relaxation over: lambdasRange suchThat: nil of: ^id<ORExpr>(ORInt e) {
            id<ORConstraint> c = [cstrs objectAtIndex: e];
            if(![c conformsToProtocol: @protocol(ORAlgebraicConstraint)])
                [NSException raise: NSGenericException format: @"ORLagrangianRelax: relaxed constraints must conform to ORAlgebraicConstraint!"];
            id<ORAlgebraicConstraint> a = (id<ORAlgebraicConstraint>)c;
            if(![[a expr] conformsToProtocol: @protocol(ORRelation)])
                [NSException raise: NSGenericException format: @"ORLagrangianRelax: relaxed constraints must conform to ORRelation!"];
            id<ORRelation> rel = (id<ORRelation>)[a expr];
            id<ORFloatVar> lambda = nil;
            switch ([rel type]) {
                case ORRLEq: lambda = [ORFactory floatVar: relaxation low: -100 up: 0]; break;
                case ORRGEq: lambda = [ORFactory floatVar: relaxation low: 0 up: 100]; break;
                case ORREq: lambda = [ORFactory floatVar: relaxation low: -100 up: 100]; break;
                default:
                    [NSException raise: NSGenericException format: @"ORLagrangianRelax: relaxed constraints not supported in Lagrangian Relaxation!"];
                    break;
            }
            [_lambdas set: lambda at: e];
            ORExprBinaryI* binexpr = (ORExprBinaryI*)rel;
            id<ORExpr> subgradient = [[binexpr right] sub: [binexpr left] track: relaxation];
            [_subgradients set: subgradient at: e];
            return [lambda mul: subgradient track: relaxation];
        }];
    id<ORExpr> prevObjective = [((id<ORObjectiveFunctionExpr>)[relaxation objective]) expr];
    id<ORFloatVar> objective = [ORFactory floatVar: relaxation low: -10000 up: 10000];
    [relaxation add: [objective geq: [prevObjective plus: cstrsSum track: relaxation]]];
    [relaxation minimize: objective];
    return relaxation;
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
    return _relaxModel;
}

-(void) run
{
    id<ORExpr> srcObjective = [((id<ORObjectiveFunctionExpr>)[_srcModel objective]) expr];
    [self subgradientSolve: [srcObjective max]];
}

-(void) subgradientSolve: (ORInt)ub
{
    /*
    ORFloat pi = 2.0f;
    ORFloat best = DBL_MIN;
    ORFloat lambdaValues[_relaxedConstraints.count];
    for(ORInt i = 0; i < _relaxedConstraints.count; i++) lambdaValues[i] = 0.0;
    ORFloat cutoff = 0.005;
    
    while(pi > cutoff) {
        id<MIPRunnable> mip = (id<MIPRunnable>)[ORFactory MIPRunnable: _relaxModel];
        MIPSolverI* solver = [[mip solver] solver];
        // Fix lambdas
        for(ORInt i = 0; i < _relaxedConstraints.count; i++) {
            MIPVariableI* v = [solver ]
            [solver updateLowerBound: lb:<#(ORFloat)#>]
        }
    }
    */
}


@end
