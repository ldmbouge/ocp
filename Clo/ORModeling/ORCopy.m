//
//  ORCopy.m
//  Clo
//
//  Created by Daniel Fontaine on 1/22/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import "ORCopy.h"
#import "ORVarI.h"
#import "ORSetI.h"
#import "ORModelI.h"
#import "ORArrayI.h"
#import "ORDataI.h"

@interface ORCopy(Private)
-(id) copyObject: (id<ORObject>)o;
@end

@implementation ORCopy {
    NSZone* _zone;
    id<ORModel> _origModel;
    ORModelI* _copyModel;
    NSMapTable* _mapping;
    id _result;
}

-(id)initORCopy: (NSZone*)zone {
    if((self = [super init])) {
        _zone = zone;
        _copyModel = nil;
    }
    return self;
}

-(id<ORModel>) copyModel:(id<ORModel>)model {
    _origModel = [model retain];
    _copyModel = [[ORModelI alloc] initORModelI];
    _mapping = [[NSMapTable alloc] init];
    
    [_origModel applyOnVar:^(id<ORVar> x) {
        [self copyObject: x];
    } onObjects:^(id<ORObject> x) {
        [self copyObject: x];
    } onConstraints:^(id<ORConstraint> c) {
        [self copyObject: c];
    } onObjective:^(id<ORObjectiveFunction> o) {
        [self copyObject: o];
    }];
    
    [_origModel release];
    [_mapping release];
    return _copyModel;
}

-(id) copyObject: (id<ORObject>)o {
    id c = [_mapping objectForKey: o];
    if(c == nil) {
        [o visit: self];
        c = _result;
        [_mapping setObject: c forKey: o];
    }
    return c;
}

// Copy objects
-(void) visitRandomStream:(id) v {}
-(void) visitZeroOneStream:(id) v {}
-(void) visitUniformDistribution:(id) v{}
-(void) visitIntSet:(id<ORIntSet>)v {
    id<ORIntSet> o = [[ORIntSetI allocWithZone: _zone] initORIntSetI];
    [v enumerateWithBlock:^(ORInt i) {
       [o insert: i];
    }];
    [_copyModel trackObject: o];
    _result = o;
}
-(void) visitIntRange:(id<ORIntRange>)v{
    id<ORIntRange> o = [[ORIntRangeI allocWithZone: _zone] initORIntRangeI: [v low] up: [v up]];
    [_copyModel trackObject: o];
    _result = o;
}
-(void) visitIntArray:(id<ORIntArray>)v  {
    id<ORIntArray> o = [[ORIntArrayI allocWithZone: _zone]
                        initORIntArray: _copyModel range: [self copyObject: [v range]] with: ^ORInt(ORInt i) {
        return [v at: i];
    }];
    [_copyModel trackObject: o];
    _result = o;
}
-(void) visitIntMatrix:(id<ORIntMatrix>)v  {
    id<ORIntMatrix> o = [[ORIntMatrixI allocWithZone: _zone] initORIntMatrix: _copyModel with: (ORIntMatrixI*)v];
    [_copyModel trackObject: o];
    _result = o;
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v  {}
-(void) visitIdMatrix: (id<ORIdMatrix>) v  {
    id<ORIdMatrix> o = nil;
    if([v arity] == 2) {
        id<ORIntRange> r0 = [self copyObject: [v range: 0]];
        id<ORIntRange> r1 = [self copyObject: [v range: 1]];
        o = [[ORIdMatrixI allocWithZone: _zone] initORIdMatrix: _copyModel range: r0 : r1];
        for(int i = [r0 low]; i <= [r0 up]; i++) {
            for(int j = [r1 low]; j <= [r1 up]; j++) {
                id obj = [v at: i : j];
                id newObj = newObj = [self copyObject: obj];
                [o set: newObj at: i : j];
            }
        }
    }
    else if([v arity] == 3) {
        id<ORIntRange> r0 = [self copyObject: [v range: 0]];
        id<ORIntRange> r1 = [self copyObject: [v range: 1]];
        id<ORIntRange> r2 = [self copyObject: [v range: 2]];
        o = [[ORIdMatrixI allocWithZone: _zone] initORIdMatrix: _copyModel range: r0 : r1];
        for(int i = [r0 low]; i <= [r0 up]; i++) {
            for(int j = [r1 low]; j <= [r1 up]; j++) {
                for(int k = [r2 low]; k <= [r2 up]; k++) {
                    id obj = [v at: i : j : k];
                    id newObj = [self copyObject: obj];
                    [o set: newObj at: i : j : k];
                }
            }
        }

    }
    [_copyModel trackObject: o];
    _result = o;
}
-(void) visitTable:(id<ORTable>) v  {}

-(void) visitIdArray: (id<ORIdArray>) v  {
    id<ORIdArray> o = [[ORIdArrayI allocWithZone: _zone] initORIdArray: _copyModel range: [self copyObject: [v range]]];
    [v enumerateWith:^(id obj,int idx) {
        id newObj = [self copyObject: obj];
        [o set: newObj at: idx];
    }];
    [_copyModel trackObject: o];
    _result = o;
}

// Copy variables
-(void) visitIntVar: (id<ORIntVar>) v  {
    id<ORVar> var = [[ORIntVarI allocWithZone: _zone] initORIntVarI: _copyModel domain: [self copyObject: [v domain]]];
    _result = var;
}

-(void) visitFloatVar: (id<ORFloatVar>) v  {
}

-(void) visitBitVar: (id<ORBitVar>) v {
    id<ORVar> var = [[ORBitVarI allocWithZone: _zone] initORBitVarI: _copyModel low: [v low] up: [v up] bitLength: [v bitLength]];
    _result = var;
}

-(void) visitIntVarLitEQView:(id<ORIntVar>)v  {}
-(void) visitAffineVar:(id<ORIntVar>) v  {}

// Copy Constraints
-(void) visitConstraint:(id<ORConstraint>)c  {}
-(void) visitObjectiveFunction:(id<ORObjectiveFunction>)f  {}
-(void) visitFail:(id<ORFail>)cstr  {}
-(void) visitRestrict:(id<ORRestrict>)cstr  {
    id<ORIntSet> restriction = [self copyObject: [cstr restriction]];
    ORRestrict* c = [[ORRestrict allocWithZone: _zone] initRestrict: [self copyObject: [cstr var]] to: restriction];
    [_copyModel add: c];
    _result = c;
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr  {
    id<ORIntVarArray> arr = [self copyObject: [cstr array]];
    id<ORAlldifferent> c = [[ORAlldifferentI allocWithZone: _zone] initORAlldifferentI: arr annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitCardinality: (id<ORCardinality>) cstr  {
    id<ORIntVarArray> arr = [self copyObject: [cstr array]];
    id<ORIntArray> lowArr = [self copyObject: [cstr low]];
    id<ORIntArray> upArr = [self copyObject: [cstr up]];
    id<ORCardinality> c = [[ORCardinalityI allocWithZone: _zone] initORCardinalityI: arr low: lowArr up: upArr];
    [_copyModel add: c];
    _result = c;
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr  {
    id<ORAlgebraicConstraint> c = [[ORAlgebraicConstraintI allocWithZone: _zone]
                                   initORAlgebraicConstraintI: [self copyObject: [cstr expr]] annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr  {}
-(void) visitLexLeq:(id<ORLexLeq>) cstr  {}
-(void) visitCircuit:(id<ORCircuit>) cstr  {}
-(void) visitNoCycle:(id<ORNoCycle>) cstr  {}
-(void) visitPackOne:(id<ORPackOne>) cstr  {}
-(void) visitPacking:(id<ORPacking>) cstr  {
    id<ORIntVarArray> item = [self copyObject: [cstr item]];
    id<ORIntArray> itemSize = [self copyObject: [cstr itemSize]];
    id<ORIntVarArray> binSize = [self copyObject: [cstr binSize]];
    id<ORPacking> c = [[ORPackingI allocWithZone: _zone] initORPackingI: item itemSize: itemSize load: binSize];
    [_copyModel add: c];
    _result = c;
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr  {
    id<ORIntVarArray> item = [self copyObject: [cstr item]];
    id<ORIntArray> weight = [self copyObject: [cstr weight]];
    id<ORIntVar> capacity = [self copyObject: [cstr capacity]];
    id<ORKnapsack> c = [[ORKnapsackI allocWithZone: _zone] initORKnapsackI: item weight: weight capacity: capacity];
    [_copyModel add: c];
    _result = c;
}
-(void) visitAssignment:(id<ORAssignment>)cstr {
    id<ORIntVarArray> x = [self copyObject: [cstr x]];
    id<ORIntMatrix> matrix = [self copyObject: [cstr matrix]];
    id<ORIntVar> cost = [self copyObject: [cstr cost]];
    id<ORAssignment> c = [[ORAssignmentI allocWithZone: _zone] initORAssignment: x matrix: matrix cost: cost];
    [_copyModel add: c];
    _result = c;
}

-(void) visitMinimizeVar: (ORObjectiveFunctionVarI*) v
{
   id<ORIntVar> vc = [self copyObject:[v var]];
   _result = [_copyModel minimizeVar:vc];
}
-(void) visitMaximizeVar: (ORObjectiveFunctionVarI*) v
{
   id<ORIntVar> vc = [self copyObject:[v var]];
   _result = [_copyModel maximizeVar:vc];
}
-(void) visitMaximizeExpr: (ORObjectiveFunctionExprI*) e
{
   ORExprI* ec = [self copyObject:[e expr]];
   _result = [_copyModel maximize:ec];
}
-(void) visitMinimizeExpr: (ORObjectiveFunctionExprI*) e
{
   ORExprI* ec = [self copyObject:[e expr]];
   _result = [_copyModel minimize:ec];
}
-(void) visitMaximizeLinear: (ORObjectiveFunctionLinearI*) o
{
   id<ORIntVarArray> cv = [self copyObject:[o array]];
   id<ORIntArray> cCoef = [self copyObject:[o coef]];
   _result = [_copyModel maximize:cv coef:cCoef];
}
-(void) visitMinimizeLinear: (ORObjectiveFunctionLinearI*) o
{
   id<ORIntVarArray> cv = [self copyObject:[o array]];
   id<ORIntArray> cCoef = [self copyObject:[o coef]];
   _result = [_copyModel minimize:cv coef:cCoef];
}

-(void) visitEqualc: (id<OREqualc>)cstr  {
    id<OREqualc> c = [[OREqualc allocWithZone: _zone] initOREqualc: [self copyObject: [cstr left]]
                                                               eqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitNEqualc: (id<ORNEqualc>)cstr  {
    id<ORNEqualc> c = [[ORNEqualc allocWithZone: _zone] initORNEqualc: [self copyObject: [cstr left]]
                                                                 neqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitLEqualc: (id<ORLEqualc>)cstr  {
    id<ORLEqualc> c = [[ORLEqualc allocWithZone: _zone] initORLEqualc: [self copyObject: [cstr left]]
                                                                 leqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitGEqualc: (id<ORGEqualc>)cstr  {
    id<ORGEqualc> c = [[ORGEqualc allocWithZone: _zone] initORGEqualc: [self copyObject: [cstr left]]
                                                                 geqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitEqual: (id<OREqual>)cstr  {
    id<OREqual> c = [[OREqual allocWithZone: _zone] initOREqual: [self copyObject: [cstr left]]
                                                             eq: [self copyObject: [cstr right]] plus: [cstr cst]
                                                     annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitAffine: (id<ORAffine>)cstr  {}
-(void) visitNEqual: (id<ORNEqual>)cstr  {
    id<ORNEqual> c = [[ORNEqual allocWithZone: _zone] initORNEqual: [self copyObject: [cstr left]]
                                                               neq: [self copyObject: [cstr right]] plus: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitLEqual: (id<ORLEqual>)cstr  {
    id<ORLEqual> c = [[ORLEqual allocWithZone: _zone] initORLEqual: [self copyObject: [cstr left]]
                                                               leq: [self copyObject: [cstr right]] plus: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitPlus: (id<ORPlus>)cstr  {
    id<ORPlus> c = [[ORPlus allocWithZone: _zone] initORPlus: [self copyObject: [cstr res]]
                                                          eq: [self copyObject: [cstr left]]
                                                        plus: [self copyObject: [cstr right]]
                                                        annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitMult: (id<ORMult>)cstr  {
    id<ORMult> c = [[ORMult allocWithZone: _zone] initORMult: [self copyObject: [cstr res]]
                                                          eq: [self copyObject: [cstr left]]
                                                       times: [self copyObject: [cstr right]]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitMod: (id<ORMod>)cstr {
    id<ORMod> c = [[ORMod allocWithZone: _zone] initORMod: [self copyObject: [cstr left]]
                                                          mod: [self copyObject: [cstr right]]
                                                        equal: [self copyObject: [cstr res]]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitModc: (id<ORModc>)cstr {
    id<ORModc> c = [[ORModc allocWithZone: _zone] initORModc: [self copyObject: [cstr left]] mod: [cstr right]
                                                       equal: [self copyObject: [cstr res]]
                                                  annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitAbs: (id<ORAbs>)cstr  {
    id<ORAbs> c = [[ORAbs allocWithZone: _zone] initORAbs: [self copyObject: [cstr res]] eqAbs: [self copyObject: [cstr left]]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitOr: (id<OROr>)cstr  {
    id<OROr> c = [[OROr allocWithZone: _zone] initOROr: [self copyObject: [cstr res]]
                                                    eq: [self copyObject: [cstr left]]
                                                    or: [self copyObject: [cstr right]]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitAnd:( id<ORAnd>)cstr  {
    id<ORAnd> c = [[ORAnd allocWithZone: _zone] initORAnd: [self copyObject: [cstr res]]
                                                       eq: [self copyObject: [cstr left]]
                                                      and: [self copyObject: [cstr right]]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitImply: (id<ORImply>)cstr  {
    id<ORImply> c = [[ORImply allocWithZone: _zone] initORImply: [self copyObject: [cstr res]]
                                                             eq: [self copyObject: [cstr left]]
                                                          imply: [self copyObject: [cstr right]]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitElementCst: (id<ORElementCst>)cstr  {
    id<ORElementCst> c = [[ORElementCst allocWithZone: _zone] initORElement: [self copyObject: [cstr idx]]
                                                                      array: [self copyObject: [cstr array]]
                                                                      equal: [self copyObject: [cstr res]]
                                                                 annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitElementVar: (id<ORElementVar>)cstr  {
    id<ORElementVar> c = [[ORElementVar allocWithZone: _zone] initORElement: [self copyObject: [cstr idx]]
                                                                      array: [self copyObject: [cstr array]]
                                                                      equal: [self copyObject: [cstr res]]
                                                                 annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)cstr  {
    id<ORReifyEqualc> c = [[ORReifyEqualc allocWithZone: _zone] initReify: [self copyObject: [cstr b]]
                                                                    equiv: [self copyObject: [cstr x]]
                                                                      eqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitReifyEqual: (id<ORReifyEqual>)cstr  {
    id<ORReifyEqual> c = [[ORReifyEqual allocWithZone: _zone] initReify: [self copyObject: [cstr b]]
                                                                  equiv: [self copyObject: [cstr x]]
                                                                     eq: [self copyObject: [cstr y]]
                                                             annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)cstr  {
    id<ORReifyNEqualc> c = [[ORReifyNEqualc allocWithZone: _zone] initReify: [self copyObject: [cstr b]]
                                                                      equiv: [self copyObject: [cstr x]]
                                                                       neqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)cstr  {
    id<ORReifyNEqual> c = [[ORReifyNEqual allocWithZone: _zone] initReify: [self copyObject: [cstr b]]
                                                                    equiv: [self copyObject: [cstr x]]
                                                                      neq: [self copyObject: [cstr y]]
                                                               annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)cstr  {
    id<ORReifyLEqualc> c = [[ORReifyLEqualc allocWithZone: _zone] initReify: [self copyObject: [cstr b]]
                                                                      equiv: [self copyObject: [cstr x]]
                                                                       leqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)cstr  {
    id<ORReifyLEqual> c = [[ORReifyLEqual allocWithZone: _zone] initReify: [self copyObject: [cstr b]]
                                                                    equiv: [self copyObject: [cstr x]]
                                                                      leq: [self copyObject: [cstr y]]
                                                               annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)cstr  {
    id<ORReifyGEqualc> c = [[ORReifyGEqualc allocWithZone: _zone] initReify: [self copyObject: [cstr b]]
                                                                      equiv: [self copyObject: [cstr x]]
                                                                       geqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)cstr  {
    id<ORReifyGEqual> c = [[ORReifyGEqual allocWithZone: _zone] initReify: [self copyObject: [cstr b]]
                                                                    equiv: [self copyObject: [cstr x]]
                                                                      geq: [self copyObject: [cstr y]]
                                                               annotation: [cstr annotation]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr  {
    id<ORSumBoolEqc> c = [[ORSumBoolEqc allocWithZone: _zone] initSumBool: [self copyObject: [cstr vars]]
                                                                      eqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)cstr  {
    id<ORSumBoolLEqc> c = [[ORSumBoolLEqc allocWithZone: _zone] initSumBool: [self copyObject: [cstr vars]]
                                                                       leqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)cstr  {
    id<ORSumBoolGEqc> c = [[ORSumBoolGEqc allocWithZone: _zone] initSumBool: [self copyObject: [cstr vars]]
                                                                       geqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitSumEqualc:(id<ORSumEqc>)cstr  {
    id<ORSumEqc> c = [[ORSumEqc allocWithZone: _zone] initSum: [self copyObject: [cstr vars]] eqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)cstr  {
    id<ORSumLEqc> c = [[ORSumLEqc allocWithZone: _zone] initSum: [self copyObject: [cstr vars]] leqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)cstr  {
    id<ORSumGEqc> c = [[ORSumGEqc allocWithZone: _zone] initSum: [self copyObject: [cstr vars]] geqi: [cstr cst]];
    [_copyModel add: c];
    _result = c;
}

// Copy Bit Constrains
-(void) visitBitEqual:(id<ORBitEqual>)c {}
-(void) visitBitOr:(id<ORBitOr>)c {}
-(void) visitBitAnd:(id<ORBitAnd>)c {}
-(void) visitBitNot:(id<ORBitNot>)c {}
-(void) visitBitXor:(id<ORBitXor>)c {}
-(void) visitBitShiftL:(id<ORBitShiftL>)c {}
-(void) visitBitRotateL:(id<ORBitRotateL>)c {}
-(void) visitBitSum:(id<ORBitSum>)c {}
-(void) visitBitIf:(id<ORBitIf>)c {}

// Copy Expressions
-(void) visitIntegerI: (id<ORInteger>) e  {
    id<ORInteger> o = [[ORIntegerI allocWithZone: _zone] initORIntegerI: _copyModel value: [e value]];
    _result = o;
}
-(void) visitExprPlusI: (ORExprPlusI*) e  {
    id<ORExpr> o = [[ORExprPlusI allocWithZone: _zone] initORExprPlusI: [self copyObject: [e left]]
                                                                   and: [self copyObject: [e right]]];
    _result = o;
}
-(void) visitExprMinusI: (ORExprMinusI*) e  {
    id<ORExpr> o = [[ORExprMinusI allocWithZone: _zone] initORExprMinusI: [self copyObject: [e left]]
                                                                     and: [self copyObject: [e right]]];
    _result = o;
}
-(void) visitExprMulI: (ORExprMulI*) e  {
    id<ORExpr> o = [[ORExprMulI allocWithZone: _zone] initORExprMulI: [self copyObject: [e left]]
                                                                 and: [self copyObject: [e right]]];
    _result = o;
}
-(void) visitExprEqualI: (ORExprEqualI*) e  {
    id<ORExpr> o = [[ORExprEqualI allocWithZone: _zone] initORExprEqualI: [self copyObject: [e left]]
                                                                     and: [self copyObject: [e right]]];
    _result = o;
}
-(void) visitExprNEqualI: (ORExprNotEqualI*) e  {
    id<ORExpr> o = [[ORExprNotEqualI allocWithZone: _zone] initORExprNotEqualI: [self copyObject: [e left]]
                                                                           and: [self copyObject: [e right]]];
    _result = o;
}
-(void) visitExprLEqualI: (ORExprLEqualI*) e {
    id<ORExpr> o = [[ORExprLEqualI allocWithZone: _zone] initORExprLEqualI: [self copyObject: [e left]]
                                                                       and: [self copyObject: [e right]]];
    _result = o;
}
-(void) visitExprSumI: (ORExprSumI*) e {
    id<ORExpr> o = [[ORExprSumI allocWithZone: _zone] initORExprSumI: [self copyObject: [e expr]]];
    _result = o;
}
-(void) visitExprProdI: (ORExprProdI*) e {
    id<ORExpr> o = [[ORExprProdI allocWithZone: _zone] initORExprProdI: [self copyObject: [e expr]]];
    _result = o;
}
-(void) visitExprAbsI:(ORExprAbsI*) e {
    id<ORExpr> o = [[ORExprAbsI allocWithZone: _zone] initORExprAbsI: [self copyObject: [e operand]]];
    _result = o;

}
-(void) visitExprNegateI:(ORExprNegateI*) e {
    id<ORExpr> o = [[ORExprNegateI allocWithZone: _zone] initORNegateI:[self copyObject: [e operand]]];
    _result = o;
}
-(void) visitExprCstSubI: (ORExprCstSubI*) e  {
    ORExprCstSubI* o = [[ORExprCstSubI allocWithZone: _zone] initORExprCstSubI: [self copyObject: [e array]]
                                                                         index: [self copyObject: [e index]]];
    _result = o;
}
-(void) visitExprDisjunctI:(id<ORExpr>) e  {}
-(void) visitExprConjunctI: (id<ORExpr>) e  {}
-(void) visitExprImplyI: (id<ORExpr>) e  {}
-(void) visitExprAggOrI: (id<ORExpr>) e  {}
-(void) visitExprVarSubI: (id<ORExpr>) e  {}


@end



