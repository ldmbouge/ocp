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
#import <objcp/CPBitConstraint.h>


@implementation ORCPConcretizer
{
   id<CPCommonProgram> _solver;
   id<CPEngine>        _engine;
   id*                 _gamma;
}
-(ORCPConcretizer*) initORCPConcretizer: (id<CPCommonProgram>) solver
{
   self = [super init];
   _solver = [solver retain];
   _engine = [_solver engine];
   _gamma = [solver gamma];
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
   return _gamma[x.getId];
}

-(id) concreteArray: (id<ORIntVarArray>) x
{
   [x visit: self];
   return _gamma[x.getId];
}

-(id)concreteMatrix: (id<ORIntVarMatrix>) m
{
   [m visit:self];
   return _gamma[m.getId];
}
// visit interface

-(void) visitTrailableInt: (id<ORTrailableInt>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORTrailableInt> n = [ORFactory trailableInt:_engine value: [v value]];
      _gamma[v.getId] = n;
   }
}
-(void) visitIntSet: (id<ORIntSet>) v
{}
-(void) visitIntRange:(id<ORIntRange>) v
{}
-(void) visitUniformDistribution:(id) v
{}

-(void) visitIntVar: (id<ORIntVar>) v
{
   if (!_gamma[v.getId]) 
      _gamma[[v getId]] = [CPFactory intVar: _engine domain: [v domain]];
}

-(void) visitFloatVar: (id<ORFloatVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet for Float Variables"];
}

-(void) visitBitVar: (id<ORBitVar>) v
{
   if (_gamma[v.getId] == NULL) 
      _gamma[v.getId] = [CPFactory bitVar:_engine withLow:[v low] andUp:[v up] andLength:[v bitLength]];
}

-(void) visitAffineVar:(id<ORIntVar>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit: self];
      ORInt a = [v scale];
      ORInt b = [v shift];
      _gamma[v.getId] = [CPFactory intVar:(id<CPIntVar>) _gamma[mBase.getId] scale:a shift:b];
   }
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit:self];
      ORInt lit = [v literal];
      _gamma[v.getId] = [CPFactory reifyView:(id<CPIntVar>) _gamma[mBase.getId] eqi:lit];
   }
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _engine range: R];
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
-(void) visitFloatArray:(id<ORIntArray>) v
{
}
-(void) visitIntMatrix: (id<ORIntMatrix>) v
{
}

-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   if (_gamma[v.getId] == NULL) {
      ORInt nb = (ORInt) [v count];
      for(ORInt k = 0; k < nb; k++)
         [[v flat: k] visit: self];
      id<ORIdMatrix> n = [ORFactory idMatrix: _engine with: v];
      for(ORInt k = 0; k < nb; k++)
         [n setFlat: _gamma[[[v flat: k] getId]] at: k];
      _gamma[[v getId]] = n;
   }
}

-(void) visitTable:(id<ORTable>) v
{
}
-(void) visitGroup:(id<ORGroup>)g
{
   if (_gamma[g.getId] == NULL) {
      id<CPGroup> cg = nil;
      switch([g type]) {
         case BergeGroup:
            cg = [CPFactory bergeGroup:_engine];
            break;
         default:
            cg = [CPFactory group:_engine];
            break;
      }
      [_engine add:cg]; // Do this first!!!! We want to have the group posted before posting the constraints of the group.
      [g enumerateObjectWithBlock:^(id<ORConstraint> ck) {
         [ck visit:self];
         [cg add: _gamma[ck.getId]];
      }];
      _gamma[g.getId] = cg;
   }
}


-(void) visitRestrict: (id<ORRestrict>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> x = [self concreteVar: [cstr var]];
      id<CPConstraint> concrete = [CPFactory restrict: x to: [cstr restriction]];
      [_engine add: concrete];
      _gamma[cstr.getId] = concrete;
   }
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      ORAnnotation n = [cstr annotation];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory alldifferent: _engine over: _gamma[ax.getId] annotation: n];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      id<ORIntArray> low = [cstr low];
      id<ORIntArray> up = [cstr up];
      ORAnnotation n = [cstr annotation];
      [ax visit: self];
      [low visit: self];
      [up visit: self];
      id<CPConstraint> concreteCstr = [CPFactory cardinality: _gamma[ax.getId] low: low up: up annotation: n];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
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
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> array = [cstr array];
      id<ORTable> table = [cstr table];
      [array visit: self];
      [table visit: self];
      id<CPConstraint> concreteCstr = [CPFactory table: table on: _gamma[array.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory circuit: _gamma[ax.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitNoCycle:(id<ORNoCycle>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory nocycle: _gamma[ax.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitLexLeq:(id<ORLexLeq>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray: [cstr x]];
      id<CPIntVarArray> y = [self concreteArray: [cstr y]];
      id<CPConstraint> concrete = [CPFactory lex: x leq: y];
      [_engine add: concrete];
      _gamma[cstr.getId] = concrete;
   }
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> item = [cstr item];
      id<ORIntArray> itemSize = [cstr itemSize];
      ORInt bin = [cstr bin];
      id<ORIntVar> binSize = [cstr binSize];
      [item visit: self];
      [itemSize visit: self];
      [binSize visit: self];
      id<CPConstraint> concreteCstr = [CPFactory packOne: _gamma[item.getId] itemSize: itemSize bin: bin binSize: _gamma[binSize.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> item = [cstr item];
      id<ORIntArray> weight = [cstr weight];
      id<ORIntVar> capacity = [cstr capacity];
      [item visit: self];
      [weight visit: self];
      [capacity visit: self];
      id<CPConstraint> concreteCstr = [CPFactory knapsack: _gamma[item.getId] weight: weight capacity: _gamma[capacity.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray: [cstr x]];
      id<ORIntMatrix> matrix = [cstr matrix];
      [matrix visit: self];
      id<CPIntVar> cost = [self concreteVar: [cstr cost]];
      id<CPConstraint> concreteCstr = [CPFactory assignment: _engine array: x matrix: _gamma[matrix.getId] cost: cost];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      id<CPConstraint> concreteCstr = [CPFactory minimize: _gamma[o.getId]];
      _gamma[v.getId] = concreteCstr;
      [_engine add: concreteCstr];
      [_engine setObjective: _gamma[v.getId]];
   }
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      id<CPConstraint> concreteCstr = [CPFactory maximize: _gamma[o.getId]];
      _gamma[v.getId] = concreteCstr;
      [_engine add: concreteCstr];
      [_engine setObjective: _gamma[v.getId]];
   }
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of minimizeExpr not yet implemented"]; 
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of maximizeExpr not yet implemented"];    
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of minimizeLinear not yet implemented"]; 
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of minimizeLinear not yet implemented"]; 
}


-(void) visitEqualc: (id<OREqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory equalc: (id<CPIntVar>) _gamma[left.getId]  to: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitNEqualc: (id<ORNEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory notEqualc: (id<CPIntVar>) _gamma[left.getId]  to: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
      
   }
}
-(void) visitLEqualc: (id<ORLEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory lEqualc: (id<CPIntVar>) _gamma[left.getId]  to: cst];
      [_engine add: concreteCstr];
   }
}
-(void) visitGEqualc: (id<ORGEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory gEqualc: (id<CPIntVar>) _gamma[left.getId]   to: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitEqual: (id<OREqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> left  = [self concreteVar:[cstr left]];
      id<CPIntVar> right = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory equal: left
                                                    to: right
                                                  plus: [cstr cst]
                                            annotation: [cstr annotation]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitAffine: (id<ORAffine>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> y = [self concreteVar:[cstr left]];
      id<CPIntVar> x = [self concreteVar:[cstr right]];
      id<CPConstraint> concrete = [CPFactory affine:y equal:[cstr coef] times:x plus:[cstr cst] annotation:[cstr annotation]];
      [_engine add:concrete];
      _gamma[cstr.getId] = concrete;
   }
}

-(void) visitNEqual: (id<ORNEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORInt cst = [cstr cst];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory notEqual: (id<CPIntVar>) _gamma[left.getId]  to: (id<CPIntVar>) _gamma[right.getId] plus: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitLEqual: (id<ORLEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORInt cst = [cstr cst];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory lEqual: (id<CPIntVar>) _gamma[left.getId]  to: (id<CPIntVar>) _gamma[right.getId] plus: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitPlus: (id<ORPlus>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORAnnotation annotation = [cstr annotation];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory equal3: (id<CPIntVar>) _gamma[res.getId]
                                                     to: (id<CPIntVar>) _gamma[left.getId] 
                                                   plus: (id<CPIntVar>) _gamma[right.getId]
                                             annotation:annotation
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitMult: (id<ORMult>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory mult: (id<CPIntVar>) _gamma[left.getId] 
                                                   by: (id<CPIntVar>) _gamma[right.getId]
                                                equal: (id<CPIntVar>) _gamma[res.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSquare: (id<ORSquare>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> op  = [self concreteVar:[cstr op]];
      ORAnnotation annotation = [cstr annotation];
      id<CPConstraint> concrete = [CPFactory square:op equal:res annotation:annotation];
      [_engine add:concrete];
      _gamma[cstr.getId] = concrete;
   }
}


-(void) visitMod: (id<ORMod>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> left = [self concreteVar:[cstr left]];
      id<CPIntVar> right = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr  = [CPFactory mod:left mod:right equal:res];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitModc: (id<ORModc>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> left = [self concreteVar:[cstr left]];
      ORAnnotation annotation = [cstr annotation];
      ORInt right = [cstr right];
      id<CPConstraint> concreteCstr  = [CPFactory mod:left modi:right equal:res annotation:annotation];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}


-(void) visitAbs: (id<ORAbs>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      [res visit: self];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory abs: (id<CPIntVar>) _gamma[left.getId] 
                                               equal: (id<CPIntVar>) _gamma[res.getId]
                                          annotation: DomainConsistency
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitOr: (id<OROr>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) _gamma[left.getId] 
                                                      or: (id<CPIntVar>) _gamma[right.getId]
                                                   equal: (id<CPIntVar>) _gamma[res.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitAnd:( id<ORAnd>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) _gamma[left.getId] 
                                                     and: (id<CPIntVar>) _gamma[right.getId]
                                                   equal: (id<CPIntVar>) _gamma[res.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitImply: (id<ORImply>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) _gamma[left.getId] 
                                                   imply: (id<CPIntVar>) _gamma[right.getId]
                                                   equal: (id<CPIntVar>) _gamma[res.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitElementCst: (id<ORElementCst>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntArray> array = [cstr array];
      id<ORIntVar> idx = [cstr idx];
      id<ORIntVar> res = [cstr res];
      [array visit: self];
      [idx visit: self];
      [res visit: self];
      id<CPConstraint> concreteCstr = [CPFactory element: (id<CPIntVar>) _gamma[idx.getId]
                                             idxCstArray: array
                                                   equal: (id<CPIntVar>) _gamma[res.getId]
                                              annotation: [cstr annotation]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitElementVar: (id<ORElementVar>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> array = [self concreteArray:[cstr array]];
      id<CPIntVar> idx = [self concreteVar:[cstr idx]];
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory element: idx
                                             idxVarArray: array
                                                   equal: res
                                              annotation: [cstr annotation]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitElementMatrixVar:(id<ORElementMatrixVar>)cstr
{
   assert(FALSE);
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] eqi: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyEqual: (id<ORReifyEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      id<ORIntVar> y = [cstr y];
      ORAnnotation annotation = [cstr annotation];
      [b visit: self];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] eq: _gamma[y.getId] annotation: annotation];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
   
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] neqi: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      id<ORIntVar> y = [cstr y];
      ORAnnotation annotation = [cstr annotation];
      [b visit: self];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] neq: _gamma[y.getId] annotation: annotation];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] leqi: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPIntVar> x = [self concreteVar:[cstr x]];
      id<CPIntVar> y = [self concreteVar:[cstr y]];      
      id<CPConstraint> concreteCstr = [CPFactory reify: b with: x leq: y annotation: Default];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] geqi: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPIntVar> x = [self concreteVar:[cstr x]];
      id<CPIntVar> y = [self concreteVar:[cstr y]];
      id<CPConstraint> concreteCstr = [CPFactory reify: b with: y leq: x annotation: Default];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sumbool:x eq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) 
      @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolLEqualc not yet implemented"];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sumbool:x geq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumEqualc:(id<ORSumEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sum:x eq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumLEqualc:(id<ORSumLEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sum:x leq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumGEqualc:(id<ORSumGEqc>) cstr
{
}

// Bit
-(void) visitBitEqual:(id<ORBitEqual>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitEqual:x to:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitOr:(id<ORBitOr>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitOR:x or:y equals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitAnd:(id<ORBitAnd>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitAND:x and:y equals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitNot:(id<ORBitNot>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitNOT:x equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitXor:(id<ORBitXor>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitXOR:x xor:y equals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitShiftL:(id<ORBitShiftL>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      ORInt p = [cstr places];
      id<CPConstraint> concreteCstr = [CPFactory bitShiftL:x by:p equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitRotateL:(id<ORBitRotateL>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      ORInt p = [cstr places];
      id<CPConstraint> concreteCstr = [CPFactory bitRotateL:x by:p equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitSum:(id<ORBitSum>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPBitVar> ci = [self concreteVar:[cstr in]];
      id<CPBitVar> co = [self concreteVar:[cstr out]];
      id<CPConstraint> concreteCstr = [CPFactory bitADD:x plus:y withCarryIn:ci equals:z withCarryOut:co];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitIf:(id<ORBitIf>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> w = [self concreteVar:[cstr res]];
      id<CPBitVar> x = [self concreteVar:[cstr trueIf]];
      id<CPBitVar> y = [self concreteVar:[cstr equals]];
      id<CPBitVar> z = [self concreteVar:[cstr zeroIfXEquals]];
      id<CPConstraint> concreteCstr = [CPFactory bitIF:w equalsOneIf:x equals:y andZeroIfXEquals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitIntegerI: (id<ORInteger>) e
{}
//
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   if (_gamma[e.getId] == NULL) 
      _gamma[e.getId] = [ORFactory mutable: _engine value: [e initialValue]];
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory mutableFloat: _engine value: [e initialValue]];
}
-(void) visitFloatI: (id<ORFloatNumber>) e
{
   if (_gamma[e.getId] == NULL) 
      _gamma[e.getId] = [ORFactory float: _engine value: [e floatValue]];
}
-(void) visitExprPlusI: (id<ORExpr>) e
{}
-(void) visitExprMinusI: (id<ORExpr>) e
{}
-(void) visitExprMulI: (id<ORExpr>) e
{}
-(void) visitExprDivI: (id<ORExpr>) e
{}
-(void) visitExprModI: (id<ORExpr>) e
{}
-(void) visitExprEqualI: (id<ORExpr>) e
{}
-(void) visitExprNEqualI: (id<ORExpr>) e
{}
-(void) visitExprLEqualI: (id<ORExpr>) e
{}
-(void) visitExprSumI: (id<ORExpr>) e
{}
-(void) visitExprProdI: (id<ORExpr>) e
{}
-(void) visitExprAbsI:(id<ORExpr>) e
{}
-(void) visitExprNegateI:(id<ORExpr>) e
{}
-(void) visitExprCstSubI: (id<ORExpr>) e
{}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{}
-(void) visitExprConjunctI: (id<ORExpr>) e
{}
-(void) visitExprImplyI: (id<ORExpr>) e
{}
-(void) visitExprAggOrI: (id<ORExpr>) e
{}
-(void) visitExprVarSubI: (id<ORExpr>) e
{}
@end


