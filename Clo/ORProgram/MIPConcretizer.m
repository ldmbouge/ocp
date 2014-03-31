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
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
   NSLog(@"DID NOT RECOGNIZE a selector %@",NSStringFromSelector(aSelector));
   @throw [[ORExecutionError alloc] initORExecutionError: "No MIP concretization yet"];
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
-(void) visitFloatRange:(id<ORFloatRange>)v
{}

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

-(void) visitFloatParam:(id<ORFloatParam>)v
{
    if (_gamma[v.getId] == NULL) {
        MIPParameterI* cv;
        cv = [_MIPsolver createParameter];
        _gamma[v.getId] = cv;
    }
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
      _gamma[v.getId] = dx;
   }
}
-(void) visitIdMatrix:(id<ORIdMatrix>) v
{
    if (_gamma[v.getId] == NULL) {
        ORInt nb = (ORInt) [v count];
        for(ORInt k = 0; k < nb; k++)
            [[v flat: k] visit: self];
        id<ORIdMatrix> n = [ORFactory idMatrix: _MIPsolver with: v];
        for(ORInt k = 0; k < nb; k++)
            [n setFlat: _gamma[[[v flat: k] getId]] at: k];
        _gamma[v.getId] = n;
    }}
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
      MIPObjectiveI* concreteObj = [_MIPsolver createObjectiveMinimize: dx coef: a independent:[obj independent]];
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
      MIPObjectiveI* concreteObj = [_MIPsolver createObjectiveMaximize: dx coef: a independent:[obj independent]];
      _gamma[obj.getId] = concreteObj;
      [_MIPsolver postObjective: concreteObj];
   }
}

-(void) visitLEqual: (id<ORLEqual>)c
{
   if (_gamma[c.getId]==NULL) {
      MIPVariableI* x[2] = { [self concreteVar:[c left]],[self concreteVar:[c right]]};
      ORFloat    coef[2] = { [c coefLeft],- [c coefRight]};
      MIPConstraintI* concreteCstr = [_MIPsolver createLEQ:2 var:x coef:coef rhs:[c cst]];
      _gamma[c.getId] = concreteCstr;
      [_MIPsolver postConstraint:concreteCstr];
   }
}

-(void) visitLinearEq: (id<ORLinearEq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORIntArray> a = [c coefs];
      id<ORFloatArray> fa = [ORFactory floatArray:[_MIPsolver tracker] range:[a range] with:^ORFloat(ORInt k) {
         return [a at:k];
      }];
      ORFloat cst = [c cst];
      [x visit: self];
      id<MIPVariableArray> dx = _gamma[x.getId];
      MIPConstraintI* concreteCstr = [_MIPsolver createEQ: dx coef: fa cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_MIPsolver postConstraint: concreteCstr];
   }
}
-(void) visitLinearLeq: (id<ORLinearLeq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORIntArray> a = [c coefs];
      id<ORFloatArray> fa = [ORFactory floatArray:_program range:[a range] with:^ORFloat(ORInt k) {
         return [a at:k];
      }];
      ORInt cst = [c cst];
      [x visit: self];
      id<MIPVariableArray> dx = _gamma[x.getId];
      MIPConstraintI* concreteCstr = [_MIPsolver createLEQ: dx coef: fa cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_MIPsolver postConstraint: concreteCstr];
   }
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>)c
{
    if (_gamma[c.getId] == NULL) {
        id<ORVarArray> x = [c vars];
        ORFloat cst = [c cst];
        [x visit: self];
        id<MIPVariableArray> dx = _gamma[x.getId];
        id<ORFloatArray> a = [ORFactory floatArray:_program range:dx.range with:^ORFloat(ORInt k) {
            return 1.0;
        }];
        MIPConstraintI* concreteCstr = [_MIPsolver createEQ: dx coef: a cst: -cst];
        _gamma[c.getId] = concreteCstr;
        [_MIPsolver postConstraint: concreteCstr];
    }
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
-(void) visitFloatLinearGeq: (id<ORFloatLinearGeq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORFloatArray> a = [c coefs];
      ORInt cst = [c cst];
      [x visit: self];
      id<MIPVariableArray> dx = _gamma[x.getId];
      MIPConstraintI* concreteCstr = [_MIPsolver createGEQ: dx coef: a cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_MIPsolver postConstraint: concreteCstr];
   }
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory float: _MIPsolver value: [e intValue]];
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
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   // This is called when the constraint is stored in a data structure
}
-(void) visitFloatWeightedVar:(id<ORWeightedVar>)c
{
    if (_gamma[c.getId] == NULL) {
        MIPVariableI* dx = _gamma[[c x].getId];
        MIPVariableI* dz = _gamma[[c z].getId];
        MIPParameterI* dw = _gamma[[c weight].getId];
        
        id<ORIntRange> r = RANGE(_MIPsolver, 0, 1);
        id<ORIdArray> vars = [ORFactory idArray: _MIPsolver range: r];
        [vars set: dx at: 0];
        [vars set: dz at: 1];
        ORFloat coefValues[] = { [(id<ORFloatParam>)[c weight] initialValue], -1.0 };
        id<ORFloatArray> coef = [ORFactory floatArray: _MIPsolver range: r values: coefValues];
        
        // w * x - z == 0
        MIPConstraintI* concreteCstr = [_MIPsolver createEQ: (id<MIPVariableArray>)vars coef: coef cst: 0];
        _gamma[c.getId] = concreteCstr;
        [_MIPsolver postConstraint: concreteCstr];
        [dw setCstrIdx: [concreteCstr idx]];
        [dw setCoefIdx: [dx idx]];
    }
}
-(void) visitMinimize: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"];
}
-(void) visitMaximize: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "This concretization should never be called"]; 
}
@end


