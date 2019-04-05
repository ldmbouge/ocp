/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

//#import <ORUtilities/ORTypes.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORTrailable.h>
#import <ORFoundation/ORSet.h>

@protocol ORExpr;

PORTABLE_BEGIN

@protocol ORIntArray <ORObject>
-(ORInt) at: (ORInt) value;
-(void) set: (ORInt) value at: (ORInt) idx;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(ORInt) low;
-(ORInt) up;
-(ORInt) max;
-(ORInt) min;
-(ORInt) average;
-(ORInt) sum;
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
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(ORInt) low;
-(ORInt) up;
-(ORFloat) max;
-(ORFloat) min;
-(ORFloat) average;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(ORFloat obj,int idx))block;
-(ORFloat) sumWith: (ORFloat(^)(ORFloat value,int idx))block;
@end

@protocol ORRationalArray <ORObject>
-(id<ORRational>) at: (ORInt) value;
-(void) set: (id<ORRational>) value at: (ORInt) idx;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORRational>) max;
-(id<ORRational>) min;
-(id<ORRational>) average;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(id<ORRational> obj,int idx))block;
-(id<ORRational>) sumWith: (id<ORRational>(^)(id<ORRational> value,int idx))block;
@end

@protocol ORDoubleArray <ORObject>
-(ORDouble) at: (ORInt) value;
-(void) set: (ORDouble) value at: (ORInt) idx;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(ORInt) low;
-(ORInt) up;
-(ORDouble) max;
-(ORDouble) min;
-(ORDouble) average;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(ORDouble obj,int idx))block;
@end

@protocol ORLDoubleArray <ORObject>
-(ORLDouble) at: (ORInt) value;
-(void) set: (ORLDouble) value at: (ORInt) idx;
-(ORInt) low;
-(ORInt) up;
-(ORLDouble) max;
-(ORLDouble) min;
-(ORLDouble) average;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(void)enumerateWith:(void(^)(ORLDouble obj,int idx))block;
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
-(id)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id)newValue atIndexedSubscript:(NSUInteger)idx;
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

