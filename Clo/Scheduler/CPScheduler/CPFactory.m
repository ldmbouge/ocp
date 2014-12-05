/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objcp/CPConstraint.h>
#import <ORScheduler/ORTask.h>
#import "CPFactory.h"
#import "CPConstraint.h"
#import "CPCumulative.h"
#import "CPDisjunctive.h"
#import "CPTaskCumulative.h"
#import "CPTaskDisjunctive.h"
#import "CPTaskSequence.h"
#import "CPDifference.h"
#import "CPTaskI.h"

@implementation CPFactory (CPScheduler)
// activity

// Alternative propagator
+(id<CPConstraint>) constraint:(id<CPTaskVar>)task alternatives:(id<CPTaskVarArray>)alternatives
{
    id<CPConstraint> cstr = [[CPAlternative alloc] initCPAlternative:task alternatives:alternatives];
    [[task tracker] trackMutable:cstr];
    return cstr;
}

// Span propagator
+(id<CPConstraint>) constraint:(id<CPTaskVar>)task spans:(id<CPTaskVarArray>)spans
{
    id<CPConstraint> cstr = [[CPSpan alloc] initCPSpan:task compound:spans];
    [[task tracker] trackMutable:cstr];
    return cstr;
}

// Cumulative (resource) constraint
//
+(id<ORConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d end:(id<CPIntVarArray>) e usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c
{
    // Creating the type of tasks
    TaskType* types = malloc(s.count * sizeof(TaskType));
    if (types == NULL)
        @throw [[ORExecutionError alloc] initORExecutionError: "Out of memory"];
    for (ORInt i = 0; i < s.count; i++)
        types[i] = CVAR_S;
    id<CPEngine> engine = [[s at: [[s range] low]] engine];
    
    // Creating singleton-valued variables for the resource usages
    id<CPIntVarArray> ru = [CPFactory intVarArray:[r tracker] range:[r range] with:^(ORInt k) {
        return [CPFactory intVar:engine value:[r at: k]];
    }];
    
    // Creating singleton-valued variables for the area
    ORInt offset = [[r range] low] - [[d range] low];
    id<CPIntVarArray> area = [CPFactory intVarArray:[r tracker] range:[r range] with:^(ORInt k) {
        if ([[d at: k - offset] domsize] == 1) {
            return [CPFactory intVar:engine value: [r at: k] * [d at: k - offset].min];
        }
        return [CPFactory intVar: [d at: k - offset] scale:[r at: k]];
    }];
    
    // Creating the cumulative propagator
    id<CPConstraint> o = [[CPCumulative alloc] initCPCumulative:s duration: d usage:ru energy:area end:e type:types capacity:c];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[s tracker] trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}

// Cumulative (resource) constraint
//
+(id<ORConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c
{
    // Creating view variables for the end times
    ORInt offset2 = [[s range] low] - [[d range] low];
    id<CPIntVarArray> e = [CPFactory intVarArray:[s tracker] range:[s range] with:^id<CPIntVar>(ORInt k) {
        id<CPIntVar> duration = [d at: k - offset2];
        id<CPEngine> engine =[duration engine];
        if (duration.min == duration.max)
            return [CPFactory intVar: [s at: k] shift: duration.min];
        else {
            id<CPIntVar> concreteEnd = [CPFactory intVar: engine domain: RANGE(engine,s[k].min + duration.min,s[k].max + duration.max)];
            id<CPIntVarArray> av = [CPFactory intVarArray: engine range: RANGE(engine,0,2) with: ^id<CPIntVar>(ORInt k) {
                if (k == 0)
                    return s[k];
                else if (k == 1)
                    return duration;
                else
                    return [CPFactory intVar: concreteEnd scale: -1];
            }];
            id<CPConstraint> cstr = [CPFactory sum: av eq: 0 annotation: RangeConsistency];
            [engine add: cstr];
            return concreteEnd;
        }
    }];
    return [CPFactory cumulative: s duration: d end: e usage:r capacity: c];
}

//+(id<CPConstraint>) cumulative: (id<CPActivityArray>) act usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c
//{
//    TaskType* types = malloc(act.count * sizeof(TaskType));
//    if (types == NULL)
//        @throw [[ORExecutionError alloc] initORExecutionError: "Out of memory"];
//    for (ORInt ii = 0; ii < act.count; ii++) {
//        const ORInt i = ii + act.range.low;
//        if (act[i].isOptional) {
//            if (act[i].duration.domsize == 1)
//                types[i] = CVAR_SR;
//            else
//                types[i] = CVAR_SA;
//        }
//        else {
//            if (act[i].duration.domsize == 1)
//                types[i] = CVAR_S;
//            else
//                types[i] = CVAR_SD;
//        }
//    }
//    id<CPEngine> engine =[act[act.range.low].duration engine];
//    // Start variables
//    id<CPIntVarArray> start = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
//        return act[k].startLB;
//    }];
//    // Duration variables
//    id<CPIntVarArray> duration = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
//        return act[k].duration;
//    }];
//    // End variables
//    id<CPIntVarArray> end = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
//        id<CPIntVar> duration = act[k].duration;
//        if (duration.min == duration.max)
//            return [CPFactory intVar: act[k].startLB shift: duration.min];
//        else {
//            id<CPIntVar> concreteEnd = [CPFactory intVar: engine domain: RANGE(engine,act[k].startLB.min + duration.min,act[k].startLB.max + duration.max)];
//            id<CPIntVarArray> av = [CPFactory intVarArray: engine range: RANGE(engine,0,2) with: ^id<CPIntVar>(ORInt k) {
//                if (k == 0)
//                    return act[k].startLB;
//                else if (k == 1)
//                    return duration;
//                else
//                    return [CPFactory intVar: concreteEnd scale: -1];
//            }];
//            id<CPConstraint> cstr = [CPFactory sum: av eq: 0 annotation: RangeConsistency];
//            [engine add: cstr];
//            return concreteEnd;
//        }
//    }];
//    // Resource usage variables
//    ORInt offset = r.range.low - act.range.low;
//    id<CPIntVarArray> ru = [CPFactory intVarArray:[act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
//        if (act[k].isOptional)
//            return [CPFactory intVar:act[k].top scale:[r at: k + offset]];
//        else
//            return [CPFactory intVar:engine value:[r at: k + offset]];
//    }];
//    // Area variables
//    id<CPIntVarArray> area = [CPFactory intVarArray:[act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
//        if (duration[k].domsize == 1) {
//            if (ru[k].domsize == 1)
//                return [CPFactory intVar:engine value:duration[k].min * ru[k].min];
//            else
//                return [CPFactory intVar:ru[k] scale:duration[k].min];
//        }
//        else {
//            if (ru[k].domsize == 1)
//                return [CPFactory intVar:duration[k] scale:ru[k].min];
//            else {
//                id<CPIntVar> area_k = [CPFactory intVar:engine bounds:RANGE(engine, duration[k].min * ru[k].min, duration[k].max * ru[k].max)];
//                [engine add: [CPFactory mult:duration[k] by:ru[k] equal:area_k]];
//                return area_k;
//            }
//        }
//    }];
//    // Creating the cumulative propagator
//    id<CPConstraint> o = [[CPCumulative alloc] initCPCumulative:start duration:duration usage:ru energy:area end:end type:types capacity:c];
//    
//    // XXX What is the meaning of the following? Variable subscription?
//    [[act tracker] trackMutable: o];
//    
//    // Returning the cumulative propagator
//    return o;
//}

// Disjunctive (resource) constraint
//
+(id<CPConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d
{
   assert(false);
   return 0;
//    // Creating the disjunctive propagator
//    id<CPConstraint> o = [[CPDisjunctive alloc] initCPDisjunctive:s duration:d];
//    
//    // XXX What is the meaning of the following? Variable subscription?
//    [[s tracker] trackMutable: o];
//    
//    // Returning the disjunctive propagator
//    return o;
}

// Difference (logic) constraint
//
+(id<CPConstraint>) difference: (id<ORTracker>) tracker engine: (id<CPEngine>)e withInitCapacity:(ORInt)numItems
{
    // Creating the difference logic propagator
    id<CPConstraint> o = [[CPDifference alloc] initCPDifference: e withInitCapacity: numItems];
    
    // XXX What is the meaning of the following? Variable subscription?
    [tracker trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}

+(id<CPDisjunctiveArray>) disjunctiveArray:(id<CPEngine>)engine range:(id<ORIntRange>)range with:(CPTaskDisjunctive *(^)(ORInt))clo
{
    id<ORIdArray> disj = [ORFactory idArray:engine range:range];
    for (ORInt k = range.low; k <= range.up; k++)
        [disj set: clo(k) at: k];
    return (id<CPDisjunctiveArray>) disj;
}
+(id<CPResourceArray>) resourceArray:(id<CPEngine>)engine range:(id<ORIntRange>)range with:(id<CPConstraint>(^)(ORInt))clo
{
    id<ORIdArray> res = [ORFactory idArray:engine range:range];
    for (ORInt k = range.low; k <= range.up; k++)
        [res set: clo(k) at: k];
    return (id<CPResourceArray>) res;
}

// Task of fixed duration
//
+(id<CPTaskVar>) task: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   id<CPTaskVar> task = [[CPTaskVar alloc] initCPTaskVar: engine horizon: horizon duration: duration];
   [engine trackMutable: task];
   return task;
}
+(id<CPTaskVar>) optionalTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   id<CPTaskVar> task = [[CPOptionalTaskVar alloc] initCPOptionalTaskVar: engine horizon: horizon duration: duration];
   [engine trackMutable: task];
   return task;
}
+(id<CPAlternativeTask>) task: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration withAlternatives:(id<CPTaskVarArray>)alternatives
{
    id<CPAlternativeTask> task = [[CPAlternativeTask alloc] initCPAlternativeTask:engine horizon:horizon duration:duration alternatives:alternatives];
    [engine trackMutable: task];
    return task;
}
+(id<CPAlternativeTask>) optionalTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration withAlternatives:(id<CPTaskVarArray>)alternatives
{
    id<CPAlternativeTask> task = [[CPOptionalAlternativeTask alloc] initCPOptionalAlternativeTask: engine horizon: horizon duration: duration alternatives:alternatives];
    [engine trackMutable: task];
    return task;
}
+(id<CPSpanTask>) task: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration withSpans:(id<CPTaskVarArray>)spans
{
    id<CPSpanTask> task = [[CPSpanTask alloc] initCPSpanTask:engine horizon:horizon duration:duration compound:spans];
    [engine trackMutable: task];
    return task;
}
+(id<CPSpanTask>) optionalTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration withSpans:(id<CPTaskVarArray>)spans
{
    id<CPSpanTask> task = [[CPOptionalSpanTask alloc] initCPOptionalSpanTask: engine horizon: horizon duration: duration compound:spans];
    [engine trackMutable: task];
    return task;
}
+(id<CPResourceTask>) task: (id<CPEngine>) engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration durationArray:(id<ORIntRangeArray>)durationArray runsOnOneOf:(id<CPResourceArray>)resources
{
    id<CPResourceTask> task = [[CPResourceTask alloc] initCPResourceTask:engine horizon:horizon duration:duration durationArray:durationArray runsOnOneOf:resources];
    [engine trackMutable: task];
    return task;
}
+(id<CPResourceTask>) optionalTask: (id<CPEngine>) engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration durationArray:(id<ORIntRangeArray>)durationArray runsOnOneOf:(id<CPResourceArray>)resources
{
    id<CPResourceTask> task = [[CPResourceTask alloc] initCPResourceTask:engine horizon:horizon duration:duration durationArray:durationArray runsOnOneOf:resources];
    [engine trackMutable: task];
    return task;
}

+(id<CPConstraint>) constraint: (id<CPTaskVar>) before precedes:(id<CPTaskVar>) after
{
   id<CPEngine> engine = [before engine];
   id<CPConstraint> cstr = [[CPTaskPrecedence alloc] initCPTaskPrecedence: before after: after];
   [engine trackMutable: cstr];
   return cstr;
}
+(id<CPConstraint>) constraint: (id<CPTaskVar>) before optionalPrecedes:(id<CPTaskVar>) after
{
   id<CPEngine> engine = [before engine];
   id<CPConstraint> cstr = [[CPOptionalTaskPrecedence alloc] initCPOptionalTaskPrecedence: before after: after];
   [engine trackMutable: cstr];
   return cstr;
}
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task isFinishedBy: (id<CPIntVar>) date
{
   id<CPEngine> engine = [task engine];
   id<CPConstraint> cstr =[[CPTaskIsFinishedBy alloc] initCPTaskIsFinishedBy: task : date];
   [engine trackMutable: cstr];
   return cstr;
}
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task duration: (id<CPIntVar>) duration
{
   id<CPEngine> engine = [task engine];
   id<CPConstraint> cstr =[[CPTaskDuration alloc] initCPTaskDuration: task : duration];
   [engine trackMutable: cstr];
   return cstr;
}
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task presence: (id<CPIntVar>) presence
{
    id<CPEngine> engine = [task engine];
    id<CPConstraint> cstr =[[CPTaskPresence alloc] initCPTaskPresence: task : presence];
    [engine trackMutable: cstr];
    return cstr;
}
+(id<CPConstraint>) taskCumulative: (id<CPTaskVarArray>)tasks with: (id<CPIntVarArray>) usages and: (id<CPIntVar>) capacity
{
    id<CPConstraint> o = [[CPTaskCumulative alloc] initCPTaskCumulative: tasks with: usages and: capacity];
    [[tasks tracker] trackMutable:o];
    return o;
}
+(id<CPConstraint>) taskDisjunctive:(id<CPTaskVarArray>) tasks
{
   id<CPConstraint> o = [[CPTaskDisjunctive alloc] initCPTaskDisjunctive: tasks];
   [[tasks tracker] trackMutable: o];
   return o;
}
+(id<CPConstraint>) taskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ
{
   id<CPConstraint> o = [[CPTaskSequence alloc] initCPTaskSequence: tasks successors: succ];
   [[tasks tracker] trackMutable: o];
   return o;
}
+(id<CPConstraint>) constraint: (id<CPTaskVar>) normal extended:  (id<CPTaskVar>) extended time: (id<CPIntVar>) time
{
   id<CPConstraint> o = [[CPTaskAddTransitionTime alloc] initCPTaskAddTransitionTime: normal extended: extended time: time];
   [[normal tracker] trackMutable: o];
   return o;
}
@end
