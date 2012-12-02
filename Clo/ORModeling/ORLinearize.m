//
//  ORLinearize.m
//  Clo
//
//  Created by Daniel Fontaine on 10/6/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <ORModeling/ORLinearize.h>
#import "ORModelI.h"
#import "ORSetI.h"

@interface ORLinearizeConstraint : NSObject<ORVisitor>
-(id)init:(id<ORINCModel>)m;

-(id<ORIntVarArray>) binarizationForVar: (id<ORIntVar>)var;
-(id<ORIntRange>) unionOfVarArrayRanges: (id<ORIntVarArray>)arr;
-(id<ORExpr>) linearizeExpr: (id<ORExpr>)expr;
@end

@implementation ORLinearize
-(id)initORLinearize
{
    self = [super init];
    return self;
}

-(void)apply:(id<ORModel>)m into:(id<ORINCModel>)batch
{
    [m applyOnVar:^(id<ORVar> x) {
        [batch addVariable: x];
    } onObjects:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
    } onConstraints:^(id<ORConstraint> c) {
        ORLinearizeConstraint* lc = [[ORLinearizeConstraint alloc] init: batch];
        [c visit: lc];
        [lc release];
    } onObjective:^(id<ORObjective> o) {
        //NSLog(@"Got an objective: %@",o);
    }];
}

@end

@implementation ORLinearizeConstraint {
    id<ORINCModel>  _model;
    NSMapTable*   _binMap;
    id<ORExpr> _exprResult;
}
-(id)init:(id<ORINCModel>)m;
{
    if((self = [super init]) != nil) {
        _model = m;
        _binMap = [[NSMapTable alloc] init];
        _exprResult = nil;
    }
    return self;
}
-(id<ORIntRange>) unionOfVarArrayRanges: (id<ORIntVarArray>)arr
{
    ORInt up = [ORFactory maxOver: [arr range] suchThat: nil of:^ORInt (ORInt e) {
        return [[(id<ORIntVar>)[arr at: e] domain] up];
    }];
    ORInt low = [ORFactory minOver: [arr range] suchThat: nil of:^ORInt (ORInt e) {
        return [[(id<ORIntVar>)[arr at: e] domain] low];
    }];
    id<ORIntRange> r = [[ORIntRangeI alloc] initORIntRangeI: low up: up];
    NSLog(@"LOW: %i", low);
    return r;
}
-(id<ORIntVarArray>) binarizationForVar: (id<ORIntVar>)var
{
    id<ORIntVarArray> binArr = [_binMap objectForKey: var];
    if(binArr == nil) {
        binArr = [ORFactory binarizeIntVar: var tracker: _model];
        [_binMap setObject: binArr forKey: var];
    }
    return binArr;
}
-(id<ORExpr>) linearizeExpr: (id<ORExpr>)expr {
    [expr visit: self];
    return _exprResult;
}
-(void) visitIntVar: (id<ORIntVar>) v  { _exprResult = v; }
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
    id<ORIntRange> dom = [self unionOfVarArrayRanges: [cstr array]];
    for (int d = [dom low]; d <= [dom up]; d++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [[cstr array] range]
                                   suchThat:^bool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[[cstr array] at: i];
                                       return [[var domain] inRange: d];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: [[cstr array] at: i]];
                                       return [binArr at: d];
                                   }];
        [_model addConstraint: [sumExpr eqi: 1]];
    }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
    // Constrain upper bounds
    id<ORIntArray> upArr = [cstr up];
    id<ORIntRange> ur = [upArr range];
    for (int u = ur.low; u <= ur.up; u++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [[cstr array] range]
                                   suchThat:^bool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[[cstr array] at: i];
                                       return [[var domain] inRange: u];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: [[cstr array] at: i]];
                                       return [binArr at: u];
                                   }];
        [_model addConstraint: [ORFactory expr: sumExpr leq: [ORFactory integer: _model value: [upArr at: u]]]];
    }
    
    // Constrain lower bounds
    id<ORIntArray> lowArr = [cstr low];
    id<ORIntRange> lr = [lowArr range];
    for (int l = lr.low; l <= lr.up; l++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [[cstr array] range]
                                   suchThat:^bool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[[cstr array] at: i];
                                       return [[var domain] inRange: l];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: [[cstr array] at: i]];
                                       return [binArr at: l];
                                   }];
        [_model addConstraint: [ORFactory expr: sumExpr geq: [ORFactory integer: _model value: [lowArr at: l]]]];
    }
}
-(void) visitPacking: (id<ORPacking>) cstr
{
    id<ORIntVarArray> item = [cstr item];
    id<ORIntVarArray> binSize = [cstr binSize];
    id<ORIntArray> itemSize = [cstr itemSize];
    id<ORIntRange> binRange = [binSize range];
    for(int b = [binRange low]; b < [binRange up]; b++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [item range]
                                   suchThat:^bool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[item at: i];
                                       return [[var domain] inRange: b];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: [item at: i]];
                                       id<ORInteger> size = [ORFactory integer: _model value: [itemSize at: i]];
                                       return [ORFactory expr: [binArr at: b] mul: size];
                                   }];
        [_model addConstraint: [ORFactory expr: sumExpr leq: [binSize at: b]]];
    }
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
    
    switch ([[cstr expr] type]) {
        case ORRBad: assert(NO);
        case ORREq: {
            ORExprBinaryI* binExpr = (ORExprBinaryI*)[cstr expr];
            id<ORExpr> left = [self linearizeExpr: [binExpr left]];
            id<ORExpr> right = [self linearizeExpr: [binExpr right]];
            [_model addConstraint: [left eq: right]];
        }break;
        case ORRNEq: {
            // Not implemented
        }break;
        case ORRLEq: {
            // Not implemented
        }break;
        default:
            assert(true);
            break;
    }
    
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
}
-(void) visitEqualc: (id<OREqualc>)c
{
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
}
-(void) visitEqual: (id<OREqual>)c
{
}
-(void) visitNEqual: (id<ORNEqual>)c
{
}
-(void) visitLEqual: (id<ORLEqual>)c
{
}
-(void) visitPlus: (id<ORPlus>)c
{
}
-(void) visitMult: (id<ORMult>)c
{
}
-(void) visitAbs: (id<ORAbs>)c
{
}
-(void) visitOr: (id<OROr>)c
{
}
-(void) visitAnd:( id<ORAnd>)c
{
}
-(void) visitImply: (id<ORImply>)c
{
}
-(void) visitElementCst: (id<ORElementCst>)c {
}
-(void) visitElementVar: (id<ORElementVar>)c
{
}
// Expressions
-(void) visitIntegerI: (id<ORInteger>) e  {
    _exprResult = e;
}

-(void) visitExprPlusI: (id<ORExpr>) e  {
    ORExprBinaryI* binExpr = (ORExprBinaryI*)e;
    id<ORExpr> left = [self linearizeExpr: [binExpr left]];
    id<ORExpr> right = [self linearizeExpr: [binExpr right]];
    _exprResult = [left plus: right];
}
-(void) visitExprMinusI: (id<ORExpr>) e  {
    ORExprBinaryI* binExpr = (ORExprBinaryI*)e;
    id<ORExpr> left = [self linearizeExpr: [binExpr left]];
    id<ORExpr> right = [self linearizeExpr: [binExpr right]];
    _exprResult = [left sub: right];
}
-(void) visitExprSumI: (id<ORExpr>) e  {
    ORExprSumI* sumExpr = (ORExprSumI*)e;
    [[sumExpr expr] visit: self];
}
-(void) visitExprCstSubI: (id<ORExpr>) e  {
    ORExprCstSubI* cstSubExpr = (ORExprCstSubI*)e;
    id<ORExprDomainEvaluator> domainEval = [[ORExprDomainEvaluatorI alloc] init];
    id<ORIntVar> indexVar;
    // Create the index variable if needed.
    if([[cstSubExpr index] conformsToProtocol: @protocol(ORIntVar)]) indexVar = (id<ORIntVar>)[cstSubExpr index];
    else {
        id<ORExpr> linearIndexExpr = [self linearizeExpr: [cstSubExpr index]];
        indexVar = [ORFactory intVar: _model domain: [domainEval domain: _model ForExpr: linearIndexExpr]];
        [_model addVariable: indexVar];
        [_model addConstraint: [indexVar eq: linearIndexExpr]];
    }
    id<ORIntVarArray> binIndexVar = [self binarizationForVar: indexVar];
    id<ORExpr> linearSumExpr = [ORFactory sum: _model over: [binIndexVar range] suchThat: nil of:^id<ORExpr>(ORInt i) {
        return [[binIndexVar at: i] muli: [[cstSubExpr array] at: i ]];
    }];
    id<ORIntVar> sumVar = [ORFactory intVar: _model domain: [domainEval domain: _model ForExpr: linearSumExpr]];
    [_model addVariable: sumVar];
    [_model addConstraint: [sumVar eq: linearSumExpr]];
    _exprResult = sumVar;
}
@end
