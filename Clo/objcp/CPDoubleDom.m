/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPDoubleDom.h"
//#import "CPEngineI.h"
#import "CPError.h"
#import "CPDoubleVarI.h"

#include <fpi.h>


@implementation CPDoubleDom

-(id)initCPDoubleDom:(id<ORTrail>)trail low:(ORDouble)low up:(ORDouble)up
{
    self = [super init];
    _trail = trail;
    _imin = low;
    _imax = up;
    _domain = makeTRDoubleInterval(_trail, _imin, _imax);
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return [[CPDoubleDom allocWithZone:zone] initCPDoubleDom:_trail low:_imin up:_imax];
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
-(void) updateMin:(ORDouble)newMin for:(id<CPDoubleVarNotifier>)x
{
    if(newMin > [self max])
        failNow();
    updateMinD(&_domain, newMin, _trail);
    ORBool isBound = is_eqf(_domain._low,_domain._up);
    [x changeMinEvt: isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(void) updateMax:(ORDouble)newMax for:(id<CPDoubleVarNotifier>)x
{
    if(newMax < [self min])
        failNow();
    updateMaxD(&_domain, newMax, _trail);
    ORBool isBound = is_eqf(_domain._low,_domain._up);
    [x changeMaxEvt:isBound sender:self];
    if (isBound)
        [x bindEvt:self];
}
-(void) updateInterval:(double_interval)v for:(id<CPDoubleVarNotifier>)x;
{
    [self updateMin:v.inf for:x];
    [self updateMax:v.sup for:x];
}

-(void) bind:(ORDouble)val  for:(id<CPDoubleVarNotifier>)x
{
    if (_domain._low <= val && val <= _domain._up) {
        [x changeMinEvt:YES sender:self];
        [x changeMaxEvt:YES sender:self];
        [x bindEvt:self];
        updateTRDoubleInterval(&_domain, val, val, _trail);
    }
    else
        failNow();
}
-(ORDouble) min
{
    return _domain._low;
}
-(ORDouble) max
{
    return _domain._up;
}
-(ORDouble) imin
{
    return _imin;
}
-(ORDouble) imax
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
    return  max - min;
}
-(TRDoubleInterval) domain
{
    return _domain;
}
-(ORDouble) cardinality
{
    double_cast i_inf;
    double_cast i_sup;
    i_inf.f = _domain._low;
    i_sup.f = _domain._up;
    return (i_sup.parts.exponent - i_inf.parts.exponent) * NB_DOUBLE_BY_E - i_inf.parts.mantisa + i_sup.parts.mantisa;
}
-(ORDouble) density
{
    ORDouble c = [self cardinality];
    ORLDouble w = [self domwidth];
    return c / w;
}
-(ORDouble) magnitude
{
    double_cast i_inf;
    double_cast i_sup;
    i_inf.f = _domain._low;
    i_sup.f = _domain._up;
    ORInt c = i_sup.parts.exponent + i_inf.parts.exponent;
    ORDouble w = ED_MAX * 2;
    return c / w;
}
-(ORBool) member:(ORDouble)v
{
    return _domain._low <= v && v <= _domain._up;
}
-(id) copy
{
    return [[CPDoubleDom alloc] initCPDoubleDom:_trail low:_imin up:_imax];
}
-(void) restoreDomain:(id<CPDoubleDom>)toRestore
{
    updateMinD(&_domain, toRestore.min, _trail);
    updateMaxD(&_domain, toRestore.max, _trail);
}
-(void) restoreValue:(ORDouble)toRestore for:(id<CPDoubleVarNotifier>)x
{
    updateMinD(&_domain, toRestore, _trail);
    updateMaxD(&_domain, toRestore, _trail);
    [x bindEvt:self];
}

- (void) encodeWithCoder:(NSCoder *) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_domain._low];
    [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_domain._up];
    [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_imin];
    [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_imax];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
    self = [super init];
    double low, up;
    [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&low];
    [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&up];
    _domain = makeTRDoubleInterval(_trail, low, up);
    [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_imin];
    [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_imax];
    return self;
}
@end
