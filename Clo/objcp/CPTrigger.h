/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <objcp/CPData.h>
@class ORAVLTree;

// PVH: I am not sure that I like the fact that it is a struct
// In any case, this should be hidden evenfrom those with access to extended interface.
// PVH to clean up

@class CPCoreConstraint;
@class CPEngineI;

typedef struct CPTrigger {
   struct CPTrigger*  _prev;
   struct CPTrigger*  _next;
   ConstraintCallback   _cb;       // var/val held inside the closure (captured).
   CPCoreConstraint*  _cstr;
   CPInt _vId;               // local variable identifier (var being watched)
} CPTrigger;


@protocol CPTriggerMapInterface <NSObject>
@optional
-(void)linkTrigger:(CPTrigger*)t forValue:(ORInt)value;
-(void)linkBindTrigger:(CPTrigger*)t;
// Events for those triggers.
-(void) loseValEvt:(ORInt)val solver:(CPEngineI*)fdm;
-(void) bindEvt:(CPEngineI*)fdm;
@end

@interface CPTriggerMap : NSObject<CPTriggerMapInterface> {
    @package
    bool     _active;
    CPTrigger* _bind;
}
-(CPTriggerMap*) init;
+(CPTriggerMap*) triggerMapFrom:(ORInt)low to:(ORInt)up dense:(bool)b;
-(void) linkBindTrigger:(CPTrigger*)t;
-(void) bindEvt:(CPEngineI*)fdm;
@end

@interface CPDenseTriggerMap : CPTriggerMap {
@private
    CPTrigger** _tab;
    CPInt         _low;
    CPInt          _sz;
}
-(id) initDenseTriggerMap:(ORInt)low size:(ORInt)sz;
-(void)linkTrigger:(CPTrigger*)t forValue:(ORInt)value;
-(void) loseValEvt:(ORInt)val solver:(CPEngineI*)fdm;
@end

@interface CPSparseTriggerMap : CPTriggerMap {
@private
    ORAVLTree* _map;
}
-(id) initSparseTriggerMap;
-(void) linkTrigger:(CPTrigger*)t forValue:(ORInt)value;
-(void) loseValEvt:(ORInt)val solver:(CPEngineI*)fdm;
@end

