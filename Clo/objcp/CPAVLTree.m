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

#import "CPAVLTree.h"
#import "CPTypes.h"
#import "CPError.h"

@interface CPAVLTreeIterator : NSEnumerator {
   CPAVLTree* _theTree;
   CPAVLTreeNode* _cur;   
}
-(CPAVLTreeIterator*)initCPAVLTreeIterator:(CPAVLTree*)tree;
-(NSArray*)allObjects;
-(id)nextObject;
@end


@interface CPAVLTreeNode : NSObject<Position> {
@package
   CPAVLTreeNode* _parent;
   CPAVLTreeNode* _left;
   CPAVLTreeNode* _right;
   CPInt _height;
   CPInt _size;
   id  _data;
   CPInt _key;
}
-(CPAVLTreeNode<Position>*)initAVLTreeNode:(CPInt)key object:(id)o;
-(void)dealloc;
-(bool)balanced;
-(void)fixSize;
-(void)fixHeight;
@end

#define LEFTHEIGHT(n)  ((n)->_left  ? (n)->_left->_height : 0L)
#define RIGHTHEIGHT(n) ((n)->_right ? (n)->_right->_height : 0l)
#define LEFTSIZE(n) ((n)->_left ? (n)->_left->_size : 0)
#define RIGHTSIZE(n) ((n)->_right ? (n)->_right->_size : 0)


@implementation CPAVLTreeNode
-(CPAVLTreeNode*)initAVLTreeNode:(CPInt)key object:(id)o
{
   self = [super init];
   _parent = 0;
   _left = _right = 0;
   _height = 0;
   _size   = 0;
   _data   = [o retain];
   _key    = key;
   return self;
}
-(void)dealloc
{
   [_left release];
   [_right release];
   [_data release];
   [super dealloc];
}
-(bool)balanced 
{
   CPInt bal = LEFTHEIGHT(self) - RIGHTHEIGHT(self);
   return -1 <= bal && bal <= 1;
}
-(void)fixSize
{
   _size = LEFTSIZE(self) + RIGHTSIZE(self) + 1;
}
-(void)fixHeight
{
   _height = maxOf(LEFTHEIGHT(self),RIGHTHEIGHT(self))+1;
}
-(CPAVLTreeNode<Position>*)tallest
{
   if (LEFTHEIGHT(self) > RIGHTHEIGHT(self))
       return _left;
   else 
       return _right;
}
-(id)element
{
   return _data;
}
@end

@implementation CPAVLTree

-(CPAVLTree*)initEmptyAVL
{
   self = [super init];
   _root = nil;
   return self;
}
-(void)dealloc
{
   [_root release];
   [super dealloc];
}

static inline void leftRotate(CPAVLTree* t,CPAVLTreeNode* z)
{
   CPAVLTreeNode* y = z->_right;
   z->_right = y->_left;
   if (y->_left)
       y->_left->_parent = z;
   y->_parent = z->_parent;
   z->_parent = y;
   y->_left = z;
   if (y->_parent == 0)
       t->_root = y;
   else if (y->_parent->_right == z)
       y->_parent->_right = y;
   else 
       y->_parent->_left = y;      
}

static inline void rightRotate(CPAVLTree* t,CPAVLTreeNode* z)
{
   CPAVLTreeNode* y = z->_left;
   z->_left = y->_right;
   if (y->_right)
      y->_right->_parent = z;
   y->_parent = z->_parent;
   z->_parent = y;
   y->_right  = z;
   if (y->_parent == 0)
      t->_root = y;
   else if (y->_parent->_right == z)
      y->_parent->_right = y;
   else
       y->_parent->_left = y;   
}

-(void)reBalance:(CPAVLTreeNode*)high
{
   do {
      [high fixHeight];
      [high fixSize];
      if (![high balanced]) {
         CPAVLTreeNode* z = high;
         CPAVLTreeNode* y = [z tallest];
         CPAVLTreeNode* x = [y tallest];
         CPAVLTreeNode* nr;
         if (z->_right == y) {
            if (y->_right == x) { // right-right
               leftRotate(self,z);
               nr = y;
            } else { //right-left
               rightRotate(self,y);
               leftRotate(self,z);
               nr = x;
            }
         } else {
            if (y->_right == x) { // left-right
               leftRotate(self,y);
               rightRotate(self,z);
               nr = x;
            } else { // left-left
               rightRotate(self,z);
               nr = y;
            }
         }
         if (nr->_left)  { [nr->_left fixHeight];[nr->_left fixSize];}
         if (nr->_right) { [nr->_right fixHeight];[nr->_right fixSize];}
         [nr fixHeight];
         [nr fixSize];
      }
      high = high->_parent;
   } while (high);   
}

-(CPAVLTreeNode<Position>*)insertObject:(id)o forKey:(CPInt)k
{
   CPAVLTreeNode*  par = 0;
   CPAVLTreeNode** cur = &_root;
   while(*cur) {
      par = *cur;
      if (k < (*cur)->_key) 
         cur = &(*cur)->_left;
      else if (k > (*cur)->_key) 
         cur = &(*cur)->_right;
      else return *cur;
   }
   CPAVLTreeNode* retVal = [[CPAVLTreeNode alloc] initAVLTreeNode:k 
                                                           object:o];
   *cur = retVal;
   (*cur)->_parent = par;
   [self reBalance: *cur];
   return retVal;   
}
-(CPAVLTreeNode<Position>*)findNodeForKey:(CPInt)k
{
   CPAVLTreeNode* cur = _root;
   while (cur) {
      if (k < cur->_key)
         cur = cur->_left;
      else if (k > cur->_key)
         cur = cur->_right;
      else return cur;
   }
   return nil;
}
-(id)findObjectForKey:(CPInt)k
{
   CPAVLTreeNode* nd = [self findNodeForKey:k];
   return nd ? nd->_data : nil;
}
-(CPInt)size
{
   return _root ? _root->_size : 0;
}
-(void)updateObject:(id)o forKey:(CPInt)k
{
   CPAVLTreeNode* nd = [self findNodeForKey:k];
   if (nd) {
      [nd->_data release];
      nd->_data = [o retain];
   }
}
-(void)removeObjectForKey:(CPInt)k
{
   CPAVLTreeNode* togo = [self findNodeForKey:k];
   [self removeNode:togo];
}
-(void)removeNode:(CPAVLTreeNode<Position>*)togo
{
   CPAVLTreeNode* splice = 0;
   if (togo) {
      if (togo->_left==0 || togo->_right==0) {
         splice = togo;
         CPAVLTreeNode* child = splice->_left ? splice->_left : splice->_right;
         CPAVLTreeNode* from = child ? child : ( splice->_parent ? splice->_parent : 0);
         if (splice->_parent==0) {              
            _root = child;
            if (child) child->_parent = 0;
         } else {
            if (splice->_parent->_left == splice)
               splice->_parent->_left = child;
            else splice->_parent->_right = child;
            if (child) child->_parent = splice->_parent;
         }
         splice->_left = splice->_right = splice->_parent = 0;
         [splice release];
         if (from) [self reBalance: from];
      } else {
         splice = togo->_right;
         while (splice->_left) splice = splice->_left;
         
         CPAVLTreeNode* child = splice->_left ? splice->_left : splice->_right;
         CPAVLTreeNode* from = child ? child : ( splice->_parent ? splice->_parent : 0);
         
         if (splice->_parent==0) {              
            _root = child;
            if (child) child->_parent = 0;
         } else {
            if (splice->_parent->_left == splice)
               splice->_parent->_left = child;
            else splice->_parent->_right = child;
            if (child) 
               child->_parent = splice->_parent;
         }
         splice->_left = splice->_right = splice->_parent = 0;
         togo->_key = splice->_key;
         togo->_data = splice->_data;
         [splice release];
         if (from) [self reBalance:from];
      }
   }   
}
-(CPAVLTreeNode*)smallest:(CPAVLTreeNode*)x
{
   if (x== 0) x = _root;
   while (x && x->_left != 0)
      x = x->_left;
   return x;
}
-(CPAVLTreeNode*)largest:(CPAVLTreeNode*)x
{
   if (x==0) x = _root;
   while (x && x->_right != 0)
      x = x->_right;
   return x;
}
-(CPAVLTreeNode*)findSucc:(CPAVLTreeNode*)x
{
   if (x) {
      if (x->_right) {
         return [self smallest:x->_right];
      } else {
         CPAVLTreeNode* y = x->_parent;
         while(y != 0 && x == y->_right) {
            x = y;
            y = y->_parent;
         }
         return y;
      }
   } else return 0;
}
-(CPAVLTreeNode*)findPred:(CPAVLTreeNode*)x
{
   if (x) {
      if (x->_left) {
         return [self largest:x->_left];
      } else {
         CPAVLTreeNode* y = x->_parent;
         while(y != 0 && x == y->_left) {
            x = y;
            y = y->_parent;
         }
         return y;
      }
   } else return 0;
}
-(NSEnumerator*)iterator
{
   return [[[CPAVLTreeIterator alloc] init] autorelease];
}
-(NSString*)description
{
   CPAVLTreeNode* from = [self smallest:_root];
   NSMutableString* str = [NSMutableString stringWithCapacity:128];
   [str appendString:@"{"];
   while(from) {
       [str appendFormat:@"%d:",from->_key];
       if (from->_data)
           [str appendString:[from->_data description]];
      from = [self findSucc:from];
      if (from)
         [str appendString:@","];
   }
   [str appendString:@"}"];
   return str;
}
@end

@implementation CPAVLTreeIterator

-(CPAVLTreeIterator*) initCPAVLTreeIterator:(CPAVLTree*)tree
{
   self = [super init];
   _theTree = [tree retain];
   _cur = [_theTree smallest:nil];
   return self;
}
-(void)dealloc 
{
   [_theTree release];
   [super dealloc];
}
-(NSArray*)allObjects
{
   CPInt sz = [_theTree size];
   NSMutableArray* rv = [NSMutableArray arrayWithCapacity:sz];
   CPAVLTreeNode* from = [_theTree smallest:nil];
   while (from) {
      id elem = from->_data;
      [rv addObject:elem];
      from = [_theTree findSucc:from];
   }
   return rv;
}
-(id)nextObject
{
   if (_cur) {
      id rv = _cur->_data;
      _cur = [_theTree findSucc:_cur];
      return rv;
   } else return nil;
}

@end

@implementation CPAVLTreeKeyIntEnumerator

-(CPAVLTreeKeyIntEnumerator*) initCPAVLTreeKeyIntEnumerator: (CPAVLTree*) tree
{
    self = [super init];
    _theTree = [tree retain];
    _cur = [_theTree smallest:nil];
    return self;
}
-(void) dealloc 
{
    [_theTree release];
    [super dealloc];
}
-(bool) more
{
    return (_cur != NULL);
}
-(CPInt) next
{
    if (_cur) {
        CPInt rv = _cur->_key;
        _cur = [_theTree findSucc:_cur];
        return rv;
    } 
    else 
        @throw [[CPExecutionError alloc] initCPExecutionError: "No next element in the iterator"]; ;
}

@end
