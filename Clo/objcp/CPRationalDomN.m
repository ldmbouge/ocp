//
//  CPRationalDomN.m
//  objcp
//
//  Created by Rémy Garcia on 04/07/2018.
//
#import <ORFoundation/ORFoundation.h>
#import "CPRationalDomN.h"
//#import "CPEngineI.h"
#import "CPRationalVarI.h"

@implementation CPRationalDomN

-(id)initCPRationalDom:(id<ORTrail>)trail low:(ORRational)low up:(ORRational)up
{
   self = [super init];
   _trail = trail;
   rational_init(&_imin);
   rational_init(&_imax);
   rational_set(&_imin,&low);
   rational_set(&_imax,&up);
   _domain = makeTRRationalInterval(trail, _imin, _imax);
   return self;
}
-(id)initCPRationalDom:(id<ORTrail>)trail lowF:(ORDouble)low upF:(ORDouble)up
{
   self = [super init];
   _trail = trail;
   rational_init(&_imin);
   rational_init(&_imax);
   rational_set_d(&_imin,low);
   rational_set_d(&_imax,up);
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
   rational_clear(&_imin);
   rational_clear(&_imax);
   [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
   return [[CPRationalDomN allocWithZone:zone] initCPRationalDom:_trail low:_imin up:_imax];
}
-(NSString*) description
{
   if([self bound]){
      unsigned int *inf;
      inf = (unsigned int *)&(_domain._low);
      NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
      [buf appendFormat:@"%20.20e [%4X]",rational_get_d(&_domain._low),*inf ];
      return buf;
   }
   unsigned int *inf;
   unsigned int *sup;
   inf = (unsigned int *)&(_domain._low);
   sup = (unsigned int *)&(_domain._up);
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"(%20.20e,%20.20e) hexa (%4X,%4X)",rational_get_d(&_domain._low),rational_get_d(&_domain._up),*inf,*sup];
   return buf;
}
-(void) updateMin:(ORRational)newMin for:(id<CPRationalVarNotifier>)x
{
   ORRational max = [self max];
   if(rational_cmp(&newMin, &max) > 0)
      failNow();
   updateMinR(&_domain, newMin, _trail);
   ORBool isBound = (rational_get_d(&_domain._low) == rational_get_d(&_domain._up));
   // cpjm: so that eo can use this method without propagation
   if (x != NULL) {
      [x changeMinEvt: isBound sender:self];
      if (isBound)
         [x bindEvt:self];
   }
}
-(void) updateMax:(ORRational)newMax for:(id<CPRationalVarNotifier>)x
{
   ORRational min = [self min];
   if(rational_cmp(&min, &newMax) > 0)
      failNow();
   updateMaxR(&_domain, newMax, _trail);
   ORBool isBound = (rational_get_d(&_domain._low) == rational_get_d(&_domain._up));
   // cpjm: so that eo can use this method without propagation
   if (x != NULL) {
      [x changeMaxEvt:isBound sender:self];
      if (isBound)
         [x bindEvt:self];
   }
}
-(void) updateInterval:(ri)v for:(id<CPRationalVarNotifier>)x;
{
   [self updateMin:v.inf for:x];
   [self updateMax:v.sup for:x];
}

-(void) bind:(ORRational)val  for:(id<CPRationalVarNotifier>)x
{
   if ((rational_cmp(&val, &_domain._low) || rational_eq(&val, &_domain._low)) && (rational_cmp(&_domain._up, &val) || rational_eq(&_domain._up, &val))) {
      [x changeMinEvt:YES sender:self];
      [x changeMaxEvt:YES sender:self];
      [x bindEvt:self];
      updateTRRationalInterval(&_domain, val, val, _trail);
   }
   else
      failNow();
}
-(ORRational) min
{
   return _domain._low;
}
-(ORRational) max
{
   return _domain._up;
}
-(ORRational) imin
{
   return _imin;
}
-(ORRational) imax
{
   return _imax;
}
-(ORBool) bound
{
   return (rational_eq(&_domain._up, &_domain._low) != 0);
}
-(ORInterval) bounds
{
   ORIReady();
   return createORI2(rational_get_d(&_domain._low), rational_get_d(&_domain._up));
}
-(TRRationalInterval) domain
{
   return _domain;
}

-(ORBool) member:(ORRational)v
{
   return rational_cmp(&_domain._low, &v) <= 0 && rational_cmp(&v, &_domain._low) <= 0;
}
-(id) copy
{
   return [[CPRationalDomN alloc] initCPRationalDom:_trail lowF:rational_get_d(&_imin) upF:rational_get_d(&_imax)];
}
-(void) restoreDomain:(id<CPRationalDom>)toRestore
{
   updateMinR(&_domain, toRestore.min, _trail);
   updateMaxR(&_domain, toRestore.max, _trail);
}
-(void) restoreValue:(ORRational)toRestore for:(id<CPRationalVarNotifier>)x
{
   updateMinR(&_domain, toRestore, _trail);
   updateMaxR(&_domain, toRestore, _trail);
   [x bindEvt:self];
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





