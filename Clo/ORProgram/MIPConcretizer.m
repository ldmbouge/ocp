/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORSet.h>
#import <objmp/MIPSolverI.h>
#import "MIPProgram.h"
#import "MIPConcretizer.h"


@implementation ORMIPConcretizer
{
   id<MIPProgram> _program;
   MIPSolverI*    _MIPsolver;
   id*           _gamma;
}
-(ORMIPConcretizer*) initORMIPConcretizer: (id<MIPProgram>) program
{
   self = [super init];
   _program = [program retain];
   _MIPsolver = [program solver];
   _gamma = [program gamma];
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
   return _gamma[x.getId];
}

-(id) concreteArray: (id<ORIntVarArray>) x
{
   [x visit: self];
   return _gamma[x.getId];
}

// visit interface

-(void) visitTrailableInt: (id<ORTrailableInt>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitIntSet: (id<ORIntSet>) v
{
}
-(void) visitIntRange:(id<ORIntRange>) v
{
}

-(void) visitIntVar: (id<ORIntVar>) v
{
   if (_gamma[v.getId] == NULL) 
      _gamma[v.getId] = [_MIPsolver createIntVariable: [v low] up: [v up]];
}

-(void) visitFloatVar: (id<ORFloatVar>) v
{
   if (_gamma[v.getId] == NULL) {
      MIPVariableI* cv;
      if ([v hasBounds])
         cv = [_MIPsolver createVariable: [v low] up: [v up]];
      else
         cv = [_MIPsolver createVariable];
      _gamma[v.getId] = cv;
   }
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

-(void) visitIdArray: (id<ORIdArray>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _MIPsolver range: R];
      ORInt low = R.low;
      ORInt up = R.up;
      for(ORInt i = low; i <= up; i++) {
         [v[i] visit: self];
         dx[i] = _gamma[[v[i] getId]];
      }
      _gamma[[v getId]] = dx;
   }
}
-(void) visitIntArray:(id<ORIntArray>) v
{
}
-(void) visitFloatArray:(id<ORFloatArray>) v
{
}

-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"];
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"];
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) obj
{
   if (_gamma[obj.getId] == NULL) {
      id<ORVarArray> x = [obj array];
      id<ORFloatArray> a = [obj coef];
      [x visit: self];
      id<MIPVariableArray> dx = _gamma[x.getId];
      MIPObjectiveI* concreteObj = [_MIPsolver createObjectiveMinimize: dx coef: a];
      _gamma[obj.getId] = concreteObj;
      [_MIPsolver postObjective: concreteObj];
   }
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) obj
{
   if (_gamma[obj.getId] == NULL) {
      id<ORVarArray> x = [obj array];
      id<ORFloatArray> a = [obj coef];
      [x visit: self];
      id<MIPVariableArray> dx = _gamma[x.getId];
      MIPObjectiveI* concreteObj = [_MIPsolver createObjectiveMaximize: dx coef: a];
      _gamma[obj.getId] = concreteObj;
      [_MIPsolver postObjective: concreteObj];
   }
}

-(void) visitLinearEq: (id<ORLinearEq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"]; 
}
-(void) visitLinearLeq: (id<ORLinearLeq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"];
}

-(void) visitFloatLinearEq: (id<ORFloatLinearEq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORFloatArray> a = [c coefs];
      ORFloat cst = [c cst];
      [x visit: self];
      id<MIPVariableArray> dx = _gamma[x.getId];
      MIPConstraintI* concreteCstr = [_MIPsolver createEQ: dx coef: a cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_MIPsolver postConstraint: concreteCstr];
   }
}
-(void) visitFloatLinearLeq: (id<ORFloatLinearLeq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORFloatArray> a = [c coefs];
      ORInt cst = [c cst];
      [x visit: self];
      id<MIPVariableArray> dx = _gamma[x.getId];
      MIPConstraintI* concreteCstr = [_MIPsolver createLEQ: dx coef: a cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_MIPsolver postConstraint: concreteCstr];
   }
}

-(void) visitIntegerI: (id<ORInteger>) e
{
}

-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory integer: _MIPsolver value: [e initialValue]];
}
-(void) visitMutableFloatI: (id<ORMutableInteger>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory mutableFloat: _MIPsolver value: [e initialValue]];
}

-(void) visitFloatI: (id<ORFloatNumber>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory float: _MIPsolver value: [e floatValue]];
}

-(void) visitIntMatrix: (id<ORIntMatrix>) v
{
    [v makeImpl];
//   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
    if ([v dereference] == NULL) {
        id<ORIntRange> R1 = [v range: 0];
        id<ORIntRange> R2 = [v range: 1];
        id<ORIntRange> R[] = {R1, R2};
        id<ORIdMatrix> dx = [ORFactory idMatrix: _MIPsolver arity: 2 ranges: R];
        [dx makeImpl];
        for(ORInt i = [R1 low]; i <= [R1 up]; i++) {
            for(ORInt j = [R2 low]; j <= [R2 up]; j++) {
                [[v at:i:j] visit: self];
                [dx set: [[v at:i:j] dereference] at: i : j];
            }
        }
        [v setImpl: dx];
    }
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
-(void) visitRegular:(id<ORRegular>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   // This is called when the constraint is stored in a data structure
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
-(void) visitMinimize: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"];
}
-(void) visitMaximize: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"]; 
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
-(void) visitMin:(id<ORMin>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitMax:(id<ORMax>)cstr
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
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprMinusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprMulI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprDivI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprModI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprNegateI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprConjunctI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprImplyI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of expression not yet implemented"];
}
@end


