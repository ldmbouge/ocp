/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPProgram.h"
#import "CPConcretizer.h"
#import "CPConcretizer.h"
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPSolver.h>
#import <objcp/CPSolver.h>



@implementation ORCPConcretizer
{
   id<CPCommonProgram> _solver;
   id<CPEngine>        _engine;
}
-(ORCPConcretizer*) initORCPConcretizer: (id<CPCommonProgram>) solver
{
   self = [super init];
   _solver = [solver retain];
   _engine = [_solver engine];
   return self;
}
-(void) dealloc
{
   [_solver release];
   [super dealloc];
}

-(id) concreteVar: (id<ORIntVar>) x
{
   [x visit:self];
   return [x impl];
}

-(id) concreteArray: (id<ORIntVarArray>) x
{
   [x visit: self];
   return [x impl];
}

-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
}
-(void) visitIntSet:(id<ORIntSet>)v
{
}
-(void) visitIntRange:(id<ORIntRange>)v
{
}
-(void) visitIntVar: (id<ORIntVar>) v
{
   if ([v impl] == NULL) {
      id<CPIntVar> cv = [CPFactory intVar: _engine domain: [v domain]];
      [v setImpl: cv];
   }
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
   if ([v impl] == NULL) {   
      id<ORIntVar> mBase = [v base];
      [mBase visit: self];
      ORInt a = [v scale];
      ORInt b = [v shift];
      id<CPIntVar> cv = [CPFactory intVar:(id<CPIntVar>)[mBase dereference] scale:a shift:b];
      [v setImpl: cv];
   }
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   if ([v impl] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit:self];
      ORInt lit = [v literal];
      id<CPIntVar> cv = [CPFactory reifyView:(id<CPIntVar>)[mBase dereference] eqi:lit];
      [v setImpl:cv];
   }
}

-(void) visitIdArray: (id<ORIdArray>) v
{
   if ([v impl] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _engine range: R];
      ORInt low = R.low;
      ORInt up = R.up;
      for(ORInt i = low; i <= up; i++)
         dx[i] = [v[i] dereference];
      [v setImpl: dx];
   }
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   
}
-(void) visitIntArray:(id<ORIntArray>) v
{
   
}
-(void) visitIntMatrix: (id<ORIntMatrix>) v
{
   
}
-(void) visitTable:(id<ORTable>) v
{
   
}

-(void) visitRestrict: (id<ORRestrict>) cstr
{
   if ([cstr impl] == NULL) {
      id<CPIntVar> x = [self concreteVar:[cstr var]];
      id<CPConstraint> concrete = [CPFactory restrict:x to:[cstr restriction]];
      [cstr setImpl:concrete];
   }
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      ORAnnotation n = [cstr annotation];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory alldifferent: _engine over: [ax impl] consistency: n];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      id<ORIntArray> low = [cstr low];
      id<ORIntArray> up = [cstr up];
      ORAnnotation n = [cstr annotation];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory cardinality: [ax impl] low: low up: up consistency: n];
      [cstr setImpl: concreteCstr];
   }
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
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> array = [cstr array];
      id<ORTable> table = [cstr table];
      [array visit: self];
      id<CPConstraint> concreteCstr = [CPFactory table: table on: [array impl]];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory circuit: [ax impl]];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitNoCycle:(id<ORNoCycle>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory nocycle: [ax impl]];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitLexLeq:(id<ORLexLeq>) cstr
{
   if ([cstr impl] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr x]];
      id<CPIntVarArray> y = [self concreteArray:[cstr y]];
      id<CPConstraint> concrete = [CPFactory lex:x leq:y];
      [cstr setImpl:concrete];
   }
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> item = [cstr item];
      id<ORIntArray> itemSize = [cstr itemSize];
      ORInt bin = [cstr bin];
      id<ORIntVar> binSize = [cstr binSize];
      [item visit: self];
      [binSize visit: self];
      id<CPConstraint> concreteCstr = [CPFactory packOne: [item impl] itemSize: itemSize bin: bin binSize: [binSize impl]];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> item = [cstr item];
      id<ORIntArray> weight = [cstr weight];
      id<ORIntVar> capacity = [cstr capacity];
      [item visit: self];
      [capacity visit: self];
      id<CPConstraint> concreteCstr = [CPFactory knapsack:[item impl] weight:weight capacity:[capacity impl]];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitMinimize: (id<ORObjectiveFunction>) v
{
   if ([v impl] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      id<CPConstraint> concreteCstr = [CPFactory minimize: [o impl]];
      [v setImpl: concreteCstr];
   }
}
-(void) visitMaximize: (id<ORObjectiveFunction>) v
{
   if ([v impl] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      id<CPConstraint> concreteCstr = [CPFactory maximize: [o impl]];
      [v setImpl: concreteCstr];
   }
}
-(void) visitEqualc: (id<OREqualc>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory equalc: (id<CPIntVar>) [left dereference]  to: cst];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitNEqualc: (id<ORNEqualc>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory notEqualc: (id<CPIntVar>) [left dereference]  to: cst];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitLEqualc: (id<ORLEqualc>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory lEqualc: (id<CPIntVar>) [left dereference]  to: cst];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitEqual: (id<OREqual>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORInt cst = [cstr cst];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory equal: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
      [cstr setImpl: concreteCstr];
   }
}

-(void) visitNEqual: (id<ORNEqual>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORInt cst = [cstr cst];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory notEqual: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitLEqual: (id<ORLEqual>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORInt cst = [cstr cst];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory lEqual: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitPlus: (id<ORPlus>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORAnnotation annotation = [cstr annotation];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory equal3: (id<CPIntVar>) [res dereference]
                                                     to: (id<CPIntVar>) [left dereference]
                                                   plus: (id<CPIntVar>) [right dereference]
                                            consistency:annotation
                                       ];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitMult: (id<ORMult>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory mult: (id<CPIntVar>) [left dereference]
                                                   by: (id<CPIntVar>) [right dereference]
                                                equal: (id<CPIntVar>) [res dereference]
                                       ];
      [cstr setImpl: concreteCstr];
   }
}

-(void) visitAbs: (id<ORAbs>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      [res visit: self];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory abs: (id<CPIntVar>) [left dereference]
                                               equal: (id<CPIntVar>) [res dereference]
                                         consistency: DomainConsistency
                                       ];
     [cstr setImpl: concreteCstr];
   }
}
-(void) visitOr: (id<OROr>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
                                                      or: (id<CPIntVar>) [right dereference]
                                                   equal: (id<CPIntVar>) [res dereference]
                                       ];
     [cstr setImpl: concreteCstr];
   }
}
-(void) visitAnd:( id<ORAnd>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
                                                     and: (id<CPIntVar>) [right dereference]
                                                   equal: (id<CPIntVar>) [res dereference]
                                       ];

     [cstr setImpl: concreteCstr];
   }
}
-(void) visitImply: (id<ORImply>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
                                                   imply: (id<CPIntVar>) [right dereference]
                                                   equal: (id<CPIntVar>) [res dereference]
                                       ];
     [cstr setImpl: concreteCstr];
   }
}
-(void) visitElementCst: (id<ORElementCst>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntArray> array = [cstr array];
      id<ORIntVar> idx = [cstr idx];
      id<ORIntVar> res = [cstr res];
      [array visit: self];
      [idx visit: self];
      [res visit: self];
      id<CPConstraint> concreteCstr = [CPFactory element: (id<CPIntVar>) [idx dereference]
                                             idxCstArray: array
                                                   equal: (id<CPIntVar>) [res dereference]
                                       ];
     [cstr setImpl: concreteCstr];
   }
}
-(void) visitElementVar: (id<ORElementVar>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> array = [cstr array];
      id<ORIntVar> idx = [cstr idx];
      id<ORIntVar> res = [cstr res];
      [array visit: self];
      [idx visit: self];
      [res visit: self];
      id<CPConstraint> concreteCstr = [CPFactory element: (id<CPIntVar>) [idx dereference]
                                             idxVarArray: (id<CPIntVarArray>) [array impl]
                                                   equal: (id<CPIntVar>) [res dereference]
                                       ];
     [cstr setImpl: concreteCstr];
   }
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>) cstr
{
  if ([cstr impl] == NULL) {
     id<ORIntVar> b = [cstr b];
     id<ORIntVar> x = [cstr x];
     ORInt cst = [cstr cst];
     [b visit: self];
     [x visit: self];
     id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] eqi: cst];
     [cstr setImpl: concreteCstr];
  }
}
-(void) visitReifyEqual: (id<ORReifyEqual>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      id<ORIntVar> y = [cstr y];
      ORAnnotation annotation = [cstr annotation];
      [b visit: self];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] eq: [y impl] consistency: annotation];
      [cstr setImpl: concreteCstr];
   }
   
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] neqi: cst];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      id<ORIntVar> y = [cstr y];
      ORAnnotation annotation = [cstr annotation];
      [b visit: self];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] neq: [y impl] consistency: annotation];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] leqi: cst];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>) cstr
{
   if ([cstr impl] == NULL) {
      @throw [[ORExecutionError alloc] initORExecutionError: "reify leq not yet implemented"];
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      id<ORIntVar> y = [cstr y];
//      ORAnnotation annotation = [cstr annotation];
//      [b visit: self];
//      [x visit: self];
//      [y visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] leq: [y impl] consistency: annotation];
//      [cstr setImpl: concreteCstr];
   }
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] geqi: cst];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>) cstr
{
   if ([cstr impl] == NULL) {
      @throw [[ORExecutionError alloc] initORExecutionError: "reify geq not yet implemented"];
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      id<ORIntVar> y = [cstr y];
//      ORAnnotation annotation = [cstr annotation];
//      [b visit: self];
//      [x visit: self];
//      [y visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] geq: [y impl] consistency: annotation];
//      [cstr setImpl: concreteCstr];
   }
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr
{
   if ([cstr impl] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concrete = [CPFactory sumbool:x eq:[cstr cst]];
      [cstr setImpl:concrete];
   }
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>) cstr
{
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>) cstr
{
   if ([cstr impl] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concrete = [CPFactory sumbool:x geq:[cstr cst]];
      [cstr setImpl:concrete];
   }
}
-(void) visitSumEqualc:(id<ORSumEqc>) cstr
{
   if ([cstr impl] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concrete = [CPFactory sum:x eq:[cstr cst]];
      [cstr setImpl:concrete];
   }   
}
-(void) visitSumLEqualc:(id<ORSumLEqc>) cstr
{
   if ([cstr impl] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concrete = [CPFactory sum:x leq:[cstr cst]];
      [cstr setImpl:concrete];
   }   
}
-(void) visitSumGEqualc:(id<ORSumGEqc>) cstr
{
   
}
//
-(void) visitIntegerI: (id<ORInteger>) e
{
   
}
-(void) visitExprPlusI: (id<ORExpr>) e
{
   
}
-(void) visitExprMinusI: (id<ORExpr>) e
{
   
}
-(void) visitExprMulI: (id<ORExpr>) e
{
   
}
-(void) visitExprEqualI: (id<ORExpr>) e
{
   
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
   
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
   
}
-(void) visitExprSumI: (id<ORExpr>) e
{
   
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
   
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
   
}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{
   
}
-(void) visitExprConjunctI: (id<ORExpr>) e
{
   
}
-(void) visitExprImplyI: (id<ORExpr>) e
{
   
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
   
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
   
}
@end


//@implementation ORCPMultiStartConcretizer
//{
//   id<ORTracker> _tracker;
//   CPMultiStartSolver* _solver;
//   ORInt _nb;
//}
//-(ORCPMultiStartConcretizer*) initORCPMultiStartConcretizer: (id<ORTracker>) tracker solver: (CPMultiStartSolver*) solver
//{
//   self = [super init];
//   _tracker = tracker;
//   _solver = solver;
//   _nb = [solver nb];
//   return self;
//}
//-(void) dealloc
//{
//   [_solver release];
//   [super dealloc];
//}
//
//-(id) concreteVar: (id<ORIntVar>) x
//{
//   // PVH to revisit soon
//   [x visit: self];
//   return [x impl];
//}
//
//-(id) concreteArray: (id<ORIntVarArray>) x
//{
//      // PVH to revisit soon
//   [x visit: self];
//   return [x impl];
//}
//
//-(void) visitTrailableInt:(id<ORTrailableInt>)v
//{
//}
//-(void) visitIntSet:(id<ORIntSet>)v
//{
//}
//-(void) visitIntRange:(id<ORIntRange>)v
//{
//}
//-(void) visitIntVar: (id<ORIntVar>) v
//{
//   if ([v impl] == NULL) {
//      
//      for(ORInt i = 0; i < _nb; i++) {
//         id<CPIntVar> cv = [CPFactory intVar: [[_solver at: i] engine] domain: [v domain]];
//         ba[i] = cv;
//      }
//      [v setImpl: ba];
//   }
//}
//-(void) visitFloatVar: (id<ORFloatVar>) v
//{
//   if ([v impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [v setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//
//      }
//      [v setImpl: ba];
//   }
//}
//-(void) visitAffineVar:(id<ORIntVar>) v
//{
//   if ([v impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [v setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [v setImpl: ba];
//   }
//
//   if ([v impl] == NULL) {
//      id<ORIntVar> mBase = [v base];
//      [mBase visit: self];
//      ORInt a = [v scale];
//      ORInt b = [v shift];
//      id<CPIntVar> cv = [CPFactory intVar:(id<CPIntVar>)[mBase dereference] scale:a shift:b];
//      [v setImpl: cv];
//   }
//}
//-(void) visitIntVarLitEQView:(id<ORIntVar>)v
//{
//   if ([v impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [v setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [v setImpl: ba];
//   }
//
//   if ([v impl] == NULL) {
//      id<ORIntVar> mBase = [v base];
//      [mBase visit:self];
//      ORInt lit = [v literal];
//      id<CPIntVar> cv = [CPFactory reifyView:(id<CPIntVar>)[mBase dereference] eqi:lit];
//      [v setImpl:cv];
//   }
//}
//
//-(void) visitIdArray: (id<ORIdArray>) v
//{
//   if ([v impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [v setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [v setImpl: ba];
//   }
//
//   if ([v impl] == NULL) {
//      id<ORIntRange> R = [v range];
//      id<ORIdArray> dx = [ORFactory idArray: _engine range: R];
//      ORInt low = R.low;
//      ORInt up = R.up;
//      for(ORInt i = low; i <= up; i++)
//         dx[i] = [v[i] dereference];
//      [v setImpl: dx];
//   }
//}
//-(void) visitIdMatrix: (id<ORIdMatrix>) v
//{
//   
//}
//-(void) visitIntArray:(id<ORIntArray>) v
//{
//   
//}
//-(void) visitIntMatrix: (id<ORIntMatrix>) v
//{
//   
//}
//-(void) visitTable:(id<ORTable>) v
//{
//   
//}
//
//-(void) visitRestrict: (id<ORRestrict>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//
//   if ([cstr impl] == NULL) {
//      id<CPIntVar> x = [self concreteVar: [cstr var]];
//      id<CPConstraint> concrete = [CPFactory restrict:x to:[cstr restriction]];
//      [cstr setImpl:concrete];
//   }
//}
//-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//
//   if ([cstr impl] == NULL) {
//      id<ORIntVarArray> ax = [cstr array];
//      ORAnnotation n = [cstr annotation];
//      [ax visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory alldifferent: _engine over: [ax impl] consistency: n];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitCardinality: (id<ORCardinality>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//
//   if ([cstr impl] == NULL) {
//      id<ORIntVarArray> ax = [cstr array];
//      id<ORIntArray> low = [cstr low];
//      id<ORIntArray> up = [cstr up];
//      ORAnnotation n = [cstr annotation];
//      [ax visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory cardinality: [ax impl] low: low up: up consistency: n];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitPacking: (id<ORPacking>) cstr
//{
//   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Algebraic constraints"];
//}
//-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
//{
//   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Algebraic constraints"];
//}
//-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//
//   if ([cstr impl] == NULL) {
//      id<ORIntVarArray> array = [cstr array];
//      id<ORTable> table = [cstr table];
//      [array visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory table: table on: [array impl]];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitCircuit:(id<ORCircuit>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([cstr impl] == NULL) {
//      id<ORIntVarArray> ax = [cstr array];
//      [ax visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory circuit: [ax impl]];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitNoCycle:(id<ORNoCycle>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//
//   if ([cstr impl] == NULL) {
//      id<ORIntVarArray> ax = [cstr array];
//      [ax visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory nocycle: [ax impl]];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitLexLeq:(id<ORLexLeq>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([cstr impl] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr x]];
//      id<CPIntVarArray> y = [self concreteArray:[cstr y]];
//      id<CPConstraint> concrete = [CPFactory lex:x leq:y];
//      [cstr setImpl:concrete];
//   }
//}
//-(void) visitPackOne:(id<ORPackOne>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([cstr impl] == NULL) {
//      id<ORIntVarArray> item = [cstr item];
//      id<ORIntArray> itemSize = [cstr itemSize];
//      ORInt bin = [cstr bin];
//      id<ORIntVar> binSize = [cstr binSize];
//      [item visit: self];
//      [binSize visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory packOne: [item impl] itemSize: itemSize bin: bin binSize: [binSize impl]];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitKnapsack:(id<ORKnapsack>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([cstr impl] == NULL) {
//      id<ORIntVarArray> item = [cstr item];
//      id<ORIntArray> weight = [cstr weight];
//      id<ORIntVar> capacity = [cstr capacity];
//      [item visit: self];
//      [capacity visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory knapsack:[item impl] weight:weight capacity:[capacity impl]];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitMinimize: (id<ORObjectiveFunction>) v
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([v impl] == NULL) {
//      id<ORIntVar> o = [v var];
//      [o visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory minimize: [o impl]];
//      [v setImpl: concreteCstr];
//   }
//}
//-(void) visitMaximize: (id<ORObjectiveFunction>) v
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([v impl] == NULL) {
//      id<ORIntVar> o = [v var];
//      [o visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory maximize: [o impl]];
//      [v setImpl: concreteCstr];
//   }
//}
//-(void) visitEqualc: (id<OREqualc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory equalc: (id<CPIntVar>) [left dereference]  to: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitNEqualc: (id<ORNEqualc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory notEqualc: (id<CPIntVar>) [left dereference]  to: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitLEqualc: (id<ORLEqualc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory lEqualc: (id<CPIntVar>) [left dereference]  to: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitEqual: (id<OREqual>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//      [cstr setImpl: ba];
//      for(ORInt i = 0; i < _nb; i++) {
//         
//      }
//      [cstr setImpl: ba];
//   }
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory equal: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//
//-(void) visitNEqual: (id<ORNEqual>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory notEqual: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitLEqual: (id<ORLEqual>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory lEqual: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitPlus: (id<ORPlus>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      ORAnnotation annotation = [cstr annotation];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory equal3: (id<CPIntVar>) [res dereference]
//                                                     to: (id<CPIntVar>) [left dereference]
//                                                   plus: (id<CPIntVar>) [right dereference]
//                                            consistency:annotation
//                                       ];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitMult: (id<ORMult>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory mult: (id<CPIntVar>) [left dereference]
//                                                   by: (id<CPIntVar>) [right dereference]
//                                                equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      [cstr setImpl: concreteCstr];
//   }
//}
//
//-(void) visitAbs: (id<ORAbs>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      [res visit: self];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory abs: (id<CPIntVar>) [left dereference]
//                                               equal: (id<CPIntVar>) [res dereference]
//                                         consistency: DomainConsistency
//                                       ];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitOr: (id<OROr>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
//                                                      or: (id<CPIntVar>) [right dereference]
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitAnd:( id<ORAnd>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
//                                                     and: (id<CPIntVar>) [right dereference]
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitImply: (id<ORImply>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
//                                                   imply: (id<CPIntVar>) [right dereference]
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitElementCst: (id<ORElementCst>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntArray> array = [cstr array];
//      id<ORIntVar> idx = [cstr idx];
//      id<ORIntVar> res = [cstr res];
//      [array visit: self];
//      [idx visit: self];
//      [res visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory element: (id<CPIntVar>) [idx dereference]
//                                             idxCstArray: array
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitElementVar: (id<ORElementVar>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVarArray> array = [cstr array];
//      id<ORIntVar> idx = [cstr idx];
//      id<ORIntVar> res = [cstr res];
//      [array visit: self];
//      [idx visit: self];
//      [res visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory element: (id<CPIntVar>) [idx dereference]
//                                             idxVarArray: (id<CPIntVarArray>) [array impl]
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitReifyEqualc: (id<ORReifyEqualc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      ORInt cst = [cstr cst];
//      [b visit: self];
//      [x visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] eqi: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitReifyEqual: (id<ORReifyEqual>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      id<ORIntVar> y = [cstr y];
//      ORAnnotation annotation = [cstr annotation];
//      [b visit: self];
//      [x visit: self];
//      [y visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] eq: [y impl] consistency: annotation];
//      [cstr setImpl: concreteCstr];
//   }
//   
//}
//-(void) visitReifyNEqualc: (id<ORReifyNEqualc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      ORInt cst = [cstr cst];
//      [b visit: self];
//      [x visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] neqi: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitReifyNEqual: (id<ORReifyNEqual>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      id<ORIntVar> y = [cstr y];
//      ORAnnotation annotation = [cstr annotation];
//      [b visit: self];
//      [x visit: self];
//      [y visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] neq: [y impl] consistency: annotation];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitReifyLEqualc: (id<ORReifyLEqualc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      ORInt cst = [cstr cst];
//      [b visit: self];
//      [x visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] leqi: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitReifyLEqual: (id<ORReifyLEqual>) cstr
//{
//   if ([cstr impl] == NULL) {
//      @throw [[ORExecutionError alloc] initORExecutionError: "reify leq not yet implemented"];
//      //      id<ORIntVar> b = [cstr b];
//      //      id<ORIntVar> x = [cstr x];
//      //      id<ORIntVar> y = [cstr y];
//      //      ORAnnotation annotation = [cstr annotation];
//      //      [b visit: self];
//      //      [x visit: self];
//      //      [y visit: self];
//      //      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] leq: [y impl] consistency: annotation];
//      //      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitReifyGEqualc: (id<ORReifyGEqualc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      ORInt cst = [cstr cst];
//      [b visit: self];
//      [x visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] geqi: cst];
//      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitReifyGEqual: (id<ORReifyGEqual>) cstr
//{
//   if ([cstr impl] == NULL) {
//      @throw [[ORExecutionError alloc] initORExecutionError: "reify geq not yet implemented"];
//      //      id<ORIntVar> b = [cstr b];
//      //      id<ORIntVar> x = [cstr x];
//      //      id<ORIntVar> y = [cstr y];
//      //      ORAnnotation annotation = [cstr annotation];
//      //      [b visit: self];
//      //      [x visit: self];
//      //      [y visit: self];
//      //      id<CPConstraint> concreteCstr = [CPFactory reify: [b impl] with: [x impl] geq: [y impl] consistency: annotation];
//      //      [cstr setImpl: concreteCstr];
//   }
//}
//-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
//      id<CPConstraint> concrete = [CPFactory sumbool:x eq:[cstr cst]];
//      [cstr setImpl:concrete];
//   }
//}
//-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>) cstr
//{
//}
//-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
//      id<CPConstraint> concrete = [CPFactory sumbool:x geq:[cstr cst]];
//      [cstr setImpl:concrete];
//   }
//}
//-(void) visitSumEqualc:(id<ORSumEqc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
//      id<CPConstraint> concrete = [CPFactory sum:x eq:[cstr cst]];
//      [cstr setImpl:concrete];
//   }
//}
//-(void) visitSumLEqualc:(id<ORSumLEqc>) cstr
//{
//   if ([cstr impl] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
//      id<CPConstraint> concrete = [CPFactory sum:x leq:[cstr cst]];
//      [cstr setImpl:concrete];
//   }
//}
//-(void) visitSumGEqualc:(id<ORSumGEqc>) cstr
//{
//   
//}
////
//-(void) visitIntegerI: (id<ORInteger>) e
//{
//   
//}
//-(void) visitExprPlusI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprMinusI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprMulI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprEqualI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprNEqualI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprLEqualI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprSumI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprAbsI:(id<ORExpr>) e
//{
//   
//}
//-(void) visitExprCstSubI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprDisjunctI:(id<ORExpr>) e
//{
//   
//}
//-(void) visitExprConjunctI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprImplyI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprAggOrI: (id<ORExpr>) e
//{
//   
//}
//-(void) visitExprVarSubI: (id<ORExpr>) e
//{
//   
//}
//@end

//@implementation ORExprConcretizer
//{
//   CPConcretizerI* _concretizer;
//   id<ORExpr> _result;
//}
//-(ORExprConcretizer*) initORExprConcretizer:(CPConcretizerI*) concretizer
//{
//   self = [super init];
//   _concretizer = concretizer;
//   return self;
//}
//-(id<ORExpr>) result
//{
//   return _result;
//}
//-(void) visitIntegerI: (id<ORInteger>) e
//{
//   _result = e;
//}
//-(void) visitExprPlusI: (ORExprPlusI*) e
//{
//   [[e left] visit: self];
//   id<ORExpr> leftc = _result;
//   [[e right] visit: self];
//   id<ORExpr> rightc = _result;
//   _result = [ORFactory expr: leftc plus: rightc];
//}
//-(void) visitExprMinusI: (ORExprMinusI*) e
//{
//   [[e left] visit: self];
//   id<ORExpr> leftc = _result;
//   [[e right] visit: self];
//   id<ORExpr> rightc = _result;
//   _result = [ORFactory expr: leftc sub: rightc];
//}
//-(void) visitExprMulI: (ORExprMulI*) e
//{
//   [[e left] visit: self];
//   id<ORExpr> leftc = _result;
//   [[e right] visit: self];
//   id<ORExpr> rightc = _result;
//   _result = [ORFactory expr: leftc mul: rightc];
//}
//-(void) visitExprEqualI: (ORExprEqualI*) e
//{
//   [[e left] visit: self];
//   id<ORExpr> leftc = _result;
//   [[e right] visit: self];
//   id<ORExpr> rightc = _result;
//   _result = [ORFactory expr: leftc equal: rightc];
//}
//-(void) visitExprNEqualI: (ORExprNotEqualI*) e
//{
//   [[e left] visit: self];
//   id<ORExpr> leftc = _result;
//   [[e right] visit: self];
//   id<ORExpr> rightc = _result;
//   _result = [ORFactory expr: leftc neq: rightc];
//}
//-(void) visitExprLEqualI: (ORExprLEqualI*) e
//{
//   [[e left] visit: self];
//   id<ORExpr> leftc = _result;
//   [[e right] visit: self];
//   id<ORExpr> rightc = _result;
//   _result = [ORFactory expr: leftc leq: rightc];
//}
//-(void) visitExprSumI: (ORExprSumI*) e
//{
//   [[e expr] visit: self];  // we can remove the sum node. It serves no purpose.
//}
//-(void) visitExprAbsI: (ORExprAbsI*) e
//{
//   [[e operand] visit: self];
//   id<ORExpr> ec = _result;
//   _result = [ORFactory exprAbs: ec];
//}
//-(void) visitExprCstSubI: (ORExprCstSubI*) e
//{
//   ORExprI* index = [e index];
//   [index visit: self];
//   id<ORExpr> indexc = _result;
//   _result = [ORFactory elt:[e tracker] intArray:[e array] index:indexc];
//}
//-(void) visitExprDisjunctI: (ORDisjunctI*) e
//{
//   [[e left] visit: self];
//   id<ORRelation> leftc = (id<ORRelation>) _result;
//   [[e right] visit: self];
//   id<ORRelation> rightc = (id<ORRelation>) _result;
//   _result = [ORFactory  expr: leftc or: rightc];
//}
//-(void) visitExprConjunctI: (ORConjunctI*) e;
//{
//   [[e left] visit: self];
//   id<ORRelation> leftc = (id<ORRelation>) _result;
//   [[e right] visit: self];
//   id<ORRelation> rightc = (id<ORRelation>) _result;
//   _result = [ORFactory expr: leftc and: rightc];
//}
//-(void) visitExprImplyI: (ORImplyI*) e
//{
//   [[e left] visit: self];
//   id<ORRelation> leftc = (id<ORRelation>) _result;
//   [[e right] visit: self];
//   id<ORRelation> rightc = (id<ORRelation>) _result;
//   _result = [ORFactory expr: leftc imply: rightc];
//}
//-(void) visitExprAggOrI: (ORExprAggOrI*) e
//{
//   [[e expr] visit: self]; // we can remove the OR node, it serves no purpose.
//}
//-(void) visitIntVar: (id<ORIntVar>) var
//{
//   [var visit:_concretizer];
//   _result = [var dereference];
//}
//-(void) visitExprVarSubI: (ORExprVarSubI*) e
//{
//   [_concretizer idArray: [e array]];
//   ORExprI* index = [e index];
//   [index visit: self];
//   id<ORExpr> indexc = _result;
//   _result = [ORFactory  elt:[e tracker] intVarArray:[e array] index:indexc];
//}
//@end
//

//@implementation CPConcretizerI
//{
//   id<CPSolver> _solver;
//}
//-(CPConcretizerI*) initCPConcretizerI: (id<CPSolver>) solver
//{
//   self = [super init];
//   _solver = solver;
//   return self;
//}
//-(id<ORIntVar>) intVar: (id<ORIntVar>) v
//{
//   return [CPFactory intVar: _solver domain: [v domain]];
//}
//-(id<ORFloatVar>) floatVar: (id<ORFloatVar>) v
//{
//   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for floatVar"];
//   return nil;
//}
//-(id<ORIntVar>) affineVar:(id<ORIntVar>) v
//{
//   id<ORIntVar> mBase = [v base];
//   ORInt a = [v scale];
//   ORInt b = [v shift];
//   return [CPFactory intVar:[mBase dereference] scale:a shift:b];
//}
//-(id<ORIdArray>) idArray: (id<ORIdArray>) a
//{
//   assert(FALSE); // [todo]
//}
//
//-(id<ORConstraint>) alldifferent: (ORAlldifferentI*) cstr
//{
//   id<ORIntVarArray> dx = [ORFactory intVarArrayDereference: _solver array: [cstr array]];
//   id<ORConstraint> ncstr = [CPFactory alldifferent: _solver over: dx];
//   [_solver add: ncstr];
//   return ncstr;
//}
//-(id<ORConstraint>) cardinality: (ORCardinalityI*) cstr
//{
//   id<ORIntVarArray> dx = [ORFactory intVarArrayDereference: _solver array: [cstr array]];
//   id<ORConstraint> ncstr = [CPFactory cardinality: dx low: [cstr low] up: [cstr up] consistency: DomainConsistency];
//   [_solver add: ncstr];
//   return ncstr;
//}
//-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr
//{
//   id<ORIntVarArray> ditem = [ORFactory intVarArrayDereference: _solver array: [cstr item]];
//   id<ORIntVarArray> dbinSize = [ORFactory intVarArrayDereference: _solver array: [cstr binSize]];
//   id<ORConstraint> ncstr = [CPFactory packing: ditem itemSize: [cstr itemSize] load: dbinSize];
//   [_solver add: ncstr];
//   return ncstr;
//}
//-(id<ORConstraint>) algebraicConstraint: (ORAlgebraicConstraintI*) cstr
//{
//   ORExprConcretizer* ec = [[ORExprConcretizer alloc] initORExprConcretizer: _solver concretizer: self];
//   [((ORExprI*) [cstr expr]) visit: ec];
//   id<ORConstraint> c = [CPFactory relation2Constraint:_solver expr: [ec result]];
//   [_solver add: c];
//   [ec release];
//   return c;
//}
//-(id<ORConstraint>) tableConstraint: (ORTableConstraintI*) cstr
//{
//   id<ORIntVarArray> x = [ORFactory intVarArrayDereference: _solver array: [cstr array]];
//   id<ORConstraint> c = [CPFactory table: [cstr table] on: x];
//   [_solver add: c];
//   return c;
//}
//-(id<ORObjectiveFunction>) minimize: (id<ORObjectiveFunction>) v
//{
//   id<ORObjective> rv = [_solver minimize: [[v var] dereference]];
//   return rv;
//}
//-(id<ORObjectiveFunction>) maximize: (id<ORObjectiveFunction>) v
//{
//   id<ORObjective> rv = [_solver maximize: [[v var] dereference]];
//   return rv;
//}
//@end
//

