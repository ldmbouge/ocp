/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@protocol ORTaskPrecedes;
@protocol ORTaskIsFinishedBy;
@protocol ORTaskVarArray;
@protocol ORResourceArray;

@protocol ORTaskVar <ORVar>
-(id<ORTracker>) tracker;
-(id<ORIntRange>) horizon;
-(id<ORIntRange>) duration;
-(ORBool) isOptional;
-(id<ORTaskPrecedes>) precedes: (id<ORTaskVar>) after;
-(id<ORTaskIsFinishedBy>) isFinishedBy: (id<ORIntVar>) date;
-(id<ORIntVar>) getPresenceVar;
@end

@protocol ORAlternativeTask <ORTaskVar>
-(id<ORTaskVarArray>) alternatives;
@end

@protocol ORSpanTask <ORTaskVar>
-(id<ORTaskVarArray>) compound;
@end

@protocol ORResourceTask <ORTaskVar>
-(id<ORResourceArray>) resources;
-(id<ORIntRangeArray>) durationArray;
-(void) addResource: (id<ORConstraint>) resource with: (id<ORIntRange>) duration;
-(ORInt) getIndex: (id<ORConstraint>) resource;
-(void) close;
@end

@protocol ORTaskVarArray <ORObject>
-(id<ORTaskVar>) at: (ORInt) idx;
-(void) set: (id<ORTaskVar>) value at: (ORInt)idx;
-(id<ORTaskVar>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORTaskVar>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORTaskVarMatrix <ORObject>
-(id) flat:(ORInt)i;
-(id<ORTaskVar>) at: (ORInt) i1 : (ORInt) i2;
-(id<ORTaskVar>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) setFlat:(id<ORTaskVar>) x at:(ORInt)i;
-(void) set: (id<ORTaskVar>) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id<ORTaskVar>) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(ORInt) arity;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORTaskVarArray>) flatten;
@end

@protocol ORTaskVarSnapshot
-(ORInt) ect;
@end;

@protocol ORAlternativeTaskArray <ORObject>
-(id<ORAlternativeTask>) at: (ORInt) idx;
-(void) set: (id<ORAlternativeTask>) value at: (ORInt)idx;
-(id<ORAlternativeTask>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORAlternativeTask>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORResourceArray <ORObject>
-(id<ORConstraint>) at: (ORInt) idx;
-(void) set: (id<ORConstraint>) value at: (ORInt)idx;
-(id<ORConstraint>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORConstraint>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end
