/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORModeling.h"
#import "ORDecompose.h"
#import "ORFloatDecompose.h"
#import "ORFloatLinear.h"
#import "ORDoubleLinear.h"
#import "ORExprI.h"

@implementation ORFloatLinearizer
{
    id<ORFloatLinear>   _terms;
    id<ORAddToModel>    _model;
    id<ORFloatVar>       _eqto;
}
-(id) init: (id<ORFloatLinear>) t model: (id<ORAddToModel>) model
{
    self = [super init];
    _terms = t;
    _model = model;
    return self;
}
-(id) init: (id<ORFloatLinear>) t model: (id<ORAddToModel>) model equalTo:(id<ORFloatVar>)x
{
    self = [super init];
    _terms = t;
    _model = model;
    _eqto  = x;
    return self;
}
-(void) visitIntVar: (id<ORIntVar>) e
{
   [_model incrOccurences:e];
    if (_eqto) {
        [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
        [_terms addTerm:_eqto by:1];
        _eqto = nil;
    } else
        [_terms addTerm:e by:1];
}

-(void) visitFloatVar: (id<ORFloatVar>) e
{
   [_model incrOccurences:e];
    if (_eqto) {
        [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
        [_terms addTerm:_eqto by:1];
        _eqto = nil;
    } else
        [_terms addTerm:e by:1];
}
-(void) visitFloat: (id<ORFloatNumber>) e
{
    [_terms addIndependent:[e floatValue]];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
    [_terms addIndependent:[e doubleValue]];
}
-(void) visitExprAssignI:(ORExprAssignI*)e
{
   if (_eqto) {
      id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORFloatVar> alpha =  [ORNormalizer floatVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
    if (_eqto) {
        id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
        [_terms addTerm:alpha by:1];
        _eqto = nil;
    } else {
        id<ORFloatVar> alpha =  [ORNormalizer floatVarIn:_model expr:e];
        [_terms addTerm:alpha by:1];
    }
}
-(void) visitExprUnaryMinusI: (ORExprUnaryMinusI*) e
{
   if (_eqto) {
      id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORFloatVar> alpha =  [ORNormalizer floatVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
    if (_eqto) {
        id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
        [_terms addTerm:alpha by:1];
        _eqto = nil;
    } else {
        id<ORFloatVar> alpha =  [ORNormalizer floatVarIn:_model expr:e];
        [_terms addTerm:alpha by:1];
    }
}
-(void) visitExprMulI: (ORExprMulI*) e
{
    if (_eqto) {
        id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
        [_terms addTerm:alpha by:1];
        _eqto = nil;
    } else {
        id<ORFloatVar> alpha =  [ORNormalizer floatVarIn:_model expr:e];
        [_terms addTerm:alpha by:1];
    }
}
-(void) visitExprDivI:(ORExprDivI *)e
{
    if (_eqto) {
        id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
        [_terms addTerm:alpha by:1];
        _eqto = nil;
    } else {
        id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e];
        [_terms addTerm:alpha by:1];
    }
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   if (_eqto) {
      id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprSqrtI:(ORExprSqrtI*) e
{
   if (_eqto) {
      id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprToFloatI:(ORExprToFloatI*) e
{
   if (_eqto) {
      id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
@end

@implementation ORFloatSubst
-(id)initORFloatSubst:(id<ORAddToModel>) model
{
    self = [super init];
    _rv = nil;
    _model = model;
    return self;
}
-(id)initORFloatSubst:(id<ORAddToModel>) model by:(id<ORFloatVar>)x
{
    self = [super init];
    _rv = nil;
    _rv  = x;
    _model = model;
    return self;
}
-(void) visitFloatVar: (id<ORFloatVar>) e
{
   [_model incrOccurences:e];
    if (_rv)
        [_model addConstraint:[ORFactory equal:_model var:_rv to:e plus:0]];
    else
        _rv = (id)e;
}
-(void) visitExprPlusI:(ORExprPlusI*) e
{
    id<ORFloatLinear> lT = [ORNormalizer floatLinearFrom:[e left] model:_model];
    id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e right] model:_model];
    id<ORFloatVar> lV = [ORNormalizer floatVarIn:lT for:_model];
    id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
    if (_rv==nil){
        _rv = [ORFactory floatVar:_model];
    }
    id<ORVarArray> var = [ORFactory floatVarArray:_model range:RANGE(_model,0,2)];
    var[0] = _rv;
    var[1] = lV;
    var[2] = rV;
    id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model, 0,2) with:^ORFloat(ORInt i) {
        return 1;
    }];
    [_model addConstraint:[ORFactory floatSum:_model array:var coef:coefs eq:0.0f]];
    [lT release];
    [rT release];
}
-(void) visitExprUnaryMinusI:(ORExprUnaryMinusI*) e
{
   id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e operand] model:_model];
   id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory floatVar:_model];
   }
   [_model addConstraint:[ORFactory floatUnaryMinus:_model var:_rv eqm: rV]];
   [rT release];
}
-(void) visitExprMinusI:(ORExprMinusI*) e
{
    id<ORFloatLinear> lT = [ORNormalizer floatLinearFrom:[e left] model:_model];
    id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e right] model:_model];
    id<ORFloatVar> lV = [ORNormalizer floatVarIn:lT for:_model];
    id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
    if (_rv==nil){
        _rv = [ORFactory floatVar:_model];
    }
    id<ORVarArray> var = [ORFactory floatVarArray:_model range:RANGE(_model,0,2)];
    var[0] = _rv;
    var[1] = lV;
    var[2] = rV;
    id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model, 0,2)];
    [coefs set:1 at:0];
    [coefs set:1 at:1];
    [coefs set:-1 at:2];
    [_model addConstraint:[ORFactory floatSum:_model array:var coef:coefs eq:0.0f]];
    [lT release];
    [rT release];
}
-(void) visitExprMulI: (ORExprMulI*) e
{
    id<ORFloatLinear> lT = [ORNormalizer floatLinearFrom:[e left] model:_model];
    id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e right] model:_model];
    id<ORFloatVar> lV = [ORNormalizer floatVarIn:lT for:_model];
    id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
    if (_rv==nil){
        _rv = [ORFactory floatVar:_model];
    }
    [_model addConstraint: [ORFactory floatMult:_model var:lV by:rV equal:_rv]];
    [lT release];
    [rT release];
}
-(void) visitExprDivI: (ORExprDivI*) e
{
    id<ORFloatLinear> lT = [ORNormalizer floatLinearFrom:[e left] model:_model];
    id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e right] model:_model];
    id<ORFloatVar> lV = [ORNormalizer floatVarIn:lT for:_model];
    id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
    if (_rv==nil){
        _rv = [ORFactory floatVar:_model];
    }
    [_model addConstraint: [ORFactory floatDiv:_model var:lV by:rV equal:_rv]];
    [lT release];
    [rT release];
}
-(id<ORFloatVar>)result
{
    return _rv;
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e operand] model:_model];
   id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory floatVar:_model];
   }
   [_model addConstraint:[ORFactory floatAbs:_model var:_rv eq: rV]];
   [rT release];
}
-(void) visitExprSqrtI:(ORExprSqrtI*) e
{
   id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e operand] model:_model];
   id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory floatVar:_model];
   }
   [_model addConstraint:[ORFactory floatSqrt:_model var:_rv eq: rV]];
   [rT release];
}
-(void) visitExprToFloatI:(ORExprToFloatI*) e
{
   id<ORDoubleLinear> rT = [ORNormalizer doubleLinearFrom:[e operand] model:_model];
   id<ORDoubleVar> rV = [ORNormalizer doubleVarIn:rT for:_model];
   if (_rv==nil){
      _rv = [ORFactory floatVar:_model];
   }
   [_model addConstraint:[ORFactory floatCast:_model from:rV res:_rv]];
   [rT release];
}
@end
