/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
