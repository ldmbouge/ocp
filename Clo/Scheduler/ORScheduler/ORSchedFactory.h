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
+(id<ORTaskVar>) optionalTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;

// Task array
+(id<ORTaskVarArray>) taskVarArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORTaskVar>(^)(ORInt)) clo;
+(id<ORTaskVarArray>) taskVarArray: (id<ORTracker>) model range: (id<ORIntRange>) range horizon: (id<ORIntRange>) horizon duration: (id<ORIntArray>) duration;

// Task matrix
+(id<ORTaskVarMatrix>) taskVarMatrix: (id<ORTracker>) model range: (id<ORIntRange>) horizon with: (id<ORTaskVar>(^)(ORInt,ORInt)) clo;
+(id<ORTaskVarMatrix>) taskVarMatrix: (id<ORTracker>) model range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
                               horizon: (id<ORIntRange>) horizon duration: (id<ORIntMatrix>) duration;

+(id<ORTaskDisjunctiveArray>) taskDisjunctiveArray: (id<ORTracker>) model range: (id<ORIntRange>) range;

// Cumulative Resource constraints
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<ORIntVar>) c;
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r maxCapacity:(ORInt) c;

// Disjunctive Resource constraint
+(id<ORTaskDisjunctive>) taskDisjunctive: (id<ORTaskVarArray>) task;
+(id<ORTaskDisjunctive>) disjunctiveConstraint: (id<ORTracker>) model;

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

@end
