/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPSetI.h"
#import "CPAVLTree.h"
#import "CPFactoryI.h"
#import "CPError.h"

@implementation CPIntSetI 
-(id<CPIntSet>) initCPIntSetI: (id<CP>) cp
{
    self = [super init];
    _cp = cp;
    _avl = [[CPInternalFactory AVLTree: cp] retain];
    return self;
}
-(void) dealloc 
{
    [_avl release];
    [super dealloc];
}
-(bool) member: (CPInt) v
{
    return [_avl findNodeForKey:v] != NULL;
}
-(void) insert: (CPInt) v
{
    [_avl insertObject: NULL forKey:v];
}
-(void) delete: (CPInt) v
{
    [_avl removeObjectForKey: v];
}
-(CPInt) size
{
    return [_avl size];
}
-(NSString*) description
{
    return [_avl description];
}
-(id<CP>) cp
{
    return _cp;
}
-(id<IntEnumerator>) enumerator
{
    return [CPInternalFactory AVLTreeKeyIntEnumerator: _cp for: _avl];
}
- (void) encodeWithCoder:(NSCoder*) aCoder
{   
    [aCoder encodeObject:_cp];
    CPInt size = [_avl size];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&size];
    id<IntEnumerator> it = [self enumerator];
    while ([it more]) {
        CPInt e = [it next];
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&e];
    }   
}
- (id) initWithCoder:(NSCoder*) aDecoder
{
    self = [super init];
    _cp = [[aDecoder decodeObject] retain];
    _avl = [[CPInternalFactory AVLTree: _cp] retain];
    CPInt size;
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&size];
    for(CPInt i = 0; i < size; i++) {
        CPInt e;
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&e];
        [self insert: e];
    }
    return self;   
}
@end


