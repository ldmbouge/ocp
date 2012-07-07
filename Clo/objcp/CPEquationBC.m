/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPEquationBC.h"
#import "ORFoundation/ORArrayI.h"
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
   else if ([x isKindOfClass:[ORIdArrayI class]]) {
      id<CPIntVarArray> xa = x;
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
   free(_bndIMP);
   free(_updateBounds);
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
   CPULong     _nb;
};

struct CPTerm {
   UBType  update;
   CPIntVarI* var;
   CPLong     low;
   CPLong      up;
   BOOL   updated;
};

static void sumBounds(struct CPTerm* terms,CPLong nb,struct Bounds* bnd)
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
   _bndIMP = malloc(sizeof(IMP)*_nb);
   _updateBounds = malloc(sizeof(UBType)*_nb);
   for(CPInt k=0;k<_nb;k++) {
      _updateBounds[k] = (UBType)[_x[k] methodForSelector:@selector(updateMin:andMax:)];
      _bndIMP[k] = [_x[k] methodForSelector:@selector(bounds:)];
   }
   [self propagate];
   for(CPInt k=0;k<_nb;k++) {
      if (![_x[k] bound])
         [_x[k] whenChangeBoundsPropagate: self];
   }
   return CPSuspend;
}

-(void) propagate
{
    struct CPTerm* terms = alloca(sizeof(struct CPTerm)*_nb);
    for(CPInt k=0;k<_nb;k++) {
        CPBounds b;
        _bndIMP[k](_x[k],@selector(bounds:),&b);
        terms[k] = (struct CPTerm){_updateBounds[k],_x[k],b.min,b.max,NO};
    }
    struct Bounds b;
    b._bndLow = b._bndUp = - _c;
    b._nb = _nb;
    
    bool changed;   
    bool feasible = true;
    do {        
        sumBounds(terms, b._nb, &b);
        if (b._sumLow > 0 || b._sumUp < 0) 
           failNow();        
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
       failNow();    
    for(CPUInt i=0;i<_nb;i++) {
       if (terms[i].updated)
          terms[i].update(terms[i].var,@selector(updateMin:andMax:),
                          (CPInt)terms[i].low,
                          (CPInt)terms[i].up);
    }
}
-(NSString*)description
{
   NSMutableString* buf = [NSMutableString stringWithCapacity:64];
   [buf appendFormat:@"<CPEquationBC:[%lld] == %d>",_nb,_c];
   return buf;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(CPLong) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
   for(int k=0;k<_nb;k++)
      [aCoder encodeObject:_x[k]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];   
   [aDecoder decodeValueOfObjCType:@encode(CPLong) at:&_nb];
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
   else if ([x isKindOfClass:[ORIdArrayI class]]) {
      id<CPIntVarArray> xa = x;
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

static void sumLowerBound(struct CPTerm* terms,CPLong nb,struct Bounds* bnd)
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
   _bndIMP = malloc(sizeof(IMP)*_nb);
   _updateMax = malloc(sizeof(UBType)*_nb);
   for(CPInt k=0;k<_nb;k++) {
      _bndIMP[k] = [_x[k] methodForSelector:@selector(bounds:)];
      _updateMax[k] = (UBType)[_x[k] methodForSelector:@selector(updateMax:)];
   }
   [self propagate];
   for(CPInt k=0;k<_nb;k++) {
      if (![_x[k] bound])
         [_x[k] whenChangeMinPropagate: self];
   }
   return CPSuspend;
}

-(void) propagate
{
   struct CPTerm* terms = alloca(sizeof(struct CPTerm)*_nb);
   for(CPInt k=0;k<_nb;k++) {
      CPBounds b;
      _bndIMP[k](_x[k],@selector(bounds:),&b);
      terms[k] = (struct CPTerm){_updateMax[k],_x[k],b.min,b.max,NO};
   }
   struct Bounds b;
   b._bndLow = - _c;
   b._nb = _nb;
   
   BOOL changed;   
   BOOL feasible = true;
   do {      
      sumLowerBound(terms, b._nb, &b);
      if (b._sumLow > 0) 
         failNow();      
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
      failNow();
   
   for(CPUInt i=0;i<_nb;i++) {
      if (terms[i].updated) 
         terms[i].update(terms[i].var,@selector(updateMax:),(CPInt)terms[i].up);
   }
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(CPLong) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
   for(int k=0;k<_nb;k++)
      [aCoder encodeObject:_x[k]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];   
   [aDecoder decodeValueOfObjCType:@encode(CPLong) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   _x = malloc(sizeof(CPIntVarI*)*_nb);
   for(int k=0;k<_nb;k++)
      _x[k] = [aDecoder decodeObject];
   _bndIMP = NULL;
   return self;
}
@end

