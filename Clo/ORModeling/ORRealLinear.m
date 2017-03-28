/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORRealLinear.h"
#import "ORModeling/ORModeling.h"


@implementation ORRealLinear
-(ORRealLinear*) initORRealLinear: (ORInt) mxs
{
   self = [super init];
   _max   = mxs;
   _terms = malloc(sizeof(struct ORDoubleTerm) *_max);
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
-(ORDouble) fmin
{
   ORDouble lb = _indep;
   for(ORInt k=0;k < _nb;k++) {
      ORDouble c = _terms[k]._coef;
      ORDouble vlb,vub;
      if ([_terms[k]._var conformsToProtocol:@protocol(ORRealVar)]) {
         id<ORRealRange> d = [(id<ORRealVar>)_terms[k]._var domain];
         vlb = d.low;
         vub = d.up;
      } else if ([_terms[k]._var conformsToProtocol:@protocol(ORIntVar)]) {
         id<ORIntRange> d = [(id<ORIntVar>)_terms[k]._var domain];
         vlb = d.low;
         vub = d.up;
      }
      ORDouble svlb = c > 0 ? vlb * c : vub * c;
      lb += svlb;
   }
    return ((-FLT_MAX) > lb) ? FLT_MAX : lb;
}

-(ORDouble) fmax
{
   ORDouble ub = _indep;
   for(ORInt k=0;k < _nb;k++) {
      ORDouble c = _terms[k]._coef;
      id<ORRealRange> d = [(id<ORRealVar>)_terms[k]._var domain];
      ORDouble vlb = d.low;
      ORDouble vub = d.up;
      ORDouble svub = c > 0 ? vub * c : vlb * c;
      ub += svub;
   }
    return ((FLT_MAX) < ub) ? FLT_MAX : ub;
}

-(void) addTerm: (id<ORVar>) x by: (ORDouble) c
{
   if (c==0) return;
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
      else
         low = mid + 1;
   }
   if (found) {
      _terms[mid]._coef += c;
   } else {
      if (_nb >= _max) {
         _terms = realloc(_terms, sizeof(struct ORDoubleTerm)*_max*2);
         _max <<= 1;
      }
      if (mid==-1)
         _terms[_nb++] = (struct ORDoubleTerm){x,c};
      else {
         if (xid > kid)
            mid++;
         for(int k=_nb-1;k>=mid;--k)
            _terms[k+1] = _terms[k];
         _terms[mid] = (struct ORDoubleTerm){x,c};
         _nb += 1;
      }
   }
}

-(void) addLinear: (ORRealLinear*) lts
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
static int decCoef(const struct ORDoubleTerm* t1,const struct ORDoubleTerm* t2)
{
   return t2->_coef - t1->_coef;
}
-(void) positiveFirst  // sort by decreasing coefficient
{
   qsort(_terms, _nb, sizeof(struct ORDoubleTerm),(int(*)(const void*,const void*))&decCoef);
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
   return [ORFactory doubleArray: model range: RANGE(model,0,_nb-1) with: ^ORDouble(ORInt i) { return _terms[i]._coef; }];
}

-(ORInt) size
{
   return _nb;
}

-(id<ORConstraint>) postEQZ: (id<ORAddToModel>) model
{
    return [model addConstraint:[ORFactory realSum: model
                                             array: [self variables: model]
                                              coef: [self coefficients: model]
                                                eq: -_indep]];
}
-(id<ORConstraint>) postLEQZ: (id<ORAddToModel>) model
{
    return [model addConstraint:[ORFactory realSum: model
                                             array: [self variables: model]
                                              coef: [self coefficients: model]
                                               leq: -_indep]];
}
-(id<ORConstraint>) postGEQZ: (id<ORAddToModel>) model
{
   return [model addConstraint:[ORFactory realSum: model
                                            array: [self variables: model]
                                             coef: [self coefficients: model]
                                              geq: -_indep]];
}

-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model
{
    assert(NO);
    return nil;
}
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model
{
    assert(NO);
    return nil;
}
-(id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model
{
   assert(NO);
   return nil;
}
-(id<ORConstraint>)postLTZ:(id<ORAddToModel>)model
{
    assert(NO);
    return nil;
}
-(id<ORConstraint>)postGTZ:(id<ORAddToModel>)model
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
@end


@implementation ORRealLinearFlip
-(id) initORRealLinearFlip: (id<ORRealLinear>) r
{
   self = [super init];
   _real = r;
   return self;
}
-(void) setIndependent: (ORDouble) idp
{
   [_real setIndependent: -idp];
}
-(void) addIndependent: (ORDouble) idp
{
   [_real addIndependent: -idp];
}
-(void) addTerm: (id<ORIntVar>) x by: (ORDouble) c
{
   [_real addTerm: x by: -c];
}
-(void) addLinear: (id<ORRealLinear>) lts
{
   for(ORInt k=0;k < [lts size];k++) {
      [_real addTerm:[lts var:k] by: - [lts coef:k]];
   }
   [_real addIndependent:- [lts independent]];
}
-(void) scaleBy: (ORDouble) s
{
   [_real scaleBy: -s];
}
-(ORInt) size
{
   return [_real size];
}
-(id<ORVar>) var: (ORInt) k
{
   return [_real var: k];
}
-(ORDouble) coef: (ORInt) k
{
   return [_real coef:k];
}
-(ORDouble) independent
{
   return [_real independent];
}
-(NSString*) description
{
   return [_real description];
}
-(ORDouble) fmin
{
   return [_real fmin];
}
-(ORDouble) fmax
{
   return [_real fmax];
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
-(id<ORConstraint>)postLTZ:(id<ORAddToModel>)model
{
    return [_real postLTZ:model];
}
-(id<ORConstraint>)postGTZ:(id<ORAddToModel>)model
{
    return [_real postGTZ:model];
}
@end

