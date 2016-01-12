/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <CPUKernel/CPUKernel.h>

@class ORAVLTree;

@protocol CPTrigger <NSObject>
-(void) detach;
-(ORInt) localID;
-(void) setLocalID: (ORInt) lid;
@end

@class CPEngineI;

@protocol CPTriggerMap <NSObject>
@optional
-(id<CPTrigger>)linkTrigger:(id<CPTrigger>)t forValue:(ORInt)value;
-(id<CPTrigger>)linkBindTrigger:(id<CPTrigger>)t;
// Events for those triggers.
-(void) loseValEvt: (ORInt) val solver: (CPEngineI*)fdm;
-(void) bindEvt: (CPEngineI*) fdm;
@end

@interface CPTriggerMap : NSObject<CPTriggerMap>
+(id<CPTrigger>)     createTrigger: (ORClosure) todo onBehalf: (id<CPConstraint>) c;
+(id<CPTriggerMap>) triggerMapFrom: (ORInt) low to: (ORInt) up dense: (ORBool) b;
-(id<CPTrigger>) linkTrigger: (id<CPTrigger>) trig forValue: (ORInt) value;
-(id<CPTrigger>) linkBindTrigger: (id<CPTrigger>) t;
-(void) bindEvt:(CPEngineI*) fdm;
@end

