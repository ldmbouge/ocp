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

@interface CPObjectQueue : NSObject {
   @package
   CPInt      _mxs;
   id*            _tab;
   CPInt    _enter;
   CPInt     _exit;
   CPInt     _mask;
}
-(id)initEvtQueue:(CPInt)sz;
-(void)dealloc;
-(id)deQueue;
-(void)enQueue:(id)obj;
-(bool)empty;
-(void)reset;
@end

// Producer-Consumer queue
@interface PCObjectQueue  : NSObject {
   CPInt           _mxs;
   id*                 _tab;
   CPInt         _enter;
   CPInt          _exit;
   CPInt          _mask;  
   CPInt        _nbUsed;
   CPInt     _nbWorkers;
   CPInt    _nbWWaiting;
   NSCondition*      _avail;
}
-(id)initPCQueue:(CPInt)sz nbWorkers:(CPInt)nbw;
-(void)dealloc;
-(id)deQueue;
-(void)enQueue:(id)obj;
-(bool)empty;
-(void)reset;
@end
