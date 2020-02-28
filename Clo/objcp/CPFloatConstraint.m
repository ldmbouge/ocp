/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPFloatConstraint.h"
#import "CPFloatVarI.h"
#import "CPDoubleVarI.h"
#import "ORConstraintI.h"
#import <fenv.h>
#import "rationalUtilities.h"

#define PERCENT 5.0

id<ORRationalInterval> ulp_computation_f(const float_interval f){
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
      [tmp0 set_d: nextafterf(DBL_MAX, -INFINITY) - DBL_MAX];
      [tmp1 set_d: 2.0];
      [tmp2 set: [tmp0 div: tmp1]];
      [tmp3 set: [tmp0 div: tmp1]];
      [ulp set_q:[tmp2 neg] and:tmp3];
   } else{
      ORDouble inf, sup;
      inf = minDbl(nextafterf(f.inf, -INFINITY) - f.inf, nextafterf(f.sup, -INFINITY) - f.sup);
      sup = maxDbl(nextafterf(f.inf, +INFINITY) - f.inf, nextafterf(f.sup, +INFINITY) - f.sup);
      
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

id<ORRationalInterval> compute_eo_add_f(const float_interval x, const float_interval y, const float_interval z)
{
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   /* First, let see if Sterbenz is applicable */
   if (((0.0 <= x.inf) && (y.sup <= 0.0) && (-y.inf/2.0 <= x.inf) && (x.sup <= -2.0*y.sup)) ||
       ((x.sup <= 0.0) && (0.0 <= y.inf) && (y.sup/2.0 <= -x.sup) && (-x.inf <= 2.0*y.inf))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      [eo set_q:zero and:zero];
      [zero release];
   } else if ((((float_cast)((z.inf))).parts.exponent <= 1) && (((float_cast)((z.sup))).parts.exponent <= 1)) {
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
      
      [ulp_q set: ulp_computation_f(z)];
      [eo set: ulp_q];
      [ulp_q release];
   }
   [eo autorelease];
   return eo;
}

id<ORRationalInterval> compute_eo_sub_f(const float_interval x, const float_interval y, const float_interval z)
{
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   /* First, let see if Sterbenz is applicable (requires gradual underflow (denormalized) or that x-y does not underflow */
   if (((x.inf >= 0.0) && (y.inf >= 0.0) && (y.sup/2.0 <= x.inf) && (x.sup <= 2.0*y.inf)) ||
       ((x.sup <= 0.0) && (y.sup <= 0.0) && (y.inf/2.0 >= x.sup) && (x.inf >= 2.0*y.sup))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      [eo set_q:zero and:zero];
      [zero release];
   } else if ((((float_cast)((z.inf))).parts.exponent <= 1) && (((float_cast)((z.sup))).parts.exponent <= 1)) {
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
      
      [ulp_q set: ulp_computation_f(z)];
      [eo set:ulp_q];
      [ulp_q release];
   }
   [eo autorelease];
   return eo;
}


id<ORRationalInterval> compute_eo_mul_f(const float_interval x, const float_interval y, const float_interval z)
{
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   /* Check if its a product by a power of 2 */
   if (((x.inf == x.sup) && (((float_cast)((x.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(x.inf) <= y.inf) && (y.sup <= DBL_MAX/fabs(x.inf))) ||
       ((y.inf == y.sup) && (((float_cast)((y.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(y.inf) <= x.inf) && (x.sup <= DBL_MAX/fabs(y.inf)))) {
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
      
      [ulp_q set: ulp_computation_f(z)];
      [eo set:ulp_q];
      [ulp_q release];
   }
   [eo autorelease];
   return eo;
}

int checkDivPower2f(float x, float y) { // x/y
   float_cast z;
   z.f = x/y;
   return (z.parts.exponent >= 1);
}

id<ORRationalInterval> compute_eo_div_f(const float_interval x, const float_interval y, const float_interval z)
{
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   /* Check if its a division by a power of 2 */
   if ((y.inf == y.sup) && (((float_cast)(y.inf)).parts.mantissa == 0) &&
       (((-DBL_MAX <= x.inf) && (x.sup < 0.0) && checkDivPower2f(x.sup, y.inf)) || ((0.0 < x.inf) && (x.sup <= DBL_MAX) && checkDivPower2f(x.inf, y.inf)))) {
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
      
      [ulp_q set: ulp_computation_f(z)];
      [eo set:ulp_q];
      [ulp_q release];
   }
   [eo autorelease];
   return eo;
}
int checkPerfectSquare(const float x)
{
   float sx = sqrtf(x);
   
   return ((sx - floorf(sx)) == 0);
}

id<ORRationalInterval> compute_eo_sqrt(id<ORRationalInterval> eo, const float_interval x, const float_interval z){
   
   /* Check if its a division by a power of 2 */
   if ((x.inf == x.sup) && checkPerfectSquare(x.inf)) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
      
   } else if((x.inf == x.sup)){
      ORDouble tmpf = sqrtf(x.inf);
      id<ORRational> tmpq = [[ORRational alloc] init];
      id<ORRational> xq = [ORRational rationalWith_d:x.inf];
      
      tmpq = xq; /* Q sqrt(xq) */
      //mpq_set_den(xq.rational, mpz_sqrt(mpq_get_den(xq.rational)));
      //mpq_set_num(xq.rational, mpz_sqrt(mpq_get_num(xq.rational)))
      [xq set_d:tmpf];
      tmpq = [tmpq sub: xq];
      
      eo = [eo proj_inter:tmpq and:tmpq];
      
      [tmpq release];
      [xq release];
   } else {
      id<ORRationalInterval> ulp_q = [[ORRationalInterval alloc] init];
      
      [ulp_q set: ulp_computation_f(z)];
      eo = [eo proj_inter:ulp_q];
      [ulp_q release];
   }
   
   return eo;
   
}


@implementation CPFloatCast{
   int _precision;
   int _rounding;
   float_interval _resi;
   double_interval _initiali;
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)res equals:(CPDoubleVarI*)initial rewrite:(ORBool) rewrite
{
   self = [super initCPCoreConstraint: [res engine]];
   _res = res;
   _initial = initial;
   _resi = makeFloatInterval(_res.min, _res.max);
   _initiali = makeDoubleInterval(_initial.min, _initial.max);
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
   if([_initial bound]){
      if(is_eqf([_initial min],-0.0f) && is_eqf([_initial max],+0.0f))
         [_res updateInterval:[_initial min] and:[_initial max]];
      else
         [_res bind:[_initial value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithDV([_res min],[_res max],[_initial min],[_initial max])){
      failNow();
   }else {
      updateFloatInterval(&_resi,_res);
      updateDoubleInterval(&_initiali,_initial);
      intersectionInterval inter;
      float_interval resTmp = makeFloatInterval(_resi.inf, _resi.sup);
      fpi_dtof(_precision, _rounding, &resTmp, &_initiali);
      inter = intersection(_res, _resi, resTmp, 0.0f);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      
      updateFloatInterval(&_resi,_res);
      double_interval initialTmp = makeDoubleInterval(_initiali.inf, _initiali.sup);
      intersectionIntervalD inter2;
      fpi_dtof_inv(_precision, _rounding, &initialTmp,&_resi);
      inter2 = intersectionD(_initial,_initiali, initialTmp, 0.0f);
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

//unary minus constraint
@implementation CPFloatUnaryMinus{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _yi;
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)x eqm:(CPFloatVarI*)y rewrite:(ORBool) r
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = makeFloatInterval(x.min, x.max);
   _yi = makeFloatInterval(y.min, y.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   _rewrite = r;
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
   updateFloatInterval(&_xi,_x);
   updateFloatInterval(&_yi,_y);
   intersectionInterval inter;
   id<ORRationalInterval> interError = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   
   float_interval yTmp = makeFloatInterval(_yi.inf, _yi.sup);
   fpi_minusf(_precision,_rounding, &yTmp, &_xi);
   inter = intersection(_y, _yi, yTmp, 0.0f);
   [interError set: [ey proj_inter:[ex neg]]];
   if(inter.changed)
      [_y updateInterval:inter.result.inf and:inter.result.sup];
   if(interError.changed)
      [_y updateIntervalError:interError.low and:interError.up];
   
   updateFloatInterval(&_yi,_y);
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
   fpi_minusf(_precision,_rounding, &xTmp, &_yi);
   inter = intersection(_x, _xi, xTmp, 0.0f);
   [interError set: [ex proj_inter:[ey neg]]];
   if(inter.changed)
      [_x updateInterval:inter.result.inf and:inter.result.sup];
   if(interError.changed)
      [_x updateIntervalError:interError.low and:interError.up];
   
   [interError release];
   [ex release];
   [ey release];
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
@end

@implementation CPFloatEqual{
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)x equals:(CPFloatVarI*)y  rewrite:(ORBool) rewrite
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
   if(isDisjointWith(_x,_y)){
      failNow();
   }else{
      ORFloat min = maxFlt([_x min], [_y min]);
      ORFloat max = minFlt([_x max], [_y max]);
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

@implementation CPFloatEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   //hzi : equality constraint is different from assignment constraint for 0.0
   //in case when check equality -0.0f == 0.0f
   //in case of assignement x = -0.0f != from x = 0.0f
   if(_c == 0.f)
      [_x updateInterval:-0.0f and:+0.0f];
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

@implementation CPFloatAssign{
   int _precision;
   int _rounding;
}
-(id) init:(CPFloatVarI*)x set:(CPFloatVarI*)y
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
   float_interval x, y;
   intersectionInterval inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> interError = [[ORRationalInterval alloc] init];
   
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   
   if(isDisjointWith(_x,_y)){
      failNow();
   }else if(isDisjointWithR(_x,_y)){
      failNow();
   }else{
      float_interval xTmp = makeFloatInterval(x.inf, x.sup);
      fpi_setf(_precision, _rounding, &xTmp, &y);
      
      inter = intersection(_x, x, xTmp, 0.0f);
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
   
   fesetround(FE_TONEAREST);
   [ex release];
   [ey release];
   [interError release];

   if([_x bound] && [_y bound])
      assignTRInt(&_active, NO, _trail);
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
   return [NSString stringWithFormat:@"<%@ <- %@>",_x,_y];
}
- (id<CPVar>)result
{
   return _x;
}
@end

@implementation CPFloatAssignC
-(id) init:(CPFloatVarI*)x set:(ORFloat)c
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
- (id<CPVar>)result
{
   return _x;
}
@end


@implementation CPFloatNEqual
-(id) init:(CPFloatVarI*)x nequals:(CPFloatVarI*)y
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
               [_y updateMin:fp_next_float([_y min])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x min] == [_y max]) {
               [_y updateMax:fp_previous_float([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
         }
         return;
      }
   }else  if([_y bound]){
      if([_x min] == [_y min]){
         [_x updateMin:fp_next_float([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y min]){
         [_x updateMax:fp_previous_float([_x max])];
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

@implementation CPFloatNEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
}
-(void)dealloc
{
   [super dealloc];
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
         [_x updateMin:fp_next_float(_c)];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == _c){
         [_x updateMax:fp_previous_float(_c)];
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

@implementation CPFloatLT
-(id) init:(CPFloatVarI*)x lt:(CPFloatVarI*)y
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
   if(canFollow(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] >= [_y min]){
         ORFloat nmin = fp_next_float([_x min]);
         [_y updateMin:nmin];
      }
      if([_x max] >= [_y max]){
         ORFloat pmax = fp_previous_float([_y max]);
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

@implementation CPFloatGT
-(id) init:(CPFloatVarI*)x gt:(CPFloatVarI*)y
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
   if(canPrecede(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] <= [_y min]){
         ORFloat pmin = fp_next_float([_y min]);
         [_x updateMin:pmin];
      }
      if([_x max] <= [_y max]){
         ORFloat nmax = fp_previous_float([_x max]);
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


@implementation CPFloatLEQ
-(id) init:(CPFloatVarI*)x leq:(CPFloatVarI*)y
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
   if(canFollow(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] > [_y min]){
         ORFloat nmin = [_x min];
         [_y updateMin:nmin];
      }
      if([_x max] > [_y max]){
         ORFloat pmax = [_y max];
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

@implementation CPFloatGEQ
-(id) init:(CPFloatVarI*)x geq:(CPFloatVarI*)y
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
   if(canPrecede(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] < [_y min]){
         ORFloat pmin = [_y min];
         [_x updateMin:pmin];
      }
      if([_x max] < [_y max]){
         ORFloat nmax = [_x max];
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

@implementation CPFloatTernaryAdd{
   TRInt _limit;
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y
{
   return [self init:z equals:x plus:y kbpercent:PERCENT rewrite:NO];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   return [self init:z equals:x plus:y kbpercent:p rewrite:NO];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y rewrite:(ORBool)f
{
   return [self init:z equals:x plus:y kbpercent:PERCENT rewrite:f];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y kbpercent:(ORDouble)p rewrite:(ORBool) f
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _rewrite = f;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   assignTRInt(&_limit, YES, _trail);
   nbConstraint++;
   return self;
}
-(void) post
{
   [self propagate];
   if (![_x bound] || ![_x boundError]) {
      [_x whenChangeBoundsPropagate:self];
      if(_rewrite)
         [_x whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_y bound] || ![_y boundError]) {
      [_y whenChangeBoundsPropagate:self];
      if(_rewrite)
         [_y whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
   
}
//hzi : _Temps variables are useless ? inter.result ? x is already changed ?
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ez = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> exTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eyTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ezTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eoTemp = [[ORRationalInterval alloc] init];
   
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   @autoreleasepool {
      do {
         changed = false;
         zTemp = z;
         fpi_addf(_precision, _rounding, &zTemp, &x, &y);
         inter = intersection(_z, z, zTemp,_percent);
         z = inter.result;
         changed |= inter.changed;
         
         xTemp = x;
         yTemp = y;
         fpi_add_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
         inter = intersection(_x, x , xTemp,_percent);
         x = inter.result;
         changed |= inter.changed;
         
         inter = intersection(_y, y, yTemp,_percent);
         y = inter.result;
         changed |= inter.changed;
         
         xTemp = x;
         fpi_addxf_inv(_precision, _rounding, &xTemp, &z, &y);
         inter = intersection(_x, x , xTemp,_percent);
         x = inter.result;
         changed |= inter.changed;
         
         yTemp = y;
         fpi_addyf_inv(_precision, _rounding, &yTemp, &z, &x);
         inter = intersection(_y, y, yTemp,_percent);
         y = inter.result;
         changed |= inter.changed;
         
         /* ERROR PROPAG */
         
         [eoTemp set: compute_eo_add_f(x, y, z)];
         [eo set: [eo proj_inter:eoTemp]];
         changed |= eo.changed;
         
         if(_limit._val && (z.inf <= z.sup)){
            if(
               ((z.inf >= 0) && (((float_cast)(z.inf)).parts.exponent == ((float_cast)(z.sup)).parts.exponent)) ||
               ((z.sup < 0) && (((float_cast)(z.inf)).parts.exponent == ((float_cast)(z.sup)).parts.exponent))
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
      [_eo updateMin:(eo.low) for:NULL];
      [_eo updateMax:(eo.up) for:NULL];
      
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
-(void) propagateFixPoint
{
   if([self nbUVars]){
      if(absorb(_x,_y)){
//         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatEqual:_z to:_x rewrite:YES] engine:[_x engine]];
      }else if(absorb(_y,_x) ){
//         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatEqual:_z to:_y rewrite:YES] engine:[_x engine]];
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
-(id<CPVar>) varSubjectToAbsorption:(id<CPFloatVar>)x
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
   ORInt exmin, exmax, eymin,eymax,ezmin,ezmax,gmax,zmin;
   frexpf(fabs([_x min]),&exmin);
   frexpf(fabs([_x max]),&exmax);
   frexpf(fabs([_y min]),&eymin);
   frexpf(fabs([_y max]),&eymax);
   frexpf(fabs([_z min]),&ezmin);
   frexpf(fabs([_z max]),&ezmax);
   gmax = max(exmin, exmax);
   gmax = max(gmax,eymin);
   gmax = max(gmax,eymax);
   zmin = (([_z min] <= 0 && [_z max] >= 0) || ([_x min] == 0.f && [_x max] == 0.f) ||([_y min] == 0.0f && [_y max] == 0.0f)) ? 0.0 : min(ezmin,ezmax);
   return gmax-zmin;
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


@implementation CPFloatTernarySub{
   ORBool _rewrite;
   TRInt _limit;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y kbpercent:(ORDouble)p rewrite:(ORBool) f
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
   _rewrite = f;
   return self;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   return [self init:z equals:x minus:y kbpercent:p rewrite:NO];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y rewrite:(ORBool)f
{
   return [self init:z equals:x minus:y kbpercent:PERCENT rewrite:f];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y
{
   return [self init:z equals:x minus:y kbpercent:PERCENT rewrite:NO];
}
-(void) post
{
   [self propagate];
   if (![_x bound] || ![_x boundError]) {
      [_x whenChangeBoundsPropagate:self];
      if(_rewrite)
         [_x whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_y bound] || ![_y boundError]) {
      [_y whenChangeBoundsPropagate:self];
      if(_rewrite)
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
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ey = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ez = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> exTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eyTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ezTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eoTemp = [[ORRationalInterval alloc] init];
   
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   @autoreleasepool {
      do {
         changed = false;
         zTemp = z;
         fpi_subf(_precision, _rounding, &zTemp, &x, &y);
         inter = intersection(_z, z, zTemp,_percent);
         z = inter.result;
         changed |= inter.changed;
         
         xTemp = x;
         yTemp = y;
         fpi_sub_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
         inter = intersection(_x, x , xTemp,_percent);
         x = inter.result;
         changed |= inter.changed;
         
         inter = intersection(_y, y, yTemp,_percent);
         y = inter.result;
         changed |= inter.changed;
         
         xTemp = x;
         fpi_subxf_inv(_precision, _rounding, &xTemp, &z, &y);
         inter = intersection(_x, x , xTemp,_percent);
         x = inter.result;
         changed |= inter.changed;
         
         yTemp = y;
         fpi_subyf_inv(_precision, _rounding, &yTemp, &z, &x);
         inter = intersection(_y, y, yTemp,_percent);
         y = inter.result;
         changed |= inter.changed;
         
         /* ERROR PROPAG */
         [eoTemp set: compute_eo_sub_f(x, y, z)];
         [eo set: [eo proj_inter:eoTemp]];
         changed |= eo.changed;
         
         if(_limit._val && (z.inf <= z.sup)){
            if(
               ((z.inf >= 0) && (((float_cast)(z.inf)).parts.exponent == ((float_cast)(z.sup)).parts.exponent)) ||
               ((z.sup < 0) && (((float_cast)(z.inf)).parts.exponent == ((float_cast)(z.sup)).parts.exponent))
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
      [_eo updateMin:(eo.low) for:NULL];
      [_eo updateMax:(eo.up) for:NULL];
      
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
-(void) propagateFixPoint
{
   if([self nbUVars]){
      if(absorb(_x,_y)){
//         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatEqual:_z to:_x rewrite:YES] engine:[_x engine]];
      }else if(absorb(_y,_x) ){
//         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatEqual:_z to:_y rewrite:YES] engine:[_x engine]];
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
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(id<CPVar>) varSubjectToAbsorption:(id<CPFloatVar>)x
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
   ORInt exmin, exmax, eymin,eymax,ezmin,ezmax,gmax,zmin;
   frexpf([_x min],&exmin);
   frexpf([_x max],&exmax);
   frexpf([_y min],&eymin);
   frexpf([_y max],&eymax);
   frexpf([_z min],&ezmin);
   frexpf([_z max],&ezmax);
   gmax = max(exmin, exmax);
   gmax = max(gmax,eymin);
   gmax = max(gmax,eymax);
   zmin = (([_z min] <= 0 && [_z max] >= 0) || ([_x min] == 0.f && [_x max] == 0.f) ||([_y min] == 0.0f && [_y max] == 0.0f)) ? 0.0 : min(ezmin,ezmax);
   return gmax-zmin;
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

@implementation CPFloatTernaryMult{
   TRInt _limit;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x mult:(CPFloatVarI*)y
{
   return [self init:z equals:x mult:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x mult:(CPFloatVarI*)y kbpercent:(ORDouble)p
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
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
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
   
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   @autoreleasepool {
      do {
         changed = false;
         zTemp = z;
         fpi_multf(_precision, _rounding, &zTemp, &x, &y);
         inter = intersection(_z, z, zTemp,_percent);
         z = inter.result;
         changed |= inter.changed;
         
         xTemp = x;
         fpi_multxf_inv(_precision, _rounding, &xTemp, &z, &y);
         inter = intersection(_x, x , xTemp,_percent);
         x = inter.result;
         changed |= inter.changed;
         
         yTemp = y;
         fpi_multyf_inv(_precision, _rounding, &yTemp, &z, &x);
         inter = intersection(_y, y, yTemp,_percent);
         y = inter.result;
         changed |= inter.changed;
         
         /* ERROR PROPAG */
         [xr set_d:x.inf and:x.sup];
         [yr set_d:y.inf and:y.sup];
         
         [eoTemp set: compute_eo_mul_f(x, y, z)];
         [eo set: [eo proj_inter:eoTemp]];
         changed |= eo.changed;
         
         if(_limit._val && (z.inf <= z.sup)){
            if(
               ((z.inf >= 0) && (((float_cast)(z.inf)).parts.exponent == ((float_cast)(z.sup)).parts.exponent)) ||
               ((z.sup < 0) && (((float_cast)(z.inf)).parts.exponent == ((float_cast)(z.sup)).parts.exponent))
               ){
               assignTRInt(&limitCounter, limitCounter._val+1, _trail);
               assignTRInt(&_limit, NO, _trail);
            }
         }
         // ============================== ez
         // x*ey + y*ex + ex*ey + eo
         [ezTemp set: [[[[xr mul: ey] add: [yr mul: ex]] add: [ex mul: ey]] add: eo]];
         
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
-(id<CPVar>) result
{
   return _z;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ * %@>",_z, _x, _y];
}
@end

@implementation CPFloatTernaryDiv{
   TRInt _limit;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x div:(CPFloatVarI*)y
{
   return [self init:z equals:x div:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x div:(CPFloatVarI*)y kbpercent:(ORDouble)p
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
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
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
   id<ORRationalInterval> d1 = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> d2 = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> tmp = [[ORRationalInterval alloc] init];
   
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   @autoreleasepool {
      do {
         changed = false;
         zTemp = z;
         fpi_divf(_precision, _rounding, &zTemp, &x, &y);
         inter = intersection(_z, z, zTemp,_percent);
         z = inter.result;
         changed |= inter.changed;
         
         xTemp = x;
         fpi_divxf_inv(_precision, _rounding, &xTemp, &z, &y);
         inter = intersection(_x, x , xTemp,_percent);
         x = inter.result;
         changed |= inter.changed;
         
         yTemp = y;
         fpi_divyf_inv(_precision, _rounding, &yTemp, &z, &x);
         inter = intersection(_y, y, yTemp,_percent);
         y = inter.result;
         changed |= inter.changed;
         
         /* ERROR PROPAG */
         [xr set_d:x.inf and:x.sup];
         [yr set_d:y.inf and:y.sup];
         
         [eoTemp set: compute_eo_div_f(x, y, z)];
         [eo set: [eo proj_inter:eoTemp]];
         changed |= eo.changed;
         
         if(_limit._val && (z.inf <= z.sup)){
            if(
               ((z.inf >= 0) && (((float_cast)(z.inf)).parts.exponent == ((float_cast)(z.sup)).parts.exponent)) ||
               ((z.sup < 0) && (((float_cast)(z.inf)).parts.exponent == ((float_cast)(z.sup)).parts.exponent))
               ){
               assignTRInt(&limitCounter, limitCounter._val+1, _trail);
               assignTRInt(&_limit, NO, _trail);
            }
         }
         // ============================== ez
         // (y*ex - x*ey)/(y*(y + ey)) + eo
         [ezTemp set: [[[[yr mul: ex] sub: [xr mul: ey]] div: [yr mul: [yr add: ey]]] add: eo]];
         
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
   return ![_x bound] + ![_y bound] + ![_z bound];
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

@implementation CPFloatReifyNEqual
-(id) initCPReify:(CPIntVar*)b when:(CPFloatVarI*)x neq:(CPFloatVarI*)y
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
         [self addConstraint: [CPFactory floatNEqualc:_y to:[_x max]] engine:[_b engine]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }else  if ([_y bound] || [_y min] == [_y max]) {     // TRUE <=> (x != c)
         [self addConstraint: [CPFactory floatNEqualc:_x to:[_y max]] engine:[_b engine]];         // Rewrite as x==y  (addInternal can throw)
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyNEqual:%02d %@ <=> (%@ != %@)>",_name,_b,_x,_y];
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

@implementation CPFloatReifyEqual{
   ORBool _notified;
   ORBool _drewrite;
   ORBool _srewrite;
}
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(CPFloatVarI*)y dynRewrite:(ORBool) r staticRewrite:(ORBool) s
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
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(CPFloatVarI*)y
{
   self = [self initCPReifyEqual:b when:x eqi:y dynRewrite:NO staticRewrite:NO];
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
         if(!_notified && ((_drewrite && ![[_x engine] isPosting]) || (_srewrite && [[_x engine] isPosting]))){
            [[[_x engine] mergedVar] notifyWith:_x andId:_y  isStatic:[[_x engine] isPosting]];
            [[_x engine] incNbRewrites:1];
            _notified = YES;
         }
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_x bound] || [_x min] == [_x max] )
         [self addConstraint: [CPFactory floatNEqualc:_y to:[_x min]] engine:[_b engine]];
      else if ([_y bound] || [_y min] == [_y max])
         [self addConstraint: [CPFactory floatNEqualc:_y to:[_x min]] engine:[_b engine]];
   }else {                        // b is unknown
      if (([_x bound] && [_y bound]) || ([_x min] == [_x max] &&  [_y min] == [_y max]))
         [_b bind: [_x min] == [_y min]];
      else if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:NO];
   }
   if(([_b bound] && [_x bound] && [_y bound])  || ([_b bound] && ([_x min] == [_x max] &&  [_y min] == [_y max]))) assignTRInt(&_active, 0, _trail);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyEqual:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
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

@implementation CPFloatReifyAssignc{
   ORInt _precision;
   ORInt _rounding;
}
-(id) initCPReify:(CPIntVar*)b when:(CPFloatVarI*)x set:(ORFloat)c
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
         [self addConstraint:[CPFactory floatAssignC:_x to:_c] engine:[_x engine]];
      }else{
         if ([_x bound]){
            if(is_eqf([_x min],_c)) failNow();
         }else{
            if(is_eqf([_x min],_c)){
               [_x updateMin:fp_next_float(_c)];
               assignTRInt(&_active, NO, _trail);
            }else if(is_eqf([_x max],_c)){
               [_x updateMax:fp_previous_float(_c)];
               assignTRInt(&_active, NO, _trail);
            }
         }
      }
   }else{
      if ([_x bound]) {
         [_b bind:is_eqf([_x min],_c)];
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyAssignC:%02d %@ <=> (%@ <- %16.16e)>",_name,_b,_x,_c];
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

@implementation CPFloatReifyAssign{
   ORInt _precision;
   ORInt _rounding;
   float_interval _xi;
   float_interval _yi;
}
-(id) initCPReify:(CPIntVar*)b when:(CPFloatVarI*)x set:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   _xi = makeFloatInterval(x.min, x.max);
   _yi = makeFloatInterval(y.min, y.max);
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
         [self addConstraint:[CPFactory floatAssign:_x to:_y] engine:[_x engine]];
      }else{
         if ([_x bound]) {
            if([_y bound]){
               if (is_eqf([_x min],[_y min]))
                  failNow();
            }else{
                  if(is_eqf([_x min],[_y min])){
                     [_y updateMin:fp_next_float([_y min])];
                     assignTRInt(&_active, NO, _trail);
                  }
                  if(is_eqf([_x min],[_y max])) {
                     [_y updateMax:fp_previous_float([_y max])];
                     assignTRInt(&_active, NO, _trail);
                  }
               }
         }else  if([_y bound]){
            if(is_eqf([_x min],[_y min])){
               [_x updateMin:fp_next_float([_x min])];
               assignTRInt(&_active, NO, _trail);
            }
            if(is_eqf([_x max],[_y min])){
               [_x updateMax:fp_previous_float([_x max])];
               assignTRInt(&_active, NO, _trail);
            }
         }
      }
   }else{
      if ([_x bound] && [_y bound])
         [_b bind:is_eqf([_x min], [_y min])];
   }
   if([_b bound] && [_x bound] && [_y bound]) assignTRInt(&_active, 0, _trail);
}

-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyAssign:%02d %@ <=> (%@ <- %@)>",_name,_b,_x,_y];
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

@implementation CPFloatReifyGThen
-(id) initCPReifyGThen:(CPIntVar*)b when:(CPFloatVarI*)x gti:(CPFloatVarI*)y
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
         if(canPrecede(_x,_y))
            failNow();
         if(isIntersectingWith(_x,_y)){
            if([_x min] <= [_y min]){
               ORFloat pmin = fp_next_float([_y min]);
               [_x updateMin:pmin];
            }
            if([_x max] <= [_y max]){
               ORFloat nmax = fp_previous_float([_x max]);
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqual:%02d %@ <=> (%@ > %@)>",_name,_b,_x,_y];
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


@implementation CPFloatReifyGEqual
-(id) initCPReifyGEqual:(CPIntVar*)b when:(CPFloatVarI*)x geqi:(CPFloatVarI*)y
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
         [_y updateMax:fp_next_float([_x max])];
         [_x updateMin:fp_previous_float([_y min])];
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqual:%02d %@ <=> (%@ >= %@)>",_name,_b,_x,_y];
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


@implementation CPFloatReifyLEqual
-(id) initCPReifyLEqual:(CPIntVar*)b when:(CPFloatVarI*)x leqi:(CPFloatVarI*)y
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
         [_x updateMin:fp_next_float([_y min])];
         [_y updateMax:fp_previous_float([_x max])];
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLEqual:%02d %@ <=> (%@ <= %@)>",_name,_b,_x,_y];
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


@implementation CPFloatReifyLThen
-(id) initCPReifyLThen:(CPIntVar*)b when:(CPFloatVarI*)x lti:(CPFloatVarI*)y
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
         if(canFollow(_x,_y))
            failNow();
         if(isIntersectingWith(_x,_y)){
            if([_x min] >= [_y min]){
               ORFloat nmin = fp_next_float([_x min]);
               [_y updateMin:nmin];
            }
            if([_x max] >= [_y max]){
               ORFloat pmax = fp_previous_float([_y max]);
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
   if([_b bound] && [_x bound] && [_y bound])
      assignTRInt(&_active, NO, _trail);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLThen:%02d %@ <=> (%@ < %@)>",_name,_b,_x,_y];
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




@implementation CPFloatReifyEqualc
-(id) initCPReifyEqualc:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(ORFloat)c
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
         [self addConstraint: [CPFactory floatNEqualc:_x to:_c] engine:[_b engine]];    // Rewrite as x!=c  (addInternal can throw)
   }
   else if ([_x bound])
      [_b bind:[_x min] == _c];
   else if (![_x member:_c])
      [_b bind:false];
   else {
      [_b setBindTrigger: ^ {
         if ([_b min] == true)
            [_x bind:_c];
          else
            [self addConstraint: [CPFactory floatNEqualc:_x to:_c] engine:[_b engine]];     // Rewrite as x!=c  (addInternal can throw)
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyEqual:%02d %@ <=> (%@ == %16.16e)>",_name,_b,_x,_c];
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

@implementation CPFloatReifyLEqualc
-(id) initCPReifyLEqualc:(CPIntVar*)b when:(CPFloatVarI*)x leqi:(ORFloat)c
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
         [_x updateMin:fp_next_float(_c)];
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLEqualc:%02d %@ <=> (%@ <= %16.16e)>",_name,_b,_x,_c];
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


@implementation CPFloatReifyLThenc
-(id) initCPReifyLThenc:(CPIntVar*)b when:(CPFloatVarI*)x lti:(ORFloat)c
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
         [_x updateMax:fp_previous_float(_c)];
      else
         [_x updateMin:_c];
      assignTRInt(&_active, NO, _trail);
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLThenc:%02d %@ <=> (%@ < %16.16e)>",_name,_b,_x,_c];
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


@implementation CPFloatReifyNotEqualc
-(id) initCPReifyNotEqualc:(CPIntVar*)b when:(CPFloatVarI*)x neqi:(ORFloat)c
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
         [self addConstraint: [CPFactory floatNEqualc:_x to:_c] engine:[_b engine]];     // Rewrite as x!=c  (addInternal can throw)
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
            [self addConstraint: [CPFactory floatNEqualc:_x to:_c] engine:[_b engine]];     // Rewrite as x!=c  (addInternal can throw)
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyNotEqualc:%02d %@ <=> (%@ != %16.16e)>",_name,_b,_x,_c];
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

@implementation CPFloatReifyGEqualc
-(id) initCPReifyGEqualc:(CPIntVar*)b when:(CPFloatVarI*)x geqi:(ORFloat)c
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
         [_x updateMax:fp_previous_float(_c)];
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqualc:%02d %@ <=> (%@ >= %16.16e)>",_name,_b,_x,_c];
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


@implementation CPFloatReifyGThenc
-(id) initCPReifyGThenc:(CPIntVar*)b when:(CPFloatVarI*)x gti:(ORFloat)c
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
         [_x updateMin:fp_next_float(_c)];
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
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqualc:%02d %@ <=> (%@ > %16.16e)>",_name,_b,_x,_c];
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

@implementation CPFloatSquare{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _resi;
}
-(id) init:(CPFloatVarI*)res eq:(CPFloatVarI*)x //res = x^2
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeFloatInterval(x.min, x.max);
   _resi = makeFloatInterval(res.min, res.max);
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
   updateFloatInterval(&_xi,_x);
   updateFloatInterval(&_resi,_res);
   intersectionInterval inter;
   float_interval resTmp = makeFloatInterval(_resi.inf, _resi.sup);
   fpi_xxf(_precision, _rounding, &resTmp, &_xi);
   inter = intersection(_res, _resi, resTmp, 0.0f);
   if(inter.changed)
      [_res updateInterval:inter.result.inf and:inter.result.sup];
   
   updateFloatInterval(&_xi,_x);
   float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
   fpi_xxf_inv(_precision,_rounding, &xTmp, &_resi);
   inter = intersection(_x, _xi, xTmp, 0.0f);
   if(inter.changed)
      [_x updateInterval:inter.result.inf and:inter.result.sup];
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
   return [NSString stringWithFormat:@"<%@ == (%@^2)>",_res,_x];
}
- (id<CPVar>)result
{
   return _res;
}
@end

@implementation CPFloatVarMinimize
{
   CPFloatVarI*  _x;
   ORFloat       _primalBound;
   ORFloat       _dualBound;
}
-(CPFloatVarMinimize*) init: (CPFloatVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = +INFINITY;
   _dualBound   = -INFINITY;
   return self;
}
-(id<CPFloatVar>)var
{
   return _x;
}
-(void) post
{
   if (![_x bound])
      [_x whenChangeMinDo: ^ {
         [_x updateMax: nextafterf(_primalBound,-INFINITY)];
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
-(ORBool)   isMinimization
{
   return YES;
}
-(void) updatePrimalBound
{
   ORFloat bound = [_x min];
   @synchronized(self) {
      if (bound < _primalBound)
         _primalBound = nextafterf(bound,-INFINITY);
   }
}
-(void) updateDualBound
{
   ORFloat bound = [_x min];
   @synchronized (self) {
      if (bound > _dualBound)
         _dualBound = nextafterf(bound,+INFINITY);
   }
}
-(void) tightenPrimalBound: (id<ORObjectiveValueFloat>) newBound
{
   @synchronized(self) {
      if ([newBound value] < _primalBound)
         _primalBound = [newBound value];
   }
}
-(ORStatus) tightenDualBound:(id<ORObjectiveValueFloat>)newBound
{
   @synchronized (self) {
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         ORFloat b = [(id<ORObjectiveValueInt>)newBound value];
         ORStatus ok = b > _primalBound ? ORFailure : ORSuspend;
         if (ok && b > _dualBound)
            _dualBound = b;
         return ok;
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
         ORFloat b = [(id<ORObjectiveValueFloat>)newBound value];
         ORStatus ok = b > _primalBound ? ORFailure : ORSuspend;
         if (ok && b > _dualBound)
            _dualBound = b;
         return ok;
      } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         ORFloat b = [(id<ORObjectiveValueReal>)newBound doubleValue];
         ORStatus ok = b > _primalBound ? ORFailure : ORSuspend;
         if (ok && b > _dualBound)
            _dualBound = b;
         return ok;
      } else return ORFailure;
   }
}
-(void) tightenLocallyWithDualBound: (id) newBound
{
   @synchronized(self) {
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         ORFloat b = [((id<ORObjectiveValueInt>) newBound) value];
         [_x updateMin: b];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
         ORFloat b = [((id<ORObjectiveValueFloat>) newBound) value];
         [_x updateMin: b];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         ORFloat b = [((id<ORObjectiveValueReal>) newBound) value];
         [_x updateMin: b];
      }
   }
}

-(id<ORObjectiveValue>) primalValue
{
   return [ORFactory objectiveValueFloat:[_x value] minimize:YES];
}
-(id<ORObjectiveValue>) dualValue
{
   return [ORFactory objectiveValueFloat:[_x min] minimize:NO];
   // dual bound ordering is opposite of primal bound. (if we minimize in primal, we maximize in dual).
}
-(id<ORObjectiveValue>) primalBound
{
   return [ORFactory objectiveValueFloat:_primalBound minimize:YES];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueFloat:_dualBound minimize:YES];
}

-(ORStatus) check
{
   return tryfail(^ORStatus{
      [_x updateMax:nextafterf(_primalBound,-INFINITY)];
      [_x updateMin:_dualBound];
      return ORSuspend;
   }, ^ORStatus{
      return ORFailure;
   });
}
-(ORBool)   isBound
{
   return [_x bound];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"MINIMIZE(%@) with f* = %f  (dual: %f)",[_x description],_primalBound,_dualBound];
   return buf;
}
@end

@implementation CPFloatVarMaximize
{
   CPFloatVarI*  _x;
   ORFloat    _primalBound;
   ORFloat      _dualBound;
}

-(CPFloatVarMaximize*) init: (CPFloatVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = -INFINITY;
   _dualBound = +INFINITY;
   return self;
}
-(id<CPFloatVar>)var
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
         [_x updateMin: nextafterf(_primalBound,+INFINITY)];
      } onBehalf:self];
}

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(id<ORObjectiveValue>) primalValue
{
   return [ORFactory objectiveValueFloat:_x.value minimize:NO];
}
-(id<ORObjectiveValue>) dualValue
{
   return [ORFactory objectiveValueFloat:_x.max minimize:YES];
}

-(id<ORObjectiveValue>) primalBound
{
   return [ORFactory objectiveValueFloat:_primalBound minimize:NO];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueFloat:_dualBound minimize:NO];
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
   NSLog(@"primal bound: %20.20e",_primalBound);
}
-(void) updateDualBound
{
   ORFloat bound = [_x max];
   if (bound < _dualBound)
      _dualBound = bound;
   NSLog(@"dual bound: %20.20e",_dualBound);
}

-(void) tightenPrimalBound: (id<ORObjectiveValueFloat>) newBound
{
   if ([newBound value] > _primalBound)
      _primalBound = [newBound value];
}
-(ORStatus) tightenDualBound:(id<ORObjectiveValue>)newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      ORFloat b = [(id<ORObjectiveValueInt>)newBound value];
      ORStatus ok = b < _primalBound ? ORFailure : ORSuspend;
      if (ok && b < _dualBound)
         _dualBound = b;
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
      ORFloat b = [(id<ORObjectiveValueFloat>)newBound floatValue];
      ORStatus ok = b < _primalBound ? ORFailure : ORSuspend;
      if (ok && b < _dualBound)
         _dualBound = b;
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      ORDouble b = [(id<ORObjectiveValueReal>)newBound doubleValue];
      ORStatus ok = b < _primalBound ? ORFailure : ORSuspend;
      if (ok && b < _dualBound)
         _dualBound = b;
      return ok;
   }  else return ORSuspend;
}

-(void) tightenLocallyWithDualBound: (id) newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      ORFloat b = [((id<ORObjectiveValueInt>) newBound) value];
      [_x updateMax: b];
   }
   else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
      ORFloat b = [((id<ORObjectiveValueFloat>) newBound) value];
      [_x updateMax: b];
   }
   else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      ORFloat b = [((id<ORObjectiveValueReal>) newBound) value];
      [_x updateMax: b];
   }
}

-(ORStatus) check
{
   @try {
      [_x updateMin:nextafterf(_primalBound,+INFINITY)];
      [_x updateMax:_dualBound];
   }
   @catch (ORFailException* e) {
      [e release];
      return ORFailure;
   }
   return ORSuspend;
}

-(ORBool)   isBound
{
   return [_x bound];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"MAXIMIZE(%@) with f* = %f  (dual: %f) [thread: %d]",[_x description],_primalBound,_dualBound,[NSThread threadID]];
   return buf;
}
@end
@implementation CPFloatAbs{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _resi;
}
-(id) init:(CPFloatVarI*)res eq:(CPFloatVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeFloatInterval(x.min, x.max);
   _resi = makeFloatInterval(res.min, res.max);
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
      updateFloatInterval(&_xi,_x);
      updateFloatInterval(&_resi,_res);
      intersectionInterval inter;
      float_interval resTmp = makeFloatInterval(_resi.inf, _resi.sup);
      fpi_fabsf(_precision, _rounding, &resTmp, &_xi);
      inter = intersection(_res, _resi, resTmp, 0.0f);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      updateFloatInterval(&_xi,_x);
      float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
      fpi_fabs_invf(_precision,_rounding, &xTmp, &_resi);
      inter = intersection(_x, _xi, xTmp, 0.0f);
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

@implementation CPFloatSqrt{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _resi;
}
-(id) init:(CPFloatVarI*)res eq:(CPFloatVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeFloatInterval(x.min, x.max);
   _resi = makeFloatInterval(res.min, res.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[res engine] trail] lowF:-INFINITY upF:+INFINITY];
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
   int gchanged,changed;
   changed = gchanged = false;
   //   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   //   id<ORRationalInterval> eres = [[ORRationalInterval alloc] init];
   //   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   //   id<ORRationalInterval> exTemp = [[ORRationalInterval alloc] init];
   //   id<ORRationalInterval> eresTemp = [[ORRationalInterval alloc] init];
   //   id<ORRationalInterval> eoTemp = [[ORRationalInterval alloc] init];
   //   id<ORRationalInterval> one = [[ORRationalInterval alloc] init];
   //   id<ORRationalInterval> two = [[ORRationalInterval alloc] init];
   //   id<ORRationalInterval> xq = [[ORRationalInterval alloc] init];
   
   updateFloatInterval(&_xi,_x);
   updateFloatInterval(&_resi,_res);
   
   //   [one.low setOne];
   //   [one.up setOne];
   //   [two set_d:2.0 and:2.0];
   //   [xq set_d:_xi.inf and:_xi.sup];
   //   [ex set_q:[_x minErr] and:[_x maxErr]];
   //   [eres set_q:[_res minErr] and:[_res maxErr]];
   //   [eo set_q:[_eo min] and:[_eo max]];
   
   
   intersectionInterval inter;
   float_interval resTmp = makeFloatInterval(_resi.inf, _resi.sup);
   fpi_sqrtf(_precision,_rounding, &resTmp, &_xi);
   inter = intersection(_res, _resi, resTmp, 0.0f);
   if(inter.changed)
      [_res updateInterval:inter.result.inf and:inter.result.sup];
   
   updateFloatInterval(&_xi,_x);
   float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
   fpi_sqrtf_inv(_precision,_rounding, &xTmp, &_resi);
   inter = intersection(_x, _xi, xTmp, 0.0f);
   if(inter.changed)
      [_x updateInterval:inter.result.inf and:inter.result.sup];
   if([_res bound] && [_x bound])
      assignTRInt(&_active, NO, _trail);
   
   /* ERROR PROPAG */
   //   do {
   //      eo = compute_eo_sqrt(eo, _xi, _resi);
   //      changed |= eo.changed;
   //      // ============================== ez
   //      // sqrt(x) * (sqrt(1 + ex) - 1) + eo
   //      eresTemp = [[[xq sqrt] mul: [[[ex add: one] sqrt] sub: one]] add: eo];
   //      eres = [eres proj_inter: eresTemp];
   //      changed |= eres.changed;
   //
   //      // ============================== eo
   //      // ez - sqrt(x) * (sqrt(1 + ex) - 1)
   //      eoTemp = [eres sub: [[xq sqrt] mul: [[[ex add: one] sqrt] sub: one]]];
   //      eo = [eo proj_inter: eoTemp];
   //      changed |= eo.changed;
   //
   //      // ============================== ex
   //      // (eo^2 - 2*eo*ez + ez^2 - 2*eo*sqrt(x) + 2*ez*sqrt(x)) / x
   //      exTemp = [[[[[[eo mul: eo] sub: [[two mul: eo] mul: eres]] add: [eres mul: eres]] sub: [[two mul: eo] mul: [xq sqrt]]] add: [[two mul: eres] mul: [xq sqrt]]] div: xq];
   //      ex = [ex proj_inter: exTemp];
   //      changed |= ex.changed;
   //
   //      gchanged |= changed;
   //   } while(changed);
   /* END ERROR PROPAG */
   //if(gchanged){
   // Cause no propagation on eo is insured
   //[_eo updateMin:(eo.low) for:NULL];
   //[_eo updateMax:(eo.up) for:NULL];
   
   //[_x updateIntervalError:(ex.low) and:(ex.up)];
   //[_res updateIntervalError:(eres.low) and:(eres.up)];
   //      if([_x bound] && [_res bound] && [_x boundError] && [_res boundError])
   //         assignTRInt(&_active, NO, _trail);
   //   }
   //   [ex release];
   //   [eres release];
   //   [eo release];
   //   [exTemp release];
   //   [eresTemp release];
   //   [eoTemp release];
   //   [one release];
   //   [two release];
   //   [xq release];
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

@implementation CPFloatIsPositive
-(id) init:(CPFloatVarI*) x isPositive:(CPIntVarI*) b
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
         [_x updateMin:+0.0f];
      else
         [_x updateMax:-0.0f];
   } else {
      if (is_positivef([_x min])) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if (is_negativef([_x max])) {
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

@implementation CPFloatIsZero
-(id) init:(CPFloatVarI*) x isZero:(CPIntVarI*) b
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
         [_x updateInterval:-0.0f and:+0.0f];
      else
         [self addConstraint:[CPFactory floatNEqualc:_x to:0.0f] engine:[_x engine]];
   } else {
      if([_x bound]){
         bindDom(_b, [_x min] == 0.0f);
         assignTRInt(&_active, NO, _trail);
      }else if ([_x min] == 0.0f && [_x max] == 0.0f) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > 0.0f && [_x max] < 0.0f) {
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

@implementation CPFloatIsInfinite
-(id) init:(CPFloatVarI*) x isInfinite:(CPIntVarI*) b
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
         [_x updateInterval:fp_next_float(-INFINITY) and:fp_previous_float(+INFINITY)];
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

@implementation CPFloatIsNormal
-(id) init:(CPFloatVarI*)x isNormal:(CPIntVarI*)b
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
         if([_x bound] && is_infinityf([_x min]))
            failNow();
         
         if([_x min] >= -maxdenormalf() && [_x min] <= maxdenormalf()){
            [_x updateMin:minnormalf()];
            assignTRInt(&_active, NO, _trail);
         }else if(is_infinityf([_x min]))
            [_x updateMin:fp_next_float(-infinityf())];
         
         if([_x max] >= -maxdenormalf() && [_x max] <= maxdenormalf()){
            [_x updateMax:-minnormalf()];
            assignTRInt(&_active, NO, _trail);
         }else if(is_infinityf([_x max]))
            [_x updateMax:fp_previous_float(infinityf())];
         
      }else{
         [_x updateInterval:-maxdenormalf() and:maxdenormalf()];
         assignTRInt(&_active, NO, _trail);
      }
   }else{
      if([_x min] >= -maxdenormalf() && [_x max] <= maxdenormalf()){
         [_b bind:0];
         assignTRInt(&_active, NO, _trail);
      }else if(([_x max] <= -minnormalf() || [_x min] >= minnormalf()) && !is_infinityf([_x max]) && !is_infinityf([_x min])){
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

@implementation CPFloatIsSubnormal
-(id) init:(CPFloatVarI*)x isSubnormal:(CPIntVarI*)b
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
         [_x updateInterval:-maxdenormalf() and:maxdenormalf()];
         [self addConstraint:[CPFactory floatNEqualc:_x to:0.0f] engine:[_x engine]];
         assignTRInt(&_active, NO, _trail);
      }else{
         [self addConstraint:[CPFactory floatNEqualc:_x to:0.0f] engine:[_x engine]];
         if([_x min] >= -maxdenormalf() && [_x min] <= maxdenormalf()){
            [_x updateMin:minnormalf()];
            assignTRInt(&_active, NO, _trail);
         }
         if([_x max] >= -maxdenormalf() && [_x max] <= maxdenormalf()){
            [_x updateMax:-minnormalf()];
            assignTRInt(&_active, NO, _trail);
         }
      }
   }else{
      if(([_x min] >= -maxdenormalf() && [_x max] <= -mindenormalf()) || ([_x min] >= mindenormalf() && [_x max] <= maxdenormalf())){
         [_b bind:1];
         assignTRInt(&_active, NO, _trail);
      }else if([_x max] <= -minnormalf() || [_x min] >= minnormalf() || ([_x min] == 0.0f && [_x min] == 0.0f)){
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
