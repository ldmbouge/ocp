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
        //TODO use maxFlt
        ORFloat min = maxOf([_x min], [_y min]);
        ORFloat max = minOf([_x max], [_y max]);
        [_x updateInterval:min and:max];
        [_y updateInterval:min and:max];
        [_x whenChangeBoundsPropagate:self];
        [_y whenChangeBoundsPropagate:self];
    }
}
-(void) propagate
{
    //TODO clean up
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
        //TODO use maxFlt
        ORFloat min = maxOf([_x min], [_y min]);
        ORFloat max = minOf([_x max], [_y max]);
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
    if ([_x bound]) {
        if([_x min] == _c)
            failNow();
    } else {
        [_x whenBindDo:^{
            if([_x min] == _c)
                failNow();
        } onBehalf:self];
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
    
    if([_x bound]){
        ORFloat nmin = fp_next_float([_x min]);
        [_y updateMin:nmin];
        assignTRInt(&_active, NO, _trail);
        return;
    }else if ([_y bound]){
        ORFloat pmin = fp_previous_float([_y min]);
        [_x updateMax:pmin];
        assignTRInt(&_active, NO, _trail);
        return;
    }
    if([_x isIntersectingWith:_y]){
        if([_x min] >= [_y min]){
            ORFloat nmin = fp_next_float([_x min]);
            [_y updateMin:nmin];
        }
        if([_x max] >= [_y max]){
            ORFloat pmax = fp_previous_float([_y max]);
            [_x updateMax:pmax];
        }
    }else{
        if([_x canFollow:_y])
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
    if([_x bound]){
        ORFloat pmin = fp_previous_float([_x min]);
        [_y updateMax:pmin];
        assignTRInt(&_active, NO, _trail);
        return;
    }else if ([_y bound]){
        ORFloat nmin = fp_next_float([_y min]);
        [_x updateMin:nmin];
        assignTRInt(&_active, NO, _trail);
        return;
    }
    if([_x isIntersectingWith:_y]){
        if([_x min] <= [_y min]){
            ORFloat pmin = fp_next_float([_y min]);
            [_x updateMin:pmin];
        }
        if([_x max] <= [_y max]){
            ORFloat nmax = fp_previous_float([_x max]);
            [_y updateMax:nmax];
        }
    }else{
        if([_x canPrecede:_y])
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
    return [NSString stringWithFormat:@"<%@ > %@>",_x,_y];
}
@end


@implementation CPFloatTernaryAdd
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y
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
    //TODO generalise
    ORInt precision = 1;
    ORInt arrondi = FE_TONEAREST;
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        //fix me update only low ?
        fpi_addf(precision, arrondi, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
        //FIX ME quand je passe un interval degenerer beug ?
        fpi_add_invsub_boundsf(precision, arrondi, &xTemp, &yTemp, &z);
        inter = intersection(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        inter = intersection(changed, y, yTemp);
        y = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_addxf_inv(precision, arrondi, &xTemp, &z, &y);
        inter = intersection(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_addyf_inv(precision, arrondi, &yTemp, &z, &x);
        inter = intersection(changed, y, yTemp);
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
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_subf(precision, arrondi, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
        fpi_sub_invsub_boundsf(precision, arrondi, &xTemp, &yTemp, &z);
        inter = intersection(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        inter = intersection(changed, y, yTemp);
        y = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_subxf_inv(precision, arrondi, &xTemp, &z, &y);
        inter = intersection(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_subyf_inv(precision, arrondi, &yTemp, &z, &x);
        inter = intersection(changed, y, yTemp);
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
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_multf(precision, arrondi, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_multxf_inv(precision, arrondi, &xTemp, &z, &y);
        inter = intersection(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_multyf_inv(precision, arrondi, &yTemp, &z, &x);
        inter = intersection(changed, y, yTemp);
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

@implementation CPFloatTernaryDiv
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x div:(CPFloatVarI*)y
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
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_divf(precision, arrondi, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        fpi_divxf_inv(precision, arrondi, &xTemp, &z, &y);
        inter = intersection(changed, x , xTemp);
        x = inter.result;
        changed |= inter.changed;
        
        yTemp = y;
        fpi_divyf_inv(precision, arrondi, &yTemp, &z, &x);
        inter = intersection(changed, y, yTemp);
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

