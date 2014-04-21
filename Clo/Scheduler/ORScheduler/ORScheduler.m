/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORScheduler.h"
#import <ORProgram/CPSolver.h>

@interface CPCoreSolver (CPScheduling)
-(void) labelActivities: (id<ORActivityArray>) act;
@end

@implementation CPCoreSolver (CPScheduling)
-(void) labelActivities: (id<ORActivityArray>) act
{
   id<ORIntVarArray> start = [ORFactory intVarArray: self range: act.range with: ^id<ORIntVar>(ORInt k) {
      return act[k].start;
   }];
   [self labelArray: start];
}
-(void) labelActivity: (id<ORActivity>) act
{
   [self label: act.start];
}
-(void) setTimes: (id<ORActivityArray>) act
{
   id<ORIntRange> R = act.range;
   ORInt low = R.low;
   ORInt up = R.up;
   ORInt m = FDMAXINT;
   ORInt found = FALSE;
   while (true) {
      found = FALSE;
      m = FDMAXINT;
      for(ORInt k = low; k <= up; k++) {
         ORInt vm = [self min: act[k].start];
         if (![self bound: act[k].start]) {
            found = TRUE;
            if (vm < m)
               m = vm;
         }
      }
      if (!found)
         break;
      [self tryall: R suchThat: ^bool(ORInt k) { return ([self min: act[k].start] == m) && ![self bound: act[k].start]; } in: ^(ORInt k) {
         [self label: act[k].start with: m];
      }];
   }
}
@end

@implementation ORFactory (CPScheduling)
+(id<CPSchedulingProgram>) createCPSchedulingProgram: (id<ORModel>) model
{
   return (id<CPSchedulingProgram>) [ORFactory createCPProgram: model];
}

@end
