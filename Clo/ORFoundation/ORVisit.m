/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORVisit.h>
#import <ORFoundation/ORError.h>

@implementation ORVisitor

-(void) visitRandomStream:(id) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RandomStream: visit method not defined"];
}
-(void) visitZeroOneStream:(id) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ZeroOneStream: visit method not defined"];   
}
-(void) visitUniformDistribution:(id) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "UniformDistribution: visit method not defined"];    
}
-(void) visitIntSet:(id<ORIntSet>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntSet: visit method not defined"];    
}
-(void) visitIntRange:(id<ORIntRange>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntRange: visit method not defined"];    
}
-(void) visitFloatRange:(id<ORFloatRange>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatRange: visit method not defined"];    
}
-(void) visitIntArray:(id<ORIntArray>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntArray: visit method not defined"];    
}
-(void) visitFloatArray:(id<ORFloatArray>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatArray: visit method not defined"];    
}
-(void) visitIntMatrix:(id<ORIntMatrix>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntMatrix: visit method not defined"];    
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "TrailableInt: visit method not defined"];    
}
-(void) visitIntVar: (id<ORIntVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntVar: visit method not defined"];    
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatVar: visit method not defined"];    
}
-(void) visitBitVar: (id<ORBitVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitVar: visit method not defined"];    
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntVarLitEQView: visit method not defined"];    
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "AffineVar: visit method not defined"];    
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IdArray: visit method not defined"]; 
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IdMatrix: visit method not defined"]; 
}
-(void) visitTable:(id<ORTable>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Table: visit method not defined"]; 
}
-(void) visitConstraint:(id<ORConstraint>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Constraint: visit method not defined"]; 
}
-(void) visitGroup:(id<ORGroup>)g
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Group: visit method not defined"]; 
}
-(void) visitObjectiveFunctionVar:(id<ORObjectiveFunctionVar>)f
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ObjectiveFunctionVar: visit method not defined"]; 
}
-(void) visitObjectiveFunctionExpr:(id<ORObjectiveFunctionExpr>)f
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ObjectiveFunctionExpr: visit method not defined"]; 
}
-(void) visitObjectiveFunctionLinear:(id<ORObjectiveFunctionLinear>)f
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ObjectiveFunctionLinear: visit method not defined"]; 
}
-(void) visitFail:(id<ORFail>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Fail: visit method not defined"]; 
}
-(void) visitRestrict:(id<ORRestrict>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Restrict: visit method not defined"]; 
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Alldifferent: visit method not defined"]; 
}
-(void) visitRegular:(id<ORRegular>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Regular: visit method not defined"]; 
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cardinality: visit method not defined"]; 
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "AlgebraicConstraint: visit method not defined"]; 
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "TableConstraint: visit method not defined"]; 
}
-(void) visitLexLeq:(id<ORLexLeq>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "LexLeq: visit method not defined"]; 
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Circuit: visit method not defined"]; 
}
-(void) visitNoCycle:(id<ORNoCycle>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NoCycle: visit method not defined"]; 
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "PackOne: visit method not defined"]; 
}
-(void) visitPacking:(id<ORPacking>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Packing: visit method not defined"]; 
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Knapsack: visit method not defined"]; 
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Assignment: visit method not defined"]; 
}
-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MinimizeVar: visit method not defined"]; 
}
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MaximizeVar: visit method not defined"]; 
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MaximizeExpr: visit method not defined"]; 
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MinimizeExpr: visit method not defined"]; 
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MaximizeLinear: visit method not defined"]; 
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MinimizeLinear: visit method not defined"]; 
}
-(void) visitEqualc: (id<OREqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Equalc: visit method not defined"]; 
}
-(void) visitFloatEqualc: (id<ORFloatEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatEqualc: visit method not defined"];    
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NEqualc: visit method not defined"]; 
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "LEqualc: visit method not defined"]; 
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "GEqualc: visit method not defined"]; 
}
-(void) visitEqual: (id<OREqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Equal: visit method not defined"]; 
}
-(void) visitAffine: (id<ORAffine>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Affine: visit method not defined"]; 
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NEqual: visit method not defined"]; 
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "LEqual: visit method not defined"]; 
}
-(void) visitPlus: (id<ORPlus>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Plus: visit method not defined"]; 
}
-(void) visitMult: (id<ORMult>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Mult: visit method not defined"]; 
}
-(void) visitSquare:(id<ORSquare>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Square: visit method not defined"]; 
}
-(void) visitFloatSquare:(id<ORSquare>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatSquare: visit method not defined"]; 
}
-(void) visitMod: (id<ORMod>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Mod: visit method not defined"]; 
}
-(void) visitModc: (id<ORModc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Modc: visit method not defined"]; 
}
-(void) visitMin:(id<ORMin>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Min: visit method not defined"]; 
}
-(void) visitMax:(id<ORMax>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Max: visit method not defined"]; 
}
-(void) visitAbs: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Abs: visit method not defined"]; 
}
-(void) visitOr: (id<OROr>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Or: visit method not defined"]; 
}
-(void) visitAnd:( id<ORAnd>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "And: visit method not defined"]; 
}
-(void) visitImply: (id<ORImply>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Imply: visit method not defined"]; 
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ElementCst: visit method not defined"]; 
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ElementVar: visit method not defined"]; 
}
-(void) visitElementMatrixVar:(id<ORElementMatrixVar>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ElementMatrixVar: visit method not defined"];   
}
-(void) visitFloatElementCst: (id<ORFloatElementCst>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatElementCst: visit method not defined"]; 
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifyEqualc: visit method not defined"]; 
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifyEqual: visit method not defined"]; 
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifyNEqualc: visit method not defined"]; 
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifyNEqual: visit method not defined"]; 
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifyLEqualc: visit method not defined"]; 
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifyLEqual: visit method not defined"]; 
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifyGEqualc: visit method not defined"]; 
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifyGEqual: visit method not defined"]; 
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolEqualc: visit method not defined"]; 
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolLEqualc: visit method not defined"]; 
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolGEqualc: visit method not defined"]; 
}
-(void) visitSumEqualc:(id<ORSumEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumEqualc: visit method not defined"]; 
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumLEqualc: visit method not defined"]; 
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumGEqualc: visit method not defined"]; 
}
-(void) visitLinearGeq: (id<ORLinearGeq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "LinearGeq: visit method not defined"]; 
}
-(void) visitLinearLeq: (id<ORLinearLeq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "LinearLeq: visit method not defined"]; 
}
-(void) visitLinearEq: (id<ORLinearEq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "LinearEq: visit method not defined"]; 
}
-(void) visitFloatLinearLeq: (id<ORFloatLinearLeq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatLinearLeq: visit method not defined"]; 
}
-(void) visitFloatLinearEq: (id<ORFloatLinearEq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatLinearEq: visit method not defined"]; 
}
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitEqual: visit method not defined"]; 
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitOr: visit method not defined"]; 
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitAnd: visit method not defined"]; 
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitNot: visit method not defined"]; 
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitXor: visit method not defined"]; 
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitShiftL: visit method not defined"]; 
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitRotateL: visit method not defined"]; 
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitSum: visit method not defined"]; 
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitIf: visit method not defined"]; 
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntegerI: visit method not defined"]; 
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MutableIntegerI: visit method not defined"]; 
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MutableFloatI: visit method not defined"]; 
}
-(void) visitFloatI: (id<ORFloatNumber>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatI: visit method not defined"]; 
}
-(void) visitExprPlusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprPlusI: visit method not defined"]; 
}
-(void) visitExprMinusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprMinusI: visit method not defined"]; 
}
-(void) visitExprMulI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprMulI: visit method not defined"]; 
}
-(void) visitExprDivI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprDivI: visit method not defined"]; 
}
-(void) visitExprEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprEqualI: visit method not defined"]; 
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprNEqualI: visit method not defined"]; 
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprLEqualI: visit method not defined"]; 
}
-(void) visitExprSumI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprSumI: visit method not defined"]; 
}
-(void) visitExprProdI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprProdI: visit method not defined"]; 
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprAbsI: visit method not defined"]; 
}
-(void) visitExprSquareI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprSquareI: visit method not defined"]; 
}
-(void) visitExprModI:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprModI: visit method not defined"]; 
}
-(void) visitExprMinI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprMinI: visit method not defined"]; 
}
-(void) visitExprMaxI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprMaxI: visit method not defined"]; 
}
-(void) visitExprNegateI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprNegateI: visit method not defined"]; 
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstSubI: visit method not defined"]; 
}
-(void) visitExprCstFloatSubI:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstFloatSubI: visit method not defined"]; 
}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprDisjunctI: visit method not defined"]; 
}
-(void) visitExprConjunctI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprConjunctI: visit method not defined"]; 
}
-(void) visitExprImplyI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprImplyI: visit method not defined"]; 
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggOrI: visit method not defined"]; 
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggAndI: visit method not defined"]; 
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMinI: visit method not defined"]; 
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMaxI: visit method not defined"]; 
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprVarSubI: visit method not defined"]; 
}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprMatrixVarSubI: visit method not defined"];    
}
@end


@implementation ORNOopVisit
-(void) visitRandomStream:(id) v {}
-(void) visitZeroOneStream:(id) v {}
-(void) visitUniformDistribution:(id) v{}
-(void) visitIntSet:(id<ORIntSet>)v{}
-(void) visitIntRange:(id<ORIntRange>)v     {}
-(void) visitFloatRange:(id<ORFloatRange>)v {}
-(void) visitIntArray:(id<ORIntArray>)v  {}
-(void) visitFloatArray:(id<ORFloatArray>)v  {}
-(void) visitIntMatrix:(id<ORIntMatrix>)v  {}
-(void) visitTrailableInt:(id<ORTrailableInt>)v  {}
-(void) visitIntVar: (id<ORIntVar>) v  {}
-(void) visitFloatVar: (id<ORFloatVar>) v  {}
-(void) visitBitVar: (id<ORBitVar>) v {}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v  {}
-(void) visitAffineVar:(id<ORIntVar>) v  {}
-(void) visitIdArray: (id<ORIdArray>) v  {}
-(void) visitIdMatrix: (id<ORIdMatrix>) v  {}
-(void) visitTable:(id<ORTable>) v  {}
// micro-Constraints
-(void) visitConstraint:(id<ORConstraint>)c  {}
-(void) visitGroup:(id<ORGroup>)g {}
-(void) visitObjectiveFunctionVar:(id<ORObjectiveFunctionVar>)f  {}
-(void) visitObjectiveFunctionExpr:(id<ORObjectiveFunctionExpr>)f  {}
-(void) visitObjectiveFunctionLinear:(id<ORObjectiveFunctionLinear>)f  {}
-(void) visitFail:(id<ORFail>)cstr  {}
-(void) visitRestrict:(id<ORRestrict>)cstr  {}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr  {}
-(void) visitRegular:(id<ORRegular>) cstr {}
-(void) visitCardinality: (id<ORCardinality>) cstr  {}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr  {}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr  {}
-(void) visitLexLeq:(id<ORLexLeq>) cstr  {}
-(void) visitCircuit:(id<ORCircuit>) cstr  {}
-(void) visitNoCycle:(id<ORNoCycle>) cstr  {}
-(void) visitPackOne:(id<ORPackOne>) cstr  {}
-(void) visitPacking:(id<ORPacking>) cstr  {}
-(void) visitKnapsack:(id<ORKnapsack>) cstr  {}
-(void) visitAssignment:(id<ORAssignment>)cstr {}

-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v {}
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v {}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e {}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e {}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o {}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o {}

-(void) visitEqualc: (id<OREqualc>)c  {}
-(void) visitNEqualc: (id<ORNEqualc>)c  {}
-(void) visitLEqualc: (id<ORLEqualc>)c  {}
-(void) visitGEqualc: (id<ORGEqualc>)c  {}
-(void) visitEqual: (id<OREqual>)c  {}
-(void) visitAffine: (id<ORAffine>)c  {}
-(void) visitNEqual: (id<ORNEqual>)c  {}
-(void) visitLEqual: (id<ORLEqual>)c  {}
-(void) visitPlus: (id<ORPlus>)c  {}
-(void) visitMult: (id<ORMult>)c  {}
-(void) visitSquare:(id<ORSquare>)c {}
-(void) visitFloatSquare:(id<ORSquare>)c {}
-(void) visitMod: (id<ORMod>)c {}
-(void) visitModc: (id<ORModc>)c {}
-(void) visitMin:(id<ORMin>)c  {}
-(void) visitMax:(id<ORMax>)c  {}
-(void) visitAbs: (id<ORAbs>)c  {}
-(void) visitOr: (id<OROr>)c  {}
-(void) visitAnd:( id<ORAnd>)c  {}
-(void) visitImply: (id<ORImply>)c  {}
-(void) visitElementCst: (id<ORElementCst>)c  {}
-(void) visitElementVar: (id<ORElementVar>)c  {}
-(void) visitFloatElementCst: (id<ORFloatElementCst>) cstr {}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c  {}
-(void) visitReifyEqual: (id<ORReifyEqual>)c  {}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c  {}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c  {}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c  {}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c  {}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c  {}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c  {}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c  {}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c  {}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c  {}
-(void) visitSumEqualc:(id<ORSumEqc>)c  {}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c  {}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c  {}

-(void) visitLinearGeq: (id<ORLinearGeq>) c {}
-(void) visitLinearLeq: (id<ORLinearLeq>) c {}
-(void) visitLinearEq: (id<ORLinearEq>) c {}
-(void) visitFloatLinearLeq: (id<ORFloatLinearLeq>) c {}
-(void) visitFloatLinearEq: (id<ORFloatLinearEq>) c {}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c {}
-(void) visitBitOr:(id<ORBitOr>)c {}
-(void) visitBitAnd:(id<ORBitAnd>)c {}
-(void) visitBitNot:(id<ORBitNot>)c {}
-(void) visitBitXor:(id<ORBitXor>)c {}
-(void) visitBitShiftL:(id<ORBitShiftL>)c {}
-(void) visitBitRotateL:(id<ORBitRotateL>)c {}
-(void) visitBitSum:(id<ORBitSum>)c {}
-(void) visitBitIf:(id<ORBitIf>)c {}
// Expressions
-(void) visitIntegerI: (id<ORInteger>) e  {}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e  {}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e {}
-(void) visitFloatI: (id<ORFloatNumber>) e  {}
-(void) visitExprPlusI: (id<ORExpr>) e  {}
-(void) visitExprMinusI: (id<ORExpr>) e  {}
-(void) visitExprMulI: (id<ORExpr>) e  {}
-(void) visitExprDivI: (id<ORExpr>) e  {}
-(void) visitExprEqualI: (id<ORExpr>) e  {}
-(void) visitExprNEqualI: (id<ORExpr>) e  {}
-(void) visitExprLEqualI: (id<ORExpr>) e  {}
-(void) visitExprSumI: (id<ORExpr>) e  {}
-(void) visitExprProdI: (id<ORExpr>) e  {}
-(void) visitExprAbsI:(id<ORExpr>) e  {}
-(void) visitExprSquareI:(id<ORExpr>) e  {}
-(void) visitExprModI:(id<ORExpr>)e   {}
-(void) visitExprMinI: (id<ORExpr>) e {}
-(void) visitExprMaxI: (id<ORExpr>) e {}
-(void) visitExprNegateI:(id<ORExpr>) e  {}
-(void) visitExprCstSubI: (id<ORExpr>) e  {}
-(void) visitExprCstFloatSubI:(id<ORExpr>)e {}
-(void) visitExprDisjunctI:(id<ORExpr>) e  {}
-(void) visitExprConjunctI: (id<ORExpr>) e  {}
-(void) visitExprImplyI: (id<ORExpr>) e  {}
-(void) visitExprAggOrI: (id<ORExpr>) e  {}
-(void) visitExprAggAndI: (id<ORExpr>) e  {}
-(void) visitExprAggMinI: (id<ORExpr>) e  {}
-(void) visitExprAggMaxI: (id<ORExpr>) e  {}
-(void) visitExprVarSubI: (id<ORExpr>) e  {}
@end