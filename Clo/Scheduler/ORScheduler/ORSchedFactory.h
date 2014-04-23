/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>

@interface ORFactory (ORScheduler)

// activities
+(id<ORActivity>) activity: (id<ORTracker>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
+(id<ORActivityArray>) activityArray: (id<ORTracker>) model range: (id<ORIntRange>) horizon with: (id<ORActivity>(^)(ORInt)) clo;
+(id<ORActivityArray>) activityArray: (id<ORTracker>) model range: (id<ORIntRange>) range horizon: (id<ORIntRange>) horizon duration: (id<ORIntArray>) duration;
+(id<ORActivityMatrix>) activityMatrix: (id<ORTracker>) model range: (id<ORIntRange>) horizon with: (id<ORActivity>(^)(ORInt,ORInt)) clo;
+(id<ORActivityMatrix>) activityMatrix: (id<ORTracker>) model range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
                               horizon: (id<ORIntRange>) horizon duration: (id<ORIntMatrix>) duration;
+(id<ORDisjunctiveResourceArray>) disjunctiveResourceArray: (id<ORTracker>) model range: (id<ORIntRange>) range;

// Precedence constraints
+(id<ORPrecedes>) precedence: (id<ORActivity>) before precedes:(id<ORActivity>) after;

// Cumulative Resource constraints
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<ORIntVar>) c;
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r maxCapacity:(ORInt) c;
+(id<ORSchedulingCumulative>) cumulative: (id<ORActivityArray>) act usage:(id<ORIntArray>) r maxCapacity:(ORInt) c;

// Disjunctive Resource constraint
+(id<ORDisjunctive>) disjunctive: (id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d;
+(id<ORSchedulingDisjunctive>) disjunctive: (id<ORActivityArray>) act;
+(id<ORDisjunctiveResource>) disjunctiveResource: (id<ORTracker>) model;

// Difference Logic constraints
+(id<ORDifference>) difference: (id<ORTracker>) model initWithCapacity:(ORInt) numItems;
// x <= y + d handled by the difference logic constraint
+(id<ORDiffLEqual>) diffLEqual: (id<ORDifference>) diff var: (id<ORIntVar>)x to: (id<ORIntVar>)y plus: (ORInt)d;
// b <-> x <= y + d handled by the difference logic constraint
+(id<ORDiffReifyLEqual>) diffReifyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d;
// b -> x <= y + d handled by the difference logic constraint
+(id<ORDiffImplyLEqual>) diffImplyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d;
@end
