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
-(void) visitFloatVar:(id<ORRealVar>) e
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
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Float Linearization supported"];
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory floatEqualc:_model var:_eqto to:[e value]]];
      [_terms addIndependent:[e value]];
      _eqto = nil;
   } else
      [_terms addIndependent:[e value]];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   [_terms addIndependent:[e initialValue]];
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   [_terms addIndependent:[e initialValue]];
}
-(void) visitFloatI: (id<ORDoubleNumber>) e
{
   [_terms addIndependent:[e floatValue]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   if (_eqto) {
      id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
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
      id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
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
      id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      BOOL cv = [[e left] isConstant] && [[e right] isVariable];
      BOOL vc = [[e left] isVariable] && [[e right] isConstant];
      if (cv || vc) {
         ORDouble coef = cv ? [[e left] floatValue] : [[e right] floatValue];
         id       x = cv ? [e right] : [e left];
         [_terms addTerm: x by: coef];
      } else if ([[e left] isConstant]) {
         id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:[e right]];
         [_terms addTerm:alpha by:[[e left] min]];
      } else if ([[e right] isConstant]) {
         id<ORRealLinear> left = [ORNormalizer floatLinearFrom:[e left] model:_model];
         [left scaleBy:[[e right] min]];
         [_terms addLinear:left];
      } else {
         id<ORRealVar> alpha =  [ORNormalizer floatVarIn:_model expr:e];
         [_terms addTerm:alpha by:1];
      }
   }
}
-(void) visitExprDivI: (ORExprDivI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Float Linearization supported for div"];
}
-(void) visitExprModI: (ORExprModI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Float Linearization supported for mod"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprSquareI:(ORExprSquareI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNegateI:(ORExprNegateI*) e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprCstFloatSubI: (ORExprCstFloatSubI*) e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}

-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   id<ORRealVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
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
-(void) visitFloatVar: (id<ORRealVar>) e
{
   if (_rv)
      [_model addConstraint:[ORFactory equal:_model var:_rv to:e plus:0]];
   else
      _rv = e;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (!_rv)
      _rv = [ORFactory floatVar:_model low:[e value] up:[e value]];
   [_model addConstraint:[ORFactory floatEqualc:_model var:_rv to:[e value]]];
}
-(void) visitFloatI: (id<ORDoubleNumber>) e
{
   if (!_rv)
      _rv = [ORFactory floatVar:_model low:[e floatValue] up:[e floatValue]];
   [_model addConstraint:[ORFactory floatEqualc:_model var:_rv to:[e floatValue]]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   id<ORRealLinear> terms = [ORNormalizer floatLinearFrom:e model:_model];
   if (_rv==nil)
      _rv = [ORFactory floatVar:_model low:[terms fmin] up:[terms fmax]];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model];
   [terms release];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   id<ORRealLinear> terms = [ORNormalizer floatLinearFrom:e model:_model];
   if (_rv==nil)
      _rv = [ORFactory floatVar:_model low:[terms fmin] up:[terms fmax]];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model];
   [terms release];
}
-(void) visitExprSquareI:(ORExprSquareI *)e
{
   id<ORRealLinear> lT = [ORNormalizer floatLinearFrom:[e operand] model:_model];
   id<ORRealVar> oV = [ORNormalizer floatVarIn:lT for:_model];
   ORDouble lb = [lT fmin];
   ORDouble ub = [lT fmax];
   ORDouble nlb = lb < 0 ? 0 : lb*lb;
   ORDouble nub = max(lb*lb, ub*ub);
   if (_rv == nil)
      _rv = [ORFactory floatVar:_model low:nlb up:nub];
   [_model addConstraint:[ORFactory floatSquare:_model var:oV equal:_rv]];
   [lT release];
}

-(void) visitExprMulI: (ORExprMulI*) e
{
   id<ORRealLinear> lT = [ORNormalizer floatLinearFrom:[e left] model:_model];
   id<ORRealLinear> rT = [ORNormalizer floatLinearFrom:[e right] model:_model];
   if (lT.isOne) {
      id<ORRealVar> rV = [ORNormalizer floatVarIn:rT for:_model];
      if (_rv == nil)
         _rv = rV;
      else
         [_model addConstraint:[ORFactory floatEqual:_model var:_rv to:rV]];
   } else if (rT.isOne) {
      id<ORRealVar> lV = [ORNormalizer floatVarIn:lT for:_model];
      if (_rv == nil)
         _rv  = lV;
      else
         [_model addConstraint:[ORFactory floatEqual:_model var:_rv to:lV]];
   } else {
      id<ORRealVar> lV = [ORNormalizer floatVarIn:lT for:_model];
      id<ORRealVar> rV = [ORNormalizer floatVarIn:rT for:_model];
      ORDouble llb = [[lV domain] low];
      ORDouble lub = [[lV domain] up];
      ORDouble rlb = [[rV domain] low];
      ORDouble rub = [[rV domain] up];
      ORDouble a = minDouble(llb * rlb,llb * rub);
      ORDouble b = minDouble(lub * rlb,lub * rub);
      ORDouble lb = minDouble(a,b);
      ORDouble c = maxDouble(llb * rlb,llb * rub);
      ORDouble d = maxDouble(lub * rlb,lub * rub);
      ORDouble ub = maxDouble(c,d);
      if (_rv==nil)
         _rv = [ORFactory floatVar:_model low:lb up:ub];
      [_model addConstraint: [ORFactory floatMult:_model var:lV by:rV equal:_rv]];
   }
   [lT release];
   [rT release];
}


-(void) visitExprCstFloatSubI:(ORExprCstFloatSubI*)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e index] model:_model];
   id<ORIntVar> oV = [ORNormalizer intVarIn:lT for:_model];
   id<ORDoubleArray> a = [e array];
   ORDouble lb = [a min];
   ORDouble ub = [a max];
   if (_rv == nil)
      _rv = [ORFactory floatVar:_model low:lb up:ub];
   [_model addConstraint:[ORFactory floatElement:_model var:oV idxCstArray:a equal:_rv]];
   [lT release];
}

-(void) reifyEQc:(ORExprI*)theOther constant:(ORDouble)c
{
   id<ORIntLinear> linOther  = [ORNormalizer intLinearFrom:theOther model:_model];
   id<ORIntVar> theVar = [ORNormalizer intVarIn:linOther for:_model];
   [linOther release];
#if OLDREIFY==1
   if (_rv==nil) {
      _rv = [ORFactory intVar:_model domain: RANGE(_model,0,1)];
   }
   [_model addConstraint: [ORFactory reify:_model boolean:_rv with:theVar eqi:c]];
#else
   if (_rv != nil) {
      [_model addConstraint: [ORFactory reify:_model boolean:_rv with:theVar eqi:c]];
   } else {
      _rv = [ORFactory reifyView:_model var:theVar eqi:c];
   }
#endif
}
-(void) reifyNEQc:(ORExprI*)theOther constant:(ORDouble)c
{
   id<ORIntLinear> linOther  = [ORNormalizer intLinearFrom:theOther model:_model];
   id<ORIntVar> theVar = [ORNormalizer intVarIn:linOther for:_model];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model addConstraint: [ORFactory reify:_model boolean:_rv with:theVar neqi:c]];
   [linOther release];
}
-(void) reifyLEQc:(ORExprI*)theOther constant:(ORDouble)c
{
   id<ORRealLinear> linOther  = [ORNormalizer floatLinearFrom:theOther model:_model];
   id<ORRealVar> theVar = [ORNormalizer floatVarIn:linOther for:_model];
   if ([[theVar domain] up] <= c) {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model value:1];
      else
         [_model addConstraint:[ORFactory equalc:_model var:_rv to:1]];
   } else {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
      [_model addConstraint: [ORFactory reify:_model boolean:_rv withReal:theVar leqi:c]];
   }
   [linOther release];
}
-(void) reifyGEQc:(ORExprI*)theOther constant:(ORDouble)c
{
   id<ORRealLinear> linOther  = [ORNormalizer floatLinearFrom:theOther model:_model];
   id<ORRealVar> theVar = [ORNormalizer floatVarIn:linOther for:_model];
   if ([[theVar domain] low] >= c) {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain:RANGE(_model,1,1)];
      else
         [_model addConstraint:[ORFactory equalc:_model var:_rv to:1]];
   } else {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
      [_model addConstraint: [ORFactory reify:_model boolean:_rv withReal:theVar geqi:c]];
   }
   [linOther release];
}
-(void) reifyLEQ:(ORExprI*)left right:(ORExprI*)right
{
   id<ORIntLinear> linLeft   = [ORNormalizer intLinearFrom:left model:_model];
   id<ORIntLinear> linRight  = [ORNormalizer intLinearFrom:right model:_model];
   id<ORIntVar> varLeft  = [ORNormalizer intVarIn:linLeft for:_model];
   id<ORIntVar> varRight = [ORNormalizer intVarIn:linRight for:_model];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model addConstraint: [ORFactory reify:_model boolean:_rv with:varLeft leq:varRight]];
   [linLeft release];
   [linRight release];
}

-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   if ([[e left] isConstant]) {
      [self reifyGEQc:[e right] constant:[[e left] floatValue]];
   } else if ([[e right] isConstant]) {
      [self reifyLEQc:[e left] constant:[[e right] floatValue]];
   } else
      [self reifyLEQ:[e left] right:[e right]];
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
