/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/
#import "ORDecompose.h"
#import "ORModeling/ORModeling.h"

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
-(void) visitFloatI: (id<ORFloatNumber>) e   {}
-(void) visitExprPlusI: (ORExprPlusI*) e   {}
-(void) visitExprMinusI: (ORExprMinusI*) e {}
-(void) visitExprMulI: (ORExprMulI*) e     {}
-(void) visitExprDivI: (ORExprDivI*) e     {}
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
{
   id<ORLinear>   _terms;
   id<ORAddToModel>    _model;
   ORAnnotation       _n;
   id<ORIntVar>       _eqto;
}

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
-(void) visitFloatI: (id<ORFloatNumber>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer expression and encountering a FloatNumber"];
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
-(void) visitExprDivI:(ORExprDivI *)e
{
   if (_eqto) {
      id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e by:_eqto annotation:_n];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORIntVar> alpha = [ORSubst substituteIn:_model expr:e annotation:_n];
      [_terms addTerm:alpha by:1];
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
-(void) visitFloatI: (id<ORFloatNumber>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer expression and encountering a FloatNumber"];   
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
static inline ORLong minSeq(ORLong v[4])  {
   ORLong min = MAXINT;
   for(int i=0;i<4;i++)
      min = min > v[i] ? v[i] : min;
   return min;
}
static inline ORLong maxSeq(ORLong v[4])  {
   ORLong mx = MININT;
   for(int i=0;i<4;i++)
      mx = mx < v[i] ? v[i] : mx;
   return mx;
}
-(void) visitExprDivI: (ORExprDivI*) e
{
   /*
   ORLinear* lT = [ORLinearizer linearFrom:[e left] model:_model annotation:_c];
   ORLinear* rT = [ORLinearizer linearFrom:[e right] model:_model annotation:_c];
   id<ORIntVar> lV = [ORSubst normSide:lT for:_model annotation:_c];
   id<ORIntVar> rV = [ORSubst normSide:rT for:_model annotation:_c];
   
   if ([lT size] == 0) {  // z ==  c / y
      id<ORIntVar> y = [ORSubst normSide:rT for:_model annotation:_c];
      ORInt c = [lT independent];
      ORLong yMin = y.min == 0 ? 1  : y.min;
      ORLong yMax = y.max == 0 ? -1 : y.max;
      ORLong vals[4] = {c/yMin,c/yMax,-c,c};
      int low = bindDown(minSeq(vals));
      int up  = bindUp(maxSeq(vals));
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain: RANGE(_model,bindDown(low),bindUp(up))];
      if(c)
         [_model addConstraint:[ORFactory expr:_rv neq:[ORFactory integer:_model value:0]]];
      [_model addConstraint:[[_rv mul:y] eqi:c]];
   }
   else if ([rT size] == 0) { // z == x / c
      id<ORIntVar> x = [ORSubst normSide:lT for:_model annotation:_c];
      ORInt c = [rT independent];
      if (c==0)
         [_model addConstraint:[ORFactory fail:_model]];
      
      int xMin = x->getIMin();
      int xMax = x->getIMax();
      int low,up;
      if (c > 0) {
         low = xMin / c;
         up  = xMax / c;
      } else {
         low = xMax / c;
         up  = xMin / c;
      }
      CotCPIntVarI* rem  = _mgr->adaptiveCreateIntVariable(-c+1,c-1);
      CotCPIntVarI* prod = _mgr->adaptiveCreateIntVariable(c*low,c*up);
      CotCPIntVarI* z = hasContext() ?
      topContext() : _mgr->adaptiveCreateIntVariable(low,up);
      setSuccess(_mgr->post(cf.mod(x,c,rem)));
      setSuccess(_mgr->post(cf.mul(z,c,prod)));
      setSuccess(_mgr->post(cf.equalTern(prod,rem,x)));
      if (!_term) _term = new (_alloc) ColCPlinearTerm(_alloc,1);
      _term->addTerm(1,z);
   }
   else {
      CotCPIntVarI *v1 = postEqualToVar(tl);
      CotCPIntVarI *v2 = postEqualToVar(tr);
      sint64 v1Min = v1->getIMin();
      sint64 v1Max = v1->getIMax();
      sint64 yp = v2->getIMin() == 0 ? v2->after(0)  : v2->getIMin();
      sint64 ym = v2->getIMax() == 0 ? v2->before(0) : v2->getIMax();
      
      sint64 mxvals[4] = { v1Min/yp,v1Min/ym,v1Max/yp,v1Max/ym};
      int low = CotCP::bindDown(minSeq(mxvals,4));
      int up  = CotCP::bindUp(maxSeq(mxvals,4));
      sint64 pxvals[4] = { low * v2->getMin(),low * v2->getMax(), up * v2->getMin(), up * v2->getMax()};
      int pxlow = CotCP::bindDown(minSeq(pxvals,4));
      int pxup  = CotCP::bindUp(maxSeq(pxvals,4));
      int rb = max(abs(yp),abs(ym))-1;
      CotCPIntVarI* rem  = _mgr->adaptiveCreateIntVariable(-rb,rb);
      CotCPIntVarI* prod = _mgr->adaptiveCreateIntVariable(pxlow,pxup);
      CotCPIntVarI* z = hasContext() ?
      topContext() : _mgr->adaptiveCreateIntVariable(low,up);
      setSuccess(_mgr->post(cf.mod(v1,v2,rem)));
      setSuccess(_mgr->post(cf.nequalCst(v2,0)));
      setSuccess(_mgr->post(cf.mul(z,v2,prod)));
      setSuccess(_mgr->post(cf.equalTern(prod,rem,v1)));
      if (!_term) _term = new (_alloc) ColCPlinearTerm(_alloc,1);
      _term->addTerm(1,z);
   }
   
   [lT release];
   [rT release];
    */
}

-(void) visitExprModI:(ORExprModI *)e
{
   ORLinear* lT = [ORLinearizer linearFrom:[e left] model:_model annotation:_c];
   ORLinear* rT = [ORLinearizer linearFrom:[e right] model:_model annotation:_c];
   if ([rT size] == 0) {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain: RANGE(_model,[e min],[e max])];
      id<ORIntVar> lV = [ORSubst normSide:lT for:_model annotation:_c];
      [_model addConstraint:[ORFactory mod:_model var:lV modi:[rT independent] equal:_rv annotation:_c]];
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
