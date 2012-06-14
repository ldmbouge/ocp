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

#import "CPSetI.h"
#import "CPAVLTree.h"
#import "CPFactoryI.h"
#import "CPError.h"

@implementation CPIntSetI 
-(id<CPIntSet>) initCPIntSetI: (id<CP>) cp
{
    self = [super init];
    _cp = cp;
    _avl = [[CPFactory AVLTree: cp] retain];
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
    return [CPFactory AVLTreeKeyIntEnumerator: _cp for: _avl];
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
    _avl = [[CPFactory AVLTree: _cp] retain];
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


