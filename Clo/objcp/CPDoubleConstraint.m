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

id<ORRationalInterval> ulp_computation_d(const double_interval f){
   id<ORRationalInterval> ulp = [[ORRationalInterval alloc] init];
   id<ORRational> tmp0 = [[ORRational alloc] init];
   id<ORRational> tmp1 = [[ORRational alloc] init];
   id<ORRational> tmp2 = [[ORRational alloc] init];
   id<ORRational> tmp3 = [[ORRational alloc] init];
   
   if(f.inf == -INFINITY || f.sup == INFINITY){
      [tmp1 setNegInf];
      [tmp2 setPosInf];
      [ulp set_q:tmp1 and:tmp2];
   }else if(fabs(f.inf) == DBL_MAX || fabs(f.sup) == DBL_MAX){
      [tmp0 set_d: nextafter(DBL_MAX, -INFINITY) - DBL_MAX];
      [tmp1 set_d: 2.0];
      [tmp2 set: [tmp0 div: tmp1]];
      [tmp3 set: [tmp0 div: tmp1]];
      [ulp set_q:[tmp2 neg] and:tmp3];
   } else{
      ORDouble inf, sup;
//      id<ORRational> nextInf = [[ORRational alloc] init];
//      id<ORRational> nextSup = [[ORRational alloc] init];
//      id<ORRational> infQ = [[ORRational alloc] init];
//      id<ORRational> supQ = [[ORRational alloc] init];
      

      inf = minDbl(nextafter(f.inf, -INFINITY) - f.inf, nextafter(f.sup, -INFINITY) - f.sup);
      sup = maxDbl(nextafter(f.inf, +INFINITY) - f.inf, nextafter(f.sup, +INFINITY) - f.sup);
      
//      [infQ set_d:f.inf];
//      [supQ set_d:f.sup];
//
//      [nextInf set_d:nextafter(f.inf, -INFINITY)];
//      [nextSup set_d:nextafter(f.sup, -INFINITY)];
//      [tmp0 set: minQ([nextInf sub:infQ], [nextSup sub: supQ])];
//
//      [nextInf set_d:nextafter(f.inf, +INFINITY)];
//      [nextSup set_d:nextafter(f.sup, +INFINITY)];
//      [tmp3 set: maxQ([nextInf sub:infQ], [nextSup sub: supQ])];
//
//      [infQ release];
//      [supQ release];
//      [nextInf release];
//      [nextSup release];
      
      [tmp0 set_d: inf];
      [tmp1 set_d: 2.0];
      [ulp.low set: [tmp0 div: tmp1]];
      [tmp3 set_d: sup];
      [ulp.up set: [tmp3 div: tmp1]];
   }
   
   [tmp0 release];
   [tmp1 release];
   [tmp2 release];
   [tmp3 release];
   [ulp autorelease];
   
   return ulp;
}

id<ORRationalInterval> compute_eo_add_d(const double_interval x, const double_interval y, const double_interval z)
{
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   /* First, let see if Sterbenz is applicable */
   if (((0.0 <= x.inf) && (y.sup <= 0.0) && (-y.inf/2.0 <= x.inf) && (x.sup <= -2.0*y.sup)) ||
       ((x.sup <= 0.0) && (0.0 <= y.inf) && (y.sup/2.0 <= -x.sup) && (-x.inf <= 2.0*y.inf))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      [eo set_q:zero and:zero];
      [zero release];
   } else if ((((double_cast)((z.inf))).parts.exponent <= 1) && (((double_cast)((z.sup))).parts.exponent <= 1)) {
      /* Hauser theorems:
       3.4.1: if Round(x + y) is denormalized, then Round(x + y) = x + y (provided we use denormalized numbers)
       see p 154. Also apply to subtraction (as x - y = x + (- y))
       3.4.1a: Let u be the least positive normalized float. If abs(x + y) < 2*u then Round(x + y) = x + y
       Hauser, J. R. 1996. Handling floating-point exceptions in numeric programs. ACM Transactions on Pro-
       gramming Languages and Systems 18, 2, 139–174 */
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      [eo set_q:zero and:zero];
      [zero release];
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORDouble tmpf = x.inf + y.inf;
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      id<ORRational> yq = [ORRational rationalWith_d:y.inf];
      
      [tmpq set: [xq add: yq]];
      [yq set_d:tmpf];
      [tmpq set: [tmpq sub: yq]];
      [eo set_q:tmpq and:tmpq];
      
      [tmpq release];
      [yq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      [ulp_q set: ulp_computation_d(z)];
      [eo set: ulp_q];
      [ulp_q release];
   }
   [eo autorelease];
   return eo;
}

id<ORRationalInterval> compute_eo_sub_d(const double_interval x, const double_interval y, const double_interval z)
{
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   /* First, let see if Sterbenz is applicable (requires gradual underflow (denormalized) or that x-y does not underflow */
   if (((x.inf >= 0.0) && (y.inf >= 0.0) && (y.sup/2.0 <= x.inf) && (x.sup <= 2.0*y.inf)) ||
       ((x.sup <= 0.0) && (y.sup <= 0.0) && (y.inf/2.0 >= x.sup) && (x.inf >= 2.0*y.sup))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      [eo set_q:zero and:zero];
      [zero release];
   } else if ((((double_cast)((z.inf))).parts.exponent <= 1) && (((double_cast)((z.sup))).parts.exponent <= 1)) {
      /* Hauser theorems:
       3.4.1: if Round(x + y) is denormalized, then Round(x + y) = x + y (provided we use denormalized numbers)
       see p 154. Also apply to subtraction (as x - y = x + (- y))
       3.4.1a: Let u be the least positive normalized float. If abs(x + y) < 2*u then Round(x + y) = x + y
       Hauser, J. R. 1996. Handling floating-point exceptions in numeric programs. ACM Transactions on Pro-
       gramming Languages and Systems 18, 2, 139–174 */
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      [eo set_q:zero and:zero];
      [zero release];
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORDouble tmpf = x.inf - y.inf;
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      id<ORRational> yq = [ORRational rationalWith_d:y.inf];
      
      [tmpq set: [xq sub: yq]];
      [yq set_d:tmpf];
      [tmpq set: [tmpq sub: yq]];
      
      [eo set_q:tmpq and:tmpq];
      
      [tmpq release];
      [yq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      [ulp_q set: ulp_computation_d(z)];
      [eo set:ulp_q];
      [ulp_q release];
   }
   [eo autorelease];
   return eo;
}

id<ORRationalInterval> compute_eo_mul_d(const double_interval x, const double_interval y, const double_interval z)
{
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   /* Check if its a product by a power of 2 */
   if (((x.inf == x.sup) && (((double_cast)((x.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(x.inf) <= y.inf) && (y.sup <= DBL_MAX/fabs(x.inf))) ||
       ((y.inf == y.sup) && (((double_cast)((y.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(y.inf) <= x.inf) && (x.sup <= DBL_MAX/fabs(y.inf)))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      [eo set_q:zero and:zero];
      [zero release];
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORDouble tmpf = x.inf*y.inf;
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      id<ORRational> yq = [ORRational rationalWith_d:y.inf];
      
      [tmpq set: [xq mul: yq]];
      [yq set_d:tmpf];
      [tmpq set: [tmpq sub: yq]];
      
      [eo set_q:tmpq and:tmpq];
      
      [tmpq release];
      [yq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      [ulp_q set: ulp_computation_d(z)];
      [eo set:ulp_q];
      [ulp_q release];
   }
   [eo autorelease];
   return eo;
}

int checkDivPower2d(double x, double y) { // x/y
   double_cast z;
   z.f = x/y;
   return (z.parts.exponent >= 1);
}

id<ORRationalInterval> compute_eo_div_d(const double_interval x, const double_interval y, const double_interval z)
{
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   /* Check if its a division by a power of 2 */
   if ((y.inf == y.sup) && (((double_cast)(y.inf)).parts.mantissa == 0) &&
       (((-DBL_MAX <= x.inf) && (x.sup < 0.0) && checkDivPower2d(x.sup, y.inf)) || ((0.0 < x.inf) && (x.sup <= DBL_MAX) && checkDivPower2d(x.inf, y.inf)))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      [eo set_q:zero and:zero];
      [zero release];
      
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORDouble tmpf = x.inf/y.inf;
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      id<ORRational> yq = [ORRational rationalWith_d:y.inf];
      
      [tmpq set: [xq div: yq]];
      [yq set_d:tmpf];
      [tmpq set: [tmpq sub: yq]];
      
      [eo set_q:tmpq and:tmpq];
      
      [tmpq release];
      [yq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      [ulp_q set: ulp_computation_d(z)];
      [eo set:ulp_q];
      [ulp_q release];
   }
   [eo autorelease];
   return eo;
}



//unary minus constraint
@implementation CPDoubleUnaryMinus{
   int _precision;
   int _rounding;
   double_interval _xi;
   double_interval _yi;
   ORBool _rewrite;
   id<ORRationalInterval> interError;
   id<ORRationalInterval> ex;
   id<ORRationalInterval> ey;
   
}
-(id) init:(CPDoubleVarI*)x eqm:(CPDoubleVarI*)y  rewrite:(ORBool)rewrite
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = makeDoubleInterval(x.min, x.max);
   _yi = makeDoubleInterval(y.min, y.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   _rewrite = rewrite;
   interError = [[ORRationalInterval alloc] init];
   ex = [[ORRationalInterval alloc] init];
   ey = [[ORRationalInterval alloc] init];
   
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
   if(_rewrite){
      [[[_x engine] mergedVar] notifyWith:_x andId:_y isStatic:YES];
      [[_x engine] incNbRewrites:1];
   }
}
-(void) propagate
{
   @autoreleasepool {
      updateDoubleInterval(&_xi,_x);
      updateDoubleInterval(&_yi,_y);
      intersectionIntervalD inter;
      
      [ex set_q:[_x minErr] and:[_x maxErr]];
      [ey set_q:[_y minErr] and:[_y maxErr]];
      
      double_interval yTmp = makeDoubleInterval(_yi.inf, _yi.sup);
      fpi_minusd(_precision,_rounding, &yTmp, &_xi);
      inter = intersectionD(_y,_yi, yTmp, 0.0f);
      [interError set: [ey proj_inter:[ex neg]]];
      
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
      [interError set: [ex proj_inter:[ey neg]]];
      
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
      if(interError.changed)
         [_x updateIntervalError:interError.low and:interError.up];
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
- (id<CPVar>)result
{
   return _x;
}
- (void) dealloc
{
   [interError release];
   [ex release];
   [ey release];
   [super dealloc];
}
@end


@implementation CPDoubleCast {
   int _precision;
   int _rounding;
   double_interval _resi;
   float_interval _initiali;
   ORBool _rewrite;
}
-(id) init:(CPDoubleVarI*)res equals:(CPFloatVarI*)initial  rewrite:(ORBool)rewrite
{
   self = [super initCPCoreConstraint: [res engine]];
   _res = res;
   _initial = initial;
   _resi = makeDoubleInterval(_res.min, _res.max);
   _initiali = makeFloatInterval(_initial.min, _initial.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   _rewrite = rewrite;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_res bound])        [_res whenChangeBoundsPropagate:self];
   if(![_initial bound])    [_initial whenChangeBoundsPropagate:self];
   if(_rewrite){
      [[[_res engine] mergedVar] notifyWith:_res andId:_initial isStatic:YES];
      [[_res engine] incNbRewrites:1];
   }
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
      inter = intersectionD(_res, _resi, resTmp, 0.0);
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
- (id<CPVar>)result
{
   return _res;
}
@end


@implementation CPDoubleEqual{
   ORBool _rewrite;
}
-(id) init:(CPDoubleVarI*)x equals:(CPDoubleVarI*)y rewrite:(ORBool)rewrite
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _rewrite = rewrite;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
   if(_rewrite){
      [[[_x engine] mergedVar] notifyWith:_x andId:_y isStatic:[[_x engine] isPosting]];
      [[_x engine] incNbRewrites:1];
   }
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
   id<ORRationalInterval> ex;
   id<ORRationalInterval> ey;
   id<ORRationalInterval> interError;
   
}
-(id) init:(CPDoubleVarI*)x set:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _precision = 1;
   _rounding = FE_TONEAREST;
   ex = [[ORRationalInterval alloc] init];
   ey = [[ORRationalInterval alloc] init];
   interError = [[ORRationalInterval alloc] init];
   
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
   @autoreleasepool {
      double_interval x, y;
      intersectionIntervalD inter;
      
      x = makeDoubleInterval([_x min], [_x max]);
      y = makeDoubleInterval([_y min], [_y max]);
      
      [ex set_q:[_x minErr] and:[_x maxErr]];
      [ey set_q:[_y minErr] and:[_y maxErr]];
      
      if(isDisjointWithD(_x,_y)){
         failNow();
      } else if(isDisjointWithDR(_x,_y)){
         failNow();
      } else{
         double_interval xTmp = makeDoubleInterval(x.inf, x.sup);
         fpi_set(_precision, _rounding, &xTmp, &y);
         
         inter = intersectionD(_x, x, xTmp, 0.0f);
         [interError set: [ex proj_inter:ey]];
         
         if(inter.changed)
            [_x updateInterval:inter.result.inf and:inter.result.sup];
         if(interError.changed)
            [_x updateIntervalError:interError.low and:interError.up];
         if ((y.inf != inter.result.inf) || (y.sup != inter.result.sup))
            [_y updateInterval:inter.result.inf and:inter.result.sup];
         if ([ey.low neq: interError.low] || [ey.up neq: interError.up])
            [_y updateIntervalError:interError.low and:interError.up];
      }
      
   }
}
- (void)dealloc
{
   [ex release];
   [ey release];
   [interError release];
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
- (id<CPVar>)result
{
   return _x;
}
@end

@implementation CPDoubleAssignC {
   id<ORRational> zero;
}
-(id) init:(CPDoubleVarI*)x set:(ORDouble)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   zero = [[ORRational alloc] init];
   return self;
}
-(void) post
{
   [zero setZero];
   [_x bind:_c];
   [_x bindError:zero];
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
- (id<CPVar>)result
{
   return _x;
}
- (void)dealloc
{
   [zero release];
   [super dealloc];
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
         }
         return;
      }
   }else  if([_y bound]){
      if([_x min] == [_y min]){
         [_x updateMin:fp_next_double([_y min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y min]){
         [_x updateMax:fp_previous_double([_y max])];
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

@implementation CPDoubleSquare{
   int _precision;
   int _rounding;
   double_interval _xi;
   double_interval _resi;
   TRInt _limit;
   id<ORRationalInterval> ex;
   id<ORRationalInterval> eres;
   id<ORRationalInterval> eo;
   id<ORRationalInterval> exTemp;
   id<ORRationalInterval> eresTemp;
   id<ORRationalInterval> eoTemp;
   id<ORRationalInterval> xr;
   id<ORRationalInterval> xrTemp;
   id<ORRationalInterval> two;
}
-(id) init:(CPDoubleVarI*)res eq:(CPDoubleVarI*)x //res = x^2
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeDoubleInterval(x.min, x.max);
   _resi = makeDoubleInterval(res.min, res.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   //_eo = [[CPRationalDom alloc] initCPRationalDom:[[res engine] trail] lowF:-INFINITY upF:+INFINITY];
   _eo = [[CPRationalVarI alloc] init:[res engine] low:[res minErr] up:[res maxErr]]; 
   //assignTRInt(&_limit, YES, _trail);
   _limit = makeTRInt(_trail,YES);
   nbConstraint++;
   
   ex = [[ORRationalInterval alloc] init];
   eres = [[ORRationalInterval alloc] init];
   eo = [[ORRationalInterval alloc] init];
   exTemp = [[ORRationalInterval alloc] init];
   eresTemp = [[ORRationalInterval alloc] init];
   eoTemp = [[ORRationalInterval alloc] init];
   xr = [[ORRationalInterval alloc] init];
   xrTemp = [[ORRationalInterval alloc] init];
   two = [[ORRationalInterval alloc] init];
   
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || [_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_res bound] || [_res boundError])  [_res whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged, changed;
   changed = gchanged = false;
   updateDoubleInterval(&_xi,_x);
   updateDoubleInterval(&_resi,_res);
   intersectionIntervalD inter;
   double_interval resTmp = makeDoubleInterval(_resi.inf, _resi.sup);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [eres set_q:[_res minErr] and:[_res maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   [two set_d:2.0 and:2.0];
   
   @autoreleasepool {
      fpi_xxd(_precision, _rounding, &resTmp, &_xi);
      inter = intersectionD(_res, _resi, resTmp, 0.0);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      updateDoubleInterval(&_xi,_x);
      double_interval xTmp = makeDoubleInterval(_xi.inf, _xi.sup);
      fpi_xxd_inv(_precision,_rounding, &xTmp, &_resi);
      inter = intersectionD(_x, _xi, xTmp, 0.0);
      
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
      
      updateDoubleInterval(&_xi,_x);
      updateDoubleInterval(&_resi,_res);
      
      //do {
      changed = false;
      
      /* ERROR PROPAG */
      [xr set_d:_xi.inf and:_xi.sup];
      
      [eoTemp set: compute_eo_mul_d(_xi, _xi, _resi)];
      [eo set: [eo proj_inter:eoTemp]];
      changed |= eo.changed;
      
      if(_limit._val && (_resi.inf <= _resi.sup)){
         if(
            ((_resi.inf >= 0) && (((double_cast)(_resi.inf)).parts.exponent == ((double_cast)(_resi.sup)).parts.exponent)) ||
            ((_resi.sup < 0) && (((double_cast)(_resi.inf)).parts.exponent == ((double_cast)(_resi.sup)).parts.exponent))
            ){
            assignTRInt(&limitCounter, limitCounter._val+1, _trail);
            assignTRInt(&_limit, NO, _trail);
         }
      }
      // ============================== eres
      // eo + ex * (ex + 2 * x)
      [eresTemp set: [eo add: [ex mul: [ex add: [two mul: xr]]]]];
      
      [eres set: [eres proj_inter: eresTemp]];
      changed |= eres.changed;
      
      // ============================== eo
      // eres - ex * (ex + 2 * x)
      [eoTemp set: [eres sub: [ex mul: [ex add: [two mul: xr]]]] ];
      
      [eo set: [eo proj_inter: eoTemp]];
      changed |= eo.changed;
      
      // ============================== ex
      // (eres - x*ex - eo)/(x + ex)
      [exTemp set: [[[eres sub: [xr mul: ex]] sub: eo] div: [xr add: ex]]];
      
      [ex set: [ex proj_inter: exTemp]];
      changed |= ex.changed;
      
      // ============================== x
      // (eres/ex) - x - ex - (eo/ex)
      [xrTemp set: [[[[eres div: ex] sub: xr] sub: ex] sub: [eo div: ex]]];
      
      [xr set: [xr proj_inter:xrTemp]];
      changed |= xr.changed;
      
      _xi.inf = [[xr low] get_sup_d];
      _xi.sup = [[xr up] get_inf_d];
      
      /* END ERROR PROPAG */
      gchanged |= changed;
      //} while(changed);
   }
   
   //if(gchanged){
   // Cause no propagation on eo is insured
   //[_eo updateMin:(eo.low) for:NULL];
   //[_eo updateMax:(eo.up) for:NULL];
   [_eo updateInterval:eo.low and:eo.up];
   
   [_x updateInterval:_xi.inf and:_xi.sup];
   [_x updateIntervalError:(ex.low) and:(ex.up)];
   [_res updateIntervalError:(eres.low) and:(eres.up)];
   //}
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
-(id<CPRationalVar>)getOperationError
{
   return _eo;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == (%@^2)>",_res,_x];
}
- (id<CPVar>)result
{
   return _res;
}
- (void) dealloc
{
   [ex release];
   [eres release];
   [eo release];
   [xr release];
   [exTemp release];
   [eresTemp release];
   [eoTemp release];
   [xrTemp release];
   [two release];
   [super dealloc];
}
@end

@implementation CPDoubleTernaryAdd {
   TRInt _limit;
   id<ORRationalInterval> ex;
   id<ORRationalInterval> ey;
   id<ORRationalInterval> ez;
   id<ORRationalInterval> eo;
   id<ORRationalInterval> exTemp;
   id<ORRationalInterval> eyTemp;
   id<ORRationalInterval> ezTemp;
   id<ORRationalInterval> eoTemp;
   
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y
{
   return [self init:z equals:x plus:y kbpercent:PERCENT rewriting:NO];
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y   rewriting:(ORBool) f
{
   return [self init:z equals:x plus:y kbpercent:PERCENT rewriting:f];
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y kbpercent:(ORDouble)p
{
   return [self init:z equals:x plus:y kbpercent:p rewriting:NO];
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y kbpercent:(ORDouble)p  rewriting:(ORBool) f
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _rewriting = f;
   //_eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   _eo = [[CPRationalVarI alloc] init:[z engine] low:[z minErr] up:[z maxErr]];
   //assignTRInt(&_limit, YES, _trail);
   _limit = makeTRInt(_trail,YES);
   nbConstraint++;
   ex = [[ORRationalInterval alloc] init];
   ey = [[ORRationalInterval alloc] init];
   ez = [[ORRationalInterval alloc] init];
   eo = [[ORRationalInterval alloc] init];
   exTemp = [[ORRationalInterval alloc] init];
   eyTemp = [[ORRationalInterval alloc] init];
   ezTemp = [[ORRationalInterval alloc] init];
   eoTemp = [[ORRationalInterval alloc] init];
   
   return self;
}
-(void) post
{
   [self propagate];
   if (![_x bound]  || ![_x boundError]) {
      [_x whenChangeBoundsPropagate:self];
      if(_rewriting)
         [_x whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_y bound]  || ![_y boundError]) {
      [_y whenChangeBoundsPropagate:self];
      if(_rewriting)
         [_y whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_z bound]  || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   @autoreleasepool {
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
         
         [eoTemp set: compute_eo_add_d(x, y, z)];
         [eo set: [eo proj_inter:eoTemp]];
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
         [ezTemp set: [[ex add: ey] add: eo]];
         
         [ez set: [ez proj_inter: ezTemp]];
         changed |= ez.changed;
         
         // ============================== eo
         // ez - ex - ey
         [eoTemp set: [[ez sub: ex] sub: ey]];
         
         [eo set: [eo proj_inter: eoTemp]];
         changed |= eo.changed;
         
         // ============================== ex
         // ez - ey - eo
         [exTemp set: [[ez sub: ey] sub: eo]];
         
         [ex set: [ex proj_inter: exTemp]];
         changed |= ex.changed;
         
         // ============================== ey
         // ez - ex - eo
         [eyTemp set: [[ez sub: ex] sub: eo]];
         
         [ey set: [ey proj_inter: eyTemp]];
         changed |= ey.changed;
         
         /* END ERROR PROPAG */
         
         gchanged |= changed;
      } while(changed);
   }
   
   if(gchanged){
      // Cause no propagation on eo is insured
      //[_eo updateMin:(eo.low) for:NULL];
      //[_eo updateMax:(eo.up) for:NULL];
      [_eo updateInterval:eo.low and:eo.up];
      
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:(ex.low) and:(ex.up)];
      [_y updateIntervalError:(ey.low) and:(ey.up)];
      [_z updateIntervalError:(ez.low) and:(ez.up)];
      if(![self nbUVars])
         assignTRInt(&_active, NO, _trail);
   }
   
   fesetround(FE_TONEAREST);
}
- (void)dealloc {
   [ex release];
   [ey release];
   [ez release];
   [eo release];
   [exTemp release];
   [eyTemp release];
   [ezTemp release];
   [eoTemp release];
   [super dealloc];
}
-(void) propagateFixPoint
{
   if([self nbUVars]){
      if(absorbD(_x,_y)){
         //         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory doubleEqual:_z to:_x rewrite:YES] engine:[_x engine]];
      }else if(absorbD(_y,_x)){
         //         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory doubleEqual:_z to:_y rewrite:YES] engine:[_x engine]];
      }
   }
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
-(id<CPRationalVar>)getOperationError
{
   return _eo;
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
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ + %@>",_z, _x, _y];
}
- (id<CPVar>)result
{
   return _z;
}
@end


@implementation CPDoubleTernarySub {
   TRInt _limit;
   id<ORRationalInterval> ex;
   id<ORRationalInterval> ey;
   id<ORRationalInterval> ez;
   id<ORRationalInterval> eo;
   id<ORRationalInterval> exTemp;
   id<ORRationalInterval> eyTemp;
   id<ORRationalInterval> ezTemp;
   id<ORRationalInterval> eoTemp;
   
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y kbpercent:(ORDouble)p rewriting:(ORBool) f
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _rewriting = f;
   //_eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   _eo = [[CPRationalVarI alloc] init:[z engine] low:[z minErr] up:[z maxErr]];
   //assignTRInt(&_limit, YES, _trail);
   _limit = makeTRInt(_trail,YES);
   nbConstraint++;
   ex = [[ORRationalInterval alloc] init];
   ey = [[ORRationalInterval alloc] init];
   ez = [[ORRationalInterval alloc] init];
   eo = [[ORRationalInterval alloc] init];
   exTemp = [[ORRationalInterval alloc] init];
   eyTemp = [[ORRationalInterval alloc] init];
   ezTemp = [[ORRationalInterval alloc] init];
   eoTemp = [[ORRationalInterval alloc] init];
   
   return self;
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y kbpercent:(ORDouble)p
{
   return [self init:z equals:x minus:y kbpercent:p rewriting:NO];
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y
{
   return [self init:z equals:x minus:y kbpercent:PERCENT rewriting:NO];
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y rewriting:(ORBool) f
{
   return [self init:z equals:x minus:y kbpercent:PERCENT rewriting:f];
}
-(void) post
{
   [self propagate];
   if (![_x bound] || ![_x boundError]) {
      [_x whenChangeBoundsPropagate:self];
      if(_rewriting)
         [_x whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_y bound] || ![_y boundError]) {
      [_y whenChangeBoundsPropagate:self];
      if(_rewriting)
         [_y whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
   
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   @autoreleasepool {
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
         [eoTemp set: compute_eo_sub_d(x, y, z)];
         [eo set: [eo proj_inter:eoTemp]];
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
         [ezTemp set: [[ex sub: ey] add: eo]];
         
         [ez set: [ez proj_inter: ezTemp]];
         changed |= ez.changed;
         
         // ============================== eo
         // ez - (ex - ey)
         [eoTemp set: [ez sub: [ex sub: ey]]];
         
         [eo set: [eo proj_inter: eoTemp]];
         changed |= eo.changed;
         
         // ============================== ex
         // ez + ey - eo
         [exTemp set: [[ez add: ey] sub: eo]];
         
         [ex set: [ex proj_inter: exTemp]];
         changed |= ex.changed;
         
         // ============================== ey
         // ex - ez + eo
         [eyTemp set: [[ex sub: ez] add: eo]];
         
         [ey set: [ey proj_inter: eyTemp]];
         changed |= ey.changed;
         
         /* END ERROR PROPAG */
         
         gchanged |= changed;
      } while(changed);
   }
   
   if(gchanged){
      // Cause no propagation on eo is insured
      //[_eo updateMin:(eo.low) for:NULL];
      //[_eo updateMax:(eo.up) for:NULL];
      [_eo updateInterval:eo.low and:eo.up];
      
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:(ex.low) and:(ex.up)];
      [_y updateIntervalError:(ey.low) and:(ey.up)];
      [_z updateIntervalError:(ez.low) and:(ez.up)];
      if(![self nbUVars])
         assignTRInt(&_active, NO, _trail);
   }
   fesetround(FE_TONEAREST);
}
- (void)dealloc {
   [ex release];
   [ey release];
   [ez release];
   [eo release];
   [exTemp release];
   [eyTemp release];
   [ezTemp release];
   [eoTemp release];
   [super dealloc];
}
-(void) propagateFixPoint
{
   if([self nbUVars]){
      if(absorbD(_x,_y)){
         //         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory doubleEqual:_z to:_x rewrite:YES] engine:[_x engine]];
      }else if(absorbD(_y,_x)){
         //         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory doubleEqual:_z to:_y rewrite:YES] engine:[_x engine]];
      }
   }
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
-(id<CPRationalVar>)getOperationError
{
   return _eo;
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
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
- (id<CPVar>)result
{
   return _z;
}
@end

@implementation CPDoubleTernaryMult{
   TRInt _limit;
   id<ORRationalInterval> ex;
   id<ORRationalInterval> ey;
   id<ORRationalInterval> ez;
   id<ORRationalInterval> eo;
   id<ORRationalInterval> exTemp;
   id<ORRationalInterval> eyTemp;
   id<ORRationalInterval> ezTemp;
   id<ORRationalInterval> ezTemp1;
   id<ORRationalInterval> ezTemp2;
   id<ORRationalInterval> ezTemp3;
   id<ORRationalInterval> eoTemp;
   id<ORRationalInterval> xrTemp;
   id<ORRationalInterval> yrTemp;
   id<ORRationalInterval> xr;
   id<ORRationalInterval> yr;
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
   //_eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   _eo = [[CPRationalVarI alloc] init:[z engine] low:[z minErr] up:[z maxErr]];
   //assignTRInt(&_limit, YES, _trail);
   _limit = makeTRInt(_trail,YES);
   nbConstraint++;
   ex = [[ORRationalInterval alloc] init];
   ey = [[ORRationalInterval alloc] init];
   ez = [[ORRationalInterval alloc] init];
   eo = [[ORRationalInterval alloc] init];
   exTemp = [[ORRationalInterval alloc] init];
   eyTemp = [[ORRationalInterval alloc] init];
   ezTemp = [[ORRationalInterval alloc] init];
   ezTemp1 = [[ORRationalInterval alloc] init];
   ezTemp2 = [[ORRationalInterval alloc] init];
   ezTemp3 = [[ORRationalInterval alloc] init];
   eoTemp = [[ORRationalInterval alloc] init];
   xrTemp = [[ORRationalInterval alloc] init];
   yrTemp = [[ORRationalInterval alloc] init];
   xr = [[ORRationalInterval alloc] init];
   yr = [[ORRationalInterval alloc] init];
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
   
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   @autoreleasepool {
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
         
         [eoTemp set: compute_eo_mul_d(x, y, z)];
         [eo set: [eo proj_inter:eoTemp]];
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
         [ezTemp1 set: [[[[xr mul: ey] add: [yr mul: ex]] add: [ex mul: ey]] add: eo]];
         // x*ey + ex*(y+ey) + eo
         [ezTemp2 set: [[[xr mul: ey] add: [ex mul:[yr add: ey]]] add: eo]];
         // ey*(x + ex) + y*ex + eo
         [ezTemp3 set: [[[ey mul: [xr add: ex]] add:[yr mul: ex]] add: eo]];
         
         [ezTemp set: [ezTemp1 proj_inter: ezTemp2]];
         [ezTemp set: [ezTemp proj_inter:ezTemp3]];
         
         [ez set: [ez proj_inter: ezTemp]];
         changed |= ez.changed;
         
         // ============================== eo
         // ez - (x*ey + y*ex + ex*ey)
         [eoTemp set: [ez sub: [[[xr mul: ey] add: [yr mul: ex]] add: [ex mul: ey]]]];
         
         [eo set: [eo proj_inter: eoTemp]];
         changed |= eo.changed;
         
         // ============================== ex
         // (ez - x*ey - eo)/(y + ey)
         [exTemp set: [[[ez sub: [xr mul: ey]] sub: eo] div: [yr add: ey]]];
         
         [ex set: [ex proj_inter: exTemp]];
         changed |= ex.changed;
         
         // ============================== ey
         // (ez - y*ex - eo)/(x + ex)
         [eyTemp set: [[[ez sub: [yr mul: ex]] sub: eo] div: [xr add: ex]]];
         
         [ey set: [ey proj_inter: eyTemp]];
         changed |= ey.changed;
         
         // ============================== x
         // (ez - y*ex - ex*ey - eo)/ey
         [xrTemp set: [[[[ez sub: [yr mul: ex]] sub: [ex mul: ey]] sub: eo] div: ey]];
         
         [xr set: [xr proj_inter:xrTemp]];
         changed |= xr.changed;
         
         x.inf = [[xr low] get_sup_d];
         x.sup = [[xr up] get_inf_d];
         
         // ============================== y
         // (ez - x*ey - ex*ey - eo)/ex
         [yrTemp set: [[[[ez sub: [xr mul: ey]] sub: [ex mul: ey]] sub: eo] div: ex]];
         
         [yr set: [yr proj_inter:yrTemp]];
         changed |= yr.changed;
         
         y.inf = [[yr low] get_sup_d];
         y.sup = [[yr up] get_inf_d];
         
         /* END ERROR PROPAG */
         
         gchanged |= changed;
      } while(changed);
   }
   
   if(gchanged){
      // Cause no propagation on eo is insured
      //[_eo updateMin:(eo.low) for:NULL];
      //[_eo updateMax:(eo.up) for:NULL];
      [_eo updateInterval:eo.low and:eo.up];
      
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
}
- (void)dealloc {
   [ex release];
   [ey release];
   [ez release];
   [eo release];
   [exTemp release];
   [eyTemp release];
   [ezTemp release];
   [ezTemp1 release];
   [ezTemp2 release];
   [ezTemp3 release];
   [eoTemp release];
   [xrTemp release];
   [yrTemp release];
   [xr release];
   [yr release];
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
-(id<CPRationalVar>)getOperationError
{
   return _eo;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ * %@>",_z, _x, _y];
}
@end

@implementation CPDoubleTernaryDiv {
   TRInt _limit;
   id<ORRationalInterval> ex;
   id<ORRationalInterval> ey;
   id<ORRationalInterval> ez;
   id<ORRationalInterval> eo;
   id<ORRationalInterval> exTemp;
   id<ORRationalInterval> eyTemp;
   id<ORRationalInterval> ezTemp;
   id<ORRationalInterval> ezTemp1;
   id<ORRationalInterval> ezTemp2;
   id<ORRationalInterval> ezTemp3;
   id<ORRationalInterval> eoTemp;
   id<ORRationalInterval> xrTemp;
   id<ORRationalInterval> yrTemp;
   id<ORRationalInterval> xr;
   id<ORRationalInterval> yr;
   id<ORRationalInterval> D;
   id<ORRationalInterval> D1;
   id<ORRationalInterval> D2;
   id<ORRationalInterval> d1;
   id<ORRationalInterval> d2;
   id<ORRationalInterval> tmp;
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
   //_eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   _eo = [[CPRationalVarI alloc] init:[z engine] low:[z minErr] up:[z maxErr]];
   //assignTRInt(&_limit, YES, _trail);
   _limit = makeTRInt(_trail,YES);
   nbConstraint++;
   ex = [[ORRationalInterval alloc] init];
   ey = [[ORRationalInterval alloc] init];
   ez = [[ORRationalInterval alloc] init];
   eo = [[ORRationalInterval alloc] init];
   exTemp = [[ORRationalInterval alloc] init];
   eyTemp = [[ORRationalInterval alloc] init];
   ezTemp = [[ORRationalInterval alloc] init];
   ezTemp1 = [[ORRationalInterval alloc] init];
   ezTemp2 = [[ORRationalInterval alloc] init];
   ezTemp3 = [[ORRationalInterval alloc] init];
   eoTemp = [[ORRationalInterval alloc] init];
   xrTemp = [[ORRationalInterval alloc] init];
   yrTemp = [[ORRationalInterval alloc] init];
   xr = [[ORRationalInterval alloc] init];
   yr = [[ORRationalInterval alloc] init];
   D = [[ORRationalInterval alloc] init];
   D1 = [[ORRationalInterval alloc] init];
   D2 = [[ORRationalInterval alloc] init];
   d1 = [[ORRationalInterval alloc] init];
   d2 = [[ORRationalInterval alloc] init];
   tmp = [[ORRationalInterval alloc] init];
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
   
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   @autoreleasepool {
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
         
         [eoTemp set: compute_eo_div_d(x, y, z)];
         [eo set: [eo proj_inter:eoTemp]];
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
         [ezTemp set: [[[[yr mul: ex] sub: [xr mul: ey]] div: [yr mul: [yr add: ey]]] add: eo]];
         //
         [ez set: [ez proj_inter: ezTemp]];
         changed |= ez.changed;
         
         // ============================== eo
         // ez - (y*ex - x*ey)/(y*(y + ey))
         [eoTemp set: [ez sub: [[[yr mul: ex] sub: [xr mul: ey]] div: [yr mul: [yr add: ey]]]]];
         
         [eo set: [eo proj_inter: eoTemp]];
         changed |= eo.changed;
         
         // ============================== ex
         // (ez - eo)*(y + ey) + (x*ey)/y
         [exTemp set: [[[ez sub: eo] mul: [yr add: ey]] add: [[xr mul: ey] div: yr]]];
         
         [ex set: [ex proj_inter: exTemp]];
         changed |= ex.changed;
         
         // ============================== ey
         // (ex - ez*y + eo*y)/(ez - eo + (x/y))
         [eyTemp set: [[[ex sub: [ez mul: yr]] add: [eo mul: yr]] div: [[ez sub: eo] add: [xr div: yr]]]];
         
         [ey set: [ey proj_inter: eyTemp]];
         changed |= ey.changed;
         
         // ============================== x
         // ((eo-ez) * y * (y+ey) + y*ex)/ey
         [xrTemp set: [[[[[eo sub: ez] mul: yr] mul: [yr add:ey]] add: [yr mul: ex]] div: ey]];
         
         [xr set: [xr proj_inter:xrTemp]];
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
   }
   
   if(gchanged){
      // Cause no propagation on eo is insured
      //[_eo updateMin:(eo.low) for:NULL];
      //[_eo updateMax:(eo.up) for:NULL];
      [_eo updateInterval:eo.low and:eo.up];
      
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
}
- (void)dealloc {
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
-(id<CPRationalVar>)getOperationError
{
   return _eo;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ / %@>",_z, _x, _y];
}
- (id<CPVar>)result
{
   return _z;
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
         [self addConstraint:[CPFactory doubleNEqualc:_y to:[_x min]] engine:[_x engine]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }else  if ([_y bound] || [_y min] == [_y max]) {     // TRUE <=> (x != c)
         [self addConstraint: [CPFactory doubleNEqualc:_x to:[_y min]] engine:[_x engine]];        // Rewrite as x==y  (addInternal can throw)
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

@implementation CPDoubleReifyEqual{
   ORBool _notified;
   ORBool _drewrite;
   ORBool _srewrite;
}
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPDoubleVarI*)x eqi:(CPDoubleVarI*)y dynRewrite:(ORBool) r staticRewrite:(ORBool) s
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   _notified = NO;
   _drewrite = r;
   _srewrite = s;
   return self;
}
-(void) post
{
   if(getId(_x) == getId(_y)){
      [_b bind:1];
   }else{
      [self propagate];
      if(![_b bound])
         [_b whenBindPropagate:self];
      if(![_x bound])
         [_x whenChangeBoundsPropagate:self];
      if(![_y bound])
         [_y whenChangeBoundsPropagate:self];
   }
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
         if(!_notified && ((_drewrite && ![[_x engine] isPosting]) || (_srewrite && [[_x engine] isPosting]))){
            [[[_x engine] mergedVar] notifyWith:_x andId:_y  isStatic:[[_x engine] isPosting]];
            [[_x engine] incNbRewrites:1];
            _notified = YES;
         }
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_x bound] || [_x min] == [_x max] )
         [self addConstraint:[CPFactory doubleNEqualc:_y to:[_x min]] engine:[_b engine]]; // Rewrite as min(x)!=y  (addInternal can throw)
      else if ([_y bound] || [_y min] == [_y max])
         [self addConstraint:[CPFactory doubleNEqualc:_x to:[_y min]] engine:[_b engine]]; // Rewrite as min(y)!=x  (addInternal can throw)
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

@implementation CPDoubleReifyAssignc{
   ORInt _precision;
   ORInt _rounding;
}
-(id) initCPReify:(CPIntVar*)b when:(CPDoubleVarI*)x set:(ORDouble)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   _precision = 1;
   _rounding = FE_TONEAREST;
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
-(void)propagate
{
   if([_b bound]){
      if(minDom(_b)){
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory doubleAssignC:_x to:_c] engine:[_x engine]];
      }else{
         if ([_x bound]){
            if(is_eq([_x min],_c)) failNow();
         }else{
            if(is_eq([_x min],_c)){
               [_x updateMin:fp_next_double(_c)];
               assignTRInt(&_active, NO, _trail);
            }else if(is_eq([_x max],_c)){
               [_x updateMax:fp_previous_double(_c)];
               assignTRInt(&_active, NO, _trail);
            }
         }
      }
   }else{
      if ([_x bound]) {
         [_b bind:is_eq([_x min],_c)];
         assignTRInt(&_active, NO, _trail);
      }else{
         if([_x min] > _c || [_x max] < _c){
            [_b bind:NO];
            assignTRInt(&_active, NO, _trail);
         }
      }
   }
   if([_b bound] && [_x bound]) assignTRInt(&_active, 0, _trail);
}

-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyAssignC:%02d %@ <=> (%@ <- %16.16e)>",_name,_b,_x,_c];
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
   return ![_x bound] +   ![_b bound];
}
@end

@implementation CPDoubleReifyAssign{
   ORInt _precision;
   ORInt _rounding;
   double_interval _xi;
   double_interval _yi;
}
-(id) initCPReify:(CPIntVar*)b when:(CPDoubleVarI*)x set:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   _precision = 1;
   _rounding = FE_TONEAREST;
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
   if([_b bound]){
      if(minDom(_b)){
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory doubleAssign:_x to:_y] engine:[_x engine]];
      }else{
         if ([_x bound]) {
            if([_y bound]){
               if (is_eq([_x min],[_y min]))
                  failNow();
            }else{
               if(is_eq([_x min],[_y min])){
                  [_y updateMin:fp_next_double([_y min])];
                  assignTRInt(&_active, NO, _trail);
               }
               if(is_eq([_x min],[_y max])) {
                  [_y updateMax:fp_previous_double([_y max])];
                  assignTRInt(&_active, NO, _trail);
               }
            }
         }else  if([_y bound]){
            if(is_eq([_x min],[_y min])){
               [_x updateMin:fp_next_double([_x min])];
               assignTRInt(&_active, NO, _trail);
            }
            if(is_eq([_x max],[_y min])){
               [_x updateMax:fp_previous_double([_x max])];
               assignTRInt(&_active, NO, _trail);
            }
         }
      }
   }else{
      if ([_x bound] && [_y bound])
         [_b bind:is_eq([_x min], [_y min])];
   }
   if([_b bound] && [_x bound] && [_y bound]) assignTRInt(&_active, 0, _trail);
}

-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyAssign:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
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
         [self addConstraint:[CPFactory doubleNEqualc:_x to:_c] engine:[_b engine]];     // Rewrite as x!=c  (addInternal can throw)
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
            [self addConstraint:[CPFactory doubleNEqualc:_x to:_c] engine:[_b engine]];    // Rewrite as x!=c  (addInternal can throw)
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
         [self addConstraint:[CPFactory doubleNEqualc:_x to:_c] engine:[_b engine]];    // Rewrite as x!=c  (addInternal can throw)
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
            [self addConstraint:[CPFactory doubleNEqualc:_x to:_c] engine:[_b engine]];     // Rewrite as x!=c  (addInternal can throw)
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
      inter = intersectionD(_res, _resi, resTmp, 0.0);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      updateDoubleInterval(&_xi,_x);
      double_interval xTmp = makeDoubleInterval(_x.min, _x.max);
      fpi_fabs_invd(_precision,_rounding, &xTmp, &_resi);
      inter = intersectionD(_x, _xi, xTmp, 0.0);
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
- (id<CPVar>)result
{
   return _res;
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
   inter = intersectionD(_res, _resi, resTmp, 0.0);
   if(inter.changed)
      [_res updateInterval:inter.result.inf and:inter.result.sup];
   
   updateDoubleInterval(&_xi,_x);
   double_interval xTmp = makeDoubleInterval(_xi.inf, _xi.sup);
   fpi_sqrtd_inv(_precision,_rounding, &xTmp, &_resi);
   inter = intersectionD(_x, _xi, xTmp, 0.0);
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
- (id<CPVar>)result
{
   return _res;
}
@end

@implementation CPDoubleIsPositive
-(id) init:(CPDoubleVarI*) x isPositive:(CPIntVar*) b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
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
         [_x updateMin:+0.0];
      else
         [_x updateMax:-0.0];
   } else {
      if (is_positive([_x min])) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if (is_negative([_x max])) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isPositive(%@)>",_b,_x];
}
@end

@implementation CPDoubleIsZero
-(id) init:(CPDoubleVarI*) x isZero:(CPIntVar*) b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
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
         [_x updateInterval:-0.0 and:+0.0];
      else
         [self addConstraint:[CPFactory doubleNEqualc:_x to:0.0] engine:[_x engine]];
   } else {
      if ([_x min] == 0.0 && [_x max] == 0.0) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > 0.0 && [_x max] < 0.0) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isZero(%@)>",_b,_x];
}
@end

@implementation CPDoubleIsInfinite
-(id) init:(CPDoubleVarI*) x isInfinite:(CPIntVar*) b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
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
      if (minDom(_b)){
         if([_x max] < +INFINITY) [_x bind:-INFINITY];
         if([_x min] > -INFINITY) [_x bind:+INFINITY];
      }else
         [_x updateInterval:fp_next_double(-INFINITY) and:fp_previous_double(+INFINITY)];
   } else {
      if ([_x max] == -INFINITY || [_x min] == +INFINITY) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > -INFINITY && [_x max] < +INFINITY) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isInfinite(%@)>",_b,_x];
}
@end

@implementation CPDoubleIsNormal
-(id) init:(CPDoubleVarI*)x isNormal:(CPIntVar*)b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
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
      if (minDom(_b)){
         if([_x bound] && is_infinity([_x min]))
            failNow();
         
         if([_x min] >= -maxdenormal() && [_x min] <= maxdenormal()){
            [_x updateMin:minnormal()];
            assignTRInt(&_active, NO, _trail);
         }else if(is_infinity([_x min]))
            [_x updateMin:fp_next_double(-infinity())];
         
         if([_x max] >= -maxdenormal() && [_x max] <= maxdenormal()){
            [_x updateMax:-minnormal()];
            assignTRInt(&_active, NO, _trail);
         }else if(is_infinity([_x max]))
            [_x updateMax:fp_previous_double(infinity())];
         
      }else{
         [_x updateInterval:-maxdenormal() and:maxdenormal()];
         assignTRInt(&_active, NO, _trail);
      }
   }else{
      if([_x min] >= -maxdenormal() && [_x max] <= maxdenormal()){
         [_b bind:0];
         assignTRInt(&_active, NO, _trail);
      }else if(([_x max] <= -minnormal() || [_x min] >= minnormal()) && !is_infinity([_x max]) && !is_infinity([_x min])){
         [_b bind:1];
         assignTRInt(&_active, NO, _trail);
      }
   }
}

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isNormal(%@)>",_b,_x];
}
@end

@implementation CPDoubleIsSubnormal
-(id) init:(CPDoubleVarI*)x isSubnormal:(CPIntVar*)b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
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
      if (minDom(_b)){
         [_x updateInterval:-maxdenormal() and:maxdenormal()];
         [self addConstraint:[CPFactory doubleNEqualc:_x to:0.0] engine:[_x engine]];
         assignTRInt(&_active, NO, _trail);
      }else{
         
         [self addConstraint:[CPFactory doubleNEqualc:_x to:0.0] engine:[_x engine]];
         
         if([_x min] >= -maxdenormal() && [_x min] <= maxdenormal()){
            [_x updateMin:minnormal()];
            assignTRInt(&_active, NO, _trail);
         }
         if([_x max] >= -maxdenormal() && [_x max] <= maxdenormal()){
            [_x updateMax:-minnormal()];
            assignTRInt(&_active, NO, _trail);
         }
      }
   }else{
      if(([_x min] >= -maxdenormal() && [_x max] <= -mindenormal()) || ([_x min] >= mindenormal() && [_x max] <= maxdenormal())){ //zero
         [_b bind:1];
         assignTRInt(&_active, NO, _trail);
      }else if([_x max] <= -minnormal() || [_x min] >= minnormal() || ([_x min] == 0.0 && [_x min] == 0.0)){
         [_b bind:0];
         assignTRInt(&_active, NO, _trail);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isSubnormal(%@)>",_b,_x];
}
@end
