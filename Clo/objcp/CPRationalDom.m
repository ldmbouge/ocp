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

-(id)initCPRationalDom:(id<ORTrail>)trail low:(ORRational)low up:(ORRational)up
{
    self = [super init];
    _trail = trail;
    mpq_inits(_imin, _imax, NULL);
    mpq_set(_imin,low);
    mpq_set(_imax,up);
    _domain = makeTRRationalInterval(trail, _imin, _imax);
    return self;
}
-(id)initCPRationalDom:(id<ORTrail>)trail lowF:(ORDouble)low upF:(ORDouble)up
{
    self = [super init];
    _trail = trail;
    mpq_inits(_imin, _imax, NULL);
    mpq_set_d(_imin,low);
    mpq_set_d(_imax,up);
    _domain = makeTRRationalInterval(trail, _imin, _imax);
    return self;
}
-(id)initCPRationalDom:(id<ORTrail>)trail
{
   self = [self initCPRationalDom:trail lowF:-DBL_MAX upF:DBL_MAX];
   return self;
}
-(void) dealloc
{
   mpq_clears(_imin,_imax,NULL);
   [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
    return [[CPRationalDom allocWithZone:zone] initCPRationalDom:_trail lowF:mpq_get_d(_imin) upF:mpq_get_d(_imax)];
}
-(NSString*) description
{
    if([self bound]){
        unsigned int *inf;
        inf = (unsigned int *)&(_domain._low);
        NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
        [buf appendFormat:@"%20.20e [%4X]",mpq_get_d(_domain._low),*inf ];
        return buf;
    }
    unsigned int *inf;
    unsigned int *sup;
    inf = (unsigned int *)&(_domain._low);
    sup = (unsigned int *)&(_domain._up);
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"(%20.20e,%20.20e) hexa (%4X,%4X)",mpq_get_d(_domain._low),mpq_get_d(_domain._up),*inf,*sup];
    return buf;
}
-(void) updateMin:(ORRational)newMin for:(id<CPFVarNotifier>)x
{
    if(mpq_cmp(newMin, *[self max]) > 0)
        failNow();
    updateMinR(&_domain, newMin, _trail);
    ORBool isBound = (mpq_get_d(_domain._low) == mpq_get_d(_domain._up));
    // cpjm: so that eo can use this method without propagation
    if (x != NULL) {
        [x changeMinEvtErr: isBound sender:self];
        if (isBound)
            [x bindEvtErr:self];
    }
}
-(void) updateMax:(ORRational)newMax for:(id<CPFVarNotifier>)x
{
    if(mpq_cmp(*[self min], newMax) > 0)
        failNow();
    updateMaxR(&_domain, newMax, _trail);
    ORBool isBound = (mpq_get_d(_domain._low) == mpq_get_d(_domain._up));
    // cpjm: so that eo can use this method without propagation
    if (x != NULL) {
        [x changeMaxEvtErr:isBound sender:self];
        if (isBound)
            [x bindEvtErr:self];
    }
}
-(void) updateInterval:(rational_interval)v for:(id<CPFVarNotifier>)x;
{
    [self updateMin:v.inf for:x];
    [self updateMax:v.sup for:x];
}

-(void) bind:(ORRational)val  for:(id<CPFVarNotifier>)x
{
    if ((mpq_cmp(val, _domain._low) || mpq_equal(val, _domain._low)) && (mpq_cmp(_domain._up, val) || mpq_equal(_domain._up, val))) {
        [x changeMinEvtErr:YES sender:self];
        [x changeMaxEvtErr:YES sender:self];
        [x bindEvtErr:self];
        updateTRRationalInterval(&_domain, val, val, _trail);
    }
    else
        failNow();
}
-(ORRational*) min
{
    return &_domain._low;
}
-(ORRational*) max
{
    return &_domain._up;
}
-(ORRational*) imin
{
    return &_imin;
}
-(ORRational*) imax
{
    return &_imax;
}
-(ORBool) bound
{
    return (mpq_equal(_domain._up, _domain._low) != 0);
}
-(ORInterval) bounds
{
    ORIReady();
    return createORI2(mpq_get_d(_domain._low), mpq_get_d(_domain._up));
}
-(TRRationalInterval) domain
{
    return _domain;
}

-(ORBool) member:(ORRational)v
{
   return mpq_cmp(_domain._low, v) <= 0 && mpq_cmp(v, _domain._low) <= 0;
}
-(id) copy
{
    return [[CPRationalDom alloc] initCPRationalDom:_trail lowF:mpq_get_d(_imin) upF:mpq_get_d(_imax)];
}
-(void) restoreDomain:(id<CPRationalDom>)toRestore
{
    updateMinR(&_domain, *toRestore.min, _trail);
    updateMaxR(&_domain, *toRestore.max, _trail);
}
-(void) restoreValue:(ORRational)toRestore for:(id<CPFVarNotifier>)x
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
    ORRational low, up;
    [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&low];
    [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&up];
    _domain = makeTRRationalInterval(_trail, low, up);
    [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&_imin];
    [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&_imax];
    return self;
}
@end





