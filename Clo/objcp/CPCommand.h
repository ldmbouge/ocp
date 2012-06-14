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
#import <objcp/CPTypes.h>
#import <objcp/CPData.h>

/**
 * This is a simple Command protocol to record "decisions" that must be redone
 * when redoing a different semantic path. 
 * Constraints are commands. 
 * Other commands could be: going to atomic mode, setting a controller, etc.... 
 */

@protocol CPCommand <NSObject,NSCoding>
-(CPStatus) doIt;
@end

@interface CPCommandList : NSObject<NSCoding> {
   struct CNode {
      id<CPCommand>    _c;
      struct CNode*    _next;
   };
   struct CNode* _head;
   CPInt     _ndId;  // node id
}
-(CPCommandList*)initCPCommandList;
-(CPCommandList*)initCPCommandList:(CPInt)node;
-(void)dealloc;
-(void)insert:(id<CPCommand>)c;
-(id<CPCommand>)removeFirst;
-(bool)empty;
-(bool)equalTo:(CPCommandList*)cList;
-(CPInt)getNodeId;
-(bool)apply:(bool(^)(id<CPCommand>))clo;
@end
