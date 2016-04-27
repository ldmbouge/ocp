/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPRealConstraint.h"
#import "CPIntVarI.h"
#import "CPRealVarI.h"

@implementation CPRealSquareBC

-(id)initCPRealSquareBC:(CPRealVarI*)z equalSquare:(CPRealVarI*)x  // z == x^2
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _z = z;
   return self;
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if (![_z bound])
      [_z whenChangeBoundsPropagate:self];
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
   return [NSMutableString stringWithFormat:@"<CPRealSquareBC:%02d %@ == %@^2>",_name,_z,_x];
}
@end

@implementation CPRealWeightedVarBC

-(id)initCPRealWeightedVarBC:(CPRealVarI*)z equal:(CPRealVarI*)x weight: (CPRealParamI*)w // z = w * x, for constant w
{
    self = [super initCPCoreConstraint:[x engine]];
    _x = x;
    _z = z;
    _w = w;
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
    // Make sure weight is not zero
    if(fabs([_w value]) < 1e-8) {
        [_z updateInterval: createORI2(0.0, 0.0)];
        return;
    }
    ORNarrowing xs = ORNone, zs = ORNone;
    do {
        if ([_x bound]) {
            zs = [_z updateInterval:ORIMul(createORI1([_w value]), [_x bounds])];
            break;
        } else if ([_z bound]) {
            xs = [_x updateInterval:ORIDiv([_x bounds], createORI1([_w value]))];
            break;
        } else {
            ORInterval xb = [_x bounds];
            ORInterval wb = createORI1([_w value]);
            zs = [_z updateInterval:ORIMul(xb, wb)];
            ORInterval zb = [_z bounds];
            xs = [_x updateInterval:ORIDiv(zb, wb)];
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
    return [NSMutableString stringWithFormat:@"<CPFloatWeightedVarBC:%02d %@ == %@ * %@>",_name,_z,_w,_x];
}
@end

@implementation CPRealEquationBC
-(id)init:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs eqi:(ORDouble)c   // sum(i in S) c_i * x_i == c  [[ saved constant is -c ]]
{
   self = [super initCPCoreConstraint:(id)[x[x.range.low] engine]];
   _x = x;
   _coefs = coefs;
   _c = - c;
   return self;
}

-(void) post
{
   [self propagate];
   [_x enumerateWith:^(CPRealVarI* obj, int k) {
      if (![obj bound])
         [obj whenChangeBoundsPropagate:self];
   }];
}

-(void) propagate
{
   ORIReady();
   BOOL changed = NO;
   do {
      __block ORInterval S = createORI1(_c);
      [_x enumerateWith:^(CPRealVarI* xk,int k) {
         S = ORIAdd(S,ORIMul([xk bounds],createORI1([_coefs at:k])));
         if (ORIEmpty(S))
            @throw [[ORExecutionError alloc] initORExecutionError:"interval empty in RealEquation"];
      }];
      changed = NO;
      for(ORInt i=_x.low;i <= _x.up;i++) {
         ORDouble ci = [_coefs at:i];
         CPRealVarI* xi = (id)_x[i];
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
   [_x enumerateWith:^(id<CPRealVar> obj, int idx) {
      nb += ![obj bound];
   }];
   return nb;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPRealEquationBC:%02d %@ %@ + (%f) == 0>",_name,_x,_coefs,_c];
}
@end

@implementation CPRealINEquationBC
-(id)init:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs leqi:(ORDouble)c   // sum(i in S) c_i * x_i <= c  [[ saved constant is -c ]]
{
   self = [super initCPCoreConstraint:(id)[x[x.range.low] engine]];
   _x = x;
   _coefs = coefs;
   _c = - c;
   return self;
}
-(void) post
{
   [self propagate];
   [_x enumerateWith:^(CPRealVarI* obj, int k) {
      ORDouble ck = [_coefs at:k];
      if (ck > 0) {
         if (![obj bound])
            [obj whenChangeMinPropagate:self];
      } else if (ck < 0) {
         if (![obj bound])
            [obj whenChangeMaxPropagate:self];
      }
   }];
}
-(void) propagate
{
   ORIReady();
   BOOL changed = NO;
   do {
      __block ORInterval S = createORI1(_c);
      [_x enumerateWith:^(CPRealVarI* xk,int k) {
         S = ORIAdd(S,ORIMul([xk bounds],createORI1([_coefs at:k])));
      }];
      if (ORISurePositive(S))
         failNow();
      changed = NO;
      for(ORInt i=_x.low;i <= _x.up;i++) {
         ORDouble ci = [_coefs at:i];
         CPRealVarI* xi = (id)_x[i];
         ORInterval xii  = xi.bounds;
         ORInterval TMP = ORISubPointwise(S, ORIMul(xii, ci > 0 ? createORI1(ci) : ORISwap(createORI1(ci))));
         ORInterval NEW = ORIDiv(ORIOpposite(TMP), createORI1(ci));
         ORNarrowing nrw = ORINarrow(xii, NEW);
         switch(nrw) {
            case ORUp: {
               if (ci>0) {
                  [xi updateMax:ORIUp(NEW)];
                  changed |= true;
               }
            }break;
            case ORLow: {
               if (ci < 0) {
                  [xi updateMin:ORILow(NEW)];
                  changed |= true;
               }
            }break;
            case ORBoth: {
               if (ci > 0)
                  [xi updateMax:ORIUp(NEW)];
               else
                  [xi updateMin:ORILow(NEW)];
               changed |= true;
            }
            case ORNone:break;
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
   [_x enumerateWith:^(id<CPRealVar> obj, int idx) {
      nb += ![obj bound];
   }];
   return nb;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPRealINEquationBC:%02d %@ %@ + (%f) <= 0>",_name,_x,_coefs,_c];
}
@end

@implementation CPRealEqualc
-(id) init:(CPRealVarI*)x and:(ORDouble)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   [_x bind:_c];
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



typedef struct CPRealEltRecordTag {
   ORInt   _idx;
   ORDouble _val;
} CPRealEltRecord;

@implementation CPRealElementCstBC {
   CPRealEltRecord* _tab;
   ORInt              _sz;
   TRInt            _from;
   TRInt              _to;
}

-(id) init: (CPIntVar*) x indexCstArray:(id<ORDoubleArray>) c equal:(CPRealVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
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
int compareCPRealEltRecords(const CPRealEltRecord* r1,const CPRealEltRecord* r2)
{
   ORInt d1 = r1->_val - r2->_val;
   if (d1==0)
      return r1->_idx - r2->_idx;
   else
      return d1;
}
-(void) post
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
      _tab = malloc(sizeof(CPRealEltRecord)*_sz);
      for(ORInt k=cLow;k <= cUp;k++)
         _tab[k - cLow] = (CPRealEltRecord){k,[_c at:k]};
      qsort(_tab, _sz,sizeof(CPRealEltRecord),(int(*)(const void*,const void*)) &compareCPRealEltRecords);
      ORDouble ybmin = [_y min];
      ORDouble ybmax = [_y max];
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
      ORDouble ybmin = [_y min];
      ORDouble ybmax = [_y max];
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
   [buf appendFormat:@"CPRealElementCstBC: <%02d %@ [ %@ ] == %@ >",_name,_c,_x,_y];
   return buf;
}
@end

@implementation CPRealVarMinimize
{
   CPRealVarI*  _x;
   ORDouble        _primalBound;
}
-(id) init: (CPRealVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = MAXINT;
   return self;
}
-(id<CPRealVar>)var
{
   return _x;
}
-(ORBool)   isMinimization
{
   return YES;
}
-(void) post
{
   _primalBound = MAXINT;
   if (![_x bound])
      [_x whenChangeMinDo: ^ {
         [_x updateMax: _primalBound];
      } onBehalf:self];
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
   ORDouble bound = [_x min];
   @synchronized(self) {
      if (bound < _primalBound)
          _primalBound = bound - 0.000001;
   }
}
-(void) tightenPrimalBound: (id<ORObjectiveValueReal>) newBound
{
   @synchronized(self) {
      if ([newBound value] < _primalBound)
         _primalBound = [newBound value];
   }
}
-(void) tightenWithDualBound: (id) newBound
{
   @synchronized(self) {
      
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         ORDouble b = [((id<ORObjectiveValueInt>) newBound) value];
         [_x updateMin: b];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         ORDouble b = [((id<ORObjectiveValueReal>) newBound) value];
         [_x updateMin: b];
      }
   }
}

-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueReal:_x.value minimize:YES];
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
   return [ORFactory objectiveValueReal:_primalBound minimize:YES];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueReal:[_x min] minimize:YES];
}
-(ORBool)   isBound
{
    return [_x bound];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"Real-MINIMIZE(%@) with f* = %f",[_x description],_primalBound];
   return buf;
}
@end

@implementation CPRealVarMaximize {
   CPRealVarI*  _x;
   ORDouble       _primalBound;
}
-(id) init: (CPRealVarI*) x
{
    self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = -MAXINT;
   return self;
}
-(id<CPRealVar>)var
{
   return _x;
}
-(ORBool)   isMinimization
{
   return NO;
}
-(void) post
{
   if (![_x bound])
      [_x whenChangeMaxDo: ^ {
         [_x updateMin: _primalBound];
      } onBehalf:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueReal:_x.value minimize:NO];
}
-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}
-(void) updatePrimalBound
{
   ORDouble bound = [_x max];
   if (bound > _primalBound)
      _primalBound = bound;
   NSLog(@"primal bound: %f",_primalBound);
}
-(void) tightenPrimalBound: (id<ORObjectiveValueReal>) newBound
{
   if ([newBound value] > _primalBound)
      _primalBound = [newBound value];
}
-(void) tightenWithDualBound: (id) newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      ORDouble b = [((id<ORObjectiveValueInt>) newBound) value];
      [_x updateMax: b];
   }
   else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      ORDouble b = [((id<ORObjectiveValueReal>) newBound) value];
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
   return [ORFactory objectiveValueReal:_primalBound minimize:NO];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueReal:[_x max] minimize:NO];
}

-(ORBool)   isBound
{
    return [_x bound];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"Real-MAXIMIZE(%@) with f* = %f  [thread: %d]",[_x description],_primalBound,[NSThread threadID]];
   return buf;
}
@end


