/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFloatLinear.h"
#import "ORModeling/ORModeling.h"


@implementation ORFloatLinear
-(ORFloatLinear*) initORFloatLinear: (ORInt) mxs
{
    self = [super init];
    _max   = mxs;
    _terms = malloc(sizeof(struct ORFloatTerm) *_max);
    _nb    = 0;
    _indep = 0.0;
    return self;
}
-(ORFloatLinear*) initORFloatLinear: (ORInt) mxs type:(ORRelationType) t
{
    self = [super init];
    _max   = mxs;
    _terms = malloc(sizeof(struct ORFloatTerm) *_max);
    _type = t;
    _nb    = 0;
    _indep = 0.0;
    return self;
}
-(void) dealloc
{
    free(_terms);
    [super dealloc];
}
-(void) setIndependent: (ORExprI*) idp direction:(ORInt)d
{
   _indep = (d > 0) ? [idp fmin] : -[idp fmin];
}
-(void) addIndependent: (ORFloat) idp
{
    _indep += idp;
}
-(ORFloat) independent
{
    return _indep;
}
-(id<ORVar>) var: (ORInt) k
{
    return _terms[k]._var;
}
-(ORFloat) coef: (ORInt) k
{
    return _terms[k]._coef;
}
-(ORFloat) fmin
{
    ORDouble lb = _indep;
    for(ORInt k=0;k < _nb;k++) {
        ORDouble c = _terms[k]._coef;
        ORDouble vlb,vub;
        id<ORFloatRange> d = [(id<ORFloatVar>)_terms[k]._var domain];
        vlb = d.low;
        vub = d.up;
        ORDouble svlb = c > 0 ? vlb * c : vub * c;
        lb += svlb;
    }
    return ((-FLT_MAX) > lb) ? -FLT_MAX : lb;
}
-(ORFloat) fmax
{
    ORDouble ub = _indep;
    for(ORInt k=0;k < _nb;k++) {
        ORDouble c = _terms[k]._coef;
        id<ORFloatRange> d = [(id<ORFloatVar>)_terms[k]._var domain];
        ORDouble vlb = d.low;
        ORDouble vub = d.up;
        ORDouble svub = c > 0 ? vub * c : vlb * c;
        ub += svub;
    }
    return ((FLT_MAX) < ub) ? FLT_MAX : ub;
}

-(void) addTerm: (id<ORVar>) x by: (ORFloat) c
{
    if (_nb >= _max) {
        _terms = realloc(_terms, sizeof(struct ORFloatTerm)*_max*2);
        _max <<= 1;
    }
    _terms[_nb++] = (struct ORFloatTerm){x,c};
}

-(void) addLinear: (ORFloatLinear*) lts
{
    for(ORInt k=0;k < lts->_nb;k++) {
        [self addTerm:lts->_terms[k]._var by:lts->_terms[k]._coef];
    }
    [self addIndependent:lts->_indep];
}
-(void) scaleBy: (ORFloat) s
{
    for(ORInt k=0;k<_nb;k++)
        _terms[k]._coef *= s;
    _indep  *= s;
}
-(ORBool) allPositive
{
    BOOL ap = YES;
    for(ORInt k=0;k<_nb;k++)
        ap &= _terms[k]._coef > 0;
    return ap;
}
-(ORBool) allNegative
{
    BOOL an = YES;
    for(ORInt k=0;k<_nb;k++)
        an &= _terms[k]._coef < 0;
    return an;
}
-(ORInt) nbPositive
{
    ORInt nbP = 0;
    for(ORInt k=0;k<_nb;k++)
        nbP += (_terms[k]._coef > 0);
    return nbP;
}
-(ORInt) nbNegative
{
    ORInt nbN = 0;
    for(ORInt k=0;k<_nb;k++)
        nbN += (_terms[k]._coef < 0);
    return nbN;
}
-(BOOL)isZero
{
    return _nb == 0 && _indep == 0;
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:128] autorelease];
    for(ORInt k=0;k<_nb;k++) {
        [buf appendFormat:@"(%f * %@) + ",_terms[k]._coef,[_terms[k]._var description]];
    }
    [buf appendFormat:@" (%f)",_indep];
    return buf;
}
-(id<ORVarArray>) variables: (id<ORAddToModel>) model
{
    return [ORFactory varArray: model range: RANGE(model,0,_nb-1) with:^id<ORVar>(ORInt i) { return _terms[i]._var; }];
}

-(id<ORFloatArray>) coefficients: (id<ORAddToModel>) model
{
    return [ORFactory floatArray: model
                           range: RANGE(model,0,_nb-1)
                            with: ^ORFloat(ORInt i) { return _terms[i]._coef; }];
}

-(ORInt) size
{
    return _nb;
}

-(id<ORConstraint>) postEQZ: (id<ORAddToModel>) model
{
    return [model addConstraint:[ORFactory floatSum: model
                                              array: [self variables: model]
                                               coef: [self coefficients: model]
                                                 eq: -_indep]];
}
-(id<ORConstraint>) postLTZ: (id<ORAddToModel>) model
{
    return [model addConstraint:[ORFactory floatSum: model
                                              array: [self variables: model]
                                               coef: [self coefficients: model]
                                                 lt: -_indep]];
}
-(id<ORConstraint>) postGTZ: (id<ORAddToModel>) model
{
    return [model addConstraint:[ORFactory floatSum: model
                                              array: [self variables: model]
                                               coef: [self coefficients: model]
                                                 gt: -_indep]];
}
-(id<ORConstraint>) postLEQZ: (id<ORAddToModel>) model
{
    assert(NO);
    return nil;
}
-(id<ORConstraint>) postGEQZ: (id<ORAddToModel>) model
{
    assert(NO);
    return nil;
}
-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model
{
    return [model addConstraint:[ORFactory floatSum:model
                                              array:[self variables:model]
                                               coef:[self coefficients:model]
                                                neq:-_indep]];
}
//TODO need to be filled
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model
{
    assert(NO);
    return nil;
}
-(void) postMinimize: (id<ORAddToModel>) model
{
//    [model minimize: [self variables: model] coef: [self coefficients: model]];
    assert(NO);
}
-(void) postMaximize: (id<ORAddToModel>) model
{
    //[model maximize: [self variables: model] coef: [self coefficients: model]];
    assert(NO);
}
-(id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model
{
    assert(NO);
    return nil;
}
-(void) visit :(id<ORFloatLinear>) right
{
    switch(_type)
    {
    case ORRLThen ://same as ORRGThen
    case ORRGThen :
            [right scaleBy:-1];
            [self addLinear:right];
            break;
    case ORREq :
            if([self size] == 1){
                [right scaleBy:-1];
                [self addLinear:right];
            }else{
                [self scaleBy:-1];
                [right addLinear:self];
            }
            break;
    default :
            if([self size] == 1){
                [right scaleBy:-1];
                [self addLinear:right];
            }else{
                [self scaleBy:-1];
                [right addLinear:self];
            }
            break;
    }
}
@end


@implementation ORFloatLinearFlip
-(id) initORFloatLinearFlip: (id<ORFloatLinear>) r
{
    self = [super init];
    _float = r;
    return self;
}
-(void) setIndependent: (ORExprI*) idp direction:(ORInt)d
{
    [_float setIndependent:idp direction:d];
}
-(void) setIndependent: (ORExprI*) idp
{
   [_float setIndependent:idp direction:-1];
}
-(void) addIndependent: (ORFloat) idp
{
    [_float addIndependent: -idp];
}
-(void) addTerm: (id<ORFloatVar>) x by: (ORFloat) c
{
    [_float addTerm: x by: -c];
}
-(void) addLinear: (id<ORFloatLinear>) lts
{
    for(ORInt k=0;k < [lts size];k++) {
        [_float addTerm:[lts var:k] by: - [lts coef:k]];
    }
    [_float addIndependent:- [lts independent]];
}
-(void) scaleBy: (ORFloat) s
{
    [_float scaleBy: -s];
}
-(ORInt) size
{
    return [_float size];
}
-(id<ORVar>) var: (ORInt) k
{
    return [_float var: k];
}
-(ORFloat) coef: (ORInt) k
{
    return [_float coef:k];
}
-(ORFloat) independent
{
    return [_float independent];
}
-(NSString*) description
{
    return [_float description];
}
-(ORFloat) fmin
{
    return [_float fmin];
}
-(ORFloat) fmax
{
    return [_float fmax];
}
-(BOOL)isZero
{
    return [_float isZero];
}
-(id<ORConstraint>)postEQZ:(id<ORAddToModel>)model
{
    return [_float postEQZ:model];
}
-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model
{
    return [_float postNEQZ:model];
}
-(id<ORConstraint>) postLTZ: (id<ORAddToModel>) model
{
    return [_float postLTZ:model];
}
-(id<ORConstraint>) postGTZ: (id<ORAddToModel>) model
{
    return [_float postGTZ:model];
}
-(id<ORConstraint>)postLEQZ:(id<ORAddToModel>)model
{
    return [_float postLEQZ:model];
}
-(id<ORConstraint>)postGEQZ:(id<ORAddToModel>)model
{
    return [_float postGEQZ:model];
}
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model
{
    return [_float postDISJ:model];
}
-(id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model
{
    return [_float postIMPLY:model];
}
@end

