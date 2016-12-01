/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/
#import "ORDecompose.h"
#import "ORModeling/ORModeling.h"


@implementation ORIntLinear {
    struct CPTerm {
        id<ORIntVar>  _var;
        ORInt        _coef;
    };
    struct CPTerm* _terms;
    ORInt             _nb;
    ORInt            _max;
    ORInt          _indep;
}
-(ORIntLinear*)initORLinear:(ORInt)mxs
{
    self = [super init];
    _max   = mxs;
    _terms = malloc(sizeof(struct CPTerm)*_max);
    _nb    = 0;
    _indep = 0;
    return self;
}
-(void)dealloc
{
    free(_terms);
    [super dealloc];
}
-(BOOL)isZero
{
    return _nb == 0 && _indep == 0;
}
-(BOOL)isOne
{
    return _nb== 0 && _indep == 1;
}
-(BOOL)clausalForm
{
   BOOL cf = _indep == 0;
   for(int i=0;i < _nb && cf; i++) {
      cf = cf && _terms[i]._coef == 1 && [_terms[i]._var isBool];
   }
   return cf;
}
-(void)setIndependent:(ORInt)idp
{
    _indep = idp;
}
-(void)addIndependent:(ORInt)idp
{
    _indep += idp;
}
-(ORInt)independent
{
    return _indep;
}
-(id<ORIntVar>)var:(ORInt)k
{
    return _terms[k]._var;
}
-(ORInt)coef:(ORInt)k
{
    return _terms[k]._coef;
}
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c
{
    if (c==0) return;
   id<ORIntRange> dom = [x domain];
   if (dom.low == dom.up  && dom.up == 0) return;
   if (dom.low == dom.up) {
      _indep += dom.low * c;
      return ;
   }
    ORInt low = 0,up=_nb-1,mid=-1,kid;
    ORInt xid = [x  getId];
    BOOL found = NO;
    while (low <= up) {
        mid = (low+up)/2;
        kid = [_terms[mid]._var getId];
        found = kid == xid;
        if (found)
            break;
        else if (xid < kid)
            up = mid - 1;
        else low = mid + 1;
    }
    if (found) {
        _terms[mid]._coef += c;
        //assert(_terms[mid]._coef != 0);
        if (_terms[mid]._coef == 0) {
            for(ORInt k=mid+1;k<_nb;k++)
                _terms[k-1] = _terms[k];
            _nb--;
        }
    } else {
        if (_nb >= _max) {
            _terms = realloc(_terms, sizeof(struct CPTerm)*_max*2);
            _max <<= 1;
        }
        if (mid==-1)
            _terms[_nb++] = (struct CPTerm){x,c};
        else {
            if (xid > kid)
                mid++;
            for(int k=_nb-1;k>=mid;--k)
                _terms[k+1] = _terms[k];
            _terms[mid] = (struct CPTerm){x,c};
            _nb += 1;
        }
    }
}

-(void)addLinear:(ORIntLinear*)lts
{
    for(ORInt k=0;k < lts->_nb;k++) {
        [self addTerm:lts->_terms[k]._var by:lts->_terms[k]._coef];
    }
    [self addIndependent:lts->_indep];
}
-(void)scaleBy:(ORInt)s
{
    for(ORInt k=0;k<_nb;k++)
        _terms[k]._coef *= s;
    _indep  *= s;
}
-(ORBool)allPositive
{
    BOOL ap = YES;
    for(ORInt k=0;k<_nb;k++)
        ap &= _terms[k]._coef > 0;
    return ap;
}
-(ORBool)allNegative
{
    BOOL an = YES;
    for(ORInt k=0;k<_nb;k++)
        an &= _terms[k]._coef < 0;
    return an;
}
-(ORInt)nbPositive
{
    ORInt nbP = 0;
    for(ORInt k=0;k<_nb;k++)
        nbP += (_terms[k]._coef > 0);
    return nbP;
}
-(ORInt)nbNegative
{
    ORInt nbN = 0;
    for(ORInt k=0;k<_nb;k++)
        nbN += (_terms[k]._coef < 0);
    return nbN;
}
static int decCoef(const struct CPTerm* t1,const struct CPTerm* t2)
{
    return t2->_coef - t1->_coef;
}
-(void)positiveFirst  // sort by decreasing coefficient
{
    qsort(_terms, _nb, sizeof(struct CPTerm),(int(*)(const void*,const void*))&decCoef);
}

-(NSString*)description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:128] autorelease];
    for(ORInt k=0;k<_nb;k++) {
        [buf appendFormat:@"(%d * %@) + ",_terms[k]._coef,[_terms[k]._var description]];
    }
    [buf appendFormat:@" (%d)",_indep];
    return buf;
}
-(id<ORIntVarArray>) variables: (id<ORAddToModel>) model
{
    return [ORFactory intVarArray: [model tracker] range: RANGE(model,0,_nb-1) with:^id<ORIntVar>(ORInt i) { return _terms[i]._var; }];
}
-(id<ORIntArray>) coefficients: (id<ORAddToModel>) model
{
    return [ORFactory intArray: [model tracker] range: RANGE(model,0,_nb-1) with: ^ORInt(ORInt i) { return _terms[i]._coef; }];
}

-(id<ORIntVarArray>)scaledViews:(id<ORAddToModel>)model
{
    id<ORIntVarArray> sx = [ORFactory intVarArray:model
                                            range:RANGE(model,0,_nb-1)
                                             with:^id<ORIntVar>(ORInt i) {
                                                 id<ORIntVar> xi = _terms[i]._var;
                                                 id<ORIntVar> theView = [ORFactory intVar:model
                                                                                      var:xi
                                                                                    scale:_terms[i]._coef];
                                                 return theView;
                                             }];
    return sx;
}
-(id<ORIntVar>)oneView:(id<ORAddToModel>)model
{
    id<ORIntVar> rv = [ORFactory intVar:model
                                    var:_terms[0]._var
                                  scale:_terms[0]._coef
                                  shift:_indep];
    return rv;
}
-(ORInt)size
{
    return _nb;
}
-(ORInt)min
{
    ORLong lb = _indep;
    for(ORInt k=0;k < _nb;k++) {
        ORInt c = _terms[k]._coef;
        id<ORIntRange> d = [_terms[k]._var domain];
        ORLong vlb = d.low;
        ORLong vub = d.up;
        ORLong svlb = c > 0 ? vlb * c : vub * c;
        lb += svlb;
    }
    return max(MININT,bindDown(lb));
}
-(ORInt)max
{
    ORLong ub = _indep;
    for(ORInt k=0;k < _nb;k++) {
        ORInt c = _terms[k]._coef;
        id<ORIntRange> d = [_terms[k]._var domain];
        ORLong vlb = d.low;
        ORLong vub = d.up;
        ORLong svub = c > 0 ? vub * c : vlb * c;
        ub += svub;
    }
    return min(MAXINT,bindUp(ub));
}

-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model
{
    id<ORConstraint> rv = NULL;
    switch(_nb) {
        case 0: assert(NO);return rv;
        case 1: {
            if (_terms[0]._coef == 1) {
                rv = [model addConstraint:[ORFactory notEqualc:model var:_terms[0]._var to:- _indep]];
            } else if (_terms[0]._coef == -1) {
                rv = [model addConstraint:[ORFactory notEqualc:model var:_terms[0]._var to:_indep]];
            } else {
                assert(_terms[0]._coef != 0);
                ORInt nc = - _indep / _terms[0]._coef;
                ORInt cr = - _indep % _terms[0]._coef;
                if (cr == 0)
                    rv = [model addConstraint:[ORFactory notEqualc:model var:_terms[0]._var to:nc]];
            }
        }break;
        case 2: {
            if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
                rv = [model addConstraint:[ORFactory notEqual:model var:_terms[0]._var to:_terms[1]._var plus:-_indep]];
            } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1) {
                rv = [model addConstraint:[ORFactory notEqual:model var:_terms[1]._var to:_terms[0]._var plus:-_indep]];
            } else {
                id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
                id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef];
                rv = [model addConstraint:[ORFactory notEqual:model var:xp to:yp plus:- _indep]];
            }
        }break;
        default: {
//           ORInt lb = [self min];
//           ORInt ub = [self max];
//           id<ORIntVar> alpha = [ORFactory intVar:model
//                                           domain:[ORFactory intRange:[_terms[0]._var tracker] low:lb up:ub]];
//           [self addTerm:alpha by:-1];
//           [model addConstraint:[ORFactory sum:model array:[self scaledViews:model] eqi:-_indep]];
//           rv = [model addConstraint:[ORFactory notEqualc:model var:alpha to:0]];
           ORInt nbCOne = 0;
           for(ORInt k=0;k<_nb;k++)
              if ([_terms[k]._var isBool])
                 nbCOne += (_terms[k]._coef == 1);
           if (nbCOne == _nb) {
              id<ORIntVarArray> bv = All(model,ORIntVar,i,RANGE(model,0,_nb-1),_terms[i]._var);
              rv = [model addConstraint:[ORFactory sumbool:model array:bv neqi:- _indep]];
           } else {
              ORInt lb = [self min];
              ORInt ub = [self max];
              id<ORIntVar> alpha = [ORFactory intVar:model
                                              domain:[ORFactory intRange:[_terms[0]._var tracker] low:lb up:ub]];
              [self addTerm:alpha by:-1];
              [model addConstraint:[ORFactory sum:model array:[self scaledViews:model] eqi:-_indep]];
              rv = [model addConstraint:[ORFactory notEqualc:model var:alpha to:0]];
           }
        }break;
    }
    return rv;
}
-(id<ORConstraint>)postEQZ:(id<ORAddToModel>)model
{
    // [ldm] This should *never* raise an exception, but return a ORFailure.
    id<ORConstraint> rv = NULL;
    switch (_nb) {
      case 0: {
         if (_indep == 0)
            return NULL;
         else rv = [model addConstraint:[ORFactory fail:model]];
      }break;
        case 1: {
            if (_terms[0]._coef == 1) {
                rv = [model addConstraint:[ORFactory equalc:model var:_terms[0]._var to:-_indep]];
            } else if (_terms[0]._coef == -1) {
                rv = [model addConstraint:[ORFactory equalc:model var:_terms[0]._var to:_indep]];
            } else {
                assert(_terms[0]._coef != 0);
                ORInt nc = - _indep / _terms[0]._coef;
                ORInt cr = - _indep % _terms[0]._coef;
                if (cr != 0)
                    rv = [model addConstraint:[ORFactory fail:model]];
                else
                    rv = [model addConstraint:[ORFactory equalc:model var:_terms[0]._var to:nc]];
            }
        }break;
        case 2: {
            if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
                rv = [model addConstraint:[ORFactory equal:model var:_terms[0]._var to:_terms[1]._var plus:-_indep]];
            } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1) {
                rv = [model addConstraint:[ORFactory equal:model var:_terms[1]._var to:_terms[0]._var plus:-_indep]];
            } else {
                id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
                id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef];
                rv = [model addConstraint:[ORFactory equal:model var:xp to:yp plus:- _indep]];
            }
        }break;
        case 3: {
            // The creation of views should be the prerogative of the concretization. So we create a "vanilla" linear here.
            // after cleaning up to have most coefficients positive. See CPConcretizer.m[~ 200]
            ORInt np = [self nbPositive];
            if (np == 1 || np == 0) [self scaleBy:-1];
            assert([self nbPositive]>=2);
            [self positiveFirst];
            assert(_terms[0]._coef > 0 && _terms[1]._coef > 0);
            rv = [model addConstraint:[ORFactory sum:model array:[self variables:model] coef:[self coefficients:model] eq:-_indep]];
        }break;
        default: {
            ORInt sumCoefs = 0;
            for(ORInt k=0;k<_nb;k++)
                if ([_terms[k]._var isBool])
                    sumCoefs += (_terms[k]._coef == 1);
            if (sumCoefs == _nb) {
                id<ORIntVarArray> boolVars = All(model,ORIntVar, i, RANGE(model,0,_nb-1), _terms[i]._var);
                rv = [model addConstraint:[ORFactory sumbool:model array:boolVars eqi: - _indep]];
            }
            else
                rv = [model addConstraint:[ORFactory sum:model
                                                   array:[self variables:model]
                                                    coef:[self coefficients:model]
                                                      eq: - _indep]];
        }
    }
    return rv;
}
-(id<ORConstraint>)postLEQZ:(id<ORAddToModel>)model
{
   id<ORConstraint> rv = NULL;
   switch(_nb) {
      case 0: return NULL;
      case 1: {  // x <= c
         if (_terms[0]._coef == 1)
            rv = [model addConstraint: [ORFactory lEqualc:model var:_terms[0]._var to:- _indep]];
         else if (_terms[0]._coef == -1)
            rv = [model addConstraint: [ORFactory gEqualc:model var:_terms[0]._var to: _indep]];
         else {
            assert(_terms[0]._coef != 0);
            ORInt nc = - _indep / _terms[0]._coef;
            ORInt cr = - _indep % _terms[0]._coef;
            if (nc < 0 && cr != 0)
               rv = [model addConstraint:[ORFactory lEqualc:model var:_terms[0]._var to:nc - 1]];
            else
               rv = [model addConstraint:[ORFactory lEqualc:model var:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {  // x <= y
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            rv = [model addConstraint:[ORFactory lEqual:model var: _terms[0]._var to:_terms[1]._var plus:- _indep]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1  && _indep == 0) {
            rv = [model addConstraint:[ORFactory lEqual:model var: _terms[1]._var to:_terms[0]._var plus:- _indep]];
         } else {
//            id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
//            id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef shift:- _indep];
//            rv = [model addConstraint:[ORFactory lEqual:model var:xp to:yp]];
            rv = [model addConstraint:[ORFactory lEqual:model
                                                   coef:_terms[0]._coef
                                                  times:_terms[0]._var
                                                    leq:-_terms[1]._coef
                                                  times:_terms[1]._var
                                                   plus:- _indep]];
         }
      }break;
      default:
         //rv = [model addConstraint:[ORFactory sum:model array:[self scaledViews:model annotation:cons] leqi:- _indep]];
         rv = [model addConstraint:[ORFactory sum:model
                                            array:[self variables:model]
                                             coef:[self coefficients:model]
                                              leq:- _indep]];
   }
   return rv;
}
-(id<ORConstraint>)postGEQZ:(id<ORAddToModel>)model
{
   id<ORConstraint> rv = NULL;
   switch(_nb) {
      case 0: return NULL;
      case 1: {  // x >= c
         if (_terms[0]._coef == 1) // x + c >= 0 =>  x >= - c
            rv = [model addConstraint: [ORFactory gEqualc:model var:_terms[0]._var to:- _indep]];
         else if (_terms[0]._coef == -1)  // -x + c >= 0 =>  c >= x =>  x <= c
            rv = [model addConstraint: [ORFactory lEqualc:model var:_terms[0]._var to: _indep]];
         else {   // a * x + c >= 0 => a *x >= -c => x >= floor(-c/a)
            assert(_terms[0]._coef != 0);
            ORInt nc = - _indep / _terms[0]._coef;
            ORInt cr = - _indep % _terms[0]._coef;
            if (nc < 0 && cr != 0)
               rv = [model addConstraint:[ORFactory gEqualc:model var:_terms[0]._var to:nc - 1]];
            else
               rv = [model addConstraint:[ORFactory gEqualc:model var:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {  // x - y +c >= 0 =>  x >= y - c
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            rv = [model addConstraint:[ORFactory gEqual:model var: _terms[0]._var to:_terms[1]._var plus:- _indep]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1  && _indep == 0) { // -x + y +c >= 0 => y >= x -c
            rv = [model addConstraint:[ORFactory gEqual:model var: _terms[1]._var to:_terms[0]._var plus:- _indep]];
         } else { // a * x + b * y +c >= 0 => - a * x - b * y -c <= 0
            // a * x >= -b * y - c ==>  -a * x <= b * y + c
            rv = [model addConstraint:[ORFactory lEqual:model
                                                   coef: - _terms[0]._coef
                                                  times: _terms[0]._var
                                                    leq: _terms[1]._coef
                                                  times: _terms[1]._var
                                                   plus:+ _indep]];
         }
      }break;
      default: {
         // sum(i in S) a_i * x_i + c >= 0  => sum(i in S) - a_i * x_i -c <= 0 => sum(i in S) - a_i * x_i <= c
         id<ORIntArray> c  = [self coefficients:model];
         id<ORIntArray> fc = [ORFactory intArray:model range:c.range with:^ORInt(ORInt k) {
            return - [c at:k];
         }];
         rv = [model addConstraint:[ORFactory sum:model
                                            array:[self variables:model]
                                             coef: fc
                                              leq: _indep]];
      }break;
   }
   return rv;
}

-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model
{
    id<ORConstraint> rv = NULL;
    switch (_nb) {
      case 0: {
         if (_indep == 0)
            rv = [model addConstraint:[ORFactory fail:model]];
      }break;
        case 1: {
            assert(_terms[0]._coef == 1 && _indep == 0);
            rv = [model addConstraint:[ORFactory equalc:model var:_terms[0]._var to:1]];
        }break;
        case 2: {
            assert(_terms[0]._coef == 1 && _terms[1]._coef == 1 && _indep == 0);
            id<ORIntVar> nx = [ORFactory intVar:model var:_terms[0]._var scale:-1];
            id<ORIntVar> y  = _terms[1]._var;
            rv = [model addConstraint:[ORFactory lEqual:model var:nx to:y plus:-1]];
            //rv = [model addConstraint:[ORFactory sumbool:model array:[self scaledViews:model] geqi:1]];
        }break;
        default:
            rv = [model addConstraint:[ORFactory sumbool:model array:[self scaledViews:model] geqi:1]];
            break;
    }
    return rv;
}
-(id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model
{
   assert(_nb == 0);
   if (_indep == 0)
      return [ORFactory fail:model];
   else
      return nil;
}
@end


@implementation ORLinearFlip {
    id<ORIntLinear> _real;
}
-(ORLinearFlip*) initORLinearFlip: (id<ORIntLinear>)r
{
    self = [super init];
    _real = r;
    return self;
}
-(BOOL)isZero
{
    return [_real isZero];
}
-(BOOL)isOne
{
    return [_real size] == 0 && [_real independent] == -1;
}
-(BOOL)clausalForm
{
   return NO;
}
-(void) setIndependent:(ORInt)idp
{
    [_real setIndependent:-idp];
}
-(void) addIndependent:(ORInt)idp
{
    [_real addIndependent:-idp];
}
-(void) addTerm:(id<ORIntVar>) x by: (ORInt) c
{
    [_real addTerm: x by: -c];
}
-(void) addLinear: (id<ORIntLinear>) lts
{
    for(ORInt k=0;k < [lts size];k++) {
        [_real addTerm:[lts var:k] by: - [lts coef:k]];
    }
    [_real addIndependent:- [lts independent]];
}
-(void) scaleBy: (ORInt) s
{
    [_real scaleBy: -s];
}
-(ORInt) size
{
    return [_real size];
}
-(id<ORIntVar>) var: (ORInt) k
{
    return [_real var: k];
}
-(ORInt)coef: (ORInt) k
{
    return [_real coef:k];
}
-(ORInt)min
{
    return [_real min];
}
-(ORInt)max
{
    return [_real max];
}
-(ORInt) independent
{
    return [_real independent];
}
-(NSString*) description
{
    return [_real description];
}
-(id<ORConstraint>)postEQZ:(id<ORAddToModel>)model
{
    return [_real postEQZ:model];
}
-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model
{
    return [_real postNEQZ:model];
}
-(id<ORConstraint>)postLEQZ:(id<ORAddToModel>)model
{
    return [_real postLEQZ:model];
}
-(id<ORConstraint>)postGEQZ:(id<ORAddToModel>)model
{
   return [_real postGEQZ:model];
}
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model
{
    return [_real postDISJ:model];
}
-(id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model
{
   return [_real postIMPLY:model];
}

@end

