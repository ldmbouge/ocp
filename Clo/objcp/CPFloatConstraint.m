/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORConstraintI.h"
#import "CPFloatConstraint.h"
#import "CPIntVarI.h"
#import "CPFloatVarI.h"
#import "CPEngineI.h"

@implementation CPFloatSquareBC

-(id)initCPFloatSquareBC:(CPFloatVarI*)z equalSquare:(CPFloatVarI*)x  // z == x^2
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _z = z;
   _idempotent = TRUE;
   return self;
}
-(ORStatus) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if (![_z bound])
      [_z whenChangeBoundsPropagate:self];
   return ORSuspend;
}
-(void) propagate
{
   ORIReady();
   ORNarrowing xs = ORNone, zs = ORNone;
   do {
      if ([_x bound]) {
         zs = [_z updateInterval:ORISquare([_x bounds])];
         break;
      } else if ([_z bound]) {
         xs = [_x updateInterval:ORISqrt([_z bounds])];
         break;
      } else {
         ORInterval xb = [_x bounds];
         zs = [_z updateInterval:ORISquare(xb)];
         ORInterval zb = [_z bounds];
         if (ORISurePositive(xb))
            xs = [_x updateInterval:ORIPSqrt(zb)];
         else if (ORISureNegative(xb))
            xs = [_x updateInterval:ORIOpposite(ORIPSqrt(zb))];
         else
            xs = [_x updateInterval:ORISqrt(zb)];
      }
   }
   while (zs != ORNone || xs != ORNone);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatSquareBC:%02d %@ == %@^2>",_name,_z,_x];
}
@end

@implementation CPFloatEquationBC
-(id)init:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs eqi:(ORFloat)c   // sum(i in S) c_i * x_i == c  [[ saved constant is -c ]]
{
   self = [super initCPCoreConstraint:(id)[x[x.range.low] engine]];
   _x = x;
   _coefs = coefs;
   _c = - c;
   _idempotent = TRUE;
   return self;
}

-(ORStatus) post
{
   [self propagate];
   [_x enumerateWith:^(CPFloatVarI* obj, int k) {
      if (![obj bound])
         [obj whenChangeBoundsPropagate:self];
   }];
   return ORSuspend;
}

-(void) propagate
{
   ORIReady();
   BOOL changed = NO;
   do {
      __block ORInterval S = createORI1(_c);
      [_x enumerateWith:^(CPFloatVarI* xk,int k) {
         S = ORIAdd(S,ORIMul([xk bounds],createORI1([_coefs at:k])));
         if (ORIEmpty(S))
            @throw [[ORExecutionError alloc] initORExecutionError:"interval empty in FloatEquation"];
      }];
      changed = NO;
      for(ORInt i=_x.low;i <= _x.up;i++) {
         ORFloat ci = [_coefs at:i];
         CPFloatVarI* xi = (id)_x[i];
         ORInterval xii  = xi.bounds;
         ORInterval TMP = ORISubPointwise(S, ORIMul(xii, ci > 0 ? createORI1(ci) : ORISwap(createORI1(ci))));
         ORInterval NEW = ORIDiv(ORIOpposite(TMP), createORI1(ci));
         BOOL update = ORINarrow(xii, NEW) >= ORLow;
         changed |= update;
         if (update)
            [xi updateInterval: NEW];
      }
   }
   while (changed);
}
-(NSSet*)allVars
{
   NSMutableSet* theSet = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [theSet addObject:obj];
   }];
   return theSet;
}
-(ORUInt)nbUVars
{
   __block ORUInt nb=0;
   [_x enumerateWith:^(id<CPFloatVar> obj, int idx) {
      nb += ![obj bound];
   }];
   return nb;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatEquationBC:%02d %@ %@ + (%f) == 0>",_name,_x,_coefs,_c];
}
@end

@implementation CPFloatINEquationBC
-(id)init:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs leqi:(ORFloat)c   // sum(i in S) c_i * x_i <= c  [[ saved constant is -c ]]
{
   self = [super initCPCoreConstraint:(id)[x[x.range.low] engine]];
   _x = x;
   _coefs = coefs;
   _c = - c;
   _idempotent = TRUE;
   return self;
}
-(ORStatus) post
{
   [self propagate];
   [_x enumerateWith:^(CPFloatVarI* obj, int k) {
      ORFloat ck = [_coefs at:k];
      if (ck > 0) {
         if (![obj bound])
            [obj whenChangeMinPropagate:self];
      } else if (ck < 0) {
         if (![obj bound])
            [obj whenChangeMaxPropagate:self];
      }
   }];
   return ORSuspend;
}
-(void) propagate
{
   ORIReady();
   BOOL changed = NO;
   do {
      __block ORInterval S = createORI1(_c);
      [_x enumerateWith:^(CPFloatVarI* xk,int k) {
         S = ORIAdd(S,ORIMul([xk bounds],createORI1([_coefs at:k])));
      }];
      if (ORISurePositive(S))
         failNow();
      changed = NO;
      for(ORInt i=_x.low;i <= _x.up;i++) {
         ORFloat ci = [_coefs at:i];
         CPFloatVarI* xi = (id)_x[i];
         ORInterval xii  = xi.bounds;
         ORInterval TMP = ORISubPointwise(S, ORIMul(xii, ci > 0 ? createORI1(ci) : ORISwap(createORI1(ci))));
         ORInterval NEW = ORIDiv(ORIOpposite(TMP), createORI1(ci));
         BOOL update = ORINarrow(xii, NEW) >= ORLow;
         changed |= update;
         if (update) {
            if (ci > 0)
               [xi updateMax:ORIUp(NEW)];
            else
               [xi updateMin:ORILow(NEW)];
         }
      }
   }
   while (changed);
}
-(NSSet*)allVars
{
   NSMutableSet* theSet = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [theSet addObject:obj];
   }];
   return theSet;
}
-(ORUInt)nbUVars
{
   __block ORUInt nb=0;
   [_x enumerateWith:^(id<CPFloatVar> obj, int idx) {
      nb += ![obj bound];
   }];
   return nb;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatINEquationBC:%02d %@ %@ + (%f) <= 0>",_name,_x,_coefs,_c];
}
@end

@implementation CPFloatEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(ORStatus) post
{
   [_x bind:_c];
   return ORSkip;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];   
}
-(ORUInt)nbUVars
{
   return ![_x bound];   
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<x[%d] == %f>",[_x getId],_c];
}
@end



typedef struct CPlFoatEltRecordTag {
   ORInt   _idx;
   ORFloat _val;
} CPFloatEltRecord;

@implementation CPFloatElementCstBC {
   CPFloatEltRecord* _tab;
   ORInt              _sz;
   TRInt            _from;
   TRInt              _to;
}

-(id) init: (CPIntVarI*) x indexCstArray:(id<ORFloatArray>) c equal:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _idempotent = TRUE;
   _x = x;
   _y = y;
   _c = c;
   _tab = NULL;
   _sz  = 0;
   return self;
}
-(void) dealloc
{
   free(_tab);
   [super dealloc];
}
int compareCPFloatEltRecords(const CPFloatEltRecord* r1,const CPFloatEltRecord* r2)
{
   ORInt d1 = r1->_val - r2->_val;
   if (d1==0)
      return r1->_idx - r2->_idx;
   else
      return d1;
}
-(ORStatus) post
{
   if (bound(_x)) {
      [_y bind:[_c at:[_x min]]];
   }
   else if ([_y bound]) {
      ORInt cLow = [_c low];
      ORInt cUp  = [_c up];
      ORBounds xb = bounds(_x);
      for(ORInt k=xb.min;k <= xb.max;k++)
         if (k < cLow || k > cUp || ![_y member:[_c at:k]])
            removeDom(_x, k);
   }
   else {
      ORInt cLow = [_c low];
      ORInt cUp  = [_c up];
      _sz = cUp - cLow + 1;
      _tab = malloc(sizeof(CPFloatEltRecord)*_sz);
      for(ORInt k=cLow;k <= cUp;k++)
         _tab[k - cLow] = (CPFloatEltRecord){k,[_c at:k]};
      qsort(_tab, _sz,sizeof(CPFloatEltRecord),(int(*)(const void*,const void*)) &compareCPFloatEltRecords);
      ORFloat ybmin = [_y min];
      ORFloat ybmax = [_y max];
      _from = makeTRInt(_trail, -1);
      _to   = makeTRInt(_trail, -1);
      for(ORInt k=0;k < _sz;k++) {
         if (_tab[k]._val < ybmin || _tab[k]._val > ybmax)
            removeDom(_x, _tab[k]._idx);
         else {
            if (_from._val == -1)
               assignTRInt(&_from, k, _trail);
            assignTRInt(&_to, k, _trail);
         }
      }
      if (bound(_x))
         [_y bind:[_x min]];
      else {
         [_y whenChangeBoundsPropagate:self];
         [_x whenChangePropagate:self];
      }
   }
   return ORSuspend;
}
-(void) propagate
{
   if (bound(_x)) {
      [_y bind:[_c at:[_x min]]];
   } else {
      ORInt k = _from._val;
      while (k < _sz && !memberDom(_x, _tab[k]._idx))
         ++k;
      if (k < _sz) {
         [_y updateMin:_tab[k]._val];
         assignTRInt(&_from, k, _trail);
      }
      else
         failNow();
      k = _to._val;
      while(k >= 0 && !memberDom(_x,_tab[k]._idx))
         --k;
      if (k >= 0) {
         [_y updateMax:_tab[k]._val];
         assignTRInt(&_to, k, _trail);
      }
      else
         failNow();
      ORFloat ybmin = [_y min];
      ORFloat ybmax = [_y max];
      k = _from._val;
      while (k < _sz && _tab[k]._val < ybmin)
         removeDom(_x, _tab[k++]._idx);
      assignTRInt(&_from, k, _trail);
      k = _to._val;
      while (k >= 0 && _tab[k]._val > ybmax)
         removeDom(_x,_tab[k--]._idx);
      assignTRInt(&_to,k,_trail);
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return !bound(_x) && ![_y bound];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"CPFloatElementCstBC: <%02d %@ [ %@ ] == %@ >",_name,_c,_x,_y];
   return buf;
}
@end

@implementation CPFloatVarMinimize
{
   CPFloatVarI*  _x;
   ORFloat        _primalBound;
}
-(id) init: (CPFloatVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _idempotent = TRUE;
   _x = x;
   _primalBound = MAXINT;
   return self;
}
-(id<CPFloatVar>)var
{
   return _x;
}
-(ORStatus) post
{
   if (![_x bound])
      [_x whenChangeMinDo: ^ {
         [_x updateMax: _primalBound];
      } onBehalf:self];
   return ORSuspend;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}
-(void) updatePrimalBound
{
   ORFloat bound = [_x min];
   @synchronized(self) {
      if (bound < _primalBound)
         _primalBound = bound;
   }
}
-(void) tightenPrimalBound: (ORObjectiveValueFloatI*) newBound
{
   @synchronized(self) {
      if ([newBound value] < _primalBound)
         _primalBound = [newBound value];
   }
}
-(void) tightenWithDualBound: (id) newBound
{
   @synchronized(self) {
      if ([newBound isKindOfClass:[ORObjectiveValueIntI class]]) {
         ORFloat b = [((ORObjectiveValueIntI*) newBound) value];
         [_x updateMin: b];
      }
      else if ([newBound isKindOfClass:[ORObjectiveValueFloatI class]]) {
         ORFloat b = [((ORObjectiveValueFloatI*) newBound) value];
         [_x updateMin: b];
      }
   }
}

-(id<ORObjectiveValue>) value
{
   return [[ORObjectiveValueFloatI alloc] initObjectiveValueFloatI: [_x value] minimize:YES];
}
-(ORStatus) check
{
   return tryfail(^ORStatus{
      [_x updateMax: _primalBound];
      return ORSuspend;
   }, ^ORStatus{
      return ORFailure;
   });
}
-(id<ORObjectiveValue>) primalBound
{
   return [[ORObjectiveValueFloatI alloc] initObjectiveValueFloatI: _primalBound minimize:YES];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"Float-MINIMIZE(%@) with f* = %f",[_x description],_primalBound];
   return buf;
}
@end

@implementation CPFloatVarMaximize {
   CPFloatVarI*  _x;
   ORFloat       _primalBound;
}
-(id) init: (CPFloatVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _idempotent = TRUE;
   _x = x;
   _primalBound = -MAXINT;
   return self;
}
-(id<CPFloatVar>)var
{
   return _x;
}
-(ORStatus) post
{
   if (![_x bound])
      [_x whenChangeMaxDo: ^ {
         [_x updateMin: _primalBound];
      } onBehalf:self];
   return ORSuspend;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(id<ORObjectiveValue>) value
{
   return [[ORObjectiveValueFloatI alloc] initObjectiveValueFloatI: [_x value] minimize: NO];
}
-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}
-(void) updatePrimalBound
{
   ORFloat bound = [_x max];
   if (bound > _primalBound)
      _primalBound = bound;
   NSLog(@"primal bound: %f",_primalBound);
}
-(void) tightenPrimalBound: (ORObjectiveValueFloatI*) newBound
{
   if ([newBound value] > _primalBound)
      _primalBound = [newBound value];
}
-(void) tightenWithDualBound: (id) newBound
{
   if ([newBound isKindOfClass:[ORObjectiveValueIntI class]]) {
      ORFloat b = [((ORObjectiveValueIntI*) newBound) value];
      [_x updateMax: b];
   }
   else if ([newBound isKindOfClass:[ORObjectiveValueFloatI class]]) {
      ORFloat b = [((ORObjectiveValueFloatI*) newBound) value];
      [_x updateMax: b];
   }
}

-(ORStatus) check
{
   @try {
      [_x updateMin: _primalBound];
   }
   @catch (ORFailException* e) {
      [e release];
      return ORFailure;
   }
   return ORSuspend;
}
-(id<ORObjectiveValue>) primalBound
{
   return [[ORObjectiveValueFloatI alloc] initObjectiveValueFloatI: _primalBound minimize: NO];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"Float-MAXIMIZE(%@) with f* = %f  [thread: %d]",[_x description],_primalBound,[NSThread threadID]];
   return buf;
}
@end

