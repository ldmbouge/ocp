/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

/*!
 *  @header
 *
 *  For information, contact <a href="http://org.nicta.com.au/people/andreas-schutt/">Andreas Schutt</a>.
 *
 *  @author Andreas Schutt and Pascal Van Hentenryck
 *  @copyright 2014-2015 NICTA
 *  @updated 2015-02-11
 */

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORTask.h>

/*!
 * @brief A precedence constraint.
 */
@protocol ORTaskPrecedes <ORConstraint>
/*!
 * @brief Retrieval of the task that must be completed before the other task can start.
 * @return A task variable.
 */
-(id<ORTaskVar>) before;
/*!
 * @brief Retrieval of the task that must start after the other task is completed.
 * @return A task variable.
 */
-(id<ORTaskVar>) after;
@end

@protocol ORTaskAddTransitionTime <ORConstraint>
-(id<ORTaskVar>) normal;
-(id<ORTaskVar>) extended;
-(id<ORIntVar>)  time;
@end

@protocol ORTaskIsFinishedBy <ORConstraint>
-(id<ORTaskVar>) task;
-(id<ORIntVar>) date;
@end

@protocol ORCumulative <ORConstraint>
-(id<ORIntVarArray>) start;
-(id<ORIntVarArray>) duration;
-(id<ORIntArray>) usage;
-(id<ORIntVar>) capacity;
@end

/*!
 * @brief A discrete cumulative resource constraint.
 */
@protocol ORTaskCumulative <ORConstraint>
/*!
 * @brief Adding a task requiring the cumulative resource.
 * @param act A task.
 * @param usage An integer variable representing possible resource unit required by the task.
 * @throws ORExecutionError when the cumulative resource constraint is closed.
 */
-(void) add: (id<ORTaskVar>) act with: (id<ORIntVar>) usage;
/*!
 * @brief Adding a resource task with a fixed duration that may require the cumulative resource.
 * @param act A resource task.
 * @param duration An integer.
 * @param usage An integer variable representing possible resource unit required by the task.
 * @throws ORExecutionError when the cumulative resource constraint is closed.
 */
-(void) add: (id<ORResourceTask>) act duration: (ORInt) duration with: (id<ORIntVar>) usage;
/*!
 * @brief Adding a resource task that may require the cumulative resource.
 * @param act A resource task.
 * @param duration An integer range with possible values for the duration.
 * @param usage An integer variable representing possible resource unit required by the task.
 * @throws ORExecutionError when the cumulative resource constraint is closed.
 */
-(void) add: (id<ORResourceTask>) act durationRange: (id<ORIntRange>) duration with: (id<ORIntVar>) usage;
-(id<ORTaskVarArray>) taskVars;
-(id<ORIntVarArray>) usages;
-(id<ORIntVar>) capacity;
@end

/*!
 * @brief A discrete disjunctive (unary) resource constraint.
 */
@protocol ORTaskDisjunctive <ORConstraint>
/*!
 * @brief Adding a task requiring the disjunctive resource.
 * @param act A task.
 * @throws ORExecutionError when the disjunctive resource constraint is closed.
 */
-(void) add: (id<ORTaskVar>) act;
/*!
 * @brief Adding a task requiring the disjunctive resource and having transition times.
 * @param act A task.
 * @param t An integer identifying the index of the task in the transition matrix.
 * @throws ORExecutionError when the disjunctive resource constraint is closed.
 */
-(void) add: (id<ORTaskVar>) act type: (ORInt) t;
/*!
 * @brief Adding a resource task with duration that may require the disjunctive resource.
 * @param act A resource task.
 * @param duration An integer representing the fixed duration.
 * @throws ORExecutionError when the disjunctive resource constraint is closed.
 */
-(void) add: (id<ORResourceTask>) act duration: (ORInt) duration;
/*!
 * @brief Adding a resource task with duration that may require the disjunctive resource.
 * @param act A resource task.
 * @param duration An integer range with possible values for the duration.
 * @throws ORExecutionError when the disjunctive resource constraint is closed.
 */
-(void) add: (id<ORResourceTask>) act durationRange: (id<ORIntRange>) duration;
-(id<ORTaskVarArray>) taskVars;
-(id<ORTaskVarArray>) transitionTaskVars;
-(ORBool) hasTransition;
-(id<ORIntMatrix>) extendedTransitionMatrix;
-(id<ORIntVarArray>) successors;
-(id<ORIntVarArray>) transitionTimes;
@end

@protocol ORTaskDisjunctiveArray <ORObject>
-(id<ORTaskDisjunctive>) at: (ORInt) idx;
-(void) set: (id<ORTaskDisjunctive>) value at: (ORInt)idx;
-(id<ORTaskDisjunctive>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORTaskDisjunctive>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORDifference <ORConstraint>
-(id<ORTracker>) tracker;
-(ORInt)         initCapacity;
@end

@protocol ORDiffLEqual <ORConstraint>
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORInt)        d;
-(id<ORDifference>) diff;
@end

@protocol ORDiffReifyLEqual <ORConstraint>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORInt)        d;
-(id<ORDifference>) diff;
@end

@protocol ORDiffImplyLEqual <ORConstraint>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORInt)        d;
-(id<ORDifference>) diff;
@end

@protocol ORSumTransitionTimes <ORConstraint>
-(id<ORTaskDisjunctive>) disjunctive;
-(id<ORIntVar>) ub;
@end

