/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORSet.h>
#import <objmp/LPSolverI.h>
#import "LPProgram.h"
#import "LPConcretizer.h"


@implementation ORLPConcretizer
{
   id<LPProgram> _program;
   LPSolverI*    _lpsolver;
}
-(ORLPConcretizer*) initORLPConcretizer: (id<LPProgram>) program
{
   self = [super init];
   _program = [program retain];
   _lpsolver = [program solver];
   return self;
}
-(void) dealloc
{
   [_program release];
   [super dealloc];
}

// Helper function
-(id) concreteVar: (id<ORVar>) x
{
   [x visit:self];
   return [x dereference];
}

-(id) concreteArray: (id<ORIntVarArray>) x
{
   [x visit: self];
   return [x dereference];
}

// visit interface

-(void) visitTrailableInt: (id<ORTrailableInt>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitIntSet: (id<ORIntSet>) v
{
   if ([v dereference] == NULL) {
      id<ORIntSet> i = [ORFactory intSet: _lpsolver];
      [i makeImpl];
      [v copyInto: i];
      [v setImpl: i];
   }
}
-(void) visitIntRange:(id<ORIntRange>) v
{
   [v makeImpl];
}

// pvh: this is bogus right now but this is easy for testing
-(void) visitIntVar: (id<ORIntVar>) v
{
   if ([v dereference] == NULL) {
      LPVariableI* cv = [_lpsolver createVariable];
      [v setImpl: cv];
   }
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   if ([v dereference] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _lpsolver range: R];
      [dx makeImpl];
      ORInt low = R.low;
      ORInt up = R.up;
      for(ORInt i = low; i <= up; i++) {
         [v[i] visit: self];
         dx[i] = [v[i] dereference];
      }
      [v setImpl: dx];
   }
}
-(void) visitIntArray:(id<ORIntArray>) v
{
   if ([v dereference] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIntArray> dx = [ORFactory intArray: _lpsolver range: R with: ^ORInt(ORInt i) { return [v at: i]; }];
      [dx makeImpl];
      [v setImpl: dx];
   }
}

-(void) visitMinimize: (id<ORObjectiveFunction>) v
{
   if ([v dereference] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      LPObjectiveI* concreteObj = [_lpsolver createObjectiveMinimize: [o dereference]];
      [v setImpl: concreteObj];
      [_lpsolver solve];
   }
}
-(void) visitMaximize: (id<ORObjectiveFunction>) v
{
   if ([v dereference] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      LPObjectiveI* concreteObj = [_lpsolver createObjectiveMaximize: [o dereference]];
      [v setImpl: concreteObj];
      [_lpsolver postObjective: concreteObj];
   }
}
-(void) visitLinearEq: (id<ORLinearEq>) c
{
   if ([c dereference] == NULL) {
      id<ORIntVarArray> x = [c vars];
      id<ORIntArray> a = [c coefs];
      ORInt cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = [x dereference];
      [a visit: self];
      id<ORIntArray> da = [a dereference];
      LPConstraintI* concreteCstr = [_lpsolver createEQ: dx coef: da cst: -cst];
      [c setImpl:concreteCstr];
      [_lpsolver postConstraint: concreteCstr];
   }
}
-(void) visitLinearLeq: (id<ORLinearLeq>) c
{
   if ([c dereference] == NULL) {
      id<ORIntVarArray> x = [c vars];
      id<ORIntArray> a = [c coefs];
      ORInt cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = [x dereference];
      [a visit: self];
      id<ORIntArray> da = [a dereference];
      LPConstraintI* concreteCstr = [_lpsolver createLEQ: dx coef: da cst: -cst];
      [c setImpl:concreteCstr];
      [_lpsolver postConstraint: concreteCstr];
   }
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if ([e dereference] == NULL) {
      id<ORInteger> n = [ORFactory integer: _lpsolver value: [e value]];
      [n makeImpl];
      [e setImpl: n];
   }
}

-(void) visitFloatVar: (id<ORFloatVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet for Float Variables"];
}
-(void) visitBitVar: (id<ORBitVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitIntMatrix: (id<ORIntMatrix>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitTable:(id<ORTable>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitGroup:(id<ORGroup>)g
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitRestrict: (id<ORRestrict>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Algebraic constraints"];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Algebraic constraints"];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitNoCycle:(id<ORNoCycle>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitLexLeq:(id<ORLexLeq>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitEqualc: (id<OREqualc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitNEqualc: (id<ORNEqualc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitLEqualc: (id<ORLEqualc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitGEqualc: (id<ORGEqualc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitEqual: (id<OREqual>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitAffine: (id<ORAffine>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitNEqual: (id<ORNEqual>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitLEqual: (id<ORLEqual>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitPlus: (id<ORPlus>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitMult: (id<ORMult>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitSquare: (id<ORSquare>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitMod: (id<ORMod>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitModc: (id<ORModc>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitAbs: (id<ORAbs>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitOr: (id<OROr>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitAnd:( id<ORAnd>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitImply: (id<ORImply>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitElementCst: (id<ORElementCst>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitElementVar: (id<ORElementVar>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitReifyEqual: (id<ORReifyEqual>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitSumEqualc:(id<ORSumEqc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitSumLEqualc:(id<ORSumLEqc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitSumGEqualc:(id<ORSumGEqc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitEqual:(id<ORBitEqual>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitOr:(id<ORBitOr>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitAnd:(id<ORBitAnd>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitNot:(id<ORBitNot>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitXor:(id<ORBitXor>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitShiftL:(id<ORBitShiftL>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitRotateL:(id<ORBitRotateL>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitSum:(id<ORBitSum>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitBitIf:(id<ORBitIf>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitExprPlusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprMinusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprMulI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprModI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprNegateI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprConjunctI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprImplyI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
@end


