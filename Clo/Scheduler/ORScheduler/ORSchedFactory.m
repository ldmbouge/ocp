/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>
#import "ORConstraintI.h"
#import "ORTaskI.h"

@implementation ORFactory (ORScheduler)

//+(id<ORActivity>) activity: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORActivity>(^)(ORInt)) clo;
//{
//    id<ORActivityArray> acts = [ORFactory activityArray:model range:range with:clo];
//    id<ORActivity> o;
//    ORInt count = 0;
//    for (ORInt i = acts.range.low; i <= acts.range.up; i++) {
//        if (!acts[i].isOptional) count++;
//    }
//    if (count > 1) failNow();
//    if (count == 1) {
//        for (ORInt i = acts.range.low; i <= acts.range.up; i++) {
//            if (acts[i].isOptional) {
//                [model add: [ORFactory equalc:model var:acts[i].top to:0]];
//            }
//            else {
//                o = acts[i];
//            }
//        }
//    }
//    else if (range.low == range.up) {
//        o = acts[range.low];
//    }
//    else {
//        o = [[ORActivity alloc] initORActivity:model alternatives:acts];
//    }
//    [model trackMutable:o];
//    return o;
//}
//+(id<ORActivity>) optionalActivity: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORActivity>(^)(ORInt)) clo;
//{
//    id<ORActivityArray> acts = [ORFactory activityArray:model range:range with:clo];
//    id<ORActivity> o;
//    ORInt count = 0;
//    for (ORInt i = acts.range.low; i <= acts.range.up; i++) {
//        if (!acts[i].isOptional) count++;
//    }
//    if (count > 1) failNow();
//    if (count == 1) {
//        for (ORInt i = acts.range.low; i <= acts.range.up; i++) {
//            if (acts[i].isOptional) {
//                [model add: [ORFactory equalc:model var:acts[i].top to:0]];
//            }
//            else {
//                o = acts[i];
//            }
//        }
//    }
//    else if (range.low == range.up) {
//        o = acts[range.low];
//    }
//    else {
//        o = [[ORActivity alloc] initOROptionalActivity:model alternatives:acts];
//    }
//    [model trackMutable:o];
//    return o;
//}
//+(id<ORActivity>) activity: (id<ORModel>) model range: (id<ORIntRange>) range withSpan: (id<ORActivity>(^)(ORInt)) clo;
//{
//    id<ORActivityArray> acts = [ORFactory activityArray:model range:range with:clo];
//    id<ORActivity> o;
//    if (range.low == range.up) {
//        o = acts[range.low];
//    }
//    else {
//        o = [[ORActivity alloc] initORActivity:model span:acts];
//    }
//    [model trackMutable:o];
//    return o;
//}
//+(id<ORActivity>) optionalActivity: (id<ORModel>) model range: (id<ORIntRange>) range withSpan: (id<ORActivity>(^)(ORInt)) clo;
//{
//    id<ORActivityArray> acts = [ORFactory activityArray:model range:range with:clo];
//    id<ORActivity> o;
//    ORInt count = 0;
//    for (ORInt i = acts.range.low; i <= acts.range.up; i++) {
//        if (!acts[i].isOptional) count++;
//    }
//    if (range.low == range.up) {
//        o = acts[range.low];
//    }
//    else if (count > 0) {
//        o = [[ORActivity alloc] initORActivity:model span:acts];
//    }
//    else {
//        o = [[ORActivity alloc] initOROptionalActivity:model span:acts];
//    }
//    [model trackMutable:o];
//    return o;
//}

+(id<ORTaskDisjunctiveArray>) disjunctiveArray: (id<ORTracker>) model range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray: model range:range];
   for(ORInt k=range.low;k <= range.up;k++) {
      id<ORTaskDisjunctive> dr = [ORFactory disjunctiveConstraint: model];
      [o set: dr at:k];
   }
   return (id<ORTaskDisjunctiveArray>) o;
}

//+(id<ORTaskSequenceArray>) sequenceArray: (id<ORTracker>) model range: (id<ORIntRange>) range
//{
//   id<ORIdArray> o = [ORFactory idArray: model range:range];
//   for(ORInt k=range.low;k <= range.up;k++) {
//      id<ORTaskSequence> dr = [ORFactory sequenceConstraint: model];
//      [o set: dr at:k];
//   }
//   return (id<ORTaskSequenceArray>) o;
//}

// Precedes
//
+(id<ORTaskPrecedes>) constraint: (id<ORTaskVar>) before precedes: (id<ORTaskVar>) after
{
   id<ORTaskPrecedes> o = [[ORTaskPrecedes alloc] initORTaskPrecedes: before precedes: after];
   [[before tracker] trackMutable: o];
   return o;
}
+(id<ORTaskIsFinishedBy>) constraint: (id<ORTaskVar>) task isFinishedBy: (id<ORIntVar>) date
{
   id<ORTaskIsFinishedBy> o = [[ORTaskIsFinishedBy alloc] initORTaskIsFinishedBy: task isFinishedBy: date];
   [[task tracker] trackMutable: o];
   return o;
}
+(id<ORTaskDuration>) constraint: (id<ORTaskVar>) task duration: (id<ORIntVar>) duration
{
   id<ORTaskDuration> o = [[ORTaskDuration alloc] initORTaskDuration: task duration: duration];
   [[task tracker] trackMutable: o];
   return o;
}
+(id<ORTaskAddTransitionTime>) constraint: (id<ORTaskVar>) normal extended:  (id<ORTaskVar>) extended time: (id<ORIntVar>) time
{
   id<ORTaskAddTransitionTime> o = [[ORTaskAddTransitionTime alloc] initORTaskAddTransitionTime: normal extended: extended time: time];
   [[normal tracker] trackMutable: o];
   return o;
}
// Cumulative (resource) constraint
//
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<ORIntVar>) c
{
    id<ORTracker> tracker = [s tracker];
    id<ORIntVarArray> duration = [ORFactory intVarArray: tracker range:[s range] with:^id<ORIntVar>(ORInt k) {
        return [ORFactory intVar: tracker value: [d at: k]];
    }];
    id<ORCumulative> o = [[ORCumulative alloc] initORCumulative:s duration: duration usage:r capacity:c];
    [[s tracker] trackMutable:o];
    return o;
}
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r maxCapacity:(ORInt) c
{
    id<ORTracker> tracker = [s tracker];
    id<ORIntVarArray> duration = [ORFactory intVarArray: tracker range:[s range] with:^id<ORIntVar>(ORInt k) {
        return [ORFactory intVar: tracker value:[d at: k]];
    }];
    id<ORIntVar> capacity = [ORFactory intVar: [s tracker] value: c];
    id<ORCumulative> o = [[ORCumulative alloc] initORCumulative:s duration: duration usage:r capacity:capacity];
    [[s tracker] trackObject:o];
    return o;
}
+(id<ORTaskCumulative>) cumulative: (id<ORTaskVarArray>) task with: (id<ORIntVarArray>) usage and: (id<ORIntVar>) capacity
{
    id<ORTaskCumulative> o = [[ORTaskCumulative alloc] initORTaskCumulative: task with: usage and: capacity];
    [[task tracker] trackObject:o];
    return o;
}
+(id<ORTaskCumulative>) cumulativeConstraint: (id<ORIntVar>) capacity
{
    id<ORTaskCumulative> o = [[ORTaskCumulative alloc] initORTaskCumulativeEmpty: capacity];
    [[capacity tracker] trackObject:o];
    return o;
}

// Disjunctive (resource) constraint
//

+(id<ORTaskDisjunctive>) disjunctive: (id<ORTaskVarArray>) task
{
   id<ORTaskDisjunctive> o = [[ORTaskDisjunctive alloc] initORTaskDisjunctive: task];
   [[task tracker] trackObject:o];
   return o;
}

+(id<ORTaskDisjunctive>) disjunctiveConstraint: (id<ORTracker>) model
{
   id<ORTaskDisjunctive> o = [[ORTaskDisjunctive alloc] initORTaskDisjunctiveEmpty: model];
   [model trackObject:o];
   return o;
}

+(id<ORTaskDisjunctive>) disjunctiveConstraint: (id<ORTracker>) model transition: (id<ORIntMatrix>) matrix
{
   id<ORTaskDisjunctive> o = [[ORTaskDisjunctive alloc] initORTaskDisjunctiveEmpty: model transition: matrix];
   [model trackObject:o];
   return o;
}

// Difference Logic constraint
+(id<ORDifference>) difference: (id<ORTracker>) model initWithCapacity:(ORInt) numItems
{
    id<ORDifference> o = [[ORDifference alloc] initORDifference: model initWithCapacity: numItems];
    [model trackObject:o];
    return o;
}

// x <= y + d handled by the difference logic constraint
+(id<ORDiffLEqual>) diffLEqual:(id<ORDifference>)diff var: (id<ORIntVar>)x to: (id<ORIntVar>)y plus: (ORInt)d
{
    id<ORDiffLEqual> o = [[ORDiffLEqual alloc] initORDiffLEqual:diff var:x to:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}

// b <-> x <= y + d handled by the difference logic constraint
+(id<ORDiffReifyLEqual>) diffReifyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d
{
    if (!b.isBool) {
        @throw [[ORExecutionError alloc] initORExecutionError: "diffReifyLEqual: b is not Boolean!"];
    }
    id<ORDiffReifyLEqual> o = [[ORDiffReifyLEqual alloc] initORDiffReifyLEqual:diff boolean:b with:x leqc:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}

// b -> x <= y + d handled by the difference logic constraint
+(id<ORDiffImplyLEqual>) diffImplyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d
{
    if (!b.isBool) {
        @throw [[ORExecutionError alloc] initORExecutionError: "diffImplyLEqual: b is not Boolean!"];
    }
    id<ORDiffImplyLEqual> o = [[ORDiffImplyLEqual alloc] initORDiffImplyLEqual:diff boolean:b with:x leqc:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}

// ORTaskVar
+(id<ORTaskVar>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   id<ORTaskVar> o = [[ORTaskVar alloc] initORTaskVar: model horizon: horizon duration: RANGE(model,duration,duration)];
   [model trackVariable:o];
   return o;
}
+(id<ORTaskVar>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon durationRange: (id<ORIntRange>) duration
{
   id<ORTaskVar> o = [[ORTaskVar alloc] initORTaskVar: model horizon: horizon duration: duration];
   [model trackVariable:o];
   return o;
}
+(id<ORTaskVar>) optionalTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   id<ORTaskVar> o = [[ORTaskVar alloc] initOROptionalTaskVar: model horizon: horizon duration: RANGE(model,duration,duration)];
   [model trackMutable:o];
   return o;
}
// ORAlternativeVar
+(id<ORAlternativeVar>) task: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORTaskVar>(^)(ORInt)) clo;
{
    id<ORIdArray> alts = [ORFactory idArray:model range:range];
    for(ORInt k = range.low; k <= range.up; k++)
        [alts set: clo(k) at:k];
    id<ORAlternativeVar> o = [[ORAlternativeVar alloc] initORAlternativeVar: model alternatives: (id<ORTaskVarArray>) alts];
    [model trackMutable:o];
    return o;
}
// ORAlternativeVar array
+(id<ORAlternativeVarArray>) alternativeVarArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORAlternativeVar>(^)(ORInt)) clo;
{
    id<ORIdArray> o = [ORFactory idArray:model range:range];
    for(ORInt k = range.low; k <= range.up; k++)
        [o set: clo(k) at:k];
    return (id<ORAlternativeVarArray>) o;
}
// ORTaskVar array
+(id<ORTaskVarArray>) taskVarArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORTaskVar>(^)(ORInt)) clo;
{
   id<ORIdArray> o = [ORFactory idArray:model range:range];
   for(ORInt k = range.low; k <= range.up; k++)
      [o set: clo(k) at:k];
   return (id<ORTaskVarArray>) o;
}
+(id<ORTaskVarArray>) taskVarArray: (id<ORModel>) model range: (id<ORIntRange>) range horizon: (id<ORIntRange>) horizon duration: (id<ORIntArray>) duration
{
   return [ORFactory taskVarArray: model range: range with: ^id<ORTaskVar>(ORInt i) {
      return [ORFactory task: model horizon: horizon duration: [duration at:i]];
   }];
}
+(id<ORTaskVarArray>) taskVarArray: (id<ORModel>) model range: (id<ORIntRange>) range horizon: (id<ORIntRange>) horizon range: (id<ORIntRange>) duration
{
   return [ORFactory taskVarArray: model range: range with: ^id<ORTaskVar>(ORInt i) {
      return [ORFactory task: model horizon: horizon durationRange: duration];
   }];
}
// TaskVar matrix
+(id<ORTaskVarMatrix>) taskVarMatrix: (id<ORTracker>) model range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2  with: (id<ORTaskVar>(^)(ORInt,ORInt)) clo;
{
   id<ORIdMatrix> o = [ORFactory idMatrix: model range: R1 : R2];
   for(ORInt i=R1.low;i <= R1.up;i++)
      for(ORInt j=R2.low;j <= R2.up;j++)
         [o set: clo(i,j) at: i : j];
   return (id<ORTaskVarMatrix>) o;
}
+(id<ORTaskVarMatrix>) taskVarMatrix: (id<ORModel>) model range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
                             horizon: (id<ORIntRange>) horizon duration: (id<ORIntMatrix>) duration
{
   return [ORFactory taskVarMatrix: model range: R1 : R2  with: ^id<ORTaskVar>(ORInt i,ORInt j) {
      return [ORFactory task: model horizon: horizon duration: [duration at: i : j]];
   }];
}
+(id<ORSumTransitionTimes>) sumTransitionTimes: (id<ORTaskDisjunctive>) disjunctive leq: (id<ORIntVar>) sumTransitionTimes
{
   id<ORSumTransitionTimes> o = [[ORSumTransitionTimes alloc] initORSumTransitionTimes: disjunctive  leq: sumTransitionTimes];
   [[sumTransitionTimes tracker] trackMutable: o];
   return o;
}

@end
