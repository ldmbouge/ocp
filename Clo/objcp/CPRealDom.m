/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPRealDom.h"
//#import "CPEngineI.h"
#import "CPError.h"
#import "CPRealVarI.h"

#define BIND_EPSILON (0.0000001)
#define TOLERANCE    (0.0000001)

@implementation CPRealDom

-(id)initCPRealDom:(id<ORTrail>)trail low:(ORDouble)low up:(ORDouble)up
{
   self = [super init];
   _trail = trail;
   _imin = low;
   _imax = up;
   _min = makeTRDouble(_trail, _imin);
   _max = makeTRDouble(_trail, _imax);
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   return [[CPRealDom allocWithZone:zone] initCPRealDom:_trail low:_imin up:_imax];
}
-(NSString*) description
{
   ORIReady();
   return ORIFormat(createORI2(_min._val, _max._val));
}
-(void) updateMin:(ORDouble)newMin for:(id<CPRealVarNotifier>)x
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
   assignTRDouble(&_min, newMin, _trail);
   ORIReady();
   ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
   [x changeMinEvt: isBound sender:self];
   if (isBound)
      [x bindEvt:self];
}
-(void) updateMax:(ORDouble)newMax for:(id<CPRealVarNotifier>)x
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
   assignTRDouble(&_max, newMax, _trail);
   ORIReady();
   ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
   [x changeMaxEvt:isBound sender:self];
   if (isBound)
      [x bindEvt:self];
}
-(ORNarrowing) updateInterval: (ORInterval) v for: (id<CPRealVarNotifier>) x
{
   ORIReady();
   ORInterval src= createORI2(_min._val, _max._val);
   ORInterval is = ORIInter(src, v);
   if (ORIEmpty(is))
      failNow();
   switch (ORINarrow(src, is)) {
      case ORBoth:
      {
         ORDouble nl,nu;
         ORIBounds(is, &nl, &nu);
         assignTRDouble(&_min, nl, _trail);
         assignTRDouble(&_max, nu, _trail);
         ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
         [x changeMinEvt:isBound sender:self];
         [x changeMaxEvt:isBound sender:self];
         if (isBound)
            [x bindEvt:self];
         return ORBoth;
      }break;
      case ORLow:
      {
         ORDouble nl = ORILow(is);
         assignTRDouble(&_min, nl, _trail);
         ORBool isBound = ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
         [x changeMinEvt:isBound sender:self];
         if (isBound)
            [x bindEvt:self];
         return ORLow;
      }break;
      case ORUp:
      {
         ORDouble nu = ORIUp(is);
         assignTRDouble(&_max, nu, _trail);
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

-(void) bind:(ORDouble)val  for:(id<CPRealVarNotifier>)x
{
   ORIReady();
   if (_min._val <= val && val <= _max._val) {
      if (ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON))
         return;
      [x changeMinEvt:YES sender:self];
      [x changeMaxEvt:YES sender:self];
      [x bindEvt:self];
      assignTRDouble(&_min, val, _trail);
      assignTRDouble(&_max, val, _trail);
   }
   else
      failNow();
}
-(ORDouble) min
{
   return _min._val;
}
-(ORDouble) max
{
   return _max._val;
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
   ORIReady();
   return ORIBound(createORI2(_min._val, _max._val), BIND_EPSILON);
}
-(ORInterval) bounds
{
   ORIReady();
   return createORI2(_min._val, _max._val);
}
-(ORDouble) domwidth
{
   ORIReady();
   return ORIWidth(createORI2(_min._val, _max._val));
}
-(ORBool) member:(ORDouble)v
{
   return _min._val <= v && v <= _max._val;
}
-(id) copy
{
   return [[CPRealDom alloc] initCPRealDom:_trail low:_imin up:_imax];
}
-(void) restoreDomain:(id<CPFDom>)toRestore
{
   _min._val = [toRestore min];
   _max._val = [toRestore max];
}
-(void) restoreValue:(ORDouble)toRestore for:(id<CPRealVarNotifier>)x
{
   _min._val = _max._val = toRestore;
   [x bindEvt:self];
}

- (void) encodeWithCoder:(NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_min._val];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_max._val];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_imin];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_imax];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_min._val];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_max._val];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_imin];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_imax];
   return self;
}
- (void)unionWith:(id<CPFDom>)d
{
   assignTRDouble(&_min,min(_min._val,d.min),_trail);
   assignTRDouble(&_max,max(_max._val,d.max),_trail);
}

@end
