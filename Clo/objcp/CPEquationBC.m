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

#import "CPEquationBC.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPSolverI.h"

@implementation CPEquationBC

-(CPEquationBC*) initCPEquationBC: (id) x equal: (CPInt) c
{
   self = [super initCPCoreConstraint];
   _idempotent = YES;
   _priority = HIGHEST_PRIO - 1;
   if ([x isKindOfClass:[NSArray class]]) {
      [super initCPCoreConstraint];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVarI*)*_nb);
      for(CPInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   } 
   else if ([x isKindOfClass:[CPIntVarArrayI class]]) {
      CPIntVarArrayI* xa = x;
      [super initCPCoreConstraint];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarI*)*_nb);
      int i =0;
      for(CPInt k=[x low];k <= [x up];k++)
         _x[i++] = (CPIntVarI*) [xa at:k];
   }
   _c = c;
   return self;
}

-(void) dealloc
{
   free(_x);
   [super dealloc];
}

-(NSSet*)allVars
{
   NSSet* theSet = [[NSSet alloc] initWithObjects:_x count:_nb];
   return theSet;
}
-(CPUInt)nbUVars
{
   CPUInt nb=0;
   for(CPUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

struct Bounds {
   long long _bndLow;
   long long _bndUp;
   long long _sumLow;
   long long _sumUp;
   CPUInt _nb;
};

struct CPTerm {
   CPIntVarI* var;
   long long low;
   long long up;
   bool      updated;
};

static void sumBounds(struct CPTerm* terms,CPInt nb,struct Bounds* bnd)
{
   long long slow = 0,sup = 0;
   int k=0;
   while(k < nb) {
      if (terms[k].low == terms[k].up) {         
         bnd->_bndLow += terms[k].low;
         bnd->_bndUp  += terms[k].low;
         struct CPTerm tmp = terms[k];
         terms[k] = terms[--nb];
         terms[nb] = tmp;
      } 
      else {
         slow += terms[k].low;
         sup  += terms[k].up;
         ++k;
      }
   }
   bnd->_sumLow = slow + bnd->_bndLow;
   bnd->_sumUp  = sup  + bnd->_bndUp;
   bnd->_nb     = nb;
}

-(CPStatus) post
{
   _bndSEL = @selector(bounds:);
   _bndIMP = malloc(sizeof(IMP)*_nb);
   for(CPInt k=0;k<_nb;k++) 
      _bndIMP[k] = [_x[k] methodForSelector:_bndSEL];
   
   CPStatus ok = [self propagate];
   if (ok) {
      for(CPInt k=0;k<_nb;k++) {
         if (![_x[k] bound])
             [_x[k] whenChangeBoundsPropagate: self];
      }
   }
   return ok;
}

-(CPStatus) propagate
{
    struct CPTerm* terms = alloca(sizeof(struct CPTerm)*_nb);
    for(CPInt k=0;k<_nb;k++) {
        CPBounds b;
        //[_x[k] bounds:&b];
        _bndIMP[k](_x[k],_bndSEL,&b);
        terms[k] = (struct CPTerm){_x[k],b.min,b.max,NO};
    }
    struct Bounds b;
    b._bndLow = b._bndUp = - _c;
    b._nb = _nb;
    
    bool changed;   
    bool feasible = true;
    do {
        
        sumBounds(terms, b._nb, &b);
        if (b._sumLow > 0 || b._sumUp < 0) 
            return CPFailure;
        
        changed=false;
        for (int i=0; i < b._nb && feasible; i++) {
            
            long long supi  = b._sumUp - terms[i].up;
            long long slowi = b._sumLow - terms[i].low;
            long long nLowi = - supi;
            long long nSupi = - slowi;
            bool updateNow = nLowi > terms[i].low || nSupi < terms[i].up;
            changed |= updateNow;
            terms[i].updated |= updateNow;
            terms[i].low = maxOf(terms[i].low,nLowi);
            terms[i].up  = minOf(terms[i].up,nSupi);
            feasible = terms[i].low <= terms[i].up;
            
        }
        
    } while (changed && feasible);
    
    if (!feasible)
        return CPFailure;
    
    for(CPUInt i=0;i<_nb;i++) {
        if (terms[i].updated) {
            if ([terms[i].var updateMin:(CPInt)terms[i].low] == CPFailure)
                return CPFailure;
            if ([terms[i].var updateMax:(CPInt)terms[i].up] == CPFailure)
                return CPFailure;
        }
    }
    return CPSuspend; 
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
   for(int k=0;k<_nb;k++)
      [aCoder encodeObject:_x[k]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];   
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   _x = malloc(sizeof(CPIntVarI*)*_nb);
   for(int k=0;k<_nb;k++)
      _x[k] = [aDecoder decodeObject];
   _bndIMP = NULL;
   return self;
}
@end

@implementation CPINEquationBC 
-(CPINEquationBC*) initCPINEquationBC: (id) x lequal: (CPInt) c
{
   self = [super initCPCoreConstraint];
   _idempotent = YES;
   _priority = HIGHEST_PRIO - 1;
   if ([x isKindOfClass:[NSArray class]]) {
      [super initCPCoreConstraint];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVarI*)*_nb);
      for(CPInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   } 
   else if ([x isKindOfClass:[CPIntVarArrayI class]]) {
      CPIntVarArrayI* xa = x;
      [super initCPCoreConstraint];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarI*)*_nb);
      int i =0;
      for(CPInt k=[x low];k <= [x up];k++)
         _x[i++] = (CPIntVarI*) [xa at:k];
   }
   _c = c;
   return self;
}

-(void) dealloc
{
   free(_x);
   [super dealloc];
}

-(NSSet*)allVars
{
   NSSet* theSet = [[NSSet alloc] initWithObjects:_x count:_nb];
   return theSet;
}
-(CPUInt)nbUVars
{
   CPUInt nb=0;
   for(CPUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

static void sumLowerBound(struct CPTerm* terms,CPInt nb,struct Bounds* bnd)
{
   CPLong slow = 0;
   int k=0;
   while(k < nb) {
      if (terms[k].low == terms[k].up) {         
         bnd->_bndLow += terms[k].low;
         struct CPTerm tmp = terms[k];
         terms[k] = terms[--nb];
         terms[nb] = tmp;
      } 
      else 
         slow += terms[k++].low;
   }
   bnd->_sumLow = slow + bnd->_bndLow;
   bnd->_nb     = nb;
}

-(CPStatus) post
{
   _bndSEL = @selector(bounds:);
   _bndIMP = malloc(sizeof(IMP)*_nb);
   for(CPInt k=0;k<_nb;k++) 
      _bndIMP[k] = [_x[k] methodForSelector:_bndSEL];
   
   CPStatus ok = [self propagate];
   if (ok) {
      for(CPInt k=0;k<_nb;k++) {
         if (![_x[k] bound])
            [_x[k] whenChangeMinPropagate: self];
      }
   }
   return ok;
}

-(CPStatus) propagate
{
   struct CPTerm* terms = alloca(sizeof(struct CPTerm)*_nb);
   for(CPInt k=0;k<_nb;k++) {
      CPBounds b;
      _bndIMP[k](_x[k],_bndSEL,&b);
      terms[k] = (struct CPTerm){_x[k],b.min,b.max,NO};
   }
   struct Bounds b;
   b._bndLow = - _c;
   b._nb = _nb;
   
   BOOL changed;   
   BOOL feasible = true;
   do {      
      sumLowerBound(terms, b._nb, &b);
      if (b._sumLow > 0) 
         return CPFailure;      
      changed=false;
      for (int i=0; i < b._nb && feasible; i++) {         
         CPLong slowi = b._sumLow - terms[i].low;
         CPLong nSupi = - slowi;
         BOOL updateNow = nSupi < terms[i].up;
         changed |= updateNow;
         terms[i].updated |= updateNow;
         terms[i].up  = minOf(terms[i].up,nSupi);
         feasible = terms[i].low <= terms[i].up;         
      }      
   } while (changed && feasible);
   
   if (!feasible)
      return CPFailure;
   
   for(CPUInt i=0;i<_nb;i++) {
      if (terms[i].updated) {
         if ([terms[i].var updateMax:(CPInt)terms[i].up] == CPFailure)
            return CPFailure;
      }
   }
   return CPSuspend; 
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
   for(int k=0;k<_nb;k++)
      [aCoder encodeObject:_x[k]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];   
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   _x = malloc(sizeof(CPIntVarI*)*_nb);
   for(int k=0;k<_nb;k++)
      _x[k] = [aDecoder decodeObject];
   _bndIMP = NULL;
   return self;
}
@end

