//
//  ORLinearize.m
//  Clo
//
//  Created by Daniel Fontaine on 10/6/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <ORModeling/ORLinearize.h>
#import <ORFoundation/ORSetI.h>
#import "ORModelI.h"
#import "ORExprI.h"
#import <ORFoundation/ORVisit.h>
#import <ORScheduler/ORScheduler.h>

@interface ORLinearizeConstraint : ORVisitor<NSObject> {
@protected
    id<ORAddToModel>  _model;
    NSMapTable*   _binMap;
    id<ORExpr> _exprResult;
}
-(id)init:(id<ORAddToModel>)m;

-(id<ORIntVarArray>) binarizationForVar: (id<ORIntVar>)var;
-(id<ORIntRange>) unionOfVarArrayRanges: (id<ORExprArray>)arr;
-(id<ORExpr>) linearizeExpr: (id<ORExpr>)expr;
@end

@interface ORLinearizeSchedConstraint : ORLinearizeConstraint
-(id)init:(id<ORAddToModel>)m;
-(void) noOverlap: (id<ORTaskVar>) t0 with: (id<ORTaskVar>) t1;
@end

// Time Indexed linearization
@interface ORLinearizeSchedConstraintTI : ORLinearizeConstraint
-(id)init:(id<ORAddToModel>)m taskMapping: (NSMapTable*)taskMapping resourceMapping: (NSMapTable*)resMapping
indexVars: (id<ORIntVar>***)y horizon: (ORInt)horizon;
@end

@interface ORLinearizeObjective : ORVisitor<NSObject>
-(id)init:(id<ORAddToModel>)m;

@end

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
        [_into addVariable: x];
    } onMutables:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
    } onImmutables:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
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
    id<ORExpr> sumBinVars = Sum(_model, i,[x domain], o[i]);
    id<ORExpr> sumExpr    = Sum(_model, i,[x domain], [o[i] mul: @(i)]);
    [_model addConstraint: [sumBinVars eq: @(1)]];
    [_model addConstraint: [sumExpr eq: x]];
    [[[_model modelMappings] tau] set: o forKey: x];
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
    [expr visit: self];
    return _exprResult;
}
-(void) visitIntVar: (id<ORIntVar>) v  { _exprResult = v; }
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
    // [ldm] this code needs to be revised if the input is an array of expressions.
    id<ORIntVarArray> varsOfC = (id) [cstr array];
    id<ORIntRange> dom = [self unionOfVarArrayRanges: varsOfC];
    for (int d = [dom low]; d <= [dom up]; d++) {
        id<ORExpr> sumExpr = [ORFactory sum: _model over: [varsOfC range]
                                   suchThat:^bool(ORInt i) {
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
        [_model addConstraint: [sumExpr leq: [ORFactory integer: _model value: [upArr at: u]]]];
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
                                   suchThat:^bool(ORInt i) {
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
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
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
            assert(true);
            break;
    }
    
}
-(void) visitKnapsack:(id<ORKnapsack>)cstr {
    id<ORExpr> sumExpr = Sum(_model, i, [[cstr item] range], [[[cstr item] at: i] mul: @([[cstr weight] at: i])]);
    [_model addConstraint: [sumExpr eq: [cstr capacity]]];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
}
-(void) visitRealEqualc: (id<ORRealEqualc>)c
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
-(void) visitGEqualc: (id<ORGEqualc>)c
{
}
-(void) visitEqual: (id<OREqual>)c
{
}
-(void) visitAffine: (id<ORAffine>)c
{
}
-(void) visitNEqual: (id<ORNEqual>)c
{
    id<ORIntVar> x = [c left];
    id<ORIntVarArray> bx = [self binarizationForVar: x];
    id<ORIntVar> y = [c right];
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
-(void) visitLEqual: (id<ORLEqual>)c
{
}
-(void) visitPlus: (id<ORPlus>)c
{
}
-(void) visitMult: (id<ORMult>)c
{
}
-(void) visitSquare:(id<ORSquare>)c
{
}
-(void) visitFloatSquare:(id<ORSquare>)c
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
-(void) visitRealElementCst: (id<ORRealElementCst>) c
{
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
    id<ORModel> lm = [ORFactory createModel: [m nbObjects] mappings:nil];
    ORBatchModel* batch = [[ORBatchModel alloc] init: lm source: m annotation:nil]; //TOFIX
    id<ORModelTransformation> linearizer = [[ORLinearize alloc] initORLinearize:batch];
    [linearizer apply: m with:nil]; // TOFIX
    [batch release];
    [linearizer release];
    return lm;
}
+(id<ORModel>) linearizeSchedulingModel: (id<ORModel>)m encoding: (MIPSchedEncoding)enc {
    id<ORModel> lm = [ORFactory createModel: [m nbObjects] mappings:nil];
    ORBatchModel* batch = [[ORBatchModel alloc] init: lm source: m annotation:nil]; //TOFIX
    
    // Choose the correct linearizer
    id<ORModelTransformation> linearizer;
    if(enc == MIPSchedTimeIndexed) linearizer = [[ORLinearizeSchedulingTI alloc] initORLinearizeSched: batch];
    else linearizer = [[ORLinearizeScheduling alloc] initORLinearizeSched:batch];
    
    [linearizer apply: m with:nil]; // TOFIX
    [batch release];
    [linearizer release];
    return lm;
}
@end


// Standard Scheduling
@implementation ORLinearizeSchedConstraint {
}
-(id) init:(id<ORAddToModel>)m {
    self = [super init: m];
    if(self) {
    }
    return self;
}

-(void) noOverlap: (id<ORTaskVar>) t0 with: (id<ORTaskVar>) t1 {
    id<ORIntVar> sx0 = [t0 getStartVar];
    id<ORIntVar> sx1 = [t1 getStartVar];
    ORInt d0 = [[t0 duration] up];
    ORInt d1 = [[t1 duration] up];
    
    ORInt M = 99999;
    id<ORIntVar> z = [ORFactory intVar: _model domain: RANGE(_model, 0, 1)];
    [_model addConstraint: [[sx0 plus: @(d0)] leq: [sx1 plus: [z mul: @(M)]]]];
    [_model addConstraint: [[sx1 plus: @(d1)] leq: [sx0 plus: [[@(1) sub: z] mul: @(M)]]]];
}

//-(void) visitPrecedes: (id<ORPrecedes>) cstr
//{
//}
-(void) visitTaskPrecedes: (id<ORPrecedes>) cstr
{
    id<ORTaskPrecedes> precedesCstr = (id<ORTaskPrecedes>)cstr;
    id<ORIntVar> sx0 = [[precedesCstr before] getStartVar];
    ORInt d0 = [[[precedesCstr before] duration] up];
    id<ORIntVar> sx1 = [[precedesCstr after] getStartVar];
    [_model addConstraint: [[sx0 plus: @(d0)] leq: sx1]];
}
//-(void) visitTaskDuration: (id<ORTaskDuration>) cstr
//{
//}
//-(void) visitTaskAddTransitionTime:  (id<ORTaskAddTransitionTime>) cstr
//{
//}
//-(void) visitSumTransitionTimes:  (id<ORSumTransitionTimes>) cstr;
//{
//}
-(void) visitTaskIsFinishedBy:  (id<ORTaskIsFinishedBy> ) cstr
{
    id<ORIntVar> sx0 = [[cstr task] getStartVar];
    ORInt duration = [[[cstr task] duration] up];
    [_model addConstraint: [[sx0 plus: @(duration)] leq: [cstr date]]];
}
//-(void) visitTaskCumulative: (id<ORTaskCumulative>) cstr
//{
//}
-(void) visitTaskDisjunctive: (id<ORTaskDisjunctive>) cstr
{
    id<ORTaskVarArray> tasks = [cstr taskVars];
    for(ORInt i = [tasks low]; i < [tasks up]; i++) {
        for(ORInt j = i+1; j <= [tasks up]; j++) {
            id<ORTaskVar> t0 = [tasks objectAtIndexedSubscript: i];
            id<ORTaskVar> t1 = [tasks objectAtIndexedSubscript: j];
            [self noOverlap: t0 with: t1];
        }
    }
}
//-(void) visitSoftTaskDisjunctive:  (id<ORSoftTaskDisjunctive> ) cstr
//{
//}
//-(void) visitCumulative: (id<ORCumulative>) cstr
//{
//}
//-(void) visitDifference: (id<ORDifference>) cstr
//{
//}
//-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr
//{
//}
//-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr
//{
//}
//-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr
//{
//}
@end


@implementation ORLinearizeScheduling {
    id<ORAddToModel> _into;
}
-(id)initORLinearizeSched:(id<ORAddToModel>)into
{
    self = [super init];
    _into = into;
    return self;
}

-(void)apply:(id<ORModel>)m with:(id<ORAnnotation>)notes
{
    NSMapTable* taskVarsMap = [[NSMapTable alloc] init];
    NSMutableArray* taskVars = [[NSMutableArray alloc] init];
    for(id<ORVar> x in [m variables])
        if([x conformsToProtocol: @protocol(ORTaskVar)]) [taskVars addObject: x];
    for(id<ORTaskVar> x in taskVars)
            [taskVarsMap setObject: [(id<ORTaskVar>)x getStartVar] forKey: x];
    
    ORLinearizeSchedConstraint* lc = [[ORLinearizeSchedConstraint alloc] init: _into];
    [m applyOnVar:^(id<ORVar> x) {
        if(![x conformsToProtocol: @protocol(ORTaskVar)]) {
            [_into addVariable: x];
            //[[[_into modelMappings] tau] set: x forKey: x];
        }
    } onMutables:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
    } onImmutables:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
    } onConstraints:^(id<ORConstraint> c) {
        [c visit: lc];
    } onObjective:^(id<ORObjectiveFunction> o) {
        ORLinearizeObjective* lo = [[ORLinearizeObjective alloc] init: _into];
        [o visit: lo];
    }];
    [taskVars release];
    [taskVarsMap release];
    [lc release];
}
@end

// Time Indexed
@implementation ORLinearizeSchedConstraintTI {
    NSMapTable* _taskVarMap;
    NSMapTable* _resMap;
    id<ORIntVar>***   _y;
    ORInt _horizon;
}
-(id)init:(id<ORAddToModel>)m taskMapping: (NSMapTable*)taskMapping resourceMapping: (NSMapTable*)resMapping
indexVars: (id<ORIntVar>***)y horizon: (ORInt)horizon {
    self = [super init: m];
    if(self) {
        _taskVarMap = taskMapping;
        _resMap = resMapping;
        _y = y;
        _horizon = horizon;
    }
    return self;
}
//-(void) visitPrecedes: (id<ORPrecedes>) cstr
//{
//}
-(void) visitTaskPrecedes: (id<ORPrecedes>) cstr
{
    id<ORTaskPrecedes> precedesCstr = (id<ORTaskPrecedes>)cstr;
    ORInt j0 = [[_taskVarMap objectForKey: [precedesCstr before]] intValue];
    ORInt d0 = [[[precedesCstr before] duration] up];
    ORInt j1 = [[_taskVarMap objectForKey: [precedesCstr after]] intValue];
    id<ORIntRange> r1 = RANGE(_model, 0, _horizon);
    for(ORInt k0 = 0; k0 < [_resMap count]; k0++) {
        for(ORInt k1 = 0; k1 < [_resMap count]; k1++) {
            [_model addConstraint:
             [Sum(_model, t, r1, [_y[k0][j0][t] mul: @(t+d0)]) leq:
              Sum(_model, t, r1, [_y[k1][j1][t] mul: @(t)])]];
        }
    }
}
//-(void) visitTaskDuration: (id<ORTaskDuration>) cstr
//{
//}
//-(void) visitTaskAddTransitionTime:  (id<ORTaskAddTransitionTime>) cstr
//{
//}
//-(void) visitSumTransitionTimes:  (id<ORSumTransitionTimes>) cstr;
//{
//}
-(void) visitTaskIsFinishedBy:  (id<ORTaskIsFinishedBy> ) cstr
{
    ORInt j0 = [[_taskVarMap objectForKey: [cstr task]] intValue];
    ORInt d0 = [[[cstr task] duration] up];
    id<ORIntRange> r1 = RANGE(_model, 0, _horizon);
    for(ORInt k = 0; k < [_resMap count]; k++) {
        [_model addConstraint: [Sum(_model, t, r1, [_y[k][j0][t] mul: @(t+d0)]) leq: [cstr date]]];
    }
}
//-(void) visitTaskCumulative: (id<ORTaskCumulative>) cstr
//{
//}
-(void) visitTaskDisjunctive: (id<ORTaskDisjunctive>) cstr
{
    id<ORTaskVarArray> tasks = [cstr taskVars];
    id<ORIntArray> ji = [ORFactory intArray: _model range: [tasks range] value: 0];
    id<ORIdMatrix> T = [ORFactory idMatrix: _model range: [tasks range] : RANGE(_model, 0, _horizon)];
    for(ORInt j = [tasks low]; j <= [tasks up]; j++) {
        id<ORTaskVar> task = [tasks at: j];
        [ji set: [[_taskVarMap objectForKey: task] intValue] at: j];
        for(ORInt t = 0; t <= _horizon; t++) {
            [T set: RANGE(_model, max(0, t - [[task duration] up]+1), t) at: j : t];
        }
    }
    ORInt ki = [[_resMap objectForKey: cstr] intValue];
    for(ORInt t = 0; t <= _horizon; t++) {
        id<ORExpr> sum = Sum(_model, j, [tasks range], Sum(_model, tt, [T at: j:t], _y[ki][[ji at: j]][tt]));
        [_model addConstraint: [sum leq: @(1)]];
    }
}
//-(void) visitSoftTaskDisjunctive:  (id<ORSoftTaskDisjunctive> ) cstr
//{
//}
//-(void) visitCumulative: (id<ORCumulative>) cstr
//{
//}
//-(void) visitDifference: (id<ORDifference>) cstr
//{
//}
//-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr
//{
//}
//-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr
//{
//}
//-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr
//{
//}
@end


@implementation ORLinearizeSchedulingTI {
    id<ORAddToModel> _into;
    NSMapTable* _taskVarMap;
    NSMapTable* _resMap;
    id<ORIntVar>***   _y;
}
-(id)initORLinearizeSched:(id<ORAddToModel>)into
{
    self = [super init];
    _into = into;
    _taskVarMap = [[NSMapTable alloc] init];
    _resMap = [[NSMapTable alloc] init];
    return self;
}
-(ORInt) initializeMapping: (id<ORModel>)m {
    ORInt horizon = 0;
    ORInt taskCount = 0;
    NSMutableArray* tasks = [[NSMutableArray alloc] init];
    for(id<ORVar> x in [m variables]) {
        if([x conformsToProtocol: @protocol(ORTaskVar)]) {
            id<ORTaskVar> task = (id<ORTaskVar>)x;
            if([[task horizon] up] > horizon) horizon = [[task horizon] up];
            ORInt idx = (ORInt)[_taskVarMap count];
            [_taskVarMap setObject: @(idx) forKey: task];
            [tasks addObject: task];
            taskCount++;
        }
    }
    ORInt resCount = 0;
    for(id<ORConstraint> c in [m constraints]) {
        if([c conformsToProtocol: @protocol(ORTaskDisjunctive)]) {
            ORInt idx = (ORInt)[_resMap count];
            [_resMap setObject: @(idx) forKey: c];
            resCount++;
        }
    }
    _y = malloc(resCount * sizeof(id<ORIntVar>));
    for(ORInt k = 0; k < resCount; k++) {
        _y[k] = malloc(taskCount * sizeof(id<ORIntVar>));
        for(ORInt j = 0; j < taskCount; j++) {
            _y[k][j] = malloc((horizon+1) * sizeof(id<ORIntVar>));
            for(ORInt t = 0; t <= horizon; t++) {
                _y[k][j][t] = [ORFactory intVar: _into domain: RANGE(_into, 0, 1)];
            }
        }
    }
    // Add mapping constraints
    for(id<ORTaskVar> task in tasks) {
        ORInt j = [[_taskVarMap objectForKey: task] intValue];
        ORInt release = [[task horizon] low];
        ORInt due = [[task horizon] up];
        ORInt dur = [[task duration] up];
        for(ORInt k = 0; k < resCount; k++) {
            id<ORIntRange> rng = RANGE(_into, release, due - dur);
            [_into addConstraint: [Sum(_into, t, rng, _y[k][j][t]) eq: @(1)]];
        }
    }
    return horizon;
}
-(void)apply:(id<ORModel>)m with:(id<ORAnnotation>)notes
{
    ORInt horizon = [self initializeMapping: m];
    ORLinearizeSchedConstraintTI* lc = [[ORLinearizeSchedConstraintTI alloc] init: _into taskMapping: _taskVarMap resourceMapping: _resMap indexVars: _y horizon: horizon];
    [m applyOnVar:^(id<ORVar> x) {
        if(![x conformsToProtocol: @protocol(ORTaskVar)]) {
            [_into addVariable: x];
        }
    } onMutables:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
    } onImmutables:^(id<ORObject> x) {
        //NSLog(@"Got an object: %@",x);
    } onConstraints:^(id<ORConstraint> c) {
        [c visit: lc];
    } onObjective:^(id<ORObjectiveFunction> o) {
        ORLinearizeObjective* lo = [[ORLinearizeObjective alloc] init: _into];
        [o visit: lo];
    }];
    [lc release];
}


@end

