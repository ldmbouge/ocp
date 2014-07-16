/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORLSConcretizer.h"
#import <objls/LSFactory.h>
#import <objls/LSIntVar.h>
#import <objls/LSConstraint.h>
#import "ORVarI.h"

@interface ExprToLSFun : ORNOopVisit
+(id<LSFunction>)convert:(id<ORExpr>)expr forEngine:(id<LSEngine>)e concretizeWith:(ORLSConcretizer*)cc;
@end

@implementation ORLSConcretizer

-(ORLSConcretizer*) initORLSConcretizer: (id<LSProgram>) solver annotation:(id<ORAnnotation>)notes
{
   self = [super init];
   _solver = [solver retain];
   _engine = [_solver engine];
   _gamma = [solver gamma];
   _notes = notes;
   _allCstrs = [[NSMutableArray alloc] initWithCapacity:64];
   _hardCstrs = [[NSMutableArray alloc] initWithCapacity:64];
   _objective = nil;
   return self;
}
-(void) dealloc
{
   [_solver release];
   [_allCstrs release];
   [_hardCstrs release];
   [super dealloc];
}
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
   NSLog(@"DID NOT RECOGNIZE a selector %@",NSStringFromSelector(aSelector));
   @throw [[ORExecutionError alloc] initORExecutionError:"ORLSConcretizer missing a selector"];
   //return [super doesNotRecognizeSelector:aSelector];
}

-(id<LSConstraint>)wrapUp
{
   id<LSConstraint> sys = [LSFactory lrsystem:_engine with:_allCstrs];
   if (_objective) {
      id<LSConstraint> com = [LSFactory lrsystem:_engine with:@[sys,_objective]];
      [_engine addConstraint:sys];
      return [_engine addConstraint:com];
   } else {
      return [_engine addConstraint:sys];
   }
}
-(NSMutableArray*)hardSet
{
   return _hardCstrs;
}
// Helper function
-(id) concreteVar: (id<ORVar>) x
{
   [x visit:self];
   return _gamma[x.getId];
}

// [pvh] this needs to be replaced with a real scaled view
// [ldm] done.
-(id) scaleVar:(id<ORVar>) x coef:(ORInt)a
{
   [x visit:self];
   if (a == 1) {
      return _gamma[x.getId];
   } else {
      return [LSFactory intVarView:_engine a:a times:_gamma[getId(x)] plus:0];
   }
}
-(id) concreteArray: (id<ORVarArray>) x
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
-(void) visitFloatRange:(id<ORFloatRange>)v
{}
-(void) visitUniformDistribution:(id) v
{}

-(void) visitIntVar: (id<ORIntVar>) v
{
   if (!_gamma[v.getId])
      _gamma[v.getId] = [LSFactory intVar: _engine domain: [v domain]];
}

-(void) visitFloatVar: (id<ORFloatVar>) v
{
//   if (!_gamma[v.getId])
//      _gamma[v.getId] = [LSFactory floatVar: _engine bounds: [v domain]];
}

// [pvh] this must be transformed into an affine view as well to allow for increase/decrease
// [ldm] done.
-(void) visitAffineVar:(ORIntVarAffineI*) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit: self];
      ORInt a = [v scale];
      ORInt b = [v shift];
      LSIntVar* src = _gamma[getId(mBase)];
      _gamma[getId(v)] = [LSFactory intVarView:_engine a:a times:src plus:b];
   }
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit:self];
      ORInt lit = [v literal];
      LSIntVar* src = _gamma[getId(mBase)];
      _gamma[getId(v)] = [LSFactory intVarView:_engine var:src eq:lit];
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
      _gamma[v.getId] = dx;
   }
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{}

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
      _gamma[v.getId] = n;
   }
}
-(void) visitTable:(id<ORTable>) v
{
}
-(void) visitLEqual: (id<ORLEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<LSIntVar> left  = [self scaleVar:[cstr left] coef:[cstr coefLeft]];
      id<LSIntVar> right = [self scaleVar:[cstr right] coef:[cstr coefRight]];
      id<LSConstraint> concreteCstr = [LSFactory lEqual: left  to: right plus: [cstr cst]];
      [_engine addConstraint: concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitNEqualc: (id<ORNEqualc>)cstr
{
   if (_gamma[getId(cstr)] == NULL) {
      id<LSIntVar> left = [self concreteVar:[cstr left]];
      id<LSConstraint> concreteCstr = [LSFactory nEqualc: left to: [cstr cst]];
      [_engine addConstraint:concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[getId(cstr)] = concreteCstr;
   }
}
-(void) visitOr: (id<OROr>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<LSIntVar> res = [self concreteVar:[cstr res]];
      id<LSIntVar> left = [self concreteVar:[cstr left]];
      id<LSIntVar> right = [self concreteVar:[cstr right]];
      id<LSConstraint> concreteCstr = [LSFactory boolean: left or: right equal: res];
      [_engine addConstraint: concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}


-(void) visitLinearGeq: (id<ORLinearGeq>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError:"reached visitLinearGeq in CPConcretizer"];
}
-(void) visitLinearLeq: (id<ORLinearLeq>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError:"ORLSConcretizer missing a selector"];
}
-(void) visitLinearEq: (id<ORLinearEq>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<LSIntVarArray> ca = [self concreteArray:[cstr vars]];
      id<ORIntArray>    coefs = [cstr coefs];
      id<LSConstraint> concreteCstr = [LSFactory linear:_engine coef:coefs vars:ca eq:[cstr cst]];
      [_engine addConstraint:concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      //ORCLevel n = [_notes levelFor: cstr];  // [ldm] will be useful for Soft vs. Hard annotation
      id<LSIntVarArray> cax = [self concreteArray:(id)[cstr array]];
      id<LSConstraint> concreteCstr = [LSFactory alldifferent: _engine over: cax];
      [_engine addConstraint: concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
      ORCLevel annotation = [_notes levelFor:cstr];
      if (annotation == HardConsistency)
          [_hardCstrs addObject:concreteCstr];
   }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   if (_gamma[getId(cstr)] == NULL) {
      id<LSIntVarArray> cx = [self concreteArray:[cstr array]];
      id<ORIntArray>    low = [cstr low],up = [cstr up];
      id<LSConstraint> concreteCstr = [LSFactory cardinality:_engine low:low vars:cx up:up];
      [_engine addConstraint:concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[getId(cstr)] = concreteCstr;
      ORCLevel annotation = [_notes levelFor:cstr];
      if (annotation == HardConsistency)
         [_hardCstrs addObject:concreteCstr];
   }
}

-(void) visitMultiKnapsack: (id<ORMultiKnapsack>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<LSIntVarArray> citem = [self concreteArray:(id)[cstr item]];
      id<LSConstraint> concreteCstr = [LSFactory packing: citem weight: [cstr itemSize] capacity: [cstr capacity]];
      [_engine addConstraint: concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitMultiKnapsackOne: (id<ORMultiKnapsackOne>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<LSIntVarArray> citem = [self concreteArray:(id)[cstr item]];
      id<LSConstraint> concreteCstr = [LSFactory packingOne: citem weight: [cstr itemSize] bin: [cstr bin] capacity: [cstr capacity]];
      [_engine addConstraint: concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitMeetAtmost: (id<ORMeetAtmost>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<LSIntVarArray> cx = [self concreteArray:(id)[cstr x]];
      id<LSIntVarArray> cy = [self concreteArray:(id)[cstr y]];
      id<LSConstraint> concreteCstr = [LSFactory meetAtmost: cx and: cy atmost: [cstr atmost]];
      [_engine addConstraint: concreteCstr];
      [_allCstrs addObject:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   if (_gamma[getId(v)] == NULL) {
      id<LSIntVar> theVar = [self concreteVar:[v var]];
      id<LSFunction> fun = [LSFactory varRef:_engine var:theVar];
      id<LSConstraint> concreteCstr = [LSFactory minimize:_engine var:fun];
      [_engine addConstraint:concreteCstr];
      _objective = concreteCstr;
      _gamma[getId(v)] = concreteCstr;
   }
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of maximizeVar not yet implemented"];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   if (_gamma[getId(v)] == NULL) {
      id<LSFunction> fun = [ExprToLSFun convert:[v expr] forEngine:_engine concretizeWith:self];
      id<LSConstraint> concreteCstr = [LSFactory minimize:_engine var:fun];
      [_engine addConstraint:concreteCstr];
      _objective = concreteCstr;
      _gamma[getId(v)] = concreteCstr;
   }
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
-(void) visitIntegerI: (id<ORInteger>) e
{}
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
-(void) visitExprSquareI:(id<ORExpr>)e
{}
-(void) visitExprNegateI:(id<ORExpr>) e
{}
-(void) visitExprCstSubI: (id<ORExpr>) e
{}
-(void) visitExprCstFloatSubI:(id<ORExpr>)e
{}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{}
-(void) visitExprConjunctI: (id<ORExpr>) e
{}
-(void) visitExprImplyI: (id<ORExpr>) e
{}
-(void) visitExprAggOrI: (id<ORExpr>) e
{}
-(void) visitExprAggAndI: (id<ORExpr>) e
{}
-(void) visitExprAggMinI: (id<ORExpr>) e
{}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{}
-(void) visitExprVarSubI: (id<ORExpr>) e
{}
@end

@implementation ExprToLSFun {
   id<LSEngine> _engine;
   id<LSFunction>   _rv;
   ORInt            _rc;
   ORLSConcretizer* _cc;
}
-(id)init:(id<LSEngine>)e concretizeWith:(ORLSConcretizer*)cc
{
   self = [super init];
   _engine = e;
   _rv     = nil;
   _rc     = 1;
   _cc     = cc;
   return self;
}
-(id<LSFunction>)doIt:(id<ORExpr>)e
{
   _rv = nil;
   _rc = 1;
   [e visit:self];
   return _rv;
}
+(id<LSFunction>)convert:(id<ORExpr>)expr forEngine:(id<LSEngine>)e concretizeWith:(ORLSConcretizer *)cc
{
   ExprToLSFun* visitor = [[ExprToLSFun alloc] init:e concretizeWith:cc];
   [expr visit:visitor];
   id<LSFunction> rv = visitor->_rv;
   [visitor release];
   return rv;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   _rv = [LSFactory constant:_engine constant:[e intValue]];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{}
-(void) visitFloatI: (id<ORFloatNumber>) e
{}
-(void) visitExprPlusI: (id<ORExpr>) e
{
   assert(NO);
}
-(void) visitExprMinusI: (id<ORExpr>) e
{
   assert(NO);
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   if ([[e left] isConstant] && [[e right] isConstant]) {
      _rv = [LSFactory constant:_engine constant:[e min]];
      [_engine addFunction:_rv];
      _rc = 1;
   } else if ([[e left] isConstant]) {
      _rv = [self doIt:[e right]];
      _rc = [[e left] min];
   } else if ([[e right] isConstant]) {
      _rv = [self doIt:[e left]];
      _rc = [[e right] min];
   } else {
      id<LSFunction> lf = [self doIt:[e left]];
      id<LSFunction> rf = [self doIt:[e right]];
      _rv = [LSFactory funMul:lf by:rf];
      _rc = 1;
   }
}
-(void) visitExprDivI: (id<ORExpr>) e
{
   assert(NO);
}
-(void) visitExprModI: (id<ORExpr>) e
{
   assert(NO);
}
-(void) visitExprMinI: (id<ORExpr>) e
{
   assert(NO);
}
-(void) visitExprMaxI: (id<ORExpr>) e
{
   assert(NO);
}
-(void) visitExprEqualI: (ORExprEqualI*) e
{
   if ([[e left] isConstant] && [[e right] isConstant]) {
      _rv = [LSFactory constant:_engine constant:[e min]];
      [_engine addFunction:_rv];
   } else if ([[e left] isConstant] && [[e right] isVariable]) {
      id<ORVar> theVar = (id)[e right];
      id<LSIntVar> theRealVar = [_cc concreteVar:theVar];
      id<LSIntVar> eqLitView = [LSFactory intVarView:_engine var:theRealVar eq:[[e left] min]];
      _rv = [LSFactory varRef:_engine var:eqLitView];
      [_engine addFunction:_rv];
   } else if ([[e right] isConstant] && [[e left] isVariable]) {
      id<ORVar> theVar = (id)[e left];
      id<LSIntVar> theRealVar = [_cc concreteVar:theVar];
      id<LSIntVar> eqLitView = [LSFactory intVarView:_engine var:theRealVar eq:[[e right] min]];
      _rv = [LSFactory varRef:_engine var:eqLitView];
      [_engine addFunction:_rv];
   } else {
      assert(NO);
   }
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
}
-(ORInt)count:(Class)c in:(ORExprI*)root
{
   ORInt nb = 0;
   while ([root isKindOfClass:c]) {
      nb += 1;
      root = [(ORExprBinaryI*)root left];
   }
   return nb;
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   id<ORExpr> root = [e expr];
   ORInt nb = [self count:[ORExprPlusI class] in:root];
   id<ORIdArray> terms  = [ORFactory idArray:_engine range:RANGE(_engine,0,nb-1)];
   id<ORIntArray> coefs = [ORFactory intArray:_engine range:RANGE(_engine,0,nb-1) value:1];
   ORInt i = 0;
   while ([root isKindOfClass:[ORExprPlusI class]]) {
      ORExprPlusI* cr   = (ORExprPlusI*)root;
      id<ORExpr> term = [cr right];
      [term visit:self];
      terms[i] = _rv;
      [coefs set:_rc at:i];
      i += 1;
      root = [cr left];
   }
   assert([root conformsToProtocol:@protocol(ORInteger)]);
   id<LSFunction> fun = [LSFactory sum:_engine terms:terms coefs:coefs];
   [_engine addFunction:fun];
   _rv = fun;
}
-(void) visitExprProdI: (id<ORExpr>) e
{}
-(void) visitExprAggMinI: (id<ORExpr>) e
{}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{}
-(void) visitExprAbsI:(id<ORExpr>) e
{}
-(void) visitExprSquareI:(id<ORExpr>)e
{}
-(void) visitExprNegateI:(id<ORExpr>)e
{}
-(void) visitExprCstSubI: (id<ORExpr>) e
{}
-(void) visitExprCstFloatSubI:(id<ORExpr>)e
{}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{}
-(void) visitExprConjunctI: (id<ORExpr>) e
{}
-(void) visitExprImplyI: (id<ORExpr>) e
{}
-(void) visitExprAggOrI: (ORExprAggOrI*) e
{
   id<ORExpr> root = [e expr];
   ORInt nb = [self count:[ORDisjunctI class] in:root];
   id<ORIdArray> terms  = [ORFactory idArray:_engine range:RANGE(_engine,0,nb-1)];
   ORInt i = 0;
   while ([root isKindOfClass:[ORDisjunctI class]]) {
      ORDisjunctI* cr   = (ORDisjunctI*)root;
      id<ORExpr> term = [cr right];
      [term visit:self];
      terms[i] = _rv;
      i += 1;
      root = [cr left];
   }
   id<LSFunction> fun = [LSFactory disjunction:_engine terms:terms];
   [_engine addFunction:fun];
   _rv = fun;
}
-(void) visitExprAggAndI: (ORExprAggAndI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{}
@end