/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORVisit.h>
#import <ORFoundation/ORError.h>
#import <ORFoundation/ORConstraint.h>

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
-(void) visitRealRange:(id<ORRealRange>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "realRange: visit method not defined"];    
}
-(void) visitFloatRange:(id<ORFloatRange>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatRange: visit method not defined"];
}
-(void) visitRationalRange:(id<ORRationalRange>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalRange: visit method not defined"];
}
-(void) visitDoubleRange:(id<ORDoubleRange>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleRange: visit method not defined"];
}
-(void) visitLDoubleRange:(id<ORLDoubleRange>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "LDoubleRange: visit method not defined"];
}
-(void) visitIntArray:(id<ORIntArray>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntArray: visit method not defined"];    
}
-(void) visitFloatArray:(id<ORFloatArray>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "floatArray: visit method not defined"];
}
-(void) visitRationalArray:(id<ORRationalArray>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "rationalArray: visit method not defined"];
}
-(void) visitDoubleArray:(id<ORDoubleArray>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "doubleArray: visit method not defined"];    
}
-(void) visitLDoubleArray:(id<ORLDoubleArray>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ldoubleArray: visit method not defined"];
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
-(void) visitRealVar: (id<ORRealVar>) v
{

   @throw [[ORExecutionError alloc] initORExecutionError: "RealVar: visit method not defined"];
}
//-------------------------
-(void) visitFloatVar: (id<ORFloatVar>) v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatVar: visit method not defined"];
}
-(void) visitRationalVar: (id<ORRationalVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalVar: visit method not defined"];
}
-(void) visitDoubleVar: (id<ORDoubleVar>) v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleVar: visit method not defined"];
}
-(void) visitLDoubleVar: (id<ORLDoubleVar>) v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "LDoubleVar: visit method not defined"];
}
//-------------------------
-(void) visitExprAssignI:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "visitExprAssignI: visit method not defined"];
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
-(void) visitIntParam: (id<ORIntParam>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntParam: visit method not defined"];
}
-(void) visitRealParam: (id<ORRealParam>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealParam: visit method not defined"];
}
-(void) visitConstraint:(id<ORConstraint>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Constraint: visit method not defined"]; 
}
-(void) visitGroup:(id<ORGroup>)g
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Group: visit method not defined"]; 
}
-(void) visitCDGroup:(id<ORGroup>)g
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CDGroup: visit method not defined"];
}
-(void) visit3BGroup:(id<ORGroup>)g
{
   @throw [[ORExecutionError alloc] initORExecutionError: "3BGroup: visit method not defined"];
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
-(void) visitRealWeightedVar: (id<ORWeightedVar>) cstr;
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealWeightedVar: visit method not defined"];
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
-(void) visitPath:(id<ORPath>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Path: visit method not defined"];
}
-(void) visitSubCircuit:(id<ORSubCircuit>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SubCircuit: visit method not defined"];
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
-(void) visitMultiKnapsack:(id<ORMultiKnapsack>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MultiKnapsack: visit method not defined"];
}
-(void) visitMultiKnapsackOne:(id<ORMultiKnapsackOne>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MultiKnapsackOne: visit method not defined"];
}
-(void) visitMeetAtmost:(id<ORMeetAtmost>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MeetAtmost: visit method not defined"];
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
-(void) visitFloatUnaryMinus:(id<ORUnaryMinus>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatUnaryMinus: visit method not defined"];
}
-(void) visitFloatEqualc: (id<ORFloatEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatEqualc: visit method not defined"];
}
-(void) visitFloatGThenc: (id<ORFloatGThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatGThenc: visit method not defined"];
}
-(void) visitFloatLThenc: (id<ORFloatLThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatLThenc: visit method not defined"];
}
-(void) visitFloatLEqualc: (id<ORFloatLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatLEqualc: visit method not defined"];
}
-(void) visitFloatGEqualc: (id<ORFloatGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatLEqualc: visit method not defined"];
}
-(void) visitRationalUnaryMinus:(id<ORConstraint>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalUnaryMinus: visit method not defined"];
}
-(void) visitRationalEqualc: (id<ORRationalEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalEqualc: visit method not defined"];
}
-(void) visitRationalLEqualc: (id<ORRationalLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalLEqualc: visit method not defined"];
}
-(void) visitRationalGEqualc: (id<ORRationalGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalGEqualc: visit method not defined"];
}
-(void) visitRationalErrorOf: (id<ORRationalErrorOf>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalErrorOf: visit method not defined"];
}
-(void) visitRationalUlpOf: (id<ORRationalUlpOf>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalUlpOf: visit method not defined"];
}
-(void) visitRationalChannel: (id<ORRationalChannel>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalChannel: visit method not defined"];
}
-(void) visitFloatAssignC: (id<ORFloatAssignC>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "FloatAssignc: visit method not defined"];
}
-(void) visitDoubleUnaryMinus:(id<ORUnaryMinus>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleUnaryMinus: visit method not defined"];
}
-(void) visitRationalAssignC: (id<ORRationalAssignC>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalAssignc: visit method not defined"];
}
-(void) visitDoubleEqualc: (id<ORDoubleEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleEqualc: visit method not defined"];
}
-(void) visitDoubleGEqualc: (id<ORDoubleGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleGEqualc: visit method not defined"];
}
-(void) visitDoubleLEqualc: (id<ORDoubleLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleLEqualc: visit method not defined"];
}
-(void) visitDoubleGThenc: (id<ORDoubleGThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleGThenc: visit method not defined"];
}
-(void) visitDoubleLThenc: (id<ORDoubleLThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleLThenc: visit method not defined"];
}
-(void) visitRealEqualc: (id<ORRealEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealEqualc: visit method not defined"];    
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NEqualc: visit method not defined"]; 
}
-(void) visitFloatNEqualc: (id<ORFloatNEqualc>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatNEqualc: visit method not defined"];
}
-(void) visitRationalNEqualc: (id<ORRationalNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalNEqualc: visit method not defined"];
}
-(void) visitDoubleNEqualc: (id<ORDoubleNEqualc>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleNEqualc: visit method not defined"];
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
-(void) visitSoftNEqual: (id<ORSoftNEqual>)c {
    @throw [[ORExecutionError alloc] initORExecutionError: "SoftNEqual: visit method not defined"];
}
-(void) visitAffine: (id<ORAffine>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Affine: visit method not defined"]; 
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NEqual: visit method not defined"]; 
}
-(void) visitFloatAssign: (id<ORFloatAssign>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatAssign: visit method not defined"];
}
-(void) visitDoubleCast: (id<ORCast>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleCast: visit method not defined"];
}
-(void) visitFloatCast: (id<ORCast>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatCast: visit method not defined"];
}
-(void) visitRationalAssign: (id<ORRationalAssign>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalAssign: visit method not defined"];
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
-(void) visitRealSquare:(id<ORSquare>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealSquare: visit method not defined"]; 
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
-(void) visitSqrt: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Sqrt: visit method not defined"];
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
-(void) visitBinImply: (id<ORBinImply>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BinImply: visit method not defined"];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ElementCst: visit method not defined"]; 
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ElementVar: visit method not defined"]; 
}
-(void) visitElementBitVar: (id<ORElementBitVar>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ElementBitVar: visit method not defined"];
}
-(void) visitElementMatrixVar:(id<ORElementMatrixVar>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ElementMatrixVar: visit method not defined"];   
}
-(void) visitRealElementCst: (id<ORRealElementCst>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealElementCst: visit method not defined"]; 
}
-(void) visitImplyEqualc: (id<ORImplyEqualc>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ImplyEqualc: visit method not defined"];
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
-(void) visitReifySumBoolEqualc: (id<ORReifySumBoolEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifySumBoolEqualc: visit method not defined"];
}
-(void) visitReifySumBoolGEqualc: (id<ORReifySumBoolGEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ReifySumBoolGEqualc: visit method not defined"];
}
-(void) visitHReifySumBoolEqualc: (id<ORReifySumBoolEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "HReifySumBoolEqualc: visit method not defined"];
}
-(void) visitHReifySumBoolGEqualc: (id<ORReifySumBoolGEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "HReifySumBoolGEqualc: visit method not defined"];
}
-(void) visitFloatAbs: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Abs: visit method not defined"];
}
-(void) visitFloatSqrt: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Sqrt: visit method not defined"];
}
-(void) visitFloatReifyEqualc: (id<ORFloatReifyEqualc>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatReifyEqualc: visit method not defined"];
}
-(void) visitRationalReifyEqualc: (id<ORRationalReifyEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalReifyEqualc: visit method not defined"];
}
-(void) visitFloatReifyEqual: (id<ORFloatReifyEqual>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatReifyEqual: visit method not defined"];
}
-(void) visitRationalReifyEqual: (id<ORRationalReifyEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalReifyEqual: visit method not defined"];
}
-(void) visitFloatReifyNEqualc: (id<ORFloatReifyNEqualc>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatReifyNEqualc: visit method not defined"];
}
-(void) visitRationalReifyNEqualc: (id<ORRationalReifyNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalReifyNEqualc: visit method not defined"];
}
-(void) visitFloatReifyNEqual: (id<ORFloatReifyNEqual>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatReifyNEqual: visit method not defined"];
}
-(void) visitRationalReifyNEqual: (id<ORRationalReifyNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalReifyNEqual: visit method not defined"];
}
-(void) visitFloatReifyLEqualc: (id<ORFloatReifyLEqualc>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatReifyLEqualc: visit method not defined"];
}
-(void) visitRationalReifyLEqualc: (id<ORRationalReifyLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalReifyLEqualc: visit method not defined"];
}
-(void) visitFloatReifyLEqual: (id<ORFloatReifyLEqual>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatReifyLEqual: visit method not defined"];
}
-(void) visitRationalReifyLEqual: (id<ORRationalReifyLEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalReifyLEqual: visit method not defined"];
}
-(void) visitFloatReifyLThen: (id<ORFloatReifyLThen>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatReifyLThen: visit method not defined"];
}
-(void) visitRationalReifyLThen: (id<ORRationalReifyLThen>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalReifyLThen: visit method not defined"];
}
-(void) visitFloatReifyLThenc: (id<ORFloatReifyLThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatReifyLThenc: visit method not defined"];
}
-(void) visitRationalReifyLThenc: (id<ORRationalReifyLThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalsReifyLThenc: visit method not defined"];
}
-(void) visitFloatReifyGEqualc: (id<ORFloatReifyGEqualc>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatReifyGEqualc: visit method not defined"];
}
-(void) visitRationalReifyGEqualc: (id<ORRationalReifyGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalReifyGEqualc: visit method not defined"];
}
-(void) visitFloatReifyGEqual: (id<ORFloatReifyGEqual>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatReifyGEqual: visit method not defined"];
}
-(void) visitRationalReifyGEqual: (id<ORRationalReifyGEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalReifyGEqual: visit method not defined"];
}
-(void) visitFloatReifyGThen: (id<ORFloatReifyGThen>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatReifyGThen: visit method not defined"];
}
-(void) visitRationalReifyGThen: (id<ORRationalReifyGThen>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalReifyGThen: visit method not defined"];
}
-(void) visitFloatReifyGThenc: (id<ORFloatReifyGThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatReifyGThenc: visit method not defined"];
}
-(void) visitDoubleAbs: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Abs: visit method not defined"];
}
-(void) visitDoubleSqrt: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Sqrt: visit method not defined"];
}
-(void) visitRationalReifyGThenc: (id<ORRationalReifyGThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalReifyGThenc: visit method not defined"];
}
-(void) visitDoubleReifyEqualc: (id<ORDoubleReifyEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleReifyEqualc: visit method not defined"];
}
-(void) visitDoubleReifyEqual: (id<ORDoubleReifyEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleReifyEqual: visit method not defined"];
}
-(void) visitDoubleReifyNEqualc: (id<ORDoubleReifyNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleReifyNEqualc: visit method not defined"];
}
-(void) visitDoubleReifyNEqual: (id<ORDoubleReifyNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleReifyNEqual: visit method not defined"];
}
-(void) visitDoubleReifyLEqualc: (id<ORDoubleReifyLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleReifyLEqualc: visit method not defined"];
}
-(void) visitDoubleReifyLEqual: (id<ORDoubleReifyLEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleReifyLEqual: visit method not defined"];
}
-(void) visitDoubleReifyLThen: (id<ORDoubleReifyLThen>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleReifyLThen: visit method not defined"];
}
-(void) visitDoubleReifyLThenc: (id<ORDoubleReifyLThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleReifyLThenc: visit method not defined"];
}
-(void) visitDoubleReifyGEqualc: (id<ORDoubleReifyGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleReifyGEqualc: visit method not defined"];
}
-(void) visitDoubleReifyGEqual: (id<ORDoubleReifyGEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "DoubleReifyGEqual: visit method not defined"];
}
-(void) visitDoubleReifyGThen: (id<ORDoubleReifyGThen>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleReifyGThen: visit method not defined"];
}
-(void) visitDoubleReifyGThenc: (id<ORDoubleReifyGThenc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleReifyGThenc: visit method not defined"];
}
-(void) visitDoubleAssignC: (id<ORDoubleAssignC>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "visitDoubleAssignC: visit method not defined"];
}
-(void) visitDoubleAssign: (id<ORDoubleAssign>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "visitDoubleAssign: visit method not defined"];
}
-(void) visitClause:(id<ORClause>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Clause: visit method not defined"];
}
-(void) visitSumSquare: (id<ORSumSquare>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumSquare: visit method not defined"];
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolEqualc: visit method not defined"]; 
}
-(void) visitSumBoolNEqualc: (id<ORSumBoolEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolNEqualc: visit method not defined"];
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
-(void) visitFloatLinearEq: (id<ORFloatLinearEq>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatLineareq: visit method not defined"];
}
-(void) visitFloatLinearNEq: (id<ORFloatLinearNEq>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatLinearNeq: visit method not defined"];
}
-(void) visitFloatLinearLT: (id<ORFloatLinearLT>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatLinearLT: visit method not defined"];
}
-(void) visitFloatLinearGT: (id<ORFloatLinearGT>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatLinearLT: visit method not defined"];
}
-(void) visitFloatLinearLEQ: (id<ORFloatLinearLEQ>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatLinearLEQ: visit method not defined"];
}
-(void) visitFloatLinearGEQ: (id<ORFloatLinearGEQ>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatLinearGEQ: visit method not defined"];
}
-(void) visitFloatMult: (id<ORFloatMult>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatMult: visit method not defined"];
}
-(void) visitFloatDiv: (id<ORFloatDiv>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORFloatDiv: visit method not defined"];
}
-(void) visitRationalLinearEq: (id<ORRationalLinearEq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalLineareq: visit method not defined"];
}
-(void) visitRationalLinearNEq: (id<ORRationalLinearNEq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalLinearNeq: visit method not defined"];
}
-(void) visitRationalLinearLT: (id<ORRationalLinearLT>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalLinearLT: visit method not defined"];
}
-(void) visitRationalLinearGT: (id<ORRationalLinearGT>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalLinearLT: visit method not defined"];
}
-(void) visitRationalLinearLEQ: (id<ORRationalLinearLEQ>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalLinearLEQ: visit method not defined"];
}
-(void) visitRationalLinearGEQ: (id<ORRationalLinearGEQ>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalLinearGEQ: visit method not defined"];
}
-(void) visitRationalMult: (id<ORRationalMult>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalMult: visit method not defined"];
}
-(void) visitRationalDiv: (id<ORRationalDiv>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRationalDiv: visit method not defined"];
}
-(void) visitRationalAbs: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Abs: visit method not defined"];
}
-(void) visitDoubleLinearEq: (id<ORDoubleLinearEq>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleLinearLeq: visit method not defined"];
}
-(void) visitDoubleLinearNEq: (id<ORDoubleLinearNEq>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleLinearNeq: visit method not defined"];
}
-(void) visitDoubleLinearLT: (id<ORDoubleLinearLT>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleLinearLT: visit method not defined"];
}
-(void) visitDoubleLinearGT: (id<ORDoubleLinearGT>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleLinearLT: visit method not defined"];
}
-(void) visitDoubleLinearLEQ: (id<ORDoubleLinearLEQ>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleLinearLEQ: visit method not defined"];
}
-(void) visitDoubleLinearGEQ: (id<ORDoubleLinearGEQ>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleLinearGEQ: visit method not defined"];
}
-(void) visitDoubleMult: (id<ORDoubleMult>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleMult: visit method not defined"];
}
-(void) visitDoubleDiv: (id<ORDoubleDiv>) c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ORDoubleDiv: visit method not defined"];
}
-(void) visitRealMult: (id<ORRealMult>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRealMult: visit method not defined"];
}
-(void) visitRealMin: (id<ORRealMin>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealMin: visit method not defined"];
}
-(void) visitRealLinearLeq: (id<ORRealLinearLeq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealLinearLeq: visit method not defined"]; 
}
-(void) visitRealLinearGeq: (id<ORRealLinearGeq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealLinearGeq: visit method not defined"];
}
-(void) visitRealLinearEq: (id<ORRealLinearEq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RealLinearEq: visit method not defined"]; 
}
-(void) visitRealReifyEqual: (id<ORRealReifyEqual>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRealReifyEqual: visit method not defined"];
}
-(void) visitRealReifyEqualc: (id<ORRealReifyEqualc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRealReifyEqualc: visit method not defined"];
}
-(void) visitRealReifyGEqualc: (id<ORRealReifyGEqualc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORRealReifyGEqualc: visit method not defined"];
}
-(void) visitBitEqBool:(id<ORConstraint>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitEqBool: visit method not defined"];
}
-(void) visitBitEqualAt:(id<ORConstraint>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitEqualAt: visit method not defined"];
}
-(void) visitBitEqualc:(id<ORConstraint>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitEqualc: visit method not defined"];
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
-(void) visitBitShiftL_BV:(id<ORBitShiftL_BV>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitShiftL_BV: visit method not defined"];
}
-(void) visitBitShiftR:(id<ORBitShiftR>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitShiftR: visit method not defined"];
}
-(void) visitBitShiftR_BV:(id<ORBitShiftR_BV>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitShiftR_BV: visit method not defined"];
}
-(void) visitBitShiftRA:(id<ORBitShiftRA>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitShiftRA: visit method not defined"];
}
-(void) visitBitShiftRA_BV:(id<ORBitShiftRA_BV>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitShiftRA_BV: visit method not defined"];
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitRotateL: visit method not defined"]; 
}
-(void) visitBitNegative:(id<ORBitNegative>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitNegative: visit method not defined"];
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitSum: visit method not defined"]; 
}
-(void) visitBitSubtract:(id<ORBitSubtract>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitSubtract: visit method not defined"];
}
-(void) visitBitMultiply:(id<ORBitMultiply>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitMultiply: visit method not defined"];
}
-(void) visitBitDivide:(id<ORBitDivide>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitDivide: visit method not defined"];
}
-(void) visitBitDivideSigned:(id<ORBitDivideSigned>)c
{
    @throw [[ORExecutionError alloc] initORExecutionError: "BitDivideSigned: visit method not defined"];
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitIf: visit method not defined"]; 
}
-(void) visitBitCount:(id<ORBitCount>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitCount: visit method not defined"];
}
-(void) visitBitChannel:(id<ORBitChannel>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitChannel: visit method not defined"];
}
-(void) visitBitZeroExtend:(id<ORBitZeroExtend>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitZeroExtend: visit method not defined"];
}
-(void) visitBitSignExtend:(id<ORBitSignExtend>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitSignExtend: visit method not defined"];
}
-(void) visitBitExtract:(id<ORBitExtract>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitExtract: visit method not defined"];
}
-(void) visitBitConcat:(id<ORBitConcat>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitConcat: visit method not defined"];
}
-(void) visitBitLogicalEqual:(id<ORBitLogicalEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitLogicalEqual: visit method not defined"];
}

-(void) visitBitLT:(id<ORBitLT>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitLT: visit method not defined"];
}

-(void) visitBitLE:(id<ORBitLE>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitLE: visit method not defined"];
}

-(void) visitBitSLE:(id<ORBitSLE>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitSLE: visit method not defined"];
}

-(void) visitBitSLT:(id<ORBitSLT>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitSLT: visit method not defined"];
}

-(void) visitBitITE:(id<ORBitITE>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitITE: visit method not defined"];
}
-(void) visitBitLogicalAnd:(id<ORBitLogicalAnd>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitLogicalAnd: visit method not defined"];
}

-(void) visitBitLogicalOr:(id<ORBitLogicalOr>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitLogicalOr: visit method not defined"];
}
-(void) visitBitOrb:(id<ORBitOrb>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitOrb: visit method not defined"];
}
-(void) visitBitNotb:(id<ORBitNotb>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitNotb: visit method not defined"];
}
-(void) visitBitEqualb:(id<ORBitEqualb>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitEqualb: visit method not defined"];
}
-(void) visitBitDistinct:(id<ORBitDistinct>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "BitDistinct: visit method not defined"];
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "IntegerI: visit method not defined"]; 
}
//-(void) visitRationalI: (id<ORRational>) e
//{
//   @throw [[ORExecutionError alloc] initORExecutionError: "RationalI: visit method not defined"];
//}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MutableIntegerI: visit method not defined"]; 
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MutableFloatI: visit method not defined"];
}
-(void) visitMutableRationalI: (id<ORMutableRational>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MutableRationalI: visit method not defined"];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "MutableRealI: visit method not defined"]; 
}
-(void) visitFloat: (id<ORFloatNumber>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "FloatI: visit method not defined"];
}
-(void) visitRational: (id<ORRationalNumber>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "RationalI: visit method not defined"];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "RealI: visit method not defined"];
}
-(void) visitExprPlusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprPlusI: visit method not defined"]; 
}
-(void) visitExprUnaryMinusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprUnaryMinusI: visit method not defined"]; 
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
-(void) visitExprErrorOfI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprErrorOfI: visit method not defined"];
}
-(void) visitExprUlpOfI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprUlpOfI: visit method not defined"];
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprNEqualI: visit method not defined"]; 
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprLEqualI: visit method not defined"]; 
}
-(void) visitExprGEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprGEqualI: visit method not defined"];
}
-(void) visitExprLThenI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprLThenI: visit method not defined"];
}
-(void) visitExprGThenI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprGThenI: visit method not defined"];
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
-(void) visitExprSqrtI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprSqrtI: visit method not defined"];
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
-(void) visitExprCstRationalSubI:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstRationalSubI: visit method not defined"];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstDoubleSubI: visit method not defined"]; 
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
-(void) visitFloatVar: (id<ORFloatVar>) v {}
-(void) visitDoubleVar: (id<ORDoubleVar>) v {}
-(void) visitFloat: (id<ORFloatNumber>) e {}
-(void) visitDouble: (id<ORDoubleNumber>) e {}
-(void) visitRandomStream:(id) v {}
-(void) visitZeroOneStream:(id) v {}
-(void) visitUniformDistribution:(id) v{}
-(void) visitIntSet:(id<ORIntSet>)v{}
-(void) visitIntRange:(id<ORIntRange>)v     {}
-(void) visitRealRange:(id<ORRealRange>)v {}
-(void) visitIntArray:(id<ORIntArray>)v  {}
-(void) visitDoubleArray:(id<ORDoubleArray>)v  {}
-(void) visitLDoubleArray:(id<ORLDoubleArray>)v  {}
-(void) visitIntMatrix:(id<ORIntMatrix>)v  {}
-(void) visitTrailableInt:(id<ORTrailableInt>)v  {}
-(void) visitIntVar: (id<ORIntVar>) v  {}
-(void) visitRealVar: (id<ORRealVar>) v  {}
-(void) visitBitVar: (id<ORBitVar>) v {}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v  {}
-(void) visitAffineVar:(id<ORIntVar>) v  {}
-(void) visitIdArray: (id<ORIdArray>) v  {}
-(void) visitIdMatrix: (id<ORIdMatrix>) v  {}
-(void) visitTable:(id<ORTable>) v  {}
-(void) visitIntParam: (id<ORIntParam>) v {}
-(void) visitFloatParam: (id<ORRealParam>) v {}
-(void) visitRationalParam: (id<ORRealParam>) v {}
// micro-Constraints
-(void) visitConstraint:(id<ORConstraint>)c  {}
-(void) visitGroup:(id<ORGroup>)g {}
-(void) visitCDGroup:(id<ORGroup>)g {}
-(void) visit3BGroup:(id<ORGroup>)g {}
-(void) visitObjectiveFunctionVar:(id<ORObjectiveFunctionVar>)f  {}
-(void) visitObjectiveFunctionExpr:(id<ORObjectiveFunctionExpr>)f  {}
-(void) visitObjectiveFunctionLinear:(id<ORObjectiveFunctionLinear>)f  {}
-(void) visitFail:(id<ORFail>)cstr  {}
-(void) visitRestrict:(id<ORRestrict>)cstr  {}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr  {}
-(void) visitRegular:(id<ORRegular>) cstr {}
-(void) visitCardinality: (id<ORCardinality>) cstr  {}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr  {}
-(void) visitRealWeightedVar: (id<ORWeightedVar>) cstr  {}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr  {}
-(void) visitLexLeq:(id<ORLexLeq>) cstr  {}
-(void) visitCircuit:(id<ORCircuit>) cstr  {}
-(void) visitPath:(id<ORPath>) cstr  {}
-(void) visitSubCircuit:(id<ORSubCircuit>) cstr  {}
-(void) visitNoCycle:(id<ORNoCycle>) cstr  {}
-(void) visitPackOne:(id<ORPackOne>) cstr  {}
-(void) visitPacking:(id<ORPacking>) cstr  {}
-(void) visitKnapsack:(id<ORKnapsack>) cstr  {}
-(void) visitMultiKnapsack:(id<ORMultiKnapsack>) cstr  {}
-(void) visitMultiKnapsackOne:(id<ORMultiKnapsackOne>) cstr  {}
-(void) visitMeetAtmost:(id<ORMeetAtmost>) cstr  {}
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
-(void) visitRationalErrorOf: (id<ORRationalErrorOf>)c  {}
-(void) visitRationalUlpOf: (id<ORRationalUlpOf>)c  {}
-(void) visitRationalChannel: (id<ORRationalChannel>)c  {}
-(void) visitAffine: (id<ORAffine>)c  {}
-(void) visitNEqual: (id<ORNEqual>)c  {}
-(void) visitLEqual: (id<ORLEqual>)c  {}
-(void) visitPlus: (id<ORPlus>)c  {}
-(void) visitMult: (id<ORMult>)c  {}
-(void) visitSquare:(id<ORSquare>)c {}
-(void) visitRealSquare:(id<ORSquare>)c {}
-(void) visitMod: (id<ORMod>)c {}
-(void) visitModc: (id<ORModc>)c {}
-(void) visitMin:(id<ORMin>)c  {}
-(void) visitMax:(id<ORMax>)c  {}
-(void) visitAbs: (id<ORAbs>)c  {}
-(void) visitSqrt: (id<ORSqrt>)c  {}
-(void) visitOr: (id<OROr>)c  {}
-(void) visitAnd:( id<ORAnd>)c  {}
-(void) visitImply: (id<ORImply>)c  {}
-(void) visitBinImply: (id<ORBinImply>)c  {}
-(void) visitElementCst: (id<ORElementCst>)c  {}
-(void) visitElementVar: (id<ORElementVar>)c  {}
-(void) visitElementBitVar: (id<ORElementBitVar>)c  {}
-(void) visitRealElementCst: (id<ORRealElementCst>) cstr {}
-(void) visitImplyEqualc: (id<ORImplyEqualc>)c  {}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c  {}
-(void) visitReifyEqual: (id<ORReifyEqual>)c  {}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c  {}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c  {}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c  {}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c  {}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c  {}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c  {}
-(void) visitReifySumBoolEqualc: (id<ORReifySumBoolEqc>) c {}
-(void) visitReifySumBoolGEqualc: (id<ORReifySumBoolGEqc>) c {}
-(void) visitHReifySumBoolEqualc: (id<ORReifySumBoolEqc>) c {}
-(void) visitHReifySumBoolGEqualc: (id<ORReifySumBoolGEqc>) c {}
-(void) visitClause:(id<ORConstraint>)c           {}
-(void) visitSumSquare: (id<ORSumSquare>) c  {}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c  {}
-(void) visitSumBoolNEqualc: (id<ORSumBoolNEqc>) c  {}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c  {}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c  {}
-(void) visitSumEqualc:(id<ORSumEqc>)c  {}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c  {}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c  {}

-(void) visitLinearGeq: (id<ORLinearGeq>) c {}
-(void) visitLinearLeq: (id<ORLinearLeq>) c {}
-(void) visitLinearEq: (id<ORLinearEq>) c {}
-(void) visitRealMin: (id<ORRealMin>) c {}
-(void) visitRealLinearLeq: (id<ORRealLinearLeq>) c {}
-(void) visitRealLinearGeq: (id<ORRealLinearGeq>) c {}
-(void) visitRealLinearEq: (id<ORRealLinearEq>) c {}
// Bit
-(void) visitBitEqBool:(id<ORBitEqualAt>)c {}
-(void) visitBitEqualAt:(id<ORBitEqualAt>)c {}
-(void) visitBitEqualc:(id<ORBitEqualc>)c {}
-(void) visitBitEqual:(id<ORBitEqual>)c {}
-(void) visitBitOr:(id<ORBitOr>)c {}
-(void) visitBitAnd:(id<ORBitAnd>)c {}
-(void) visitBitNot:(id<ORBitNot>)c {}
-(void) visitBitXor:(id<ORBitXor>)c {}
-(void) visitBitShiftL:(id<ORBitShiftL>)c {}
-(void) visitBitShiftR:(id<ORBitShiftR>)c {}
-(void) visitBitShiftR_BV:(id<ORBitShiftR_BV>)c {}
-(void) visitBitShiftRA:(id<ORBitShiftRA>)c {}
-(void) visitBitShiftRA_BV:(id<ORBitShiftRA_BV>)c {}
-(void) visitBitRotateL:(id<ORBitRotateL>)c {}
-(void) visitBitNegative:(id<ORBitNegative>)c {}
-(void) visitBitSum:(id<ORBitSum>)c {}
-(void) visitBitSubtract:(id<ORBitSubtract>)c {}
-(void) visitBitIf:(id<ORBitIf>)c {}
-(void) visitBitCount:(id<ORBitCount>)c {}
-(void) visitBitChannel:(id<ORBitChannel>)c {}
-(void) visitBitZeroExtend:(id<ORBitZeroExtend>)c{}
-(void) visitBitSignExtend:(id<ORBitSignExtend>)c{}
-(void) visitBitExtract:(id<ORBitExtract>)c{}
-(void) visitBitConcat:(id<ORBitConcat>)c{}
-(void) visitBitLogicalEqual:(id<ORBitLogicalEqual>)c{}
-(void) visitBitLT:(id<ORBitLT>)c{}
-(void) visitBitLE:(id<ORBitLE>)c{}
-(void) visitBitSLE:(id<ORBitSLE>)c{}
-(void) visitBitSLT:(id<ORBitSLT>)c{}
-(void) visitBitITE:(id<ORBitITE>)c{}
-(void) visitBitLogicalAnd:(id<ORBitLogicalAnd>)c{}
-(void) visitBitLogicalOr:(id<ORBitLogicalOr>)c{}
-(void) visitBitOrb:(id<ORBitOrb>)c{}
-(void) visitBitNotb:(id<ORBitNotb>)c{}
-(void) visitBitEqualb:(id<ORBitEqualb>)c{}
-(void) visitBitDistinct:(id<ORBitDistinct>)c{}
// Expressions
-(void) visitIntegerI: (id<ORInteger>) e  {}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e  {}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e  {}
-(void) visitMutableRationalI: (id<ORMutableRational>) e  {}
-(void) visitMutableDouble: (id<ORMutableDouble>) e {}
-(void) visitExprPlusI: (id<ORExpr>) e  {}
-(void) visitExprUnaryMinusI: (id<ORExpr>) e  {}
-(void) visitExprMinusI: (id<ORExpr>) e  {}
-(void) visitExprMulI: (id<ORExpr>) e  {}
-(void) visitExprDivI: (id<ORExpr>) e  {}
-(void) visitExprEqualI: (id<ORExpr>) e  {}
-(void) visitExprErrorOfI: (id<ORExpr>) e  {}
-(void) visitExprUlpOfI: (id<ORExpr>) e  {}
-(void) visitExprNEqualI: (id<ORExpr>) e  {}
-(void) visitExprLEqualI: (id<ORExpr>) e  {}
-(void) visitExprGEqualI: (id<ORExpr>) e  {}
-(void) visitExprLThenI: (id<ORExpr>) e  {}
-(void) visitExprGThenI: (id<ORExpr>) e  {}
-(void) visitExprSumI: (id<ORExpr>) e  {}
-(void) visitExprProdI: (id<ORExpr>) e  {}
-(void) visitExprAbsI:(id<ORExpr>) e  {}
-(void) visitExprSquareI:(id<ORExpr>) e  {}
-(void) visitExprModI:(id<ORExpr>)e   {}
-(void) visitExprMinI: (id<ORExpr>) e {}
-(void) visitExprMaxI: (id<ORExpr>) e {}
-(void) visitExprNegateI:(id<ORExpr>) e  {}
-(void) visitExprSqrtI:(id<ORExpr>) e  {}
-(void) visitExprCstSubI: (id<ORExpr>) e  {}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e {}
-(void) visitExprDisjunctI:(id<ORExpr>) e  {}
-(void) visitExprConjunctI: (id<ORExpr>) e  {}
-(void) visitExprImplyI: (id<ORExpr>) e  {}
-(void) visitExprAggOrI: (id<ORExpr>) e  {}
-(void) visitExprAggAndI: (id<ORExpr>) e  {}
-(void) visitExprAggMinI: (id<ORExpr>) e  {}
-(void) visitExprAggMaxI: (id<ORExpr>) e  {}
-(void) visitExprVarSubI: (id<ORExpr>) e  {}
@end
