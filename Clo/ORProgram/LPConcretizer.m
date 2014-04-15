;/************************************************************************
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
   id*           _gamma;
}
-(ORLPConcretizer*) initORLPConcretizer: (id<LPProgram>) program
{
   self = [super init];
   _program = [program retain];
   _lpsolver = [program solver];
   _gamma = [program gamma];
   return self;
}
-(void) dealloc
{
   [_program release];
   [super dealloc];
}
- (void) doesNotRecognizeSelector: (SEL) aSelector
{
   NSLog(@"DID NOT RECOGNIZE a selector %@",NSStringFromSelector(aSelector));
   @throw [[ORExecutionError alloc] initORExecutionError: "No LP concretization yet"];
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
   @throw [[ORExecutionError alloc] initORExecutionError: "no concretization of integer variables in linear program"];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   if (_gamma[v.getId] == NULL) {
      LPVariableI* cv;
      if ([v hasBounds])
         cv = [_lpsolver createVariable: [v low] up: [v up]];
      else
         cv = [_lpsolver createVariable];
      _gamma[v.getId] = cv;
   }
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _lpsolver range: R];
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
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
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
      id<LPVariableArray> dx = _gamma[x.getId];
      LPObjectiveI* concreteObj = [_lpsolver createObjectiveMinimize: dx coef: a];
      _gamma[obj.getId] = concreteObj;
      [_lpsolver postObjective: concreteObj];
   }
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) obj
{
   if (_gamma[obj.getId] == NULL) {
      id<ORVarArray> x = [obj array];
      id<ORFloatArray> a = [obj coef];
      [x visit: self];
      id<LPVariableArray> dx = _gamma[x.getId]; 
      LPObjectiveI* concreteObj = [_lpsolver createObjectiveMaximize: dx coef: a];
      _gamma[obj.getId] = concreteObj;
      [_lpsolver postObjective: concreteObj];
   }
}

-(void) visitFloatLinearEq: (id<ORFloatLinearEq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORFloatArray> a = [c coefs];
      ORFloat cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = _gamma[x.getId];    
      LPConstraintI* concreteCstr = [_lpsolver createEQ: dx coef: a cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_lpsolver postConstraint: concreteCstr];
   }
}
-(void) visitFloatLinearLeq: (id<ORFloatLinearLeq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORFloatArray> a = [c coefs];
      ORInt cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = _gamma[x.getId];     
      LPConstraintI* concreteCstr = [_lpsolver createLEQ: dx coef: a cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_lpsolver postConstraint: concreteCstr];
   }
}

-(void) visitIntegerI: (id<ORInteger>) e
{
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory integer: _lpsolver value: [e initialValue]];
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory mutableFloat: _lpsolver value: [e initialValue]];
}
-(void) visitFloatI: (id<ORFloatNumber>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory float: _lpsolver value: [e floatValue]];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Packing constraints"];
}
-(void) visitMultiKnapsack: (id<ORMultiKnapsack>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for MultiKnapsack constraints"];
}
-(void) visitMultiKnapsackOne: (id<ORMultiKnapsackOne>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for MultiKnapsackOne constraints"];
}

-(void) visitMeetAtmost: (id<ORMeetAtmost>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for MeetAtmost constraints"];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   // This is called only when the original constraint is stored in a data structure
}
@end

@implementation ORLPRelaxationConcretizer
{
   id<LPRelaxation> _program;
   LPSolverI*       _lpsolver;
   id*              _gamma;
}
-(ORLPRelaxationConcretizer*) initORLPRelaxationConcretizer: (id<LPRelaxation>) program
{
   self = [super init];
   _program = [program retain];
   _lpsolver = [program solver];
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
   @throw [[ORExecutionError alloc] initORExecutionError: "No LPRelaxation concretization yet"];
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
   if (_gamma[v.getId] == NULL) {
      LPVariableI* cv;
      cv = [_lpsolver createVariable: [v low] up: [v up]];
      _gamma[v.getId] = cv;
   }
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   if (_gamma[v.getId] == NULL) {
      LPVariableI* cv;
      if ([v hasBounds])
         cv = [_lpsolver createVariable: [v low] up: [v up]];
      else
         cv = [_lpsolver createVariable];
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
      id<ORIdArray> dx = [ORFactory idArray: _lpsolver range: R];
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
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
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
      id<LPVariableArray> dx = _gamma[x.getId];
      LPObjectiveI* concreteObj = [_lpsolver createObjectiveMinimize: dx coef: a];
      _gamma[obj.getId] = concreteObj;
      [_lpsolver postObjective: concreteObj];
   }
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) obj
{
   if (_gamma[obj.getId] == NULL) {
      id<ORVarArray> x = [obj array];
      id<ORFloatArray> a = [obj coef];
      [x visit: self];
      id<LPVariableArray> dx = _gamma[x.getId];
      LPObjectiveI* concreteObj = [_lpsolver createObjectiveMaximize: dx coef: a];
      _gamma[obj.getId] = concreteObj;
      [_lpsolver postObjective: concreteObj];
   }
}

-(void) visitLinearEq: (id<ORLinearEq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORIntArray> a = [c coefs];
      id<ORFloatArray> af = [ORFactory floatArray: _lpsolver range: [a range] with: ^ORFloat(ORInt i) { return [a at: i]; }  ];
      ORFloat cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = _gamma[x.getId];
      LPConstraintI* concreteCstr = [_lpsolver createEQ: dx coef: af cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_lpsolver postConstraint: concreteCstr];
   }
}

-(void) visitLinearLeq: (id<ORLinearLeq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORIntArray> a = [c coefs];
      id<ORFloatArray> af = [ORFactory floatArray: _lpsolver range: [a range] with: ^ORFloat(ORInt i) { return [a at: i]; }];
      ORFloat cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = _gamma[x.getId];
      LPConstraintI* concreteCstr = [_lpsolver createLEQ: dx coef: af cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_lpsolver postConstraint: concreteCstr];
   }
}

-(void) visitFloatLinearEq: (id<ORFloatLinearEq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
      id<ORFloatArray> a = [c coefs];
      ORFloat cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = _gamma[x.getId];
      LPConstraintI* concreteCstr = [_lpsolver createEQ: dx coef: a cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_lpsolver postConstraint: concreteCstr];
   }
}
-(void) visitFloatLinearLeq: (id<ORFloatLinearLeq>) c
{
   if (_gamma[c.getId] == NULL) {
      id<ORVarArray> x = [c vars];
//      NSLog(@"x: %@",x);
      id<ORFloatArray> a = [c coefs];
      ORInt cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = _gamma[x.getId];
//      NSLog(@"dx: %@",dx);
      LPConstraintI* concreteCstr = [_lpsolver createLEQ: dx coef: a cst: -cst];
      _gamma[c.getId] = concreteCstr;
      [_lpsolver postConstraint: concreteCstr];
   }
}

-(void) visitIntegerI: (id<ORInteger>) e
{
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory integer: _lpsolver value: [e initialValue]];
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory mutableFloat: _lpsolver value: [e initialValue]];
}
-(void) visitFloatI: (id<ORFloatNumber>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory float: _lpsolver value: [e floatValue]];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   // This is called only when the original constraint is stored in a data structure
}
@end



