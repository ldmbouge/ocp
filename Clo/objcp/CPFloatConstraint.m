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
    //TODO clean up
    NSLog(@"x : %f %f",[_x min],[_x max]);
    NSLog(@"y : %f %f",[_y min],[_y max]);
    if(([_x min] < [_y min] && [_x max] < [_y min]) || ([_y min] < [_x min] && [_y max] < [_x min])){
        //empty inter
        failNow();
    }else{
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
    }else if([_y bound]){
        [_x bind:[_y value]];
        assignTRInt(&_active, NO, _trail);
    }
    if(([_x min] < [_y min] && [_x max] < [_y min]) || ([_y min] < [_x min] && [_y max] < [_x min])){
        failNow();
    }else{
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
    //FIXME z domain Inf,-Inf
    z = makeFloatInterval([_z min],[_z max]);
    x = makeFloatInterval([_x min],[_x max]);
    y = makeFloatInterval([_y min],[_y max]);
    do {
        changed = false;
        zTemp = z;
        fpi_addf(precision, arrondi, &zTemp, &x, &y);
        inter = intersection(changed, z, zTemp);
        z = inter.result;
        changed |= inter.changed;
        
        xTemp = x;
        yTemp = y;
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

