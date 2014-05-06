/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORSchedConstraint.h>


// Precedence
@interface ORPrecedes : ORConstraintI<ORPrecedes>
-(id<ORPrecedes>) initORPrecedes:(id<ORActivity>) before precedes:(id<ORActivity>) after;
-(id<ORActivity>) before;
-(id<ORActivity>) after;
@end


// Cumulative (resource) constraint
@interface ORCumulative : ORConstraintI<ORCumulative>
-(id<ORCumulative>) initORCumulative:(id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d usage:(id<ORIntArray>) ru capacity:(id<ORIntVar>)c;
-(id<ORIntVarArray>) start;
-(id<ORIntVarArray>) duration;
-(id<ORIntArray>) usage;
-(id<ORIntVar>) capacity;
@end

@interface ORSchedulingCumulative : ORConstraintI<ORSchedulingCumulative>
-(id<ORSchedulingCumulative>) initORSchedulingCumulative:(id<ORActivityArray>) act usage:(id<ORIntArray>) ru capacity:(id<ORIntVar>)c;
-(id<ORActivityArray>) activities;
-(id<ORIntArray>) usage;
-(id<ORIntVar>) capacity;
@end


// Disjunctive (resource) constraint
@interface ORDisjunctive : ORConstraintI<ORDisjunctive>
-(id<ORDisjunctive>) initORDisjunctive:(id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d;
-(id<ORDisjunctive>) initORDisjunctive:(id<OROptionalActivityArray>) act;
-(id<OROptionalActivityArray>) act;
-(id<ORIntVarArray>) start;
-(id<ORIntVarArray>) duration;
@end

@interface ORSchedulingDisjunctive : ORConstraintI<ORSchedulingDisjunctive>
-(id<ORSchedulingDisjunctive>) initORSchedulingDisjunctive:(id<ORActivityArray>) act;
-(id<ORActivityArray>) activities;
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
