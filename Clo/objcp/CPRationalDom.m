/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPRationalDom.h"
//#import "CPEngineI.h"
//#import "CPFloatVarI.h"

@implementation CPRationalDom

-(id)initCPRationalDom:(id<ORTrail>)trail low:(id<ORRational>)low up:(id<ORRational>)up
{
    self = [super init];
    _trail = trail;
    _imin = [ORRational rationalWith:low];
    _imax = [ORRational rationalWith:up];
    _domain = makeTRRationalInterval(trail, _imin, _imax);
    return self;
}
-(id)initCPRationalDom:(id<ORTrail>)trail lowF:(ORDouble)low upF:(ORDouble)up
{
    self = [super init];
    _trail = trail;
    _imin = [ORRational rationalWith_d:low];
    _imax = [ORRational rationalWith_d:up];
    _domain = makeTRRationalInterval(trail, _imin, _imax);
    return self;
}
-(id)initCPRationalDom:(id<ORTrail>)trail
{
   self = [self initCPRationalDom:trail lowF:-INFINITY upF:+INFINITY];
   return self;
}
-(void) dealloc
{
   [_imin release];
   [_imax release];
   [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
    return [[CPRationalDom allocWithZone:zone] initCPRationalDom:_trail lowF:[_imin get_d] upF:[_imax get_d]];
}
-(NSString*) description
{
    if([self bound]){
        NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
        [buf appendFormat:@"%@",_domain._low];
        return buf;
    }
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"(%@,%@)",_domain._low,_domain._up];
    return buf;
}
-(void) updateMin:(id<ORRational>)newMin for:(id<CPFloatVarRatNotifier>)x
{
   if([newMin gt: [self max]])
        failNow();
    updateMinR(&_domain, newMin, _trail);
   //id<ORRational> epsilon = [[ORRational alloc] init];
   //[epsilon set: 1 and: 1073741824];
   //ORBool isBound = [[_domain._up sub: _domain._low] lt: epsilon];
   //[epsilon release];
   ORBool isBound = [_domain._up eq: _domain._low];
    // cpjm: so that eo can use this method without propagation
    if (x != NULL) {
        [x changeMinEvtErr: isBound sender:self];
        if (isBound)
            [x bindEvtErr:self];
    }
}
-(void) updateMax:(id<ORRational>)newMax for:(id<CPFloatVarRatNotifier>)x
{
   if([[self min] gt: newMax])
        failNow();
    updateMaxR(&_domain, newMax, _trail);
//   id<ORRational> epsilon = [[ORRational alloc] init];
//   [epsilon set: 1 and: 1073741824];
//   ORBool isBound = [[_domain._up sub: _domain._low] lt: epsilon];
//   [epsilon release];   // cpjm: so that eo can use this method without propagation
   ORBool isBound = [_domain._up eq: _domain._low];
    if (x != NULL) {
        [x changeMaxEvtErr:isBound sender:self];
        if (isBound)
            [x bindEvtErr:self];
    }
}
-(void) updateInterval:(id<ORRationalInterval>)v for:(id<CPFloatVarRatNotifier>)x;
{
   [self updateMin:v.low for:x];
   [self updateMax:v.up for:x];
}

-(void) bind:(id<ORRational>)val  for:(id<CPFloatVarRatNotifier>)x
{
   if (([val gt: _domain._low] || [val eq: _domain._low]) && ([_domain._up gt: val] || [_domain._up eq:val])) {
        [x changeMinEvtErr:YES sender:self];
        [x changeMaxEvtErr:YES sender:self];
        [x bindEvtErr:self];
        updateTRRationalInterval(&_domain, val, val, _trail);
    }
    else
        failNow();
}
-(id<ORRational>) min
{
    return _domain._low;
}
-(id<ORRational>) max
{
    return _domain._up;
}
-(id<ORRational>) imin
{
    return _imin;
}
-(id<ORRational>) imax
{
    return _imax;
}
-(ORBool) bound
{
   /*id<ORRational> epsilon = [[ORRational alloc] init];
   [epsilon set:1 and:562949953421312];
   BOOL b = [[_domain._up sub: _domain._low] lt: epsilon];
   [epsilon release];
   return b;*/
   return [_domain._up eq: _domain._low];
}
-(ORInterval) bounds
{
    ORIReady();
    return createORI2([_domain._low get_d], [_domain._up get_d]);
}
-(TRRationalInterval) domain
{
    return _domain;
}

-(ORBool) member:(id<ORRational>)v
{
   return [_domain._low leq: v] && [v leq: _domain._up];
}
-(id) copy
{
    return [[CPRationalDom alloc] initCPRationalDom:_trail lowF:[_imin get_d] upF:[_imax get_d]];
}
-(void) restoreDomain:(id<CPRationalDom>)toRestore
{
    updateMinR(&_domain, toRestore.min, _trail);
    updateMaxR(&_domain, toRestore.max, _trail);
}
-(void) restoreValue:(id<ORRational>)toRestore for:(id<CPFloatVarRatNotifier>)x
{
    updateMinR(&_domain, toRestore, _trail);
    updateMaxR(&_domain, toRestore, _trail);
    [x bindEvtErr:self];
}

- (void) encodeWithCoder:(NSCoder *) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORRational) at:&_domain._low];
    [aCoder encodeValueOfObjCType:@encode(ORRational) at:&_domain._up];
    [aCoder encodeValueOfObjCType:@encode(ORRational) at:&_imin];
    [aCoder encodeValueOfObjCType:@encode(ORRational) at:&_imax];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
    self = [super init];
   id<ORRational> low = [[ORRational alloc] init];
   id<ORRational> up = [[ORRational alloc] init];
    [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&low];
    [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&up];
    _domain = makeTRRationalInterval(_trail, low, up);
   [low release];
   [up release];
    [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&_imin];
    [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&_imax];
    return self;
}
@end





