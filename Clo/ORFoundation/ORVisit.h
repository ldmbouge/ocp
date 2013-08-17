/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORData.h>
#import <ORFoundation/ORVar.h>

@protocol ORTrailableInt;
@protocol ORFloatVar;

@interface ORVisitor : NSObject<NSObject>
-(void) visitRandomStream:(id) v;
-(void) visitZeroOneStream:(id) v;
-(void) visitUniformDistribution:(id) v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitFloatRange:(id<ORFloatRange>)v;
-(void) visitIntArray:(id<ORIntArray>)v;
-(void) visitFloatArray:(id<ORFloatArray>)v;
-(void) visitIntMatrix:(id<ORIntMatrix>)v;
-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
-(void) visitIntVarLitEQView:(id<ORIntVar>)v;
-(void) visitAffineVar:(id<ORIntVar>) v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitTable:(id<ORTable>) v;
// micro-Constraints
-(void) visitConstraint:(id<ORConstraint>)c;
-(void) visitGroup:(id<ORGroup>)g;
-(void) visitObjectiveFunctionVar:(id<ORObjectiveFunctionVar>)f;
-(void) visitObjectiveFunctionExpr:(id<ORObjectiveFunctionExpr>)f;
-(void) visitObjectiveFunctionLinear:(id<ORObjectiveFunctionLinear>)f;
-(void) visitFail:(id<ORFail>)cstr;
-(void) visitRestrict:(id<ORRestrict>)cstr;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitRegular:(id<ORRegular>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitLexLeq:(id<ORLexLeq>) cstr;
-(void) visitCircuit:(id<ORCircuit>) cstr;
-(void) visitNoCycle:(id<ORNoCycle>) cstr;
-(void) visitPackOne:(id<ORPackOne>) cstr;
-(void) visitPacking:(id<ORPacking>) cstr;
-(void) visitKnapsack:(id<ORKnapsack>) cstr;
-(void) visitAssignment:(id<ORAssignment>)cstr;
-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o;
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o;

-(void) visitFloatEqualc: (id<ORFloatEqualc>)c;
-(void) visitEqualc: (id<OREqualc>)c;
-(void) visitNEqualc: (id<ORNEqualc>)c;
-(void) visitLEqualc: (id<ORLEqualc>)c;
-(void) visitGEqualc: (id<ORGEqualc>)c;
-(void) visitEqual: (id<OREqual>)c;
-(void) visitAffine: (id<ORAffine>)c;
-(void) visitNEqual: (id<ORNEqual>)c;
-(void) visitLEqual: (id<ORLEqual>)c;
-(void) visitPlus: (id<ORPlus>)c;
-(void) visitMult: (id<ORMult>)c;
-(void) visitSquare: (id<ORSquare>)c;
-(void) visitFloatSquare: (id<ORSquare>)c;
-(void) visitMod: (id<ORMod>)c;
-(void) visitModc: (id<ORModc>)c;
-(void) visitMin: (id<ORMin>)c;
-(void) visitMax: (id<ORMax>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
-(void) visitElementMatrixVar:(id<ORElementMatrixVar>)c;
-(void) visitFloatElementCst: (id<ORFloatElementCst>)c;
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c;
-(void) visitReifyEqual: (id<ORReifyEqual>)c;
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c;
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c;
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c;
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c;
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c;
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c;
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c;
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c;
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c;
-(void) visitSumEqualc:(id<ORSumEqc>)c;
-(void) visitSumLEqualc:(id<ORSumLEqc>)c;
-(void) visitSumGEqualc:(id<ORSumGEqc>)c;

-(void) visitLinearGeq: (id<ORLinearGeq>) c;
-(void) visitLinearLeq: (id<ORLinearLeq>) c;
-(void) visitLinearEq: (id<ORLinearEq>) c;
-(void) visitFloatLinearLeq: (id<ORFloatLinearLeq>) c;
-(void) visitFloatLinearEq: (id<ORFloatLinearEq>) c;


// Expressions
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e;
-(void) visitMutableFloatI: (id<ORMutableFloat>) e;
-(void) visitFloatI: (id<ORFloatNumber>) e;
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprMinusI: (id<ORExpr>) e;
-(void) visitExprMulI: (id<ORExpr>) e;
-(void) visitExprDivI: (id<ORExpr>) e;
-(void) visitExprModI: (id<ORExpr>) e;
-(void) visitExprMinI: (id<ORExpr>) e;
-(void) visitExprMaxI: (id<ORExpr>) e;
-(void) visitExprEqualI: (id<ORExpr>) e;
-(void) visitExprNEqualI: (id<ORExpr>) e;
-(void) visitExprLEqualI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprProdI: (id<ORExpr>) e;
-(void) visitExprAggMinI: (id<ORExpr>) e;
-(void) visitExprAggMaxI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprSquareI:(id<ORExpr>)e;
-(void) visitExprNegateI:(id<ORExpr>)e;
-(void) visitExprCstSubI: (id<ORExpr>) e;
-(void) visitExprCstFloatSubI:(id<ORExpr>)e;
-(void) visitExprDisjunctI:(id<ORExpr>) e;
-(void) visitExprConjunctI: (id<ORExpr>) e;
-(void) visitExprImplyI: (id<ORExpr>) e;
-(void) visitExprAggOrI: (id<ORExpr>) e;
-(void) visitExprAggAndI: (id<ORExpr>) e;
-(void) visitExprVarSubI: (id<ORExpr>) e;
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e;
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c;
-(void) visitBitOr:(id<ORBitOr>)c;
-(void) visitBitAnd:(id<ORBitAnd>)c;
-(void) visitBitNot:(id<ORBitNot>)c;
-(void) visitBitXor:(id<ORBitXor>)c;
-(void) visitBitShiftL:(id<ORBitShiftL>)c;
-(void) visitBitRotateL:(id<ORBitRotateL>)c;
-(void) visitBitSum:(id<ORBitSum>)cstr;
-(void) visitBitIf:(id<ORBitIf>)cstr;
@end

@interface ORNOopVisit : ORVisitor
@end

