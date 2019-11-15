/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPDoubleConstraint.h"
#import "CPDoubleVarI.h"
#import "CPFloatVarI.h"
#import "ORConstraintI.h"
#import <fenv.h>
#import "rationalUtilities.h"

#define PERCENT 5.0

void ulp_computation_d(id<ORRationalInterval> ulp, const double_interval f){
   id<ORRational> tmp0 = [[ORRational alloc] init];
   id<ORRational> tmp1 = [[ORRational alloc] init];
   id<ORRational> tmp2 = [[ORRational alloc] init];
   
   if(f.inf == -INFINITY || f.sup == INFINITY){
      [tmp1 setNegInf];
      [tmp2 setPosInf];
      [ulp set_q:tmp1 and:tmp2];
   }else if(fabs(f.inf) == DBL_MAX || fabs(f.sup) == DBL_MAX){
      [tmp0 set_d: nextafter(DBL_MAX, -INFINITY) - DBL_MAX];
      [tmp1 set_d: 2.0];
      tmp2 = [tmp0 div: tmp1];
      [tmp1 set: tmp2];
      [tmp2 neg];
      [ulp set_q:tmp2 and:tmp1];
   } else{
      ORDouble inf, sup;
      inf = minDbl(nextafter(f.inf, -INFINITY) - f.inf, nextafter(f.sup, -INFINITY) - f.sup);
      sup = maxDbl(nextafter(f.inf, +INFINITY) - f.inf, nextafter(f.sup, +INFINITY) - f.sup);
      
      [tmp0 set_d: inf];
      [tmp1 set_d: 2.0];
      tmp2 = [tmp0 div: tmp1];
      [ulp.low set: tmp2];
      [tmp0 set_d: sup];
      tmp2 = [tmp0 div: tmp1];
      [ulp.up set: tmp2];
   }
   
   [tmp0 release];
   [tmp1 release];
   [tmp2 release];
}

id<ORRationalInterval> compute_eo_add_d(id<ORRationalInterval> eo, const double_interval x, const double_interval y, const double_interval z){
   
   /* First, let see if Sterbenz is applicable */
   if (((0.0 <= x.inf) && (y.sup <= 0.0) && (-y.inf/2.0 <= x.inf) && (x.sup <= -2.0*y.sup)) ||
       ((x.sup <= 0.0) && (0.0 <= y.inf) && (y.sup/2.0 <= -x.sup) && (-x.inf <= 2.0*y.inf))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
   } else if ((((double_cast)((z.inf))).parts.exponent <= 1) && (((double_cast)((z.sup))).parts.exponent <= 1)) {
      /* Hauser theorems:
       3.4.1: if Round(x + y) is denormalized, then Round(x + y) = x + y (provided we use denormalized numbers)
       see p 154. Also apply to subtraction (as x - y = x + (- y))
       3.4.1a: Let u be the least positive normalized float. If abs(x + y) < 2*u then Round(x + y) = x + y
       Hauser, J. R. 1996. Handling floating-point exceptions in numeric programs. ACM Transactions on Pro-
       gramming Languages and Systems 18, 2, 139–174 */
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORDouble tmpf = x.inf + y.inf;
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      id<ORRational> yq = [ORRational rationalWith_d:y.inf];
      
      tmpq = [xq add: yq];
      [yq set_d:tmpf];
      tmpq = [tmpq sub: yq];
      
      eo = [eo proj_inter:tmpq and:tmpq];
      
      [tmpq release];
      [yq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      ulp_computation_d(ulp_q, z);
      eo = [eo proj_inter:ulp_q];
      [ulp_q release];
   }
   
   return eo;
}

id<ORRationalInterval> compute_eo_sub_d(id<ORRationalInterval> eo, const double_interval x, const double_interval y, const double_interval z){
   
   /* First, let see if Sterbenz is applicable (requires gradual underflow (denormalized) or that x-y does not underflow */
   if (((x.inf >= 0.0) && (y.inf >= 0.0) && (y.sup/2.0 <= x.inf) && (x.sup <= 2.0*y.inf)) ||
       ((x.sup <= 0.0) && (y.sup <= 0.0) && (y.inf/2.0 >= x.sup) && (x.inf >= 2.0*y.sup))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
   } else if ((((double_cast)((z.inf))).parts.exponent <= 1) && (((double_cast)((z.sup))).parts.exponent <= 1)) {
      /* Hauser theorems:
       3.4.1: if Round(x + y) is denormalized, then Round(x + y) = x + y (provided we use denormalized numbers)
       see p 154. Also apply to subtraction (as x - y = x + (- y))
       3.4.1a: Let u be the least positive normalized float. If abs(x + y) < 2*u then Round(x + y) = x + y
       Hauser, J. R. 1996. Handling floating-point exceptions in numeric programs. ACM Transactions on Pro-
       gramming Languages and Systems 18, 2, 139–174 */
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORDouble tmpf = x.inf - y.inf;
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      id<ORRational> yq = [ORRational rationalWith_d:y.inf];
      
      tmpq = [xq sub: yq];
      [yq set_d:tmpf];
      tmpq = [tmpq sub: yq];
      
      eo = [eo proj_inter:tmpq and:tmpq];
      
      [tmpq release];
      [yq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      ulp_computation_d(ulp_q, z);
      eo = [eo proj_inter:ulp_q];
      [ulp_q release];
   }
   
   return eo;
}

id<ORRationalInterval> compute_eo_mul_d(id<ORRationalInterval> eo, const double_interval x, const double_interval y, const double_interval z){
   
   /* Check if its a product by a power of 2 */
   if (((x.inf == x.sup) && (((double_cast)((x.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(x.inf) <= y.inf) && (y.sup <= DBL_MAX/fabs(x.inf))) ||
       ((y.inf == y.sup) && (((double_cast)((y.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(y.inf) <= x.inf) && (x.sup <= DBL_MAX/fabs(y.inf)))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORDouble tmpf = x.inf*y.inf;
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      id<ORRational> yq = [ORRational rationalWith_d:y.inf];
      
      tmpq = [xq mul: yq];
      [yq set_d:tmpf];
      tmpq = [tmpq sub: yq];
      
      eo = [eo proj_inter:tmpq and:tmpq];
      
      [tmpq release];
      [yq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      ulp_computation_d(ulp_q, z);
      eo = [eo proj_inter:ulp_q];
      [ulp_q release];
   }
   
   return eo;
}

int checkDivPower2d(double x, double y) { // x/y
   double_cast z;
   z.f = x/y;
   return (z.parts.exponent >= 1);
}

id<ORRationalInterval> compute_eo_div_d(id<ORRationalInterval> eo, const double_interval x, const double_interval y, const double_interval z){
   
   /* Check if its a division by a power of 2 */
   if ((y.inf == y.sup) && (((double_cast)(y.inf)).parts.mantissa == 0) &&
       (((-DBL_MAX <= x.inf) && (x.sup < 0.0) && checkDivPower2d(x.sup, y.inf)) || ((0.0 < x.inf) && (x.sup <= DBL_MAX) && checkDivPower2d(x.inf, y.inf)))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
      
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORDouble tmpf = x.inf/y.inf;
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      id<ORRational> yq = [ORRational rationalWith_d:y.inf];
      
      tmpq = [xq div: yq];
      [yq set_d:tmpf];
      tmpq = [tmpq sub: yq];
      
      eo = [eo proj_inter:tmpq and:tmpq];
      
      [tmpq release];
      [yq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      ulp_computation_d(ulp_q, z);
      eo = [eo proj_inter:ulp_q];
      [ulp_q release];
   }
   
   return eo;
}



//unary minus constraint
@implementation CPDoubleUnaryMinus{
   int _precision;
   int _rounding;
   double_interval _xi;
   double_interval _yi;
}
-(id) init:(CPDoubleVarI*)x eqm:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = makeDoubleInterval(x.min, x.max);
   _yi = makeDoubleInterval(y.min, y.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      if([_y bound]){
         if([_x value] != - [_y value]) failNow();
         assignTRInt(&_active, NO, _trail);
      }else{
         [_y bind:-[_x value]];
         [_y bindError:[[_x errorValue] neg]];
         assignTRInt(&_active, NO, _trail);
      }
   }else if([_y bound]){
      [_x bind:-[_y value]];
      [_x bindError:[[_y errorValue] neg]];
      assignTRInt(&_active, NO, _trail);
   }else {
      updateDoubleInterval(&_xi,_x);
      updateDoubleInterval(&_yi,_y);
      intersectionIntervalD inter;
      id<ORRationalInterval> interError = [[ORRationalInterval alloc] init];
      id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
      id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
      [ex set_q:[_x minErr] and:[_x maxErr]];
      [ey set_q:[_y minErr] and:[_y maxErr]];
      
      double_interval yTmp = makeDoubleInterval(_yi.inf, _yi.sup);
      fpi_minusd(_precision,_rounding, &yTmp, &_xi);
      inter = intersectionD(_y,_yi, yTmp, 0.0f);
      interError = [ey proj_inter:[ex neg]];
      if(inter.changed)
         [_y updateInterval:inter.result.inf and:inter.result.sup];
      if(interError.changed)
         [_y updateIntervalError:interError.low and:interError.up];
      
      updateDoubleInterval(&_yi,_y);
      [ex set_q:[_x minErr] and:[_x maxErr]];
      [ey set_q:[_y minErr] and:[_y maxErr]];
      double_interval xTmp = makeDoubleInterval(_xi.inf, _xi.sup);
      fpi_minusd(_precision,_rounding, &xTmp, &_yi);
      inter = intersectionD(_x,_xi, xTmp, 0.0f);
      interError = [ex proj_inter:[ey neg]];
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
      if(interError.changed)
         [_x updateIntervalError:interError.low and:interError.up];
      
      [interError release];
      [ex release];
      [ey release];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == -%@>",_x,_y];
}
@end


@implementation CPDoubleCast {
   int _precision;
   int _rounding;
   double_interval _resi;
   float_interval _initiali;
}
-(id) init:(CPDoubleVarI*)res equals:(CPFloatVarI*)initial
{
   self = [super initCPCoreConstraint: [res engine]];
   _res = res;
   _initial = initial;
   _resi = makeDoubleInterval(_res.min, _res.max);
   _initiali = makeFloatInterval(_initial.min, _initial.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_res bound])        [_res whenChangeBoundsPropagate:self];
   if(![_initial bound])    [_initial whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_res bound]){
      if(is_eq([_res min],-0.0) && is_eq([_res max],+0.0))
         [_initial updateInterval:[_res min] and:[_res max]];
      else
         [_initial bind:[_res value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithDV([_res min],[_res max],[_initial min],[_initial max])){
      failNow();
   }else {
      updateDoubleInterval(&_resi,_res);
      updateFloatInterval(&_initiali,_initial);
      intersectionIntervalD inter;
      double_interval resTmp = makeDoubleInterval(_resi.inf, _resi.sup);
      fpi_ftod(_precision, _rounding, &resTmp, &_initiali);
      inter = intersectionD(_res, _resi, resTmp, 0.0f);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      
      updateDoubleInterval(&_resi,_res);
      float_interval initialTmp = makeFloatInterval(_initiali.inf, _initiali.sup);
      intersectionInterval inter2;
      fpi_ftod_inv(_precision, _rounding, &initialTmp,&_resi);
      inter2 = intersection(_initial, _initiali, initialTmp, 0.0f);
      if(inter2.changed)
         [_initial updateInterval:inter2.result.inf and:inter2.result.sup];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_res,_initial,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_res,_initial,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_res bound] + ![_initial bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ castedTo %@>",_initial,_res];
}
@end


@implementation CPDoubleEqual
-(id) init:(CPDoubleVarI*)x equals:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      [_y bind:[_x value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      [_x bind:[_y value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithD(_x,_y)){
      failNow();
   }else{
      ORDouble min = maxDbl([_x min], [_y min]);
      ORDouble max = minDbl([_x max], [_y max]);
      [_x updateInterval:min and:max];
      [_y updateInterval:min and:max];
      if(_x.min == _x.max && _y.min == _y.max) //to deal with -0,0
         assignTRInt(&_active, NO, _trail);
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %@>",_x,_y];
}
@end

@implementation CPDoubleEqualc
-(id) init:(CPDoubleVarI*)x and:(ORDouble)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   if(_c == 0.)
      [_x updateInterval:-0.0 and:+0.0];
   else
      [_x bind:_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %16.16e>",_x,_c];
}
@end

@implementation CPDoubleAssign{
   int _precision;
   int _rounding;
}
-(id) init:(CPDoubleVarI*)x set:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   double_interval x, y;
   intersectionIntervalD inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> interError = [[ORRationalInterval alloc] init];
   
   x = makeDoubleInterval([_x min], [_x max]);
   y = makeDoubleInterval([_y min], [_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   
   if(isDisjointWithD(_x,_y)){
      failNow();
   }else if(isDisjointWithDR(_x,_y)){
      failNow();
   }else{
      double_interval xTmp = makeDoubleInterval(x.inf, x.sup);
      fpi_set(_precision, _rounding, &xTmp, &y);
      
      inter = intersectionD(_x, x, xTmp, 0.0f);
      interError = [ex proj_inter:ey];
      
      
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
      if(interError.changed)
         [_x updateIntervalError:interError.low and:interError.up];
      if ((y.inf != inter.result.inf) || (y.sup != inter.result.sup))
         [_y updateInterval:inter.result.inf and:inter.result.sup];
      if ([ey.low neq: interError.low] || [ey.up neq: interError.up])
         [_y updateIntervalError:interError.low and:interError.up];
   }
   [ex release];
   [ey release];
   [interError release];
}
- (void)dealloc
{
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@>",_x,_y];
}
@end

@implementation CPDoubleAssignC
-(id) init:(CPDoubleVarI*)x set:(ORDouble)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   [_x bind:_c];
   [_x bindError:[ORRational rationalWith_d:0]];
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
   return [NSString stringWithFormat:@"<%@ = %16.16e>",_x,_c];
}
@end


@implementation CPDoubleNEqual
-(id) init:(CPDoubleVarI*)x nequals:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
   
}
-(void) post
{
   [self propagate];
   if(![_x bound])[_x whenBindPropagate:self];
   if(![_y bound])[_y whenBindPropagate:self];
}
-(void) propagate
{
   if ([_x bound]) {
      if([_y bound]){
         if ([_x min] == [_y min])
            failNow();
         else{
            if([_x min] == [_y min]){
               [_y updateMin:fp_next_double([_y min])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x min] == [_y max]) {
               [_y updateMax:fp_previous_double([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x max] == [_y min]){
               [_y updateMin:fp_next_double([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x max] == [_y max]) {
               [_y updateMax:fp_previous_double([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
         }
         return;
      }
   }else  if([_y bound]){
      if([_x min] == [_y min]){
         [_x updateMin:fp_next_double([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x min] == [_y max]) {
         [_x updateMin:fp_next_double([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y min]){
         [_x updateMax:fp_previous_double([_x max])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y max]) {
         [_x updateMax:fp_previous_double([_x max])];
         assignTRInt(&_active, NO, _trail);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ != %@>",_x,_y];
}
@end

@implementation CPDoubleNEqualc
-(id) init:(CPDoubleVarI*)x and:(ORDouble)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound]){
      [_x whenBindPropagate:self];
      [_x whenChangeBoundsPropagate:self];
   }
}
-(void) propagate
{
   if ([_x bound]) {
      if([_x min] == _c)
         failNow();
   }else{
      if([_x min] == _c){
         [_x updateMin:fp_next_double(_c)];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == _c){
         [_x updateMax:fp_previous_double(_c)];
         assignTRInt(&_active, NO, _trail);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ != %f>",_x,_c];
}
@end

@implementation CPDoubleLT
-(id) init:(CPDoubleVarI*)x lt:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canFollowD(_x,_y))
      failNow();
   if(isIntersectingWithD(_x,_y)){
      if([_x min] >= [_y min]){
         ORDouble nmin = fp_next_double([_x min]);
         [_y updateMin:nmin];
      }
      if([_x max] >= [_y max]){
         ORDouble pmax = fp_previous_double([_y max]);
         [_x updateMax:pmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
   
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ < %@>",_x,_y];
}
@end

@implementation CPDoubleGT
-(id) init:(CPDoubleVarI*)x gt:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canPrecedeD(_x,_y))
      failNow();
   if(isIntersectingWithD(_x,_y)){
      if([_x min] <= [_y min]){
         ORDouble pmin = fp_next_double([_y min]);
         [_x updateMin:pmin];
      }
      if([_x max] <= [_y max]){
         ORDouble nmax = fp_previous_double([_x max]);
         [_y updateMax:nmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ > %@>",_x,_y];
}
@end


@implementation CPDoubleLEQ
-(id) init:(CPDoubleVarI*)x leq:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canFollowD(_x,_y))
      failNow();
   if(isIntersectingWithD(_x,_y)){
      if([_x min] > [_y min]){
         ORDouble nmin = [_x min];
         [_y updateMin:nmin];
      }
      if([_x max] > [_y max]){
         ORDouble pmax = [_y max];
         [_x updateMax:pmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <= %@>",_x,_y];
}
@end

@implementation CPDoubleGEQ
-(id) init:(CPDoubleVarI*)x geq:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canPrecedeD(_x,_y))
      failNow();
   if(isIntersectingWithD(_x,_y)){
      if([_x min] < [_y min]){
         ORDouble pmin = [_y min];
         [_x updateMin:pmin];
      }
      if([_x max] < [_y max]){
         ORDouble nmax = [_x max];
         [_y updateMax:nmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ >= %@>",_x,_y];
}
@end


@implementation CPDoubleTernaryAdd {
   TRInt _limit;
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y
{
   return [self init:z equals:x plus:y kbpercent:PERCENT];
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   assignTRInt(&_limit, YES, _trail);
   nbConstraint++;
   return self;
}
-(void) post
{
   [self propagate];
   if (![_x bound] || ![_x boundError]) [_x whenChangeBoundsPropagate:self];
   if (![_y bound] || ![_y boundError]) [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ez = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> exTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eyTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ezTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eoTemp = [[ORRationalInterval alloc] init];
   
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   do {
      changed = false;
      zTemp = z;
      fpi_addd(_precision, _rounding, &zTemp, &x, &y);
      inter = intersectionD(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_add_invsub_bounds(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersectionD(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_addxd_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_addyd_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersectionD(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      
      eo = compute_eo_add_d(eo, x, y, z);
      changed |= eo.changed;
      
      if(_limit._val && (z.inf <= z.sup)){
         if(
            ((z.inf >= 0) && (((double_cast)(z.inf)).parts.exponent == ((double_cast)(z.sup)).parts.exponent)) ||
            ((z.sup < 0) && (((double_cast)(z.inf)).parts.exponent == ((double_cast)(z.sup)).parts.exponent))
            ){
            assignTRInt(&limitCounter, limitCounter._val+1, _trail);
            assignTRInt(&_limit, NO, _trail);
         }
      }
      // ============================== ez
      // ex + ey + eo
      ezTemp = [[ex add: ey] add: eo];
      
      ez = [ez proj_inter: ezTemp];
      changed |= ez.changed;
      
      // ============================== eo
      // ez - ex - ey
      eoTemp = [[ez sub: ex] sub: ey];
      
      eo = [eo proj_inter: eoTemp];
      changed |= eo.changed;
      
      // ============================== ex
      // ez - ey - eo
      exTemp = [[ez sub: ey] sub: eo];
      
      ex = [ex proj_inter: exTemp];
      changed |= ex.changed;
      
      // ============================== ey
      // ez - ex - eo
      eyTemp = [[ez sub: ex] sub: eo];
      
      ey = [ey proj_inter: eyTemp];
      changed |= ey.changed;
      
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);
   
   if(gchanged){
      // Cause no propagation on eo is insured
      [_eo updateMin:(eo.low) for:NULL];
      [_eo updateMax:(eo.up) for:NULL];
      
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:(ex.low) and:(ex.up)];
      [_y updateIntervalError:(ey.low) and:(ey.up)];
      [_z updateIntervalError:(ez.low) and:(ez.up)];
      if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
   }
   
   fesetround(FE_TONEAREST);
   [ex release];
   [ey release];
   [ez release];
   [eo release];
   [exTemp release];
   [eyTemp release];
   [ezTemp release];
   [eoTemp release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound] + ![_x boundError] + ![_y boundError] + ![_z boundError];
}
-(id<CPVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x
{
   if([x getId] == [_x getId])
      return _y;
   else if([x getId] == [_y getId])
      return _x;
   return nil;
}
-(ORBool) canLeadToAnAbsorption
{
   return true;
}
//hzi : todo check cancellation for odometrie_10
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
   return 0.0;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ + %@>",_z, _x, _y];
}
@end


@implementation CPDoubleTernarySub {
   TRInt _limit;
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   assignTRInt(&_limit, YES, _trail);
   nbConstraint++;
   return self;
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y
{
   return [self init:z equals:x minus:y kbpercent:PERCENT];
}

-(void) post
{
   [self propagate];
   if (![_x bound] || ![_x boundError]) [_x whenChangeBoundsPropagate:self];
   if (![_y bound] || ![_x boundError]) [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_x boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ez = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> exTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eyTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ezTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eoTemp = [[ORRationalInterval alloc] init];
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   do {
      changed = false;
      zTemp = z;
      fpi_subd(_precision, _rounding, &zTemp, &x, &y);
      inter = intersectionD(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_sub_invsub_bounds(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersectionD(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_subxd_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_subyd_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersectionD(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      eo = compute_eo_sub_d(eo, x, y, z);
      changed |= eo.changed;
      
      if(_limit._val && (z.inf <= z.sup)){
         if(
            ((z.inf >= 0) && (((double_cast)(z.inf)).parts.exponent == ((double_cast)(z.sup)).parts.exponent)) ||
            ((z.sup < 0) && (((double_cast)(z.inf)).parts.exponent == ((double_cast)(z.sup)).parts.exponent))
            ){
            assignTRInt(&limitCounter, limitCounter._val+1, _trail);
            assignTRInt(&_limit, NO, _trail);
         }
      }
      // ============================== ez
      // ex - ey + eo
      ezTemp = [[ex sub: ey] add: eo];
      
      ez = [ez proj_inter: ezTemp];
      changed |= ez.changed;
      
      // ============================== eo
      // ez - (ex - ey)
      eoTemp = [ez sub: [ex sub: ey]];
      
      eo = [eo proj_inter: eoTemp];
      changed |= eo.changed;
      
      // ============================== ex
      // ez + ey - eo
      exTemp = [[ez add: ey] sub: eo];
      
      ex = [ex proj_inter: exTemp];
      changed |= ex.changed;
      
      // ============================== ey
      // ex - ez + eo
      eyTemp = [[ex sub: ez] add: eo];
      
      ey = [ey proj_inter: eyTemp];
      changed |= ey.changed;
      
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);

   if(gchanged){
      // Cause no propagation on eo is insured
      [_eo updateMin:(eo.low) for:NULL];
      [_eo updateMax:(eo.up) for:NULL];
      
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:(ex.low) and:(ex.up)];
      [_y updateIntervalError:(ey.low) and:(ey.up)];
      [_z updateIntervalError:(ez.low) and:(ez.up)];
      if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
   }
   
   fesetround(FE_TONEAREST);
   [ex release];
   [ey release];
   [ez release];
   [eo release];
   [exTemp release];
   [eyTemp release];
   [ezTemp release];
   [eoTemp release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound] + ![_x boundError] + ![_y boundError] + ![_z boundError];
}
-(id<CPVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x
{
   if([x getId] == [_x getId])
      return _y;
   else if([x getId] == [_y getId])
      return _x;
   return nil;
}
-(ORBool) canLeadToAnAbsorption
{
   return true;
}
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
   return 0.0;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
@end

@implementation CPDoubleTernaryMult{
   TRInt _limit;
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x mult:(CPDoubleVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   assignTRInt(&_limit, YES, _trail);
   nbConstraint++;
   return self;
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x mult:(CPDoubleVarI*)y
{
   return [self init:z equals:x mult:y kbpercent:PERCENT];
}
-(void) post
{
   [self propagate];
   if (![_x bound] || ![_x boundError]) [_x whenChangeBoundsPropagate:self];
   if (![_y bound] || ![_x boundError]) [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_x boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged, changed;
   changed = gchanged = false;
   double_interval zTemp, yTemp, xTemp, z, x, y;
   intersectionIntervalD inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ez = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> exTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eyTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ezTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eoTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xrTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> yrTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xr = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> yr = [[ORRationalInterval alloc] init];
   
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   do {
      changed = false;
      zTemp = z;
      fpi_multd(_precision, _rounding, &zTemp, &x, &y);
      inter = intersectionD(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_multxd_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_multyd_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersectionD(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      [xr set_d:x.inf and:x.sup];
      [yr set_d:y.inf and:y.sup];
      
      eo = compute_eo_mul_d(eo, x, y, z);
      changed |= eo.changed;
      
      if(_limit._val && (z.inf <= z.sup)){
         if(
            ((z.inf >= 0) && (((double_cast)(z.inf)).parts.exponent == ((double_cast)(z.sup)).parts.exponent)) ||
            ((z.sup < 0) && (((double_cast)(z.inf)).parts.exponent == ((double_cast)(z.sup)).parts.exponent))
            ){
            assignTRInt(&limitCounter, limitCounter._val+1, _trail);
            assignTRInt(&_limit, NO, _trail);
         }
      }
      // ============================== ez
      // x*ey + y*ex + ex*ey + eo
      ezTemp = [[[[xr mul: ey] add: [yr mul: ex]] add: [ex mul: ey]] add: eo];
      
      ez = [ez proj_inter: ezTemp];
      changed |= ez.changed;
      
      // ============================== eo
      // ez - (x*ey + y*ex + ex*ey)
      eoTemp = [ez sub: [[[xr mul: ey] add: [yr mul: ex]] add: [ex mul: ey]]];
      
      eo = [eo proj_inter: eoTemp];
      changed |= eo.changed;
      
      // ============================== ex
      // (ez - x*ey - eo)/(y + ey)
      exTemp = [[[ez sub: [xr mul: ey]] sub: eo] div: [yr add: ey]];
      
      ex = [ex proj_inter: exTemp];
      changed |= ex.changed;
      
      // ============================== ey
      // (ez - y*ex - eo)/(x + ex)
      eyTemp = [[[ez sub: [yr mul: ex]] sub: eo] div: [xr add: ex]];
      
      ey = [ey proj_inter: eyTemp];
      changed |= ey.changed;
      
      // ============================== x
      // (ez - y*ex - ex*ey - eo)/ey
      xrTemp = [[[[ez sub: [yr mul: ex]] sub: [ex mul: ey]] sub: eo] div: ey];
      
      xr = [xr proj_inter:xrTemp];
      changed |= xr.changed;
      
      x.inf = [[xr low] get_sup_d];
      x.sup = [[xr up] get_inf_d];
      
      // ============================== y
      // (ez - x*ey - ex*ey - eo)/ex
      yrTemp = [[[[ez sub: [xr mul: ey]] sub: [ex mul: ey]] sub: eo] div: ex];
      
      yr = [yr proj_inter:yrTemp];
      changed |= yr.changed;
      
      y.inf = [[yr low] get_sup_d];
      y.sup = [[yr up] get_inf_d];
      
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);

   if(gchanged){
      // Cause no propagation on eo is insured
      [_eo updateMin:(eo.low) for:NULL];
      [_eo updateMax:(eo.up) for:NULL];
      
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:(ex.low) and:(ex.up)];
      [_y updateIntervalError:(ey.low) and:(ey.up)];
      [_z updateIntervalError:(ez.low) and:(ez.up)];
      if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
   }
   
   fesetround(FE_TONEAREST);
   [ex release];
   [ey release];
   [ez release];
   [eo release];
   [exTemp release];
   [eyTemp release];
   [ezTemp release];
   [eoTemp release];
   [xrTemp release];
   [yrTemp release];
   [xr release];
   [yr release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(id<CPDoubleVar>) result
{
   return _z;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound] + ![_x boundError] + ![_y boundError] + ![_z boundError];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ * %@>",_z, _x, _y];
}
@end

@implementation CPDoubleTernaryDiv {
   TRInt _limit;
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x div:(CPDoubleVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   assignTRInt(&_limit, YES, _trail);
   nbConstraint++;
   return self;
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x div:(CPDoubleVarI*)y
{
   return [self init:z equals:x div:y kbpercent:PERCENT];
}
-(void) post
{
   [self propagate];
   if (![_x bound] || ![_x boundError]) [_x whenChangeBoundsPropagate:self];
   if (![_y bound] || ![_x boundError]) [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_x boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ez = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> exTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eyTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ezTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eoTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xrTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> yrTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xr = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> yr = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> D = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> D1 = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> D2 = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> d1 = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> d2 = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> tmp = [[ORRationalInterval alloc] init];
   
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   do {
      changed = false;
      zTemp = z;
      fpi_divd(_precision, _rounding, &zTemp, &x, &y);
      inter = intersectionD(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_divxd_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_divyd_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersectionD(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      [xr set_d:x.inf and:x.sup];
      [yr set_d:y.inf and:y.sup];
      
      eo = compute_eo_div_d(eo, x, y, z);
      changed |= eo.changed;
      
      if(_limit._val && (z.inf <= z.sup)){
         if(
            ((z.inf >= 0) && (((double_cast)(z.inf)).parts.exponent == ((double_cast)(z.sup)).parts.exponent)) ||
            ((z.sup < 0) && (((double_cast)(z.inf)).parts.exponent == ((double_cast)(z.sup)).parts.exponent))
            ){
            assignTRInt(&limitCounter, limitCounter._val+1, _trail);
            assignTRInt(&_limit, NO, _trail);
         }
      }
      // ============================== ez
      // (y*ex - x*ey)/(y*(y + ey)) + eo
      ezTemp = [[[[yr mul: ex] sub: [xr mul: ey]] div: [yr mul: [yr add: ey]]] add: eo];
      
      ez = [ez proj_inter: ezTemp];
      changed |= ez.changed;
      
      // ============================== eo
      // ez - (y*ex - x*ey)/(y*(y + ey))
      eoTemp = [ez sub: [[[yr mul: ex] sub: [xr mul: ey]] div: [yr mul: [yr add: ey]]]];
      
      eo = [eo proj_inter: eoTemp];
      changed |= eo.changed;
      
      // ============================== ex
      // (ez - eo)*(y + ey) + (x*ey)/y
      exTemp = [[[ez sub: eo] mul: [yr add: ey]] add: [[xr mul: ey] div: yr]];
      
      ex = [ex proj_inter: exTemp];
      changed |= ex.changed;
      
      // ============================== ey
      // (ex - ez*y + eo*y)/(ez - eo + (x/y))
      eyTemp = [[[ex sub: [ez mul: yr]] add: [eo mul: yr]] div: [[ez sub: eo] add: [xr div: yr]]];
      
      ey = [ey proj_inter: eyTemp];
      changed |= ey.changed;
      
      // ============================== x
      // ((eo-ez) * y * (y+ey) + y*ex)/ey
      xrTemp = [[[[[eo sub: ez] mul: yr] mul: [yr add:ey]] add: [yr mul: ex]] div: ey];
      
      xr = [xr proj_inter:xrTemp];
      changed |= xr.changed;
      
      x.inf = [[xr low] get_sup_d];
      x.sup = [[xr up] get_inf_d];
      
      // ============================== y
      // min(d1, d2), max(d1, d2)
      // d1 = (ex - (ez - eo)*ey - sqrt(D))/(2*(ez - eo))
      // d2 = (ex - (ez - eo)*ey + sqrt(D))/(2*(ez - eo))
      // D = [0, +INF] inter ((ez - eo)*ey - ex)^2 + 4*(ez - eo)*ey*x
      
      //      [tmp set_d:4.0 and:4.0];
      //      D = [[[[[ez sub: eo] mul: ey] sub: ex] mul: [[[ez sub: eo] mul: ey] sub: ex]] add: [[[tmp mul: [ez sub: eo]] mul: ey] mul: xr]];
      //      [tmp set_d:0.0 and:+INFINITY];
      //      D1 = [tmp proj_inter:D];
      //      if(![D1 empty]){
      //         tmp = [ex sub: [[ez sub: eo] mul: ey]];
      //         fesetround(FE_DOWNWARD);
      //         [D2.low set_d: sqrt([D1.low get_sup_d])];
      //         fesetround(FE_UPWARD);
      //         [D2.up set_d: sqrt([D1.up get_inf_d])];
      //         fesetround(FE_TONEAREST);
      //         d1 = [tmp sub: D2];
      //         d2 = [tmp add: D2];
      //         [tmp set_d:2.0 and:2.0];
      //         tmp = [tmp mul: [ez sub: eo]];
      //         d1 = [d1 div: tmp];
      //         d2 = [d2 div: tmp];
      //
      //         [yrTemp set_q:minQ(d1.low, d2.low) and:maxQ(d1.up, d2.up)];
      //         yr = [yr proj_inter:yrTemp];
      //         changed |= yr.changed;
      //
      //         y.inf = [[yr low] get_sup_d];
      //         y.sup = [[yr up] get_inf_d];
      //      }
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);
   
   if(gchanged){
      // Cause no propagation on eo is insured
      [_eo updateMin:(eo.low) for:NULL];
      [_eo updateMax:(eo.up) for:NULL];
      
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:(ex.low) and:(ex.up)];
      [_y updateIntervalError:(ey.low) and:(ey.up)];
      [_z updateIntervalError:(ez.low) and:(ez.up)];
      if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
   }
   
   fesetround(FE_TONEAREST);
   [ex release];
   [ey release];
   [ez release];
   [eo release];
   [exTemp release];
   [eyTemp release];
   [ezTemp release];
   [eoTemp release];
   [xrTemp release];
   [yrTemp release];
   [xr release];
   [yr release];
   [D release];
   [D1 release];
   [D2 release];
   [d1 release];
   [d2 release];
   [tmp release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound] + ![_x boundError] + ![_y boundError] + ![_z boundError];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ / %@>",_z, _x, _y];
}
@end

@implementation CPDoubleReifyNEqual
-(id) initCPReify:(CPIntVar*)b when:(CPDoubleVarI*)x neq:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}

-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if ([_x bound] || [_x min] == [_x max]){            // TRUE <=> (y != c)
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_y to:[_x min]]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }else  if ([_y bound] || [_y min] == [_y max]) {     // TRUE <=> (x != c)
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:[_y min]]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_x bound]){
         [_y bind:[_x min]];
         assignTRInt(&_active, NO, _trail);
         return;
      } else if ([_y bound]){
         [_x bind:[_y min]];
         assignTRInt(&_active, NO, _trail);
         return;
      }else {                    // FALSE <=> (x == y)
         [_x updateInterval:[_y min] and:[_y max]];
         [_y updateInterval:[_x min] and:[_x max]];
      }
   }
   else {                        // b is unknown
      if ([_x bound] && [_y bound]){
         [_b bind: [_x min] != [_y min]];
         assignTRInt(&_active, NO, _trail);
      } else if ([_x max] < [_y min] || [_y max] < [_x min]){
         [_b bind:YES];
         assignTRInt(&_active, NO, _trail);
         
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyNEqual:%02d %@ <=> (%@ != %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] +  ![_y bound] + ![_b bound];
}
@end

@implementation CPDoubleReifyEqual
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPDoubleVarI*)x eqi:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}

-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if ([_x bound]) {           // TRUE <=> (y == c)
         assignTRInt(&_active, 0, _trail);
         [_y bind:[_x min]];
      }else  if ([_y bound]) {     // TRUE <=> (x == c)
         assignTRInt(&_active, 0, _trail);
         [_x bind:[_y min]];
      } else {
         [_x updateInterval:[_y min] and:[_y max]];
         [_y updateInterval:[_x min] and:[_x max]];
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_x bound] || [_x min] == [_x max] )
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_y to:[_x min]]]; // Rewrite as min(x)!=y  (addInternal can throw)
      else if ([_y bound] || [_y min] == [_y max])
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:[_y min]]]; // Rewrite as min(y)!=x  (addInternal can throw)
   }
   else {                        // b is unknown
      if (([_x bound] && [_y bound]) || ([_x min] == [_x max] &&  [_y min] == [_y max]))
         [_b bind: [_x min] == [_y min]];
      else if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:NO];
   }
   if(([_b bound] && [_x bound] && [_y bound])  || ([_b bound] && ([_x min] == [_x max] &&  [_y min] == [_y max]))) assignTRInt(&_active, 0, _trail);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyEqual:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] +  ![_y bound] + ![_b bound];
}
@end

@implementation CPDoubleReifyGThen
-(id) initCPReifyGThen:(CPIntVar*)b when:(CPDoubleVarI*)x gti:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         if(canPrecedeD(_x,_y))
            failNow();
         if(isIntersectingWithD(_x,_y)){
            if([_x min] <= [_y min]){
               ORDouble pmin = fp_next_double([_y min]);
               [_x updateMin:pmin];
            }
            if([_x max] <= [_y max]){
               ORDouble nmax = fp_previous_double([_x max]);
               [_y updateMax:nmax];
            }
         }
      } else {
         if ([_x bound]) { // c <= y
            [_y updateMin:[_x min]];
         } else {         // x <= y
            [_y updateMin:[_x min]];
            [_x updateMax:[_y max]];
         }
      }
   } else {
      if ([_y max] < [_x min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] <= [_y min]){
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqual:%02d %@ <=> (%@ > %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_x bound] + ![_b bound];
}
@end


@implementation CPDoubleReifyGEqual
-(id) initCPReifyGEqual:(CPIntVar*)b when:(CPDoubleVarI*)x geqi:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_y updateMax:[_x max]];
         [_x updateMin:[_y min]];
      } else {
         [_y updateMax:fp_next_double([_x max])];
         [_x updateMin:fp_previous_double([_y min])];
      }
   } else {
      if ([_y max] <= [_x min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] < [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqual:%02d %@ <=> (%@ >= %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_x bound] + ![_b bound];
}
@end


@implementation CPDoubleReifyLEqual
-(id) initCPReifyLEqual:(CPIntVar*)b when:(CPDoubleVarI*)x leqi:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_x updateMax:[_y max]];
         [_y updateMin:[_x min]];
      } else {
         [_x updateMin:fp_next_double([_y min])];
         [_y updateMax:fp_previous_double([_x max])];
      }
   } else {
      if ([_x max] <= [_y min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyLEqual:%02d %@ <=> (%@ <= %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}
@end


@implementation CPDoubleReifyLThen
-(id) initCPReifyLThen:(CPIntVar*)b when:(CPDoubleVarI*)x lti:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         if(canFollowD(_x,_y))
            failNow();
         if(isIntersectingWithD(_x,_y)){
            if([_x min] >= [_y min]){
               ORDouble nmin = fp_next_double([_x min]);
               [_y updateMin:nmin];
            }
            if([_x max] >= [_y max]){
               ORDouble pmax = fp_previous_double([_y max]);
               [_x updateMax:pmax];
            }
         }
      } else {
         [_y updateMax:[_x max]];
         [_x updateMin:[_y min]];
      }
   } else {
      if ([_x max] < [_y min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] >= [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyLThen:%02d %@ <=> (%@ < %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}
@end




@implementation CPDoubleReifyEqualc
-(id) initCPReifyEqualc:(CPIntVar*)b when:(CPDoubleVarI*)x eqi:(ORDouble)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   if ([_b bound]) {
      if ([_b min] == true)
         [_x bind:_c];
      else
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
   }
   else if ([_x bound])
      [_b bind:[_x min] == _c];
   else if (![_x member:_c])
      [_b bind:false];
   else {
      [_b setBindTrigger: ^ {
         if ([_b min] == true) {
            [_x bind:_c];
         } else {
            [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
         }
      } onBehalf:self];
      [_x whenChangeBoundsDo: ^ {
         if ([_x bound])
            [_b bind:[_x min] == _c];
         else if (![_x member:_c])
            [_b remove:true];
      } onBehalf:self];
      [_x whenBindDo: ^ {
         [_b bind:[_x min] == _c];
      } onBehalf:self];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyEqual:%02d %@ <=> (%@ == %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end

@implementation CPDoubleReifyLEqualc
-(id) initCPReifyLEqualc:(CPIntVar*)b when:(CPDoubleVarI*)x leqi:(ORDouble)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMax:_c];
      else
         [_x updateMin:fp_next_double(_c)];
   } else {
      if ([_x min] > _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, NO);
      } else if ([_x max] <= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, YES);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyLThen:%02d %@ <=> (%@ <= %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPDoubleReifyLThenc
-(id) initCPReifyLThenc:(CPIntVar*)b when:(CPDoubleVarI*)x lti:(ORDouble)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      if (minDom(_b))
         [_x updateMax:fp_previous_double(_c)];
      else
         [_x updateMin:_c];
      assignTRInt(&_active, NO, _trail);
   } else {
      if ([_x min] >= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, NO);
      } else if ([_x max] < _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, YES);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyLThenc:%02d %@ <=> (%@ < %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPDoubleReifyNotEqualc
-(id) initCPReifyNotEqualc:(CPIntVar*)b when:(CPDoubleVarI*)x neqi:(ORDouble)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   if ([_b bound]) {
      if ([_b min] == true)
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
      else
         [_x bind:_c];
   }
   else if ([_x bound])
      [_b bind:[_x min] != _c];
   else if (![_x member:_c])
      [_b remove:false];
   else {
      [_b whenBindDo: ^void {
         if ([_b min]==true)
            [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
         else
            [_x bind:_c];
      } onBehalf:self];
      [_x whenChangeBoundsDo:^{
         if ([_x bound])
            [_b bind:[_x min] != _c];
         else if (![_x member:_c])
            [_b remove:false];
      } onBehalf:self];
      [_x whenBindDo: ^(void) { [_b bind:[_x min] != _c];} onBehalf:self];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyNotEqualc:%02d %@ <=> (%@ != %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end

@implementation CPDoubleReifyGEqualc
-(id) initCPReifyGEqualc:(CPIntVar*)b when:(CPDoubleVarI*)x geqi:(ORDouble)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post  // b <=>  x >= c
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMin:_c];
      else
         [_x updateMax:fp_previous_double(_c)];
   } else {
      if ([_x min] >= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] < _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqualc:%02d %@ <=> (%@ >= %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPDoubleReifyGThenc
-(id) initCPReifyGThenc:(CPIntVar*)b when:(CPDoubleVarI*)x gti:(ORDouble)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post  // b <=>  x > c
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMin:fp_next_double(_c)];
      else
         [_x updateMax:_c];
   } else {
      if ([_x min] > _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] <= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqualc:%02d %@ <=> (%@ >= %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end

@implementation CPDoubleAbs{
   int _precision;
   int _rounding;
   double_interval _xi;
   double_interval _resi;
}
-(id) init:(CPDoubleVarI*)res eq:(CPDoubleVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeDoubleInterval(x.min, x.max);
   _resi = makeDoubleInterval(res.min, res.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_res bound])  [_res whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      if([_res bound]){
         if(([_res value] !=  -[_x value]) && ([_res value] != [_x value])) failNow();
         assignTRInt(&_active, NO, _trail);
      }else{
         [_res bind:([_x value] >= 0) ? [_x value] : -[_x value]];
         assignTRInt(&_active, NO, _trail);
      }
   }else if([_res bound]){
      if([_x member:-[_res value]]){
         if([_x member:[_res value]])
            [_x updateInterval:-[_res value] and:[_res value]];
         else
            [_x bind:-[_res value]];
      }else if([_x member:[_res value]])
         [_x bind:[_res value]];
      else
         failNow();
   }else {
      updateDoubleInterval(&_xi,_x);
      updateDoubleInterval(&_resi,_res);
      intersectionIntervalD inter;
      double_interval resTmp = makeDoubleInterval(_res.min, _res.max);
      fpi_fabsd(_precision, _rounding, &resTmp, &_xi);
      inter = intersectionD(_res, _resi, resTmp, 0.0f);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      updateDoubleInterval(&_xi,_x);
      double_interval xTmp = makeDoubleInterval(_x.min, _x.max);
      fpi_fabs_invd(_precision,_rounding, &xTmp, &_resi);
      inter = intersectionD(_x, _xi, xTmp, 0.0f);
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_res bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == |%@|>",_res,_x];
}
@end

@implementation CPDoubleSqrt{
   int _precision;
   int _rounding;
   double_interval _xi;
   double_interval _resi;
}
-(id) init:(CPDoubleVarI*)res eq:(CPDoubleVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeDoubleInterval(x.min, x.max);
   _resi = makeDoubleInterval(res.min, res.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_res bound])  [_res whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   updateDoubleInterval(&_xi,_x);
   updateDoubleInterval(&_resi,_res);
   intersectionIntervalD inter;
   double_interval resTmp = makeDoubleInterval(_resi.inf, _resi.sup);
   fpi_sqrtd(_precision,_rounding, &resTmp, &_xi);
   inter = intersectionD(_res, _resi, resTmp, 0.0f);
   if(inter.changed)
      [_res updateInterval:inter.result.inf and:inter.result.sup];
   
   updateDoubleInterval(&_xi,_x);
   double_interval xTmp = makeDoubleInterval(_xi.inf, _xi.sup);
   fpi_sqrtd_inv(_precision,_rounding, &xTmp, &_resi);
   inter = intersectionD(_x, _xi, xTmp, 0.0f);
   if(inter.changed)
      [_x updateInterval:inter.result.inf and:inter.result.sup];
   if([_res bound] && [_x bound]){
      assignTRInt(&_active, NO, _trail);
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_res bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == sqrt(%@)>",_res,_x];
}
@end
