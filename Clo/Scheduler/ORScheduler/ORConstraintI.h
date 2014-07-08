/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORSchedConstraint.h>


@interface ORTaskPrecedes : ORConstraintI<ORTaskPrecedes>
-(id<ORTaskPrecedes>) initORTaskPrecedes:(id<ORTaskVar>) before precedes:(id<ORTaskVar>) after;
-(id<ORTaskVar>) before;
-(id<ORTaskVar>) after;
@end

@interface ORTaskIsFinishedBy : ORConstraintI<ORTaskIsFinishedBy>
-(id<ORTaskIsFinishedBy>) initORTaskIsFinishedBy:(id<ORTaskVar>) task isFinishedBy:(id<ORIntVar>) date;
-(id<ORTaskVar>) task;
-(id<ORIntVar>) date;
@end

// Cumulative (resource) constraint
@interface ORCumulative : ORConstraintI<ORCumulative>
-(id<ORCumulative>) initORCumulative:(id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d usage:(id<ORIntArray>) ru capacity:(id<ORIntVar>)c;
-(id<ORIntVarArray>) start;
-(id<ORIntVarArray>) duration;
-(id<ORIntArray>) usage;
-(id<ORIntVar>) capacity;
@end

@interface ORTaskDisjunctive : ORConstraintI<ORTaskDisjunctive>
-(id<ORTaskDisjunctive>) initORTaskDisjunctive:(id<ORTaskVarArray>) tasks;
-(id<ORTaskDisjunctive>) initORTaskDisjunctiveEmpty: (id<ORTracker>) tracker;
-(id<ORTaskVarArray>) taskVars;
-(void) isRequiredBy: (id<ORTaskVar>) act;
@end

// Difference logic constraint
@interface ORDifference : ORConstraintI<ORDifference>
-(id<ORDifference>) initORDifference:(id<ORTracker>) model initWithCapacity:(ORInt) numItems;
-(id<ORTracker>) tracker;
-(ORInt)         initCapacity;
@end

// x <= y + d
@interface ORDiffLEqual : ORConstraintI<ORDiffLEqual>
-(id<ORDiffLEqual>) initORDiffLEqual:(id<ORDifference>)diff var:(id<ORIntVar>)x to:(id<ORIntVar>)y plus:(ORInt)d;
-(id<ORIntVar>)     x;
-(id<ORIntVar>)     y;
-(ORInt)            d;
-(id<ORDifference>) diff;
@end

// b <-> x <= y + d
@interface ORDiffReifyLEqual : ORConstraintI<ORDiffReifyLEqual>
-(id<ORDiffLEqual>) initORDiffReifyLEqual:(id<ORDifference>)diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus:(ORInt)d;
-(id<ORIntVar>)     b;
-(id<ORIntVar>)     x;
-(id<ORIntVar>)     y;
-(ORInt)            d;
-(id<ORDifference>) diff;
@end

// b -> x <= y + d
@interface ORDiffImplyLEqual : ORConstraintI<ORDiffImplyLEqual>
-(id<ORDiffLEqual>) initORDiffImplyLEqual:(id<ORDifference>)diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus:(ORInt)d;
-(id<ORIntVar>)     b;
-(id<ORIntVar>)     x;
-(id<ORIntVar>)     y;
-(ORInt)            d;
-(id<ORDifference>) diff;
@end
