/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPLDoubleDom.h>
//#import "CPEngineI.h"
#import "CPError.h"
#import "CPLDoubleVarI.h"

#define BIND_EPSILON (0.0000001)
#define TOLERANCE    (0.0000001)

@implementation CPLDoubleDom

-(id)initCPLDoubleDom:(id<ORTrail>)trail low:(ORLDouble)low up:(ORLDouble)up
{
    self = [super init];
    _trail = trail;
    _imin = low;
    _imax = up;
  //  _min = makeTRDouble(_trail, _imin);
  //  _max = makeTRDouble(_trail, _imax);
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return [[CPLDoubleDom allocWithZone:zone] initCPLDoubleDom:_trail low:_imin up:_imax];
}
-(NSString*) description
{
    ORIReady();
    return ORIFormat(createORI2(_min._val, _max._val));
}
-(void) updateMin:(ORLDouble)newMin for:(id<CPLDoubleVarNotifier>)x
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
    assignTRLDouble(&_min, newMin, _trail);
    ORIReady();
    ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
    [x changeMinEvt: isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(void) updateMax:(ORLDouble)newMax for:(id<CPLDoubleVarNotifier>)x
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
    assignTRLDouble(&_max, newMax, _trail);
    ORIReady();
    ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
    [x changeMaxEvt:isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(void) bind:(ORLDouble)val  for:(id<CPLDoubleVarNotifier>)x
{
    ORIReady();
    if (_min._val <= val && val <= _max._val) {
        if (ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON))
            return;
        [x changeMinEvt:YES sender:self];
        [x changeMaxEvt:YES sender:self];
        [x bindEvt:self];
        assignTRLDouble(&_min, val, _trail);
        assignTRLDouble(&_max, val, _trail);
    }
    else
        failNow();
}
-(ORLDouble) min
{
    return _min._val;
}
-(ORLDouble) max
{
    return _max._val;
}
-(ORLDouble) imin
{
    return _imin;
}
-(ORLDouble) imax
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
-(ORLDouble) domwidth
{
    ORIReady();
    return ORIWidth(createORI2(_min._val, _max._val));
}
-(ORBool) member:(ORLDouble)v
{
    return _min._val <= v && v <= _max._val;
}
-(id) copy
{
    return [[CPLDoubleDom alloc] initCPLDoubleDom:_trail low:_imin up:_imax];
}
-(void) restoreDomain:(id<CPDoubleDom>)toRestore
{
    _min._val = [toRestore min];
    _max._val = [toRestore max];
}
-(void) restoreValue:(ORLDouble)toRestore for:(id<CPLDoubleVarNotifier>)x
{
    _min._val = _max._val = toRestore;
    [x bindEvt:self];
}

- (void) encodeWithCoder:(NSCoder *) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORLDouble) at:&_min._val];
    [aCoder encodeValueOfObjCType:@encode(ORLDouble) at:&_max._val];
    [aCoder encodeValueOfObjCType:@encode(ORLDouble) at:&_imin];
    [aCoder encodeValueOfObjCType:@encode(ORLDouble) at:&_imax];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORLDouble) at:&_min._val];
    [aDecoder decodeValueOfObjCType:@encode(ORLDouble) at:&_max._val];
    [aDecoder decodeValueOfObjCType:@encode(ORLDouble) at:&_imin];
    [aDecoder decodeValueOfObjCType:@encode(ORLDouble) at:&_imax];
    return self;
}
-(void) unionWith:(CPLDoubleDom*)d
{
   assignTRLDouble(&_min,min(_min._val,d->_min._val),_trail);
   assignTRLDouble(&_max,max(_max._val,d->_max._val),_trail);
}
@end
