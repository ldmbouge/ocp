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

@protocol CPSchedulingProgram <CPProgram>
-(void) labelActivities: (id<ORActivityArray>) act;
-(void) labelActivity: (id<ORActivity>) act;
-(void) setTimes: (id<ORActivityArray>) act;
-(void) labelTimes: (id<ORActivityArray>) act;
@end

@interface ORFactory (CPScheduling)
+(id<CPSchedulingProgram>) createCPSchedulingProgram: (id<ORModel>) model;
@end
