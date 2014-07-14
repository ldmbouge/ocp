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

@protocol ORTaskVar <ORVar>
-(id<ORTracker>) tracker;
-(id<ORIntRange>) horizon;
-(id<ORIntRange>) duration;
-(ORBool) isOptional;
-(id<ORTaskPrecedes>) precedes: (id<ORTaskVar>) after;
-(id<ORTaskIsFinishedBy>) isFinishedBy: (id<ORIntVar>) date;
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
