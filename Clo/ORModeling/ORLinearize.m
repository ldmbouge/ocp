//
//  ORLinearize.m
//  Clo
//
//  Created by Daniel Fontaine on 10/6/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <ORModeling/ORLinearize.h>
#import "ORModelI.h"

@interface ORLinearizeConstraint : NSObject<ORVisitor>
-(id)init:(ORModelI*)m;

-(id<ORIntVarArray>) binarizationForVar: (id<ORIntVar>)var;
-(ORRange) unionOfVarArrayRanges: (id<ORIntVarArray>)arr;

-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitBinPacking: (id<ORBinPacking>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitEqualc: (id<OREqualc>)c;
-(void) visitNEqualc: (id<ORNEqualc>)c;
-(void) visitLEqualc: (id<ORLEqualc>)c;
-(void) visitEqual: (id<OREqual>)c;
-(void) visitNEqual: (id<ORNEqual>)c;
-(void) visitLEqual: (id<ORLEqual>)c;
-(void) visitEqual3: (id<OREqual3>)c;
-(void) visitMult: (id<ORMult>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
@end

@implementation ORLinearize
-(id)initORLinearize
{
    self = [super init];
    return self;
}

-(id<ORModel>)apply:(id<ORModel>)m
{
    ORModelI* out = [ORFactory createModel];
    [m applyOnVar:^(id<ORVar> x) {
        [out captureVariable: x];
    } onObjects:^(id<ORObject> x) {
        NSLog(@"Got an object: %@",x);
    } onConstraints:^(id<ORConstraint> c) {
        ORLinearizeConstraint* lc = [[ORLinearizeConstraint alloc] init: out];
        [c visit: lc];
        [lc release];
    } onObjective:^(id<ORObjective> o) {
        NSLog(@"Got an objective: %@",o);
    }];
    return out;
}

@end

@implementation ORLinearizeConstraint {
    ORModelI* _model;
    NSMapTable* _binMap;
}
-(id)init:(ORModelI*)m;
{
    if((self = [super init]) != nil) {
        _model = m;
        _binMap = [[NSMapTable alloc] init];
    }
    return self;
}
-(ORRange) unionOfVarArrayDomains: (id<ORIntVarArray>)arr
{
    ORRange r;
    r.up = [ORFactory maxOver: [arr range] suchThat: nil of:^ORInt (ORInt e) {
        return [[(id<ORIntVar>)[arr at: e] domain] up];
    }];
    r.low = [ORFactory minOver: [arr range] suchThat: nil of:^ORInt (ORInt e) {
        return [[(id<ORIntVar>)[arr at: e] domain] low];
    }];
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
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
    ORRange dom = [self unionOfVarArrayDomains: [cstr array]];
    for (int d = dom.low; d <= dom.up; d++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [[cstr array] range]
                                   suchThat:^bool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[[cstr array] at: i];
                                       return [[var domain] inRange: d];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: [[cstr array] at: i]];
                                       return [binArr at: d];
                                   }];
        [_model add: [ORFactory expr: sumExpr equal: [ORFactory integer: _model value: 1]]];
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
        [_model add: [ORFactory expr: sumExpr leq: [ORFactory integer: _model value: [upArr at: u]]]];
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
        [_model add: [ORFactory expr: sumExpr geq: [ORFactory integer: _model value: [lowArr at: l]]]];
    }
}
-(void) visitBinPacking: (id<ORBinPacking>) cstr
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
        [_model add: [ORFactory expr: sumExpr leq: [binSize at: b]]];
    }
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
    
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
-(void) visitEqual3: (id<OREqual3>)c
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
-(void) visitElementCst: (id<ORElementCst>)c
{
}
-(void) visitElementVar: (id<ORElementVar>)c
{
}
@end
