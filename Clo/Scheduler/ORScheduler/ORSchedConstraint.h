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


@protocol ORTaskPrecedes <ORConstraint>
-(id<ORTaskVar>) before;
-(id<ORTaskVar>) after;
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

@protocol ORTaskDisjunctive <ORConstraint>
-(void) add: (id<ORTaskVar>) act;
-(id<ORTaskVarArray>) taskVars;
@end

@protocol ORTaskSequence <ORConstraint>
-(void) add: (id<ORTaskVar>) act;
-(id<ORTaskVarArray>) taskVars;
-(id<ORIntVarArray>) successors;
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

@protocol ORTaskSequenceArray <ORObject>
-(id<ORTaskSequence>) at: (ORInt) idx;
-(void) set: (id<ORTaskDisjunctive>) value at: (ORInt)idx;
-(id<ORTaskSequence>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORTaskSequence>)newValue atIndexedSubscript:(NSUInteger)idx;
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
