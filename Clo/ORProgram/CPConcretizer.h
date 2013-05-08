/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/CPSolver.h>

@interface ORCPBasicConcretizer  : NSObject
-(ORCPBasicConcretizer*) initORCPBasicConcretizer;
-(void) dealloc;

-(id) visitTrailableInt:(id<ORTrailableInt>)v engine: (id<CPEngine>) engine;
-(id) visitIntSet:(id<ORIntSet>)v engine: (id<CPEngine>) engine;
-(id) visitIntRange:(id<ORIntRange>)v engine: (id<CPEngine>) engine;
-(id) visitTable:(id<ORTable>) v engine: (id<CPEngine>) engine;

-(id) visitIntVar: (id<ORIntVar>) v engine: (id<CPEngine>) engine;
-(id) visitFloatVar: (id<ORFloatVar>) v engine: (id<CPEngine>) engine;
-(id) visitBitVar: (id<ORBitVar>) v engine:(id<CPEngine>)engine;
-(id) visitAffineVar:(id<ORIntVar>) v engine: (id<CPEngine>) engine;
-(id) visitIdArray: (id<ORIdArray>) v engine: (id<CPEngine>) engine;
-(id) visitIdMatrix: (id<ORIdMatrix>) v engine: (id<CPEngine>) engine;
-(id) visitIntArray:(id<ORIntArray>) v engine: (id<CPEngine>) engine;
-(id) visitFloatArray:(id<ORFloatArray>) v engine: (id<CPEngine>) engine;
-(id) visitIntMatrix:(id<ORIntMatrix>) v engine: (id<CPEngine>) engine;
-(id) visitRestrict:(id<ORRestrict>)cstr engine: (id<CPEngine>) engine;
-(id) visitAlldifferent: (id<ORAlldifferent>) cstr engine: (id<CPEngine>) engine;
-(id) visitCardinality: (id<ORCardinality>) cstr engine: (id<CPEngine>) engine;
-(id) visitPacking: (id<ORPacking>) cstr engine: (id<CPEngine>) engine;
-(id) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr engine: (id<CPEngine>) engine;
-(id) visitTableConstraint: (id<ORTableConstraint>) cstr engine: (id<CPEngine>) engine;
-(id) visitCircuit:(id<ORCircuit>) cstr engine: (id<CPEngine>) engine;
-(id) visitNoCycle:(id<ORNoCycle>) cstr engine: (id<CPEngine>) engine;
-(id) visitLexLeq:(id<ORLexLeq>) cstr engine: (id<CPEngine>) engine;
-(id) visitPackOne:(id<ORPackOne>) cstr engine: (id<CPEngine>) engine;
-(id) visitKnapsack:(id<ORKnapsack>) cstr engine: (id<CPEngine>) engine;
-(id) visitMinimize: (id<ORObjectiveFunction>) v engine: (id<CPEngine>) engine;
-(id) visitMaximize: (id<ORObjectiveFunction>) v engine: (id<CPEngine>) engine;
-(id) visitEqualc: (id<OREqualc>)c engine: (id<CPEngine>) engine;
-(id) visitNEqualc: (id<ORNEqualc>)c engine: (id<CPEngine>) engine;
-(id) visitLEqualc: (id<ORLEqualc>)c engine: (id<CPEngine>) engine;
-(id) visitGEqualc: (id<ORGEqualc>)c engine: (id<CPEngine>) engine;
-(id) visitEqual: (id<OREqual>)c engine: (id<CPEngine>) engine;
-(id) visitAffine: (id<ORAffine>)c engine:(id<CPEngine>)engine;
-(id) visitNEqual: (id<ORNEqual>)c engine: (id<CPEngine>) engine;
-(id) visitLEqual: (id<ORLEqual>)c engine: (id<CPEngine>) engine;
-(id) visitPlus: (id<ORPlus>)c engine: (id<CPEngine>) engine;
-(id) visitMult: (id<ORMult>)c engine: (id<CPEngine>) engine;
-(id) visitSquare: (id<ORSquare>)c engine:(id<CPEngine>)engine;
-(id) visitMod: (id<ORMod>)c engine:(id<CPEngine>) engine;
-(id) visitModc: (id<ORModc>)c engine:(id<CPEngine>) engine;
-(id) visitAbs: (id<ORAbs>)c engine: (id<CPEngine>) engine;
-(id) visitOr: (id<OROr>)c engine: (id<CPEngine>) engine;
-(id) visitAnd:( id<ORAnd>)c engine: (id<CPEngine>) engine;
-(id) visitImply: (id<ORImply>)c engine: (id<CPEngine>) engine;
-(id) visitElementCst: (id<ORElementCst>)c engine: (id<CPEngine>) engine;
-(id) visitElementVar: (id<ORElementVar>)c engine: (id<CPEngine>) engine;
-(id) visitReifyEqualc: (id<ORReifyEqualc>)c engine: (id<CPEngine>) engine;
-(id) visitReifyEqual: (id<ORReifyEqual>)c engine: (id<CPEngine>) engine;
-(id) visitReifyNEqualc: (id<ORReifyNEqualc>)c engine: (id<CPEngine>) engine;
-(id) visitReifyNEqual: (id<ORReifyNEqual>)c engine: (id<CPEngine>) engine;
-(id) visitReifyLEqualc: (id<ORReifyLEqualc>)c engine: (id<CPEngine>) engine;
-(id) visitReifyLEqual: (id<ORReifyLEqual>)c engine: (id<CPEngine>) engine;
-(id) visitReifyGEqualc: (id<ORReifyGEqualc>)c engine: (id<CPEngine>) engine;
-(id) visitReifyGEqual: (id<ORReifyGEqual>)c engine: (id<CPEngine>) engine;
-(id) visitSumBoolEqualc: (id<ORSumBoolEqc>) c engine: (id<CPEngine>) engine;
-(id) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c engine: (id<CPEngine>) engine;
-(id) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c engine: (id<CPEngine>) engine;
-(id) visitSumEqualc:(id<ORSumEqc>)c engine: (id<CPEngine>) engine;
-(id) visitSumLEqualc:(id<ORSumLEqc>)c engine: (id<CPEngine>) engine;
-(id) visitSumGEqualc:(id<ORSumGEqc>)c engine: (id<CPEngine>) engine;
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c engine: (id<CPEngine>) engine;
-(void) visitBitOr:(id<ORBitOr>)c engine: (id<CPEngine>) engine;
-(void) visitBitAnd:(id<ORBitAnd>)c engine: (id<CPEngine>) engine;
-(void) visitBitNot:(id<ORBitNot>)c engine: (id<CPEngine>) engine;
-(void) visitBitXor:(id<ORBitXor>)c engine: (id<CPEngine>) engine;
-(void) visitBitShiftL:(id<ORBitShiftL>)c engine: (id<CPEngine>) engine;
-(void) visitBitRotateL:(id<ORBitRotateL>)c engine: (id<CPEngine>) engine;
-(void) visitBitSum:(id<ORBitSum>)c engine: (id<CPEngine>) engine;
-(void) visitBitIf:(id<ORBitIf>)c engine: (id<CPEngine>) engine;
//
-(id) visitIntegerI: (id<ORInteger>) e engine: (id<CPEngine>) engine;
-(id) visitMutableIntegerI: (id<ORMutableInteger>) e engine: (id<CPEngine>) engine;
-(id) visitFloatI: (id<ORFloatNumber>) e engine: (id<CPEngine>) engine;
-(id) visitExprPlusI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprMinusI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprMulI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprDivI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprModI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprEqualI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprNEqualI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprLEqualI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprSumI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprProdI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprAbsI:(id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprNegateI:(id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprCstSubI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprDisjunctI:(id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprConjunctI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprImplyI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprAggOrI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
-(id) visitExprVarSubI: (id<ORExpr>) e engine: (id<CPEngine>) engine;
@end


@interface ORCPConcretizer  : NSObject<ORVisitor>
-(ORCPConcretizer*) initORCPConcretizer: (id<CPCommonProgram>) solver;
-(void) dealloc;

-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitTable:(id<ORTable>) v;

-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
-(void) visitAffineVar:(id<ORIntVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitIntArray:(id<ORIntArray>) v;
-(void) visitFloatArray:(id<ORIntArray>) v;
-(void) visitIntMatrix:(id<ORIntMatrix>) v;
-(void) visitRestrict:(id<ORRestrict>)cstr;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitPacking: (id<ORPacking>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitCircuit:(id<ORCircuit>) cstr;
-(void) visitNoCycle:(id<ORNoCycle>) cstr;
-(void) visitLexLeq:(id<ORLexLeq>) cstr;
-(void) visitPackOne:(id<ORPackOne>) cstr;
-(void) visitKnapsack:(id<ORKnapsack>) cstr;
-(void) visitAssignment:(id<ORAssignment>)cstr;
-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o;
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o;
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
-(void) visitMod: (id<ORMod>)c;
-(void) visitModc: (id<ORModc>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
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
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c;
-(void) visitBitOr:(id<ORBitOr>)c;
-(void) visitBitAnd:(id<ORBitAnd>)c;
-(void) visitBitNot:(id<ORBitNot>)c;
-(void) visitBitXor:(id<ORBitXor>)c;
-(void) visitBitShiftL:(id<ORBitShiftL>)c;
-(void) visitBitRotateL:(id<ORBitRotateL>)c;
-(void) visitBitSum:(id<ORBitSum>)c;
-(void) visitBitIf:(id<ORBitIf>)c;

//
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e;
-(void) visitFloatI: (id<ORFloatNumber>) e;
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprMinusI: (id<ORExpr>) e;
-(void) visitExprMulI: (id<ORExpr>) e;
-(void) visitExprDivI: (id<ORExpr>) e;
-(void) visitExprModI: (id<ORExpr>) e;
-(void) visitExprEqualI: (id<ORExpr>) e;
-(void) visitExprNEqualI: (id<ORExpr>) e;
-(void) visitExprLEqualI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprProdI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprNegateI:(id<ORExpr>) e;
-(void) visitExprCstSubI: (id<ORExpr>) e;
-(void) visitExprDisjunctI:(id<ORExpr>) e;
-(void) visitExprConjunctI: (id<ORExpr>) e;
-(void) visitExprImplyI: (id<ORExpr>) e;
-(void) visitExprAggOrI: (id<ORExpr>) e;
-(void) visitExprVarSubI: (id<ORExpr>) e;
@end

@interface ORCPMultiStartConcretizer  : NSObject<ORVisitor>
-(ORCPMultiStartConcretizer*) initORCPMultiStartConcretizer: (id<ORTracker>) tracker solver: (id<CPCommonProgram>) solver;
-(void) dealloc;

-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitTable:(id<ORTable>) v;

-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitAffineVar:(id<ORIntVar>) v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitIntArray:(id<ORIntArray>) v;
-(void) visitFloatArray:(id<ORIntArray>) v;
-(void) visitIntMatrix:(id<ORIntMatrix>) v;
-(void) visitRestrict:(id<ORRestrict>)cstr;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitPacking: (id<ORPacking>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitCircuit:(id<ORCircuit>) cstr;
-(void) visitNoCycle:(id<ORNoCycle>) cstr;
-(void) visitLexLeq:(id<ORLexLeq>) cstr;
-(void) visitPackOne:(id<ORPackOne>) cstr;
-(void) visitKnapsack:(id<ORKnapsack>) cstr;

-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o;
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o;

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
-(void) visitMod: (id<ORMod>)c;
-(void) visitModc: (id<ORModc>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
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
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c;
-(void) visitBitOr:(id<ORBitOr>)c;
-(void) visitBitAnd:(id<ORBitAnd>)c;
-(void) visitBitNot:(id<ORBitNot>)c;
-(void) visitBitXor:(id<ORBitXor>)c;
-(void) visitBitShiftL:(id<ORBitShiftL>)c;
-(void) visitBitRotateL:(id<ORBitRotateL>)c;
-(void) visitBitSum:(id<ORBitSum>)c;
-(void) visitBitIf:(id<ORBitIf>)c;
//
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e;
-(void) visitFloatI: (id<ORFloatNumber>) e;
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprMinusI: (id<ORExpr>) e;
-(void) visitExprMulI: (id<ORExpr>) e;
-(void) visitExprDivI: (id<ORExpr>) e;
-(void) visitExprModI: (id<ORExpr>) e;
-(void) visitExprEqualI: (id<ORExpr>) e;
-(void) visitExprNEqualI: (id<ORExpr>) e;
-(void) visitExprLEqualI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprProdI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprNegateI:(id<ORExpr>) e;
-(void) visitExprCstSubI: (id<ORExpr>) e;
-(void) visitExprDisjunctI:(id<ORExpr>) e;
-(void) visitExprConjunctI: (id<ORExpr>) e;
-(void) visitExprImplyI: (id<ORExpr>) e;
-(void) visitExprAggOrI: (id<ORExpr>) e;
-(void) visitExprVarSubI: (id<ORExpr>) e;
@end

