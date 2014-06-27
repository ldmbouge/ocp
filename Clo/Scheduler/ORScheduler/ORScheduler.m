/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
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
    for (ORInt i = act.range.low; i <= act.range.up; i++) {
        [self labelActivity:act[i]];
    }
}
-(void) labelActivity: (id<ORActivity>) act
{
    if ((act.type & 1) == 1) {
        [self label: act.top];
    }
    [self label: act.startLB ];
    [self label: act.duration];
    if (act.type > 1) {
        [self labelActivities:act.composition];
    }
}
-(void) setTimes: (id<ORActivityArray>) act
{
    id<ORIntRange> R = act.range;
    ORInt low = R.low;
    ORInt up = R.up;
    ORInt m = FDMAXINT;
    ORInt found = FALSE;
   
   for (ORInt k = low; k <= up; k++) {
      if ((act[k].type & 1) == 1)
         [self label: act[k].top];
   }

    while (true) {
        found = FALSE;
        m = FDMAXINT;
       id<ORIntArray> assigned = [ORFactory intArray: self range: R value: 0];
       for(ORInt k = low; k <= up; k++) {
          [assigned set: [self bound: act[k].startLB] at: k];
       }
        for(ORInt k = low; k <= up; k++) {
            ORInt vm = [self min: act[k].startLB];
           if (![assigned at: k]) {
                found = TRUE;
                if (vm < m)
                    m = vm;
            }
        }
        if (!found)
            break;
       [self tryall: R suchThat: ^bool(ORInt k) { return ([self min: act[k].startLB] == m) && ![assigned at: k]; } orderedBy: ^(ORInt k) { return (ORFloat) k; } in: ^(ORInt k) {
            [self label: act[k].startLB with: m];
        }
       onFailure: ^(ORInt k) {  [self diff: act[k].startLB with: m];  }
         ];
    }
}

-(void) labelTimes: (id<ORActivityArray>) act
{
   id<ORIntRange> R = act.range;
   ORInt low = R.low;
   ORInt up = R.up;
   ORInt m = FDMAXINT;
   ORInt im = FDMAXINT;
   ORInt found = FALSE;
   while (true) {
      found = FALSE;
      m = FDMAXINT;
      for (ORInt k = low; k <= up; k++) {
         if ((act[k].type & 1) == 1)
            [self label: act[k].top];
      }
      for(ORInt k = low; k <= up; k++) {
         ORInt vm = [self min: act[k].startLB];
         if (![self bound: act[k].startLB]) {
            found = TRUE;
            if (vm < m) {
               m = vm;
               im = k;
            }
         }
      }
      if (!found)
         break;
      [self try: ^() { [self label: act[im].startLB with: m]; } or: ^() { [self diff: act[im].startLB with: m]; } ];
   }
}


@end

@implementation ORFactory (CPScheduling)
+(id<CPSchedulingProgram>) createCPSchedulingProgram: (id<ORModel>) model
{
   return (id<CPSchedulingProgram>) [ORFactory createCPProgram: model];
}

@end
