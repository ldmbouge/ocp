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

#include <fpi.h>


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
    if([self bound]){
        unsigned int *inf;
        inf = (unsigned int *)&(_domain._low);
        NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
        [buf appendFormat:@"%20.20e [%4X]",_domain._low,*inf ];
        return buf;
    }
    unsigned int *inf;
    unsigned int *sup;
    inf = (unsigned int *)&(_domain._low);
    sup = (unsigned int *)&(_domain._up);
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"(%20.20e,%20.20e) hexa (%4X,%4X)",_domain._low,_domain._up,*inf,*sup];
    return buf;
}
-(void) updateMin:(ORFloat)newMin for:(id<CPFloatVarNotifier>)x
{
    if(newMin > [self max])
        failNow();
    updateMin(&_domain, newMin, _trail);
    ORBool isBound = is_eqf(_domain._low,_domain._up);
    [x changeMinEvt: isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(void) updateMax:(ORFloat)newMax for:(id<CPFloatVarNotifier>)x
{
    if(newMax < [self min])
        failNow();
    updateMax(&_domain, newMax, _trail);
    ORBool isBound = is_eqf(_domain._low,_domain._up);
    [x changeMaxEvt:isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(void) updateInterval:(float_interval)v for:(id<CPFloatVarNotifier>)x;
{
    [self updateMin:v.inf for:x];
    [self updateMax:v.sup for:x];
}

-(void) bind:(ORFloat)val  for:(id<CPFloatVarNotifier>)x
{
    if (_domain._low <= val && val <= _domain._up) {
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
    return _domain._up == _domain._low;
}
-(ORInterval) bounds
{
    ORIReady();
    return createORI2(_domain._low, _domain._up);
}
-(ORLDouble) domwidth
{
    ORDouble min = (_domain._low == -infinityf()) ? -FLT_MAX : _domain._low;
    ORDouble max = (_domain._up == infinityf()) ? FLT_MAX : _domain._up;
    if(_domain._low == -INFINITY && _domain._up == INFINITY) return DBL_MAX;
    return  max - min;
}
-(TRFloatInterval) domain
{
    return _domain;
}
-(ORDouble) cardinality
{
    float_cast i_inf;
    float_cast i_sup;
    i_inf.f = _domain._low;
    i_sup.f = _domain._up;
    if(_domain._low == -INFINITY && _domain._up == INFINITY) return DBL_MAX;
    ORInt smin = (i_inf.parts.sign) ? -1:1;
    ORInt smax = (i_sup.parts.sign) ? -1:1;
    return (smax * i_sup.parts.exponent - smin * i_inf.parts.exponent) * NB_FLOAT_BY_E - i_inf.parts.mantisa + i_sup.parts.mantisa;
}
-(ORDouble) density
{
    ORDouble c = [self cardinality];
    ORLDouble w = [self domwidth];
    return c / w;
}
-(ORFloat) magnitude
{
    float_cast i_inf;
    float_cast i_sup;
    i_inf.f = _domain._low;
    i_sup.f = _domain._up;
    ORInt c = i_sup.parts.exponent + i_inf.parts.exponent;
    ORFloat w = E_MAX * 2;
    return c / w;
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



