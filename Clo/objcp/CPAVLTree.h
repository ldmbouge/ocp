/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPData.h"

@protocol Position    
-(id)element;
@end

@class CPAVLTreeNode;


@interface CPAVLTree : NSObject {
@private
    CPAVLTreeNode<Position>* _root;
}
-(CPAVLTree*)initEmptyAVL;
-(void)dealloc;
-(CPAVLTreeNode<Position>*)insertObject:(id)o forKey:(CPInt)k;
-(CPAVLTreeNode<Position>*)findNodeForKey:(CPInt)k;
-(id)findObjectForKey:(CPInt)k;
-(CPInt)size;
-(void)updateObject:(id)o forKey:(CPInt)k;
-(void)removeObjectForKey:(CPInt)k;
-(void)removeNode:(CPAVLTreeNode<Position>*)n;
-(NSEnumerator*)iterator;
@end

@interface CPAVLTreeKeyIntEnumerator : NSObject<IntEnumerator> {
    CPAVLTree* _theTree;
    CPAVLTreeNode* _cur; 
    CPInt*     _ra;
}
-(CPAVLTreeKeyIntEnumerator*) initCPAVLTreeKeyIntEnumerator: (CPAVLTree*) tree;
-(CPInt) next;
-(bool) more;
@end
