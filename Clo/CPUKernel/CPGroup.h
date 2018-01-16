/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPCstr.h>
#import <CPUKernel/CPConstraintI.h>

@class CPGroupController;

@protocol CPGroup <CPConstraint>
-(void)  add:(id<CPConstraint>)p;
-(void)  assignIdToConstraint:(id<ORConstraint>)c;
-(void)  scheduleClosure:(id<CPClosureList>)evt;
-(id<ORTrail>) trail;
-(void) propagate;
@end

@interface CPGroup : CPCoreConstraint<CPGroup>
{
   id<CPConstraint>*        _inGroup;
   ORInt                    _nbIn;
}
-(id)   init: (id<CPEngine>) engine;
-(void) add: (id<CPConstraint>) p;
-(void) assignIdToConstraint:(id<ORConstraint>)c;
-(void) scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c;
-(void) scheduleClosure: (id<CPClosureList>) evt;
-(void) scheduleValueClosure: (id<CPValueEvent>) evt;
-(void) enumerateWithBlock:(void(^)(ORInt,id<ORConstraint>))block;
-(void) post;
-(void) propagate;
@end

@interface CPBergeGroup : CPCoreConstraint<CPGroup>
-(id) init:(id<CPEngine>)engine;
-(void) add:(id<CPConstraint>)p;
-(void) assignIdToConstraint:(id<ORConstraint>)c;
-(void) scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c;
-(void) scheduleClosure:(id<CPClosureList>)evt;
-(void) scheduleValueClosure: (id<CPValueEvent>)evt;
-(void) post;
-(void) propagate;
@end
