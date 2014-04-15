/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORSchedConstraint.h>
#import "ORConstraintI.h"

@implementation ORFactory (ORScheduler)

+(id<ORDisjunctivePair>) disjunctivePair: (id<ORIntVar>) x duration: (ORInt) dx start: (id<ORIntVar>) y duration: (ORInt) dy;
{
    id<ORDisjunctivePair> o = [[ORDisjunctivePair alloc] initORDisjunctivePair: x duration: dx start: y duration: dy];
    [[x tracker] trackObject:o];
    return o;
}

// Cumulative (resource) constraint
//
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<ORIntVar>) c
{
    id<ORCumulative> o = [[ORCumulative alloc] initORCumulative:s duration:d usage:r capacity:c];
    [[s tracker] trackObject:o];
    return o;
}

// Disjunctive (resource) constraint
//
+(id<ORDisjunctive>) disjunctive: (id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d
{
    id<ORDisjunctive> o = [[ORDisjunctive alloc] initORDisjunctive:s duration:d];
    [[s tracker] trackObject:o];
    return o;
}

// Difference Logic constraint
+(id<ORDifference>) difference: (id<ORTracker>) model initWithCapacity:(ORInt) numItems
{
    id<ORDifference> o = [[ORDifference alloc] initORDifference: model initWithCapacity: numItems];
    [model trackObject:o];
    return o;
}

// x <= y + d handled by the difference logic constraint
+(id<ORDiffLEqual>) diffLEqual:(id<ORDifference>)diff var: (id<ORIntVar>)x to: (id<ORIntVar>)y plus: (ORInt)d
{
    id<ORDiffLEqual> o = [[ORDiffLEqual alloc] initORDiffLEqual:diff var:x to:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}

// b <-> x <= y + d handled by the difference logic constraint
+(id<ORDiffReifyLEqual>) diffReifyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d
{
    if (!b.isBool) {
        @throw [[ORExecutionError alloc] initORExecutionError: "diffReifyLEqual: b is not Boolean!"];
    }
    id<ORDiffReifyLEqual> o = [[ORDiffReifyLEqual alloc] initORDiffReifyLEqual:diff boolean:b with:x leqc:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}

// b -> x <= y + d handled by the difference logic constraint
+(id<ORDiffImplyLEqual>) diffImplyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d
{
    if (!b.isBool) {
        @throw [[ORExecutionError alloc] initORExecutionError: "diffImplyLEqual: b is not Boolean!"];
    }
    id<ORDiffImplyLEqual> o = [[ORDiffImplyLEqual alloc] initORDiffImplyLEqual:diff boolean:b with:x leqc:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}
@end
