/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORSet.h>
#import "CPProgram.h"
#import "CPConcretizer.h"
#import "CPConcretizer.h"
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPSolver.h>
#import <objcp/CPSolver.h>
#import <objcp/CPBitConstraint.h>


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
   if ([v dereference] == NULL) { 
      id<ORTrailableInt> n = [ORFactory trailableInt:_engine value: [v value]];
      [n makeImpl];
      [v setImpl: n];
   }
}
-(void) visitIntSet: (id<ORIntSet>) v
{
   if ([v dereference] == NULL) {   
      id<ORIntSet> i = [ORFactory intSet: _engine];
      [i makeImpl];
      [v copyInto: i];
      [v setImpl: i];
   }
}
-(void) visitIntRange:(id<ORIntRange>) v
{
   [v makeImpl];
}

-(void) visitIntVar: (id<ORIntVar>) v
{
   if ([v dereference] == NULL) {
      id<CPIntVar> cv = [CPFactory intVar: _engine domain: [v domain]];
      [v setImpl: cv];
   }
}

-(void) visitFloatVar: (id<ORFloatVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet for Float Variables"];
}

-(void) visitBitVar: (id<ORBitVar>) v
{
   if ([v dereference] == NULL) {
      id<CPBitVar> cv = [CPFactory bitVar:_engine withLow:[v low] andUp:[v up] andLength:[v bitLength]];
      [v setImpl:cv];
   }
}

-(void) visitAffineVar:(id<ORIntVar>) v
{
   if ([v dereference] == NULL) {
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
   if ([v dereference] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit:self];
      ORInt lit = [v literal];
      id<CPIntVar> cv = [CPFactory reifyView:(id<CPIntVar>)[mBase dereference] eqi:lit];
      [v setImpl:cv];
   }
}

-(void) visitIdArray: (id<ORIdArray>) v
{
   if ([v dereference] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _engine range: R];
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
      id<ORIntArray> dx = [ORFactory intArray: _engine range: R with: ^ORInt(ORInt i) { return [v at: i]; }];
      [dx makeImpl];
      [v setImpl: dx];
   }
   
}
-(void) visitIntMatrix: (id<ORIntMatrix>) v
{
   if ([v dereference] == NULL) {
      id<ORIntMatrix> n = [ORFactory intMatrix: _engine with: v];
      [n makeImpl];
      [v setImpl: n];
   }
}

-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
 if ([v dereference] == NULL) {
      ORInt nb = (ORInt) [v count];
      for(ORInt k = 0; k < nb; k++)
         [[v flat: k] visit: self];
      id<ORIdMatrix> n = [ORFactory idMatrix: _engine withDereferenced: v];
      [n makeImpl];
      [v setImpl: n];
   }
}

-(void) visitTable:(id<ORTable>) v
{
   if ([v dereference] == NULL) {
      id<ORTable> n = [ORFactory table: _engine with: v];
      [n makeImpl];
      [v setImpl: n];
   }
}

-(void) visitRestrict: (id<ORRestrict>) cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVar> x = [self concreteVar: [cstr var]];
      id<CPConstraint> concrete = [CPFactory restrict: x to: [cstr restriction]];
      [cstr setImpl:concrete];
      [_engine add: concrete];
   }
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      ORAnnotation n = [cstr annotation];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory alldifferent: _engine over: [ax dereference] annotation: n];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      id<ORIntArray> low = [cstr low];
      id<ORIntArray> up = [cstr up];
      ORAnnotation n = [cstr annotation];
      [ax visit: self];
      [low visit: self];
      [up visit: self];
      id<CPConstraint> concreteCstr = [CPFactory cardinality: [ax dereference] low: [low dereference] up: [up dereference] annotation: n];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
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
   if ([cstr dereference] == NULL) {
      id<ORIntVarArray> array = [cstr array];
      id<ORTable> table = [cstr table];
      [array visit: self];
      [table visit: self];
      id<CPConstraint> concreteCstr = [CPFactory table: [table dereference] on: [array dereference]];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory circuit: [ax dereference]];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitNoCycle:(id<ORNoCycle>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory nocycle: [ax dereference]];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitLexLeq:(id<ORLexLeq>) cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVarArray> x = [self concreteArray: [cstr x]];
      id<CPIntVarArray> y = [self concreteArray: [cstr y]];
      id<CPConstraint> concrete = [CPFactory lex: x leq: y];
      [cstr setImpl:concrete];
      [_engine add: concrete];
   }
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVarArray> item = [cstr item];
      id<ORIntArray> itemSize = [cstr itemSize];
      ORInt bin = [cstr bin];
      id<ORIntVar> binSize = [cstr binSize];
      [item visit: self];
      [itemSize visit: self];
      [binSize visit: self];
      id<CPConstraint> concreteCstr = [CPFactory packOne: [item dereference] itemSize: [itemSize dereference] bin: bin binSize: [binSize dereference]];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVarArray> item = [cstr item];
      id<ORIntArray> weight = [cstr weight];
      id<ORIntVar> capacity = [cstr capacity];
      [item visit: self];
      [weight visit: self];
      [capacity visit: self];
      id<CPConstraint> concreteCstr = [CPFactory knapsack: [item dereference] weight: [weight dereference] capacity: [capacity dereference]];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   if ([cstr impl] == NULL) {
      id<CPIntVarArray> x = [self concreteArray: [cstr x]];
      id<ORIntMatrix> matrix = [cstr matrix];
      [matrix visit: self];
      id<CPIntVar> cost = [self concreteVar: [cstr cost]];
      id<CPConstraint> concreteCstr = [CPFactory assignment: _engine array: x matrix: [matrix dereference] cost: cost];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitMinimize: (id<ORObjectiveFunction>) v
{
   if ([v dereference] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      id<CPConstraint> concreteCstr = [CPFactory minimize: [o dereference]];
      [v setImpl: concreteCstr];
      [_engine add: concreteCstr];
      [_engine setObjective: [v dereference]];
   }
}
-(void) visitMaximize: (id<ORObjectiveFunction>) v
{
   if ([v dereference] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      id<CPConstraint> concreteCstr = [CPFactory maximize: [o dereference]];
      [v setImpl: concreteCstr];
      [_engine add: concreteCstr];
      [_engine setObjective: [v dereference]];
   }
}
-(void) visitEqualc: (id<OREqualc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory equalc: (id<CPIntVar>) [left dereference]  to: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitNEqualc: (id<ORNEqualc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory notEqualc: (id<CPIntVar>) [left dereference]  to: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitLEqualc: (id<ORLEqualc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory lEqualc: (id<CPIntVar>) [left dereference]  to: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitGEqualc: (id<ORGEqualc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory gEqualc: (id<CPIntVar>) [left dereference]  to: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitEqual: (id<OREqual>) cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVar> left  = [self concreteVar:[cstr left]];
      id<CPIntVar> right = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory equal: left
                                                    to: right
                                                  plus: [cstr cst]
                                            annotation: [cstr annotation]];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitAffine: (id<ORAffine>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVar> y = [self concreteVar:[cstr left]];
      id<CPIntVar> x = [self concreteVar:[cstr right]];
      id<CPConstraint> concrete = [CPFactory affine:y equal:[cstr coef] times:x plus:[cstr cst] annotation:[cstr annotation]];
      [cstr setImpl: concrete];
      [_engine add:concrete];
   }
}

-(void) visitNEqual: (id<ORNEqual>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORInt cst = [cstr cst];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory notEqual: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitLEqual: (id<ORLEqual>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORInt cst = [cstr cst];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory lEqual: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitPlus: (id<ORPlus>) cstr
{
   if ([cstr dereference] == NULL) {
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
                                             annotation:annotation
                                       ];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitMult: (id<ORMult>) cstr
{
   if ([cstr dereference] == NULL) {
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
      [_engine add: concreteCstr];
   }
}

-(void) visitMod: (id<ORMod>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> left = [self concreteVar:[cstr left]];
      id<CPIntVar> right = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr  = [CPFactory mod:left mod:right equal:res];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitModc: (id<ORModc>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> left = [self concreteVar:[cstr left]];
      ORInt right = [cstr right];
      id<CPConstraint> concreteCstr  = [CPFactory mod:left modi:right equal:res];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}


-(void) visitAbs: (id<ORAbs>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      [res visit: self];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory abs: (id<CPIntVar>) [left dereference]
                                               equal: (id<CPIntVar>) [res dereference]
                                          annotation: DomainConsistency
                                       ];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitOr: (id<OROr>) cstr
{
   if ([cstr dereference] == NULL) {
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
      [_engine add: concreteCstr];
   }
}
-(void) visitAnd:( id<ORAnd>) cstr
{
   if ([cstr dereference] == NULL) {
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
      [_engine add: concreteCstr];
   }
}
-(void) visitImply: (id<ORImply>) cstr
{
   if ([cstr dereference] == NULL) {
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
      [_engine add: concreteCstr];
   }
}
-(void) visitElementCst: (id<ORElementCst>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntArray> array = [cstr array];
      id<ORIntVar> idx = [cstr idx];
      id<ORIntVar> res = [cstr res];
      [array visit: self];
      [idx visit: self];
      [res visit: self];
      id<CPConstraint> concreteCstr = [CPFactory element: (id<CPIntVar>) [idx dereference]
                                             idxCstArray: [array dereference]
                                                   equal: (id<CPIntVar>) [res dereference]
                                              annotation: [cstr annotation]
                                       ];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitElementVar: (id<ORElementVar>) cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVarArray> array = [self concreteArray:[cstr array]];
      id<CPIntVar> idx = [self concreteVar:[cstr idx]];
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory element: idx
                                             idxVarArray: array
                                                   equal: res
                                              annotation: [cstr annotation]
                                       ];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] eqi: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitReifyEqual: (id<ORReifyEqual>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      id<ORIntVar> y = [cstr y];
      ORAnnotation annotation = [cstr annotation];
      [b visit: self];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] eq: [y dereference] annotation: annotation];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
   
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] neqi: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      id<ORIntVar> y = [cstr y];
      ORAnnotation annotation = [cstr annotation];
      [b visit: self];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] neq: [y dereference] annotation: annotation];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] leqi: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>) cstr
{
   if ([cstr dereference] == NULL) {
      @throw [[ORExecutionError alloc] initORExecutionError: "reify leq not yet implemented"];
      //      id<ORIntVar> b = [cstr b];
      //      id<ORIntVar> x = [cstr x];
      //      id<ORIntVar> y = [cstr y];
      //      ORAnnotation annotation = [cstr annotation];
      //      [b visit: self];
      //      [x visit: self];
      //      [y visit: self];
      //      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] leq: [y dereference] annotation: annotation];
      //      [cstr setImpl: concreteCstr];
   }
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] geqi: cst];
      [cstr setImpl: concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>) cstr
{
   if ([cstr dereference] == NULL) {
      @throw [[ORExecutionError alloc] initORExecutionError: "reify geq not yet implemented"];
      //      id<ORIntVar> b = [cstr b];
      //      id<ORIntVar> x = [cstr x];
      //      id<ORIntVar> y = [cstr y];
      //      ORAnnotation annotation = [cstr annotation];
      //      [b visit: self];
      //      [x visit: self];
      //      [y visit: self];
      //      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] geq: [y dereference] annotation: annotation];
      //      [cstr setImpl: concreteCstr];
   }
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sumbool:x eq:[cstr cst]];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>) cstr
{
   if ([cstr dereference] == NULL)
      @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolLEqualc not yet implemented"];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sumbool:x geq:[cstr cst]];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitSumEqualc:(id<ORSumEqc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sum:x eq:[cstr cst]];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitSumLEqualc:(id<ORSumLEqc>) cstr
{
   if ([cstr dereference] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sum:x leq:[cstr cst]];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitSumGEqualc:(id<ORSumGEqc>) cstr
{
}

// Bit
-(void) visitBitEqual:(id<ORBitEqual>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitEqual:x to:y];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitBitOr:(id<ORBitOr>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitOR:x or:y equals:z];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitBitAnd:(id<ORBitAnd>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitAND:x and:y equals:z];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}
-(void) visitBitNot:(id<ORBitNot>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitNOT:x equals:y];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitBitXor:(id<ORBitXor>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitXOR:x xor:y equals:z];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitBitShiftL:(id<ORBitShiftL>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      ORInt p = [cstr places];
      id<CPConstraint> concreteCstr = [CPFactory bitShiftL:x by:p equals:y];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitBitRotateL:(id<ORBitRotateL>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      ORInt p = [cstr places];
      id<CPConstraint> concreteCstr = [CPFactory bitRotateL:x by:p equals:y];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitBitSum:(id<ORBitSum>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPBitVar> ci = [self concreteVar:[cstr in]];
      id<CPBitVar> co = [self concreteVar:[cstr out]];
      id<CPConstraint> concreteCstr = [CPFactory bitADD:x plus:y withCarryIn:ci equals:z withCarryOut:co];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

-(void) visitBitIf:(id<ORBitIf>)cstr
{
   if ([cstr dereference] == NULL) {
      id<CPBitVar> w = [self concreteVar:[cstr res]];
      id<CPBitVar> x = [self concreteVar:[cstr trueIf]];
      id<CPBitVar> y = [self concreteVar:[cstr equals]];
      id<CPBitVar> z = [self concreteVar:[cstr zeroIfXEquals]];
      id<CPConstraint> concreteCstr = [CPFactory bitIF:w equalsOneIf:x equals:y andZeroIfXEquals:z];
      [cstr setImpl:concreteCstr];
      [_engine add: concreteCstr];
   }
}

//
-(void) visitIntegerI: (id<ORInteger>) e
{
   if ([e dereference] == NULL) {
      id<ORInteger> n = [ORFactory integer: _engine value: [e value]];
      [n makeImpl];
      [e setImpl: n];
   }
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


