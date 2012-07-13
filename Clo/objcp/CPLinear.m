/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPLinear.h"
#import "CPExprI.h"
#import "CPIntVarI.h"
#import "CPSolverI.h"
#import <objcp/CPData.h>

@interface CPLinearFlip : NSObject<CPLinear> {
   id<CPLinear> _real;   
}
-(CPLinearFlip*)initCPLinearFlip:(id<CPLinear>)r;
-(void)setIndependent:(CPInt)idp;
-(void)addIndependent:(CPInt)idp;
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c;
@end


@interface CPSubst   : NSObject<CPExprVisitor> {
   id<CPIntVar>    _rv;
   id<CPSolver>   _fdm;
   CPConsistency    _c;
}
-(id)initCPSubst:(id<CPSolver>)fdm consistency:(CPConsistency)c;
-(id)initCPSubst:(id<CPSolver>)fdm consistency:(CPConsistency)c by:(id<CPIntVar>)x;
-(id<CPIntVar>)result;
-(void) visitIntVarI: (id<CPIntVar>) e;
-(void) visitIntegerI: (id<CPInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprAbsI:(ORExprAbsI *)e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(CPExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
+(id<CPIntVar>) substituteIn:(id<CPSolver>)fdm expr:(ORExprI*)expr consistency:(CPConsistency)c;
+(id<CPIntVar>) substituteIn:(id<CPSolver>)fdm expr:(ORExprI*)expr by:(id<CPIntVar>)x consistency:(CPConsistency)c;
+(id<CPIntVar>)normSide:(CPLinear*)e for:(id<CPSolver>)cp consistency:(CPConsistency)c;
@end

@implementation CPLinearFlip
-(CPLinearFlip*)initCPLinearFlip:(id<CPLinear>)r
{
   self = [super init];
   _real = r;
   return self;
}
-(void)setIndependent:(CPInt)idp
{
   [_real setIndependent:-idp];
}
-(void)addIndependent:(CPInt)idp
{
   [_real addIndependent:-idp];
}
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c
{
   [_real addTerm:x by:-c];
}
@end

@interface CPRNormalizer : NSObject<CPExprVisitor> {
   id<CPLinear> _terms;
   CPSolverI*     _fdm;
   CPConsistency _cons;
}
+(CPLinear*)normalize:(id<ORRelation>)rel solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
-(id)initCPRNormalizer:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitIntVarI: (CPIntVarI*) e;
-(void) visitIntegerI: (id<CPInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprAbsI:(ORExprAbsI*) e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(CPExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
@end

@interface CPLinearizer : NSObject<CPExprVisitor> {
   id<CPLinear> _terms;
   id<CPSolver>   _fdm;
   CPConsistency _cons;
}
+(CPLinear*)linearFrom:(id<ORExpr>)e  solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
+(CPLinear*)addToLinear:(id<CPLinear>)terms from:(id<ORExpr>)e  solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
-(id)initCPLinearizer:(id<CPLinear>)t solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
-(void) visitIntVarI: (CPIntVarI*) e;
-(void) visitIntegerI: (id<CPInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprAbsI:(ORExprAbsI*) e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(CPExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
@end

@implementation CPRNormalizer
+(CPLinear*)normalize:(ORExprI*)rel solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons
{
   CPRNormalizer* v = [[CPRNormalizer alloc] initCPRNormalizer:fdm consistency:cons];
   [rel visit:v];
   CPLinear* rv = v->_terms;
   [v release];
   return rv;
}
-(id)initCPRNormalizer:(CPSolverI*)fdm consistency:(CPConsistency)cons
{
   self = [super init];
   _terms = nil;
   _fdm = fdm;
   _cons = cons;
   return self;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   CPLinear* linLeft = [CPLinearizer linearFrom:[e left] solver:_fdm consistency:_cons];
   CPLinearFlip* linRight = [[CPLinearFlip alloc] initCPLinearFlip: linLeft];
   [CPLinearizer addToLinear:linRight from:[e right] solver:_fdm consistency:_cons];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   CPLinear* linLeft = [CPLinearizer linearFrom:[e left] solver:_fdm consistency:_cons];
   CPLinearFlip* linRight = [[CPLinearFlip alloc] initCPLinearFlip: linLeft];
   [CPLinearizer addToLinear:linRight from:[e right] solver:_fdm consistency:_cons];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   CPLinear* linLeft = [CPLinearizer linearFrom:[e left] solver:_fdm consistency:_cons];
   CPLinearFlip* linRight = [[CPLinearFlip alloc] initCPLinearFlip: linLeft];
   [CPLinearizer addToLinear:linRight from:[e right] solver:_fdm consistency:_cons];
   [linRight release];
   _terms = linLeft;
}
struct CPVarPair {
   id<CPIntVar> lV;
   id<CPIntVar> rV;
   id<CPIntVar> boolVar;
};
-(struct CPVarPair) visitLogical:(ORExprI*)l right:(ORExprI*)r
{
   CPLinear* linLeft  = [CPLinearizer linearFrom:l solver:_fdm consistency:_cons];
   CPLinear* linRight = [CPLinearizer linearFrom:r solver:_fdm consistency:_cons];
   id<CPIntVar> lV = [CPSubst normSide:linLeft  for:_fdm consistency:_cons];
   id<CPIntVar> rV = [CPSubst normSide:linRight for:_fdm consistency:_cons];
   id<CPIntVar> final = [CPFactory intVar:_fdm bounds:RANGE(0,1)];
   [_fdm post:[CPFactory equalc:final to:1]];
   return (struct CPVarPair){lV,rV,final};
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_fdm post:[CPFactory boolean:vars.lV or:vars.rV equal:vars.boolVar]];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_fdm post:[CPFactory boolean:vars.lV and:vars.rV equal:vars.boolVar]];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_fdm post:[CPFactory boolean:vars.lV imply:vars.rV equal:vars.boolVar]];
}
-(void) visitIntVarI: (CPIntVarI*) e       {}
-(void) visitIntegerI: (id<CPInteger>) e   {}
-(void) visitExprPlusI: (ORExprPlusI*) e   {}
-(void) visitExprMinusI: (ORExprMinusI*) e {}
-(void) visitExprMulI: (ORExprMulI*) e     {}
-(void) visitExprSumI: (ORExprSumI*) e     {}
-(void) visitExprAbsI:(ORExprAbsI*) e      {}
-(void) visitExprCstSubI:(ORExprCstSubI*)e {}
-(void) visitExprVarSubI:(CPExprVarSubI*)e {}
@end

@implementation CPLinearizer
-(id)initCPLinearizer:(id<CPLinear>)t solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons
{
   self = [super init];
   _terms = t;
   _fdm   = fdm;
   _cons  = cons;
   return self;
}
-(void) visitIntVarI: (CPIntVarI*) e 
{
   [_terms addTerm:e by:1];
}
-(void) visitIntegerI: (id<CPInteger>) e 
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
   id<CPLinear> old = _terms;
   _terms = [[CPLinearFlip alloc] initCPLinearFlip: _terms];
   [[e right] visit:self];
   [_terms release];
   _terms = old;
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   BOOL cv = [[e left] isConstant] && [[e right] isVariable];
   BOOL vc = [[e left] isVariable] && [[e right] isConstant];
   if (cv || vc) {      
      CPInt coef = cv ? [[e left] min] : [[e right] min];
      id       x = cv ? [e right] : [e left];
      [_terms addTerm:x by:coef];
   } else if ([[e left] isConstant]) {
      id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:[e right] consistency:_cons];
      [_terms addTerm:alpha by:[[e left] min]];
   } else if ([[e right] isConstant]) {
      id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:[e left] consistency:_cons];
      [_terms addTerm:alpha by:[[e right] min]];
   } else {
      id<CPIntVar> alpha =  [CPSubst substituteIn:_fdm expr:e consistency:_cons];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];   
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}

-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];   
}
-(void) visitExprVarSubI:(CPExprVarSubI*)e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];
}

+(CPLinear*)linearFrom:(ORExprI*)e solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons
{
   CPLinear* rv = [[CPLinear alloc] initCPLinear:4];
   CPLinearizer* v = [[CPLinearizer alloc] initCPLinearizer:rv solver:fdm consistency:cons];
   [e visit:v];
   [v release];
   return rv;
}
+(CPLinear*)addToLinear:(id<CPLinear>)terms from:(ORExprI*)e  solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons
{
   CPLinearizer* v = [[CPLinearizer alloc] initCPLinearizer:terms solver:fdm consistency:cons];
   [e visit:v];
   [v release];
   return terms;
}
@end

@implementation CPLinear
-(CPLinear*)initCPLinear:(CPInt)mxs
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
-(void)setIndependent:(CPInt)idp
{
   _indep = idp;
}
-(void)addIndependent:(CPInt)idp
{
   _indep += idp;
}
-(CPInt)independent
{
   return _indep;
}
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c
{
   CPInt low = 0,up=_nb-1,mid=-1,kid;
   CPInt xid = [x  getId];
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
   for(CPInt k=0;k<_nb;k++) {
      [buf appendFormat:@"(%d * %@) + ",_terms[k]._coef,[_terms[k]._var description]];
   }
   [buf appendFormat:@" (%d)",_indep];
   return buf;
}
-(id<CPIntVarArray>)scaledViews
{
   id<CP> cp = [_terms[0]._var cp];
   id<CPIntVarArray> x = [CPFactory intVarArray:cp 
                                          range:(CPRange){0,_nb-1}
                                           with:^id<CPIntVar>(CPInt i) {
                                              return _terms[i]._var;
                                           }];
   CPInt* coefs = alloca(sizeof(CPInt)*_nb);
   for(int k=0;k<_nb;k++)
      coefs[k] = _terms[k]._coef;
   id<CPIntVarArray> sx = [CPFactory pointwiseProduct:x by:coefs];
   return sx;
}
-(id<CPIntVar>)oneView
{
   id<CPIntVar> rv = [CPFactory intVar:_terms[0]._var
                                 scale:_terms[0]._coef
                                 shift:_indep];
   return rv;
}
-(CPInt)size
{ 
   return _nb;
}
-(CPInt)min
{
   CPLong lb = _indep;
   for(CPInt k=0;k < _nb;k++) {
      CPInt c = _terms[k]._coef;
      CPLong vlb = [_terms[k]._var min];
      CPLong vub = [_terms[k]._var max];
      CPLong svlb = c > 0 ? vlb * c : vub * c;
      lb += svlb;
   }
   return max(MININT,bindDown(lb));
}
-(CPInt)max
{
   CPLong ub = _indep;
   for(CPInt k=0;k < _nb;k++) {
      CPInt c = _terms[k]._coef;
      CPLong vlb = [_terms[k]._var min];
      CPLong vub = [_terms[k]._var max];
      CPLong svub = c > 0 ? vub * c : vlb * c;
      ub += svub;
   }
   return min(MAXINT,bindUp(ub));
}
-(CPStatus)postEQZ:(id<CPSolver>)fdm consistency:(CPConsistency)cons
{
   // [ldm] This should *never* raise an exception, but return a CPFailure.
   switch (_nb) {
      case 0: 
         assert(NO);
         return CPFailure;
      case 1: {
         if (_terms[0]._coef == 1) {
            return [fdm post:[CPFactory equalc:_terms[0]._var to:-_indep]];
         } else if (_terms[0]._coef == -1) {
            return [fdm post:[CPFactory equalc:_terms[0]._var to:_indep]];
         } else {
            assert(_terms[0]._coef != 0);
            CPInt nc = - _indep / _terms[0]._coef;   
            CPInt cr = - _indep % _terms[0]._coef;
            if (cr != 0)
               return CPFailure;
            else
               return [fdm post:[CPFactory equalc:_terms[0]._var to:nc]];
         }
      }break;
      case 2: {
         if (_terms[0]._coef == 1 && _terms[1]._coef == -1) {
            return [fdm post:[CPFactory equal:_terms[0]._var to:_terms[1]._var plus:-_indep consistency:cons]];
         } else if (_terms[0]._coef == -1 && _terms[1]._coef == 1) {
            return [fdm post:[CPFactory equal:_terms[1]._var to:_terms[0]._var plus:-_indep consistency:cons]];            
         } else {
            id<CPIntVar> xp = [CPFactory intVar:_terms[0]._var scale:_terms[0]._coef];
            id<CPIntVar> yp = [CPFactory intVar:_terms[1]._var scale:- _terms[1]._coef];
            return [fdm post:[CPFactory equal:xp to:yp plus:- _indep consistency:cons]];
         }
      }break;   
      case 3: {
         if (_terms[0]._coef * _terms[1]._coef * _terms[2]._coef == -1) { // odd number of negative coefs (4 cases)
            if (_terms[0]._coef + _terms[1]._coef + _terms[2]._coef == -3) { // all 3 negative
               id<CPIntVar> zp = [CPFactory intVar:_terms[0]._var scale:_terms[0]._coef shift: _indep];
               return [fdm post:[CPFactory equal3:zp to:_terms[1]._var plus:_terms[2]._var consistency:cons]];
            } else { // exactly 1 negative coef
               CPInt nc = _terms[0]._coef == -1 ? 0 : (_terms[1]._coef == -1 ? 1 : 2);
               CPInt pc[3] = {0,1,2};
               for(CPUInt i=0;i<3;i++)
                  if (pc[i] == nc)
                     pc[i] = pc[2];
               id<CPIntVar> zp = [CPFactory intVar:_terms[nc]._var scale:1 shift:-_indep];
               return [fdm post:[CPFactory equal3:zp to:_terms[pc[0]]._var plus:_terms[pc[1]]._var consistency:cons]];
            }
         } else {
            id<CPIntVar> xp = [CPFactory intVar:_terms[0]._var scale:_terms[0]._coef];
            id<CPIntVar> yp = [CPFactory intVar:_terms[1]._var scale:_terms[1]._coef];
            id<CPIntVar> zp = [CPFactory intVar:_terms[2]._var scale:- _terms[2]._coef shift:-_indep];
            return [fdm post:[CPFactory equal3:zp to:xp plus:yp consistency:cons]];            
         }
      }break;
      default: {
         CPInt sumCoefs = 0;
         id<CP> cp = [_terms[0]._var cp];
         for(CPInt k=0;k<_nb;k++)
            if ([_terms[k]._var isBool])
               sumCoefs += _terms[k]._coef;
         if (sumCoefs == _nb) {
            id<CPIntVarArray> boolVars = ALL(CPIntVar, i, RANGE(0,_nb-1), _terms[i]._var);
            return [fdm post:[CPFactory sumbool:boolVars eq: - _indep]];
         } else if (sumCoefs == - _nb) {
            id<CPIntVarArray> boolVars = ALL(CPIntVar, i, RANGE(0,_nb-1), _terms[i]._var);
            return [fdm post:[CPFactory sumbool:boolVars eq: _indep]];
         } else
            return [fdm post:[CPFactory sum:[self scaledViews] eq: - _indep consistency:cons]];
      }
   }
}
-(CPStatus)postLEQZ:(id<CPSolver>)fdm consistency:(CPConsistency)cons
{
   return [fdm post:[CPFactory sum:[self scaledViews] leq:- _indep]];
}
@end

@implementation CPSubst
+(id<CPIntVar>) substituteIn:(id<CPSolver>)fdm expr:(ORExprI*)expr consistency:(CPConsistency)c
{
   CPSubst* subst = [[CPSubst alloc] initCPSubst:fdm consistency:c];
   [expr visit:subst];
   id<CPIntVar> theVar = [subst result];
   [subst release];
   return theVar;   
}
+(id<CPIntVar>) substituteIn:(id<CPSolver>)fdm expr:(ORExprI*)expr by:(id<CPIntVar>)x consistency:(CPConsistency)c
{
   CPSubst* subst = [[CPSubst alloc] initCPSubst:fdm consistency:c by:x];
   [expr visit:subst];
   id<CPIntVar> theVar = [subst result];
   [subst release];
   return theVar;      
}
+(id<CPIntVar>)normSide:(CPLinear*)e for:(id<CPSolver>)cp consistency:(CPConsistency)c
{
   if ([e size] == 1) {
      return [e oneView];
   } else {
      id<CPIntVar> xv = [CPFactory intVar:cp domain:(CPRange){[e min],[e max]}];
      [e addTerm:xv by:-1];
      [e postEQZ:cp consistency:c];
      return xv;
   }
}

-(id)initCPSubst:(id<CPSolver>)fdm consistency: (CPConsistency) c
{
   self = [super init];
   _rv = nil;
   _fdm = fdm;
   _c = c;
   return self;
}
-(id)initCPSubst:(id<CPSolver>)fdm consistency:(CPConsistency)c by:(id<CPIntVar>)x
{
   self = [super init];
   _rv  = x;
   _fdm = fdm;
   _c = c;
   return self;
}
-(id<CPIntVar>)result
{
   return _rv;
}
-(void) visitIntVarI: (CPIntVarI*) e
{
   if (_rv)
      [_fdm post:[CPFactory equal:_rv to:e plus:0]];
   else _rv = e;
}
-(void) visitIntegerI: (id<CPInteger>) e
{
   id<ORTracker> cp = [e tracker];
   if (!_rv)
      _rv = [CPFactory intVar:cp domain:(CPRange){[e value],[e value]}];   
   [_fdm post:[CPFactory equalc:_rv to:[e value]]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   CPLinear* terms = [CPLinearizer linearFrom:e solver:_fdm consistency:_c];
   if (_rv==nil)
      _rv = [CPFactory intVar:[e tracker] domain:(CPRange){max([terms min],MININT),min([terms max],MAXINT)}];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_fdm consistency:_c];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   CPLinear* terms = [CPLinearizer linearFrom:e solver:_fdm consistency:_c];
   if (_rv==nil)
      _rv = [CPFactory intVar:[e tracker] domain:(CPRange){max([terms min],MININT),min([terms max],MAXINT)}];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_fdm consistency:_c];
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   id<ORTracker> cp = [e tracker];
   CPLinear* lT = [CPLinearizer linearFrom:[e left] solver:_fdm consistency:_c];
   CPLinear* rT = [CPLinearizer linearFrom:[e right] solver:_fdm consistency:_c];
   id<CPIntVar> lV = [CPSubst normSide:lT for:_fdm consistency:_c];
   id<CPIntVar> rV = [CPSubst normSide:rT for:_fdm consistency:_c];
   CPLong llb = [lV min];
   CPLong lub = [lV max];
   CPLong rlb = [rV min];
   CPLong rub = [rV max];
   CPLong a = minOf(llb * rlb,llb * rub);
   CPLong b = minOf(lub * rlb,lub * rub);
   CPLong lb = minOf(a,b);
   CPLong c = maxOf(llb * rlb,llb * rub);
   CPLong d = maxOf(lub * rlb,lub * rub);
   CPLong ub = maxOf(c,d);
   if (_rv==nil)
      _rv = [CPFactory intVar:cp domain:(CPRange){bindDown(lb),bindUp(ub)}];
   [_fdm post: [CPFactory mult:lV by:rV equal:_rv]];
   [lT release];
   [rT release];
}
-(void) reifyEQc:(CPIntVarI*)theVar constant:(CPInt)c
{
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [CPFactory intVar:cp bounds:RANGE(0,1)];
   [_fdm post: [CPFactory reify:_rv with:theVar eq:c]];
}
-(void) reifyNEQc:(CPIntVarI*)theVar constant:(CPInt)c
{
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [CPFactory intVar:cp bounds:RANGE(0,1)];
   [_fdm post: [CPFactory reify:_rv with:theVar neq:c]];
}
-(void) reifyLEQc:(ORExprI*)theOther constant:(CPInt)c
{
   CPLinear* linOther  = [CPLinearizer linearFrom:theOther solver:_fdm consistency:_c];
   id<CPIntVar> theVar = [CPSubst normSide:linOther for:_fdm consistency:_c];
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [CPFactory intVar:cp bounds:RANGE(0,1)];
   [_fdm post: [CPFactory reify:_rv with:theVar leq:c]];
}
-(void) reifyGEQc:(ORExprI*)theOther constant:(CPInt)c
{
   CPLinear* linOther  = [CPLinearizer linearFrom:theOther solver:_fdm consistency:_c];
   id<CPIntVar> theVar = [CPSubst normSide:linOther for:_fdm consistency:_c];
   id<ORTracker> cp = [theVar tracker];
   if (_rv==nil)
      _rv = [CPFactory intVar:cp bounds:RANGE(0,1)];
   [_fdm post: [CPFactory reify:_rv with:theVar geq:c]];
}

-(void) visitExprEqualI:(ORExprEqualI*)e
{
   if ([[e left] isConstant] && [[e right] isVariable]) {
      [self reifyEQc:(CPIntVarI*)[e right] constant:[[e left] min]];
   } else if ([[e right] isConstant] && [[e left] isVariable]) {
      [self reifyEQc:(CPIntVarI*)[e left] constant:[[e right] min]];
   } else assert(NO);
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   if ([[e left] isConstant] && [[e right] isVariable]) {
      [self reifyNEQc:(CPIntVarI*)[e right] constant:[[e left] min]];
   } else if ([[e right] isConstant] && [[e left] isVariable]) {
      [self reifyNEQc:(CPIntVarI*)[e left] constant:[[e right] min]];
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
   CPLinear* linLeft  = [CPLinearizer linearFrom:[e left] solver:_fdm consistency:_c];
   CPLinear* linRight = [CPLinearizer linearFrom:[e right] solver:_fdm consistency:_c];
   id<CPIntVar> lV = [CPSubst normSide:linLeft  for:_fdm consistency:_c];
   id<CPIntVar> rV = [CPSubst normSide:linRight for:_fdm consistency:_c];
   if (_rv==nil)
      _rv = [CPFactory intVar:_fdm bounds:RANGE(0,1)];
   [_fdm post:[CPFactory boolean:lV or:rV equal:_rv]];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   CPLinear* linLeft  = [CPLinearizer linearFrom:[e left] solver:_fdm consistency:_c];
   CPLinear* linRight = [CPLinearizer linearFrom:[e right] solver:_fdm consistency:_c];
   id<CPIntVar> lV = [CPSubst normSide:linLeft  for:_fdm consistency:_c];
   id<CPIntVar> rV = [CPSubst normSide:linRight for:_fdm consistency:_c];
   if (_rv==nil)
      _rv = [CPFactory intVar:_fdm bounds:RANGE(0,1)];
   [_fdm post:[CPFactory boolean:lV and:rV equal:_rv]];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   CPLinear* linLeft  = [CPLinearizer linearFrom:[e left] solver:_fdm consistency:_c];
   CPLinear* linRight = [CPLinearizer linearFrom:[e right] solver:_fdm consistency:_c];
   id<CPIntVar> lV = [CPSubst normSide:linLeft  for:_fdm consistency:_c];
   id<CPIntVar> rV = [CPSubst normSide:linRight for:_fdm consistency:_c];
   if (_rv==nil)
      _rv = [CPFactory intVar:_fdm bounds:RANGE(0,1)];
   [_fdm post:[CPFactory boolean:lV imply:rV equal:_rv]];
}

-(void) visitExprAbsI:(ORExprAbsI *)e  
{
   id<ORTracker> cp = [e tracker];
   CPLinear* lT = [CPLinearizer linearFrom:[e operand] solver:_fdm consistency:_c];   
   id<CPIntVar> oV = [CPSubst normSide:lT for:_fdm consistency:_c];
   CPInt lb = [lT min];
   CPInt ub = [lT max];
   if (_rv == nil)
      _rv = [CPFactory intVar:cp domain:(CPRange){lb,ub}];
   [_fdm post:[CPFactory abs:oV equal:_rv consistency:_c]];
   [lT release];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   id<ORTracker> cp = [e tracker];
   CPLinear* lT = [CPLinearizer linearFrom:[e index] solver:_fdm consistency:_c];
   id<CPIntVar> oV = [CPSubst normSide:lT for:_fdm consistency:_c];
   CPInt lb = [e min];
   CPInt ub = [e max];
   if (_rv == nil)
      _rv = [CPFactory intVar:cp domain:(CPRange){lb,ub}];
   [_fdm post:[CPFactory element:oV idxCstArray:[e array] equal:_rv]];
   [lT release];
}

-(void) visitExprVarSubI:(CPExprVarSubI*)e
{
   id<ORTracker> cp = [e tracker];
   CPLinear* lT = [CPLinearizer linearFrom:[e index] solver:_fdm consistency:_c];
   id<CPIntVar> oV = [CPSubst normSide:lT for:_fdm consistency:_c];
   CPInt lb = [e min];
   CPInt ub = [e max];
   if (_rv == nil)
      _rv = [CPFactory intVar:cp domain:(CPRange){lb,ub}];
   [_fdm post:[CPFactory element:oV idxVarArray:[e array] equal:_rv]];
   [lT release];   
}

-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
@end

@implementation CPExprConstraintI
-(id) initCPExprConstraintI:(CPSolverI*)fdm expr:(id<CPRelation>)x consistency: (CPConsistency) c
{
   self  = [super initCPActiveConstraint:fdm];
   _fdm  = fdm;
   _expr = x;
   _c    = c;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(CPStatus) post
{
   CPLinear* terms = [CPRNormalizer normalize:_expr solver:_fdm consistency:_c];
   CPStatus status = CPSuspend;
   @try {
      switch ([_expr type]) {
         case CPRBad: assert(NO);
         case CPREq: {
            if ([terms size] != 0) {
               status = [terms postEQZ:_fdm consistency:_c];
            }
         }break;
         case CPRNEq: assert(NO);
         case CPRLEq: {
            status = [terms postLEQZ: _fdm consistency:_c];
         }break;
         default:
            assert(terms == nil);
            break;
      }
      [terms release];
      return status ? CPSkip : CPFailure;
   } @catch(CPFailException* ex) {
      [terms release];
      @throw;
   }
}
-(NSSet*)allVars
{
   return [[NSSet alloc] init];
}
-(CPUInt)nbUVars
{
   return 0;
}
-(NSString*)description
{
   NSMutableString* buf = [NSMutableString stringWithCapacity:64];
   [buf appendFormat:@"<CPExprConstraintI:[%@] CL=%d>",_expr,_c];
   return buf;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_fdm];
   [aCoder encodeObject:_expr];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _fdm  = [aDecoder decodeObject];
   _expr = [[aDecoder decodeObject] retain];
   return self;
}
@end
