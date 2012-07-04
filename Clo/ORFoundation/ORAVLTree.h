/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORTypes.h"
//#import "ORData.h"

@protocol Position    
-(id)element;
@end

@class ORAVLTreeNode;

@protocol IntEnumerator <NSObject>
-(bool) more;
-(ORInt) next;
@end

@interface ORAVLTree : NSObject {
@private
    ORAVLTreeNode<Position>* _root;
}
-(ORAVLTree*)initEmptyAVL;
-(void)dealloc;
-(ORAVLTreeNode<Position>*)insertObject:(id)o forKey:(ORInt)k;
-(ORAVLTreeNode<Position>*)findNodeForKey:(ORInt)k;
-(id)findObjectForKey:(ORInt)k;
-(ORInt)size;
-(void)updateObject:(id)o forKey:(ORInt)k;
-(void)removeObjectForKey:(ORInt)k;
-(void)removeNode:(ORAVLTreeNode<Position>*)n;
-(NSEnumerator*)iterator;
@end

@interface ORAVLTreeKeyIntEnumerator : NSObject<IntEnumerator> {
    ORAVLTree* _theTree;
    ORAVLTreeNode* _cur; 
    ORInt*     _ra;
}
-(ORAVLTreeKeyIntEnumerator*) initORAVLTreeKeyIntEnumerator: (ORAVLTree*) tree;
-(ORInt) next;
-(BOOL) more;
@end
