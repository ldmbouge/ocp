/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORData.h>

@protocol ORExpr;
@protocol ORIntSet;
@protocol ORIntRange;

PORTABLE_BEGIN

@protocol ORIntArray <ORObject>
-(ORInt) at: (ORInt) value;
-(void) set: (ORInt) value at: (ORInt) idx;
-(id)objectAtIndexedSubscript: (NSInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSInteger) idx;
-(ORInt) low;
-(ORInt) up;
-(ORInt) max;
-(ORInt) min;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(ORInt obj,int idx))block;
-(ORInt) sumWith: (ORInt(^)(ORInt value,int idx))block;
@end

@protocol ORFloatArray <ORObject>
-(ORFloat) at: (ORInt) value;
-(void) set: (ORFloat) value at: (ORInt) idx;
-(ORInt) low;
-(ORInt) up;
-(ORFloat) max;
-(ORFloat) min;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(ORFloat obj,int idx))block;
@end

@protocol ORDoubleArray <ORObject>
-(ORDouble) at: (ORInt) value;
-(void) set: (ORDouble) value at: (ORInt) idx;
-(ORInt) low;
-(ORInt) up;
-(ORDouble) max;
-(ORDouble) min;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(ORDouble obj,int idx))block;
@end

@protocol ORIntRangeArray <ORObject>
-(id<ORIntRange>) at: (ORInt) value;
-(void) set: (id<ORIntRange>) value at: (ORInt) idx;
-(id<ORIntRange>)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id<ORIntRange>) newValue atIndexedSubscript: (NSUInteger) idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(void)enumerateWith:(void(^)(ORInt obj,int idx))block;
@end

@protocol ORIntSetArray <ORObject>
-(id<ORIntSet>) at: (ORInt) idx;
-(void) set: (id<ORIntSet>) value at: (ORInt)idx;
-(id<ORIntSet>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORIntSet>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORIdArray <ORObject,NSFastEnumeration>
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(id)objectAtIndexedSubscript:(ORInt)key;
-(void)setObject:(id)newValue atIndexedSubscript:(ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(ORBool) contains: (id)obj;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(void)enumerateWith:(void(^)(id obj,int idx))block;
-(id<ORIdArray>) map:(id(^)(id obj, int idx))block;
-(NSArray*) toNSArray;
@end

@protocol ORIdMatrix <ORObject>
-(id) flat:(ORInt)i;
-(id) at: (ORInt) i1 : (ORInt) i2;
-(id) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) setFlat:(id) x at:(ORInt)i;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(ORInt) arity;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORIdArray>) flatten;
@end

@protocol ORIntMatrix <ORObject>
-(ORInt) at: (ORInt) i1 : (ORInt) i2;
-(ORInt) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (ORInt) value at: (ORInt) i1 : (ORInt) i2;
-(void) set: (ORInt) value at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORTrailableIntArray <ORObject>
-(id<ORTrailableInt>) at: (ORInt) idx;
-(void) set: (id<ORTrailableInt>) value at: (ORInt)idx;
-(id<ORTrailableInt>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORIntSet>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

PORTABLE_END

