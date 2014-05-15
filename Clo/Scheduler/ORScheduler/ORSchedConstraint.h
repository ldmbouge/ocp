/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>

@protocol ORPrecedes <ORConstraint>
-(id<ORActivity>) before;
-(id<ORActivity>) after;
@end

@protocol OROptionalPrecedes <ORConstraint>
-(id<OROptionalActivity>) before;
-(id<OROptionalActivity>) after;
@end

@protocol ORSchedulingCumulative <ORConstraint>
-(id<ORActivityArray>) activities;
-(id<ORIntArray>) usage;
-(id<ORIntVar>) capacity;
@end

@protocol ORCumulative <ORConstraint>
-(id<ORIntVarArray>) start;
-(id<ORIntVarArray>) duration;
-(id<ORIntArray>) usage;
-(id<ORIntVar>) capacity;
@end

@protocol ORSchedulingDisjunctive <ORConstraint>
-(id<ORActivityArray>) activities;
@end


@protocol ORDisjunctive <ORConstraint>
-(id<OROptionalActivityArray>) act;
-(id<ORIntVarArray>) start;
-(id<ORIntVarArray>) duration;
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
