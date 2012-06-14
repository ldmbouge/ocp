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
#import "CPConcurrency.h"
#import "CPData.h"

@interface CPBarrierI : NSObject<CPBarrier> {
    CPInt _nb;
    CPInt _count;
    NSCondition* _condition; 
}
-(id<CPBarrier>) initCPBarrierI: (CPInt) nb;
-(void) join;
-(void) wait;
@end

@class CPEventQueue;

@interface CPEventList : NSObject {
   CPEventQueue* _queue;
}
-(CPEventList*) initCPEventList;
-(void) addEvent: (id) closure;
-(void) dealloc;
-(void) execute;
@end

@interface CPThread : NSThread {
    CPInt _value;
    CPBarrierI* _barrier;
    CPInt2Void _closure;
}
-(CPThread*) initCPThread: (CPInt) v barrier: (CPBarrierI*) barrier closure: (CPInt2Void) closure;
-(void) main;
@end

@interface CPInformerI : NSObject<CPVoidInformer,CPIntInformer,CPIdxIntInformer> {
    NSLock* _lock;
    NSMutableArray* _whenList;
    NSMutableArray* _wheneverList;
    NSMutableArray* _sleeperList;
}
-(CPInformerI*) initCPInformerI;
-(void) whenNotifiedDo: (id) closure;
-(void) wheneverNotifiedDo: (id) closure;
-(void) sleepUntilNotified;
-(void) notify;
-(void) notifyWith:(int)a0;
-(void) notifyWith:(id)a0 andInt:(CPInt)v;
@end


@interface CPConcurrency (Internals)
+(CPEventList*) eventList;
@end

@interface CPInterruptI : NSObject 
-(CPInterruptI*) initCPInterruptI;
@end

