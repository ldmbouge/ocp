/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORData.h>
#import <ORFoundation/ORParameter.h>

@protocol ORTrailableInt;
@protocol ORRealVar;
@protocol ORFloatVar;
@protocol ORDoubleVar;
@protocol ORLDoubleVar;
@protocol ORIntMatrix;
@protocol ORIdMatrix;
@protocol ORIdArray;
@protocol ORIntVar;
@protocol ORBitVar;
@protocol ORFail;
@protocol ORGroup;
@protocol ORObjectiveFunctionVar;
@protocol ORObjectiveFunctionExpr;
@protocol ORObjectiveFunctionLinear;
@protocol ORRestrict;
@protocol ORAlldifferent;
@protocol ORRegular;
@protocol ORCardinality;
@protocol ORAlgebraicConstraint;
@protocol ORTableConstraint;
@protocol ORLexLeq;
@protocol ORCircuit;
@protocol ORPath;
@protocol ORSubCircuit;
@protocol ORNoCycle;
@protocol ORPacking;
@protocol ORPackOne;
@protocol ORKnapsack;
@protocol ORMultiKnapsack;
@protocol ORMultiKnapsackOne;
@protocol ORMeetAtmost;
@protocol ORAssignment;
@protocol ORObjectiveFunction;
@protocol ORRealEqualc;
@protocol ORRealRange;
@protocol ORFloatRange;
@protocol ORDoubleRange;
@protocol ORLDoubleRange;



@interface ORVisitor : NSObject<NSObject>
-(void) visitRandomStream:(id) v;
-(void) visitZeroOneStream:(id) v;
-(void) visitUniformDistribution:(id) v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitRealRange:(id<ORRealRange>)v;
-(void) visitFloatRange:(id<ORFloatRange>)v;
-(void) visitDoubleRange:(id<ORDoubleRange>)v;
-(void) visitLDoubleRange:(id<ORLDoubleRange>)v;
-(void) visitIntArray:(id<ORIntArray>)v;
-(void) visitDoubleArray:(id<ORDoubleArray>)v;
-(void) visitFloatArray:(id<ORFloatArray>)v;
-(void) visitIntMatrix:(id<ORIntMatrix>)v;
-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitRealVar: (id<ORRealVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
-(void) visitDoubleVar: (id<ORDoubleVar>) v;
-(void) visitLDoubleVar: (id<ORLDoubleVar>) v;
-(void) visitIntVarLitEQView:(id<ORIntVar>)v;
-(void) visitAffineVar:(id<ORIntVar>) v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitTable:(id<ORTable>) v;
-(void) visitIntParam: (id<ORIntParam>) v;
-(void) visitRealParam: (id<ORRealParam>) v;

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
-(void) visitRealWeightedVar: (id<ORWeightedVar>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitLexLeq:(id<ORLexLeq>) cstr;
-(void) visitCircuit:(id<ORCircuit>) cstr;
-(void) visitPath:(id<ORPath>) cstr;
-(void) visitSubCircuit:(id<ORSubCircuit>) cstr;
-(void) visitNoCycle:(id<ORNoCycle>) cstr;
-(void) visitPackOne:(id<ORPackOne>) cstr;
-(void) visitPacking:(id<ORPacking>) cstr;
-(void) visitKnapsack:(id<ORKnapsack>) cstr;
-(void) visitMultiKnapsack:(id<ORMultiKnapsack>) cstr;
-(void) visitMultiKnapsackOne:(id<ORMultiKnapsackOne>) cstr;
-(void) visitMeetAtmost:(id<ORMeetAtmost>) cstr;
-(void) visitAssignment:(id<ORAssignment>)cstr;
-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o;
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o;

-(void) visitRealEqualc: (id<ORRealEqualc>)c;
-(void) visitEqualc: (id<ORConstraint>)c;
-(void) visitNEqualc: (id<ORConstraint>)c;
-(void) visitLEqualc: (id<ORConstraint>)c;
-(void) visitGEqualc: (id<ORConstraint>)c;
-(void) visitEqual: (id<ORConstraint>)c;
-(void) visitAffine: (id<ORConstraint>)c;
-(void) visitNEqual: (id<ORConstraint>)c;
-(void) visitSoftNEqual: (id<ORSoftNEqual>)c;
-(void) visitLEqual: (id<ORConstraint>)c;
-(void) visitPlus: (id<ORConstraint>)c;
-(void) visitMult: (id<ORConstraint>)c;
-(void) visitSquare: (id<ORConstraint>)c;
-(void) visitRealSquare: (id<ORConstraint>)c;
-(void) visitMod: (id<ORConstraint>)c;
-(void) visitModc: (id<ORConstraint>)c;
-(void) visitMin: (id<ORConstraint>)c;
-(void) visitMax: (id<ORConstraint>)c;
-(void) visitAbs: (id<ORConstraint>)c;
-(void) visitOr: (id<ORConstraint>)c;
-(void) visitAnd:( id<ORConstraint>)c;
-(void) visitImply: (id<ORConstraint>)c;
-(void) visitBinImply: (id<ORBinImply>)c;
-(void) visitElementCst: (id<ORConstraint>)c;
-(void) visitElementVar: (id<ORConstraint>)c;
-(void) visitElementBitVar: (id<ORConstraint>)c;
-(void) visitElementMatrixVar:(id<ORConstraint>)c;
-(void) visitRealElementCst: (id<ORConstraint>)c;
-(void) visitImplyEqualc: (id<ORConstraint>)c;
-(void) visitReifyEqualc: (id<ORConstraint>)c;
-(void) visitReifyEqual: (id<ORConstraint>)c;
-(void) visitReifyNEqualc: (id<ORConstraint>)c;
-(void) visitReifyNEqual: (id<ORConstraint>)c;
-(void) visitReifyLEqualc: (id<ORConstraint>)c;
-(void) visitReifyLEqual: (id<ORConstraint>)c;
-(void) visitReifyGEqualc: (id<ORConstraint>)c;
-(void) visitReifyGEqual: (id<ORConstraint>)c;
-(void) visitReifySumBoolEqualc: (id<ORConstraint>) c;
-(void) visitReifySumBoolGEqualc: (id<ORConstraint>) c;
-(void) visitHReifySumBoolEqualc: (id<ORConstraint>) c;
-(void) visitHReifySumBoolGEqualc: (id<ORConstraint>) c;
-(void) visitClause:(id<ORConstraint>)c;
-(void) visitSumBoolEqualc: (id<ORConstraint>) c;
-(void) visitSumBoolNEqualc: (id<ORConstraint>) c;
-(void) visitSumBoolLEqualc:(id<ORConstraint>)c;
-(void) visitSumBoolGEqualc:(id<ORConstraint>)c;
-(void) visitSumEqualc:(id<ORConstraint>)c;
-(void) visitSumLEqualc:(id<ORConstraint>)c;
-(void) visitSumGEqualc:(id<ORConstraint>)c;

-(void) visitLinearGeq: (id<ORConstraint>) c;
-(void) visitLinearLeq: (id<ORConstraint>) c;
-(void) visitLinearEq: (id<ORConstraint>) c;
-(void) visitRealLinearLeq: (id<ORConstraint>) c;
-(void) visitRealLinearGeq: (id<ORConstraint>) c;
-(void) visitRealLinearEq: (id<ORConstraint>) c;
-(void) visitFloatEqualc: (id<ORConstraint>)c;
-(void) visitFloatNEqualc: (id<ORConstraint>)c;
-(void) visitFloatLinearEq: (id<ORConstraint>) c;
-(void) visitFloatLinearNEq: (id<ORConstraint>) c;
-(void) visitFloatLinearLT: (id<ORConstraint>) c;
-(void) visitFloatLinearGT: (id<ORConstraint>) c;
-(void) visitFloatMult: (id<ORFloatMult>) c;
-(void) visitFloatDiv: (id<ORFloatDiv>) c;
-(void) visitFloatSSA: (id<ORFloatSSA>) c;



// Expressions
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e;
-(void) visitMutableDouble: (id<ORMutableDouble>) e;
-(void) visitFloat: (id<ORFloatNumber>) e;
-(void) visitDouble: (id<ORDoubleNumber>) e;
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
-(void) visitExprGEqualI: (id<ORExpr>) e;
-(void) visitExprLThenI: (id<ORExpr>) e;
-(void) visitExprGThenI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprProdI: (id<ORExpr>) e;
-(void) visitExprAggMinI: (id<ORExpr>) e;
-(void) visitExprAggMaxI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprSquareI:(id<ORExpr>)e;
-(void) visitExprNegateI:(id<ORExpr>)e;
-(void) visitExprCstSubI: (id<ORExpr>) e;
-(void) visitExprCstFloatSubI: (id<ORExpr>) e;
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e;
-(void) visitExprDisjunctI:(id<ORExpr>) e;
-(void) visitExprConjunctI: (id<ORExpr>) e;
-(void) visitExprImplyI: (id<ORExpr>) e;
-(void) visitExprAggOrI: (id<ORExpr>) e;
-(void) visitExprAggAndI: (id<ORExpr>) e;
-(void) visitExprVarSubI: (id<ORExpr>) e;
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e;
-(void) visitExprSSAI:(id<ORExpr>)e;

// Bit
-(void) visitBitEqualAt:(id<ORConstraint>)c;
-(void) visitBitEqualc:(id<ORConstraint>)c;
-(void) visitBitEqual:(id<ORConstraint>)c;
-(void) visitBitOr:(id<ORConstraint>)c;
-(void) visitBitAnd:(id<ORConstraint>)c;
-(void) visitBitNot:(id<ORConstraint>)c;
-(void) visitBitXor:(id<ORConstraint>)c;
-(void) visitBitShiftL:(id<ORConstraint>)c;
-(void) visitBitShiftL_BV:(id<ORConstraint>)c;
-(void) visitBitShiftR:(id<ORConstraint>)c;
-(void) visitBitShiftR_BV:(id<ORConstraint>)c;
-(void) visitBitShiftRA:(id<ORConstraint>)c;
-(void) visitBitShiftRA_BV:(id<ORConstraint>)c;
-(void) visitBitRotateL:(id<ORConstraint>)c;
-(void) visitBitSum:(id<ORConstraint>)cstr;
-(void) visitBitSubtract:(id<ORConstraint>)cstr;
-(void) visitBitMultiply:(id<ORConstraint>)cstr;
-(void) visitBitDivide:(id<ORConstraint>)cstr;
-(void) visitBitIf:(id<ORConstraint>)cstr;
-(void) visitBitCount:(id<ORConstraint>)cstr;
-(void) visitBitChannel:(id<ORBitChannel>)cstr;
-(void) visitBitZeroExtend:(id<ORConstraint>)c;
-(void) visitBitExtract:(id<ORConstraint>)c;
-(void) visitBitConcat:(id<ORConstraint>)c;
-(void) visitBitLogicalEqual:(id<ORConstraint>)c;
-(void) visitBitLT:(id<ORConstraint>)c;
-(void) visitBitLE:(id<ORConstraint>)c;
-(void) visitBitSLE:(id<ORConstraint>)c;
-(void) visitBitSLT:(id<ORConstraint>)c;
-(void) visitBitITE:(id<ORConstraint>)c;
-(void) visitBitLogicalAnd:(id<ORConstraint>)c;
-(void) visitBitLogicalOr:(id<ORConstraint>)c;
-(void) visitBitOrb:(id<ORConstraint>)c;
-(void) visitBitNotb:(id<ORConstraint>)c;
-(void) visitBitEqualb:(id<ORConstraint>)c;
-(void) visitBitNegative:(id<ORConstraint>)c;
-(void) visitBitSignExtend:(id<ORConstraint>)c;
-(void) visitBitDistinct:(id<ORConstraint>)c;
@end

@interface ORNOopVisit : ORVisitor
@end

