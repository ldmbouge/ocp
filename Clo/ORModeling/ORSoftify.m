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
    id<ORExpr> greaterExpr = nil;
    id<ORExpr> lessExpr = nil;
    switch([binexpr type]) {
        case ORRLEq:
            lessExpr = [binexpr left];
            greaterExpr = [binexpr right];
            break;
        case ORRGEq:
            lessExpr = [binexpr right];
            greaterExpr = [binexpr left];
            break;
        default: [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];
    }
    id<ORExpr> diffExpr = [greaterExpr sub: lessExpr track: _target];
    id<ORVar> slack = nil;
    if([binexpr vtype] == ORTInt)
        slack = [ORFactory intVar: _target domain: RANGE(_target, [diffExpr min], [diffExpr max])];
    else if([binexpr vtype] == ORTFloat)
        slack =[ORFactory floatVar: _target low: [diffExpr min] up: [diffExpr max]];
    else [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];
    id<ORRelation> softExpr = [[greaterExpr plus: slack track: _target] geq: lessExpr track: _target];
    id<ORSoftConstraint> softCstr = [[ORSoftAlgebraicConstraintI alloc]
                                     initORSoftAlgebraicConstraintI: softExpr
                                     slack: slack
                                     annotation: Default];
    [_target add: softCstr];
    [[_target tau] set: softCstr forKey: cstr];
}

@end
