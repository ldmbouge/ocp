/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CPIntVarI.h"
@class ORAVLTree;

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
    ORAVLTree* _map;
}
-(id) initSparseTriggerMap;
-(void) linkTrigger:(CPTrigger*)t forValue:(CPInt)value;
-(void) loseValEvt:(CPInt)val solver:(CPSolverI*)fdm;
@end

