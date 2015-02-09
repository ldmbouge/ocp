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

/*!
 * @brief Creation of a standard task that is <b>compulsory</b> and has a fixed duration.
 *
 * @param model A model to that the task is created in.
 * @param horizon A planning horizon in that the task must be executed.
 * @param duration  A fixed duration (processing time) of the task.
 *
 * @return A standard task variable.
 */
+(id<ORTaskVar>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;

/*!
 * @brief Creation of a standard task that is <b>compulsory</b>.
 *
 * @param model A model to that the task is created in.
 * @param horizon A planning horizon in that the task must be executed.
 * @param duration An integer range of possible durations of the task.
 *
 * @return A standard task variable.
 */
+(id<ORTaskVar>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon durationRange: (id<ORIntRange>) duration;

/*!
 * @brief Creation of a standard task that is <b>optional</b> and has a fixed duration.
 *
 * @param model A model to that the task is created in.
 * @param horizon A planning horizon in that the task must be executed.
 * @param duration  A fixed duration (processing time) of the task.
 *
 * @return A standard task variable.
 */
+(id<ORTaskVar>) optionalTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;

/*!
 * @brief Creation of a standard task that is <b>optional</b>.
 *
 * @param model A model to that the task is created in.
 * @param horizon A planning horizon in that the task must be executed.
 * @param duration An integer range of possible durations of the task.
 *
 * @return A standard task variable.
 */
+(id<ORTaskVar>) optionalTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon durationRange: (id<ORIntRange>) duration;

/*!
 * @brief Creation of an alternative task that is <b>compulsory</b> and made of exactly one of the tasks passed by.
 * @discussion One of the task variables passed by is chosen or inferred for execution, whereas the other won't be executed.
 *      The start time and duration of the alternative task and its chosen task are the same.
 *
 * @param model A model to that the task is created in.
 * @param range An integer range for calling the closure.
 * @param clo A closure returning task variables.
 *
 * @return An alternative task variable.
 */
+(id<ORAlternativeTask>) task: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORTaskVar>(^)(ORInt)) clo;

/*!
 * @brief Creation of an alternative task that is <b>optional</b> and might be made of exactly one of the tasks passed by.
 * @discussion If the alternative task is absent then all tasks passed by, too, and vice versa. If the alternative task is present
 *      then excatly one task passed by, too, and vice versa. The start time and duration of a present alternative task are equal
 *      to the start time and duration of the present task passed by.
 *
 * @param model A model to that the task is created in.
 * @param range An integer range for calling the closure.
 * @param clo A closure returning task variables.
 *
 * @return An alternative task variable.
 */
+(id<ORAlternativeTask>) optionalTask: (id<ORModel>) model range: (id<ORIntRange>) range withAlternatives: (id<ORTaskVar>(^)(ORInt)) clo;

/*!
 * @brief Creation of a span task that is <b>compulsory</b> and composed of other tasks.
 * @discussion One or more than one tasks passed by are executed. The start time and duration of the span task is equal to
 *      the earliest start time of the present tasks passed by and the difference of the latest completion time and the
 *      earliest start time of the present tasks passed by, respectively.
 *
 * @param model A model to that the task is created in.
 * @param range An integer range for calling the closure.
 * @param clo A closure returning task variables.
 *
 * @return A span task variable.
 */
+(id<ORSpanTask>) task: (id<ORModel>) model range: (id<ORIntRange>) range withSpans: (id<ORTaskVar>(^)(ORInt)) clo;

/*!
 * @brief Creation of a span task that is <b>optional</b> and composed of other tasks.
 * @discussion One or more than one tasks passed by are executed. The start time and duration of the span task is equal to
 *      the earliest start time of the present tasks passed by and the difference of the latest completion time and the
 *      earliest start time of the present tasks passed by, respectively.
 *
 * @param model A model to that the task is created in.
 * @param range An integer range for calling the closure.
 * @param clo A closure returning task variables.
 *
 * @return A span task variable.
 */
+(id<ORSpanTask>) optionalTask: (id<ORModel>) model range: (id<ORIntRange>) range withSpans: (id<ORTaskVar>(^)(ORInt)) clo;


// Resource activities
+(id<ORResourceTask>) task: (id<ORModel>) model horizon: (id<ORIntRange>) horizon range: (id<ORIntRange>) range runsOnOneOfResource: (id<ORConstraint>(^)(ORInt)) cloResources withDuration: (id<ORIntRange>(^)(ORInt)) cloDurations;
+(id<ORResourceTask>) resourceTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
+(id<ORResourceTask>) optionalTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon range: (id<ORIntRange>) range runsOnOneOfResource: (id<ORConstraint>(^)(ORInt)) cloResources withDuration: (ORInt(^)(ORInt)) cloDurations;
+(id<ORResourceTask>) optionalResourceTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;

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

/*!
 * @brief Creation of a <b>closed</b> cumulative resource constraints with a fixed number of tasks.
 * 
 * @param task An array of task variables requiring the resource for their execution.
 * @param usage An array of finite resource usages for all tasks on the resource.
 * @param capacity The maximal capacity of the resource, which is positive.
 *
 * @return A cumulative resource constraint.
 */
+(id<ORTaskCumulative>) cumulative: (id<ORTaskVarArray>) task with: (id<ORIntVarArray>) usage and: (id<ORIntVar>) capacity;

/*!
 * @brief Creation of an <b>open</b> cumulative resource constraints.
 *
 * @param capacity The maximal capacity of the resource, which is positive.
 *
 * @return A cumulative resource constraint.
 */
+(id<ORTaskCumulative>) cumulativeConstraint: (id<ORIntVar>) capacity;

// Disjunctive Resource constraint
/*!
 * @brief Creation of an <b>closed</b> disjunctive (also called unary) resource constraints with a fixed number of tasks.
 *
 * @param task An array of task variables requiring the resource for their execution.
 *
 * @return A disjunctive resource constraint.
 */
+(id<ORTaskDisjunctive>) disjunctive: (id<ORTaskVarArray>) task;

/*!
 * @brief Creation of an <b>open</b> disjunctive (also called unary) resource constraints.
 *
 * @param model A model to which the resource constraint belongs.
 *
 * @return A disjunctive resource constraint.
 */
+(id<ORTaskDisjunctive>) disjunctiveConstraint: (id<ORTracker>) model;

/*!
 * @brief Creation of an <b>open</b> disjunctive (also called unary) resource constraints.
 *
 * @param model A model to which the resource constraint belongs.
 * @param matrix A transition matrix containing the transition times between pairs of tasks.
 *
 * @return A disjunctive resource constraint.
 */
+(id<ORTaskDisjunctive>) disjunctiveConstraint: (id<ORTracker>) model transition: (id<ORIntMatrix>) matrix;

/*!
 * @brief Creation of an array containing new <b>open</b> disjunctive resources constraints.
 *
 * @param model A model to which the array and the resource constraint belong.
 * @param range An integer range defining the index set of the array.
 *
 * @return An array with new open disjunctive resources.
 */
+(id<ORTaskDisjunctiveArray>) disjunctiveArray: (id<ORTracker>) model range: (id<ORIntRange>) range;

/*!
 * @brief Creation of an array from existing disjunctive resources constraints.
 *
 * @param model A model to which the array and the resource constraint belong.
 * @param range An integer range to be used for calling the closure.
 * @param clo A closure returning disjunctive resource constraints.
 *
 * @return An array with existing disjunctive resource constraints.
 */
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
/*!
 * @brief Creation of a precedence constraints between two tasks.
 *
 * @param before A task that needs to be completed before the other one can be started.
 * @param after A task that can only be started after the other one is completed.
 *
 * @return A precedence constraint.
 */
+(id<ORTaskPrecedes>) constraint: (id<ORTaskVar>) before precedes: (id<ORTaskVar>) after;

/*!
 * @brief Creation of a constraint imposing a flexible deadline on a task.
 *
 * @param task A task variable.
 * @param date An integer variable defining a flexible deadline.
 *
 * @return A constraint.
 */
+(id<ORTaskIsFinishedBy>) constraint: (id<ORTaskVar>) task isFinishedBy: (id<ORIntVar>) date;
+(id<ORTaskAddTransitionTime>) constraint: (id<ORTaskVar>) normal extended:  (id<ORTaskVar>) extended time: (id<ORIntVar>) time;

/*!
 * @brief Creation of a constraint imposing an upper bound on the sum of transition times for a disjunctive resource constraint.
 *
 * @param disjunctive A disjunctive resource constraint.
 * @param sumTransitionTimes A flexible upper bound for the total transition times.
 *
 * @return A constraint.
 */
+(id<ORSumTransitionTimes>) sumTransitionTimes: (id<ORTaskDisjunctive>) disjunctive leq: (id<ORIntVar>) sumTransitionTimes;

// Miscellaneous
+(id<ORIntRangeArray>) intRangeArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORIntRange>(^)(ORInt)) clo;
@end
