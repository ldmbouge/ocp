//
//  ORLagrangeRelax.m
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import "ORLagrangeRelax.h"
#import "ORExprI.h"

@interface ORLagrangeRelax(Private)
-(id<ORModel>) lagrangianRelax: (id<ORModel>)m constraints: (NSArray*)cstrs;
@end

@implementation ORLagrangeRelax {
@protected
    id<ORModel> _srcModel;
    id<ORModel> _relaxModel;
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
        _sig = nil;
    }
    return self;
}

-(id<ORModel>) lagrangianRelax: (id<ORModel>)m constraints: (NSArray*)cstrs {
    id<ORModel> relaxation = [m relaxConstraints: cstrs];
    id<ORExpr> cstrsSum =
        [ORFactory sum: relaxation
                  over: [ORFactory intRange: relaxation low: 0 up: (ORInt)cstrs.count-1]
              suchThat: nil
                    of: ^id<ORExpr>(ORInt e) {
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
                            case ORREq: lambda = [ORFactory floatVar: relaxation low: -100 up: 100]; break;
                            default:
                                [NSException raise: NSGenericException format: @"ORLagrangianRelax: relaxed constraints not supported in Lagrangian Relaxation!"];
                                break;
                        }
                        ORExprBinaryI* binexpr = (ORExprBinaryI*)rel;
                        return [lambda mul: [[binexpr right] sub: [binexpr left] track: relaxation] track: relaxation];
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

-(void) run {
    
}

@end
