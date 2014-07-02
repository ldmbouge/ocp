/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORScheduler.h"
#import "ORSchedulingProgram.h"
#import <ORProgram/CPSolver.h>
#import <CPScheduler/CPTask.h>

// PVH: to clean up the code for optional activities; this is ugly right now

@interface CPCoreSolver (CPScheduling)
-(void) labelActivities: (id<ORActivityArray>) act;
@end

@implementation CPCoreSolver (CPScheduling)
-(void) labelActivities: (id<ORActivityArray>) act
{
   for (ORInt i = act.range.low; i <= act.range.up; i++)
      [self labelActivity:act[i]];
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
   ORInt im = 0;
   ORInt found = FALSE;
   ORInt hasPostponedActivities = FALSE;
   
   // optional activities
   for (ORInt k = low; k <= up; k++) {
      if ((act[k].type & 1) == 1)
         [self label: act[k].top];
   }
   
   id<ORTrailableIntArray> postponed = [ORFactory trailableIntArray: [self engine] range: R value: 0];
   id<ORTrailableIntArray> ptime = [ORFactory trailableIntArray: [self engine] range: R value: 0];
   
   while (true) {
      found = FALSE;
      m = FDMAXINT;
      hasPostponedActivities = FALSE;
      ORInt lsd = FDMAXINT;
      for(ORInt k = low; k <= up; k++) {
         
         if (![self bound: act[k].startLB]) {
            if (![[postponed at: k] value]) {
               ORInt vm = [self min: act[k].startLB];
               found = TRUE;
               if (vm < m) {
                  m = vm;
                  im = k;
               }
            }
            else {
               hasPostponedActivities = TRUE;
               ORInt vm = [self max: act[k].startLB];
               if (vm < lsd)
                  lsd = vm;
            }
         }
      }
      if (!found) {
         if (hasPostponedActivities)
            [[self explorer] fail];
         else
            break;
      }
      if (lsd <= m)
         [[self explorer] fail];
      
      for(ORInt k = low; k <= up; k++)
         if ([[postponed at: k] value])
            if ([self min: act[k].startLB] + [self min: act[k].duration] <= m)
               [[self explorer] fail];
      
      
      [self try:
       ^() {
          
          [self label: act[im].startLB with: m];
          
          for(ORInt k = low; k <= up; k++)
             if ([[postponed at: k] value])
                if ([self min: act[k].startLB] > [[ptime at: k] value])
                   [[postponed at: k] setValue: 0];
          
       }
             or:
       ^() {
          [[postponed at: im]  setValue: 1];
          [[ptime at: im] setValue: m];
       }
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

-(ORInt) est: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) est];
}
-(ORInt) ect: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) ect];
}
-(ORInt) lst: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) lst];
}
-(ORInt) lct: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) lct];
}
-(ORBool) boundActivity: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) bound];
}
-(ORInt) minDuration: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) minDuration];
}
-(ORInt) maxDuration: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) maxDuration];
}
-(void) updateStart: (id<ORTaskVar>) task with: (ORInt) newStart
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) updateStart: newStart]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) updateEnd: (id<ORTaskVar>) task with: (ORInt) newEnd
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) updateEnd: newEnd]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) updateMinDuration: (id<ORTaskVar>) task with: (ORInt) newMinDuration
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) updateMinDuration: newMinDuration]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) updateMaxDuration: (id<ORTaskVar>) task with: (ORInt) newMaxDuration
{
    ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) updateMaxDuration: newMaxDuration]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(NSString*) description: (id<ORObject>) o
{
   return [_gamma[o.getId] description];
}
@end

@implementation ORFactory (CPScheduling)
+(id<CPSchedulingProgram>) createCPSchedulingProgram: (id<ORModel>) model
{
   return (id<CPSchedulingProgram>) [ORFactory createCPProgram: model];
}

@end
