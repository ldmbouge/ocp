/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORSchedulingProgram.h"
#import <ORProgram/CPSolver.h>
#import <CPScheduler/CPScheduler.h>
#import <ORProgram/CPSolver.h>
#import <CPScheduler/CPTask.h>
#import "ORTaskI.h"
#import "ORConstraintI.h"

@implementation CPSolver (CPScheduler)
-(void) labelActivity: (id<ORTaskVar>) act
{
    if ([act isMemberOfClass: [ORResourceTask class]])
        [self labelResourceTask: (id<ORResourceTask>)act];
    [self labelPresent  : act];
    [self labelStart    : act];
    [self labelDuration : act];
    [self labelEnd      : act];
}
-(void) labelActivities: (id<ORTaskVarArray>) act
{
    for (ORInt i = act.low; i <= act.up; i++)
        [self labelActivity:act[i]];
}
-(void) setAlternatives: (id<ORAlternativeTaskArray>) act
{
    // TODO better heuristic that takes the slack of
    // corresponding machines into account
    for (ORInt i = act.low; i <= act.up; i++) {
        id<ORTaskVarArray> alt = [act[i] alternatives];
        for (ORInt j = alt.low; j <= alt.up; j++) {
            [self labelPresent: alt[j]];
        }
    }
}
-(void) assignAlternatives: (id<ORTaskVarArray>) act
{
    const ORInt low = act.low;
    const ORInt up  = act.up;
    for (ORInt i = low; i <= up; i++) {
        if ([self isAbsent: act[i]])
            continue;
        if (![self isAbsent: act[i]] && [act[i] isMemberOfClass:[ORAlternativeTask class]]) {
            id<ORTaskVarArray> alt = [(id<ORAlternativeTask>)act[i] alternatives];
            for (ORInt j = alt.low; j <= alt.up; j++) {
                [self labelPresent: alt[j]];
            }
        }
    }
}
-(void) assignResources: (id<ORTaskVarArray>) act
{
    const ORInt low = act.low;
    const ORInt up  = act.up;
    for (ORInt i = low; i <= up; i++) {
        if ([self isAbsent: act[i]])
            continue;
        if ([act[i] isMemberOfClass:[ORResourceTask class]])
            [self labelResourceTask: (id<ORResourceTask>) act[i]];
    }
}
-(void) labelResourceTask: (id<ORResourceTask>) act
{
    assert([act isMemberOfClass: [ORResourceTask class]]);
    assert(_gamma[act.getId] != NULL);
    id<ORResourceTask> resAct = (id<ORResourceTask>) act;
    id<ORIntArray> avail = [((id<CPResourceTask>)_gamma[act.getId]) getAvailResources];
    id<ORResourceArray> res = [resAct resources];
    assert(^ORBool(){
        for (ORInt i = avail.low; i <= avail.up; i++)
            if ([avail at:i] < res.low || [avail at:i] > res.up)
                return false;
        return true;
    });
    for (ORInt i = avail.low; i <= avail.up; i++) {
        if ([self isResourceAssigned:act])
            break;
        id<ORConstraint> d = [res at: [avail at:i]];
        [self labelResourceTask:act to:d];
    }
}
-(void) setTimes: (id<ORTaskVarArray>) act
{
   id<ORIntRange> R = act.range;
   ORInt low = R.low;
   ORInt up = R.up;
   ORInt m = FDMAXINT;
   ORInt im = 0;
   ORInt found = FALSE;
   ORInt hasPostponedActivities = FALSE;

    // Assumptions
    // - activities must be present or absent
    // - present activities must have a fixed duration
    for (ORInt k = low; k <= up; k++) {
        if (![self isPresent: act[k]] && ![self isAbsent: act[k]])
            @throw [[ORExecutionError alloc] initORExecutionError: "An activity is neither present nor absent immediately before running setTimes"];
        if ([self isPresent: act[k]] && [self minDuration: act[k]] < [self maxDuration: act[k]])
            @throw [[ORExecutionError alloc] initORExecutionError: "The duration of a present activity is not fixed immediately before running setTimes"];
    }
    
   id<ORTrailableIntArray> postponed = [ORFactory trailableIntArray: [self engine] range: R value: 0];
   id<ORTrailableIntArray> ptime = [ORFactory trailableIntArray: [self engine] range: R value: 0];
   
   while (true) {
      found = FALSE;
      m = FDMAXINT;
      hasPostponedActivities = FALSE;
      ORInt lsd = FDMAXINT;
      for(ORInt k = low; k <= up; k++) {
         
         if (![self boundActivity: act[k]] && [self isPresent: act[k]]) {
            if (![[postponed at: k] value]) {
               ORInt vm = [self est:  act[k]];
               found = TRUE;
               if (vm < m) {
                  m = vm;
                  im = k;
               }
            }
            else {
               hasPostponedActivities = TRUE;
               ORInt vm = [self lst: act[k]];
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
            if ([self ect: act[k]] <= m)
               [[self explorer] fail];
      
      
      [self try:
       ^() {
          
          [self labelStart: act[im] with: m];
//          NSLog(@"labelStart[%i] %@ with %d",im,act[im],m);
          for(ORInt k = low; k <= up; k++)
             if ([[postponed at: k] value])
                if ([self est: act[k]] > [[ptime at: k] value])
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

//-(void) labelTimes: (id<ORActivityArray>) act
//{
//   id<ORIntRange> R = act.range;
//   ORInt low = R.low;
//   ORInt up = R.up;
//   ORInt m = FDMAXINT;
//   ORInt im = FDMAXINT;
//   ORInt found = FALSE;
//   while (true) {
//      found = FALSE;
//      m = FDMAXINT;
//      for (ORInt k = low; k <= up; k++) {
//         if ((act[k].type & 1) == 1)
//            [self label: act[k].top];
//      }
//      for(ORInt k = low; k <= up; k++) {
//         ORInt vm = [self min: act[k].startLB];
//         if (![self bound: act[k].startLB]) {
//            found = TRUE;
//            if (vm < m) {
//               m = vm;
//               im = k;
//            }
//         }
//      }
//      if (!found)
//         break;
//      [self try: ^() { [self label: act[im].startLB with: m]; } or: ^() { [self diff: act[im].startLB with: m]; } ];
//   }
//}

-(void) sequence: (id<ORIntVarArray>) succ by: (ORInt2Float) o
{
   ORInt low = succ.range.low;
   ORInt size = succ.range.size - 1;
   ORInt k = low;
   for(ORInt j = 1; j <= size; j++) {
      [self label: succ[k] by: o];
      k = [self intValue: succ[k]];
   }
}
-(void) printSequence: (id<ORIntVarArray>) succ
{
   ORInt low = succ.range.low;
   ORInt up = succ.range.up;
   ORInt k = low;
   while (true) {
      printf("%d -> ",k);
      if (k == up+1)
         break;
      if (![self bound: succ[k]])
         break;
      k = [self intValue: succ[k]];
   }
   printf("\n");
}
-(void) sequence: (id<ORIntVarArray>) succ by: (ORInt2Float) o1 then: (ORInt2Float) o2
{
   ORInt low = succ.range.low;
   ORInt size = succ.range.size - 1;
   ORInt k = low;
   for(ORInt j = 1; j <= size; j++) {
      [self label: succ[k] by: o1 then: o2];
      k = [self intValue: succ[k]];
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
-(ORInt) isPresent: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) isPresent];
}
-(ORInt) isAbsent: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) isAbsent];
}
-(id<ORConstraint>) runsOnResource: (id<ORResourceTask>) task
{
    if (![self isResourceAssigned:task])
        @throw [[ORExecutionError alloc] initORExecutionError: "The task is not assigned to any machine"];
    id<ORResourceArray> res = [task resources];
    return [res at: [((id<CPResourceTask>)_gamma[task.getId]) runsOn]];
}
-(ORBool) isResourceAssigned: (id<ORResourceTask>) task
{
    return [((id<CPResourceTask>)_gamma[task.getId]) isAssigned];
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
-(void) labelStart: (id<ORTaskVar>) task
{
    if (![self isAbsent: task]) {
        while ([self est: task] < [self lst: task]) {
            ORInt est = [self est: task];
            [self try: ^{ [self labelStart : task with: est    ]; }
                   or: ^{ [self updateStart: task with: est + 1]; }
             ];
        }
    }
}
-(void) labelStart: (id<ORTaskVar>) task with: (ORInt) start
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) labelStart: start]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) labelEnd: (id<ORTaskVar>) task
{
    if (![self isAbsent: task]) {
        while ([self ect: task] < [self lct: task]) {
            ORInt ect = [self ect: task];
            [self try: ^{ [self labelEnd : task with: ect    ]; }
                   or: ^{ [self updateEnd: task with: ect + 1]; }
             ];
        }
    }
}
-(void) labelEnd: (id<ORTaskVar>) task with: (ORInt) end
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) labelEnd: end]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) labelDuration: (id<ORTaskVar>) task
{
    if (![self isAbsent: task]) {
        while ([self minDuration: task] < [self maxDuration: task]) {
            ORInt m = [self minDuration: task];
            [self try: ^{ [self labelDuration    : task with: m    ]; }
                   or: ^{ [self updateMinDuration: task with: m + 1]; }
             ];
        }
    }
}
-(void) labelDuration: (id<ORTaskVar>) task with: (ORInt) duration
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) labelDuration: duration]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) labelPresent: (id<ORTaskVar>) task
{
    if (![self isAbsent: task] && ![self isPresent: task]) {
        [self try: ^{ [self labelPresent: task with: true ]; }
               or: ^{ [self labelPresent: task with: false]; }
         ];
    }
}
-(void) labelPresent: (id<ORTaskVar>) task with: (ORBool) present
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) labelPresent: present]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) labelResourceTask: (id<ORResourceTask>) task to: (id<ORConstraint>) res
{
    if (![self isResourceAssigned:task]) {
        [self try: ^{ [self   bindResourceTask:task with:res]; }
               or: ^{ [self removeResourceTask:task with:res]; }
         ];
    }
}
-(void) bindResourceTask: (id<ORResourceTask>) task with: (id<ORConstraint>) res
{
    ORStatus status = [[self engine] enforce:^{ [((id<CPResourceTask>) _gamma[task.getId]) bind: _gamma[res.getId]]; }];
    if (status == ORFailure)
        [[self explorer] fail];
    [ORConcurrency pumpEvents];
}
-(void) removeResourceTask: (id<ORResourceTask>) task with: (id<ORConstraint>) res
{
    ORStatus status = [[self engine] enforce:^{ [((id<CPResourceTask>) _gamma[task.getId]) remove: _gamma[res.getId]]; }];
    if (status == ORFailure)
        [[self explorer] fail];
    [ORConcurrency pumpEvents];
}
-(ORInt) globalSlack: (id<ORTaskDisjunctive>) d
{
   ORInt gs = [((CPTaskDisjunctive*)_gamma[d.getId]) globalSlack];
//   NSLog(@"Global slack: %d",gs);
   return gs;
}
-(ORInt) localSlack: (id<ORTaskDisjunctive>) d
{
   ORInt gs = [((CPTaskDisjunctive*)_gamma[d.getId]) localSlack];
   //   NSLog(@"Local slack: %d",gs);
   return gs;
}

-(NSString*) description: (id<ORObject>) o
{
   return [_gamma[o.getId] description];
}
@end

@interface ORSolution (CPScheduler)
-(ORInt) est: (id<ORTaskVar>) task;
-(ORInt) ect: (id<ORTaskVar>) task;
-(ORInt) lst: (id<ORTaskVar>) task;
-(ORInt) lct: (id<ORTaskVar>) task;
-(ORInt) isPresent: (id<ORTaskVar>) task;
-(ORInt) isAbsent: (id<ORTaskVar>) task;
-(ORBool) boundActivity: (id<ORTaskVar>) task;
-(ORInt) minDuration: (id<ORTaskVar>) task;
-(ORInt) maxDuration: (id<ORTaskVar>) task;
@end

@implementation ORSolution (CPScheduler)
-(ORInt) est: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap est];
}
-(ORInt) ect: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap ect];
}
-(ORInt) lst: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap lst];
}
-(ORInt) lct: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap lct];
}
-(ORInt) isPresent: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap isPresent];
}
-(ORInt) isAbsent: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap isAbsent];
}
-(ORBool) boundActivity: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap bound];
}
-(ORInt) minDuration: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap minDuration];
}
-(ORInt) maxDuration: (id<ORTaskVar>) task
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [task getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap maxDuration];
}
@end