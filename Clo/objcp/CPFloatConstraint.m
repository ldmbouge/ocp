/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFoundation/ORFoundation.h"
#import "CPFloatConstraint.h"
#import "CPFloatVarI.h"
#import "CPEngineI.h"

@implementation CPFloatSquareBC

-(id)initCPFloatSquareBC:(CPFloatVarI*)z equalSquare:(CPFloatVarI*)x  // z == x^2
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _z = z;
   return self;
}
-(ORStatus)post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if (![_z bound])
      [_z whenChangeBoundsPropagate:self];
   return ORSuspend;
}
-(void)propagate
{
   ORIReady();
   ORStatus xs = ORNoop,zs = ORNoop;
   do {
      _todo = CPChecked;
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
   } while (zs != ORNoop || xs != ORNoop || _todo == CPTocheck);
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
   return self;
}
-(ORStatus)post
{
   [self propagate];
   [_x enumerateWith:^(CPFloatVarI* obj, int k) {
      if (![obj bound])
         [obj whenChangeBoundsPropagate:self];
   }];
   return ORSuspend;
}
-(void)propagate
{
   ORIReady();
   BOOL changed = NO;
   do {
      _todo = CPChecked;
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
         if (update) [xi updateInterval:NEW];
      }
   } while (changed || _todo == CPTocheck);
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
   return self;
}
-(ORStatus)post
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
-(void)propagate
{
   ORIReady();
   BOOL changed = NO;
   do {
      _todo = CPChecked;
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
            else [xi updateMin:ORILow(NEW)];
         }
      }
   } while (changed || _todo == CPTocheck);
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

