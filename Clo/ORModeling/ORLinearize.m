/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORLinearize.h>
#import <ORFoundation/ORSetI.h>
#import "ORModelI.h"
#import "ORExprI.h"
#import "ORVarI.h"
#import <ORFoundation/ORVisit.h>

@implementation ORLinearize {
    id<ORAddToModel> _into;
}
-(id)initORLinearize:(id<ORAddToModel>)into
{
    self = [super init];
    _into = into;
    return self;
}

+(id<ORModel>) linearize:(id<ORModel>)model
{
    id<ORModel> lin = [ORFactory createModel];
    ORBatchModel* lm = [[ORBatchModel alloc] init: lin source:model annotation:nil];
    id<ORModelTransformation> linearizer = [[ORLinearize alloc] initORLinearize :lm];
    [linearizer apply: model with:nil]; //TOFIX
    return lin;
}

-(void)apply:(id<ORModel>)m with:(id<ORAnnotation>)notes
{
    ORLinearizeConstraint* lc = [[ORLinearizeConstraint alloc] init: _into];
    [m applyOnVar:^(id<ORVar> x) {
        [x visit: lc];
    } onMutables:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
        if([x conformsToProtocol: @protocol(ORIdArray)])
            [x visit: lc];
        //else [_into addMutable: x];
    } onImmutables:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
        [_into addImmutable: x];
    } onConstraints:^(id<ORConstraint> c) {
        [c visit: lc];
    } onObjective:^(id<ORObjectiveFunction> o) {
        ORLinearizeObjective* lo = [[ORLinearizeObjective alloc] init: _into];
        [o visit: lo];
    }];
    [lc release];
}

@end

@implementation ORLinearizeConstraint
-(id)init:(id<ORAddToModel>) m;
{
    if ((self = [super init]) != nil) {
        _model = m;
        _binMap = [[NSMapTable alloc] init];
        _exprResult = nil;
    }
    return self;
}
-(id<ORIntRange>) unionOfVarArrayRanges: (id<ORExprArray>)arr
{
    ORInt up = [ORFactory maxOver: [arr range] suchThat: nil of:^ORInt (ORInt e) {
        return [[(id<ORIntVar>)[arr at: e] domain] up];
    }];
    ORInt low = [ORFactory minOver: [arr range] suchThat: nil of:^ORInt (ORInt e) {
        return [[(id<ORIntVar>)[arr at: e] domain] low];
    }];
    id<ORIntRange> r = [[ORIntRangeI alloc] initORIntRangeI: low up: up];
    return r;
}
-(id<ORIntVarArray>) binarizeIntVar:(id<ORIntVar>)x
{
    id<ORIntVarArray> o = [ORFactory intVarArray:_model range:[x domain] with:^id<ORIntVar>(ORInt i) {
        return [ORFactory intVar:_model domain:RANGE(_model,0,1)];
    }];
    id<ORExpr> sumBinVars = Sum(_model, i,[x domain], [o at: i]);
    id<ORExpr> sumExpr    = Sum(_model, i,[x domain], [[o at: i] mul: @(i)]);
    [_model addConstraint: [sumBinVars eq: @(1)]];
    [_model addConstraint: [sumExpr eq: x]];
    //[[[_model modelMappings] tau] set: o forKey: x];
    return o;
}
-(id<ORIntVarArray>) binarizationForVar: (id<ORIntVar>)var
{
    id<ORIntVarArray> binArr = [_binMap objectForKey: var];
    if(binArr == nil) {
        binArr = [self binarizeIntVar: var];
        [_binMap setObject: binArr forKey: var];
    }
    return binArr;
}
-(id<ORExpr>) linearizeExpr: (id<ORExpr>)expr
{
    _exprResult = nil;
    [expr visit: self];
    return _exprResult;
}
-(void) visitIdArray:(id<ORIdArray>)v {
    id<ORIdArray> dv = [[[_model modelMappings] tau] get: v];
    if(dv == nil) {
        dv = [v map: ^id(id obj, int idx) { return [[[_model modelMappings] tau] get: obj]; }];
        //assert([dv at: [[dv range] low]] != nil); DAN
        [_model trackMutable: dv];
        [[[_model modelMappings] tau] set: dv forKey: v];
        [_model addMutable: dv];
        return;
    }
}
-(void) visitIntVar: (id<ORIntVar>) v  {
    id<ORIntVar> dv = [[[_model modelMappings] tau] get: v];
    if(dv == nil) {
        [[[_model modelMappings] tau] set: v forKey: v];
        [_model addVariable: v];
        return;
    }
    _exprResult = dv;
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v {
    id<ORIntVar> dv = [[[_model modelMappings] tau] get: v];
    if(dv == nil) {
        ORIntVarLitEQView* view = (ORIntVarLitEQView*)v;
        if([[[v base] domain] inRange: [view literal]]) {
            id<ORIntVarArray> bv = [self binarizationForVar: [v base]];
            [[[_model modelMappings] tau] set: [bv at: [view literal]] forKey: v];
        }
        else assert(false);
        return;
    }
    _exprResult = dv;
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
    // [ldm] this code needs to be revised if the input is an array of expressions.
    id<ORIntVarArray> varsOfC = (id) [cstr array];
    id<ORIntRange> dom = [self unionOfVarArrayRanges: varsOfC];
    for (int d = [dom low]; d <= [dom up]; d++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [varsOfC range]
                                   suchThat:^ORBool(ORInt i) {
                                       return [[varsOfC[i] domain] inRange: d];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: varsOfC[i]];
                                       return binArr[d];
                                   }];
        [_model addConstraint: [sumExpr eq: @(1)]];
    }
}
-(void) visitRegular:(id<ORRegular>) cstr
{
    assert(NO);
}
-(void) visitMultiKnapsack:(id<ORMultiKnapsack>) cstr
{
    assert(NO);
}
-(void) visitMultiKnapsackOne:(id<ORMultiKnapsackOne>) cstr
{
    assert(NO);
}
-(void) visitMeetAtmost:(id<ORMeetAtmost>) cstr
{
    assert(NO);
}
-(void) visitMax:(id<ORMax>)c
{
   id<ORIntVar> x0 = (id<ORIntVar>)[ self linearizeExpr: [c left]];
   id<ORIntVar> x1 = (id<ORIntVar>)[ self linearizeExpr: [c right]];
   id<ORIntVar> y  = (id<ORIntVar>)[ self linearizeExpr: [c res]];
   id<ORIntVar> d0 = [ORFactory boolVar:_model];
   id<ORIntVar> d1 = [ORFactory boolVar:_model];
   ORInt Umax = max(x0.up, x1.up);
   [_model addConstraint:[[d0 plus: d1] eq: @(1)]];
   [_model addConstraint:[y geq: x0]];
   [_model addConstraint:[y geq: x1]];
   [_model addConstraint:[y leq: [x0 plus: [[@(1) sub: d0] mul: @(Umax - x0.low)]]]];
   [_model addConstraint:[y leq: [x1 plus: [[@(1) sub: d1] mul: @(Umax - x1.low)]]]];
}

-(void) visitBinImply: (id<ORBinImply>)c
{
    id<ORIntVar> x0 = (id<ORIntVar>)[ self linearizeExpr: [c left]];
    id<ORIntVar> x1 = (id<ORIntVar>)[ self linearizeExpr: [c right]];
    [_model addConstraint: [x1 geq: x0]];
}
-(void) visitPlus: (id<ORPlus>)c
{
   id<ORIntVar> x0 = (id<ORIntVar>)[ self linearizeExpr: [c left]];
   id<ORIntVar> x1 = (id<ORIntVar>)[ self linearizeExpr: [c right]];
   id<ORIntVar> x2 = (id<ORIntVar>)[ self linearizeExpr: [c res]];
   [_model addConstraint:[x2 eq: [x0 plus:x1]]];
}

-(void) visitMult: (id<ORMult>)c
{   
    id<ORIntVar> x0 = (id<ORIntVar>)[ self linearizeExpr: [c left]];
    id<ORIntRange> d0 = [x0 domain];
    id<ORIntVar> x1 = (id<ORIntVar>)[ self linearizeExpr: [c right]];
    id<ORIntRange> d1 = [x1 domain];
    id<ORIntVar> z = (id<ORIntVar>)[ self linearizeExpr: [c res]];
    if (d0.isBool && d1.isBool) {     // Both Binary
        [_model addConstraint: [z leq: x0]];
        [_model addConstraint: [z leq: x1]];
        [_model addConstraint: [z geq: [[x0 plus: x1] sub: @(1)]]];
    }
    else if (d0.isBool || d1.isBool) {     // x1 or x0 binary
       ORBool d0b = d0.isBool;
       id<ORIntVar> x = d0b ? x1 : x0;
       id<ORIntVar> b = d0b ? x0 : x1;
       ORInt L = x.low, U = x.up;
       [_model addConstraint: [z geq: [@(L) mul: b]]];
       [_model addConstraint: [z leq: [@(U) mul: b]]];
       [_model addConstraint: [[x sub: z] geq: [@(L) mul: [@(1) sub: b]]]];
       [_model addConstraint: [[x sub: z] leq: [@(U) mul: [@(1) sub: b]]]];
    }
    else {
        id<ORIntVarArray> bx0 = [self binarizationForVar: x0];
        id<ORIntVarArray> bx1 = [self binarizationForVar: x1];
        
        ORInt offset = [d1 size];
        id<ORIntRange> idxRange = RANGE(_model, 0, [d0 size] * [d1 size] - 1);
        id<ORIntVarArray> idx = [ORFactory intVarArray: _model range: idxRange domain: RANGE(_model, 0, 1)];
        for(ORInt i = [d0 low]; i <= [d0 up]; i++) {
            for(ORInt j = [d1 low]; j <= [d1 up]; j++) {
                ORInt k = (i - [d0 low]) * offset + (j - [d1 low]);
                [_model addConstraint: [[idx at: k] leq: [bx0 at: i]]];
                [_model addConstraint: [[idx at: k] leq: [bx1 at: j]]];
                [_model addConstraint: [[[idx at: k] plus: @(1)] geq: [[bx0 at: i] plus: [bx1 at: j]]]];
            }
        }
        [_model addConstraint: [[c res] eq:
                                Sum2(_model, i, d0, j, d1, [[idx at: (i - [d0 low]) * offset + (j - [d1 low])] mul: @(i * j)])]];
    }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
    // Constrain upper bounds
    id<ORIntArray> upArr = [cstr up];
    id<ORIntRange> ur = [upArr range];
    for (int u = ur.low; u <= ur.up; u++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [[cstr array] range]
                                   suchThat:^ORBool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[[cstr array] at: i];
                                       return [[var domain] inRange: u];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: [[cstr array] at: i]];
                                       return [binArr at: u];
                                   }];
        [_model addConstraint: [sumExpr leq: [ORFactory integer: _model value: [upArr at: u]]]];
    }
    
    // Constrain lower bounds
    id<ORIntArray> lowArr = [cstr low];
    id<ORIntRange> lr = [lowArr range];
    for (int l = lr.low; l <= lr.up; l++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [[cstr array] range]
                                   suchThat:^ORBool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[[cstr array] at: i];
                                       return [[var domain] inRange: l];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: [[cstr array] at: i]];
                                       return [binArr at: l];
                                   }];
        [_model addConstraint: [sumExpr geq: [ORFactory integer: _model value: [lowArr at: l]]]];
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
                                   suchThat:^ORBool(ORInt i) {
                                       id<ORIntVar> var = (id<ORIntVar>)[item at: i];
                                       return [[var domain] inRange: b];
                                   } of:^id<ORExpr>(ORInt i) {
                                       id<ORIntVarArray> binArr = [self binarizationForVar: [item at: i]];
                                       id<ORMutableInteger> size = [ORFactory mutable: _model value: [itemSize at: i]];
                                       return [[binArr at: b] mul: size];
                                   }];
        [_model addConstraint: [sumExpr leq: [binSize at: b]]];
    }
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
    ORTableI* table = (ORTableI*)[cstr table];
    id<ORIntVarArray> vars = [cstr array];
    ORInt arity = [table arity];
    ORInt M = arity + 1;
    
    id<ORIntRange> zRange = RANGE(_model, 0, (int)[table size]-1);
    id<ORIntVarArray> z = [ORFactory intVarArray: _model range: zRange domain: RANGE(_model, 0, 1)];
    
    for(ORInt i = [zRange low]; i <= [zRange up]; i++) {
        id<ORExpr> sumExpr = [ORFactory integer: _model value: 0];
        for(ORInt a = 0; a < arity; a++) {
            id<ORIntVar> x = [vars at: a];
            id<ORIntVarArray> bx = [self binarizationForVar: x];
            sumExpr = [sumExpr plus: [bx at: [table atColumn: a position: i]]];
        }
        [_model addConstraint: [[sumExpr plus: [[@(1) sub: [z at: i]] mul: @(M)]] geq: @(arity)]];
    }
    [_model addConstraint: [Sum(_model, i, zRange, [z at: i]) eq: @(1)]];
    
}
-(void) visitAlgebraicConstraint:(id<ORAlgebraicConstraint>)cstr
{
    ORExprBinaryI* binExpr = (ORExprBinaryI*)[cstr expr];
    id<ORExpr> left = nil;
    id<ORExpr> right = nil;
    switch ([[cstr expr] type]) {
        case ORRBad: assert(NO);
        case ORREq: {
            left = [self linearizeExpr: [binExpr left]];
            right = [self linearizeExpr: [binExpr right]];
            [_model addConstraint: [left eq: right]];
        }break;
        case ORRNEq: {
            [binExpr visit: self];
        }break;
        case ORRLEq: {
            left = [self linearizeExpr: [binExpr left]];
            right = [self linearizeExpr: [binExpr right]];
            id<ORConstraint> c = [_model addConstraint: [left leq: right]];
            [[[_model modelMappings] tau] set: c forKey: cstr];
        }break;
        case ORRGEq: {
            left = [self linearizeExpr: [binExpr left]];
            right = [self linearizeExpr: [binExpr right]];
            [_model addConstraint: [left geq: right]];
        }break;
        default:
            assert(false);
            break;
    }
    
}
-(void) visitKnapsack:(id<ORKnapsack>)cstr {
    id<ORExpr> sumExpr = Sum(_model, i, [[cstr item] range], [[[cstr item] at: i] mul: @([[cstr weight] at: i])]);
    [_model addConstraint: [sumExpr eq: [cstr capacity]]];
}
-(void) visitEqualc: (id<OREqualc>)c
{
    id<ORExpr> left = [self linearizeExpr: [c left]];
    [_model addConstraint: [left eq: @([c cst])]];
}
-(void) visitExprGEqualI: (id<ORExpr>) e {
    ORExprBinaryI* binExpr = (ORExprBinaryI*)e;
    id<ORExpr> left = [self linearizeExpr: [binExpr left]];
    id<ORExpr> right = [self linearizeExpr: [binExpr right]];
    _exprResult = [left geq: right];
}
-(void) visitExprLEqualI: (id<ORExpr>) e {
    ORExprBinaryI* binExpr = (ORExprBinaryI*)e;
    id<ORExpr> left = [self linearizeExpr: [binExpr left]];
    id<ORExpr> right = [self linearizeExpr: [binExpr right]];
    _exprResult = [left leq: right];
}
-(void) visitLEqualc: (id<ORLEqualc>)c {
    id<ORExpr> left = [self linearizeExpr: [c left]];
    [_model addConstraint: [left leq: @([c cst])]];
}
-(void) visitGEqualc: (id<ORGEqualc>)c {
    id<ORExpr> left = [self linearizeExpr: [c left]];
    [_model addConstraint: [left geq: @([c cst])]];
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
    id<ORIntVar> x = (id<ORIntVar>)[self linearizeExpr: [c x]];
    id<ORIntVarArray> bx = [self binarizationForVar: x];
    id<ORIntVar> b = (id<ORIntVar>)[self linearizeExpr: [c b]];
    ORInt cst = [c cst];
    
    [_model addConstraint: [ Sum(_model, i, RANGE(_model, [[bx range] low], cst-1), [bx at: i]) eq: [@(1) sub: b]]];
    [_model addConstraint: [ Sum(_model, i, RANGE(_model, cst, [[bx range] up]), [bx at: i]) eq: b]];
}
-(void) visitReifyLEqualc: (id<ORReifyGEqualc>)c
{
    id<ORExpr> expr = (id<ORIntVar>)[self linearizeExpr: [[c x] mul: @(-1)]];
    id<ORIntVar> y = [ORFactory intVar: _model bounds: RANGE(_model, [expr min], [expr max])];
    id<ORIntVarArray> by = [self binarizationForVar: y];
    id<ORIntVar> b = (id<ORIntVar>)[self linearizeExpr: [c b]];
    ORInt cst = -[c cst];
    
    [_model addConstraint: [y eq: expr]];
    [_model addConstraint: [ Sum(_model, i, RANGE(_model, [[by range] low], cst-1), [by at: i]) eq: [@(1) sub: b]]];
    [_model addConstraint: [ Sum(_model, i, RANGE(_model, cst, [[by range] up]), [by at: i]) eq: b]];
}
-(void) visitLinearEq: (id<ORLinearEq>) c
{
    id<ORIntVarArray> narr = (id<ORIntVarArray>)[[c vars] map: ^id(id obj, int idx) {
        return [[[_model modelMappings] tau] get: obj];  }];
    [_model addMutable: narr];
    [_model trackMutable: narr];
    id<ORConstraint> cstr = [Sum(_model, i, [narr range], [narr[i] mul: @([[c coefs] at: i])]) eq: @([c cst])];
    [_model addConstraint: cstr];
    [[[_model modelMappings] tau] set: cstr forKey: c];
}
-(void) visitLinearLeq: (id<ORLinearLeq>) c
{
    id<ORIntVarArray> narr = (id<ORIntVarArray>)[[c vars] map: ^id(id obj, int idx) {
        return [[[_model modelMappings] tau] get: obj];  }];
    [_model addMutable: narr];
    [_model trackMutable: narr];
    id<ORConstraint> cstr = [Sum(_model, i, [narr range], [narr[i] mul: @([[c coefs] at: i])]) leq: @([c cst])];
    //[ORFactory sum: _model array: narr coef: [c coefs] leq: [c cst]];
    [_model addConstraint: cstr];
    [[[_model modelMappings] tau] set: cstr forKey: c];
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
#if defined(__linux__)
#define _Nonnull
#endif  
   id<ORIntVarArray> array = (id)[c.vars map:^id _Nonnull(id  _Nonnull obj, int idx) {
      return [_model.modelMappings.tau get:obj];
   }];
   [_model addMutable:array];
   [_model trackMutable:array];
   id<ORConstraint> cstr = [Sum(_model, i, array.range, array[i]) eq: @(c.cst)];
   [_model addConstraint:cstr];
   [_model.modelMappings.tau set:cstr forKey:c];
}

-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
    id<ORIntVar> x = [c x];
    id<ORIntVar> b = [c b];
    ORInt cst = [c cst];
    
    id<ORIntVarArray> bx = [self binarizationForVar: x];
    [_model addConstraint: [[bx at: cst] eq: [@(1) sub: b]]];
    
//    id<ORIntVar> z0 = [ORFactory intVar: _model bounds: RANGE(_model, 0, 1)];
//    id<ORIntVar> z1 = [ORFactory intVar: _model bounds: RANGE(_model, 0, 1)];
//    ORInt M = 999999;
//    
//    // greater-than
//    // x + ((1 - z0) * M) > cst
//    // x - (z0 * M) <= cst
//    [_model addConstraint: [[x plus: [[@(1) sub: z0] mul: @(M)]] gt: @(cst)]];
//    [_model addConstraint: [[x sub: [z0 mul: @(M)]] leq: @(cst)]];
//
//    // less-than
//    // x - ((1 - z1) * M) < cst
//    // x + (z1 * M) >= cst
//    [_model addConstraint: [[x sub: [[@(1) sub: z1] mul: @(M)]] lt: @(cst)]];
//    [_model addConstraint: [[x plus: [z1 mul: @(M)]] geq: @(cst)]];
//    
//    // r == z0 + z1
//    // x - (z * M) == cst
//    [_model addConstraint: [r eq: [z0 plus: z1]]];
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   id<ORIntVar> x = [c x];
   id<ORIntVar> y = [c y];
   id<ORIntVar> r = [c b];
   // The original rewrite was wrong. We need to express this as
   // r = max(0, 1 - | x - y | )
   // whenever x = y we get |x-y| = 0 and therefore r = max(0,1) = 1
   //          x ≠ y we get |x-y| ≥ 1 and therefore r = max(0,non-positive number or zero) = 0
   // Therefore chain the rewrite for a max and an absolute value and we are set.
   // Let w = | x - y |
   ORInt La = 0,Ua    = max(abs(x.up - y.low),abs(x.low - y.up));
   id<ORIntVar> z0 = [ORFactory intVar: _model bounds: RANGE(_model, 0, 1)];
   id<ORIntVar> z1 = [ORFactory intVar: _model bounds: RANGE(_model, 0, 1)];
   id<ORIntVar> a  = [ORFactory intVar: _model bounds:RANGE(_model,La,Ua)];
   [_model addConstraint: [[z0 plus: z1] eq: @(1)]];
   [_model addConstraint: [[a sub:[x sub: y]] geq:@(0)]];
   [_model addConstraint: [[a sub:[x sub: y]] leq:[z1 mul: @(2 * Ua)]]];
   [_model addConstraint: [[a sub:[y sub: x]] geq:@(0)]];
   [_model addConstraint: [[a sub:[y sub: x]] leq:[z0 mul: @(2 * Ua)]]];
   // r = max(0, 1 - a)
   ORInt Umax = 1;
   id<ORIntVar> d0 = [ORFactory intVar:_model bounds:RANGE(_model,0,1)];
   id<ORIntVar> d1 = [ORFactory intVar:_model bounds:RANGE(_model,0,1)];
   [_model addConstraint:[r geq: @(0)]];
   [_model addConstraint:[r geq: [@(1) sub: a]]];
   [_model addConstraint:[r leq: [@(0) plus:[@(Umax - 0) mul:[@(1) sub: d0] ]]]];
   [_model addConstraint:[r leq: [[@(1) sub: a] plus:[@(Umax - (1 - a.up)) mul:[@(1) sub: d1] ]]]];
   [_model addConstraint:[[d0 plus: d1] eq: @(1)]];
//   
//   ORInt M1 = x.up - y.low;
//   ORInt M2 = y.up - x.low;
//   //ORInt M = 999999;
//   
//   // x + (z0 * M) >= y
//   // x - (z1 * M) <= y
//   [_model addConstraint: [[x plus: [z0 mul: @(M2)]] geq: y]];
//   [_model addConstraint: [[x sub: [z1 mul: @(M1)]] leq: y]];
//   
//   // r == 1 - (z0 + z1)
//   [_model addConstraint: [r eq: [@(1) sub: [z0 plus: z1]]]];
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
//   id<ORIntVar> dv = [[[_model modelMappings] tau] get: v];
//   if(dv == nil) {
//      [[[_model modelMappings] tau] set: v forKey: v];
//      [_model addVariable: v];
//      return;
//   }
//   _exprResult = dv;
   ORIntVarAffineI* av = (ORIntVarAffineI*)v;
   id<ORIntVar> x = (id<ORIntVar>)[self linearizeExpr: [av base]];
   ORInt tl = x.low * av.scale + av.shift, tu = x.up * av.scale + av.shift;
   id<ORIntVar> z = [ORFactory intVar:_model bounds:RANGE(_model,min(tl,tu),max(tl,tu))];
   [_model addConstraint: [z eq: [[x mul: @(av.scale)] plus: @(av.shift)] track: _model]];
   _exprResult = z;
//    ORIntVarAffineI* av = (ORIntVarAffineI*)v;
//    id<ORIntVar> x = (id<ORIntVar>)[self linearizeExpr: [av base]];
//    [_model addConstraint: [av eq: [[x mul: @([av scale])] plus: @([av shift])] track: _model]];
}
-(void) visitModc: (id<ORModc>)c
{  // res = left modc right
   id<ORIntVar> x0 = (id<ORIntVar>)[self linearizeExpr:(id<ORIntVar>)[c left]];
   id<ORIntVar> r  = (id<ORIntVar>)[self linearizeExpr:(id<ORIntVar>)[c res]];
   ORInt        cst  = [c right];
   ORInt ubm = [x0 max] / cst;
   id<ORIntVar> multiplier = [ORFactory intVar:_model bounds:RANGE(_model,0,ubm)];
   [_model addConstraint:[x0 eq: [[multiplier mul:@(cst)] plus: r]]];
   [_model addConstraint:[r lt:@(cst)]];
}

-(void) visitEqual: (id<OREqual>)c
{
    id<ORIntVar> x0 = (id<ORIntVar>)[self linearizeExpr: (id<ORIntVar>)[c left]];
    id<ORIntVar> x1 = (id<ORIntVar>)[self linearizeExpr: (id<ORIntVar>)[c right]];
    [_model addConstraint: [x0 eq: x1 track: _model]];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
    id<ORIntVar> x0 = (id<ORIntVar>)[self linearizeExpr: (id<ORIntVar>)[c left]];
    id<ORIntVar> x1 = (id<ORIntVar>)[self linearizeExpr: (id<ORIntVar>)[c right]];
    [_model addConstraint: [[x0 mul: @([c coefLeft])] leq: [[x1 mul: @([c coefLeft])] plus: @([c cst])] track: _model]];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
    id<ORIntVar> x = (id<ORIntVar>)[ self linearizeExpr: [c left]];
    id<ORIntVarArray> bx = [self binarizationForVar: x];
    id<ORIntVar> y = (id<ORIntVar>)[ self linearizeExpr: [c right]];
    id<ORIntVarArray> by = [self binarizationForVar: y];
    ORInt cst = [c cst];
    NSMutableArray* cstrs = [[NSMutableArray alloc] init];
    id<ORIntRange> dom = RANGE(_model, MAX([[x domain] low], [[y domain] low]), MIN([[x domain] up], [[y domain] up]));
    [dom enumerateWithBlock: ^(ORInt i) {
        if([[y domain] inRange: i + cst]) {
            id<ORConstraint> cstr = [ORFactory algebraicConstraint: _model expr:  [[bx[i] plus: by[i+cst] track: _model] leq: @(1) track: _model]];
            [_model addConstraint: cstr];
            [cstrs addObject: cstr];
        }
    }];
    [[[_model modelMappings] tau] set: cstrs forKey: c];
}
-(void) visitRealLinearGeq: (id<ORRealLinearGeq>) c
{
    id<ORIntVarArray> narr = (id<ORIntVarArray>)[[c vars] map: ^id(id obj, int idx) {
        return [[[_model modelMappings] tau] get: obj];  }];
    [_model addMutable: narr];
    [_model trackMutable: narr];
    id<ORConstraint> cstr = [Sum(_model, i, [narr range], [narr[i] mul: @([[c coefs] at: i])]) geq: @([c cst])];
    //[ORFactory sum: _model array: narr coef: [c coefs] leq: [c cst]];
    [_model addConstraint: cstr];
    [[[_model modelMappings] tau] set: cstr forKey: c];
}
-(void) visitAnd:( id<ORAnd>)c
{
    id<ORIntVar> x0 = (id<ORIntVar>)[self linearizeExpr: [c left]];
    id<ORIntVar> x1 = (id<ORIntVar>)[self linearizeExpr: [c right]];;
    id<ORIntVar> r = [c res];
    // r <= x0
    // r <= x1
    // r+1 >= x0 + x1
    [_model addConstraint: [r leq: x0]];
    [_model addConstraint: [r leq: x1]];
    [_model addConstraint: [[r plus: @(1)] geq: [x0 plus: x1]]];
}
-(void) visitOr:(id<OROr>)c
{
   id<ORIntVar> x0 = (id<ORIntVar>)[self linearizeExpr: [c left]];
   id<ORIntVar> x1 = (id<ORIntVar>)[self linearizeExpr: [c right]];;
   id<ORIntVar> r  = (id<ORIntVar>)[self linearizeExpr:[c res]];
   [_model addConstraint: [x0 leq: r]];
   [_model addConstraint: [x1 leq: r]];
   [_model addConstraint: [r leq: [x0 plus:x1]]];
   [_model addConstraint: [r leq: @(1)]];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
    id<ORIntVar> idx = (id<ORIntVar>)[ self linearizeExpr: [c idx]];
    id<ORIntVarArray> bidx = [self binarizationForVar: idx];
    id<ORIntArray> arr = [c array];
    id<ORIntVar> res = [c res];
    [_model addConstraint: [res eq: Sum(_model, i, [idx domain], [@([arr at: i]) mul: bidx[i]])]];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
    //NSLog(@"idx: %@", [[c idx] class]);
    id<ORIntRange> binRange = RANGE(_model, 0, 1);
    id<ORIntVarArray> bidx = [self binarizationForVar: [c idx]];
    id<ORExpr> sum = [ORFactory integer: _model value: 0];
    ORInt lb = max(c.array.low,c.idx.min), ub = min(c.array.up,c.idx.max);
    for(ORInt i = lb; i <= ub; i++) {
        id<ORIntVar> x = [c. array at: i];
        //NSLog(@"x: %@", [x class]);
        id<ORIntVarArray> bx = [self binarizationForVar: x];
        for(ORInt val = [[x domain] low]; val <= [[x domain] up]; val++) {
            id<ORIntVar> z = [ORFactory intVar: _model bounds: binRange];
            [_model addConstraint: [z leq: [bx at: val]]];
            [_model addConstraint: [z leq: [bidx at: i]]];
            [_model addConstraint: [[z plus: @(1)] geq: [[bx at: val] plus: [bidx at: i]]]];
            sum = [sum plus: [z mul: @(val)]];
        }
    }
    //NSLog(@"res: %@", [[c res] class]);
    [_model addConstraint: [[c res] eq: sum]];
}
-(void) visitElementBitVar: (id<ORElementBitVar>)c
{
   assert(NO);
}
// Expressions
-(void) visitIntegerI: (id<ORInteger>) e
{
    _exprResult = e;
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
    _exprResult = e;
}
-(void) visitMutableDouble:(id<ORMutableDouble>)e
{
    _exprResult = e;
}
-(void) visitDouble:(id<ORDoubleNumber>)e
{
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
-(void) visitExprMulI: (id<ORExpr>) e
{
    ORExprBinaryI* binExpr = (ORExprBinaryI*)e;
    id<ORExpr> left = [self linearizeExpr: [binExpr left]];
    id<ORExpr> right = [self linearizeExpr: [binExpr right]];
    assert(!([left isVariable] && [right isVariable]));
    _exprResult = [left mul: right];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
    ORExprSumI* sumExpr = (ORExprSumI*)e;
    [[sumExpr expr] visit: self];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
    ORExprProdI* pExpr = (ORExprProdI*)e;
    [[pExpr expr] visit: self];
}
-(void) visitExprCstSubI: (id<ORExpr>) e  {
    ORExprCstSubI* cstSubExpr = (ORExprCstSubI*)e;
    id<ORIntVar> indexVar;
    // Create the index variable if needed.
    if([[cstSubExpr index] conformsToProtocol: @protocol(ORIntVar)]) indexVar = (id<ORIntVar>)[cstSubExpr index];
    else {
        id<ORExpr> linearIndexExpr = [self linearizeExpr: [cstSubExpr index]];
        id<ORIntRange> dom = [ORFactory intRange:_model low:[linearIndexExpr min] up:[linearIndexExpr max]];
        indexVar = [ORFactory intVar: _model domain: dom];
        [_model addConstraint: [indexVar eq: linearIndexExpr]];
    }
    id<ORIntVarArray> binIndexVar = [self binarizationForVar: indexVar];
    id<ORExpr> linearSumExpr = [ORFactory sum: _model over: [binIndexVar range] suchThat: nil of:^id<ORExpr>(ORInt i) {
        return [[binIndexVar at: i] mul: @([[cstSubExpr array] at: i ])];
    }];
    id<ORIntRange> dom = [ORFactory intRange:_model low:[linearSumExpr min] up:[linearSumExpr max]];
    id<ORIntVar> sumVar = [ORFactory intVar: _model domain: dom];
    [_model addConstraint: [sumVar eq: linearSumExpr]];
    _exprResult = sumVar;
}
-(void) visitExprCstDoubleSubI: (ORExprCstDoubleSubI*)cstSubExpr
{
    id<ORIntVar> indexVar;
    // Create the index variable if needed.
    if([[cstSubExpr index] conformsToProtocol: @protocol(ORIntVar)])
        indexVar = (id<ORIntVar>)[cstSubExpr index];
    else {
        id<ORExpr> linearIndexExpr = [self linearizeExpr: [cstSubExpr index]];
        id<ORIntRange> dom = [ORFactory intRange:_model low:[linearIndexExpr min] up:[linearIndexExpr max]];
        indexVar = [ORFactory intVar: _model domain: dom];
        [_model addConstraint: [indexVar eq: linearIndexExpr]];
    }
    id<ORIntVarArray> binIndexVar = [self binarizationForVar: indexVar];
    id<ORExpr> linearSumExpr = [ORFactory sum: _model over: [binIndexVar range] suchThat: nil of:^id<ORExpr>(ORInt i) {
        return [[binIndexVar at: i] mul: @([[cstSubExpr array] at: i ])];
    }];
    id<ORRealVar> sumVar = [ORFactory realVar: _model low:[linearSumExpr min] up:[linearSumExpr max]];
    [_model addConstraint: [sumVar eq: linearSumExpr]];
    _exprResult = sumVar;
}

@end

@implementation ORLinearizeObjective {
    id<ORAddToModel> _model;
    id _result;
}
-(id)init:(id<ORAddToModel>)m
{
    self = [super init];
    _model = m;
    return self;
}
-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
    [_model minimize:[v var]];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
    [_model maximize:[v var]];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) v
{
    //assert([[v expr] conformsToProtocol:@protocol(ORVar)]);
    [_model minimize:[v expr]];
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
    //assert([[v expr] conformsToProtocol:@protocol(ORVar)]);
    [_model maximize:[v expr]];
}
-(void) visitIntVar: (id<ORIntVar>) v  { _result = v; }

@end

@implementation ORFactory(Linearize)
+(id<ORModel>) linearizeModel:(id<ORModel>)m
{
    id<ORAnnotation> notes = [ORFactory annotation];
    id<ORModel> fm = [m flatten: notes];
    id<ORModel> lm = [ORFactory createModel: [fm nbObjects] mappings: [fm modelMappings]];
    ORBatchModel* batch = [[ORBatchModel alloc] init: lm source: fm annotation:nil]; //TOFIX
    id<ORModelTransformation> linearizer = [[ORLinearize alloc] initORLinearize:batch];
    [linearizer apply: fm with:nil]; // TOFIX
    [batch release];
    [linearizer release];
    return lm;
}

@end
