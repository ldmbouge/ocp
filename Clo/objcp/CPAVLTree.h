/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
