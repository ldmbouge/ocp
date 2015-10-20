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

#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>
#import <ORScheduler/ORSchedFactory.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORTask.h>

/*!
 * @brief The CP program for the scheduling modul.
 */
@protocol CPScheduler
/*!
 * @brief Labeling of one task.
 * @discussion The task's key attributs are labeled in following order.
 *      1. Assignment of the presence and then the absence on failure.
 *      2. Assignment of the start time by assigning the earliest start time and then excluding it on failure.
 *      3. Assignment of the duration starting with the smallest value and then excluding it on failure.
 * @param act A task variable.
 */
-(void) labelActivity: (id<ORTaskVar>) act;
/*!
 * @brief Labeling of one or more tasks.
 * @discussion The tasks are labeled in the order of their appearance in the 
 *      array started with the one at the smallest index.
 * @param act An array of task variables.
 */
-(void) labelActivities: (id<ORTaskVarArray>) act;
-(void) setAlternatives: (id<ORAlternativeTaskArray>) act;
-(void) assignAlternatives: (id<ORTaskVarArray>) act;
-(void) assignResources: (id<ORTaskVarArray>) act;
/*!
 * @brief Labeling of one or more tasks using dominance rules on failure.
 * @discussion The present tasks are labeled in the order of their earliest start time 
 *      by assigning the earliest start time to the task's start. On failure, the 
 *      task is post-poned the next earliest completion time of another task.
 * @param act An array of task variables.
 * @throws ORExecutionError when a task is neither present nor absent or its duration is unbounded.
 */
-(void) setTimes: (id<ORTaskVarArray>) act;
-(void) sequence: (id<ORIntVarArray>) succ by: (ORInt2Double) o;
-(void) sequence: (id<ORIntVarArray>) succ by: (ORInt2Double) o1 then: (ORInt2Double) o2;
//-(void) labelTimes: (id<ORActivityArray>) act;

/*!
 * @brief Retrieval of the earliest start time of a task.
 * @param task A task variable.
 * @return The earliest start time.
 */
-(ORInt) est: (id<ORTaskVar>) task;
/*!
 * @brief Retrieval of the earliest completion time of a task.
 * @param task A task variable.
 * @return The earliest completion time.
 */
-(ORInt) ect: (id<ORTaskVar>) task;
/*!
 * @brief Retrieval of the latest start time of a task.
 * @param task A task variable.
 * @return The latest start time.
 */
-(ORInt) lst: (id<ORTaskVar>) task;
/*!
 * @brief Retrieval of the latest completion time of a task.
 * @param task A task variable.
 * @return The latest completion time.
 */
-(ORInt) lct: (id<ORTaskVar>) task;
/*!
 * @brief Retrieval of the presence a task.
 * @param task A task variable.
 * @return The presence of a task. If 1 then the task is present, and if 0 then the task is present (yet).
 */
-(ORInt) isPresent: (id<ORTaskVar>) task;
/*!
 * @brief Retrieval of the absence a task.
 * @param task A task variable.
 * @return The absence of a task. If 1 then the task is absent, and if 0 then the task is absent (yet).
 */
-(ORInt) isAbsent: (id<ORTaskVar>) task;
-(id<ORConstraint>) runsOnResource: (id<ORResourceTask>) task;
/*!
 * @brief Retrieval whether a task is bounded.
 * @discussion A task is bounded if the start and end time are bounded when it is present, or the task is absent.
 *      An alternative and span task additionally requires that its constituent tasks are bounded, too, if present.
 *      A resource task additionally requires that it is assigned to one resource if present.
 * @param task A task variable.
 * @return True if the task is bounded and False otherwise.
 */
-(ORBool) boundActivity: (id<ORTaskVar>) task;
/*!
 * @brief Retrieval of the minimal duration of a task.
 * @param task A task variable.
 * @return The minimal duration.
 */
-(ORInt) minDuration: (id<ORTaskVar>) task;
/*!
 * @brief Retrieval of the maximal duration of a task.
 * @param task A task variable.
 * @return The maximal duration.
 */
-(ORInt) maxDuration: (id<ORTaskVar>) task;
-(void) updateStart: (id<ORTaskVar>) task with: (ORInt) newStart;
-(void) updateEnd: (id<ORTaskVar>) task with: (ORInt) newEnd;
-(void) updateMinDuration: (id<ORTaskVar>) task with: (ORInt) newMinDuration;
-(void) updateMaxDuration: (id<ORTaskVar>) task with: (ORInt) newMaxDuration;

/*!
 * @brief Labeling of the start time of a task.
 * @discussion The start time is assigned to the earliest start time and then this time is excluded on failure.
 * @param task A task variable.
 */
-(void) labelStart: (id<ORTaskVar>) task;
/*!
 * @brief Assigning of a time to the start time of a task.
 * @discussion The start time is assigned to the provided start.
 * @param task A task variable.
 * @param start An integer.
 */
-(void) labelStart: (id<ORTaskVar>) task with: (ORInt) start;
/*!
 * @brief Labeling of the end time of a task.
 * @discussion The end time is assigned to the earliest completion time and then this time is excluded on failure.
 * @param task A task variable.
 */
-(void) labelEnd: (id<ORTaskVar>) task;
/*!
 * @brief Assigning of a time to the end time of a task.
 * @discussion The end time is assigned to the provided end.
 * @param task A task variable.
 * @param end An integer.
 */
-(void) labelEnd: (id<ORTaskVar>) task with: (ORInt) end;
/*!
 * @brief Labeling of the duration of a task.
 * @discussion The duration is assigned to the smallest one at first and then this duration is excluded on failure.
 * @param task A task variable.
 */
-(void) labelDuration: (id<ORTaskVar>) task;
/*!
 * @brief Assigning of the duration of a task.
 * @param task A task variable.
 * @param duration An integer to be assigned to the duration.
 */
-(void) labelDuration: (id<ORTaskVar>) task with: (ORInt) duration;
/*!
 * @brief Labeling of the presence of a task.
 * @discussion Assignment of the presence and then the absence on failure.
 * @param task A task variable.
 */
-(void) labelPresent: (id<ORTaskVar>) task;
/*!
 * @brief Assigning the presence or absence of a task.
 * @param task A task variable.
 * @param present A Boolean parameter where true (false) represents the presence (absence) of a task.
 */
-(void) labelPresent: (id<ORTaskVar>) task with: (ORBool) present;
-(ORInt) globalSlack: (id<ORTaskDisjunctive>) d;
-(ORInt) localSlack: (id<ORTaskDisjunctive>) d;

-(NSString*) description: (id<ORObject>) o;
@end

@protocol CPSchedulerSolution
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






