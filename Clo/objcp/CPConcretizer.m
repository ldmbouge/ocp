/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORUtilities/ORUtilities.h"
#import <ORFoundation/ORFoundation.h>
#import "CPIntVarI.h"
#import "CPConcretizer.h"


@implementation CPFactory (Expressions)
+(id<ORExpr>) exprPlus: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprPlusI alloc] initORExprPlusI: left and: right];
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprSub: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprMinusI alloc] initORExprMinusI: left and: right]; 
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprMul: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprMulI alloc] initORExprMulI: left and: right]; 
   [cp trackObject: o];
   return o;
}
+(id<ORRelation>) exprEq: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprEqualI alloc] initORExprEqualI: left and: right]; 
   [cp trackObject: o];
   return o;
}
+(id<ORRelation>) exprNeq: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprNotEqualI alloc] initORExprNotEqualI: left and: right];
   [cp trackObject: o];
   return o;
}
+(id<ORRelation>) exprLeq: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: left and: right];
   [cp trackObject: o];
   return o;
}
+(id<ORRelation>) exprGeq: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: right and: left];
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprAnd: (id<CPSolver>) cp  left: (id<ORRelation>) left right: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORConjunctI alloc] initORConjunctI:left and:right];
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprOr: (id<CPSolver>) cp  left: (id<ORRelation>) left right: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORDisjunctI alloc] initORDisjunctI:left or:right];
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprImply: (id<CPSolver>) cp  left: (id<ORRelation>) left right: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORImplyI alloc] initORImplyI:left imply:right];
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprAbs: (id<CPSolver>) cp  expr: (id<ORExpr>) op
{
   id<ORExpr> o = [[ORExprAbsI alloc] initORExprAbsI:op];
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprSum: (id<CPSolver>) cp expr: (id<ORExpr>) op;
{
   id<ORExpr> o = [[ORExprSumI alloc] initORExprSumI:op];
   [cp trackObject: o];
   return o;
}
+(id<ORRelation>) exprAggOr: (id<CPSolver>) cp expr: (id<ORExpr>) op;
{
   id<ORRelation> o = [[ORExprAggOrI alloc] initORExprAggOrI:op];
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprElt: (id<CPSolver>) cp intVarArray: (id<ORIntVarArray>) a index: (id<ORExpr>) index
{
   id<ORExpr> o = [[ORExprVarSubI alloc] initORExprVarSubI: a elt: index];
   [cp trackObject: o];
   return o;
}
+(id<ORExpr>) exprElt: (id<CPSolver>) cp intArray: (id<ORIntArray>) a index: (id<ORExpr>) index
{
   id<ORExpr> o = [[ORExprCstSubI alloc] initORExprCstSubI: a index: index];
   [cp trackObject: o];
   return o;
}
@end


@implementation ORExprConcretizer
{
   id<CPSolver> _cp;
   CPConcretizerI* _concretizer;
   id<ORExpr> _result;
}
-(ORExprConcretizer*) initORExprConcretizer: (id<CPSolver>) cp concretizer: (CPConcretizerI*) concretizer
{
   self = [super init];
   _cp = cp;
   _concretizer = concretizer;
   return self;
}
-(id<ORExpr>) result
{
   return _result;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   _result = e;
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   [[e left] visit: self];
   id<ORExpr> leftc = _result;
   [[e right] visit: self];
   id<ORExpr> rightc = _result;
   _result = [CPFactory exprPlus: _cp left: leftc right: rightc];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   [[e left] visit: self];
   id<ORExpr> leftc = _result;
   [[e right] visit: self];
   id<ORExpr> rightc = _result;
   _result = [CPFactory exprSub: _cp left: leftc right: rightc];
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   [[e left] visit: self];
   id<ORExpr> leftc = _result;
   [[e right] visit: self];
   id<ORExpr> rightc = _result;
   _result = [CPFactory exprMul: _cp left: leftc right: rightc];
}
-(void) visitExprEqualI: (ORExprEqualI*) e
{
   [[e left] visit: self];
   id<ORExpr> leftc = _result;
   [[e right] visit: self];
   id<ORExpr> rightc = _result;
   _result = [CPFactory exprEq: _cp left: leftc right: rightc];
}
-(void) visitExprNEqualI: (ORExprNotEqualI*) e
{
   [[e left] visit: self];
   id<ORExpr> leftc = _result;
   [[e right] visit: self];
   id<ORExpr> rightc = _result;
   _result = [CPFactory exprNeq: _cp left: leftc right: rightc];
}
-(void) visitExprLEqualI: (ORExprLEqualI*) e
{
   [[e left] visit: self];
   id<ORExpr> leftc = _result;
   [[e right] visit: self];
   id<ORExpr> rightc = _result;
   _result = [CPFactory exprLeq: _cp left: leftc right: rightc];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit: self];
   id<ORExpr> ec = _result;
   _result = [CPFactory exprSum: _cp expr: ec];
}
-(void) visitExprAbsI: (ORExprAbsI*) e
{
   [[e operand] visit: self];
   id<ORExpr> ec = _result;
   _result = [CPFactory exprAbs: _cp expr: ec];
}
-(void) visitExprCstSubI: (ORExprCstSubI*) e
{
   ORExprI* index = [e index];
   [index visit: self];
   id<ORExpr> indexc = _result;
   _result = [CPFactory exprElt: _cp intArray: [e array] index: indexc];
}
-(void) visitExprDisjunctI: (ORDisjunctI*) e
{
   [[e left] visit: self];
   id<ORRelation> leftc = (id<ORRelation>) _result;
   [[e right] visit: self];
   id<ORRelation> rightc = (id<ORRelation>) _result;
   _result = [CPFactory exprOr: _cp left: leftc right: rightc];
}
-(void) visitExprConjunctI: (ORConjunctI*) e;
{
   [[e left] visit: self];
   id<ORRelation> leftc = (id<ORRelation>) _result;
   [[e right] visit: self];
   id<ORRelation> rightc = (id<ORRelation>) _result;
   _result = [CPFactory exprAnd: _cp left: leftc right: rightc];
}
-(void) visitExprImplyI: (ORImplyI*) e
{
   [[e left] visit: self];
   id<ORRelation> leftc = (id<ORRelation>) _result;
   [[e right] visit: self];
   id<ORRelation> rightc = (id<ORRelation>) _result;
   _result = [CPFactory exprImply: _cp left: leftc right: rightc];
}
-(void) visitExprAggOrI: (ORExprAggOrI*) e
{
   [[e expr] visit: self];
   id<ORExpr> ec = _result;
   _result = [CPFactory exprAggOr: _cp expr: ec];
}
-(void) visitIntVarI: (id<ORIntVar>) var
{
   [var concretize:_concretizer];
   _result = [var dereference];
}
-(void) visitExprVarSubI: (ORExprVarSubI*) e
{
   [_concretizer idArray: [e array]];
   ORExprI* index = [e index];
   [index visit: self];
   id<ORExpr> indexc = _result;
   _result = [CPFactory exprElt: _cp intVarArray: [e array] index: indexc];
}
@end


@implementation CPConcretizerI
{
   id<CPSolver> _solver;
}
-(CPConcretizerI*) initCPConcretizerI: (id<CPSolver>) solver
{
   self = [super init];
   _solver = solver;
   return self;
}
-(id<ORIntVar>) intVar: (ORIntVarI*) v
{
   return [CPFactory intVar: _solver domain: [v domain]];
}
-(id<ORFloatVar>) floatVar: (ORFloatVarI*) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for floatVar"];
   return nil;
}
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v
{
   id<ORIntVar> mBase = [v base];
   ORInt a = [v scale];
   ORInt b = [v shift];
   return [CPFactory intVar:[mBase dereference] scale:a shift:b];
}
-(id<ORConstraint>) alldifferent: (ORAlldifferentI*) cstr
{
   id<ORIntVarArray> dx = [ORFactory intVarArrayDereference: _solver array: [cstr array]];
   id<ORConstraint> ncstr = [CPFactory alldifferent: _solver over: dx];
   [_solver add: ncstr];
   return ncstr;
}
-(id<ORConstraint>) cardinality: (ORCardinalityI*) cstr
{
   id<ORIntVarArray> dx = [ORFactory intVarArrayDereference: _solver array: [cstr array]];
   id<ORConstraint> ncstr = [CPFactory cardinality: dx low: [cstr low] up: [cstr up] consistency: DomainConsistency];
   [_solver add: ncstr];
   return ncstr;
}
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr
{
   id<ORIntVarArray> ditem = [ORFactory intVarArrayDereference: _solver array: [cstr item]];
   id<ORIntVarArray> dbinSize = [ORFactory intVarArrayDereference: _solver array: [cstr binSize]];
   id<ORConstraint> ncstr = [CPFactory packing: ditem itemSize: [cstr itemSize] load: dbinSize];
   [_solver add: ncstr];
   return ncstr;
}
-(id<ORConstraint>) algebraicConstraint: (ORAlgebraicConstraintI*) cstr
{
   ORExprConcretizer* ec = [[ORExprConcretizer alloc] initORExprConcretizer: _solver concretizer: self];
   [((ORExprI*) [cstr expr]) visit: ec];
   id<ORConstraint> c = [CPFactory relation2Constraint:_solver expr: [ec result]];
   [_solver add: c];
   [ec release];
   return c;
}
-(id<ORConstraint>) tableConstraint: (ORTableConstraintI*) cstr
{
   id<ORIntVarArray> x = [ORFactory intVarArrayDereference: _solver array: [cstr array]];
   id<ORConstraint> c = [CPFactory table: [cstr table] on: x];
   [_solver add: c];
   return c;
}
-(id<ORIdArray>) idArray: (id<ORIdArray>) a
{
   id<ORIntRange> R = [a range];
   id<ORIdArray> impl = [ORFactory idArray: _solver range: R];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++) {
      [a[i] concretize: self];
      impl[i] = [a[i] dereference];
   }
   return impl;
}
-(id<ORObjectiveFunction>) minimize: (id<ORObjectiveFunction>) v
{
   id<ORObjective> rv = [_solver minimize: [[v var] dereference]];
   return rv;
}
-(id<ORObjectiveFunction>) maximize: (id<ORObjectiveFunction>) v
{
   id<ORObjective> rv = [_solver maximize: [[v var] dereference]];
   return rv;
}
@end
