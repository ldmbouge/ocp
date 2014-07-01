/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>
#import <ORScheduler/ORSchedFactory.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORTask.h>

@protocol CPSchedulingProgram <CPProgram>
-(void) labelActivities: (id<ORActivityArray>) act;
-(void) labelActivity: (id<ORActivity>) act;
-(void) setTimes: (id<ORActivityArray>) act;
-(void) labelTimes: (id<ORActivityArray>) act;

-(ORInt) start: (id<ORTask>) task;
-(ORInt) ebd: (id<ORTask>) task;
-(ORInt) minDuration: (id<ORTask>) task;
-(ORInt) maxDuration: (id<ORTask>) task;
-(void) updateStart: (id<ORTask>) task with: (ORInt) newStart;
-(void) updateEnd: (id<ORTask>) task with: (ORInt) newEnd;
-(void) updateMinDuration: (id<ORTask>) task with: (ORInt) newMinDuration;
-(void) updateMaxDuration: (id<ORTask>) task with: (ORInt) newMaxDuration;
@end

@interface ORFactory (CPScheduling)
+(id<CPSchedulingProgram>) createCPSchedulingProgram: (id<ORModel>) model;
@end

