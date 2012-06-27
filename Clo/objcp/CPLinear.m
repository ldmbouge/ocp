/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
-(void) visitIntVarI: (CPIntVarI*) e;
-(void) visitIntegerI: (CPIntegerI*) e;
-(void) visitExprPlusI: (CPExprPlusI*) e;
-(void) visitExprMinusI: (CPExprMinusI*) e;
-(void) visitExprMulI: (CPExprMulI*) e;
-(void) visitExprEqualI:(CPExprEqualI*)e;
-(void) visitExprSumI: (CPExprSumI*) e;
-(void) visitExprAbsI:(CPExprAbsI *)e;
+(id<CPIntVar>) substituteIn:(id<CPSolver>)fdm expr:(CPExprI*)expr consistency:(CPConsistency)c;
+(id<CPIntVar>) substituteIn:(id<CPSolver>)fdm expr:(CPExprI*)expr by:(id<CPIntVar>)x consistency:(CPConsistency)c;
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


@interface CPLinearizer : NSObject<CPExprVisitor> {
   id<CPLinear> _terms;
   id<CPSolver>   _fdm;
   CPConsistency _cons;
}
+(CPLinear*)linearFrom:(id<CPExpr>)e  solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
-(id)initCPLinearizer:(id<CPLinear>)t solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
-(void) visitIntVarI: (CPIntVarI*) e;
-(void) visitIntegerI: (CPIntegerI*) e;
-(void) visitExprPlusI: (CPExprPlusI*) e;
-(void) visitExprMinusI: (CPExprMinusI*) e;
-(void) visitExprMulI: (CPExprMulI*) e;
-(void) visitExprEqualI:(CPExprEqualI*)e;
-(void) visitExprSumI: (CPExprSumI*) e;
-(void) visitExprAbsI:(CPExprAbsI*) e;
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
-(void) visitIntegerI: (CPIntegerI*) e 
{
   [_terms addIndependent:[e value]];
}
-(void) visitExprPlusI: (CPExprPlusI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinusI: (CPExprMinusI*) e
{
   [[e left] visit:self];
   id<CPLinear> old = _terms;
   _terms = [[CPLinearFlip alloc] initCPLinearFlip: _terms];
   [[e right] visit:self];
   [_terms release];
   _terms = old;
}
-(void) visitExprMulI: (CPExprMulI*) e
{
   BOOL cv = [[e left] isConstant] && [[e right] isVariable];
   BOOL vc = [[e left] isVariable] && [[e right] isConstant];
   if (cv || vc) {      
      CPInt coef = cv ? [[e left] min] : [[e right] min];
      id       x = cv ? [e right] : [e left];
      [_terms addTerm:x by:coef];
   } else {
      id<CPIntVar> alpha =  [CPSubst substituteIn:_fdm expr:e consistency:_cons];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprAbsI:(CPExprAbsI*) e
{
   id<CPIntVar> alpha = [CPSubst substituteIn:_fdm expr:e consistency:_cons];
   [_terms addTerm:alpha by:1];   
}
-(void) visitExprEqualI:(CPExprEqualI*)e
{
   if ([[e left] isVariable]) {
      id<CPIntVar> lV = (id<CPIntVar>)[e left];
      [CPSubst substituteIn:_fdm expr:[e right] by:lV consistency:_cons];
   } else {
      [[e left] visit:self];
      id<CPLinear> old = _terms;
      _terms = [[CPLinearFlip alloc] initCPLinearFlip: _terms];
      [[e right] visit:self];
      [_terms release];
      _terms = old;
   }
}
-(void) visitExprSumI: (CPExprSumI*) e 
{}

+(CPLinear*)linearFrom:(CPExprI*)e solver:(id<CPSolver>)fdm consistency:(CPConsistency)cons
{
   CPLinear* rv = [[CPLinear alloc] initCPLinear:4];
   CPLinearizer* v = [[CPLinearizer alloc] initCPLinearizer:rv solver:fdm consistency:cons];
   [e visit:v];
   [v release];
   return rv;
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
   CPLong lb = 0;
   for(CPInt k=0;k < _nb;k++) {
      CPInt c = _terms[k]._coef;
      CPLong vlb = [_terms[k]._var min];
      CPLong vub = [_terms[k]._var max];
      CPLong svlb = c > 0 ? vlb * c : vub * c;
      lb += svlb;
   }
   return max(MININT,lb);
}
-(CPInt)max
{
   CPLong ub = 0;
   for(CPInt k=0;k < _nb;k++) {
      CPInt c = _terms[k]._coef;
      CPLong vlb = [_terms[k]._var min];
      CPLong vub = [_terms[k]._var max];
      CPLong svub = c > 0 ? vub * c : vlb * c;
      ub += svub;
   }
   return min(MAXINT,ub);   
}
-(CPStatus)post:(id<CPSolver>)fdm consistency:(CPConsistency)cons
{
   return [fdm post:[CPFactory sum:[self scaledViews] eq: - _indep consistency:cons]];
}
@end

@implementation CPSubst
+(id<CPIntVar>) substituteIn:(id<CPSolver>)fdm expr:(CPExprI*)expr consistency:(CPConsistency)c
{
   CPSubst* subst = [[CPSubst alloc] initCPSubst:fdm consistency:c];
   [expr visit:subst];
   id<CPIntVar> theVar = [subst result];
   [subst release];
   return theVar;   
}
+(id<CPIntVar>) substituteIn:(id<CPSolver>)fdm expr:(CPExprI*)expr by:(id<CPIntVar>)x consistency:(CPConsistency)c
{
   CPSubst* subst = [[CPSubst alloc] initCPSubst:fdm consistency:c by:x];
   [expr visit:subst];
   id<CPIntVar> theVar = [subst result];
   [subst release];
   return theVar;      
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
-(id<CPIntVar>)normSide:(CPLinear*)e for:(id<CP>)cp
{
   if ([e size] == 1) {
      return [e oneView];
   } else {
      id<CPIntVar> xv = [CPFactory intVar:cp domain:(CPRange){[e min],[e max]}];
      [e addTerm:xv by:-1];
      [e post:_fdm consistency:_c];
      return xv;
   }
}
-(void) visitIntVarI: (CPIntVarI*) e
{
   if (_rv)
      [_fdm post:[CPFactory equal:_rv to:e plus:0]];
   else _rv = e;
}
-(void) visitIntegerI: (CPIntegerI*) e
{
   id<CP> cp = [e cp];
   if (!_rv)
      _rv = [CPFactory intVar:cp domain:(CPRange){[e value],[e value]}];   
   [_fdm post:[CPFactory equalc:_rv to:[e value]]];
}
-(void) visitExprPlusI: (CPExprPlusI*) e
{
   CPLinear* terms = [CPLinearizer linearFrom:e solver:_fdm consistency:_c];
   if (_rv==nil)
      _rv = [CPFactory intVar:[e cp] domain:(CPRange){max([terms min],MININT),min([terms max],MAXINT)}];
   [terms addTerm:_rv by:-1];
   [terms post:_fdm consistency:_c];
}
-(void) visitExprMinusI: (CPExprMinusI*) e
{
   CPLinear* terms = [CPLinearizer linearFrom:e solver:_fdm consistency:_c];
   if (_rv==nil)
      _rv = [CPFactory intVar:[e cp] domain:(CPRange){max([terms min],MININT),min([terms max],MAXINT)}];
   [terms addTerm:_rv by:-1];
   [terms post:_fdm consistency:_c];
}
-(void) visitExprMulI: (CPExprMulI*) e
{
   id<CP> cp = [e cp];
   CPLinear* lT = [CPLinearizer linearFrom:[e left] solver:_fdm consistency:_c];
   CPLinear* rT = [CPLinearizer linearFrom:[e right] solver:_fdm consistency:_c];
   id<CPIntVar> lV = [self normSide:lT for:cp];
   id<CPIntVar> rV = [self normSide:rT for:cp];
   CPLong llb = [lV min];
   CPLong lub = [lV max];
   CPLong rlb = [rV min];
   CPLong rub = [rV max];
   CPLong a = min(llb * rlb,llb * rub);
   CPLong b = min(lub * rlb,lub * rub);
   CPLong lb = min(a,b);
   CPLong c = max(llb * rlb,llb * rub);
   CPLong d = max(lub * rlb,lub * rub);
   CPLong ub = max(c,d);
   if (_rv==nil)
      _rv = [CPFactory intVar:cp domain:(CPRange){max(lb,MININT),min(ub,MAXINT)}];
   [_fdm post: [CPFactory mult:lV by:rV equal:_rv]];
   [lT release];
   [rT release];
}
-(void) visitExprEqualI:(CPExprEqualI*)e
{
   assert(NO);
}
-(void) visitExprAbsI:(CPExprAbsI *)e  
{
   id<CP> cp = [e cp];
   CPLinear* lT = [CPLinearizer linearFrom:[e operand] solver:_fdm consistency:_c];   
   id<CPIntVar> oV = [self normSide:lT for:cp];
   CPInt lb = [lT min];
   CPInt ub = [lT max];
   if (_rv == nil)
      _rv = [CPFactory intVar:cp domain:(CPRange){lb,ub}];
   [_fdm post:[CPFactory abs:oV equal:_rv consistency:_c]];
   [lT release];
}
-(void) visitExprSumI: (CPExprSumI*) e
{
   assert(NO);
}
@end

@implementation CPExprConstraintI
-(id) initCPExprConstraintI:(id<CPExpr>)x consistency: (CPConsistency) c
{
   id<CP> cp = [x cp];
   self  = [super initCPActiveConstraint:[cp solver]];
   _fdm  = (CPSolverI*)[cp solver];
   _expr = [x retain];
   _c    = c;
   return self;
}
-(void) dealloc
{
   [_expr release];
   [super dealloc];
}
-(CPStatus)post
{
   CPLinear* terms = [CPLinearizer linearFrom:_expr solver:_fdm consistency:_c];
   CPStatus status = CPSuspend;
   if ([terms size] != 0) {
      status = [terms post:_fdm consistency:_c];
   }
   [terms release];
   return status ? CPSkip : CPFailure;
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
