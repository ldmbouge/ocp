/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORUtilities/ORTypes.h"

@protocol Position    
-(id)element;
@end

@class ORAVLTreeNode;


@interface ORAVLTree : NSObject
-(ORAVLTree*)initEmptyAVL;
-(void)dealloc;
-(ORAVLTreeNode<Position>*) insertObject:(id)o forKey:(ORInt)k;
-(ORAVLTreeNode<Position>*) findNodeForKey:(ORInt)k;
-(id)findObjectForKey:(ORInt)k;
-(ORInt)size;
-(void) iterateOverKey: (ORInt2Void) f;
-(void) updateObject:(id)o forKey:(ORInt)k;
-(void) removeObjectForKey:(ORInt) k;
-(void) removeNode:(ORAVLTreeNode<Position>*)n;
-(NSEnumerator*)iterator;
@end

@interface ORAVLTreeKeyIntEnumerator : NSObject<IntEnumerator>
-(ORAVLTreeKeyIntEnumerator*) initORAVLTreeKeyIntEnumerator: (ORAVLTree*) tree;
-(ORInt) next;
-(ORBool)  more;
@end
