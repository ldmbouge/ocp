//
//  ORRationalDecompose.m
//  ORModeling
//
//  Created by Rémy Garcia on 09/07/2018.
//

#import "ORModeling.h"
#import "ORDecompose.h"
#import "ORRationalDecompose.h"
#import "ORRationalLinear.h"
#import "ORExprI.h"

@implementation ORRationalLinearizer
-(id)init:(id<ORRationalLinear>)t model:(id<ORAddToModel>)model equalTo:(id<ORRationalVar>)x
{
   self = [super init];
   _terms = t;
   _model = model;
   _eqto  = x;
   return self;
}
-(id)init:(id<ORRationalLinear>)t model:(id<ORAddToModel>)model
{
   self = [super init];
   _terms = t;
   _model = model;
   _eqto  = nil;
   return self;
}
-(void) visitRationalVar: (id<ORRationalVar>) e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
      [_terms addTerm:_eqto by:1];
      _eqto = nil;
   } else
      [_terms addTerm:e by:1];
}
/*-(void) visitAffineVar:(ORIntVarAffineI*)e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
      [_terms addTerm:_eqto by:1];
      _eqto = nil;
   } else
      [_terms addTerm:e by:1];
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
      [_terms addTerm:_eqto by:1];
      _eqto = nil;
   } else
      [_terms addTerm:e by:1];
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equalc:_model var:_eqto to:[e value]]];
      [_terms addIndependent:[e value]];
      _eqto = nil;
   } else
      [_terms addIndependent:[e value]];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   assert(NO);
   if (_eqto) {
      [_model addConstraint:[ORFactory equalc:_model var:_eqto to:[e initialValue]]];
      [_terms addIndependent:[e initialValue]];
      _eqto = nil;
   } else
      [_terms addIndependent:[e initialValue]];
}
-(void) visitMutableDouble: (id<ORMutableInteger>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer expression and encountering a MutableReal"];
}

-(void) visitDouble: (id<ORDoubleNumber>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer expression and encountering a DoubleNumber"];
}*/

-(void) visitExprPlusI: (ORExprPlusI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprUnaryMinusI: (ORExprUnaryMinusI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha =  [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha =  [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      BOOL cv = [[e left] isConstant] && [[e right] isVariable];
      BOOL vc = [[e left] isVariable] && [[e right] isConstant];
      if (cv || vc) {
         ORInt coef = cv ? [[e left] min] : [[e right] min];
         id       x = cv ? [e right] : [e left];
         [_terms addTerm:x by:coef];
      } else if ([[e left] isConstant]) {
         id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:[e right]];
         [_terms addTerm:alpha by:[[e left] min]];
      } else if ([[e right] isConstant]) {
         ORRationalLinear* left = [ORNormalizer rationalLinearFrom:[e left] model:_model];
         [left scaleBy:[[e right] min]];
         [_terms addLinear:left];
      } else {
         id<ORRationalVar> alpha =  [ORNormalizer rationalVarIn:_model expr:e];
         [_terms addTerm:alpha by:1];
      }
   }
}
-(void) visitExprDivI:(ORExprDivI *)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprModI: (ORExprModI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprMinI: (ORExprMinI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }}
-(void) visitExprAssignI:(ORExprAssignI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprSquareI:(ORExprSquareI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }}
-(void) visitExprNegateI:(ORExprNegateI*) e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }}
-(void) visitExprErrorOfI:(ORExprErrorOfI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }}
-(void) visitExprUlpOfI:(ORExprUlpOfI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprGEqualI:(ORExprGEqualI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprLThenI:(ORExprLThenI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprGThenI:(ORExprGThenI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
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
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprMatrixVarSubI:(ORExprMatrixVarSubI*)e
{
   if (_eqto) {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORRationalVar> alpha = [ORNormalizer rationalVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
@end

@implementation ORRationalSubst
-(id)initORRationalSubst:(id<ORAddToModel>) model
{
   self = [super init];
   _rv = nil;
   _model = model;
   return self;
}
-(id)initORRationalSubst:(id<ORAddToModel>) model by:(id<ORRationalVar>)x
{
   self = [super init];
   _rv = nil;
   _rv  = x;
   _model = model;
   return self;
}
-(void) visitRationalVar: (id<ORRationalVar>) e
{
   if (_rv)
      [_model addConstraint:[ORFactory equal:_model var:_rv to:e plus:0]];
   else
      _rv = (id)e;
}
-(void) visitExprPlusI:(ORExprPlusI*) e
{
   id<ORRationalLinear> lT = [ORNormalizer rationalLinearFrom:[e left] model:_model];
   id<ORRationalLinear> rT = [ORNormalizer rationalLinearFrom:[e right] model:_model];
   id<ORRationalVar> lV = [ORNormalizer rationalVarIn:lT for:_model];
   id<ORRationalVar> rV = [ORNormalizer rationalVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory rationalVar:_model];
   }
   id<ORVarArray> var = [ORFactory rationalVarArray:_model range:RANGE(_model,0,2)];
   var[0] = _rv;
   var[1] = lV;
   var[2] = rV;
   id<ORRationalArray> coefs = [ORFactory rationalArray:_model range:RANGE(_model, 0,2) with:^id<ORRational>(ORInt i) {
      id<ORRational> coef = [[[ORRational alloc] init] setOne];
      [_model trackMutable:coef];
      return coef;
   }];
   [_model addConstraint:[ORFactory rationalSum:_model array:var coef:coefs eq:[ORRational rationalWith_d:0]]];
   [lT release];
   [rT release];
}
-(void) visitExprUnaryMinusI:(ORExprUnaryMinusI*) e
{
   id<ORRationalLinear> rT = [ORNormalizer rationalLinearFrom:[e operand] model:_model];
   id<ORRationalVar> rV = [ORNormalizer rationalVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory rationalVar:_model];
   }
   [_model addConstraint:[ORFactory rationalUnaryMinus:_model var:_rv eqm: rV]];
   [rT release];
}
-(void) visitExprMinusI:(ORExprMinusI*) e
{
   id<ORRationalLinear> lT = [ORNormalizer rationalLinearFrom:[e left] model:_model];
   id<ORRationalLinear> rT = [ORNormalizer rationalLinearFrom:[e right] model:_model];
   id<ORRationalVar> lV = [ORNormalizer rationalVarIn:lT for:_model];
   id<ORRationalVar> rV = [ORNormalizer rationalVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory rationalVar:_model];
   }
   id<ORVarArray> var = [ORFactory rationalVarArray:_model range:RANGE(_model,0,2)];
   var[0] = _rv;
   var[1] = lV;
   var[2] = rV;
   id<ORRationalArray> coefs = [ORFactory rationalArray:_model range:RANGE(_model, 0,2)];
   id<ORRational> one = [[[ORRational alloc] init] setOne];
   id<ORRational> minusOne = [[[ORRational alloc] init] setMinusOne];
   id<ORRational> zero = [[[ORRational alloc] init] setZero];
   [coefs set:one at:0];
   [coefs set:one at:1];
   [coefs set:minusOne at:2];
   [_model addConstraint:[ORFactory rationalSum:_model array:var coef:coefs eq:zero]];
   [one release];
   [minusOne release];
   [zero release];
   [lT release];
   [rT release];
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   id<ORRationalLinear> lT = [ORNormalizer rationalLinearFrom:[e left] model:_model];
   id<ORRationalLinear> rT = [ORNormalizer rationalLinearFrom:[e right] model:_model];
   id<ORRationalVar> lV = [ORNormalizer rationalVarIn:lT for:_model];
   id<ORRationalVar> rV = [ORNormalizer rationalVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory rationalVar:_model];
   }
   [_model addConstraint: [ORFactory rationalMult:_model var:lV by:rV equal:_rv]];
   [lT release];
   [rT release];
}
-(void) visitExprDivI: (ORExprDivI*) e
{
   id<ORRationalLinear> lT = [ORNormalizer rationalLinearFrom:[e left] model:_model];
   id<ORRationalLinear> rT = [ORNormalizer rationalLinearFrom:[e right] model:_model];
   id<ORRationalVar> lV = [ORNormalizer rationalVarIn:lT for:_model];
   id<ORRationalVar> rV = [ORNormalizer rationalVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory rationalVar:_model];
   }
   [_model addConstraint: [ORFactory rationalDiv:_model var:lV by:rV equal:_rv]];
   [lT release];
   [rT release];
}
-(void) visitExprGEqualI:(ORExprGEqualI*)e
{
   assert(NO);
}
-(void) visitExprLEqualI:(ORExprGEqualI*)e
{
   assert(NO);
}
-(id<ORRationalVar>)result
{
   return _rv;
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   id<ORRationalLinear> rT = [ORNormalizer rationalLinearFrom:[e operand] model:_model];
   id<ORRationalVar> rV = [ORNormalizer rationalVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory rationalVar:_model];
   }
   [_model addConstraint:[ORFactory rationalAbs:_model var:_rv eq: rV]];
   [rT release];
}
@end
