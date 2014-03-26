/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPEquationBC.h"
#import <ORFoundation/ORArrayI.h>
#import "CPIntVarI.h"
#import "CPEngineI.h"

@implementation CPEquationBC

-(CPEquationBC*) initCPEquationBC: (ORIdArrayI*) x equal: (ORInt) c
{
   id<ORSearchEngine> engine = (id<ORSearchEngine>) [[x at:[x low]] engine];
   self = [super initCPCoreConstraint:engine];
   //_idempotent = YES;
   _priority = HIGHEST_PRIO - 1;
   if ([x isKindOfClass:[ORIdArrayI class]]) {
      id<CPIntVarArray> xa = (id<CPIntVarArray>)x;
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVar*)*_nb);
      int i =0;
      for(ORInt k=[xa low];k <= [xa up];k++)
         _x[i++] = (CPIntVar*) [xa at:k];
   } else assert(FALSE);
   _c = c;
   _allTerms = NULL;
   _inUse    = NULL;
   return self;
}

-(void) dealloc
{
   free(_x);
   free(_allTerms);
   free(_inUse);
   [super dealloc];
}

-(NSSet*)allVars
{
   NSSet* theSet = [[[NSSet alloc] initWithObjects:_x count:_nb] autorelease];
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

static void sumBounds(struct CPEQTerm* terms,ORLong nb,struct Bounds* bnd)
{
   long long slow = 0,sup = 0;
   int k=0;
   while(k < nb) {
      if (terms[k].low == terms[k].up) {         
         bnd->_bndLow += terms[k].low;
         bnd->_bndUp  += terms[k].low;
         struct CPEQTerm tmp = terms[k];
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
   _allTerms = malloc(sizeof(CPEQTerm)*_nb);
   _inUse    = malloc(sizeof(TRCPEQTerm)*_nb);
   for(ORInt i=0;i<_nb;i++) {
      ORBounds b = bounds(_x[i]);
      UBType mth = (UBType)[_x[i] methodForSelector:@selector(updateMin:andMax:)];
      _allTerms[i] = (CPEQTerm){mth,_x[i],b.min,b.max,NO};
      _inUse[i] = inline_makeTRCPEQTerm(_trail, _allTerms+i);
   }
   ORInt lastUsed = (ORInt)_nb-1;
   ORInt i = 0;
   ORLong ec = - _c;
   while (i <= lastUsed) {
      if (bound(_inUse[i]._val->var)) {
         ec +=_inUse[i]._val->low;
         CPEQTerm* last = _inUse[lastUsed]._val;
         inline_assignTRCPEQTerm(&_inUse[lastUsed],_inUse[i]._val,_trail);
         inline_assignTRCPEQTerm(&_inUse[i],last,_trail);
         lastUsed--;
      } else
         i++;      
   }
   _ec   = makeTRLong(_trail, ec);
   _used = makeTRInt(_trail, lastUsed+1);
   [self propagate];
   for(ORInt k=0;k<_nb;k++) {
      if (![_x[k] bound])
         [_x[k] whenChangeBoundsPropagate: self];
   }
   return ORSuspend;
}

-(void) propagate
{   
   ORInt i = 0;
   ORInt lastUsed = _used._val - 1;
   ORLong ec = _ec._val;
   long long slow = 0,sup = 0;
   while (i <= lastUsed) {
      CPEQTerm* cur = _inUse[i]._val;
      ORBounds b = bounds(cur->var);
      if (b.min == b.max) {
         ec += b.min;
         CPEQTerm* last = _inUse[lastUsed]._val;
         inline_assignTRCPEQTerm(&_inUse[lastUsed],cur,_trail);
         inline_assignTRCPEQTerm(&_inUse[i],last,_trail);
         lastUsed--;
      } else {
         cur->low = b.min;
         cur->up  = b.max;
         slow += cur->low;
         sup  += cur->up;
         cur->updated = NO;
         i++;
      }
   }
   assignTRInt(&_used, lastUsed+1, _trail);
   assignTRLong(&_ec, ec, _trail);
   bool feasible = true;

   struct Bounds b = (struct Bounds){0,0,slow + _ec._val,sup + _ec._val,_used._val};
   if (b._sumLow > 0 || b._sumUp < 0)
      failNow();
   i = 0;
   while (i < _used._val && feasible) {
      CPEQTerm* cur = _inUse[i]._val;
      long long nLowi = - (b._sumUp - cur->up);
      long long nSupi = - (b._sumLow - cur->low);
      bool updateNow = nLowi > cur->low || nSupi < cur->up;
      cur->low = maxOf(cur->low,nLowi);
      cur->up  = minOf(cur->up,nSupi);
      if (updateNow) {
         // [ldm] We must update now. A view such as y = a * x with y appearing here
         // might force a stronger tightening of the bounds of y. e.g.,
         // D(x) = {0,1}  and D(y)={0..100} with y = 100 * x.
         // If (low,up) = (10,100) then, x={1} and therefore D(y)={100} rather than {10..100}
         cur->update(cur->var,@selector(updateMin:andMax:),(ORInt)cur->low,(ORInt)cur->up);
      }
      feasible = cur->low <= cur->up;
      ++i;
   }
   if (!feasible)
      failNow();
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
@end

@implementation CPINEquationBC 
-(CPINEquationBC*) initCPINEquationBC: (ORIdArrayI*) x lequal: (ORInt) c
{
   id<ORSearchEngine> engine = (id<ORSearchEngine>) [[x at:[x low]] engine];
   self = [super initCPCoreConstraint:engine];
   //_idempotent = YES;
   _priority = HIGHEST_PRIO - 1;
   if ([x isKindOfClass:[ORIdArrayI class]]) {
      id<CPIntVarArray> xa = (id<CPIntVarArray>)x;
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVar*)*_nb);
      int i =0;
      for(ORInt k=[xa low];k <= [xa up];k++)
         _x[i++] = (CPIntVar*) [xa at:k];
   }
   else
      assert(FALSE);
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
   NSSet* theSet = [[[NSSet alloc] initWithObjects:_x count:_nb] autorelease];
   return theSet;
}
-(ORUInt)nbUVars
{
   ORUInt nb=0;
   for(ORUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

static void sumLowerBound(struct CPEQTerm* terms,ORLong nb,struct Bounds* bnd)
{
   ORLong slow = 0;
   int k=0;
   while(k < nb) {
      if (terms[k].low == terms[k].up) {         
         bnd->_bndLow += terms[k].low;
         struct CPEQTerm tmp = terms[k];
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
   for(ORInt k=0;k<_nb;k++) {
      if (![_x[k] bound])
         [_x[k] whenChangeMinPropagate: self];
   }
   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
   struct CPEQTerm* terms = alloca(sizeof(struct CPEQTerm)*_nb);
   for(ORInt k=0;k<_nb;k++) {
      ORBounds b = bounds(_x[k]);
      terms[k] = (struct CPEQTerm){_updateMax[k],_x[k],b.min,b.max,NO};
   }
   struct Bounds b;
   b._bndLow = - _c;
   b._nb = _nb;
   
   BOOL feasible = true;
   sumLowerBound(terms, b._nb, &b);
   if (b._sumLow > 0)
      failNow();
   BOOL changed=false;
   for (int i=0; i < b._nb && feasible; i++) {
      ORLong slowi = b._sumLow - terms[i].low;
      ORLong nSupi = - slowi;
      BOOL updateNow = nSupi < terms[i].up;
      changed |= updateNow;
      terms[i].updated |= updateNow;
      terms[i].up  = minOf(terms[i].up,nSupi);
      if (updateNow) {
         // [ldm] this is necessary to make sure that the view can apply its narrowing
         // so that the constraint behaves in an idempotent way.
         terms[i].update(terms[i].var,@selector(updateMax:),(ORInt)terms[i].up);
         terms[i].up = maxDom(terms[i].var);
      }
      feasible = terms[i].low <= terms[i].up;
   }
   
   if (!feasible)
      failNow();
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
@end

