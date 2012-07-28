/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORAVLTree.h"
#import "ORTypes.h"
#import "ORError.h"

@interface ORAVLTreeIterator : NSEnumerator {
   ORAVLTree* _theTree;
   ORAVLTreeNode* _cur;   
}
-(ORAVLTreeIterator*)initORAVLTreeIterator:(ORAVLTree*)tree;
-(NSArray*)allObjects;
-(id)nextObject;
@end


@interface ORAVLTreeNode : NSObject<Position> {
@package
   ORAVLTreeNode* _parent;
   ORAVLTreeNode* _left;
   ORAVLTreeNode* _right;
   ORInt _height;
   ORInt _size;
   id  _data;
   ORInt _key;
}
-(ORAVLTreeNode<Position>*)initAVLTreeNode:(ORInt)key object:(id)o;
-(void)dealloc;
-(bool)balanced;
-(void)fixSize;
-(void)fixHeight;
-(void) iterateOverKey: (ORInt2Void) f;
@end

#define LEFTHEIGHT(n)  ((n)->_left  ? (n)->_left->_height : 0L)
#define RIGHTHEIGHT(n) ((n)->_right ? (n)->_right->_height : 0l)
#define LEFTSIZE(n) ((n)->_left ? (n)->_left->_size : 0)
#define RIGHTSIZE(n) ((n)->_right ? (n)->_right->_size : 0)


@implementation ORAVLTreeNode
-(ORAVLTreeNode*)initAVLTreeNode:(ORInt)key object:(id)o
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
   ORInt bal = LEFTHEIGHT(self) - RIGHTHEIGHT(self);
   return -1 <= bal && bal <= 1;
}
-(void)fixSize
{
   _size = LEFTSIZE(self) + RIGHTSIZE(self) + 1;
}
-(void)fixHeight
{
   _height = max(LEFTHEIGHT(self),RIGHTHEIGHT(self))+1;
}
-(ORAVLTreeNode<Position>*)tallest
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
-(void) iterateOverKey: (ORInt2Void) f
{
   [_left iterateOverKey: f];
   f(_key);
   [_right iterateOverKey: f];
}
@end

@implementation ORAVLTree

-(ORAVLTree*)initEmptyAVL
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

static inline void leftRotate(ORAVLTree* t,ORAVLTreeNode* z)
{
   ORAVLTreeNode* y = z->_right;
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

static inline void rightRotate(ORAVLTree* t,ORAVLTreeNode* z)
{
   ORAVLTreeNode* y = z->_left;
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

-(void)reBalance:(ORAVLTreeNode*)high
{
   do {
      [high fixHeight];
      [high fixSize];
      if (![high balanced]) {
         ORAVLTreeNode* z = high;
         ORAVLTreeNode* y = [z tallest];
         ORAVLTreeNode* x = [y tallest];
         ORAVLTreeNode* nr;
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

-(ORAVLTreeNode<Position>*)insertObject:(id)o forKey:(ORInt)k
{
   ORAVLTreeNode*  par = 0;
   ORAVLTreeNode** cur = &_root;
   while(*cur) {
      par = *cur;
      if (k < (*cur)->_key) 
         cur = &(*cur)->_left;
      else if (k > (*cur)->_key) 
         cur = &(*cur)->_right;
      else return *cur;
   }
   ORAVLTreeNode* retVal = [[ORAVLTreeNode alloc] initAVLTreeNode:k 
                                                           object:o];
   *cur = retVal;
   (*cur)->_parent = par;
   [self reBalance: *cur];
   return retVal;   
}
-(ORAVLTreeNode<Position>*)findNodeForKey:(ORInt)k
{
   ORAVLTreeNode* cur = _root;
   while (cur) {
      if (k < cur->_key)
         cur = cur->_left;
      else if (k > cur->_key)
         cur = cur->_right;
      else return cur;
   }
   return nil;
}
-(id)findObjectForKey:(ORInt)k
{
   ORAVLTreeNode* nd = [self findNodeForKey:k];
   return nd ? nd->_data : nil;
}
-(ORInt)size
{
   return _root ? _root->_size : 0;
}
-(void)updateObject:(id)o forKey:(ORInt)k
{
   ORAVLTreeNode* nd = [self findNodeForKey:k];
   if (nd) {
      [nd->_data release];
      nd->_data = [o retain];
   }
}
-(void)removeObjectForKey:(ORInt)k
{
   ORAVLTreeNode* togo = [self findNodeForKey:k];
   [self removeNode:togo];
}
-(void)removeNode:(ORAVLTreeNode<Position>*)togo
{
   ORAVLTreeNode* splice = 0;
   if (togo) {
      if (togo->_left==0 || togo->_right==0) {
         splice = togo;
         ORAVLTreeNode* child = splice->_left ? splice->_left : splice->_right;
         ORAVLTreeNode* from = child ? child : ( splice->_parent ? splice->_parent : 0);
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
         
         ORAVLTreeNode* child = splice->_left ? splice->_left : splice->_right;
         ORAVLTreeNode* from = child ? child : ( splice->_parent ? splice->_parent : 0);
         
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
-(ORAVLTreeNode*)smallest:(ORAVLTreeNode*)x
{
   if (x== 0) x = _root;
   while (x && x->_left != 0)
      x = x->_left;
   return x;
}
-(ORAVLTreeNode*)largest:(ORAVLTreeNode*)x
{
   if (x==0) x = _root;
   while (x && x->_right != 0)
      x = x->_right;
   return x;
}
-(ORAVLTreeNode*)findSucc:(ORAVLTreeNode*)x
{
   if (x) {
      if (x->_right) {
         return [self smallest:x->_right];
      } else {
         ORAVLTreeNode* y = x->_parent;
         while(y != 0 && x == y->_right) {
            x = y;
            y = y->_parent;
         }
         return y;
      }
   } else return 0;
}
-(ORAVLTreeNode*)findPred:(ORAVLTreeNode*)x
{
   if (x) {
      if (x->_left) {
         return [self largest:x->_left];
      } else {
         ORAVLTreeNode* y = x->_parent;
         while(y != 0 && x == y->_left) {
            x = y;
            y = y->_parent;
         }
         return y;
      }
   } else return 0;
}
-(void) iterateOverKey: (ORInt2Void) f
{
   [_root iterateOverKey: f];
}
-(NSEnumerator*)iterator
{
   return [[[ORAVLTreeIterator alloc] init] autorelease];
}
-(NSString*)description
{
   ORAVLTreeNode* from = [self smallest:_root];
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

@implementation ORAVLTreeIterator

-(ORAVLTreeIterator*) initORAVLTreeIterator:(ORAVLTree*)tree
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
   ORInt sz = [_theTree size];
   NSMutableArray* rv = [NSMutableArray arrayWithCapacity:sz];
   ORAVLTreeNode* from = [_theTree smallest:nil];
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

@implementation ORAVLTreeKeyIntEnumerator

-(ORAVLTreeKeyIntEnumerator*) initORAVLTreeKeyIntEnumerator: (ORAVLTree*) tree
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
-(BOOL) more
{
    return (_cur != NULL);
}
-(ORInt) next
{
    if (_cur) {
        ORInt rv = _cur->_key;
        _cur = [_theTree findSucc:_cur];
        return rv;
    } 
    else 
        @throw [[ORExecutionError alloc] initORExecutionError: "No next element in the iterator"]; ;
}

@end
