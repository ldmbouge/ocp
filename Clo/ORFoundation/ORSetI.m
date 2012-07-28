/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORSetI.h"
#import "ORFoundation/ORAVLTree.h"
#import "ORFactoryI.h"
#import "ORError.h"

@implementation ORIntSetI 
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
-(bool) member: (ORInt) v
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
-(ORInt) size
{
    return [_avl size];
}
-(void) iterate: (ORInt2Void) f
{
   [_avl iterateOverKey: f];
}
-(NSString*) description
{
    return [_avl description];
}
-(id<IntEnumerator>) enumerator
{
   return [ORInternalFactory AVLTreeKeyIntEnumerator: _avl];
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


@interface ORIntRangeEnumerator : NSObject<IntEnumerator>
-(ORIntRangeEnumerator*) initORIntRangeEnumerator: (ORInt) low up: (ORInt) up;
-(ORInt) next;
-(BOOL) more;
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
   [super dealloc];
}
-(ORInt) next
{
   return ++_i;
}
-(BOOL) more
{
   return (_i < _up);
}
@end


@implementation ORIntRangeI
{
   ORInt _low;
   ORInt _up;
}
-(id<ORIntRange>) initORIntRangeI: (ORInt) low up: (ORInt) up
{
   self = [super init];
   _low = low;
   _up = up;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) low
{
   return _low;
}
-(ORInt) up
{
   return _up;
}
-(ORInt) size
{
   return (_up - _low + 1);
}
-(void) iterate: (ORInt2Void) f
{
   for(ORInt i = _low; i <= _up; i++)
      f(i);
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"[%d,%d]",_low,_up];
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


