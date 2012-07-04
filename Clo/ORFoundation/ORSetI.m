/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORSetI.h"
#import "ORFoundation/ORAVLTree.h"
#import "CPFactoryI.h"
#import "CPError.h"

@implementation ORIntSetI 
-(id<ORIntSet>) initORIntSetI
{
    self = [super init];
    _avl = [[CPInternalFactory AVLTree] retain];
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
-(NSString*) description
{
    return [_avl description];
}
-(id<IntEnumerator>) enumerator
{
   return [CPInternalFactory AVLTreeKeyIntEnumerator: _avl];
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
    _avl = [[CPInternalFactory AVLTree] retain];
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


