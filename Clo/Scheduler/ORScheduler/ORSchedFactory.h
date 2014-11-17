/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORTask.h>
#import <ORScheduler/ORSchedConstraint.h>

@interface ORFactory (ORScheduler)

// Activities (non-optional and optional)
//+(id<ORActivity>) activity: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORActivity>(^)(ORInt)) clo;
//+(id<ORActivity>) activity: (id<ORModel>) model range: (id<ORIntRange>) range withSpan: (id<ORActivity>(^)(ORInt)) clo;
//+(id<ORActivity>) optionalActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
//+(id<ORActivity>) optionalActivity: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORActivity>(^)(ORInt)) clo;
//+(id<ORActivity>) optionalActivity: (id<ORModel>) model range: (id<ORIntRange>) range withSpan: (id<ORActivity>(^)(ORInt)) clo;

+(id<ORTaskVar>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
+(id<ORTaskVar>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon durationRange: (id<ORIntRange>) duration;
+(id<ORTaskVar>) optionalTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;

+(id<ORAlternativeTask>) task: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORTaskVar>(^)(ORInt)) clo;
+(id<ORAlternativeTask>) optionalTask: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORTaskVar>(^)(ORInt)) clo;

+(id<ORMachineTask>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon range: (id<ORIntRange>) range runsOnOneOf: (id<ORTaskDisjunctive>(^)(ORInt)) cloDisjunctives withDuration: (ORInt(^)(ORInt)) cloDurations;
+(id<ORMachineTask>) machineTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon;

+(id<ORResourceTask>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon range: (id<ORIntRange>) range runsOnOneOfResource: (id<ORConstraint>(^)(ORInt)) cloResources withDuration: (ORInt(^)(ORInt)) cloDurations;
+(id<ORResourceTask>) resourceTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon;
+(id<ORResourceTask>) optionalTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon range: (id<ORIntRange>) range runsOnOneOfResource: (id<ORConstraint>(^)(ORInt)) cloResources withDuration: (ORInt(^)(ORInt)) cloDurations;
+(id<ORResourceTask>) optionalResourceTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon;

// Alternative Task array
+(id<ORAlternativeTaskArray>) alternativeVarArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORAlternativeTask>(^)(ORInt)) clo;

// Task array
+(id<ORTaskVarArray>) taskVarArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORTaskVar>(^)(ORInt)) clo;
+(id<ORTaskVarArray>) taskVarArray: (id<ORTracker>) model range: (id<ORIntRange>) range horizon: (id<ORIntRange>) horizon duration: (id<ORIntArray>) duration;
+(id<ORTaskVarArray>) taskVarArray: (id<ORTracker>) model range: (id<ORIntRange>) range horizon: (id<ORIntRange>) horizon range: (id<ORIntRange>) duration;

// Task matrix
+(id<ORTaskVarMatrix>) taskVarMatrix: (id<ORTracker>) model range: (id<ORIntRange>) horizon with: (id<ORTaskVar>(^)(ORInt,ORInt)) clo;
+(id<ORTaskVarMatrix>) taskVarMatrix: (id<ORTracker>) model range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
                               horizon: (id<ORIntRange>) horizon duration: (id<ORIntMatrix>) duration;



// Cumulative Resource constraints
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<ORIntVar>) c;
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r maxCapacity:(ORInt) c;
+(id<ORTaskCumulative>) cumulative: (id<ORTaskVarArray>) task with: (id<ORIntVarArray>) usage and: (id<ORIntVar>) capacity;
+(id<ORTaskCumulative>) cumulativeConstraint: (id<ORIntVar>) capacity;

// Disjunctive Resource constraint
+(id<ORTaskDisjunctive>) disjunctive: (id<ORTaskVarArray>) task;
+(id<ORTaskDisjunctive>) disjunctiveConstraint: (id<ORTracker>) model;
+(id<ORTaskDisjunctive>) disjunctiveConstraint: (id<ORTracker>) model transition: (id<ORIntMatrix>) matrix;

+(id<ORTaskDisjunctiveArray>) disjunctiveArray: (id<ORTracker>) model range: (id<ORIntRange>) range;
+(id<ORTaskDisjunctiveArray>) disjunctiveArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORTaskDisjunctive>(^)(ORInt)) clo;
+(id<ORResourceArray>) resourceArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORConstraint>(^)(ORInt)) clo;

// Difference Logic constraints
+(id<ORDifference>) difference: (id<ORTracker>) model initWithCapacity:(ORInt) numItems;
// x <= y + d handled by the difference logic constraint
+(id<ORDiffLEqual>) diffLEqual: (id<ORDifference>) diff var: (id<ORIntVar>)x to: (id<ORIntVar>)y plus: (ORInt)d;
// b <-> x <= y + d handled by the difference logic constraint
+(id<ORDiffReifyLEqual>) diffReifyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d;
// b -> x <= y + d handled by the difference logic constraint
+(id<ORDiffImplyLEqual>) diffImplyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d;

// Precedence constraints
+(id<ORTaskPrecedes>) constraint: (id<ORTaskVar>) before precedes: (id<ORTaskVar>) after;
+(id<ORTaskIsFinishedBy>) constraint: (id<ORTaskVar>) task isFinishedBy: (id<ORIntVar>) date;
+(id<ORTaskDuration>) constraint: (id<ORTaskVar>) task duration: (id<ORIntVar>) duration;
+(id<ORTaskAddTransitionTime>) constraint: (id<ORTaskVar>) normal extended:  (id<ORTaskVar>) extended time: (id<ORIntVar>) time;
+(id<ORSumTransitionTimes>) sumTransitionTimes: (id<ORTaskDisjunctive>) disjunctive leq: (id<ORIntVar>) sumTransitionTimes;
@end
