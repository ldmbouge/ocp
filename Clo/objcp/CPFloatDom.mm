/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPFloatDom.h"
//#import "CPEngineI.h"
#import "CPError.h"
#import "CPFloatVarI.h"

#include <fpc.h>


#define BIND_EPSILON (0.0000001)
#define TOLERANCE    (0.0000001)

@implementation CPFloatDom

-(id)initCPFloatDom:(id<ORTrail>)trail low:(ORFloat)low up:(ORFloat)up
{
    self = [super init];
    _trail = trail;
    _imin = low;
    _imax = up;
    _domain = makeTRFloatInterval(_trail, _imin, _imax);
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return [[CPFloatDom allocWithZone:zone] initCPFloatDom:_trail low:_imin up:_imax];
}
-(NSString*) description
{
    ORIReady();
    return ORIFormat(createORI2(_domain._low, _domain._up));
}
-(void) updateMin:(ORFloat)newMin for:(id<CPFloatVarNotifier>)x
{
    ORIReady();
    ORInterval me = createORI2(_domain._low, _domain._up);
    BOOL isb = ORIBound(me, TOLERANCE);
    if (isb)
        return;
    if (newMin <= _domain._low)
        return;
    if (ORIEmpty(ORIInter(me, createORI1(newMin))))
        failNow();
    updateMin(&_domain, newMin, _trail);
    ORBool isBound = ORIBound(createORI2(_domain._low, _domain._up), BIND_EPSILON);
    [x changeMinEvt: isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(void) updateMax:(ORFloat)newMax for:(id<CPFloatVarNotifier>)x
{
    ORIReady();
    ORInterval me = createORI2(_domain._low, _domain._up);
    BOOL isb = ORIBound(me, TOLERANCE);
    if (isb)
        return;
    if (newMax >= _domain._up)
        return;
    if (ORIEmpty(ORIInter(me, createORI1(newMax))))
        failNow();
    updateMin(&_domain, newMax, _trail);
    ORIReady();
    ORBool isBound = ORIBound(createORI2(_domain._low, _domain._up), BIND_EPSILON);
    [x changeMaxEvt:isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(ORNarrowing) updateInterval: (ORInterval) v for: (id<CPFloatVarNotifier>) x
{
    ORIReady();
    ORInterval src= createORI2(_domain._low, _domain._up);
    ORInterval is = ORIInter(src, v);
    if (ORIEmpty(is))
        failNow();
    switch (ORINarrow(src, is)) {
        case ORBoth:
        {
            ORDouble nl,nu;
            ORIBounds(is, &nl, &nu);
            updateTRFloatInterval(&_domain, nl, nu, _trail);
            ORBool isBound = ORIBound(createORI2(_domain._low, _domain._up), BIND_EPSILON);
            [x changeMinEvt:isBound sender:self];
            [x changeMaxEvt:isBound sender:self];
            if (isBound)
                [x bindEvt:self];
            return ORBoth;
        }break;
        case ORLow:
        {
            ORFloat nl = ORILow(is);
            updateMin(&_domain,nl, _trail);
            ORBool isBound = ORIBound(createORI2(_domain._low, _domain._up), BIND_EPSILON);
            [x changeMinEvt:isBound sender:self];
            if (isBound)
                [x bindEvt:self];
            return ORLow;
        }break;
        case ORUp:
        {
            ORFloat nu = ORIUp(is);
            updateMax(&_domain,nu, _trail);
            ORBool isBound = ORIBound(createORI2(_domain._low, _domain._up), BIND_EPSILON);
            [x changeMaxEvt:isBound sender:self];
            if (isBound)
                [x bindEvt:self];
            return ORUp;
        }break;
        case ORNone:
            return ORNone;
    }
}

-(void) bind:(ORFloat)val  for:(id<CPFloatVarNotifier>)x
{
    ORIReady();
    if (_domain._low <= val && val <= _domain._up) {
        if (ORIBound(createORI2(_domain._low, _domain._up), BIND_EPSILON))
            return;
        [x changeMinEvt:YES sender:self];
        [x changeMaxEvt:YES sender:self];
        [x bindEvt:self];
        updateTRFloatInterval(&_domain, val, val, _trail);
    }
    else
        failNow();
}
-(ORFloat) min
{
    return _domain._low;
}
-(ORFloat) max
{
    return _domain._up;
}
-(ORFloat) imin
{
    return _imin;
}
-(ORFloat) imax
{
    return _imax;
}
-(ORBool) bound
{
    ORIReady();
    return ORIBound(createORI2(_domain._low, _domain._up), BIND_EPSILON);
}
-(ORInterval) bounds
{
    ORIReady();
    return createORI2(_domain._low, _domain._up);
}
-(ORFloat) domwidth
{
    ORIReady();
    return ORIWidth(createORI2(_domain._low, _domain._up));
}
-(ORBool) member:(ORFloat)v
{
    return _domain._low <= v && v <= _domain._up;
}
-(id) copy
{
    return [[CPFloatDom alloc] initCPFloatDom:_trail low:_imin up:_imax];
}
-(void) restoreDomain:(id<CPFloatDom>)toRestore
{
    updateMin(&_domain, toRestore.min, _trail);
    updateMax(&_domain, toRestore.max, _trail);
}
-(void) restoreValue:(ORFloat)toRestore for:(id<CPFloatVarNotifier>)x
{
    updateMin(&_domain, toRestore, _trail);
    updateMax(&_domain, toRestore, _trail);
    [x bindEvt:self];
}

- (void) encodeWithCoder:(NSCoder *) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_domain._low];
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_domain._up];
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_imin];
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_imax];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
    self = [super init];
    float low, up;
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&low];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&up];
    _domain = makeTRFloatInterval(_trail, low, up);
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_imin];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_imax];
    return self;
}
@end
