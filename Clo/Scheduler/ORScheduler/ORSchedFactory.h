/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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

// Cumulative Resource constraints
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<ORIntVar>) c;
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r maxCapacity:(ORInt) c;
// Disjunctive Resource constraints
+(id<ORDisjunctive>) disjunctive: (id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d;
// Difference Logic constraints
+(id<ORDifference>) difference: (id<ORTracker>) model initWithCapacity:(ORInt) numItems;
// x <= y + d handled by the difference logic constraint
+(id<ORDiffLEqual>) diffLEqual: (id<ORDifference>) diff var: (id<ORIntVar>)x to: (id<ORIntVar>)y plus: (ORInt)d;
// b <-> x <= y + d handled by the difference logic constraint
+(id<ORDiffReifyLEqual>) diffReifyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d;
// b -> x <= y + d handled by the difference logic constraint
+(id<ORDiffImplyLEqual>) diffImplyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d;
@end
