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
    @protected
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
    id<ORExpr> slackExpr = nil;
    if([[cstr expr] type] == ORRGEq || [[cstr expr] type] == ORREq) slackExpr = [[binexpr right] sub: [binexpr left] track: _target];
    else if([[cstr expr] type] == ORRLEq) slackExpr = [[binexpr left] sub: [binexpr right] track: _target];
    
    id<ORVar> slack = nil;
    if([binexpr vtype] == ORTInt) slack = [ORFactory intVar: _target domain: RANGE(_target, [slackExpr min], [slackExpr max])];
    else if([binexpr vtype] == ORTFloat) slack = [ORFactory floatVar: _target low: [slackExpr min] up: [slackExpr max]];
    else [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];
    
    id<ORRelation> softExpr = nil;
    softExpr = [slack eq: slackExpr track: _target];
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
}

@end

@implementation ORViolationSoftify

-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
    ORExprBinaryI* binexpr = (ORExprBinaryI*)[cstr expr];
    id<ORExpr> slackExpr = nil;
    if([[cstr expr] type] == ORRGEq || [[cstr expr] type] == ORREq) slackExpr = [[binexpr right] sub: [binexpr left] track: _target];
    else if([[cstr expr] type] == ORRLEq) slackExpr = [[binexpr left] sub: [binexpr right] track: _target];
    
    id<ORVar> slack = nil;
    if([binexpr vtype] == ORTInt) slack = [ORFactory intVar: _target domain: RANGE(_target, 0, [slackExpr max])];
    else if([binexpr vtype] == ORTFloat) slack = [ORFactory floatVar: _target low: 0 up: [slackExpr max]];
    else [NSException raise: @"ORSoftifyTransform" format: @"Invalid Algebraic Expr"];
    
    id<ORRelation> softExpr = nil;
    softExpr = [slack geq: slackExpr track: _target];
    id<ORSoftConstraint> softCstr = [[ORSoftAlgebraicConstraintI alloc]
                                     initORSoftAlgebraicConstraintI: softExpr
                                     slack: slack];
    [_target add: softCstr];
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
    
    __block ORInt slackMax = 0;
    [softItems enumerateWith: ^(id x, int i) {
        slackMax += [(id<ORIntVar>)x max] * [softWeight at: i];
    }];
    
    id<ORIntVar> slack = [ORFactory intVar: _target domain: RANGE(_target, 0, slackMax)];
    id<ORSoftConstraint> knapsack = [ORFactory softKnapsack: softItems weight: softWeight capacity: slack slack: slack];
    [_target add: knapsack];
    [[_target tau] set: knapsack forKey: cstr];
}

-(void) visitNEqual:(id<ORNEqual>)c {
    id<ORIntVar> slack = [ORFactory intVar: _target domain: RANGE(_target, 0, 1)];
    id<ORSoftConstraint> cstr = [ORFactory softNotEqual: _target var: [c left] to: [c right] plus: [c cst] slack: slack];
    [_target add: cstr];
    [[_target tau] set: cstr forKey: c];
}

@end
