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
-(id)init:(ORModelI*)m varMap: (NSMapTable*) varMap;

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
    NSMapTable* varMap = [[NSMapTable alloc] init];
    [m applyOnVar:^(id<ORVar> x) {
        id<ORIntVarArray> arr = [ORFactory binarizeIntVar: (id<ORIntVar>)x tracker: out];
        [varMap setObject: arr forKey: x];
    } onObjects:^(id<ORObject> x) {
        NSLog(@"Got an object: %@",x);
    } onConstraints:^(id<ORConstraint> c) {
        ORLinearizeConstraint* lc = [[ORLinearizeConstraint alloc] init: out varMap: varMap];
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
    NSMapTable* _varMap;
}
-(id)init:(ORModelI*)m varMap: (NSMapTable*) varMap;
{
    if((self = [super init]) != nil) {
        _model = m;
        _varMap = varMap;
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
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
    ORRange dom = [self unionOfVarArrayDomains: [cstr array]];
    for (int d = dom.low; d <= dom.up; d++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [[cstr array] range]
                                   suchThat:^bool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[[cstr array] at: i];
                                       return [[var domain] inRange: d];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [_varMap objectForKey: [[cstr array] at: i]];
                                       return [binArr at: d];
                                   }];
        [_model add: [ORFactory expr: sumExpr equal: [ORFactory integer: _model value: 1]]];
    }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
}
-(void) visitBinPacking: (id<ORBinPacking>) cstr
{
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
