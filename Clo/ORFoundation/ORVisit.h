/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORData.h>
//#import <ORFoundation/ORParameter.h>

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
@protocol ORIntParam;
@protocol ORRealParam;
@protocol ORFloatRange;
@protocol ORDoubleRange;
@protocol ORLDoubleRange;
@protocol ORInteger;
@protocol ORFloatNumber;
@protocol ORDoubleNumber;
@protocol ORMutableInteger;
@protocol ORMutableFloat;
@protocol ORMutableDouble;



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
-(void) visitLDoubleArray:(id<ORLDoubleArray>)v;
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
-(void) visitCDGroup:(id<ORGroup>)g;
-(void) visit3BGroup:(id<ORGroup>)g;
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
-(void) visitFloatEqual: (id<ORConstraint>)c;
-(void) visitDoubleEqual: (id<ORConstraint>)c;
-(void) visitAffine: (id<ORConstraint>)c;
-(void) visitNEqual: (id<ORConstraint>)c;
-(void) visitSoftNEqual: (id<ORSoftNEqual>)c;
-(void) visitLEqual: (id<ORConstraint>)c;
-(void) visitPlus: (id<ORConstraint>)c;
-(void) visitMult: (id<ORConstraint>)c;
-(void) visitSquare: (id<ORConstraint>)c;
-(void) visitRealSquare: (id<ORConstraint>)c;
-(void) visitRealMult: (id<ORConstraint>) c;
-(void) visitMod: (id<ORConstraint>)c;
-(void) visitModc: (id<ORConstraint>)c;
-(void) visitMin: (id<ORConstraint>)c;
-(void) visitMax: (id<ORConstraint>)c;
-(void) visitAbs: (id<ORConstraint>)c;
-(void) visitSqrt: (id<ORConstraint>)c;
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
-(void) visitSumSquare:(id<ORConstraint>)c;
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
-(void) visitRealMin:(id<ORConstraint>)c;
-(void) visitRealLinearLeq: (id<ORConstraint>) c;
-(void) visitRealLinearGeq: (id<ORConstraint>) c;
-(void) visitRealLinearEq: (id<ORConstraint>) c;
-(void) visitRealReifyEqual: (id<ORConstraint>) c;
-(void) visitRealReifyEqualc: (id<ORConstraint>) c;
-(void) visitRealReifyGEqualc: (id<ORConstraint>) c;
-(void) visitFloatAbs: (id<ORConstraint>)c;
-(void) visitFloatSqrt: (id<ORConstraint>)c;
-(void) visitFloatUnaryMinus:  (id<ORConstraint>) c;
-(void) visitFloatEqualc: (id<ORConstraint>)c;
-(void) visitFloatLThenc: (id<ORFloatLThenc>)c;
-(void) visitFloatLEqualc: (id<ORFloatLEqualc>)c;
-(void) visitFloatGThenc: (id<ORFloatGThenc>)c;
-(void) visitFloatGEqualc: (id<ORFloatGEqualc>)c;
-(void) visitFloatAssignC: (id<ORConstraint>)c;
-(void) visitFloatNEqualc: (id<ORConstraint>)c;
-(void) visitFloatLinearEq: (id<ORConstraint>) c;
-(void) visitFloatAssign: (id<ORConstraint>)c;
-(void) visitFloatLinearNEq: (id<ORConstraint>) c;
-(void) visitFloatLinearLT: (id<ORConstraint>) c;
-(void) visitFloatLinearGT: (id<ORConstraint>) c;
-(void) visitFloatLinearLEQ: (id<ORFloatLinearLEQ>) c;
-(void) visitFloatLinearGEQ: (id<ORFloatLinearGEQ>) c;
-(void) visitFloatSquare: (id<ORConstraint>) c;
-(void) visitFloatMult: (id<ORFloatMult>) c;
-(void) visitFloatDiv: (id<ORFloatDiv>) c;
-(void) visitFloatReifyEqualc: (id<ORConstraint>)c;
-(void) visitFloatReifyEqual: (id<ORConstraint>)c;
-(void) visitFloatReifyNEqualc: (id<ORConstraint>)c;
-(void) visitFloatReifyNEqual: (id<ORConstraint>)c;
-(void) visitFloatReifyLEqualc: (id<ORConstraint>)c;
-(void) visitFloatReifyLThen: (id<ORConstraint>)c;
-(void) visitFloatReifyLThenc: (id<ORConstraint>)c;
-(void) visitFloatReifyLEqual: (id<ORConstraint>)c;
-(void) visitFloatReifyGEqualc: (id<ORConstraint>)c;
-(void) visitFloatReifyGEqual: (id<ORConstraint>)c;
-(void) visitFloatReifyGThenc: (id<ORConstraint>)c;
-(void) visitFloatReifyGThen: (id<ORConstraint>)c;
-(void) visitFloatReifyAssignc: (id<ORConstraint>)c;
-(void) visitFloatReifyAssign: (id<ORConstraint>)c;
-(void) visitFloatCast: (id<ORConstraint>)c;
-(void) visitFloatIsZero: (id<ORConstraint>)c;
-(void) visitFloatIsPositive: (id<ORConstraint>)c;
-(void) visitFloatIsInfinite: (id<ORConstraint>)c;
-(void) visitFloatIsNormal: (id<ORConstraint>)c;
-(void) visitFloatIsSubnormal: (id<ORConstraint>)c;
-(void) visitDoubleIsSubnormal: (id<ORConstraint>)c;
-(void) visitDoubleIsNormal: (id<ORConstraint>)c;
-(void) visitDoubleIsInfinite: (id<ORConstraint>)c;
-(void) visitDoubleIsPositive: (id<ORConstraint>)c;
-(void) visitDoubleIsZero: (id<ORConstraint>)c;
-(void) visitDoubleCast: (id<ORConstraint>)c;
-(void) visitDoubleAbs: (id<ORConstraint>)c;
-(void) visitDoubleSqrt: (id<ORConstraint>)c;
-(void) visitDoubleUnaryMinus:  (id<ORConstraint>) c;
-(void) visitDoubleEqualc: (id<ORConstraint>)c;
-(void) visitDoubleLThenc: (id<ORDoubleLThenc>)c;
-(void) visitDoubleLEqualc: (id<ORDoubleLEqualc>)c;
-(void) visitDoubleGThenc: (id<ORDoubleGThenc>)c;
-(void) visitDoubleGEqualc: (id<ORDoubleGEqualc>)c;
-(void) visitDoubleNEqualc: (id<ORConstraint>)c;
-(void) visitDoubleLinearEq: (id<ORConstraint>) c;
-(void) visitDoubleLinearNEq: (id<ORConstraint>) c;
-(void) visitDoubleLinearLT: (id<ORConstraint>) c;
-(void) visitDoubleLinearGT: (id<ORConstraint>) c;
-(void) visitDoubleLinearLEQ: (id<ORDoubleLinearLEQ>) c;
-(void) visitDoubleLinearGEQ: (id<ORDoubleLinearGEQ>) c;
-(void) visitDoubleSquare: (id<ORConstraint>) c;
-(void) visitDoubleMult: (id<ORDoubleMult>) c;
-(void) visitDoubleDiv: (id<ORDoubleDiv>) c;
-(void) visitDoubleReifyEqualc: (id<ORConstraint>)c;
-(void) visitDoubleReifyEqual: (id<ORConstraint>)c;
-(void) visitDoubleReifyAssignc: (id<ORConstraint>)c;
-(void) visitDoubleReifyAssign: (id<ORConstraint>)c;
-(void) visitDoubleReifyNEqualc: (id<ORConstraint>)c;
-(void) visitDoubleReifyNEqual: (id<ORConstraint>)c;
-(void) visitDoubleReifyLEqualc: (id<ORConstraint>)c;
-(void) visitDoubleReifyLThen: (id<ORConstraint>)c;
-(void) visitDoubleReifyLThenc: (id<ORConstraint>)c;
-(void) visitDoubleReifyLEqual: (id<ORConstraint>)c;
-(void) visitDoubleReifyGEqualc: (id<ORConstraint>)c;
-(void) visitDoubleReifyGEqual: (id<ORConstraint>)c;
-(void) visitDoubleReifyGThenc: (id<ORConstraint>)c;
-(void) visitDoubleReifyGThen: (id<ORConstraint>)c;
-(void) visitDoubleAssignC: (id<ORConstraint>)c;
-(void) visitDoubleAssign: (id<ORConstraint>)c;


// Expressions
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e;
-(void) visitMutableFloatI: (id<ORMutableFloat>) e;
-(void) visitMutableDouble: (id<ORMutableDouble>) e;
-(void) visitFloat: (id<ORFloatNumber>) e;
-(void) visitDouble: (id<ORDoubleNumber>) e;
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprUnaryMinusI: (id<ORExpr>) e;
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
-(void) visitExprSqrtI:(id<ORExpr>) e;
-(void) visitExprToFloatI:(id<ORExpr>) e;
-(void) visitExprToDoubleI:(id<ORExpr>) e;
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
-(void) visitExprAssignI:(id<ORExpr>)e;
-(void) visitExprIsZeroI:(id<ORExpr>)e;
-(void) visitExprIsPositiveI:(id<ORExpr>)e;
-(void) visitExprIsInfiniteI:(id<ORExpr>)e;
-(void) visitExprIsNormalI:(id<ORExpr>)e;
-(void) visitExprIsSubnormalI:(id<ORExpr>)e;


// Bit
-(void) visitBitEqBool:(id<ORConstraint>)c;
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
-(void) visitBitDivideSigned:(id<ORConstraint>)cstr;
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
