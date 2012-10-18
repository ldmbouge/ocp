/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORProgram.h"
#import "CPConcretizer.h"
#import "ORCPConcretizer.h"
#import "objcp/CPFactory.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPSolver.h"
#import "objcp/CPSolver.h"
//#import "ORVarI.h"

@implementation ORCPConcretizer
{
   id<CPProgram> _solver;
}
-(ORCPConcretizer*) initORCPConcretizer: (id<CPProgram>) solver
{
   self = [super init];
   _solver = [solver retain];
   return self;
}
-(void) dealloc
{
   [_solver release];
   [super dealloc];
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
   // PVH: We need to use concrete variable in the library
   if ([v impl] == NULL) {
      id<CPIntVar> cv = [CPFactory intVar: _solver domain: [v domain]];
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
      ORInt a = [v scale];
      ORInt b = [v shift];
      id<CPIntVar> cv = [CPFactory intVar:[mBase dereference] scale:a shift:b];
      [v setImpl: cv];
   }
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   if ([v impl] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _solver range: R];
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
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   if ([cstr impl] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory alldifferent: _solver over: [ax impl]];
      [cstr setImpl: concreteCstr];
   }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   
}
-(void) visitMinimize: (id<ORObjectiveFunction>) v
{
   
}
-(void) visitMaximize: (id<ORObjectiveFunction>) v
{
   
}
-(void) visitEqualc: (id<OREqualc>)c
{
   
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   
}
-(void) visitEqual: (id<OREqual>)c
{
   
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   
}
-(void) visitEqual3: (id<OREqual3>)c
{
   
}
-(void) visitMult: (id<ORMult>)c
{
   
}
-(void) visitAbs: (id<ORAbs>)c
{
   
}
-(void) visitOr: (id<OROr>)c
{
   
}
-(void) visitAnd:( id<ORAnd>)c
{
   
}
-(void) visitImply: (id<ORImply>)c
{
   
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   
}
-(void) visitElementVar: (id<ORElementVar>)c
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

