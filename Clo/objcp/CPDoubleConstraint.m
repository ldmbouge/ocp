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
    if([_x bound]){
        [_y bind:[_x value]];
        return;
    }else if([_y bound]){
        [_x bind:[_y value]];
        return;
    }
    if(![_x isIntersectingWith:_y]){
        failNow();
    }else{
        ORDouble min = maxFlt([_x min], [_y min]);
        ORDouble max = minFlt([_x max], [_y max]);
        [_x updateInterval:min and:max];
        [_y updateInterval:min and:max];
        [_x whenChangeBoundsPropagate:self];
        [_y whenChangeBoundsPropagate:self];
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
    if(![_x isIntersectingWith:_y]){
        failNow();
    }else{
        ORDouble min = maxFlt([_x min], [_y min]);
        ORDouble max = minFlt([_x max], [_y max]);
        [_x updateInterval:min and:max];
        [_y updateInterval:min and:max];
    }
    
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
    return [NSString stringWithFormat:@"<%@ == %f>",_x,_c];
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
}
-(void) propagate
{
    if ([_x bound]) {
        if([_x min] == _c)
            failNow();
    }
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
    if([_x canFollow:_y])
        failNow();
    if([_x isIntersectingWith:_y]){
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
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    return ![_x bound];
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
    if([_x canPrecede:_y])
        failNow();
    if([_x isIntersectingWith:_y]){
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
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    return ![_x bound];
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
    if([_x canFollow:_y])
        failNow();
    if([_x isIntersectingWith:_y]){
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
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    return ![_x bound];
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
    if([_x canPrecede:_y])
        failNow();
    if([_x isIntersectingWith:_y]){
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
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    return ![_x bound];
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"<%@ >= %@>",_x,_y];
}
@end


@implementation CPDoubleTernaryAdd
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    return self;
}
-(void) post
{
    [self propagate];
    if (![_x bound]) [_x whenChangeBoundsPropagate:self];
    if (![_y bound]) [_y whenChangeBoundsPropagate:self];
    if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    int changed = false;
    ORInt precision = 1;
    ORInt arrondi = FE_TONEAREST;
    double_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionDoubleInterval inter;
    z = makeDoubleInterval([_z min],[_z max]);
    x = makeDoubleInterval([_x min],[_x max]);
    y = makeDoubleInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_addd(precision, arrondi, &zTemp, &x, &y);
        inter = intersectionDouble(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
        fpi_add_invsub_bounds(precision, arrondi, &xTemp, &yTemp, &z);
        inter = intersectionDouble(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        inter = intersectionDouble(changed, y, yTemp);
        y = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_addxd_inv(precision, arrondi, &xTemp, &z, &y);
        inter = intersectionDouble(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_addyd_inv(precision, arrondi, &yTemp, &z, &x);
        inter = intersectionDouble(changed, y, yTemp);
        y = inter.result;
        changed |= inter.changed;
    } while(changed);
    [_x updateInterval:x.inf and:x.sup];
    [_y updateInterval:y.inf and:y.sup];
    [_z updateInterval:z.inf and:z.sup];
}
-(NSSet*)allVars
{
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    return ![_x bound];
}
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x
{
    ORDouble m;
    ORDouble min, max;
    ORInt e;
    if([x getId] == [_y getId]){
        m = maxDbl(fabs([_y min]),fabs([_y max]));
        frexpf((maxDbl(fabs([_y min]),fabs([_y max]))), &e);
        min = -pow(2.0,e - 23 - 1);
        max = pow(2.0,e -23 - 1);
        if(isIntersectionWithD(min, max, [_y min], [_y max])){
            return cardinalityD(maxDbl(min, [_y min]),minDbl(max, [_y max]))/[_y cardinality];
        }
    }else if([x getId] == [_x getId]){
        m = maxDbl(fabs([_y min]),fabs([_y max]));
        frexpf((maxDbl(fabs([_y min]),fabs([_y max]))), &e);
        min = -pow(2.0,e - 23 - 1);
        max = pow(2.0,e -23 - 1);
        if(isIntersectionWithD(min, max, [_y min], [_y max])){
            return cardinalityD(maxDbl(min, [_y min]),minDbl(max, [_y max]))/[_y cardinality];
        }
    }
    return 0.0;
}
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
    zmin = ([_z min] <= 0 && [_z max] >= 0) ? 0 : min(ezmin,ezmax);
    return gmax-zmin;
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"<%@ = %@ + %@>",_z, _x, _y];
}
@end


@implementation CPDoubleTernarySub
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    return self;
}

-(void) post
{
    [self propagate];
    if (![_x bound]) [_x whenChangeBoundsPropagate:self];
    if (![_y bound]) [_y whenChangeBoundsPropagate:self];
    if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    int changed = false;
    //TO generalise
    ORInt precision = 1;
    ORInt arrondi = FE_TONEAREST;
    double_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionDoubleInterval inter;
    z = makeDoubleInterval([_z min],[_z max]);
    x = makeDoubleInterval([_x min],[_x max]);
    y = makeDoubleInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_subd(precision, arrondi, &zTemp, &x, &y);
        inter = intersectionDouble(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
        fpi_sub_invsub_bounds(precision, arrondi, &xTemp, &yTemp, &z);
        inter = intersectionDouble(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        inter = intersectionDouble(changed, y, yTemp);
        y = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_subxd_inv(precision, arrondi, &xTemp, &z, &y);
        inter = intersectionDouble(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_subyd_inv(precision, arrondi, &yTemp, &z, &x);
        inter = intersectionDouble(changed, y, yTemp);
        y = inter.result;
        changed |= inter.changed;
    } while(changed);
    [_x updateInterval:x.inf and:x.sup];
    [_y updateInterval:y.inf and:y.sup];
    [_z updateInterval:z.inf and:z.sup];
}
-(NSSet*)allVars
{
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    return ![_x bound];
}
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x
{
    ORDouble m;
    ORDouble min, max;
    ORInt e;
    if([x getId] == [_y getId]){
        m = maxDbl(fabs([_y min]),fabs([_y max]));
        frexpf((maxDbl(fabs([_y min]),fabs([_y max]))), &e);
        min = -pow(2.0,e - 23 - 1);
        max = pow(2.0,e -23 - 1);
        if(isIntersectionWithD(min, max, [_y min], [_y max])){
            return cardinalityD(maxDbl(min, [_y min]),minDbl(max, [_y max]))/[_y cardinality];
        }
    }else if([x getId] == [_x getId]){
        m = maxFlt(fabs([_y min]),fabs([_y max]));
        frexpf((maxFlt(fabs([_y min]),fabs([_y max]))), &e);
        min = -pow(2.0,e - 23 - 1);
        max = pow(2.0,e -23 - 1);
        if(isIntersectionWithD(min, max, [_y min], [_y max])){
            return cardinalityD(maxDbl(min, [_y min]),minDbl(max, [_y max]))/[_y cardinality];
        }
    }
    return 0.0;
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
    zmin = ([_z min] <= 0 && [_z max] >= 0) ? 0 : min(ezmin,ezmax);
    return gmax-zmin;
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
@end

@implementation CPDoubleTernaryMult
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x mult:(CPDoubleVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    return self;
}
-(void) post
{
    [self propagate];
    if (![_x bound]) [_x whenChangeBoundsPropagate:self];
    if (![_y bound]) [_y whenChangeBoundsPropagate:self];
    if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    int changed = false;
    //TO generalise
    ORInt precision = 1;
    ORInt arrondi = FE_TONEAREST;
    double_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionDoubleInterval inter;
    z = makeDoubleInterval([_z min],[_z max]);
    x = makeDoubleInterval([_x min],[_x max]);
    y = makeDoubleInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_multd(precision, arrondi, &zTemp, &x, &y);
        inter = intersectionDouble(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_multxd_inv(precision, arrondi, &xTemp, &z, &y);
        inter = intersectionDouble(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_multyd_inv(precision, arrondi, &yTemp, &z, &x);
        inter = intersectionDouble(changed, y, yTemp);
        y = inter.result;
        changed |= inter.changed;
    } while(changed);
    [_x updateInterval:x.inf and:x.sup];
    [_y updateInterval:y.inf and:y.sup];
    [_z updateInterval:z.inf and:z.sup];
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
    return [NSString stringWithFormat:@"<%@ = %@ * %@>",_z, _x, _y];
}
@end

@implementation CPDoubleTernaryDiv
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x div:(CPDoubleVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    return self;
}
-(void) post
{
    [self propagate];
    if (![_x bound]) [_x whenChangeBoundsPropagate:self];
    if (![_y bound]) [_y whenChangeBoundsPropagate:self];
    if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    int changed = false;
    ORInt precision = 1;
    ORInt arrondi = FE_TONEAREST;
    double_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionDoubleInterval inter;
    z = makeDoubleInterval([_z min],[_z max]);
    x = makeDoubleInterval([_x min],[_x max]);
    y = makeDoubleInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_divd(precision, arrondi, &zTemp, &x, &y);
        inter = intersectionDouble(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_divxd_inv(precision, arrondi, &xTemp, &z, &y);
        inter = intersectionDouble(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_divyd_inv(precision, arrondi, &yTemp, &z, &x);
        inter = intersectionDouble(changed, y, yTemp);
        y = inter.result;
        changed |= inter.changed;
    } while(changed);
    [_x updateInterval:x.inf and:x.sup];
    [_y updateInterval:y.inf and:y.sup];
    [_z updateInterval:z.inf and:z.sup];
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
    return [NSString stringWithFormat:@"<%@ = %@ / %@>",_z, _x, _y];
}
@end

@implementation CPDoubleSSA
-(id) init:(CPDoubleVarI*)z ssa:(CPDoubleVarI*)x with:(CPDoubleVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    return self;
}
-(void) post
{
    [self propagate];
    if (![_x bound]) [_x whenChangeBoundsPropagate:self];
    if (![_y bound]) [_y whenChangeBoundsPropagate:self];
    if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    ORDouble min = maxFlt([_x min], [_y min]);
    ORDouble max = minFlt([_x max], [_y max]);
    [_z updateInterval:min and:max];
    //y = z inter y
    if([_z isIntersectingWith:_y]){
        min = maxFlt([_z min], [_y min]);
        max = minFlt([_z min], [_y min]);
        [_y updateInterval:min and:max];
    }
    //x = z inter x
    if([_z isIntersectingWith:_x]){
        min = maxFlt([_z min], [_x min]);
        max = minFlt([_z min], [_x min]);
        [_x updateInterval:min and:max];
    }
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
    return [NSString stringWithFormat:@"<SSA %@ U %@>", _x, _y];
}
@end
