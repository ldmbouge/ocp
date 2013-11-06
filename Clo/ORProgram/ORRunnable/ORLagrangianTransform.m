//
//  ORLagrangianTransform.m
//  Clo
//
//  Created by Daniel Fontaine on 10/17/13.
//
//

#import "ORLagrangianTransform.h"
#import "ORSoftify.h"
#import "ORConstraintI.h"
#import "ORModelI.h"

@implementation ORLagrangianTransform

-(id<ORParameterizedModel>) apply: (id<ORModel>)m relaxing: (NSArray*)cstrs
{
    ORSoftify* softify = [[ORSoftify alloc] initORSoftify];
    [softify apply: m toConstraints: cstrs];
    id<ORParameterizedModel> relaxedModel = [softify target];
    id<ORIntRange> slackRange = RANGE(relaxedModel, 0, (ORInt)cstrs.count-1);
    id<ORIdArray> slacks = [ORFactory idArray:  relaxedModel range: slackRange with: ^id(ORInt i) {
        id<ORSoftConstraint> c = [[relaxedModel tau] get: [cstrs objectAtIndex: i]];
        return [c slack];
    }];
    id<ORExpr> slackSum = [ORFactory sum: relaxedModel over: slackRange suchThat: nil of: ^id<ORExpr>(ORInt i) {
        id<ORFloatVar> s = [slacks at: i];
        id<ORWeightedVar> parameterization = [relaxedModel parameterizeFloatVar: s];
        return [parameterization z];
    }];
    id<ORExpr> prevObjective = [((id<ORObjectiveFunctionExpr>)[relaxedModel objective]) expr];
    [relaxedModel minimize: [prevObjective plus: slackSum track: relaxedModel]];
    [relaxedModel setSource: m];
    return relaxedModel;
}

@end
