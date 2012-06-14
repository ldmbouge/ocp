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
#import "CPIntVarI.h"
@class CPAVLTree;

@protocol CPTriggerMapInterface <NSObject>
@optional
-(void)linkTrigger:(CPTrigger*)t forValue:(CPInt)value;
-(void)linkBindTrigger:(CPTrigger*)t;
// Events for those triggers.
-(void) loseValEvt:(CPInt)val solver:(CPSolverI*)fdm;
-(void) bindEvt:(CPSolverI*)fdm;
@end

@interface CPTriggerMap : NSObject<CPTriggerMapInterface> {
    @package
    bool     _active;
    CPTrigger* _bind;
}
-(CPTriggerMap*) init;
+(CPTriggerMap*) triggerMapFrom:(CPInt)low to:(CPInt)up dense:(bool)b;
-(void) linkBindTrigger:(CPTrigger*)t;
-(void) bindEvt:(CPSolverI*)fdm;
@end

@interface CPDenseTriggerMap : CPTriggerMap {
@private
    CPTrigger** _tab;
    CPInt         _low;
    CPInt          _sz;
}
-(id) initDenseTriggerMap:(CPInt)low size:(CPInt)sz;
-(void)linkTrigger:(CPTrigger*)t forValue:(CPInt)value;
-(void) loseValEvt:(CPInt)val solver:(CPSolverI*)fdm;
@end

@interface CPSparseTriggerMap : CPTriggerMap {
@private
    CPAVLTree* _map;
}
-(id) initSparseTriggerMap;
-(void) linkTrigger:(CPTrigger*)t forValue:(CPInt)value;
-(void) loseValEvt:(CPInt)val solver:(CPSolverI*)fdm;
@end

