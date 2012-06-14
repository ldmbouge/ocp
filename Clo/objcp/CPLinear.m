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

@interface CPLinearFlip : NSObject<CPLinear> {
   id<CPLinear> _real;   
}
-(CPLinearFlip*)initCPLinearFlip:(id<CPLinear>)r;
-(void)setIndependent:(CPInt)idp;
-(void)addIndependent:(CPInt)idp;
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c;
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
}
-(id)initCPLinearizer:(id<CPLinear>)t;
-(void) visitIntVarI: (CPIntVarI*) e;
-(void) visitIntegerI: (CPIntegerI*) e;
-(void) visitExprPlusI: (CPExprPlusI*) e;
-(void) visitExprMinusI: (CPExprMinusI*) e;
-(void) visitExprEqualI:(CPExprEqualI*)e;
-(void) visitExprSumI: (CPExprSumI*) e;
@end

@implementation CPLinearizer
-(id)initCPLinearizer:(id<CPLinear>)t
{
   self = [super init];
   _terms = t;
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
-(void) visitExprEqualI:(CPExprEqualI*)e
{
   [[e left] visit:self];
   id<CPLinear> old = _terms;
   _terms = [[CPLinearFlip alloc] initCPLinearFlip: _terms];
   [[e right] visit:self];
   [_terms release];
   _terms = old;
}
-(void) visitExprSumI: (CPExprSumI*) e 
{

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
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c
{
   CPInt low = 0,up=_nb-1,mid,kid;
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
      else up = mid + 1;
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
      _terms[_nb++] = (struct CPTerm){x,c};      
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

+(CPLinear*)linearFrom:(CPExprI*)e
{
   CPLinear* rv = [[CPLinear alloc] initCPLinear:4];
   CPLinearizer* v = [[CPLinearizer alloc] initCPLinearizer:rv];
   [e visit:v];
   [v release];
   return rv;
}

@end
