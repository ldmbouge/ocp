/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <CPUKernel/CPUKernel.h>
#import <objcp/CPData.h>

@class ORAVLTree;

// PVH: I am not sure that I like the fact that it is a struct
// In any case, this should be hidden evenfrom those with access to extended interface.
// PVH to clean up
typedef struct CPTrigger {
   struct CPTrigger*  _prev;
   struct CPTrigger*  _next;
   ConstraintCallback   _cb;       // var/val held inside the closure (captured).
   CPCoreConstraint*  _cstr;
   ORInt               _vId;       // local variable identifier (var being watched)
} CPTrigger;


@class CPCoreConstraint;
@class CPEngineI;

@protocol CPTriggerMap <NSObject>
@optional
-(CPTrigger*)linkTrigger:(CPTrigger*)t forValue:(ORInt)value;
-(CPTrigger*)linkBindTrigger:(CPTrigger*)t;
// Events for those triggers.
-(void) loseValEvt:(ORInt)val solver:(CPEngineI*)fdm;
-(void) bindEvt:(CPEngineI*)fdm;
@end

@interface CPTriggerMap : NSObject<CPTriggerMap>
+(CPTrigger*)     createTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
+(id<CPTriggerMap>) triggerMapFrom: (ORInt)low to:(ORInt)up dense:(bool)b;
-(CPTrigger*) linkBindTrigger:(CPTrigger*)t;
-(void) bindEvt:(CPEngineI*)fdm;
@end

void detachTrigger(CPTrigger* t);
ORInt varOfTrigger(CPTrigger* t);
void setTriggerOwner(CPTrigger* t,ORInt vID);
ORInt getVarOfTrigger(CPTrigger* t);
