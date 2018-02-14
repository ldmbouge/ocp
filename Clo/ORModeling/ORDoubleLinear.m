/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORDoubleLinear.h"
#import "ORModeling/ORModeling.h"


@implementation ORDoubleLinear
-(ORDoubleLinear*) initORDoubleLinear: (ORInt) mxs
{
    self = [super init];
    _max   = mxs;
    _terms = malloc(sizeof(struct ORDoubleTerm) *_max);
    _nb    = 0;
    _indep = 0.0;
    return self;
}
-(ORDoubleLinear*) initORDoubleLinear: (ORInt) mxs type:(ORRelationType) t
{
    self = [super init];
    _max   = mxs;
    _terms = malloc(sizeof(struct ORDoubleTerm) *_max);
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
-(void) setIndependent: (ORDouble) idp
{
    _indep = idp;
}
-(void) addIndependent: (ORDouble) idp
{
    _indep += idp;
}
-(ORDouble) independent
{
    return _indep;
}
-(id<ORVar>) var: (ORInt) k
{
    return _terms[k]._var;
}
-(ORDouble) coef: (ORInt) k
{
    return _terms[k]._coef;
}
-(ORDouble) dmin
{
    ORLDouble lb = _indep;
    for(ORInt k=0;k < _nb;k++) {
        ORLDouble c = _terms[k]._coef;
        ORLDouble vlb,vub;
        id<ORDoubleRange> d = [(id<ORDoubleVar>)_terms[k]._var domain];
        vlb = d.low;
        vub = d.up;
        ORDouble svlb = c > 0 ? vlb * c : vub * c;
        lb += svlb;
    }
    return ((-DBL_MAX) > lb) ? -DBL_MAX : lb;
}
-(ORDouble) dmax
{
    ORLDouble ub = _indep;
    for(ORInt k=0;k < _nb;k++) {
        ORLDouble c = _terms[k]._coef;
        id<ORDoubleRange> d = [(id<ORDoubleVar>)_terms[k]._var domain];
        ORDouble vlb = d.low;
        ORDouble vub = d.up;
        ORLDouble svub = c > 0 ? vub * c : vlb * c;
        ub += svub;
    }
    return ((DBL_MAX) < ub) ? DBL_MAX : ub;
}

-(void) addTerm: (id<ORVar>) x by: (ORDouble) c
{
    if (_nb >= _max) {
        _terms = realloc(_terms, sizeof(struct ORDoubleTerm)*_max*2);
        _max <<= 1;
    }
    _terms[_nb++] = (struct ORDoubleTerm){x,c};
}

-(void) addLinear: (ORDoubleLinear*) lts
{
    for(ORInt k=0;k < lts->_nb;k++) {
        [self addTerm:lts->_terms[k]._var by:lts->_terms[k]._coef];
    }
    [self addIndependent:lts->_indep];
}
-(void) scaleBy: (ORDouble) s
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

-(id<ORDoubleArray>) coefficients: (id<ORAddToModel>) model
{
    return [ORFactory doubleArray: model
                           range: RANGE(model,0,_nb-1)
                            with: ^ORDouble(ORInt i) { return _terms[i]._coef; }];
}

-(ORInt) size
{
    return _nb;
}

-(id<ORConstraint>) postEQZ: (id<ORAddToModel>) model
{
    return [model addConstraint:[ORFactory doubleSum: model
                                              array: [self variables: model]
                                               coef: [self coefficients: model]
                                                 eq: -_indep]];
}
-(id<ORConstraint>) postLTZ: (id<ORAddToModel>) model
{
    return [model addConstraint:[ORFactory doubleSum: model
                                              array: [self variables: model]
                                               coef: [self coefficients: model]
                                                 lt: -_indep]];
}
-(id<ORConstraint>) postGTZ: (id<ORAddToModel>) model
{
    return [model addConstraint:[ORFactory doubleSum: model
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
    return [model addConstraint:[ORFactory doubleSum:model
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
//TODO need to be filled
-(id<ORConstraint>)postSET:(id<ORAddToModel>)model
{
   assert(NO);
   return nil;
}
-(void) postMinimize: (id<ORAddToModel>) model
{
    [model minimize: [self variables: model] coef: [self coefficients: model]];
}
-(void) postMaximize: (id<ORAddToModel>) model
{
    [model maximize: [self variables: model] coef: [self coefficients: model]];
}
-(id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model
{
    assert(NO);
    return nil;
}
-(void) visit :(id<ORDoubleLinear>) right
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

@implementation ORDoubleLinearFlip
-(id) initORDoubleLinearFlip: (id<ORDoubleLinear>) r
{
    self = [super init];
    _double = r;
    return self;
}
-(void) setIndependent: (ORDouble) idp
{
    [_double setIndependent: -idp];
}
-(void) addIndependent: (ORDouble) idp
{
    [_double addIndependent: -idp];
}
-(void) addTerm: (id<ORDoubleVar>) x by: (ORDouble) c
{
    [_double addTerm: x by: -c];
}
-(void) addLinear: (id<ORDoubleLinear>) lts
{
    for(ORInt k=0;k < [lts size];k++) {
        [_double addTerm:[lts var:k] by: - [lts coef:k]];
    }
    [_double addIndependent:- [lts independent]];
}
-(void) scaleBy: (ORDouble) s
{
    [_double scaleBy: -s];
}
-(ORInt) size
{
    return [_double size];
}
-(id<ORVar>) var: (ORInt) k
{
    return [_double var: k];
}
-(ORDouble) coef: (ORInt) k
{
    return [_double coef:k];
}
-(ORDouble) independent
{
    return [_double independent];
}
-(NSString*) description
{
    return [_double description];
}
-(ORDouble) dmin
{
    return [_double dmin];
}
-(ORDouble) dmax
{
    return [_double dmax];
}
-(BOOL)isZero
{
    return [_double isZero];
}
-(id<ORConstraint>)postEQZ:(id<ORAddToModel>)model
{
    return [_double postEQZ:model];
}
-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model
{
    return [_double postNEQZ:model];
}
-(id<ORConstraint>) postLTZ: (id<ORAddToModel>) model
{
    return [_double postLTZ:model];
}
-(id<ORConstraint>) postGTZ: (id<ORAddToModel>) model
{
    return [_double postGTZ:model];
}
-(id<ORConstraint>)postLEQZ:(id<ORAddToModel>)model
{
    return [_double postLEQZ:model];
}
-(id<ORConstraint>)postGEQZ:(id<ORAddToModel>)model
{
    return [_double postGEQZ:model];
}
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model
{
    return [_double postDISJ:model];
}
-(id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model
{
    return [_double postIMPLY:model];
}
-(id<ORConstraint>)postSET:(id<ORAddToModel>)model
{
   return [_double postSET:model];
}
@end

