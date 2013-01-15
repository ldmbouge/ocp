/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/
#import "ORDecompose.h"
#import "ORModeling/ORModeling.h"

@interface ORLinearFlip : NSObject<ORLinear> {
   id<ORLinear> _real;
}
-(ORLinearFlip*)initORLinearFlip:(id<ORLinear>)r;
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
@end

@interface ORSubst   : NSObject<ORVisitor> {
   id<ORIntVar>      _rv;
   id<ORAddToModel> _model;
   ORAnnotation       _c;
}
-(id)initORSubst:(id<ORAddToModel>) model annotation:(ORAnnotation)c;
-(id)initORSubst:(id<ORAddToModel>) model annotation:(ORAnnotation)c by:(id<ORIntVar>)x;
-(id<ORIntVar>)result;
-(void) visitIntVar: (id<ORIntVar>) e;
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprModI: (ORExprModI*) e;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprProdI: (ORExprProdI*) e;
-(void) visitExprAggOrI: (ORExprAggOrI*) e;
-(void) visitExprAbsI:(ORExprAbsI *)e;
-(void) visitExprNegateI:(ORExprNegateI*)e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(ORExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
+(id<ORIntVar>) substituteIn:(id<ORAddToModel>) model expr:(ORExprI*)expr annotation:(ORAnnotation)c;
+(id<ORIntVar>) substituteIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x annotation:(ORAnnotation)c;
+(id<ORIntVar>)normSide:(ORLinear*)e for:(id<ORAddToModel>) model annotation:(ORAnnotation)c;
@end

@implementation ORLinearFlip
-(ORLinearFlip*)initORLinearFlip:(id<ORLinear>)r
{
   self = [super init];
   _real = r;
   return self;
}
-(void)setIndependent:(ORInt)idp
{
   [_real setIndependent:-idp];
}
-(void)addIndependent:(ORInt)idp
{
   [_real addIndependent:-idp];
}
-(void)addTerm:(id<ORIntVar>) x by:(ORInt)c
{
   [_real addTerm: x by:-c];
}
-(void)addLinear:(id<ORLinear>)lts
{
   for(ORInt k=0;k < [lts size];k++) {
      [_real addTerm:[lts var:k] by: - [lts coef:k]];
   }
   [_real addIndependent:- [lts independent]];
}
-(void)scaleBy:(ORInt)s
{
   [_real scaleBy:-s];
}
-(ORInt)size
{
   return [_real size];
}
-(id<ORIntVar>)var:(ORInt)k
{
   return [_real var:k];
}
-(ORInt)coef:(ORInt)k
{
   return [_real coef:k];
}
-(ORInt)independent
{
   return [_real independent];
}
-(NSString*)description
{
   return [_real description];
}
@end

@interface ORLinearizer : NSObject<ORVisitor> {
   id<ORLinear>   _terms;
   id<ORAddToModel>    _model;
   ORAnnotation       _n;
   id<ORIntVar>       _eqto;
}
-(id)initORLinearizer:(id<ORLinear>)t model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(ORLinear*)linearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(ORLinear*)linearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x annotation:(ORAnnotation)n;
+(ORLinear*)addToLinear:(id<ORLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
-(void) visitIntVar: (id<ORIntVar>) e;
-(void) visitAffineVar:(id<ORIntVar>)e;
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprModI: (ORExprModI*) e;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprProdI: (ORExprProdI*) e;
-(void) visitExprAggOrI: (ORExprAggOrI*) e;
-(void) visitExprAbsI:(ORExprAbsI*) e;
-(void) visitExprNegateI:(ORExprNegateI*)e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(ORExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
@end

@implementation ORNormalizer
+(ORLinear*)normalize:(ORExprI*)rel into:(id<ORAddToModel>) model annotation:(ORAnnotation)n
{
   ORNormalizer* v = [[ORNormalizer alloc] initORNormalizer: model annotation:n];
   [rel visit:v];
   ORLinear* rv = v->_terms;
   [v release];
   return rv;
}
-(id)initORNormalizer:(id<ORAddToModel>) model annotation:(ORAnnotation)n
{
   self = [super init];
   _terms = nil;
   _model = model;
   _n = n;
   return self;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] min] == [[e right] min];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORInt c = lc ? [[e left] min] : [[e right] min];
      ORExprI* other = lc ? [e right] : [e left];
      ORLinear* lin  = [ORLinearizer linearFrom:other model:_model annotation:_n];
      [lin addIndependent: - c];
      _terms = lin;
   } else {
      bool lv = [[e left] isVariable];
      bool rv = [[e right] isVariable];
      if (lv || rv) {
         ORExprI* other = lv ? [e right] : [e left];
         ORExprI* var   = lv ? [e left] : [e right];
         id<ORIntVar> theVar = [ORSubst substituteIn:_model expr:var annotation:_n];
         ORLinear* lin  = [ORLinearizer linearFrom:other model:_model equalTo:theVar annotation:_n];
         [lin release];
         _terms = nil; // we already did the full rewrite. Nothing left todo  @ top-level.
      } else {
         ORLinear* linLeft = [ORLinearizer linearFrom:[e left] model:_model annotation:_n];
         ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
         [ORLinearizer addToLinear:linRight from:[e right] model:_model annotation:_n];
         [linRight release];
         _terms = linLeft;
      }
   }
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   ORLinear* linLeft = [ORLinearizer linearFrom:[e left] model:_model annotation:_n];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORLinearizer addToLinear:linRight from:[e right] model:_model annotation:_n];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   ORLinear* linLeft = [ORLinearizer linearFrom:[e left] model:_model annotation:_n];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORLinearizer addToLinear:linRight from:[e right] model:_model annotation:_n];
   [linRight release];
   _terms = linLeft;
}

struct CPVarPair {
   id<ORIntVar> lV;
   id<ORIntVar> rV;
   id<ORIntVar> boolVar;
};
-(struct CPVarPair) visitLogical:(ORExprI*)l right:(ORExprI*)r
{
   ORLinear* linLeft  = [ORLinearizer linearFrom:l model:_model annotation:_n];
   ORLinear* linRight = [ORLinearizer linearFrom:r model:_model annotation:_n];
   id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model annotation:_n];
   id<ORIntVar> rV = [ORSubst normSide:linRight for:_model annotation:_n];
   id<ORIntVar> final = [ORFactory intVar: _model domain:RANGE(_model,0,1)];
   [_model addConstraint:[ORFactory equalc:_model var:final to:1]];
   return (struct CPVarPair){lV,rV,final};
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_model addConstraint:[ORFactory model:_model boolean:vars.lV or:vars.rV equal:vars.boolVar]];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_model addConstraint:[ORFactory model:_model boolean:vars.lV and:vars.rV equal:vars.boolVar]];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_model addConstraint:[ORFactory model:_model boolean:vars.lV imply:vars.rV equal:vars.boolVar]];
}
-(void) visitIntVar: (id<ORIntVar>) e      {}
-(void) visitIntegerI: (id<ORInteger>) e   {}
-(void) visitExprPlusI: (ORExprPlusI*) e   {}
-(void) visitExprMinusI: (ORExprMinusI*) e {}
-(void) visitExprMulI: (ORExprMulI*) e     {}
-(void) visitExprModI: (ORExprModI*) e     {}
-(void) visitExprSumI: (ORExprSumI*) e     {}
-(void) visitExprProdI: (ORExprProdI*) e   {}
-(void) visitExprAggOrI: (ORExprAggOrI*) e {}
-(void) visitExprAbsI:(ORExprAbsI*) e      {}
-(void) visitExprNegateI:(ORExprNegateI*)e {}
-(void) visitExprCstSubI:(ORExprCstSubI*)e {}
-(void) visitExprVarSubI:(ORExprVarSubI*)e {}
@end

@implementation ORLinearizer
-(id)initORLinearizer:(id<ORLinear>)t model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x annotation:(ORAnnotation)n
{
   self = [super init];
   _terms = t;
   _model = model;
   _n     = n;
   _eqto  = x;
   return self;
}
-(id)initORLinearizer:(id<ORLinear>)t model:(id<ORAddToModel>)model annotation:(ORAnnotation)n
{
   self = [super init];
   _terms = t;
   _model = model;
   _n     = n;
   _eqto  = nil;
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
-(void) visitAffineVar:(id<ORIntVar>)e
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
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   if (_eqto) {
      id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
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
      id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      [[e left] visit:self];
      id<ORLinear> old = _terms;
      _terms = [[ORLinearFlip alloc] initORLinearFlip: _terms];
      [[e right] visit:self];
      [_terms release];
      _terms = old;
   }
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   if (_eqto) {
      id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
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
         id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:[e right] annotation:_n];
         [_terms addTerm:alpha by:[[e left] min]];
      } else if ([[e right] isConstant]) {
         ORLinear* left = [ORLinearizer linearFrom:[e left] model:_model annotation:_n];
         [left scaleBy:[[e right] min]];
         [_terms addLinear:left];
         //id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:[e left] annotation:_n];
         //[_terms addTerm:alpha by:[[e right] min]];
      } else {
         id<ORIntVar> alpha =  [ORSubst substituteIn:_model expr:e annotation:_n];
         [_terms addTerm:alpha by:1];
      }
   }
}
-(void) visitExprModI: (ORExprModI*) e
{
   id<ORIntVar> alpha =  [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNegateI:(ORExprNegateI*) e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggOrI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
   [_terms addTerm:alpha by:1];
}
+(ORLinear*)linearFrom:(ORExprI*)e model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x annotation:(ORAnnotation)cons
{
   ORLinear* rv = [[ORLinear alloc] initORLinear:4];
   ORLinearizer* v = [[ORLinearizer alloc] initORLinearizer:rv model: model  equalTo:x annotation:cons];
   [e visit:v];
   [v release];
   return rv;
}
+(ORLinear*)linearFrom:(ORExprI*)e model:(id<ORAddToModel>)model annotation:(ORAnnotation)cons
{
   ORLinear* rv = [[ORLinear alloc] initORLinear:4];
   ORLinearizer* v = [[ORLinearizer alloc] initORLinearizer:rv model: model annotation:cons];
   [e visit:v];
   [v release];
   return rv;
}
+(ORLinear*)addToLinear:(id<ORLinear>)terms from:(ORExprI*)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)cons
{
   ORLinearizer* v = [[ORLinearizer alloc] initORLinearizer:terms model: model annotation:cons];
   [e visit:v];
   [v release];
   return terms;
}
@end

@implementation ORLinear
-(ORLinear*)initORLinear:(ORInt)mxs
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

-(void)addLinear:(ORLinear*)lts
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
-(BOOL)allPositive
{
   BOOL ap = YES;
   for(ORInt k=0;k<_nb;k++)
      ap &= _terms[k]._coef > 0;
   return ap;
}
-(BOOL)allNegative
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
int decCoef(const struct CPTerm* t1,const struct CPTerm* t2)
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
-(id<ORIntVarArray>)scaledViews:(id<ORAddToModel>)model
{
   id<ORIntVarArray> sx = [ORFactory intVarArray:model
                                           range:RANGE(model,0,_nb-1)
                                            with:^id<ORIntVar>(ORInt i) {
      id<ORIntVar> xi = _terms[i]._var;
      id<ORIntVar> theView = [ORFactory intVar:model var:xi  scale:_terms[i]._coef];
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
      ORLong vlb = [_terms[k]._var min];
      ORLong vub = [_terms[k]._var max];
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
      ORLong vlb = [_terms[k]._var min];
      ORLong vub = [_terms[k]._var max];
      ORLong svub = c > 0 ? vub * c : vlb * c;
      ub += svub;
   }
   return min(MAXINT,bindUp(ub));
}

-(void)postNEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons
{
   switch(_nb) {
      case 0: assert(NO);return;
      case 1: {
         if (_terms[0]._coef == 1) {
            [model addConstraint:[ORFactory notEqualc:model var:_terms[0]._var to:- _indep]];
         } else if (_terms[0]._coef == -1) {
            [model addConstraint:[ORFactory notEqualc:model var:_terms[0]._var to:_indep]];
         } else {
            assert(_terms[0]._coef != 0);
            ORInt nc = - _indep / _terms[0]._coef;
            ORInt cr = - _indep % _terms[0]._coef;
            if (cr == 0)
               [model addConstraint:[ORFactory notEqualc:model var:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            return [model addConstraint:[ORFactory notEqual:model var:_terms[0]._var to:_terms[1]._var plus:-_indep]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1) {
            return [model addConstraint:[ORFactory notEqual:model var:_terms[1]._var to:_terms[0]._var plus:-_indep]];
         } else {
            id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
            id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef];
            [model addConstraint:[ORFactory notEqual:model var:xp to:yp plus:- _indep]];
         }
      }break;
      default: {
         ORInt lb = [self min];
         ORInt ub = [self max];
         id<ORIntVar> alpha = [ORFactory intVar:[_terms[0]._var tracker]
                                         domain:[ORFactory intRange:[_terms[0]._var tracker] low:lb up:ub]];
         [self addTerm:alpha by:-1];
         [model addConstraint:[ORFactory sum:model array:[self scaledViews:model] eqi:-_indep]];
         [model addConstraint:[ORFactory notEqualc:model var:alpha to:0]];
      }break;
   }
}
-(void)postEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons
{
   // [ldm] This should *never* raise an exception, but return a ORFailure.
   switch (_nb) {
      case 0:
         assert(NO);
         return;
      case 1: {
         if (_terms[0]._coef == 1) {
            return [model addConstraint:[ORFactory equalc:model var:_terms[0]._var to:-_indep]];
         } else if (_terms[0]._coef == -1) {
            return [model addConstraint:[ORFactory equalc:model var:_terms[0]._var to:_indep]];
         } else {
            assert(_terms[0]._coef != 0);
            ORInt nc = - _indep / _terms[0]._coef;
            ORInt cr = - _indep % _terms[0]._coef;
            if (cr != 0)
               [model addConstraint:[ORFactory fail:model]];
            else
               [model addConstraint:[ORFactory equalc:model var:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            [model addConstraint:[ORFactory equal:model var:_terms[0]._var to:_terms[1]._var plus:-_indep annotation:cons]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1) {
            [model addConstraint:[ORFactory equal:model var:_terms[1]._var to:_terms[0]._var plus:-_indep annotation:cons]];
         } else {
            id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
            id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef];
            [model addConstraint:[ORFactory equal:model var:xp to:yp plus:- _indep annotation:cons]];
         }
      }break;
      case 3: {
         ORInt np = [self nbPositive];
         if (np == 1 || np == 0) [self scaleBy:-1];
         assert([self nbPositive]>=2);
         [self positiveFirst];
         assert(_terms[0]._coef > 0 && _terms[1]._coef > 0);
         id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale: _terms[0]._coef  shift: _indep];
         id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale: _terms[1]._coef];
         id<ORIntVar> zp = [ORFactory intVar:model var:_terms[2]._var scale: - _terms[2]._coef];
         [model  addConstraint:[ORFactory equal3:model var:zp to:xp plus:yp annotation:cons]];
      }break;
      default: {
         ORInt sumCoefs = 0;
         for(ORInt k=0;k<_nb;k++)
            if ([_terms[k]._var isBool])
               sumCoefs += (_terms[k]._coef == 1);
         if (sumCoefs == _nb) {
            id<ORIntVarArray> boolVars = All(model,ORIntVar, i, RANGE(model,0,_nb-1), _terms[i]._var);
            [model addConstraint:[ORFactory sumbool:model array:boolVars eqi: - _indep]];
         }
         else
            [model addConstraint:[ORFactory sum:model array:[self scaledViews:model] eqi: - _indep]];
      }
   }
}
-(void)postLEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons
{
   switch(_nb) {
      case 0: assert(FALSE);return;
      case 1: {  // x <= c
         if (_terms[0]._coef == 1)
            return [model addConstraint: [ORFactory lEqualc:model var:_terms[0]._var to:- _indep]];
         else if (_terms[0]._coef == -1)
            return [model addConstraint: [ORFactory gEqualc:model var:_terms[0]._var to: _indep]];
         else {
            assert(_terms[0]._coef != 0);
            ORInt nc = - _indep / _terms[0]._coef;
            ORInt cr = - _indep % _terms[0]._coef;
            if (nc < 0 && cr != 0)
               [model addConstraint:[ORFactory lEqualc:model var:_terms[0]._var to:nc - 1]];
            else
               [model addConstraint:[ORFactory lEqualc:model var:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {  // x <= y
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            return [model addConstraint:[ORFactory lEqual:model var: _terms[0]._var to:_terms[1]._var plus:- _indep]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1  && _indep == 0) {
            return [model addConstraint:[ORFactory lEqual:model var: _terms[1]._var to:_terms[0]._var plus:- _indep]];
         } else {
            id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
            id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef shift:- _indep];
            [model addConstraint:[ORFactory lEqual:model var:xp to:yp]];
         }
      }break;
      default:
         [model addConstraint:[ORFactory sum:model array:[self scaledViews:model] leqi:- _indep]];
   }
}
@end

@implementation ORSubst

+(id<ORIntVar>) substituteIn:(id<ORAddToModel>) model expr:(ORExprI*)expr annotation:(ORAnnotation)c
{
   ORSubst* subst = [[ORSubst alloc] initORSubst: model annotation:c];
   [expr visit:subst];
   id<ORIntVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORIntVar>) substituteIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x annotation:(ORAnnotation)c
{
   ORSubst* subst = [[ORSubst alloc] initORSubst: model annotation:c by:x];
   [expr visit:subst];
   id<ORIntVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORIntVar>)normSide:(ORLinear*)e for:(id<ORAddToModel>)model annotation:(ORAnnotation)c
{
   if ([e size] == 1) {
      return [e oneView:model];
   } else {
      id<ORIntVar> xv = [ORFactory intVar: model domain: RANGE(model,[e min],[e max])];
      [e addTerm:xv by:-1];
      [e postEQZ: model annotation:c];
      return xv;
   }
}

-(id)initORSubst:(id<ORAddToModel>) model annotation: (ORAnnotation) c
{
   self = [super init];
   _rv = nil;
   _model = model;
   _c = c;
   return self;
}
-(id)initORSubst:(id<ORAddToModel>) model annotation:(ORAnnotation)c by:(id<ORIntVar>)x
{
   self = [super init];
   _rv  = x;
   _model = model;
   _c = c;
   return self;
}
-(id<ORIntVar>)result
{
   return _rv;
}
-(void) visitIntVar: (id<ORIntVar>) e
{
   if (_rv)
      [_model addConstraint:[ORFactory equal:_model var:_rv to:e plus:0]];
   else
      _rv = e;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (!_rv)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,[e value],[e value])];
   [_model addConstraint:[ORFactory equalc:_model var:_rv to:[e value]]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   ORLinear* terms = [ORLinearizer linearFrom:e model:_model annotation:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,max([terms min],MININT),min([terms max],MAXINT))];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model annotation:_c];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   ORLinear* terms = [ORLinearizer linearFrom:e model:_model annotation:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,max([terms min],MININT),min([terms max],MAXINT))];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model annotation:_c];
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   ORLinear* lT = [ORLinearizer linearFrom:[e left] model:_model annotation:_c];
   ORLinear* rT = [ORLinearizer linearFrom:[e right] model:_model annotation:_c];
   id<ORIntVar> lV = [ORSubst normSide:lT for:_model annotation:_c];
   id<ORIntVar> rV = [ORSubst normSide:rT for:_model annotation:_c];
   ORLong llb = [lV min];
   ORLong lub = [lV max];
   ORLong rlb = [rV min];
   ORLong rub = [rV max];
   ORLong a = minOf(llb * rlb,llb * rub);
   ORLong b = minOf(lub * rlb,lub * rub);
   ORLong lb = minOf(a,b);
   ORLong c = maxOf(llb * rlb,llb * rub);
   ORLong d = maxOf(lub * rlb,lub * rub);
   ORLong ub = maxOf(c,d);
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,bindDown(lb),bindUp(ub))];
   [_model addConstraint: [ORFactory mult:_model var:lV by:rV equal:_rv annotation:_c]];
   [lT release];
   [rT release];
}
-(void) visitExprModI:(ORExprModI *)e
{
   ORLinear* lT = [ORLinearizer linearFrom:[e left] model:_model annotation:_c];
   ORLinear* rT = [ORLinearizer linearFrom:[e right] model:_model annotation:_c];
   if ([rT size] == 0) {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain: RANGE(_model,[e min],[e max])];
      id<ORIntVar> lV = [ORSubst normSide:lT for:_model annotation:_c];
      [_model addConstraint:[ORFactory mod:_model var:lV modi:[rT independent] equal:_rv]];
   } else {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain: RANGE(_model,[e min],[e max])];
      id<ORIntVar> lV = [ORSubst normSide:lT for:_model annotation:_c];
      id<ORIntVar> rV = [ORSubst normSide:rT for:_model annotation:_c];
      [_model addConstraint:[ORFactory mod:_model var:lV mod:rV equal:_rv]];
   }
   [lT release];
   [rT release];
}

#if  USEVIEWS==1
#define OLDREIFY 0
#else
#define OLDREIFY 1
#endif


-(void) reifyEQc:(ORExprI*)theOther constant:(ORInt)c
{
   ORLinear* linOther  = [ORLinearizer linearFrom:theOther model:_model annotation:_c];
   id<ORIntVar> theVar = [ORSubst normSide:linOther for:_model annotation:_c];
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
-(void) reifyNEQc:(ORExprI*)theOther constant:(ORInt)c
{
   ORLinear* linOther  = [ORLinearizer linearFrom:theOther model:_model annotation:_c];
   id<ORIntVar> theVar = [ORSubst normSide:linOther for:_model annotation:_c];   
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [ORFactory intVar:cp domain:RANGE(cp,0,1)];
   [_model addConstraint: [ORFactory reify:_model boolean:_rv with:theVar neqi:c]];
}
-(void) reifyLEQc:(ORExprI*)theOther constant:(ORInt)c
{
   ORLinear* linOther  = [ORLinearizer linearFrom:theOther model:_model annotation:_c];
   id<ORIntVar> theVar = [ORSubst normSide:linOther for:_model annotation:_c];
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [ORFactory intVar:cp domain:RANGE(cp,0,1)];
   [_model addConstraint: [ORFactory reify:_model boolean:_rv with:theVar leqi:c]];
}
-(void) reifyGEQc:(ORExprI*)theOther constant:(ORInt)c
{
   ORLinear* linOther  = [ORLinearizer linearFrom:theOther model:_model annotation:_c];
   id<ORIntVar> theVar = [ORSubst normSide:linOther for:_model annotation:_c];
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [ORFactory intVar:cp domain:RANGE(cp,0,1)];
   [_model addConstraint: [ORFactory reify:_model boolean:_rv with:theVar geqi:c]];
}
-(void) reifyLEQ:(ORExprI*)left right:(ORExprI*)right
{
   ORLinear* linLeft   = [ORLinearizer linearFrom:left model:_model annotation:_c];
   ORLinear* linRight  = [ORLinearizer linearFrom:right model:_model annotation:_c];
   id<ORIntVar> varLeft  = [ORSubst normSide:linLeft for:_model annotation:_c];
   id<ORIntVar> varRight = [ORSubst normSide:linRight for:_model annotation:_c];
   id<ORTracker> cp = [varLeft tracker];
   if (_rv==nil)
      _rv = [ORFactory intVar:cp domain:RANGE(cp,0,1)];
   [_model addConstraint: [ORFactory reify:_model boolean:_rv with:varLeft leq:varRight]];
}

-(void) visitExprEqualI:(ORExprEqualI*)e
{
   if ([[e left] isConstant] && [[e right] isVariable]) {
      [self reifyEQc:[e right] constant:[[e left] min]];
   } else if ([[e right] isConstant] && [[e left] isVariable]) {
      [self reifyEQc:[e left] constant:[[e right] min]];
   } else {
      ORLinear* linLeft  = [ORLinearizer linearFrom:[e left] model:_model annotation:_c];
      ORLinear* linRight = [ORLinearizer linearFrom:[e right] model:_model annotation:_c];
      id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model annotation:_c];
      id<ORIntVar> rV = [ORSubst normSide:linRight for:_model annotation:_c];
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
      [_model addConstraint:[ORFactory reify:_model boolean:_rv with:lV eq:rV annotation:_c]];
   }
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   if ([[e left] isConstant] && [[e right] isVariable]) {
      [self reifyNEQc:[e right] constant:[[e left] min]];
   } else if ([[e right] isConstant] && [[e left] isVariable]) {
      [self reifyNEQc:[e left] constant:[[e right] min]];
   } else assert(NO);
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   if ([[e left] isConstant]) {
      [self reifyGEQc:[e right] constant:[[e left] min]];
   } else if ([[e right] isConstant]) {
      [self reifyLEQc:[e left] constant:[[e right] min]];
   } else
      [self reifyLEQ:[e left] right:[e right]];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   ORLinear* linLeft  = [ORLinearizer linearFrom:[e left] model:_model annotation:_c];
   ORLinear* linRight = [ORLinearizer linearFrom:[e right] model:_model annotation:_c];
   id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model annotation:_c];
   id<ORIntVar> rV = [ORSubst normSide:linRight for:_model annotation:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model addConstraint:[ORFactory model:_model boolean:lV or:rV equal:_rv]];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   ORLinear* linLeft  = [ORLinearizer linearFrom:[e left] model:_model annotation:_c];
   ORLinear* linRight = [ORLinearizer linearFrom:[e right] model:_model annotation:_c];
   id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model annotation:_c];
   id<ORIntVar> rV = [ORSubst normSide:linRight for:_model annotation:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model addConstraint:[ORFactory model:_model boolean:lV and:rV equal:_rv]];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   ORLinear* linLeft  = [ORLinearizer linearFrom:[e left] model:_model annotation:_c];
   ORLinear* linRight = [ORLinearizer linearFrom:[e right] model:_model annotation:_c];
   id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model annotation:_c];
   id<ORIntVar> rV = [ORSubst normSide:linRight for:_model annotation:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model addConstraint:[ORFactory model:_model boolean:lV imply:rV equal:_rv]];
}

-(void) visitExprAbsI:(ORExprAbsI *)e
{
   ORLinear* lT = [ORLinearizer linearFrom:[e operand] model:_model annotation:_c];
   id<ORIntVar> oV = [ORSubst normSide:lT for:_model annotation:_c];
   ORInt lb = [lT min];
   ORInt ub = [lT max];
   if (_rv == nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,lb,ub)];
   [_model addConstraint:[ORFactory abs:_model var:oV equal:_rv annotation:_c]];
   [lT release];
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
   ORLinear* lT = [ORLinearizer linearFrom:[e operand] model:_model annotation:_c];
   id<ORIntVar> oV = [ORSubst normSide:lT for:_model annotation:_c];
   if (_rv == nil)
      _rv = [ORFactory intVar:_model var:oV scale:-1 shift:1];
   else {
      id<ORIntVar> fV = [ORFactory intVar:_model var:oV scale:-1 shift:1];
      [_model addConstraint:[ORFactory equal:_model var:_rv to:fV plus:0 annotation:_c]];
   }
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   ORLinear* lT = [ORLinearizer linearFrom:[e index] model:_model annotation:_c];
   id<ORIntVar> oV = [ORSubst normSide:lT for:_model annotation:_c];
   ORInt lb = [e min];
   ORInt ub = [e max];
   if (_rv == nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,lb,ub)];
   [_model addConstraint:[ORFactory element:_model var:oV idxCstArray:[e array] equal:_rv annotation:_c]];
   [lT release];
}

-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   ORLinear* lT = [ORLinearizer linearFrom:[e index] model:_model annotation:_c];
   id<ORIntVar> oV = [ORSubst normSide:lT for:_model annotation:_c];
   ORInt lb = [e min];
   ORInt ub = [e max];
   if (_rv == nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,lb,ub)];
   [_model addConstraint:[ORFactory element:_model var:oV idxVarArray: [e array] equal:_rv annotation:_c]];
   [lT release];
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
@end
