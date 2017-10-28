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
    if (_eqto) {
        [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
        [_terms addTerm:_eqto by:1];
        _eqto = nil;
    } else
        [_terms addTerm:e by:1];
}

-(void) visitFloatVar: (id<ORFloatVar>) e
{
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
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
    ORFloatLinear* linLeft  = [ORNormalizer floatLinearFrom:[e left] model:_model];
    [ORNormalizer addToFloatLinear:linLeft from:[e right] model:_model];
    _terms = linLeft;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
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
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
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
-(void) visitExprLEqualI:(ORExprLEqualI*)e
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
-(void) visitExprGEqualI:(ORExprLEqualI*)e
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
-(void) visitExprLThenI:(ORExprLEqualI*)e
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

-(void) visitExprGThenI:(ORExprLEqualI*)e
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
-(void) visitExprNegateI:(ORExprNegateI*) e
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
-(void) visitExprMinusI:(ORExprPlusI*) e
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
}-(id<ORFloatVar>)result
{
    return _rv;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
    if (e.left.isConstant) {
        id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
        [_model addConstraint:[ORFactory floatEqualc:_model var:rV eqc:e.left.fmin]];
        [linRight release];
    } else if (e.right.isConstant) {
        id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:[e left] model:_model];
        id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft  for:_model];
        [_model addConstraint:[ORFactory floatEqualc:_model var:lV eqc:e.right.fmin]];
        [linLeft release];
    } else {
        id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:[e left] model:_model];
        id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft  for:_model];
        id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
        if (_rv==nil) {
            _rv = [ORFactory floatVar:_model];
        }
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,2)];
        id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model,0,2) with:^ORFloat(ORInt i) {
            return 1;
        }];
        vars[0] = _rv;
        vars[1] = lV;
        vars[2] = rV;
        [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs eq:0.0f]];
        [linLeft release];
        [linRight release];
    }
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
    if ([[e left] isConstant] && [[e right] isVariable]) {
        id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
        [_model addConstraint:[ORFactory floatNEqualc:_model var:rV neqc:e.left.fmin]];
        [linRight release];
    } else if ([[e right] isConstant] && [[e left] isVariable]) {
        id<ORFloatLinear> linLeft = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft for:_model];
        [_model addConstraint:[ORFactory floatNEqualc:_model var:lV neqc:e.right.fmin]];
        [linLeft release];
    } else {
        id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:[e left] model:_model];
        id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft  for:_model];
        id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
        if (_rv==nil)
            _rv = [ORFactory floatVar:_model];
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,2)];
        id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model,0,2) with:^ORFloat(ORInt i) {
            return 1.0f;
        }];
        vars[0] = _rv;
        vars[1] = lV;
        vars[2] = rV;
        [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs neq:0.0f]];
        [linLeft release];
        [linRight release];
    }
}
-(void) visitExprLThenI:(ORExprLThenI*)e
{
    if ([[e left] isConstant]) {
        id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,1)];
        id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model, 0, 1) with:^ORFloat(ORInt i) {
            return 1.0f;
        }];
        vars[0] = rV;
        [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:e.left.fmin]];
        [linRight release];
    } else if ([[e right] isConstant]) {
        id<ORFloatLinear> linLeft = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft for:_model];
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,1)];
        id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model, 0, 1) with:^ORFloat(ORInt i) {
            return 1.0f;
        }];
        vars[0] = lV;
        [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:e.left.fmin]];
        [linLeft release];
    } else {
        id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:[e left] model:_model];
        id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft  for:_model];
        id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
        if (_rv==nil)
            _rv = [ORFactory floatVar:_model];
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,2)];
        id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model,0,2) with:^ORFloat(ORInt i) {
            return 1.0f;
        }];
        vars[0] = _rv;
        vars[1] = lV;
        vars[2] = rV;
        [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:0.0f]];
        [linLeft release];
        [linRight release];
    }
}
-(void) visitExprGThenI:(ORExprGThenI*)e
{
    if ([[e left] isConstant]) {
        id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,1)];
        id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model, 0, 1) with:^ORFloat(ORInt i) {
            return 1.0f;
        }];
        vars[0] = rV;
        [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:e.left.fmin]];
        [linRight release];
    } else if ([[e right] isConstant]) {
        id<ORFloatLinear> linLeft = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft for:_model];
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,1)];
        id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model, 0, 1) with:^ORFloat(ORInt i) {
            return 1.0f;
        }];
        vars[0] = lV;
        [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:e.left.fmin]];
        [linLeft release];
    } else {
        id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:[e left] model:_model];
        id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
        id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft  for:_model];
        id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
        if (_rv==nil)
            _rv = [ORFactory floatVar:_model];
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,2)];
        id<ORFloatArray> coefs = [ORFactory floatArray:_model range:RANGE(_model,0,2) with:^ORFloat(ORInt i) {
            return 1.0f;
        }];
        vars[0] = _rv;
        vars[1] = lV;
        vars[2] = rV;
        [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:0.0f]];
        [linLeft release];
        [linRight release];
    }
}
-(void) visitExprGEqualI:(ORExprGEqualI*)e
{
    assert(NO);
}
-(void) visitExprLEqualI:(ORExprGEqualI*)e
{
    assert(NO);
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
    assert(NO); //should go in bool path 
}

-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
    assert(NO);
   /* id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:[e left] model:_model];
    id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
    if ([linLeft isZero] && [linRight isZero]) {
        assert(0);
    }else{
       id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft  for:_model];
       id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
       id<ORIntVar> r = [ORFactory boolVar:_model];
       [_model addConstraint:[ORFactory model:_model boolean:lV lor:rV equal:r]];
    }
    [linLeft release];
    [linRight release];*/
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
    assert(NO);
    id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:[e left] model:_model];
    id<ORFloatLinear> linRight = [ORNormalizer floatLinearFrom:[e right] model:_model];
    id<ORFloatVar> lV = [ORNormalizer floatVarIn:linLeft  for:_model];
    id<ORFloatVar> rV = [ORNormalizer floatVarIn:linRight for:_model];
    if ([[lV domain] low] >= 1) {
        if (_rv)
            [_model addConstraint:[ORFactory equal:_model var:_rv to:rV plus:0]];
        else
            _rv = rV;
    } else if ([[rV domain] low] >= 1) {
        if (_rv)
            [_model addConstraint:[ORFactory equal:_model var:_rv to:lV plus:0]];
        else
            _rv = lV;
    } else {
        //id<ORIntVar> r = [ORFactory boolVar:_model];
        //[_model addConstraint:[ORFactory model:_model boolean:lV land:rV equal:r]];
    }
    [linLeft release];
    [linRight release];
}

@end
