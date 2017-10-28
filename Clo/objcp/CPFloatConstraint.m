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
#import "ORConstraintI.h"

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
        ORFloat min = maxFlt([_x min], [_y min]);
        ORFloat max = minFlt([_x max], [_y max]);
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
        ORFloat min = maxFlt([_x min], [_y min]);
        ORFloat max = minFlt([_x max], [_y max]);
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
    [_x whenBindPropagate:self];
    [_y whenBindPropagate:self];
}
-(void) propagate
{
    if ([_x bound]) {
        if([_y bound]){
            if ([_x min] == [_y min])
                failNow();
            else
                assignTRInt(&_active, NO, _trail);
            return;
        }
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
    [_y whenChangeBoundsPropagate:self];
    [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    if([_x canFollow:_y])
        failNow();
    if([_x isIntersectingWith:_y]){
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
    [_y whenChangeBoundsPropagate:self];
    [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    if([_x canPrecede:_y])
        failNow();
    if([_x isIntersectingWith:_y]){
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
    [_y whenChangeBoundsPropagate:self];
    [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    if([_x canFollow:_y])
        failNow();
    if([_x isIntersectingWith:_y]){
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
    [_y whenChangeBoundsPropagate:self];
    [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    if([_x canPrecede:_y])
        failNow();
    if([_x isIntersectingWith:_y]){
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


@implementation CPFloatTernaryAdd
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    _precision = 1;
    _percent = 0.0;
    _rounding = FE_TONEAREST;
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
    int gchanged,changed;
    changed = gchanged = false;
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_addf(_precision, _rounding, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp,_percent);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
        fpi_add_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
        inter = intersection(changed, x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        inter = intersection(changed, y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_addxf_inv(_precision, _rounding, &xTemp, &z, &y);
        inter = intersection(changed, x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_addyf_inv(_precision, _rounding, &yTemp, &z, &x);
        inter = intersection(changed, y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        gchanged |= changed;
     } while(changed);
    if(gchanged){
        [_x updateInterval:x.inf and:x.sup];
        [_y updateInterval:y.inf and:y.sup];
        [_z updateInterval:z.inf and:z.sup];
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
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x
{
    ORFloat m;
    ORFloat min, max;
    ORInt e;
    if([x getId] == [_y getId]){
        m = maxFlt(fabsf([_y min]),fabs([_y max]));
        frexpf((maxFlt(fabsf([_y min]),fabs([_y max]))), &e);
        min = -pow(2.0,e - 23 - 1);
        max = pow(2.0,e -23 - 1);
        if(isIntersectionWith(min, max, [_y min], [_y max])){
            return cardinality(maxFlt(min, [_y min]),minFlt(max, [_y max]))/[_y cardinality];
        }
    }else if([x getId] == [_x getId]){
        m = maxFlt(fabsf([_x min]),fabs([_x max]));
        frexpf((maxFlt(fabsf([_x min]),fabs([_x max]))), &e);
        min = -pow(2.0,e - 23 - 1);
        max = pow(2.0,e -23 - 1);
        if(isIntersectionWith(min, max, [_x min], [_x max])){
            return cardinality(maxFlt(min, [_x min]),minFlt(max, [_x max]))/[_x cardinality];
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


@implementation CPFloatTernarySub
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    _precision = 1;
    _percent = 0.0;
    _rounding = FE_TONEAREST;
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
    int gchanged,changed;
    changed = gchanged = false;
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_subf(_precision, _rounding, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp,_percent);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
        fpi_sub_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
        inter = intersection(changed, x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        inter = intersection(changed, y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_subxf_inv(_precision, _rounding, &xTemp, &z, &y);
        inter = intersection(changed, x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_subyf_inv(_precision, _rounding, &yTemp, &z, &x);
        inter = intersection(changed, y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        gchanged |= changed;
    } while(changed);
    if(gchanged){
        [_x updateInterval:x.inf and:x.sup];
        [_y updateInterval:y.inf and:y.sup];
        [_z updateInterval:z.inf and:z.sup];
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
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x
{
    ORFloat m;
    ORFloat min, max;
    ORInt e;
    if([x getId] == [_y getId]){
        m = maxFlt(fabsf([_y min]),fabs([_y max]));
        frexpf((maxFlt(fabsf([_y min]),fabs([_y max]))), &e);
        min = -pow(2.0,e - 23 - 1);
        max = pow(2.0,e -23 - 1);
        if(isIntersectionWith(min, max, [_y min], [_y max])){
            return cardinality(maxFlt(min, [_y min]),minFlt(max, [_y max]))/[_y cardinality];
        }
    }else if([x getId] == [_x getId]){
        m = maxFlt(fabsf([_x min]),fabs([_x max]));
        frexpf((maxFlt(fabsf([_x min]),fabs([_x max]))), &e);
        min = -pow(2.0,e - 23 - 1);
        max = pow(2.0,e -23 - 1);
        if(isIntersectionWith(min, max, [_x min], [_x max])){
            ORDouble card_intersection = cardinality(maxFlt(min, [_x min]),minFlt(max, [_x max]));
            return card_intersection/[_x cardinality];
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

@implementation CPFloatTernaryMult
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x mult:(CPFloatVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    _precision = 1;
    _percent = 0.0;
    _rounding = FE_TONEAREST;
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
    int gchanged,changed;
    changed = gchanged = false;
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_multf(_precision, _rounding, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp,_percent);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_multxf_inv(_precision, _rounding, &xTemp, &z, &y);
        inter = intersection(changed, x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_multyf_inv(_precision, _rounding, &yTemp, &z, &x);
        inter = intersection(changed, y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        gchanged |= changed;
    } while(changed);
    if(gchanged){
        [_x updateInterval:x.inf and:x.sup];
        [_y updateInterval:y.inf and:y.sup];
        [_z updateInterval:z.inf and:z.sup];
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
    return [NSString stringWithFormat:@"<%@ = %@ * %@>",_z, _x, _y];
}
@end

@implementation CPFloatTernaryDiv
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x div:(CPFloatVarI*)y
{
    self = [super initCPCoreConstraint: [x engine]];
    _z = z;
    _x = x;
    _y = y;
    _precision = 1;
    _percent = 0.0;
    _rounding = FE_TONEAREST;
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
    int gchanged,changed;
    changed = gchanged = false;
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_divf(_precision, _rounding, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp,_percent);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_divxf_inv(_precision, _rounding, &xTemp, &z, &y);
        inter = intersection(changed, x , xTemp,_percent);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_divyf_inv(_precision, _rounding, &yTemp, &z, &x);
        inter = intersection(changed, y, yTemp,_percent);
        y = inter.result;
        changed |= inter.changed;
        gchanged |= changed;
    } while(changed);
    if(gchanged){
        [_x updateInterval:x.inf and:x.sup];
        [_y updateInterval:y.inf and:y.sup];
        [_z updateInterval:z.inf and:z.sup];
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
    return [NSString stringWithFormat:@"<%@ = %@ / %@>",_z, _x, _y];
}
@end
