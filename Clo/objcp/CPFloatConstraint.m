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

void ulp_computation_f(id<ORRationalInterval> ulp, const float_interval f){
   id<ORRational> tmp0 = [[ORRational alloc] init];
   id<ORRational> tmp1 = [[ORRational alloc] init];
   id<ORRational> tmp2 = [[ORRational alloc] init];
   
   
   if(f.inf == -INFINITY || f.sup == INFINITY){
      [tmp1 setNegInf];
      [tmp2 setPosInf];
      [ulp set_q:tmp1 and:tmp2];
   }else if(fabs(f.inf) == DBL_MAX || fabs(f.sup) == DBL_MAX){
      [tmp0 set_d: nextafterf(DBL_MAX, -INFINITY) - DBL_MAX];
      [tmp1 set_d: 2.0];
      tmp2 = [tmp0 div: tmp1];
      [tmp1 set: tmp2];
      [tmp2 neg];
      [ulp set_q:tmp2 and:tmp1];
   } else{
      ORDouble inf, sup;
      inf = minDbl(nextafterf(f.inf, -INFINITY) - f.inf, nextafterf(f.sup, -INFINITY) - f.sup);
      sup = maxDbl(nextafterf(f.inf, +INFINITY) - f.inf, nextafterf(f.sup, +INFINITY) - f.sup);
      
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

id<ORRationalInterval> compute_eo_add(id<ORRationalInterval> eo, const float_interval x, const float_interval y, const float_interval z){
   /* First, let see if Sterbenz is applicable */
   if (((0.0 <= x.inf) && (y.sup <= 0.0) && (-y.inf/2.0 <= x.inf) && (x.sup <= -2.0*y.sup)) ||
       ((x.sup <= 0.0) && (0.0 <= y.inf) && (y.sup/2.0 <= -x.sup) && (-x.inf <= 2.0*y.inf))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
   } else if ((((float_cast)((z.inf))).parts.exponent <= 1) && (((float_cast)((z.sup))).parts.exponent <= 1)) {
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
      
      ulp_computation_f(ulp_q, z);
      eo = [eo proj_inter:ulp_q];
      
      [ulp_q release];
   }
   
   return eo;
}

id<ORRationalInterval> compute_eo_sub(id<ORRationalInterval> eo, const float_interval x, const float_interval y, const float_interval z){
   
   /* First, let see if Sterbenz is applicable (requires gradual underflow (denormalized) or that x-y does not underflow */
   if (((x.inf >= 0.0) && (y.inf >= 0.0) && (y.sup/2.0 <= x.inf) && (x.sup <= 2.0*y.inf)) ||
       ((x.sup <= 0.0) && (y.sup <= 0.0) && (y.inf/2.0 >= x.sup) && (x.inf >= 2.0*y.sup))) {
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      eo = [eo proj_inter:zero and:zero];
      [zero release];
   } else if ((((float_cast)((z.inf))).parts.exponent <= 1) && (((float_cast)((z.sup))).parts.exponent <= 1)) {
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
      
      ulp_computation_f(ulp_q, z);
      eo = [eo proj_inter:ulp_q];
      [ulp_q release];
   }
   
   return eo;
}

id<ORRationalInterval> compute_eo_mul(id<ORRationalInterval> eo, const float_interval x, const float_interval y, const float_interval z){
   
   /* Check if its a product by a power of 2 */
   if (((x.inf == x.sup) && (((float_cast)((x.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(x.inf) <= y.inf) && (y.sup <= DBL_MAX/fabs(x.inf))) ||
       ((y.inf == y.sup) && (((float_cast)((y.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(y.inf) <= x.inf) && (x.sup <= DBL_MAX/fabs(y.inf)))) {
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
      
      ulp_computation_f(ulp_q, z);
      eo = [eo proj_inter:ulp_q];
      [ulp_q release];
   }
   
   return eo;
}

int checkDivPower2f(float x, float y) { // x/y
   float_cast z;
   z.f = x/y;
   return (z.parts.exponent >= 1);
}

id<ORRationalInterval> compute_eo_div(id<ORRationalInterval> eo, const float_interval x, const float_interval y, const float_interval z){
   
   /* Check if its a division by a power of 2 */
   if ((y.inf == y.sup) && (((float_cast)(y.inf)).parts.mantissa == 0) &&
       (((-DBL_MAX <= x.inf) && (x.sup < 0.0) && checkDivPower2f(x.sup, y.inf)) || ((0.0 < x.inf) && (x.sup <= DBL_MAX) && checkDivPower2f(x.inf, y.inf)))) {
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
      
      ulp_computation_f(ulp_q, z);
      eo = [eo proj_inter:ulp_q];
      [ulp_q release];
   }
   
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
      
      ulp_computation_f(ulp_q, z);
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
}
-(id) init:(CPFloatVarI*)res equals:(CPDoubleVarI*)initial
{
   self = [super initCPCoreConstraint: [res engine]];
   _res = res;
   _initial = initial;
   _resi = makeFloatInterval(_res.min, _res.max);
   _initiali = makeDoubleInterval(_initial.min, _initial.max);
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
@end

//unary minus constraint
@implementation CPFloatUnaryMinus{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _yi;
}
-(id) init:(CPFloatVarI*)x eqm:(CPFloatVarI*)y //x = -y
{
   self = [super initCPCoreConstraint: [x engine]];
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
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      if([_y bound]){
         if([_x value] != - [_y value]) failNow();
         assignTRInt(&_active, NO, _trail);
      }else{
         [_y bind:-[_x value]];
         assignTRInt(&_active, NO, _trail);
      }
   }else if([_y bound]){
      [_x bind:-[_y value]];
      assignTRInt(&_active, NO, _trail);
   }else {
      updateFloatInterval(&_xi,_x);
      updateFloatInterval(&_yi,_y);
      intersectionInterval inter;
      float_interval yTmp = makeFloatInterval(_yi.inf, _yi.sup);
      fpi_minusf(_precision,_rounding, &yTmp, &_xi);
      inter = intersection(_y, _yi, yTmp, 0.0f);
      if(inter.changed)
         [_y updateInterval:inter.result.inf and:inter.result.sup];
      
      updateFloatInterval(&_yi,_y);
      float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
      fpi_minusf(_precision,_rounding, &xTmp, &_yi);
      inter = intersection(_x, _xi, xTmp, 0.0f);
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
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

@implementation CPFloatEqual
-(id) init:(CPFloatVarI*)x equals:(CPFloatVarI*)y
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
   
   fesetround(FE_TONEAREST);
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
            if([_x max] == [_y min]){
               [_y updateMin:fp_next_float([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x max] == [_y max]) {
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
      if([_x min] == [_y max]) {
         [_x updateMin:fp_next_float([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y min]){
         [_x updateMax:fp_previous_float([_x max])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y max]) {
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
   
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y
{
   return [self init:z equals:x plus:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError]) [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError]) [_y whenChangeBoundsPropagate:self];
   if(![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
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
      
      eo = compute_eo_add(eo, x, y, z);
      changed |= eo.changed;
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
@end


@implementation CPFloatTernarySub{
   
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y
{
   return [self init:z equals:x minus:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
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
   
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ey set_q:[_y minErr] and:[_y maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
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
      eo = compute_eo_sub(eo, x, y, z);
      changed |= eo.changed;
      
      
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
@end

@implementation CPFloatTernaryMult{
   
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
      
      eo = compute_eo_mul(eo, x, y, z);
      changed |= eo.changed;
      
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

      x.inf = [[xr low] get_d];
      x.sup = [[xr up] get_d];
      
      // ============================== y
      // (ez - x*ey - ex*ey - eo)/ex
      yrTemp = [[[[ez sub: [xr mul: ey]] sub: [ex mul: ey]] sub: eo] div: ex];
      
      yr = [yr proj_inter:yrTemp];
      changed |= yr.changed;
      
      y.inf = [[yr low] get_d];
      y.sup = [[yr up] get_d];

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
-(id<CPFloatVar>) result
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
      
      eo = compute_eo_div(eo, x, y, z);
      changed |= eo.changed;
      
      
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
      
      x.inf = [[xr low] get_d];
      x.sup = [[xr up] get_d];
      
      // ============================== y
      // min(d1, d2), max(d1, d2)
      // d1 = (ex - (ez - eo)*ey - sqrt(D))/(2*(ez - eo))
      // d2 = (ex - (ez - eo)*ey + sqrt(D))/(2*(ez - eo))
      // D = [0, +INF] inter ((ez - eo)*ey - ex)^2 + 4*(ez - eo)*ey*x
      
      [tmp set_d:4.0 and:4.0];
      D = [[[[[ez sub: eo] mul: ey] sub: ex] mul: [[[ez sub: eo] mul: ey] sub: ex]] add: [[[tmp mul: [ez sub: eo]] mul: ey] mul: xr]];
      [tmp set_d:0.0 and:+INFINITY];
      D = [tmp proj_inter:D];
      
      tmp = [ex sub: [[ez sub: eo] mul: ey]];
      /* Check difference */
      /*[D.low set_d: sqrt([D.low get_d])];
      [D.up set_d: sqrt([D.up get_d])];*/
      D = [D sqrt];
      d1 = [tmp sub: D];
      d2 = [tmp add: D];
      [tmp set_d:2.0 and:2.0];
      tmp = [tmp mul: [ez sub: eo]];
      d1 = [d1 div: tmp];
      d2 = [d2 div: tmp];
      
      [yrTemp set_q:minQ(d1.low, d2.low) and:maxQ(d1.up, d2.up)];
      yr = [yr proj_inter:yrTemp];
      changed |= yr.changed;
      
      y.inf = [[yr low] get_d];
      y.sup = [[yr up] get_d];
      
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
         [[_b engine] addInternal: [CPFactory floatNEqualc:_y to:[_x max]]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }else  if ([_y bound] || [_y min] == [_y max]) {     // TRUE <=> (x != c)
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:[_y max]]];         // Rewrite as x==y  (addInternal can throw)
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

@implementation CPFloatReifyEqual
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(CPFloatVarI*)y
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
         [[_b engine] addInternal: [CPFactory floatNEqualc:_y to:[_x min]]]; // Rewrite as min(x)!=y  (addInternal can throw)
      else if ([_y bound] || [_y min] == [_y max])
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:[_y min]]]; // Rewrite as min(y)!=x  (addInternal can throw)
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
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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
            [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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
            [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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

@implementation CPFloatSQRT{
   
}
-(id) init:(CPFloatVarI*)z equalsSQRT:(id)x
{
   return [self init:z equalsSQRT:x kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equalsSQRT:(CPFloatVarI*)x kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-INFINITY upF:+INFINITY];
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError]) [_x whenChangeBoundsPropagate:self];
   if(![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
//hzi : _Temps variables are useless ? inter.result ? x is already changed ?
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,xTemp,z,x;
   intersectionInterval inter;
   id<ORRationalInterval> ex = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ez = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eo = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> exTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> ezTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> eoTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> one = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> two = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xq = [[ORRationalInterval alloc] init];
   [one.low setOne];
   [one.up setOne];
   [two set_d:2.0 and:2.0];
   [xq set_d:x.inf and:x.sup];
   
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   
   [ex set_q:[_x minErr] and:[_x maxErr]];
   [ez set_q:[_z minErr] and:[_z maxErr]];
   [eo set_q:[_eo min] and:[_eo max]];
   
   do {
      changed = false;
      zTemp = z;
      fpi_sqrtf(_precision, _rounding, &zTemp, &x);
      inter = intersection(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_sqrtf_inv(_precision, _rounding, &xTemp, &z);
      inter = intersection(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      
      eo = compute_eo_sqrt(eo, x, z);
      changed |= eo.changed;
      // ============================== ez
      // sqrt(x) * (sqrt(1 + ex) - 1) + eo
      ezTemp = [[[xq sqrt] mul: [[[ex add: one] sqrt] sub: one]] add: eo];
      ez = [ez proj_inter: ezTemp];
      changed |= ez.changed;
      
      // ============================== eo
      // ez - sqrt(x) * (sqrt(1 + ex) - 1)
      eoTemp = [ez sub: [[xq sqrt] mul: [[[ex add: one] sqrt] sub: one]]];
      eo = [eo proj_inter: eoTemp];
      changed |= eo.changed;
      
      // ============================== ex
      // (eo^2 - 2*eo*ez + ez^2 - 2*eo*sqrt(x) + 2*ez*sqrt(x)) / x
      exTemp = [[[[[[eo mul: eo] sub: [[two mul: eo] mul: ez]] add: [ez mul: ez]] sub: [[two mul: eo] mul: [xq sqrt]]] add: [[two mul: ez] mul: [xq sqrt]]] div: xq];
      ex = [ex proj_inter: exTemp];
      changed |= ex.changed;
      
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);
   
   if(gchanged){
      // Cause no propagation on eo is insured
      [_eo updateMin:(eo.low) for:NULL];
      [_eo updateMax:(eo.up) for:NULL];
      
      [_x updateInterval:x.inf and:x.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:(ex.low) and:(ex.up)];
      [_z updateIntervalError:(ez.low) and:(ez.up)];
      if([_x bound] && [_z bound] && [_x boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
   }
   
   fesetround(FE_TONEAREST);
   [ex release];
   [ez release];
   [eo release];
   [exTemp release];
   [ezTemp release];
   [eoTemp release];
   [one release];
   [two release];
   [xq release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_z bound] + ![_x boundError] + ![_z boundError];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = sqrt(%@)>",_z, _x];
}
@end

