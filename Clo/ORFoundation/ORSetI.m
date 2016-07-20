/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#if defined(__APPLE__)
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#endif
#import "ORFactoryI.h"

@implementation ORIntSetI
{
   ORAVLTree*     _avl;
}
-(id<ORIntSet>) initORIntSetI
{
    self = [super init];
    _avl = [[ORInternalFactory AVLTree] retain];
    return self;
}
-(void) dealloc
{
    [_avl release];
    [super dealloc];
}
-(ORBool) member: (ORInt) v
{
    return [_avl findNodeForKey:v] != NULL;
}
-(void) insert: (ORInt) v
{
    [_avl insertObject: NULL forKey:v];
}
-(void) delete: (ORInt) v
{
    [_avl removeObjectForKey: v];
}
-(ORInt) low
{
   return [self min];
}

-(ORInt) min
{
    __block ORInt value = MAXINT;
    [self enumerateWithBlock:^(ORInt e) { if(e < value) value = e; }];
    return value;
}
-(ORInt) max
{
    __block ORInt value = MININT;
    [self enumerateWithBlock:^(ORInt e) { if(e > value) value = e; }];
    return value;
}
-(ORInt) atRank:(ORInt)r
{
   ORAVLTreeNode<Position>* nd = [_avl findNodeAtRank:r];
   if (nd)
      return [nd key];
   else
      return [self min] - 1;
}

-(id<ORIntSet>)inter:(id<ORIntSet>)s2
{
   id<ORIntSet> rv = [[ORIntSetI alloc] initORIntSetI];
   [self enumerateWithBlock:^(ORInt e) {
      if ([s2 member:e])
         [rv insert:e];
   }];
   return rv;
}

-(ORInt) size
{
    return [_avl size];
}
-(void) enumerateWithBlock:(ORInt2Void) f
{
   [_avl iterateOverKey: f];
}
-(void) copyInto: (id<ORIntSet>) S
{
   [self enumerateWithBlock:^(ORInt e) { [S insert: e]; } ];
}
-(NSString*) description
{
    return [_avl description];
}
-(id<IntEnumerator>) enumerator
{
   return [ORInternalFactory AVLTreeKeyIntEnumerator: _avl];
}
-(void)visit: (ORVisitor*) v
{
   [v visitIntSet:self];
}
- (void) encodeWithCoder:(NSCoder*) aCoder
{   
    ORInt size = [_avl size];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&size];
    id<IntEnumerator> it = [self enumerator];
    while ([it more]) {
        ORInt e = [it next];
        [aCoder encodeValueOfObjCType:@encode(ORInt) at:&e];
    }   
}
- (id) initWithCoder:(NSCoder*) aDecoder
{
    self = [super init];
    _avl = [[ORInternalFactory AVLTree] retain];
    ORInt size;
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&size];
    for(ORInt i = 0; i < size; i++) {
        ORInt e;
        [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&e];
        [self insert: e];
    }
    return self;   
}
@end


@interface ORIntRangeEnumerator : ORObject<IntEnumerator>
-(ORIntRangeEnumerator*) initORIntRangeEnumerator: (ORInt) low up: (ORInt) up;
-(ORInt) next;
-(ORBool) more;
@end

@interface ORTrailIableIntRangeEnumerator : NSObject<IntEnumerator>
-(ORTrailIableIntRangeEnumerator*) initORTrailIableIntRangeEnumerator: (id<ORTracker>) track low: (ORInt) low up: (ORInt) up;
-(ORInt) next;
-(ORBool) more;
@end

@implementation ORIntRangeEnumerator {
   ORInt _low;
   ORInt _up;
   ORInt _i;
}
-(ORIntRangeEnumerator*) initORIntRangeEnumerator: (ORInt) low up: (ORInt) up
{
   self = [super init];
   _low = low;
   _up = up;
   _i = _low - 1;
   return self;
}
-(void)dealloc
{
   //NSLog(@"ORIntRangeEnumerator dealloc (%p)...",self);
   [super dealloc];
}
-(ORInt) next
{
   return ++_i;
}
-(ORBool) more
{
   return (_i < _up);
}
@end


@implementation ORIntRangeI 
-(id<ORIntRange>) initORIntRangeI: (ORInt) low up: (ORInt) up
{
   self = [super init];
   _low = low;
   _up = up;
   return self;
}
-(id)copyWithZone:(NSZone *)zone
{
   return [[ORIntRangeI allocWithZone:zone] initORIntRangeI:_low up:_up];
}
-(BOOL)isEqual:(id)object
{
   if (self == object)
      return YES;
   if (object_getClass(self) != object_getClass(object))
      return NO;
   return _low == ((ORIntRangeI*)object)->_low && _up == ((ORIntRangeI*)object)->_up;
}
-(NSUInteger)hash
{
   return _low ^ _up;
}
-(ORInt) low
{
   return _low;
}
-(ORInt) up
{
   return _up;
}
-(ORBool) isBool
{
   return _low == 0 && _up == 1;
}
-(ORBool) isDefined
{
    return _low <= _up;
}
-(ORBool) inRange: (ORInt)e
{
    return e >= _low && e <= _up;
}
-(ORInt) size
{
   return (_up - _low + 1);
}
-(ORInt) atRank:(ORInt)r
{
   return _low + r;
}
-(void)enumerateWithBlock:(void(^)(ORInt))block
{
   for(ORInt i = _low; i <= _up; i++)
      block(i);
}
-(void)visit:(ORVisitor*)v
{
   [v visitIntRange:self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"[%2d,%2d]",_low,_up];
   return rv;
}
-(id<IntEnumerator>) enumerator
{
   return [[ORIntRangeEnumerator alloc] initORIntRangeEnumerator: _low up:_up];
}
- (void) encodeWithCoder:(NSCoder*) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up];
}
- (id) initWithCoder:(NSCoder*) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up];
   return self;
}
@end

@implementation ORRealRangeI {
   ORDouble _low;
   ORDouble _up;
}
-(id<ORRealRange>)init:(ORDouble) low up:(ORDouble)up
{
   self = [super init];
   _low = low;
   _up  = up;
   return self;
}
-(id)copyWithZone:(NSZone *)zone
{
   return [[ORRealRangeI allocWithZone:zone] init:_low up:_up];
}
-(BOOL)isEqual:(id)object
{
   if ([object isKindOfClass:[self class]])
      return _low == ((ORRealRangeI*)object)->_low && _up == ((ORRealRangeI*)object)->_up;
   else return NO;
}
-(NSUInteger)hash
{
   return (NSUInteger)_low ^ (NSUInteger)_up;
}
-(ORDouble)low
{
   return _low;
}
-(ORDouble)up
{
   return _up;
}
-(ORBool) isDefined
{
   return _low <= _up;
}
-(ORBool)inRange:(ORDouble)e
{
   return _low <= e && e <= _up;
}
-(NSString*)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   if (_low <= -FLT_MAX && _up >= FLT_MAX)
      [rv appendFormat:@"[-inf,+inf]"];
   else if (_low <= -FLT_MAX)
      [rv appendFormat:@"[-inf,%lf]",_up];
   else if (_up >= FLT_MAX)
      [rv appendFormat:@"[%lf,+inf]",_low];
   else
      [rv appendFormat:@"[%lf,%lf]",_low,_up];

   return rv;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRealRange:self];
}
- (void) encodeWithCoder:(NSCoder*) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_low];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_up];
}
- (id) initWithCoder:(NSCoder*) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_low];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_up];
   return self;
}
@end


//-------------------------------------------------
//ORFLOATRange
//-------------------------------------------------

@implementation ORFloatRangeI {
    ORFloat _low;
    ORFloat _up;
}
-(id<ORFloatRange>)init:(ORFloat) low up:(ORFloat)up
{
    self = [super init];
    _low = low;
    _up  = up;
    return self;
}
-(id)copyWithZone:(NSZone *)zone
{
    return [[ORFloatRangeI allocWithZone:zone] init:_low up:_up];
}
-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
        return _low == ((ORFloatRangeI*)object)->_low && _up == ((ORFloatRangeI*)object)->_up;
    else return NO;
}
-(NSUInteger)hash
{
    return (NSUInteger)_low ^ (NSUInteger)_up;
}
-(ORFloat)low
{
    return _low;
}
-(ORFloat)up
{
    return _up;
}
-(ORBool) isDefined
{
    return _low <= _up;
}
-(ORBool)inRange:(ORFloat)e
{
    return _low <= e && e <= _up;
}
-(NSString*)description
{
    NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [rv appendFormat:@"[%lf,%lf]",_low,_up];
    return rv;
}
-(void)visit:(ORVisitor*)v
{
    [v visitFloatRange:self];
}
- (void) encodeWithCoder:(NSCoder*) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_low];
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_up];
}
- (id) initWithCoder:(NSCoder*) aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_low];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_up];
    return self;
}
@end
//----------------

//-------------------------------------------------
//ORDOUBLERange
//-------------------------------------------------

@implementation ORDoubleRangeI {
    ORDouble _low;
    ORDouble _up;
}
-(id<ORDoubleRange>)init:(ORDouble) low up:(ORDouble)up
{
    self = [super init];
    _low = low;
    _up  = up;
    return self;
}
-(id)copyWithZone:(NSZone *)zone
{
    return [[ORDoubleRangeI allocWithZone:zone] init:_low up:_up];
}
-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
        return _low == ((ORDoubleRangeI*)object)->_low && _up == ((ORDoubleRangeI*)object)->_up;
    else return NO;
}
-(NSUInteger)hash
{
    return (NSUInteger)_low ^ (NSUInteger)_up;
}
-(ORDouble)low
{
    return _low;
}
-(ORDouble)up
{
    return _up;
}
-(ORBool) isDefined
{
    return _low <= _up;
}
-(ORBool)inRange:(ORDouble)e
{
    return _low <= e && e <= _up;
}
-(NSString*)description
{
    NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [rv appendFormat:@"[%lf,%lf]",_low,_up];
    return rv;
}
-(void)visit:(ORVisitor*)v
{
    [v visitDoubleRange:self];
}
- (void) encodeWithCoder:(NSCoder*) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_low];
    [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_up];
}
- (id) initWithCoder:(NSCoder*) aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_low];
    [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_up];
    return self;
}
@end
//----------------

//-------------------------------------------------
//ORLDOUBLERange
//-------------------------------------------------

@implementation ORLDoubleRangeI {
    ORLDouble _low;
    ORLDouble _up;
}
-(id<ORLDoubleRange>)init:(ORLDouble) low up:(ORLDouble)up
{
    self = [super init];
    _low = low;
    _up  = up;
    return self;
}
-(id)copyWithZone:(NSZone *)zone
{
    return [[ORLDoubleRangeI allocWithZone:zone] init:_low up:_up];
}
-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
        return _low == ((ORLDoubleRangeI*)object)->_low && _up == ((ORLDoubleRangeI*)object)->_up;
    else return NO;
}
-(NSUInteger)hash
{
    return (NSUInteger)_low ^ (NSUInteger)_up;
}
-(ORLDouble)low
{
    return _low;
}
-(ORLDouble)up
{
    return _up;
}
-(ORBool) isDefined
{
    return _low <= _up;
}
-(ORBool)inRange:(ORLDouble)e
{
    return _low <= e && e <= _up;
}
-(NSString*)description
{
    NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [rv appendFormat:@"[%Lf,%Lf]",_low,_up];
    return rv;
}
-(void)visit:(ORVisitor*)v
{
    [v visitLDoubleRange:self];
}
- (void) encodeWithCoder:(NSCoder*) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORLDouble) at:&_low];
    [aCoder encodeValueOfObjCType:@encode(ORLDouble) at:&_up];
}
- (id) initWithCoder:(NSCoder*) aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORLDouble) at:&_low];
    [aDecoder decodeValueOfObjCType:@encode(ORLDouble) at:&_up];
    return self;
}
@end
//----------------



id<ORIntSet> filterSet(id<ORTracker> t,id<ORIntIterable> s,ORBool(^cond)(ORInt i))
{
   id<ORIntSet> sub = [ORFactory intSet:t];
   [s enumerateWithBlock:^(ORInt i) {
      if (cond(i))
         [sub insert:i];
   }];
   return sub;
}

ORInt sumSet(id<ORIntIterable> s,ORInt(^term)(ORInt i))
{
   ORInt __block ttl = 0;
   [s enumerateWithBlock:^(ORInt i) {
      ttl += term(i);
   }];
   return ttl;
}
