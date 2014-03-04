//
//  ORSoftify.m
//  Clo
//
//  Created by Daniel Fontaine on 10/23/13.
//
//

#import "ORSoftify.h"
#import "ORModelI.h"
#import "ORExprI.h"
#import "ORConstraintI.h"

@implementation ORSoftify {
    id<ORParameterizedModel> _target;
}

-(ORSoftify*) initORSoftify
{
    self = [super init];
    _target = nil;
    return self;
}
-(void)apply:(id<ORModel>)m
{
    [self apply: m toConstraints: [m constraints]];
}
-(void)apply:(id<ORModel>)m toConstraints: (NSArray*)cstrs
{
    _target = [[ORParameterizedModelI alloc] initWithModel: (ORModelI*)m relax: cstrs];
    for(id<ORConstraint> c in cstrs)
        [c visit: self];
}
-(id<ORParameterizedModel>)target
{
    return _target;
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
    ORExprBinaryI* binexpr = (ORExprBinaryI*)[cstr expr];
    id<ORExpr> slackExpr = [[binexpr right] sub: [binexpr left] track: _target];
    id<ORVar> slack = nil;
    if([binexpr vtype] == ORTInt) slack = [ORFactory intVar: _target domain: RANGE(_target, [slackExpr min], [slackExpr max])];
    else if([binexpr vtype] == ORTFloat) slack = [ORFactory floatVar: _target low: [slackExpr min] up: [slackExpr max]];
    else [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];

    id<ORRelation> softExpr = nil;
    softExpr = [slack eq: slackExpr track: _target];
//    switch([binexpr type]) {
//        case ORRLEq: softExpr = [[[binexpr left] sub: slack] leq: [binexpr right] track: _target]; break;
//        case ORRGEq: softExpr = [[[binexpr left] plus: slack] geq: [binexpr right] track: _target]; break;
//        case ORREq: softExpr = [[[binexpr left] plus: slack] eq: [binexpr right] track: _target]; break;
//        default: [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];
//    }
    id<ORSoftConstraint> softCstr = [[ORSoftAlgebraicConstraintI alloc]
                                     initORSoftAlgebraicConstraintI: softExpr
                                     slack: slack];
    [_target add: softCstr];
    //[_target add: [slack geq: slackExpr track: _target]];
    [[_target tau] set: softCstr forKey: cstr];
}

-(void) visitKnapsack:(id<ORKnapsack>)cstr
{
   __block ORInt betaMax = 0;
   [[cstr item] enumerateWith: ^(id x, int i) { betaMax += [(id<ORIntVar>)x max] * [[cstr weight] at: i]; }];
   id<ORIntVar> alpha = [ORFactory intVar: _target domain: RANGE(_target, 0, [[cstr capacity] max])];
   id<ORIntVar> beta = [ORFactory intVar: _target domain: RANGE(_target, 0, betaMax)];
   id<ORIntVar> slack = [ORFactory intVar: _target domain: RANGE(_target, 0, [[cstr capacity] max] + betaMax)];
   id<ORExpr> newRHS = [[[cstr capacity] sub: alpha track: _target] plus: beta track: _target];
   id<ORIntVar> newCap = [ORFactory intVar: _target domain: RANGE(_target, [newRHS min], [newRHS max])];
   [_target add: [newCap eq: newRHS]];
   [_target add: [slack eq: [alpha plus: beta track: _target] track: _target]];
   id<ORSoftConstraint> knapsack = [ORFactory softKnapsack: [cstr item] weight: [cstr weight] capacity: newCap slack: slack];
   [_target add: knapsack];
   [[_target tau] set: knapsack forKey: cstr];
}

@end
