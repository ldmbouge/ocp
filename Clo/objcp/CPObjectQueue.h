/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <CPUKernel/CPTypes.h>

@interface CPObjectQueue : NSObject
-(id)initEvtQueue:(ORInt)sz;
-(void)dealloc;
-(id)deQueue;
-(void)enQueue:(id)obj;
-(ORBool)empty;
-(void)reset;
@end

// Producer-Consumer queue
@interface PCObjectQueue  : NSObject 
-(id)initPCQueue:(ORInt)sz nbWorkers:(ORInt)nbw;
-(void)dealloc;
-(id)deQueue;
-(void)enQueue:(id)obj;
-(ORBool)empty;
-(void)reset;
-(ORInt)size;
@end
