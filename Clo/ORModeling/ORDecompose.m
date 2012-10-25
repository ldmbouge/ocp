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
   id<ORModel>    _model;
   ORAnnotation       _c;
}
-(id)initORSubst:(id<ORModel>) model note:(ORAnnotation)c;
-(id)initORSubst:(id<ORModel>) model note:(ORAnnotation)c by:(id<ORIntVar>)x;
-(id<ORIntVar>)result;
-(void) visitIntVar: (id<ORIntVar>) e;
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprAggOrI: (ORExprAggOrI*) e;
-(void) visitExprAbsI:(ORExprAbsI *)e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(ORExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
+(id<ORIntVar>) substituteIn:(id<ORModel>) model expr:(ORExprI*)expr note:(ORAnnotation)c;
+(id<ORIntVar>) substituteIn:(id<ORModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x note:(ORAnnotation)c;
+(id<ORIntVar>)normSide:(ORLinear*)e for:(id<ORModel>) model note:(ORAnnotation)c;
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
@end


@interface ORLinearizer : NSObject<ORVisitor> {
   id<ORLinear>   _terms;
   id<ORModel>    _model;
   ORAnnotation       _n;
}
-(id)initORLinearizer:(id<ORLinear>)t model:(id<ORModel>)model note:(ORAnnotation)n;
+(ORLinear*)linearFrom:(id<ORExpr>)e  model:(id<ORModel>)model note:(ORAnnotation)n;
+(ORLinear*)addToLinear:(id<ORLinear>)terms from:(id<ORExpr>)e  model:(id<ORModel>)model note:(ORAnnotation)n;
-(void) visitIntVar: (id<ORIntVar>) e;
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprAggOrI: (ORExprAggOrI*) e;
-(void) visitExprAbsI:(ORExprAbsI*) e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(ORExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
@end

@implementation ORNormalizer
+(ORLinear*)normalize:(ORExprI*)rel into:(id<ORModel>) model note:(ORAnnotation)n
{
   ORNormalizer* v = [[ORNormalizer alloc] initORNormalizer: model note:n];
   [rel visit:v];
   ORLinear* rv = v->_terms;
   [v release];
   return rv;
}
-(id)initORNormalizer:(id<ORModel>) model note:(ORAnnotation)n
{
   self = [super init];
   _terms = nil;
   _model = model;
   _n = n;
   return self;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   ORLinear* linLeft = [ORLinearizer linearFrom:[e left] model:_model note:_n];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORLinearizer addToLinear:linRight from:[e right] model:_model note:_n];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   ORLinear* linLeft = [ORLinearizer linearFrom:[e left] model:_model note:_n];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORLinearizer addToLinear:linRight from:[e right] model:_model note:_n];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   ORLinear* linLeft = [ORLinearizer linearFrom:[e left] model:_model note:_n];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORLinearizer addToLinear:linRight from:[e right] model:_model note:_n];
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
   ORLinear* linLeft  = [ORLinearizer linearFrom:l model:_model note:_n];
   ORLinear* linRight = [ORLinearizer linearFrom:r model:_model note:_n];
   id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model note:_n];
   id<ORIntVar> rV = [ORSubst normSide:linRight for:_model note:_n];
   id<ORIntVar> final = [ORFactory intVar: _model domain:RANGE(_model,0,1)];
   [_model add:[ORFactory equalc:_model var:final to:1]];
   return (struct CPVarPair){lV,rV,final};
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_model add:[ORFactory model:_model boolean:vars.lV or:vars.rV equal:vars.boolVar]];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_model add:[ORFactory model:_model boolean:vars.lV and:vars.rV equal:vars.boolVar]];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_model add:[ORFactory model:_model boolean:vars.lV imply:vars.rV equal:vars.boolVar]];
}
-(void) visitIntVar: (id<ORIntVar>) e      {}
-(void) visitIntegerI: (id<ORInteger>) e   {}
-(void) visitExprPlusI: (ORExprPlusI*) e   {}
-(void) visitExprMinusI: (ORExprMinusI*) e {}
-(void) visitExprMulI: (ORExprMulI*) e     {}
-(void) visitExprSumI: (ORExprSumI*) e     {}
-(void) visitExprAggOrI: (ORExprAggOrI*) e {}
-(void) visitExprAbsI:(ORExprAbsI*) e      {}
-(void) visitExprCstSubI:(ORExprCstSubI*)e {}
-(void) visitExprVarSubI:(ORExprVarSubI*)e {}
@end

@implementation ORLinearizer
-(id)initORLinearizer:(id<ORLinear>)t model:(id<ORModel>)model note:(ORAnnotation)n
{
   self = [super init];
   _terms = t;
   _model = model;
   _n     = n;
   return self;
}
-(void) visitIntVar: (id<ORIntVar>) e
{
   [_terms addTerm:e by:1];
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   [_terms addIndependent:[e value]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   [[e left] visit:self];
   id<ORLinear> old = _terms;
   _terms = [[ORLinearFlip alloc] initORLinearFlip: _terms];
   [[e right] visit:self];
   [_terms release];
   _terms = old;
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   BOOL cv = [[e left] isConstant] && [[e right] isVariable];
   BOOL vc = [[e left] isVariable] && [[e right] isConstant];
   if (cv || vc) {
      ORInt coef = cv ? [[e left] min] : [[e right] min];
      id       x = cv ? [e right] : [e left];
      [_terms addTerm:x by:coef];
   } else if ([[e left] isConstant]) {
      id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:[e right] note:_n];
      [_terms addTerm:alpha by:[[e left] min]];
   } else if ([[e right] isConstant]) {
      id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:[e left] note:_n];
      [_terms addTerm:alpha by:[[e right] min]];
   } else {
      id<ORIntVar> alpha =  [ORSubst substituteIn:_model expr:e note:_n];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggOrI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e note:_n];
   [_terms addTerm:alpha by:1];
}

+(ORLinear*)linearFrom:(ORExprI*)e model:(id<ORModel>)model note:(ORAnnotation)cons
{
   ORLinear* rv = [[ORLinear alloc] initORLinear:4];
   ORLinearizer* v = [[ORLinearizer alloc] initORLinearizer:rv model: model note:cons];
   [e visit:v];
   [v release];
   return rv;
}
+(ORLinear*)addToLinear:(id<ORLinear>)terms from:(ORExprI*)e  model:(id<ORModel>)model note:(ORAnnotation)cons
{
   ORLinearizer* v = [[ORLinearizer alloc] initORLinearizer:terms model: model note:cons];
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
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:128] autorelease];
   for(ORInt k=0;k<_nb;k++) {
      [buf appendFormat:@"(%d * %@) + ",_terms[k]._coef,[_terms[k]._var description]];
   }
   [buf appendFormat:@" (%d)",_indep];
   return buf;
}
-(id<ORIntVarArray>)scaledViews:(id<ORModel>)model
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
-(id<ORIntVar>)oneView:(id<ORModel>)model
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

-(void)postNEQZ:(id<ORModel>)model note:(ORAnnotation)cons
{
   switch(_nb) {
      case 0: assert(NO);return;
      case 1: {
         if (_terms[0]._coef == 1) {
            [model add:[ORFactory notEqualc:model var:_terms[0]._var to:- _indep]];
         } else if (_terms[0]._coef == -1) {
            [model add:[ORFactory notEqualc:model var:_terms[0]._var to:_indep]];
         } else {
            assert(_terms[0]._coef != 0);
            ORInt nc = - _indep / _terms[0]._coef;
            ORInt cr = - _indep % _terms[0]._coef;
            if (cr == 0)
               [model add:[ORFactory notEqualc:model var:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            return [model add:[ORFactory notEqual:model var:_terms[0]._var to:_terms[1]._var plus:-_indep]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1) {
            return [model add:[ORFactory notEqual:model var:_terms[1]._var to:_terms[0]._var plus:-_indep]];
         } else {
            id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
            id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef];
            [model add:[ORFactory notEqual:model var:xp to:yp plus:- _indep]];
         }
      }break;
      default: {
         ORInt lb = [self min];
         ORInt ub = [self max];
         id<ORIntVar> alpha = [ORFactory intVar:[_terms[0]._var tracker]
                                         domain:[ORFactory intRange:[_terms[0]._var tracker] low:lb up:ub]];
         [self addTerm:alpha by:-1];
         [model add:[ORFactory sum:model array:[self scaledViews:model] eqi:-_indep]];
         [model add:[ORFactory notEqualc:model var:alpha to:0]];
      }break;
   }
}
-(void)postEQZ:(id<ORModel>)model note:(ORAnnotation)cons
{
   // [ldm] This should *never* raise an exception, but return a ORFailure.
   switch (_nb) {
      case 0:
         assert(NO);
         return;
      case 1: {
         if (_terms[0]._coef == 1) {
            return [model add:[ORFactory equalc:model var:_terms[0]._var to:-_indep]];
         } else if (_terms[0]._coef == -1) {
            return [model add:[ORFactory equalc:model var:_terms[0]._var to:_indep]];
         } else {
            assert(_terms[0]._coef != 0);
            ORInt nc = - _indep / _terms[0]._coef;
            ORInt cr = - _indep % _terms[0]._coef;
            if (cr != 0)
               [model add:[ORFactory fail:model]];
            else
               [model add:[ORFactory equalc:model var:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            [model add:[ORFactory equal:model var:_terms[0]._var to:_terms[1]._var plus:-_indep note:cons]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1) {
            [model add:[ORFactory equal:model var:_terms[1]._var to:_terms[0]._var plus:-_indep note:cons]];
         } else {
            id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
            id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef];
            [model add:[ORFactory equal:model var:xp to:yp plus:- _indep note:cons]];
         }
      }break;
      case 3: {
         if (_terms[0]._coef * _terms[1]._coef * _terms[2]._coef == -1) { // odd number of negative coefs (4 cases)
            if (_terms[0]._coef + _terms[1]._coef + _terms[2]._coef == -3) { // all 3 negative
               id<ORIntVar> zp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef shift: _indep];
               return [model add:[ORFactory equal3:model var:zp to:_terms[1]._var plus:_terms[2]._var note:cons]];
            } else { // exactly 1 negative coef
               ORInt nc = _terms[0]._coef == -1 ? 0 : (_terms[1]._coef == -1 ? 1 : 2);
               ORInt pc[3] = {0,1,2};
               for(ORUInt i=0;i<3;i++)
                  if (pc[i] == nc)
                     pc[i] = pc[2];
               id<ORIntVar> zp = [ORFactory intVar:model var:_terms[nc]._var scale:1 shift:-_indep];
               [model add:[ORFactory equal3:model var:zp to:_terms[pc[0]]._var plus:_terms[pc[1]]._var note:cons]];
            }
         } else {
            id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
            id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:_terms[1]._coef];
            id<ORIntVar> zp = [ORFactory intVar:model var:_terms[2]._var scale:- _terms[2]._coef shift:-_indep];
            [model add:[ORFactory equal3:model var:zp to:xp plus:yp note:cons]];
         }
      }break;
      default: {
         ORInt sumCoefs = 0;
         for(ORInt k=0;k<_nb;k++)
            if ([_terms[k]._var isBool])
               sumCoefs += (_terms[k]._coef == 1);
         if (sumCoefs == _nb) {
            id<ORIntVarArray> boolVars = All(model,ORIntVar, i, RANGE(model,0,_nb-1), _terms[i]._var);
            [model add:[ORFactory sumbool:model array:boolVars eqi: - _indep]];
         }
         else
            [model add:[ORFactory sum:model array:[self scaledViews:model] eqi: - _indep]];
      }
   }
}
-(void)postLEQZ:(id<ORModel>)model note:(ORAnnotation)cons
{
   switch(_nb) {
      case 0: assert(FALSE);return;
      case 1: {  // x <= c
         if (_terms[0]._coef == 1)
            return [model add: [ORFactory lEqualc:model var:_terms[0]._var to:- _indep]];
         else if (_terms[0]._coef == -1)
            return [model add: [ORFactory lEqualc:model var:_terms[0]._var to: _indep]];
         else {
            assert(_terms[0]._coef != 0);
            ORInt nc = - _indep / _terms[0]._coef;
            ORInt cr = - _indep % _terms[0]._coef;
            if (nc < 0 && cr != 0)
               [model add:[ORFactory lEqualc:model var:_terms[0]._var to:nc - 1]];
            else
               [model add:[ORFactory lEqualc:model var:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {  // x <= y
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            return [model add:[ORFactory lEqual:model var: _terms[0]._var to:_terms[1]._var plus:- _indep]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1  && _indep == 0) {
            return [model add:[ORFactory lEqual:model var: _terms[1]._var to:_terms[0]._var plus:- _indep]];
         } else {
            id<ORIntVar> xp = [ORFactory intVar:model var:_terms[0]._var scale:_terms[0]._coef];
            id<ORIntVar> yp = [ORFactory intVar:model var:_terms[1]._var scale:- _terms[1]._coef shift:- _indep];
            [model add:[ORFactory lEqual:model var:xp to:yp]];
         }
      }break;
      default:
         [model add:[ORFactory sum:model array:[self scaledViews:model] leqi:- _indep]];
   }
}
@end

@implementation ORSubst

+(id<ORIntVar>) substituteIn:(id<ORModel>) model expr:(ORExprI*)expr note:(ORAnnotation)c
{
   ORSubst* subst = [[ORSubst alloc] initORSubst: model note:c];
   [expr visit:subst];
   id<ORIntVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORIntVar>) substituteIn:(id<ORModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x note:(ORAnnotation)c
{
   ORSubst* subst = [[ORSubst alloc] initORSubst: model note:c by:x];
   [expr visit:subst];
   id<ORIntVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORIntVar>)normSide:(ORLinear*)e for:(id<ORModel>)model note:(ORAnnotation)c
{
   if ([e size] == 1) {
      return [e oneView:model];
   } else {
      id<ORIntVar> xv = [ORFactory intVar: model domain: RANGE(model,[e min],[e max])];
      [e addTerm:xv by:-1];
      [e postEQZ: model note:c];
      return xv;
   }
}

-(id)initORSubst:(id<ORModel>) model note: (ORAnnotation) c
{
   self = [super init];
   _rv = nil;
   _model = model;
   _c = c;
   return self;
}
-(id)initORSubst:(id<ORModel>) model note:(ORAnnotation)c by:(id<ORIntVar>)x
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
      [_model add:[ORFactory equal:_model var:_rv to:e plus:0]];
   else
      _rv = e;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   id<ORTracker> cp = [e tracker];
   if (!_rv)
      _rv = [ORFactory intVar:cp domain: RANGE(cp,[e value],[e value])];
   [_model add:[ORFactory equalc:_model var:_rv to:[e value]]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   ORLinear* terms = [ORLinearizer linearFrom:e model:_model note:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:[e tracker] domain: RANGE(_model,max([terms min],MININT),min([terms max],MAXINT))];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model note:_c];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   ORLinear* terms = [ORLinearizer linearFrom:e model:_model note:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:[e tracker] domain: RANGE(_model,max([terms min],MININT),min([terms max],MAXINT))];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model note:_c];
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   id<ORTracker> cp = [e tracker];
   ORLinear* lT = [ORLinearizer linearFrom:[e left] model:_model note:_c];
   ORLinear* rT = [ORLinearizer linearFrom:[e right] model:_model note:_c];
   id<ORIntVar> lV = [ORSubst normSide:lT for:_model note:_c];
   id<ORIntVar> rV = [ORSubst normSide:rT for:_model note:_c];
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
      _rv = [ORFactory intVar:cp domain: RANGE(cp,bindDown(lb),bindUp(ub))];
   [_model add: [ORFactory mult:_model var:lV by:rV equal:_rv]];
   [lT release];
   [rT release];
}
#define OLDREIFY 0
-(void) reifyEQc:(ORExprI*)theOther constant:(ORInt)c
{
   ORLinear* linOther  = [ORLinearizer linearFrom:theOther model:_model note:_c];
   id<ORIntVar> theVar = [ORSubst normSide:linOther for:_model note:_c];
#if OLDREIFY==1
   if (_rv==nil) {
      _rv = [ORFactory intVar:_model domain: RANGE(_model,0,1)];
   }
   [_model add: [ORFactory reify:_rv with:theVar eqi:c]];
#else
   if (_rv != nil) {
      [_model add: [ORFactory reify:_model boolean:_rv with:theVar eqi:c]];
   } else {
      _rv = [ORFactory reifyView:_model var:theVar eqi:c];
   }
#endif
}
-(void) reifyNEQc:(ORExprI*)theOther constant:(ORInt)c
{
   ORLinear* linOther  = [ORLinearizer linearFrom:theOther model:_model note:_c];
   id<ORIntVar> theVar = [ORSubst normSide:linOther for:_model note:_c];   
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [ORFactory intVar:cp domain:RANGE(cp,0,1)];
   [_model add: [ORFactory reify:_model boolean:_rv with:theVar neqi:c]];
}
-(void) reifyLEQc:(ORExprI*)theOther constant:(ORInt)c
{
   ORLinear* linOther  = [ORLinearizer linearFrom:theOther model:_model note:_c];
   id<ORIntVar> theVar = [ORSubst normSide:linOther for:_model note:_c];
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [ORFactory intVar:cp domain:RANGE(cp,0,1)];
   [_model add: [ORFactory reify:_model boolean:_rv with:theVar leqi:c]];
}
-(void) reifyGEQc:(ORExprI*)theOther constant:(ORInt)c
{
   ORLinear* linOther  = [ORLinearizer linearFrom:theOther model:_model note:_c];
   id<ORIntVar> theVar = [ORSubst normSide:linOther for:_model note:_c];
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [ORFactory intVar:cp domain:RANGE(cp,0,1)];
   [_model add: [ORFactory reify:_model boolean:_rv with:theVar geqi:c]];
}

-(void) visitExprEqualI:(ORExprEqualI*)e
{
   if ([[e left] isConstant] && [[e right] isVariable]) {
      [self reifyEQc:[e right] constant:[[e left] min]];
   } else if ([[e right] isConstant] && [[e left] isVariable]) {
      [self reifyEQc:[e left] constant:[[e right] min]];
   } else {
      ORLinear* linLeft  = [ORLinearizer linearFrom:[e left] model:_model note:_c];
      ORLinear* linRight = [ORLinearizer linearFrom:[e right] model:_model note:_c];
      id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model note:_c];
      id<ORIntVar> rV = [ORSubst normSide:linRight for:_model note:_c];
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
      [_model add:[ORFactory reify:_model boolean:_rv with:lV eq:rV note:_c]];
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
   } else assert(NO);
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   ORLinear* linLeft  = [ORLinearizer linearFrom:[e left] model:_model note:_c];
   ORLinear* linRight = [ORLinearizer linearFrom:[e right] model:_model note:_c];
   id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model note:_c];
   id<ORIntVar> rV = [ORSubst normSide:linRight for:_model note:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model add:[ORFactory model:_model boolean:lV or:rV equal:_rv]];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   ORLinear* linLeft  = [ORLinearizer linearFrom:[e left] model:_model note:_c];
   ORLinear* linRight = [ORLinearizer linearFrom:[e right] model:_model note:_c];
   id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model note:_c];
   id<ORIntVar> rV = [ORSubst normSide:linRight for:_model note:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model add:[ORFactory model:_model boolean:lV and:rV equal:_rv]];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   ORLinear* linLeft  = [ORLinearizer linearFrom:[e left] model:_model note:_c];
   ORLinear* linRight = [ORLinearizer linearFrom:[e right] model:_model note:_c];
   id<ORIntVar> lV = [ORSubst normSide:linLeft  for:_model note:_c];
   id<ORIntVar> rV = [ORSubst normSide:linRight for:_model note:_c];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model add:[ORFactory model:_model boolean:lV imply:rV equal:_rv]];
}

-(void) visitExprAbsI:(ORExprAbsI *)e
{
   id<ORTracker> cp = [e tracker];
   ORLinear* lT = [ORLinearizer linearFrom:[e operand] model:_model note:_c];
   id<ORIntVar> oV = [ORSubst normSide:lT for:_model note:_c];
   ORInt lb = [lT min];
   ORInt ub = [lT max];
   if (_rv == nil)
      _rv = [ORFactory intVar:cp domain:RANGE(cp,lb,ub)];
   [_model add:[ORFactory abs:_model var:oV equal:_rv note:_c]];
   [lT release];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   id<ORTracker> cp = [e tracker];
   ORLinear* lT = [ORLinearizer linearFrom:[e index] model:_model note:_c];
   id<ORIntVar> oV = [ORSubst normSide:lT for:_model note:_c];
   ORInt lb = [e min];
   ORInt ub = [e max];
   if (_rv == nil)
      _rv = [ORFactory intVar:cp domain: RANGE(cp,lb,ub)];
   [_model add:[ORFactory element:_model var:oV idxCstArray:[e array] equal:_rv]];
   [lT release];
}

-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   id<ORTracker> cp = [e tracker];
   ORLinear* lT = [ORLinearizer linearFrom:[e index] model:_model note:_c];
   id<ORIntVar> oV = [ORSubst normSide:lT for:_model note:_c];
   ORInt lb = [e min];
   ORInt ub = [e max];
   if (_rv == nil)
      _rv = [ORFactory intVar:cp domain: RANGE(cp,lb,ub)];
   [_model add:[ORFactory element:_model var:oV idxVarArray: [e array] equal:_rv]];
   [lT release];
}

-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggOrI: (ORExprAggOrI*) e
{
   [[e expr] visit:self];
}
@end
