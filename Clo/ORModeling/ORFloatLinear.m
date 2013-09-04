/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
   _terms = malloc(sizeof(struct CPFloatTerm) *_max);
   _nb    = 0;
   _indep = 0.0;
   return self;
}
-(void) dealloc
{
   free(_terms);
   [super dealloc];
}
-(void) setIndependent: (ORFloat) idp
{
   _indep = idp;
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
   ORFloat lb = _indep;
   for(ORInt k=0;k < _nb;k++) {
      ORFloat c = _terms[k]._coef;
      ORFloat vlb,vub;
      if ([_terms[k]._var conformsToProtocol:@protocol(ORFloatVar)]) {
         id<ORFloatRange> d= [(id<ORFloatVar>)_terms[k]._var domain];
         vlb = d.low;
         vub = d.up;
      } else if ([_terms[k]._var conformsToProtocol:@protocol(ORIntVar)]) {
         id<ORIntRange> d = [(id<ORIntVar>)_terms[k]._var domain];
         vlb = d.low;
         vub = d.up;
      }
      ORFloat svlb = c > 0 ? vlb * c : vub * c;
      lb += svlb;
   }
   return max(MININT,lb);
}

-(ORFloat) fmax
{
   ORFloat ub = _indep;
   for(ORInt k=0;k < _nb;k++) {
      ORFloat c = _terms[k]._coef;
      ORFloat vlb,vub;
      if ([_terms[k]._var conformsToProtocol:@protocol(ORFloatVar)]) {
         id<ORFloatRange> d= [(id<ORFloatVar>)_terms[k]._var domain];
         vlb = d.low;
         vub = d.up;
      } else if ([_terms[k]._var conformsToProtocol:@protocol(ORIntVar)]) {
         id<ORIntRange> d = [(id<ORIntVar>)_terms[k]._var domain];
         vlb = d.low;
         vub = d.up;
      }
      ORFloat svub = c > 0 ? vub * c : vlb * c;
      ub += svub;
   }
   return min(MAXINT,ub);
}

-(void) addTerm: (id<ORVar>) x by: (ORFloat) c
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
         _terms = realloc(_terms, sizeof(struct CPFloatTerm)*_max*2);
         _max <<= 1;
      }
      if (mid==-1)
         _terms[_nb++] = (struct CPFloatTerm){x,c};
      else {
         if (xid > kid)
            mid++;
         for(int k=_nb-1;k>=mid;--k)
            _terms[k+1] = _terms[k];
         _terms[mid] = (struct CPFloatTerm){x,c};
         _nb += 1;
      }
   }
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
static int decCoef(const struct CPFloatTerm* t1,const struct CPFloatTerm* t2)
{
   return t2->_coef - t1->_coef;
}
-(void) positiveFirst  // sort by decreasing coefficient
{
   qsort(_terms, _nb, sizeof(struct CPFloatTerm),(int(*)(const void*,const void*))&decCoef);
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
   return [ORFactory floatArray: model range: RANGE(model,0,_nb-1) with: ^ORFloat(ORInt i) { return _terms[i]._coef; }];
}

-(ORInt) size
{
   return _nb;
}

-(id<ORConstraint>) postEQZ: (id<ORAddToModel>) model annotation: (ORAnnotation) cons affineOk:(BOOL)aok
{
   return [model addConstraint:[ORFactory floatSum: model
                                             array: [self variables: model]
                                              coef: [self coefficients: model]
                                                eq: -_indep]];
}
-(id<ORConstraint>) postLEQZ: (id<ORAddToModel>) model annotation: (ORAnnotation) cons affineOk:(BOOL)aok
{
   return [model addConstraint:[ORFactory floatSum: model
                                             array: [self variables: model]
                                              coef: [self coefficients: model]
                                               leq: -_indep]];
}
-(id<ORConstraint>) postGEQZ: (id<ORAddToModel>) model annotation: (ORAnnotation) cons affineOk:(BOOL)aok
{
   return [model addConstraint:[ORFactory floatSum: model
                                             array: [self variables: model]
                                              coef: [self coefficients: model]
                                               geq: -_indep]];
}

-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons affineOk:(BOOL)aok
{
   assert(NO);
   return nil;
}
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons affineOk:(BOOL)aok
{
   assert(NO);
   return nil;
}
-(void) postMinimize: (id<ORAddToModel>) model annotation: (ORAnnotation) cons
{
   [model minimize: [self variables: model] coef: [self coefficients: model] independent:[self independent]];
}
-(void) postMaximize: (id<ORAddToModel>) model annotation: (ORAnnotation) cons
{
   [model maximize: [self variables: model] coef: [self coefficients: model] independent:[self independent]];
}
@end


@implementation ORFloatLinearFlip
-(ORFloatLinearFlip*) initORFloatLinearFlip: (id<ORFloatLinear>) r
{
   self = [super init];
   _real = r;
   return self;
}
-(void) setIndependent: (ORFloat) idp
{
   [_real setIndependent: -idp];
}
-(void) addIndependent: (ORFloat) idp
{
   [_real addIndependent: -idp];
}
-(void) addTerm: (id<ORIntVar>) x by: (ORFloat) c
{
   [_real addTerm: x by: -c];
}
-(void) addLinear: (id<ORFloatLinear>) lts
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
-(id<ORVar>) var: (ORInt) k
{
   return [_real var: k];
}
-(ORFloat) coef: (ORInt) k
{
   return [_real coef:k];
}
-(ORFloat) independent
{
   return [_real independent];
}
-(NSString*) description
{
   return [_real description];
}
-(ORFloat) fmin
{
   return [_real fmin];
}
-(ORFloat) fmax
{
   return [_real fmax];
}

-(id<ORConstraint>)postEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons affineOk:(BOOL)aok
{
   return [_real postEQZ:model annotation:cons affineOk:aok];
}
-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons affineOk:(BOOL)aok
{
   return [_real postNEQZ:model annotation:cons affineOk:aok];
}
-(id<ORConstraint>)postLEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons affineOk:(BOOL)aok
{
   return [_real postLEQZ:model annotation:cons affineOk:aok];
}
-(id<ORConstraint>)postGEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons affineOk:(BOOL)aok
{
   return [_real postGEQZ:model annotation:cons affineOk:aok];
}
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons affineOk:(BOOL)aok
{
   return [_real postDISJ:model annotation:cons affineOk:aok];
}
@end

