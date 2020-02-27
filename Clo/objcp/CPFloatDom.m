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

#include <ORFoundation/fpi.h>


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
   CPFloatDom* res = [[CPFloatDom allocWithZone:zone] initCPFloatDom:_trail low:_domain._low up:_domain._up];
   res->_imax = _imax;
   res->_imin = _imin;
   return res;
}
-(NSString*) description
{
    if([self bound] && !(is_eqf(_domain._low,-0.0f) && is_eqf(_domain._up,+0.0f))){
        NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
        [buf appendFormat:@"%20.20e",_domain._low];
        return buf;
    }
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"(%20.20e,%20.20e)",_domain._low,_domain._up];
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

-(void) updateMin:(ORFloat)newMin for:(id<CPFloatVarNotifier>)x propagate:(ORBool) p
{
   if(newMin > [self max])
      failNow();
   updateMin(&_domain, newMin, _trail);
   if(p){
      ORBool isBound = is_eqf(_domain._low,_domain._up);
      [x changeMinEvt: isBound sender:self];
      if (isBound)
         [x bindEvt:self];
   }
}
-(void) updateMax:(ORFloat)newMax for:(id<CPFloatVarNotifier>)x propagate:(ORBool) p
{
   if(newMax < [self min])
      failNow();
   updateMax(&_domain, newMax, _trail);
   if(p){
      ORBool isBound = is_eqf(_domain._low,_domain._up);
      [x changeMaxEvt:isBound sender:self];
      if (isBound)
         [x bindEvt:self];
   }
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
   return is_eqf(_domain._low,_domain._up);
}
-(ORInterval) bounds
{
    ORIReady();
    return createORI2(_domain._low, _domain._up);
}
-(ORDouble) domwidth
{
    ORDouble min = (_domain._low == -infinityf()) ? -FLT_MAX : _domain._low;
    ORDouble max = (_domain._up == infinityf()) ? FLT_MAX : _domain._up;
    if(_domain._low == -infinityf() && _domain._up == infinityf()) return (ORDouble)FLT_MAX+(ORDouble)FLT_MAX;
   if([self bound]) return 0.0; //hzi : to deal with such domain [+INF,+INF] -> 0
    return  max - min;
}
-(TRFloatInterval) domain
{
    return _domain;
}
// HZI_TODO make this following methods has function
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
-(void) unionWith:(CPFloatDom*)d
{
   updateMin(&_domain, minFlt(_imin,d->_imin), _trail);
   updateMax(&_domain, maxFlt(_imax,d->_imax), _trail);
}
-(BOOL) isEqual:(CPFloatDom*)d
{
   return (is_eqf(_domain._low,d->_domain._low) && is_eqf(_domain._up,d->_domain._up));
}
@end
