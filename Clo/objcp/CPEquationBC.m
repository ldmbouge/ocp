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
#import "CPEngineI.h"

@implementation CPEquationBC

-(CPEquationBC*) initCPEquationBC: (id) x equal: (ORInt) c
{
   self = [super initCPCoreConstraint];
   _idempotent = YES;
   _priority = HIGHEST_PRIO - 1;
   if ([x isKindOfClass:[NSArray class]]) {
      [super initCPCoreConstraint];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVarI*)*_nb);
      for(ORInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   } 
   else if ([x isKindOfClass:[ORIdArrayI class]]) {
      id<ORIntVarArray> xa = x;
      [super initCPCoreConstraint];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarI*)*_nb);
      int i =0;
      for(ORInt k=[xa low];k <= [xa up];k++)
         _x[i++] = (CPIntVarI*) [xa at:k];
   }
   _c = c;
   return self;
}

-(void) dealloc
{
   free(_x);
   free(_updateBounds);
   [super dealloc];
}

-(NSSet*)allVars
{
   NSSet* theSet = [[NSSet alloc] initWithObjects:_x count:_nb];
   return theSet;
}
-(ORUInt)nbUVars
{
   ORUInt nb=0;
   for(ORUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

struct Bounds {
   long long _bndLow;
   long long _bndUp;
   long long _sumLow;
   long long _sumUp;
   ORULong     _nb;
};

struct CPTerm {
   UBType  update;
   CPIntVarI* var;
   ORLong     low;
   ORLong      up;
   BOOL   updated;
};

static void sumBounds(struct CPTerm* terms,ORLong nb,struct Bounds* bnd)
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

-(ORStatus) post
{
   _updateBounds = malloc(sizeof(UBType)*_nb);
   for(ORInt k=0;k<_nb;k++)
      _updateBounds[k] = (UBType)[_x[k] methodForSelector:@selector(updateMin:andMax:)];
   [self propagate];
   for(ORInt k=0;k<_nb;k++) {
      if (![_x[k] bound])
         [_x[k] whenChangeBoundsPropagate: self];
   }
   return ORSuspend;
}

-(void) propagate
{
    struct CPTerm* terms = alloca(sizeof(struct CPTerm)*_nb);
    for(ORInt k=0;k<_nb;k++) {
       ORBounds b = bounds(_x[k]);
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
    for(ORUInt i=0;i<_nb;i++) {
       if (terms[i].updated)
          terms[i].update(terms[i].var,@selector(updateMin:andMax:),
                          (ORInt)terms[i].low,
                          (ORInt)terms[i].up);
    }
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<CPEquationBC:%02d [%lld] ",_name,_nb];
   for(ORInt k=0;k < _nb;k++) {
      [buf appendFormat:@"%@ %c", [_x[k] description], k<_nb-1 ? ',' : ' '];
   }
   [buf appendFormat:@" == %d >",_c];
   return buf;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(ORLong) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
   for(int k=0;k<_nb;k++)
      [aCoder encodeObject:_x[k]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];   
   [aDecoder decodeValueOfObjCType:@encode(ORLong) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   _x = malloc(sizeof(CPIntVarI*)*_nb);
   for(int k=0;k<_nb;k++)
      _x[k] = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPINEquationBC 
-(CPINEquationBC*) initCPINEquationBC: (id) x lequal: (ORInt) c
{
   self = [super initCPCoreConstraint];
   _idempotent = YES;
   _priority = HIGHEST_PRIO - 1;
   if ([x isKindOfClass:[NSArray class]]) {
      [super initCPCoreConstraint];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVarI*)*_nb);
      for(ORInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   } 
   else if ([x isKindOfClass:[ORIdArrayI class]]) {
      id<ORIntVarArray> xa = x;
      [super initCPCoreConstraint];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarI*)*_nb);
      int i =0;
      for(ORInt k=[xa low];k <= [xa up];k++)
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
-(ORUInt)nbUVars
{
   ORUInt nb=0;
   for(ORUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

static void sumLowerBound(struct CPTerm* terms,ORLong nb,struct Bounds* bnd)
{
   ORLong slow = 0;
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

-(ORStatus) post
{
   _updateMax = malloc(sizeof(UBType)*_nb);
   for(ORInt k=0;k<_nb;k++)
      _updateMax[k] = (UBType)[_x[k] methodForSelector:@selector(updateMax:)];
   [self propagate];
   for(ORInt k=0;k<_nb;k++) {
      if (![_x[k] bound])
         [_x[k] whenChangeMinPropagate: self];
   }
   return ORSuspend;
}

-(void) propagate
{
   struct CPTerm* terms = alloca(sizeof(struct CPTerm)*_nb);
   for(ORInt k=0;k<_nb;k++) {
      ORBounds b = bounds(_x[k]);
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
         ORLong slowi = b._sumLow - terms[i].low;
         ORLong nSupi = - slowi;
         BOOL updateNow = nSupi < terms[i].up;
         changed |= updateNow;
         terms[i].updated |= updateNow;
         terms[i].up  = minOf(terms[i].up,nSupi);
         feasible = terms[i].low <= terms[i].up;         
      }      
   } while (changed && feasible);
   
   if (!feasible)
      failNow();
   
   for(ORUInt i=0;i<_nb;i++) {
      if (terms[i].updated) 
         terms[i].update(terms[i].var,@selector(updateMax:),(ORInt)terms[i].up);
   }
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<CPINEquationBC:%02d [%lld] ",_name,_nb];
   for(ORInt k=0;k < _nb;k++) {
      [buf appendFormat:@"%@ %c", [_x[k] description], k<_nb-1 ? ',' : ' '];
   }
   [buf appendFormat:@" <= %d >",_c];
   return buf;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(ORLong) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
   for(int k=0;k<_nb;k++)
      [aCoder encodeObject:_x[k]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];   
   [aDecoder decodeValueOfObjCType:@encode(ORLong) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   _x = malloc(sizeof(CPIntVarI*)*_nb);
   for(int k=0;k<_nb;k++)
      _x[k] = [aDecoder decodeObject];
   return self;
}
@end

