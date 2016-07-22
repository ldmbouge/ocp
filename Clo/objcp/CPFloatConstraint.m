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


typedef struct {
    float_interval  result;
    float_interval  interval;
    int  changed;
} intersectionInterval;


intersectionInterval intersection(int changed,float_interval r, float_interval x)
{
    fpi_narrowf(&r, &x, &changed);
    return (intersectionInterval){r,x,changed};
}

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
    return [NSString stringWithFormat:@"<x[%d] == %f>",[_x getId],_c];
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
    return [NSString stringWithFormat:@"<x[%d] != %f>",[_x getId],_c];
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
    int changed = false;
    //TO generalise
    ORInt precision = 1;
    ORInt arrondi = FE_TONEAREST;
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    z = TRFloatInterval2float_interval([_z domain]);
    x = TRFloatInterval2float_interval([_x domain]);
    y = TRFloatInterval2float_interval([_y domain]);
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
    
    [_z updateMin:z.inf];
    [_x updateMin:x.inf];
    [_y updateMin:y.inf];
    [_z updateMax:z.sup];
    [_x updateMax:x.sup];
    [_y updateMax:y.sup];
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
    if([_y bound])
        return [NSString stringWithFormat:@"<x[%d] = x[%d] + x[%d](value=%f)>",[_z getId],[_x getId],[_y getId],[_y value]];
    
    return [NSString stringWithFormat:@"<x[%d] = x[%d] + x[%d]>",[_z getId],[_x getId],[_y getId]];
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
    int changed = false;
    //TO generalise
    ORInt precision = 1;
    ORInt arrondi = FE_TONEAREST;
    float_interval zTemp,yTemp,xTemp,z,x,y;
    intersectionInterval inter;
    //TODO use min and max
    z = TRFloatInterval2float_interval([_z domain]);
    x = TRFloatInterval2float_interval([_x domain]);
    y = TRFloatInterval2float_interval([_y domain]);
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
    
    [_z updateMin:z.inf];
    [_x updateMin:x.inf];
    [_y updateMin:y.inf];
    [_z updateMax:z.sup];
    [_x updateMax:x.sup];
    [_y updateMax:y.sup];
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
    if([_y bound])
        return [NSString stringWithFormat:@"<x[%d] = x[%d] - x[%d](value=%f)>",[_z getId],[_x getId],[_y getId],[_y value]];
    return [NSString stringWithFormat:@"<x[%d] = x[%d] - x[%d]>",[_z getId],[_x getId],[_y getId]];
}
@end

