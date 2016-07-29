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
        [[e left] visit:self];
        [[e right] visit:self];
    }
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
    if (_eqto) {
        id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
        [_terms addTerm:alpha by:1];
        _eqto = nil;
    } else {
        [[e left] visit:self];
        id<ORFloatLinear> old = _terms;
        _terms = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: _terms];
        [[e right] visit:self];
        [_terms release];
        _terms = old;
    }
}
-(void) visitExprMulI: (ORExprMulI*) e
{
    if (_eqto) {
        id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:e by:_eqto];
        [_terms addTerm:alpha by:1];
        _eqto = nil;
    } else {
        BOOL cv = [[e left] isConstant] && [[e right] isVariable];
        BOOL vc = [[e left] isVariable] && [[e right] isConstant];
        if (cv || vc) {
            ORFloat coef = cv ? [[e left] floatValue] : [[e right] floatValue];
            id       x = cv ? [e right] : [e left];
            [_terms addTerm:x by:coef];
        } else if ([[e left] isConstant]) {
            id<ORFloatVar> alpha = [ORNormalizer floatVarIn:_model expr:[e right]];
            [_terms addTerm:alpha by:[[e left] min]];
        } else if ([[e right] isConstant]) {
            ORFloatLinear* left = [ORNormalizer floatLinearFrom:[e left] model:_model];
            [left scaleBy:[[e right] min]];
            [_terms addLinear:left];
        } else {
            id<ORFloatVar> alpha =  [ORNormalizer floatVarIn:_model expr:e];
            [_terms addTerm:alpha by:1];
        }
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
-(void) visitExprMulI: (ORExprMulI*) e
{
    id<ORFloatLinear> lT = [ORNormalizer floatLinearFrom:[e left] model:_model];
    id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e right] model:_model];
    id<ORFloatVar> lV = [ORNormalizer floatVarIn:lT for:_model];
    id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
    ORDouble llb = [[lV domain] low];
    ORDouble lub = [[lV domain] up];
    ORDouble rlb = [[rV domain] low];
    ORDouble rub = [[rV domain] up];
    ORDouble a = minDbl(llb * rlb,llb * rub);
    ORDouble b = minDbl(lub * rlb,lub * rub);
    ORDouble lb = minDbl(a,b);
    ORDouble c = maxDbl(llb * rlb,llb * rub);
    ORDouble d = maxDbl(lub * rlb,lub * rub);
    ORDouble ub = maxDbl(c,d);
    ORFloat flb = (lb < - FLT_MAX) ? -FLT_MAX : lb;
    ORFloat fub = (ub >  FLT_MAX) ? FLT_MAX : ub;
    if (_rv==nil){
        id<ORFloatRange> r = [ORFactory floatRange:_model low:flb up:fub];
        _rv = [ORFactory floatVar:_model domain: r];
    }
    [_model addConstraint: [ORFactory floatMult:_model var:lV by:rV equal:_rv]];
    [lT release];
    [rT release];
}
//TODO divide by 0 cf claude
-(void) visitExprDivI: (ORExprDivI*) e
{
    id<ORFloatLinear> lT = [ORNormalizer floatLinearFrom:[e left] model:_model];
    id<ORFloatLinear> rT = [ORNormalizer floatLinearFrom:[e right] model:_model];
    id<ORFloatVar> lV = [ORNormalizer floatVarIn:lT for:_model];
    id<ORFloatVar> rV = [ORNormalizer floatVarIn:rT for:_model];
    ORFloat llb = [[lV domain] low];
    ORFloat lub = [[lV domain] up];
    ORFloat rlb = [[rV domain] low];
    ORFloat rub = [[rV domain] up];
    ORDouble a = minDbl(llb / rlb,llb / rub);
    ORDouble b = minDbl(lub / rlb,lub / rub);
    ORDouble lb = minDbl(a,b);
    ORDouble c = maxDbl(llb / rlb,llb / rub);
    ORDouble d = maxDbl(lub / rlb,lub / rub);
    ORDouble ub = maxDbl(c,d);
    ORFloat flb = (lb < - FLT_MAX) ? -FLT_MAX : lb;
    ORFloat fub = (ub >  FLT_MAX) ? FLT_MAX : ub;
    if (_rv==nil){
        id<ORFloatRange> r = [ORFactory floatRange:_model low:flb up:fub];
        _rv = [ORFactory floatVar:_model domain: r];
    }
    [_model addConstraint: [ORFactory floatDiv:_model var:lV by:rV equal:_rv]];
    [lT release];
    [rT release];
}

-(id<ORFloatVar>)result
{
    return _rv;
}
@end
