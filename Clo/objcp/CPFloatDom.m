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

#define BIND_EPSILON (0.0000001)
#define TOLERANCE    (0.0000001)

@implementation CPFloatDom

-(id)initCPFloatDom:(id<ORTrail>)trail low:(ORFloat)low up:(ORFloat)up
{
    self = [super init];
    _trail = trail;
    _imin = low;
    _imax = up;
 //   _min = makeTRFloat(_trail, _imin);
 //   _max = makeTRFloat(_trail, _imax);
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return [[CPFloatDom allocWithZone:zone] initCPFloatDom:_trail low:_imin up:_imax];
}
-(NSString*) description
{
    ORIReady();
    return ORIFormat(createORI2(_min._val, _max._val));
}
-(void) updateMin:(ORFloat)newMin for:(id<CPFloatVarNotifier>)x
{
    ORIReady();
    ORInterval me = createORI2(_min._val, _max._val);
    BOOL isb = ORIBound(me, TOLERANCE);
    if (isb)
        return;
    if (newMin <= _min._val)
        return;
    if (ORIEmpty(ORIInter(me, createORI1(newMin))))
        failNow();
   // assignTRFloat(&_min, newMin, _trail);
    ORIReady();
    ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
    [x changeMinEvt: isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(void) updateMax:(ORFloat)newMax for:(id<CPFloatVarNotifier>)x
{
    ORIReady();
    ORInterval me = createORI2(_min._val, _max._val);
    BOOL isb = ORIBound(me, TOLERANCE);
    if (isb)
        return;
    if (newMax >= _max._val)
        return;
    if (ORIEmpty(ORIInter(me, createORI1(newMax))))
        failNow();
    //assignTRFloat(&_max, newMax, _trail);
    ORIReady();
    ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
    [x changeMaxEvt:isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(ORNarrowing) updateInterval: (ORInterval) v for: (id<CPFloatVarNotifier>) x
{
    ORIReady();
    ORInterval src= createORI2(_min._val, _max._val);
    ORInterval is = ORIInter(src, v);
    if (ORIEmpty(is))
        failNow();
    switch (ORINarrow(src, is)) {
        case ORBoth:
        {
            ORFloat nl,nu;
            ORIBounds(is, &nl, &nu);
          //  assignTRFloat(&_min, nl, _trail);
          //  assignTRFloat(&_max, nu, _trail);
            ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
            [x changeMinEvt:isBound sender:self];
            [x changeMaxEvt:isBound sender:self];
            if (isBound)
                [x bindEvt:self];
            return ORBoth;
        }break;
        case ORLow:
        {
            ORFloat nl = ORILow(is);
           // assignTRFloat(&_min, nl, _trail);
            ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
            [x changeMinEvt:isBound sender:self];
            if (isBound)
                [x bindEvt:self];
            return ORLow;
        }break;
        case ORUp:
        {
            ORFloat nu = ORIUp(is);
          //  assignTRFloat(&_max, nu, _trail);
            ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
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
    if (_min._val <= val && val <= _max._val) {
        if (ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON))
            return;
        [x changeMinEvt:YES sender:self];
        [x changeMaxEvt:YES sender:self];
        [x bindEvt:self];
       // assignTRFloat(&_min, val, _trail);
       // assignTRFloat(&_max, val, _trail);
    }
    else
        failNow();
}
-(ORFloat) min
{
    return _min._val;
}
-(ORFloat) max
{
    return _max._val;
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
    return ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
}
-(ORInterval) bounds
{
    ORIReady();
    return createORI2(_min._val, _max._val);
}
-(ORFloat) domwidth
{
    ORIReady();
    return ORIWidth(createORI2(_min._val, _max._val));
}
-(ORBool) member:(ORFloat)v
{
    return _min._val <= v && v <= _max._val;
}
-(id) copy
{
    return [[CPFloatDom alloc] initCPFloatDom:_trail low:_imin up:_imax];
}
-(void) restoreDomain:(id<CPFloatDom>)toRestore
{
    _min._val = [toRestore min];
    _max._val = [toRestore max];
}
-(void) restoreValue:(ORFloat)toRestore for:(id<CPFloatVarNotifier>)x
{
    _min._val = _max._val = toRestore;
    [x bindEvt:self];
}

- (void) encodeWithCoder:(NSCoder *) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_min._val];
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_max._val];
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_imin];
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_imax];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_min._val];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_max._val];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_imin];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_imax];
    return self;
}
@end
