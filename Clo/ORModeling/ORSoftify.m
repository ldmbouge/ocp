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
//    ORExprBinaryI* binexpr = (ORExprBinaryI*)[cstr expr];
//    id<ORExpr> slackExpr = [[binexpr right] sub: [binexpr left] track: _target];
//    id<ORVar> slack = nil;
//    if([binexpr vtype] == ORTInt) slack = [ORFactory intVar: _target domain: RANGE(_target, [slackExpr min], [slackExpr max])];
//    else if([binexpr vtype] == ORTFloat) slack = [ORFactory floatVar: _target low: [slackExpr min] up: [slackExpr max]];
//    else [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];
   
   ORExprBinaryI* binexpr = (ORExprBinaryI*)[cstr expr];
   id<ORExpr> slackExpr = [[binexpr right] sub: [binexpr left] track: _target];
   id<ORVar> slack = nil;
   if([binexpr vtype] == ORTInt) slack = [ORFactory intVar: _target domain: RANGE(_target, 0, [slackExpr max])];
   else if([binexpr vtype] == ORTFloat) slack = [ORFactory floatVar: _target low: 0 up: [slackExpr max]];
   else [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];
   
    id<ORRelation> softExpr = nil;
    softExpr = [slack geq: slackExpr track: _target];
//    switch([binexpr type]) {
//        case ORRLEq: softExpr = [[[binexpr left] sub: slack] leq: [binexpr right] track: _target]; break;
//        case ORRGEq: softExpr = [[[binexpr left] plus: slack] geq: [binexpr right] track: _target]; break;
//        case ORREq: softExpr = [[[binexpr left] plus: slack] eq: [binexpr right] track: _target]; break;
//        default: [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];
//    }
   
   //id<ORVar> slack2 = [ORFactory intVar: _target domain: RANGE(_target, 0, [slackExpr max])];
   //[_target add: [slack2 geq: slack]];
   
   id<ORSoftConstraint> softCstr = [[ORSoftAlgebraicConstraintI alloc]
                                     initORSoftAlgebraicConstraintI: softExpr
                                     slack: slack];
    [_target add: softCstr];
    //[_target add: [slack geq: slackExpr track: _target]];
    [[_target tau] set: softCstr forKey: cstr];
}

-(void) visitKnapsack:(id<ORKnapsack>)cstr
{
   id<ORIntRange> softRange = RANGE(_target, 0, [[[cstr item] range] up]);
   id<ORIntVarArray> softItems = [ORFactory intVarArray: _target range: softRange with: ^id<ORIntVar>(ORInt i) {
      if(i == 0) return [cstr capacity];
      else return [[cstr item] at: i - 1];
   }];
   
   id<ORIntArray> softWeight = [ORFactory intArray: _target range: softRange with: ^ORInt(ORInt i) {
      if(i == 0) return 1;
      else return -1 * [[cstr weight] at: i - 1];
   }];
   
   __block ORInt slackMin = 0;
   __block ORInt slackMax = 0;
   [softItems enumerateWith: ^(id x, int i) {
      slackMin += [(id<ORIntVar>)x min] * [softWeight at: i];
      slackMax += [(id<ORIntVar>)x max] * [softWeight at: i];
   }];
   
   id<ORIntVar> slack = [ORFactory intVar: _target domain: RANGE(_target, slackMin, slackMax)];
   id<ORSoftConstraint> knapsack = [ORFactory softKnapsack: softItems weight: softWeight capacity: slack slack: slack];
   [_target add: knapsack];
   [[_target tau] set: knapsack forKey: cstr];
   
   /*
   __block ORInt slackMin = 0;
   __block ORInt slackMax = 0;
   [[cstr item] enumerateWith: ^(id x, int i) {
      slackMin += [(id<ORIntVar>)x min] * [[cstr weight] at: i];
      slackMax += [(id<ORIntVar>)x max] * [[cstr weight] at: i];
   }];
   id<ORIntVar> slack = [ORFactory intVar: _target domain: RANGE(_target, [[cstr capacity] min] - slackMax, [[cstr capacity] max] - slackMin)];
   id<ORExpr> newRHS = [[cstr capacity] plus: slack track: _target];
   id<ORIntVar> newCap = [ORFactory intVar: _target domain: RANGE(_target, [[cstr capacity] min] + [slack min], [[cstr capacity] max] + [slack max])];
   id<ORSoftConstraint> knapsack = [ORFactory softKnapsack: [cstr item] weight: [cstr weight] capacity: newCap slack: slack];
   [_target add: knapsack];
   [_target add: [newCap eq: newRHS]];
   [[_target tau] set: knapsack forKey: cstr];
    */
}

@end
