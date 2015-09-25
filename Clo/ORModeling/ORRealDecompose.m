/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORModeling.h"
#import "ORDecompose.h"
#import "ORRealDecompose.h"
#import "ORRealLinear.h"
#import "ORExprI.h"

@implementation ORRealLinearizer
{
   id<ORRealLinear>   _terms;
   id<ORAddToModel>    _model;
   id<ORRealVar>       _eqto;
}
-(id) init: (id<ORRealLinear>) t model: (id<ORAddToModel>) model
{
   self = [super init];
   _terms = t;
   _model = model;
   return self;
}
-(id) init: (id<ORRealLinear>) t model: (id<ORAddToModel>) model equalTo:(id<ORRealVar>)x
{
   self = [super init];
   _terms = t;
   _model = model;
   _eqto  = x;
   return self;
}

-(void) visitIntVar: (id<ORIntVar>) e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
      [_terms addTerm:_eqto by:1];
      _eqto = nil;
   } else
      [_terms addTerm:e by:1];
}
-(void) visitRealVar:(id<ORRealVar>) e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
      [_terms addTerm:_eqto by:1];
      _eqto = nil;
   } else
      [_terms addTerm: e by: 1];
}
-(void) visitAffineVar:(id<ORIntVar>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Real Linearization supported"];
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory realEqualc:_model var:_eqto to:[e value]]];
      [_terms addIndependent:[e value]];
      _eqto = nil;
   } else
      [_terms addIndependent:[e value]];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   [_terms addIndependent:[e initialValue]];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
   [_terms addIndependent:[e initialValue]];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
   [_terms addIndependent:[e dblValue]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   if (_eqto) {
      id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      [[e left] visit:self];
      [[e right] visit:self];
   }
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   if (_eqto) {
      id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      [[e left] visit:self];
      id<ORRealLinear> old = _terms;
      _terms = [[ORRealLinearFlip alloc] initORRealLinearFlip: _terms];
      [[e right] visit:self];
      [_terms release];
      _terms = old;
   }
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   if (_eqto) {
      id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      BOOL cv = [[e left] isConstant] && [[e right] isVariable];
      BOOL vc = [[e left] isVariable] && [[e right] isConstant];
      if (cv || vc) {
         ORDouble coef = cv ? [[e left] dblValue] : [[e right] dblValue];
         id       x = cv ? [e right] : [e left];
         [_terms addTerm: x by: coef];
      } else if ([[e left] isConstant]) {
         id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:[e right]];
         [_terms addTerm:alpha by:[[e left] min]];
      } else if ([[e right] isConstant]) {
         id<ORRealLinear> left = [ORNormalizer realLinearFrom:[e left] model:_model];
         [left scaleBy:[[e right] min]];
         [_terms addLinear:left];
      } else {
         id<ORIntVar> alpha =  [ORNormalizer intVarIn:_model expr:e];
         [_terms addTerm:alpha by:1];
      }
   }
}
-(void) visitExprDivI: (ORExprDivI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Real Linearization supported for div"];
}
-(void) visitExprModI: (ORExprModI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Real Linearization supported for mod"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprSquareI:(ORExprSquareI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNegateI:(ORExprNegateI*) e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprCstDoubleSubI: (ORExprCstDoubleSubI*) e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}

-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   id<ORRealVar> alpha = [ORNormalizer realVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit: self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit: self];
}
-(void) visitExprAggOrI: (ORExprAggOrI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggAndI: (ORExprAggAndI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMinI: (ORExprAggMinI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMaxI: (ORExprAggMaxI*) e
{
   [[e expr] visit:self];
}
@end

@implementation ORRealSubst
-(id)initORSubst:(id<ORAddToModel>) model
{
   self = [super init];
   _rv = nil;
   _model = model;
   return self;
}
-(id)initORSubst:(id<ORAddToModel>) model by:(id<ORRealVar>)x
{
   self = [super init];
   _rv  = x;
   _model = model;
   return self;
}
-(id<ORRealVar>)result
{
   return _rv;
}
-(void) visitIntVar: (id<ORIntVar>) e
{
   if (_rv)
      [_model addConstraint:[ORFactory equal:_model var:_rv to:e plus:0]];
   else
      _rv = (id)e;
}
-(void) visitRealVar: (id<ORRealVar>) e
{
   if (_rv)
      [_model addConstraint:[ORFactory equal:_model var:_rv to:e plus:0]];
   else
      _rv = e;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (!_rv)
      _rv = [ORFactory realVar:_model low:[e value] up:[e value]];
   [_model addConstraint:[ORFactory realEqualc:_model var:_rv to:[e value]]];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
   if (!_rv)
      _rv = [ORFactory realVar:_model low:[e dblValue] up:[e dblValue]];
   [_model addConstraint:[ORFactory realEqualc:_model var:_rv to:[e dblValue]]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   id<ORRealLinear> terms = [ORNormalizer realLinearFrom:e model:_model];
   if (_rv==nil)
      _rv = [ORFactory realVar:_model low:[terms fmin] up:[terms fmax]];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model];
   [terms release];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   id<ORRealLinear> terms = [ORNormalizer realLinearFrom:e model:_model];
   if (_rv==nil)
      _rv = [ORFactory realVar:_model low:[terms fmin] up:[terms fmax]];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model];
   [terms release];
}
-(void) visitExprSquareI:(ORExprSquareI *)e
{
   id<ORRealLinear> lT = [ORNormalizer realLinearFrom:[e operand] model:_model];
   id<ORRealVar> oV = [ORNormalizer realVarIn:lT for:_model];
   ORDouble lb = [lT fmin];
   ORDouble ub = [lT fmax];
   ORDouble nlb = lb < 0 ? 0 : lb*lb;
   ORDouble nub = max(lb*lb, ub*ub);
   if (_rv == nil)
      _rv = [ORFactory realVar:_model low:nlb up:nub];
   [_model addConstraint:[ORFactory realSquare:_model var:oV equal:_rv]];
   [lT release];
}
-(void) visitExprCstDoubleSubI:(ORExprCstDoubleSubI*)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e index] model:_model];
   id<ORIntVar> oV = [ORNormalizer intVarIn:lT for:_model];
   id<ORDoubleArray> a = [e array];
   ORDouble lb = [a min];
   ORDouble ub = [a max];
   if (_rv == nil)
      _rv = [ORFactory realVar:_model low:lb up:ub];
   [_model addConstraint:[ORFactory realElement:_model var:oV idxCstArray:a equal:_rv]];
   [lT release];
}

-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggOrI: (ORExprAggOrI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggAndI: (ORExprAggAndI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMinI: (ORExprAggMinI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMaxI: (ORExprAggMaxI*) e
{
   [[e expr] visit:self];
}
@end
