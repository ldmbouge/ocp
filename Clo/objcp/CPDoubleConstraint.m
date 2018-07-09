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
#import "ORConstraintI.h"
#include "rationalUtilities.h"

#define PERCENT 5.0

#if 0
#define traceQP(body) body
#else
#define traceQP(body)
#endif


void ulp_computation_d(ri* ulp, const double_interval f){
    ORRational tmp0, tmp1, tmp2;
    
    rational_init(&tmp0);
    rational_init(&tmp1);
    rational_init(&tmp2);
    
    if(f.inf == -INFINITY || f.sup == INFINITY){
        rational_set_d(&tmp0, DBL_MAX);
        rational_set_d(&tmp1, 2.0);
        rational_multiplication(&tmp2, &tmp1, &tmp0);
        rational_neg(&tmp1, &tmp2);
        ri_set_q(ulp, &tmp1, &tmp2);
    }else if(fabs(f.inf) == DBL_MAX || fabs(f.sup) == DBL_MAX){
        rational_set_d(&tmp0, nextafter(DBL_MAX, -INFINITY) - DBL_MAX);
        rational_set_d(&tmp1, 2.0);
        rational_division(&tmp2, &tmp0, &tmp1);
        rational_neg(&tmp1, &tmp2);
        ri_set_q(ulp, &tmp2, &tmp1);
    } else{
        ORDouble inf, sup;
        inf = minDbl(nextafter(f.inf, -INFINITY) - f.inf, nextafter(f.sup, -INFINITY) - f.sup);
        sup = maxDbl(nextafter(f.inf, +INFINITY) - f.inf, nextafter(f.sup, +INFINITY) - f.sup);
        
        rational_set_d(&tmp0, inf);
        rational_set_d(&tmp1, 2.0);
        rational_division(&tmp2, &tmp0, &tmp1);
        rational_set(&ulp->inf, &tmp2);
        rational_set_d(&tmp0, sup);
        rational_division(&tmp2, &tmp0, &tmp1);
        rational_set(&ulp->sup, &tmp2);
    }
    
    rational_clear(&tmp0);
    rational_clear(&tmp1);
    rational_clear(&tmp2);
}

int compute_eo_add_d(ri eo, const double_interval x, const double_interval y, const double_interval z){
    int changed = 0;
    
    /* First, let see if Sterbenz is applicable */
    if (((0.0 <= x.inf) && (y.sup <= 0.0) && (-y.inf/2.0 <= x.inf) && (x.sup <= -2.0*y.sup)) ||
        ((x.sup <= 0.0) && (0.0 <= y.inf) && (y.sup/2.0 <= -x.sup) && (-x.inf <= 2.0*y.inf))) {
        ORRational zero;
        rational_init(&zero);
        rational_set_d(&zero, 0.0);
        changed |= ri_proj_inter_infsup(&eo, &zero, &zero);
        rational_clear(&zero);
    } else if ((((double_cast)((z.inf))).parts.exponent <= 1) && (((double_cast)((z.sup))).parts.exponent <= 1)) {
        /* Hauser theorems:
         3.4.1: if Round(x + y) is denormalized, then Round(x + y) = x + y (provided we use denormalized numbers)
         see p 154. Also apply to subtraction (as x - y = x + (- y))
         3.4.1a: Let u be the least positive normalized float. If abs(x + y) < 2*u then Round(x + y) = x + y
         Hauser, J. R. 1996. Handling floating-point exceptions in numeric programs. ACM Transactions on Pro-
         gramming Languages and Systems 18, 2, 139–174 */
        ORRational zero;
        rational_init(&zero);
        rational_set_d(&zero, 0.0);
        changed |= ri_proj_inter_infsup(&eo, &zero, &zero);
        rational_clear(&zero);
    } else if((x.inf == x.sup) && (y.inf == y.sup)){
        ORDouble tmpf = x.inf + y.inf;
        ORRational tmpq, xq, yq;
        
        rational_init(&tmpq);
        rational_init(&xq);
        rational_init(&yq);
        
        rational_set_d(&xq, x.inf);
        rational_set_d(&yq, y.inf);
        rational_addition(&tmpq, &xq, &yq);
        rational_set_d(&yq, tmpf);
        rational_subtraction(&xq, &tmpq, &yq);
        
        changed = ri_proj_inter_infsup(&eo, &xq, &xq);
        
        rational_clear(&tmpq);
        rational_clear(&xq);
        rational_clear(&yq);
    } else {
        ri ulp_q;
        
        ri_init(&ulp_q);
        ulp_computation_d(&ulp_q, z);
        changed = ri_proj_inter(&eo, &ulp_q);
        ri_clear(&ulp_q);
    }
    
    return changed;
}

int compute_eo_sub_d(ri eo, const double_interval x, const double_interval y, const double_interval z){
    int changed = 0;
    
    /* First, let see if Sterbenz is applicable (requires gradual underflow (denormalized) or that x-y does not underflow */
    if (((x.inf >= 0.0) && (y.inf >= 0.0) && (y.sup/2.0 <= x.inf) && (x.sup <= 2.0*y.inf)) ||
        ((x.sup <= 0.0) && (y.sup <= 0.0) && (y.inf/2.0 >= x.sup) && (x.inf >= 2.0*y.sup))) {
        ORRational zero;
        rational_init(&zero);
        rational_set_d(&zero, 0.0);
        changed |= ri_proj_inter_infsup(&eo, &zero, &zero);
        rational_clear(&zero);
    } else if ((((double_cast)((z.inf))).parts.exponent <= 1) && (((double_cast)((z.sup))).parts.exponent <= 1)) {
        /* Hauser theorems:
         3.4.1: if Round(x + y) is denormalized, then Round(x + y) = x + y (provided we use denormalized numbers)
         see p 154. Also apply to subtraction (as x - y = x + (- y))
         3.4.1a: Let u be the least positive normalized float. If abs(x + y) < 2*u then Round(x + y) = x + y
         Hauser, J. R. 1996. Handling floating-point exceptions in numeric programs. ACM Transactions on Pro-
         gramming Languages and Systems 18, 2, 139–174 */
        ORRational zero;
        rational_init(&zero);
        rational_set_d(&zero, 0.0);
        changed |= ri_proj_inter_infsup(&eo, &zero, &zero);
        rational_clear(&zero);
    } else if((x.inf == x.sup) && (y.inf == y.sup)){
        ORDouble tmpf = x.inf - y.inf;
        ORRational tmpq, xq, yq;
        
        rational_init(&tmpq);
        rational_init(&xq);
        rational_init(&yq);
        
        rational_set_d(&xq, x.inf);
        rational_set_d(&yq, y.inf);
        rational_subtraction(&tmpq, &xq, &yq);
        rational_set_d(&yq, tmpf);
        rational_subtraction(&xq, &tmpq, &yq);
        
        changed = ri_proj_inter_infsup(&eo, &xq, &xq);
        
        rational_clear(&tmpq);
        rational_clear(&xq);
        rational_clear(&yq);
    } else {
        ri ulp_q;
        
        ri_init(&ulp_q);
        ulp_computation_d(&ulp_q, z);
        changed = ri_proj_inter(&eo, &ulp_q);
        ri_clear(&ulp_q);
    }
    
    return changed;
}


int compute_eo_mul_d(ri eo, const double_interval x, const double_interval y, const double_interval z){
    int changed = 0;
    
    /* Check if its a product by a power of 2 */
    if (((x.inf == x.sup) && (((double_cast)((x.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(x.inf) <= y.inf) && (y.sup <= DBL_MAX/fabs(x.inf))) ||
        ((y.inf == y.sup) && (((double_cast)((y.inf))).parts.mantissa == 0) && (-DBL_MAX/fabs(y.inf) <= x.inf) && (x.sup <= DBL_MAX/fabs(y.inf)))) {
        ORRational zero;
        rational_init(&zero);
        rational_set_d(&zero, 0.0);
        changed |= ri_proj_inter_infsup(&eo, &zero, &zero);
        rational_clear(&zero);
    } else if((x.inf == x.sup) && (y.inf == y.sup)){
        ORDouble tmpf = x.inf*y.inf;
        ORRational tmpq, xq, yq;
        
        rational_init(&tmpq);
        rational_init(&xq);
        rational_init(&yq);
        
        rational_set_d(&xq, x.inf);
        rational_set_d(&yq, y.inf);
        rational_multiplication(&tmpq, &xq, &yq);
        rational_set_d(&yq, tmpf);
        rational_subtraction(&xq, &tmpq, &yq);
        
        changed = ri_proj_inter_infsup(&eo, &xq, &xq);
        
        rational_clear(&tmpq);
        rational_clear(&xq);
        rational_clear(&yq);
    } else {
        ri ulp_q;
        
        ri_init(&ulp_q);
        ulp_computation_d(&ulp_q, z);
        changed = ri_proj_inter(&eo, &ulp_q);
        ri_clear(&ulp_q);
    }
    
    return changed;
}

int checkDivPower2(double x, double y) { // x/y
    double_cast z;
    z.f = x/y;
    return (z.parts.exponent >= 1);
}

int compute_eo_div_d(ri eo, const double_interval x, const double_interval y, const double_interval z){
    int changed = 0;
    
    /* Check if its a division by a power of 2 */
    if ((y.inf == y.sup) && (((double_cast)(y.inf)).parts.mantissa == 0) &&
        (((-DBL_MAX <= x.inf) && (x.sup < 0.0) && checkDivPower2(x.sup, y.inf)) || ((0.0 < x.inf) && (x.sup <= DBL_MAX) && checkDivPower2(x.inf, y.inf)))) {
        ORRational zero;
        rational_init(&zero);
        rational_set_d(&zero, 0.0);
        changed |= ri_proj_inter_infsup(&eo, &zero, &zero);
        rational_clear(&zero);
    } else if((x.inf == x.sup) && (y.inf == y.sup)){
        ORDouble tmpf = x.inf/y.inf;
        ORRational tmpq, xq, yq;
        
        rational_init(&tmpq);
        rational_init(&xq);
        rational_init(&yq);
        
        rational_set_d(&xq, x.inf);
        rational_set_d(&yq, y.inf);
        rational_division(&tmpq, &xq, &yq);
        rational_set_d(&yq, tmpf);
        rational_subtraction(&xq, &tmpq, &yq);
        
        changed = ri_proj_inter_infsup(&eo, &xq, &xq);
        
        rational_clear(&tmpq);
        rational_clear(&xq);
        rational_clear(&yq);
    } else {
        ri ulp_q;
        
        ri_init(&ulp_q);
        ulp_computation_d(&ulp_q, z);
        changed = ri_proj_inter(&eo, &ulp_q);
        ri_clear(&ulp_q);
    }
    
    return changed;
}


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
        //hzi : if x in [-0.0,0.0]f : x is bound, but value return x.min
        //the domain of y must stay  [-0.0,0.0]f and not just -0.0
        if(is_eq([_x min],-0.0) && is_eq([_x max],+0.0))
            [_y updateInterval:[_x min] and:[_x max]];
        else
            [_y bind:[_x value]];
        assignTRInt(&_active, NO, _trail);
        return;
    }else if([_y bound]){
        if(is_eq([_y min],-0.0) && is_eq([_y max],+0.0))
            [_x updateInterval:[_y min] and:[_y max]];
        else
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
    //hzi : equality constraint is different from assignment constraint for 0.0
    //in case when check equality -0.0 == 0.0
    //in case of assignement x = -0.0 != from x = 0.0
    if(is_eq(_c,0.) || is_eq(_c,-0.))
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
    double_interval _xi;
    double_interval _yi;
    ri _exi;
    ri _eyi;
}
-(id) init:(CPDoubleVarI*)x set:(CPDoubleVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _x = x;
    _y = y;
    _xi = makeDoubleInterval(x.min, x.max);
    _yi = makeDoubleInterval(y.min, y.max);
    ri_init(&_exi);
    ri_init(&_eyi);
    makeRationalIntervalD(_exi, x.minErr, x.maxErr);
    makeRationalIntervalD(_eyi, y.minErr, y.maxErr);
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
    updateDoubleInterval(&_xi,_x);
    updateDoubleInterval(&_yi,_y);
    updateRationalIntervalD(_exi,_x);
    updateRationalIntervalD(_eyi,_y);
    intersectionIntervalD inter;
    intersectionIntervalErrorD interError;
    ri_init(&interError.interval);
    ri_init(&interError.result);
    
    if (isDisjointWithD(_x,_y)) {
        failNow();
    } else if (isDisjointWithDR(_x,_y)) {
        failNow();
    } else {
        double_interval xTmp = makeDoubleInterval(_xi.inf, _xi.sup);
        fpi_set(_precision, _rounding, &xTmp, &_yi);
        
        inter = intersectionD(_xi, xTmp, 0.0);
        intersectionErrorD(&interError, _exi, _eyi);
        
        if(inter.changed)
            [_x updateInterval:inter.result.inf and:inter.result.sup];
        if(interError.changed)
            [_x updateIntervalError:interError.result.inf and:interError.result.sup];
        if ((_yi.inf != inter.result.inf) || (_yi.sup != inter.result.sup))
            [_y updateInterval:inter.result.inf and:inter.result.sup];
        if ((rational_cmp(&_eyi.inf, &interError.result.inf) != 0) || (rational_cmp(&_eyi.sup, &interError.result.sup) != 0))
            [_y updateIntervalError:interError.result.inf and:interError.result.sup];
    }
   ri_clear(&interError.interval);
   ri_clear(&interError.result);
}
- (void)dealloc {
    freeRationalIntervalD(_exi);
    freeRationalIntervalD(_eyi);
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
    ORRational _zero;
    rational_init(&_zero);
    rational_set_d(&_zero, 0.0f);
    [_x bindError:_zero];
    rational_clear(&_zero);
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
    [_x whenBindPropagate:self];
    [_y whenBindPropagate:self];
}
-(void) propagate
{
    if ([_x bound]) {
        if([_y bound]){
            if (is_eq([_x min],[_y min]))
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
    [_x whenBindPropagate:self];
    [_x whenChangeBoundsPropagate:self];
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
    [_y whenChangeBoundsPropagate:self];
    [_x whenChangeBoundsPropagate:self];
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
    [_y whenChangeBoundsPropagate:self];
    [_x whenChangeBoundsPropagate:self];
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
    [_y whenChangeBoundsPropagate:self];
    [_x whenChangeBoundsPropagate:self];
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
    [_y whenChangeBoundsPropagate:self];
    [_x whenChangeBoundsPropagate:self];
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
    eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-MAXDBL upF:MAXDBL];
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
    ri exi, eyi, ezi, eoi, tmp0, tmp1;
    
    ri_init(&exi);
    ri_init(&eyi);
    ri_init(&ezi);
    ri_init(&eoi);
    ri_init(&tmp0);
    ri_init(&tmp1);
    
    z = makeDoubleInterval([_z min],[_z max]);
    x = makeDoubleInterval([_x min],[_x max]);
    y = makeDoubleInterval([_y min],[_y max]);
    
   ORRational min;
   ORRational max;
   min = [_x minErr];
   max = [_x maxErr];
   ri_set_q(&exi, &min, &max);
   min = [_y minErr];
   max = [_y maxErr];
   ri_set_q(&eyi, &min, &max);
   min = [_z minErr];
   max = [_z maxErr];
   ri_set_q(&ezi, &min, &max);
   min = [eo min];
   max = [eo max];
   ri_set_q(&eoi, &min, &max);
    
    /*traceQP(printf("================== ADD BEGIN d\nx    = [% 24.24e, % 24.24e], ex   = [% 24.24e, % 24.24e]\ny    = [% 24.24e, % 24.24e], ey   = [% 24.24e, % 24.24e]\nz    = [% 24.24e, % 24.24e], ez   = [% 24.24e, % 24.24e]\neo   = [% 24.24e, % 20.20e]\n",
                   x.inf, x.sup, mpq_get_d(mpri_lepref(exi)), mpq_get_d(mpri_repref(exi)),
                   y.inf, y.sup, mpq_get_d(mpri_lepref(eyi)), mpq_get_d(mpri_repref(eyi)),
                   z.inf, z.sup, mpq_get_d(mpri_lepref(ezi)), mpq_get_d(mpri_repref(ezi)),
                   mpq_get_d(mpri_lepref(eoi)), mpq_get_d(mpri_repref(eoi))));*/
    do {
        changed = false;
        zTemp = z;
        fpi_addd(_precision, _rounding, &zTemp, &x, &y);
        inter = intersectionD(z, zTemp,_percent);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
        fpi_add_invsub_bounds(_precision, _rounding, &xTemp, &yTemp, &z);
        inter = intersectionD(x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        inter = intersectionD(y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_addxd_inv(_precision, _rounding, &xTemp, &z, &y);
        inter = intersectionD(x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_addyd_inv(_precision, _rounding, &yTemp, &z, &x);
        inter = intersectionD(y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        
        /* ERROR PROPAG */
        
        /*if ((fabs(x.inf) == +INFINITY) || (fabs(x.sup) == +INFINITY) ||
            (fabs(y.inf) == +INFINITY) || (fabs(y.sup) == +INFINITY) ||
            (fabs(z.inf) == +INFINITY) || (fabs(z.sup) == +INFINITY)) {
            printf("ADD: Infinites in operands: does not handle such cases yet\n");
            exit(-1);
        }*/
        
        changed |= compute_eo_add_d(eoi, x, y, z);
        
        // ============================== ez
        // ex + ey + eo
        ri_add(&tmp0, &exi, &eyi);
        ri_add(&tmp1, &tmp0, &eoi);
        
        changed |= ri_proj_inter(&ezi, &tmp1);
        
        // ============================== eo
        // ez - (ex + ey)
        ri_sub(&tmp1, &ezi, &tmp0);
        
        changed |= ri_proj_inter(&eoi, &tmp1);
        
        // ============================== ex
        // ez - ey - eo
        ri_sub(&tmp0, &ezi, &eoi);
        ri_sub(&tmp1, &tmp0, &eyi);
        
        changed |= ri_proj_inter(&exi, &tmp1);
        
        // ============================== ey
        // ez - ex - eo
        ri_sub(&tmp1, &tmp0, &exi);
        
        changed |= ri_proj_inter(&eyi, &tmp1);
        
        /* END ERROR PROPAG */
        
        gchanged |= changed;
    } while(changed);
    
    /*traceQP(printf("================== ADD END d\nx    = [% 24.24e, % 24.24e], ex   = [% 24.24e, % 24.24e]\ny    = [% 24.24e, % 24.24e], ey   = [% 24.24e, % 24.24e]\nz    = [% 24.24e, % 24.24e], ez   = [% 24.24e, % 24.24e]\neo   = [% 24.24e, % 20.20e]\n",
                   x.inf, x.sup, rational_get_d((exi->inf)), rational_get_d((exi->sup)),
                   y.inf, y.sup, rational_get_d((eyi->inf)), rational_get_d((eyi->sup)),
                   z.inf, z.sup, rational_get_d((ezi->inf)), rational_get_d((ezi->sup)),
                   rational_get_d((eoi->inf)), rational_get_d((eoi->inf))));*/
    
    if(gchanged){
        // Cause no propagation on eo is insured
        [eo updateMin:(eoi.inf) for:NULL];
        [eo updateMax:(eoi.sup) for:NULL];
        
        [_x updateInterval:x.inf and:x.sup];
        [_y updateInterval:y.inf and:y.sup];
        [_z updateInterval:z.inf and:z.sup];
        [_x updateIntervalError:(exi.inf) and:(exi.sup)];
        [_y updateIntervalError:(eyi.inf) and:(eyi.sup)];
        [_z updateIntervalError:(ezi.inf) and:(ezi.sup)];
        if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
            assignTRInt(&_active, NO, _trail);
    }
    
    fesetround(FE_TONEAREST);
    
    ri_clear(&exi);
    ri_clear(&eyi);
    ri_clear(&ezi);
    ri_clear(&eoi);
    ri_clear(&tmp0);
    ri_clear(&tmp1);
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
-(id<CPDoubleVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x
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
    eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-MAXDBL upF:MAXDBL];
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
    ri exi, eyi, ezi, eoi, tmp0, tmp1;
    
    ri_init(&exi);
    ri_init(&eyi);
    ri_init(&ezi);
    ri_init(&eoi);
    ri_init(&tmp0);
    ri_init(&tmp1);
    
    z = makeDoubleInterval([_z min],[_z max]);
    x = makeDoubleInterval([_x min],[_x max]);
    y = makeDoubleInterval([_y min],[_y max]);
    
   ORRational min;
   ORRational max;
   min = [_x minErr];
   max = [_x maxErr];
   ri_set_q(&exi, &min, &max);
   min = [_y minErr];
   max = [_y maxErr];
   ri_set_q(&eyi, &min, &max);
   min = [_z minErr];
   max = [_z maxErr];
   ri_set_q(&ezi, &min, &max);
   min = [eo min];
   max = [eo max];
   ri_set_q(&eoi, &min, &max);
    
    /*traceQP(printf("================== SUB BEGIN d\nx    = [% 24.24e, % 24.24e], ex   = [% 24.24e, % 24.24e]\ny    = [% 24.24e, % 24.24e], ey   = [% 24.24e, % 24.24e]\nz    = [% 24.24e, % 24.24e], ez   = [% 24.24e, % 24.24e]\neo   = [% 24.24e, % 20.20e]\n",
                   x.inf, x.sup, mpq_get_d(mpri_lepref(exi)), mpq_get_d(mpri_repref(exi)),
                   y.inf, y.sup, mpq_get_d(mpri_lepref(eyi)), mpq_get_d(mpri_repref(eyi)),
                   z.inf, z.sup, mpq_get_d(mpri_lepref(ezi)), mpq_get_d(mpri_repref(ezi)),
                   mpq_get_d(mpri_lepref(eoi)), mpq_get_d(mpri_repref(eoi))));*/
    do {
        changed = false;
        zTemp = z;
        fpi_subd(_precision, _rounding, &zTemp, &x, &y);
        inter = intersectionD(z, zTemp,_percent);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
        fpi_sub_invsub_bounds(_precision, _rounding, &xTemp, &yTemp, &z);
        inter = intersectionD(x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        inter = intersectionD(y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_subxd_inv(_precision, _rounding, &xTemp, &z, &y);
        inter = intersectionD(x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_subyd_inv(_precision, _rounding, &yTemp, &z, &x);
        inter = intersectionD(y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        
        /* ERROR PROPAG */
        
        /*if ((fabs(x.inf) == +INFINITY) || (fabs(x.sup) == +INFINITY) ||
            (fabs(y.inf) == +INFINITY) || (fabs(y.sup) == +INFINITY) ||
            (fabs(z.inf) == +INFINITY) || (fabs(z.sup) == +INFINITY)) {
            printf("SUB: Infinites in operands: does not handle such cases yet\n");
            exit(-1);
        }*/
        
        changed |= compute_eo_sub_d(eoi, x, y, z);
        
        // ============================== ez
        // ex - ey + eo
        ri_sub(&tmp0, &exi, &eyi);
        ri_add(&tmp1, &tmp0, &eoi);
        
        changed |= ri_proj_inter(&ezi, &tmp1);
        
        // ============================== eo
        // ez - (ex - ey)
        ri_sub(&tmp1, &ezi, &tmp0);
        
        changed |= ri_proj_inter(&eoi, &tmp1);
        
        // ============================== ex
        // ez + ey - eo
        ri_add(&tmp0, &ezi, &eyi);
        ri_sub(&tmp1, &tmp0, &eoi);
        
        changed |= ri_proj_inter(&exi, &tmp1);
        
        // ============================== ey
        // ex - ez + eo
        ri_sub(&tmp0, &exi, &ezi);
        ri_add(&tmp1, &tmp0, &eoi);
        
        changed |= ri_proj_inter(&eyi, &tmp1);
        
        /* END ERROR PROPAG */
        
        gchanged |= changed;
    } while(changed);
    
    /*traceQP(printf("================== SUB END d\nx    = [% 24.24e, % 24.24e], ex   = [% 24.24e, % 24.24e]\ny    = [% 24.24e, % 24.24e], ey   = [% 24.24e, % 24.24e]\nz    = [% 24.24e, % 24.24e], ez   = [% 24.24e, % 24.24e]\neo   = [% 24.24e, % 20.20e]\n",
                   x.inf, x.sup, mpq_get_d(mpri_lepref(exi)), mpq_get_d(mpri_repref(exi)),
                   y.inf, y.sup, mpq_get_d(mpri_lepref(eyi)), mpq_get_d(mpri_repref(eyi)),
                   z.inf, z.sup, mpq_get_d(mpri_lepref(ezi)), mpq_get_d(mpri_repref(ezi)),
                   mpq_get_d(mpri_lepref(eoi)), mpq_get_d(mpri_repref(eoi))));*/
    
    if(gchanged){
        // Cause no propagation on eo is insured
        [eo updateMin:(eoi.inf) for:NULL];
        [eo updateMax:(eoi.sup) for:NULL];
        
        [_x updateInterval:x.inf and:x.sup];
        [_y updateInterval:y.inf and:y.sup];
        [_z updateInterval:z.inf and:z.sup];
        [_x updateIntervalError:(exi.inf) and:(exi.sup)];
        [_y updateIntervalError:(eyi.inf) and:(eyi.sup)];
        [_z updateIntervalError:(ezi.inf) and:(ezi.sup)];
        if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
            assignTRInt(&_active, NO, _trail);
    }
    
    fesetround(FE_TONEAREST);
    
    ri_clear(&exi);
    ri_clear(&eyi);
    ri_clear(&ezi);
    ri_clear(&eoi);
    ri_clear(&tmp0);
    ri_clear(&tmp1);
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
-(id<CPDoubleVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x
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

@implementation CPDoubleTernaryMult {
    //    rational_interval eo;
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
    eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-MAXDBL upF:MAXDBL];
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
    ri xi, yi, zi, exi, eyi, ezi, eoi, tmp0, tmp1, tmp2, tmp3;
    
    ri_init(&xi);
    ri_init(&yi);
    ri_init(&zi);
    ri_init(&exi);
    ri_init(&eyi);
    ri_init(&ezi);
    ri_init(&eoi);
    ri_init(&tmp0);
    ri_init(&tmp1);
    ri_init(&tmp2);
    ri_init(&tmp3);
    
    z = makeDoubleInterval([_z min],[_z max]);
    x = makeDoubleInterval([_x min],[_x max]);
    y = makeDoubleInterval([_y min],[_y max]);
    
   ORRational min;
   ORRational max;
   min = [_x minErr];
   max = [_x maxErr];
   ri_set_q(&exi, &min, &max);
   min = [_y minErr];
   max = [_y maxErr];
   ri_set_q(&eyi, &min, &max);
   min = [_z minErr];
   max = [_z maxErr];
   ri_set_q(&ezi, &min, &max);
   min = [eo min];
   max = [eo max];
   ri_set_q(&eoi, &min, &max);
    
    /*traceQP(printf("================== MUL BEGIN d\nx    = [% 24.24e, % 24.24e], ex   = [% 24.24e, % 24.24e]\ny    = [% 24.24e, % 24.24e], ey   = [% 24.24e, % 24.24e]\nz    = [% 24.24e, % 24.24e], ez   = [% 24.24e, % 24.24e]\neo   = [% 24.24e, % 20.20e]\n",
                   x.inf, x.sup, rational_get_d((exi->inf)), rational_get_d((exi->sup)),
                   y.inf, y.sup, rational_get_d((eyi->inf)), rational_get_d((eyi->sup)),
                   z.inf, z.sup, rational_get_d((ezi->inf)), rational_get_d((ezi->sup)),
                   rational_get_d((eoi->inf)), rational_get_d((eoi->sup))));*/
    
    do {
        changed = false;
        zTemp = z;
        fpi_multd(_precision, _rounding, &zTemp, &x, &y);
        inter = intersectionD(z, zTemp,_percent);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_multxd_inv(_precision, _rounding, &xTemp, &z, &y);
        inter = intersectionD(x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_multyd_inv(_precision, _rounding, &yTemp, &z, &x);
        inter = intersectionD(y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        
        /* ERROR PROPAG */
        
        /*if ((fabs(x.inf) == +INFINITY) || (fabs(x.sup) == +INFINITY) ||
            (fabs(y.inf) == +INFINITY) || (fabs(y.sup) == +INFINITY) ||
            (fabs(z.inf) == +INFINITY) || (fabs(z.sup) == +INFINITY)) {
            printf("MUL: Infinites in operands: does not handle such cases yet\n");
            exit(-1);
        }*/
        
        ri_set_d(&xi, x.inf, x.sup);
        ri_set_d(&yi, y.inf, y.sup);
        ri_set_d(&zi, z.inf, z.sup);
        
        changed |= compute_eo_mul_d(eoi, x, y, z);
        
        // ============================== ez
        // x*ey + y*ex + ex*ey + eo
        ri_mul(&tmp0, &xi, &eyi);
        ri_mul(&tmp1, &yi, &exi);
        ri_add(&tmp2, &tmp0, &tmp1);
        ri_mul(&tmp0, &exi, &eyi);
        ri_add(&tmp1, &tmp2, &tmp0);
        ri_add(&tmp0, &tmp1, &eoi);
        
        changed |= ri_proj_inter(&ezi, &tmp0);
        
        // ============================== eo
        // ez - (x*ey + y*ex + ex*ey)
        ri_sub(&tmp0, &ezi, &tmp1);
        
        changed |= ri_proj_inter(&eoi, &tmp0);
        
        // ============================== ex
        // (ez - x*ey - eo)/(y + ey)
        ri_sub(&tmp3, &ezi, &eoi);
        ri_mul(&tmp1, &xi, &eyi);
        ri_sub(&tmp2, &tmp3, &tmp1);
        ri_add(&tmp1, &yi, &eyi);
        if ((rational_cmp_ui(&(tmp1.inf), 0, 1) > 0) || (rational_cmp_ui(&(tmp1.sup), 0, 1) < 0)) {
            // We do the division, and thus the projection, iff (y + ey) does not contain 0
            ri_div(&tmp0, &tmp2, &tmp1);
            
            changed |= ri_proj_inter(&exi, &tmp0);
        } else
            printf("MUL: WARNING: cannot compute ex projections due to division by zero\n");
        
        // ============================== ey
        // (ez - y*ex - eo)/(x + ex)
        ri_mul(&tmp1, &yi, &exi);
        ri_sub(&tmp2, &tmp3, &tmp1);
        ri_add(&tmp1, &xi, &exi);
        if ((rational_cmp_ui(&(tmp1.inf), 0, 1) > 0) || (rational_cmp_ui(&(tmp1.sup), 0, 1) < 0)) {
            // We do the division, and thus the projection, iff (y + ey) does not contain 0
            ri_div(&tmp0, &tmp2, &tmp1);
            
            changed |= ri_proj_inter(&eyi, &tmp0);
        } else
            printf("MUL: WARNING: cannot compute ey projections due to division by zero\n");
        
        /* END ERROR PROPAG */
        
        gchanged |= changed;
    } while(changed);
    
    traceQP(printf("================== MUL END d\nx    = [% 24.24e, % 24.24e], ex   = [% 24.24e, % 24.24e]\ny    = [% 24.24e, % 24.24e], ey   = [% 24.24e, % 24.24e]\nz    = [% 24.24e, % 24.24e], ez   = [% 24.24e, % 24.24e]\neo   = [% 24.24e, % 20.20e]\n",
                   x.inf, x.sup, rational_get_d((exi->inf)), rational_get_d((exi->sup)),
                   y.inf, y.sup, rational_get_d((eyi->inf)), rational_get_d((eyi->sup)),
                   z.inf, z.sup, rational_get_d((ezi->inf)), rational_get_d((ezi->sup)),
                   rational_get_d((eoi->inf)), rational_get_d((eoi->sup))));
    
    if(gchanged){
        // Cause no propagation on eo is insured
        [eo updateMin:(eoi.inf) for:NULL];
        [eo updateMax:(eoi.sup) for:NULL];
        
        [_x updateInterval:x.inf and:x.sup];
        [_y updateInterval:y.inf and:y.sup];
        [_z updateInterval:z.inf and:z.sup];
        [_x updateIntervalError:(exi.inf) and:(exi.sup)];
        [_y updateIntervalError:(eyi.inf) and:(eyi.sup)];
        [_z updateIntervalError:(ezi.inf) and:(ezi.sup)];
        if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
            assignTRInt(&_active, NO, _trail);
    }
    
    fesetround(FE_TONEAREST);
    
    ri_clear(&xi);
    ri_clear(&yi);
    ri_clear(&zi);
    ri_clear(&exi);
    ri_clear(&eyi);
    ri_clear(&ezi);
    ri_clear(&eoi);
    ri_clear(&tmp0);
    ri_clear(&tmp1);
    ri_clear(&tmp2);
    ri_clear(&tmp3);
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
    //rational_interval eo;
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
    eo = [[CPRationalDom alloc] initCPRationalDom:[[z engine] trail] lowF:-MAXDBL upF:MAXDBL];
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
    ri xi, yi, zi, exi, eyi, ezi, eoi, tmp0, tmp1, tmp2, tmp3;
    
    ri_init(&xi);
    ri_init(&yi);
    ri_init(&zi);
    ri_init(&exi);
    ri_init(&eyi);
    ri_init(&ezi);
    ri_init(&eoi);
    ri_init(&tmp0);
    ri_init(&tmp1);
    ri_init(&tmp2);
    ri_init(&tmp3);
    
    z = makeDoubleInterval([_z min],[_z max]);
    x = makeDoubleInterval([_x min],[_x max]);
    y = makeDoubleInterval([_y min],[_y max]);
    
   ORRational min;
   ORRational max;
   min = [_x minErr];
   max = [_x maxErr];
   ri_set_q(&exi, &min, &max);
   min = [_y minErr];
   max = [_y maxErr];
   ri_set_q(&eyi, &min, &max);
   min = [_z minErr];
   max = [_z maxErr];
   ri_set_q(&ezi, &min, &max);
   min = [eo min];
   max = [eo max];
   ri_set_q(&eoi, &min, &max);
    
    /*traceQP(printf("================== DIV BEGIN d\nx    = [% 24.24e, % 24.24e], ex   = [% 24.24e, % 24.24e]\ny    = [% 24.24e, % 24.24e], ey   = [% 24.24e, % 24.24e]\nz    = [% 24.24e, % 24.24e], ez   = [% 24.24e, % 24.24e]\neo   = [% 24.24e, % 20.20e]\n",
                   x.inf, x.sup, mpq_get_d(mpri_lepref(exi)), mpq_get_d(mpri_repref(exi)),
                   y.inf, y.sup, mpq_get_d(mpri_lepref(eyi)), mpq_get_d(mpri_repref(eyi)),
                   z.inf, z.sup, mpq_get_d(mpri_lepref(ezi)), mpq_get_d(mpri_repref(ezi)),
                   mpq_get_d(mpri_lepref(eoi)), mpq_get_d(mpri_repref(eoi))));*/
    
    do {
        changed = false;
        zTemp = z;
        fpi_divd(_precision, _rounding, &zTemp, &x, &y);
        inter = intersectionD(z, zTemp,_percent);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_divxd_inv(_precision, _rounding, &xTemp, &z, &y);
        inter = intersectionD(x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_divyd_inv(_precision, _rounding, &yTemp, &z, &x);
        inter = intersectionD(y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        
        /* ERROR PROPAG */
        
        /*if ((fabs(x.inf) == +INFINITY) || (fabs(x.sup) == +INFINITY) ||
            (fabs(y.inf) == +INFINITY) || (fabs(y.sup) == +INFINITY) ||
            (fabs(z.inf) == +INFINITY) || (fabs(z.sup) == +INFINITY)) {
            printf("DIV: Infinites in operands: does not handle such cases yet\n");
            exit(-1);
        }*/
        
        /*if ((y.inf <= 0.0) && (0.0 <= y.sup)) {
            printf("DIV: division by zero: does not handle such cases yet\n");
            exit(-1);
        }*/
        
        ri_set_d(&xi, x.inf, x.sup);
        ri_set_d(&yi, y.inf, y.sup);
        ri_set_d(&zi, z.inf, z.sup);
        
        changed |= compute_eo_div_d(eoi, x, y, z);
        
        // ============================== ez
        // y*(y + ey)
        ri_add(&tmp0, &yi, &eyi);
        ri_mul(&tmp1, &yi, &tmp0);
        
        if ((rational_cmp_ui(&(tmp1.inf), 0, 1) > 0) || (rational_cmp_ui(&(tmp1.sup), 0, 1) < 0)) {
            // y*ex - x*ey
            ri_mul(&tmp0, &yi, &exi);
            ri_mul(&tmp2, &xi, &eyi);
            ri_sub(&tmp3, &tmp0, &tmp2);
            
            // (y*ex - x*ey)/(y*(y + ey))
            ri_div(&tmp0, &tmp3, &tmp1);
            
            // (y*ex - x*ey)/(y*(y + ey)) + eo
            ri_add(&tmp1, &tmp0, &eoi);
            
            changed |= ri_proj_inter(&ezi, &tmp1);
            
            // ============================== eo
            ri_sub(&tmp1, &ezi, &tmp0);
            
            changed |= ri_proj_inter(&eoi, &tmp1);
        } else
            printf("DIV: WARNING: cannot compute ez and eo projections due to division by zero\n");
        
        // ============================== ex
        // (ez - eo)*(y + ey)
        ri_sub(&tmp0, &ezi, &eoi);
        ri_add(&tmp1, &yi, &eyi);
        ri_mul(&tmp2, &tmp0, &tmp1);
        
        // (x*ey)/y
        ri_mul(&tmp0, &xi, &eyi);
        ri_div(&tmp1, &tmp0, &yi);
        
        // (ez - eo)*(y + ey) + (x*ey)/y
        ri_add(&tmp0, &tmp2, &tmp1);
        
        changed |= ri_proj_inter(&exi, &tmp0);
        
        // ============================== ey
        // ex - ez*y + eo*y = (eo - ez)*y + ex
        ri_sub(&tmp0, &eoi, &ezi);
        ri_mul(&tmp1, &yi, &tmp0);
        ri_add(&tmp0, &tmp1, &exi);
        
        // ez - eo + (x/y)
        ri_div(&tmp1, &xi, &yi);
        ri_add(&tmp2, &tmp1, &ezi);
        ri_sub(&tmp1, &tmp2, &eoi);
        
        if ((rational_cmp_ui(&(tmp1.inf), 0, 1) > 0) || (rational_cmp_ui(&(tmp1.sup), 0, 1) < 0)) {
            // (ex - ez*y + eo*y)/(ez - eo + (x/y))
            ri_div(&tmp2, &tmp0, &tmp1);
            
            changed |= ri_proj_inter(&eyi, &tmp2);
        } else
            printf("DIV: WARNING: cannot compute ey projection due to division by zero\n");
        
        /* END ERROR PROPAG */
        
        gchanged |= changed;
    } while(changed);
    
    /*traceQP(printf("================== DIV END d\nx    = [% 24.24e, % 24.24e], ex   = [% 24.24e, % 24.24e]\ny    = [% 24.24e, % 24.24e], ey   = [% 24.24e, % 24.24e]\nz    = [% 24.24e, % 24.24e], ez   = [% 24.24e, % 24.24e]\neo   = [% 24.24e, % 20.20e]\n",
                   x.inf, x.sup, rational_get_d((exi->inf)), rational_get_d((exi->sup)),
                   y.inf, y.sup, rational_get_d((eyi->inf)), rational_get_d((eyi->sup)),
                   z.inf, z.sup, rational_get_d((ezi->inf)),  rational_get_d((ezi->sup)),
                   rational_get_d((eoi->inf)), rational_get_d((eoi->sup))));*/
    
    if(gchanged){
        // Cause no propagation on eo is insured
        [eo updateMin:(eoi.inf) for:NULL];
        [eo updateMax:(eoi.sup) for:NULL];
        
        [_x updateInterval:x.inf and:x.sup];
        [_y updateInterval:y.inf and:y.sup];
        [_z updateInterval:z.inf and:z.sup];
        [_x updateIntervalError:(exi.inf) and:(exi.sup)];
        [_y updateIntervalError:(eyi.inf) and:(eyi.sup)];
        [_z updateIntervalError:(ezi.inf) and:(ezi.sup)];
        if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
            assignTRInt(&_active, NO, _trail);
        
        ri_clear(&xi);
        ri_clear(&yi);
        ri_clear(&zi);
        ri_clear(&exi);
        ri_clear(&eyi);
        ri_clear(&ezi);
        ri_clear(&eoi);
        ri_clear(&tmp0);
        ri_clear(&tmp1);
        ri_clear(&tmp2);
        ri_clear(&tmp3);
    }
    
    fesetround(FE_TONEAREST);
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
    if (bound(_b)) {
        if (minDom(_b)) {
            [[_b engine] addInternal: [CPFactory doubleNEqual:_x to:_y]];         // Rewrite as x==y  (addInternal can throw)
            assignTRInt(&_active, NO, _trail);
            return ;
        } else {
            [[_b engine] addInternal: [CPFactory doubleEqual:_x to:_y]];     // Rewrite as x==y  (addInternal can throw)
            assignTRInt(&_active, NO, _trail);
            return ;
        }
    }
    else if ([_x bound] && [_y bound]) {       //  b <=> c == d =>  b <- c==d
        [_b bind:[_x min] != [_y min]];
        assignTRInt(&_active, NO, _trail);
        return;
    }else if ([_x bound]) {
        [[_b engine] addInternal: [CPFactory doubleReify:_b with:_y neqi:[_x min]]];
        return ;
    }
    else if ([_y bound]) {
        [[_b engine] addInternal: [CPFactory doubleReify:_b with:_x neqi:[_y min]]];
        return ;
    } else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = YES
        if ([_x max] < [_y min] || [_y max] < [_x min])
            [_b bind:YES];
        else {   // nobody bound and domains of (x,y) overlap
            [_b whenBindPropagate:self];
            [_x whenChangeBoundsPropagate:self];
            [_y whenChangeBoundsPropagate:self];
        }
    }
}

-(void)propagate
{
    if (minDom(_b)) {            // b is TRUE
        if ([_x bound]){            // TRUE <=> (y != c)
            [[_b engine] addInternal: [CPFactory doubleNEqualc:_y to:[_x min]]];         // Rewrite as x==y  (addInternal can throw)
            assignTRInt(&_active, NO, _trail);
            return;
        }else  if ([_y bound]) {     // TRUE <=> (x != c)
            [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:[_y min]]];         // Rewrite as x==y  (addInternal can throw)
            assignTRInt(&_active, NO, _trail);
            return;
        }
    }
    else if (maxDom(_b)==0) {     // b is FALSE
        if ([_x bound]){
            if(is_eq([_x min],-0.0) && is_eq([_x max],+0.0))
                [_y updateInterval:[_x min] and:[_x max]];
            else
                [_y bind:[_x min]];
            assignTRInt(&_active, NO, _trail);
            return;
        } else if ([_y bound]){
            if(is_eq([_y min],-0.0) && is_eq([_y max],+0.0))
                [_x updateInterval:[_y min] and:[_y max]];
            else
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
    if (bound(_b)) {
        if (minDom(_b)) {
            [[_b engine] addInternal: [CPFactory doubleEqual:_x to:_y]]; // Rewrite as x==y  (addInternal can throw)
            return;
        } else {
            [[_b engine] addInternal: [CPFactory doubleNEqual:_x to:_y]];     // Rewrite as x!=y  (addInternal can throw)
            return;
        }
    }
    else if ([_x bound] && [_y bound])        //  b <=> c == d =>  b <- c==d
        [_b bind:[_x min] == [_y min]];
    else if ([_x bound]) {
        [[_b engine] add: [CPFactory doubleReify:_b with:_y eqi:[_x min]]];
        assignTRInt(&_active, 0, _trail);
        return;
    }
    else if ([_y bound]) {
        [[_b engine] add: [CPFactory doubleReify:_b with:_x eqi:[_y min]]];
        assignTRInt(&_active, 0, _trail);
        return;
    } else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = NO
        if ([_x max] < [_y min] || [_y max] < [_x min])
            [_b bind:NO];
        else {   // nobody bound and domains of (x,y) overlap
            [_b whenBindPropagate:self];
            [_x whenChangeBoundsPropagate:self];
            [_y whenChangeBoundsPropagate:self];
        }
    }
}

-(void)propagate
{
    if (minDom(_b)) {            // b is TRUE
        if ([_x bound]) {           // TRUE <=> (y == c)
            assignTRInt(&_active, 0, _trail);
            if(is_eq([_x min],-0.0) && is_eq([_x max],+0.0))
                [_y updateInterval:[_x min] and:[_x max]];
            else
                [_y bind:[_x min]];
        }else  if ([_y bound]) {     // TRUE <=> (x == c)
            assignTRInt(&_active, 0, _trail);
            if(is_eq([_y min],-0.0) && is_eq([_y max],+0.0))
                [_x updateInterval:[_y min] and:[_y max]];
            else
                [_x bind:[_y min]];
        } else {                    // TRUE <=> (x == y)
            [_x updateInterval:[_y min] and:[_y max]];
            [_y updateInterval:[_x min] and:[_x max]];
        }
    }
    else if (maxDom(_b)==0) {     // b is FALSE
        if ([_y bound])
            [[_b engine] addInternal: [CPFactory doubleNEqualc:_y to:[_x min]]]; // Rewrite as min(x)!=y  (addInternal can throw)
        else if ([_y bound])
            [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:[_y min]]]; // Rewrite as min(y)!=x  (addInternal can throw)
    }
    else {                        // b is unknown
        if ([_x bound] && [_y bound])
            [_b bind: [_x min] == [_y min]];
        else if ([_x max] < [_y min] || [_y max] < [_x min])
            [_b bind:NO];
    }
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
    if (bound(_b)) {
        if (minDom(_b)) {  // YES <=>  x > y
            [_y updateMax:fp_previous_double([_x max])];
            [_x updateMin:fp_next_double([_y min])];
        } else {            // NO <=> x <= y   ==>  YES <=> x < y
            if ([_x bound]) { // c <= y
                [_y updateMin:[_x min]];
            } else {         // x <= y
                [_y updateMin:[_x min]];
                [_x updateMax:[_y max]];
            }
        }
        if (![_x bound])
            [_x whenChangeBoundsPropagate:self];
        if (![_y bound])
            [_y whenChangeBoundsPropagate:self];
    } else {
        if ([_y max] < [_x min])
            [_b bind:YES];
        else if ([_x max] <= [_y min])
            [_b bind:NO];
        else {
            [_x whenChangeBoundsPropagate:self];
            [_y whenChangeBoundsPropagate:self];
            [_b whenBindPropagate:self];
        }
    }
}
-(void)propagate
{
    if (bound(_b)) {
        if (minDom(_b)) {
            [_y updateMax:fp_previous_double([_x max])];
            [_x updateMin:fp_next_double([_y min])];
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
    if (bound(_b)) {
        if (minDom(_b)) {  // YES <=>  x >= y
            [_y updateMax:[_x max]];
            [_x updateMin:[_y min]];
        } else {            // NO <=> x <= y   ==>  YES <=> x < y
            if ([_x bound]) { // c < y
                [_y updateMax:fp_next_double([_x min])];
            } else {         // x < y
                [_y updateMax:fp_next_double([_x max])];
                [_x updateMin:fp_previous_double([_y min])];
            }
        }
        if (![_x bound])
            [_x whenChangeBoundsPropagate:self];
        if (![_y bound])
            [_y whenChangeBoundsPropagate:self];
    } else {
        if ([_y max] <= [_x min])
            [_b bind:YES];
        else if ([_x min] < [_y max])
            [_b bind:NO];
        else {
            [_x whenChangeBoundsPropagate:self];
            [_y whenChangeBoundsPropagate:self];
            [_b whenBindPropagate:self];
        }
    }
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
    if (bound(_b)) {
        if (minDom(_b)) {  // YES <=>  x <= y
            [_x updateMax:[_y max]];
            [_y updateMin:[_x min]];
        } else {            // NO <=> x <= y   ==>  YES <=> x > y
            if ([_x bound]) { // c > y
                [_y updateMax:fp_previous_double([_x min])];
            } else {         // x > y
                [_y updateMax:fp_previous_double([_x max])];
                [_x updateMin:fp_next_double([_y min])];
            }
        }
        if (![_x bound])
            [_x whenChangeBoundsPropagate:self];
        if (![_y bound])
            [_y whenChangeBoundsPropagate:self];
    } else {
        if ([_x max] <= [_y min])
            [_b bind:YES];
        else if ([_x min] > [_y max])
            [_b bind:NO];
        else {
            [_x whenChangeBoundsPropagate:self];
            [_y whenChangeBoundsPropagate:self];
            [_b whenBindPropagate:self];
        }
    }
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
    if (bound(_b)) {
        if (minDom(_b)) {  // YES <=>  x < y
            [_x updateMax:fp_previous_double([_y max])];
            [_y updateMin:fp_next_double([_x min])];
        } else {            // NO <=> x <= y   ==>  YES <=> x > y
            if ([_x bound]) { // c >= y
                [_y updateMax:[_x min]];
            } else {         // x >= y
                [_y updateMax:[_x max]];
                [_x updateMin:[_y min]];
            }
        }
        if (![_x bound])
            [_x whenChangeBoundsPropagate:self];
        if (![_y bound])
            [_y whenChangeBoundsPropagate:self];
    } else {
        if ([_x max] <= [_y min])
            [_b bind:YES];
        else if ([_x min] > [_y max])
            [_b bind:NO];
        else {
            [_x whenChangeBoundsPropagate:self];
            [_y whenChangeBoundsPropagate:self];
            [_b whenBindPropagate:self];
        }
    }
}
-(void)propagate
{
    if (bound(_b)) {
        if (minDom(_b)) {
            [_x updateMax:fp_previous_double([_y max])];
            [_y updateMin:fp_next_double([_x min])];
        } else {
            [_y updateMax:[_x max]];
            [_x updateMin:[_y min]];
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
    if ([_b bound]) {
        if ([_b min])
            [_x updateMax:_c];
        else
            [_x updateMin:fp_next_double(_c)];
    }
    else if ([_x max] <= _c)
        [_b bind:YES];
    else if ([_x min] > _c)
        [_b bind:NO];
    else {
        [_b whenBindPropagate:self];
        [_x whenChangeBoundsPropagate:self];
    }
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
    if ([_b bound]) {
        if ([_b min]) // x < c
            [_x updateMax:fp_previous_double(_c)];
        else // x >= c
            [_x updateMin:_c];
    }
    else if ([_x max] < _c)
        [_b bind:YES];
    else if ([_x min] >= _c)
        [_b bind:NO];
    else {
        [_b whenBindPropagate:self];
        [_x whenChangeBoundsPropagate:self];
    }
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
    if ([_b bound]) {
        if ([_b min])
            [_x updateMin:_c];
        else
            [_x updateMax:fp_previous_double(_c)];
    }
    else if ([_x min] >= _c)
        [_b bind:YES];
    else if ([_x max] < _c)
        [_b bind:NO];
    else {
        [_b whenBindPropagate:self];
        [_x whenChangeBoundsPropagate:self];
    }
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
    if ([_b bound]) {
        if ([_b min])
            [_x updateMin:fp_next_double(_c)];
        else // x <= c
            [_x updateMax:_c];
    }
    else if ([_x min] > _c)
        [_b bind:YES];
    else if ([_x max] <= _c)
        [_b bind:NO];
    else {
        [_b whenBindPropagate:self];
        [_x whenChangeBoundsPropagate:self];
    }
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
    return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqualc:%02d %@ <=> (%@ > %16.16e)>",_name,_b,_x,_c];
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
