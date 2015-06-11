/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPTrailIntSet.h"
#import <ORFoundation/ORAVLTree.h>
#import <ORFoundation/ORData.h>

@implementation CPTrailIntSet {
   TRInt        _size;
   ORAVLTree*   _tree;
   id<ORTrail> _trail;
}

-(id)initWithSet:(id<ORIntSet>)theSource trail:(id<ORTrail>)t
{
   self = [super init];
   _trail = t;
   _size = makeTRInt(t, theSource ? [theSource size] : 0);
   _tree = [[[ORAVLTree alloc] initEmptyAVL] retain];
   if (theSource)
      [theSource enumerateWithBlock:^(ORInt v) {
         [_tree insertObject:nil forKey:v];
      }];
   return self;
}
-(void)dealloc
{
   [_tree release];
   [super dealloc];
}
-(void)enumerateWithBlock:(ORInt2Void)block
{
   [_tree iterateOverKey:block];
}
-(ORInt) size
{
   return _size._val;
}
-(ORInt) low
{
   id<Position> p = [_tree smallest:nil];
   assert(p);
   if (p)
      return p.key;
   else return FDMININT;
}
-(id<IntEnumerator>) enumerator
{
   return [[ORAVLTreeKeyIntEnumerator alloc] initORAVLTreeKeyIntEnumerator: _tree];
}
-(ORBool) member: (ORInt) v
{
   id<Position> p = [_tree findNodeForKey:v];
   return p != nil;
}
-(void) insert: (ORInt) v
{
   id<Position> p = [_tree findNodeForKey:v];
   if (p==nil) {
      ORAVLTreeNode<Position>* at = [_tree insertObject:nil forKey:v];
      assignTRInt(&_size, _size._val+1, _trail);
      [_trail trailClosure:^{
         [_tree removeNode:at];
      }];
   }
}
-(void) delete: (ORInt) v
{
   id<Position> p = [_tree findNodeForKey:v];
   if (p) {
      [_tree removeNode:p];
      assignTRInt(&_size, _size._val - 1, _trail);
      [_trail trailClosure:^{
         [_tree insertObject:nil forKey:v];
      }];
   }
}
-(ORInt) min
{
   id<Position> p = [_tree smallest:nil];
   assert(p);
   if (p)
      return p.key;
   else return FDMININT;   
}
-(ORInt) max
{
   id<Position> p = [_tree largest:nil];
   assert(p);
   if (p)
      return p.key;
   else return FDMAXINT;
}
-(ORInt) atRank:(ORInt)r
{
   id<Position> p = [_tree findNodeAtRank:r];
   assert(p);
   if (p)
      return p.key;
   else return -1;
}
-(NSString*) description
{
   return [_tree description];
}
-(void) copyInto: (id<ORIntSet>) S
{
   [_tree iterateOverKey:^(ORInt v) {
      [S insert:v];
   }];
}
-(id<ORIntSet>)inter:(id<ORIntSet>)s2
{
   id<ORIntSet> rv = [ORFactory intSet:nil];
   [self enumerateWithBlock:^(ORInt e) {
      if ([s2 member:e])
         [rv insert:e];
   }];
   return rv;
}
@end
