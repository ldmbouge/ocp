/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORTypes.h>
#import <ORFoundation/ORData.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORArray.h>


@interface ORIntArrayI : ORObject<NSCoding,ORIntArray>
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb value: (ORInt) v;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb with: (ORInt(^)(ORInt)) clo;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORInt) v;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (ORInt(^)(ORInt)) clo;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with:(ORInt(^)(ORInt,ORInt)) clo;
-(void) dealloc;
-(ORInt) at: (ORInt) value;
-(void) set: (ORInt) value at:(ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(ORInt) max;
-(ORInt) min;
-(ORInt) average;
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(void)enumerateWith:(void(^)(ORInt obj,int idx))block;
-(ORInt) sumWith: (ORInt(^)(ORInt value,int idx))block;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
-(int*)base;
@end


@interface ORFloatArrayI : ORObject<NSCoding,ORFloatArray>
-(ORFloatArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb value: (ORFloat) v;
-(ORFloatArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb with: (ORFloat(^)(ORInt)) clo;
-(ORFloatArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORFloat) v;
-(ORFloatArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (ORFloat(^)(ORInt)) clo;
-(ORFloatArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with:(ORFloat(^)(ORInt,ORInt)) clo;
-(void) dealloc;
-(ORFloat) at: (ORInt) value;
-(void) set: (ORFloat) value at:(ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(ORFloat) max;
-(ORFloat) min;
-(ORFloat) average;
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(void)enumerateWith:(void(^)(ORFloat obj,int idx))block;
-(ORFloat) sumWith: (ORFloat(^)(ORFloat value,int idx))block;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORRationalArrayI : ORObject<NSCoding,ORRationalArray>
-(ORRationalArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb value: (ORRational) v;
-(ORRationalArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb with: (ORRational(^)(ORInt)) clo;
-(ORRationalArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORRational) v;
-(ORRationalArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (ORRational(^)(ORInt)) clo;
-(ORRationalArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with:(ORRational(^)(ORInt,ORInt)) clo;
-(void) dealloc;
-(ORRational) at: (ORInt) value;
-(void) set: (ORRational) value at:(ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(ORRational) max;
-(ORRational) min;
-(ORRational) average;
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(void)enumerateWith:(void(^)(ORRational obj,int idx))block;
-(ORRational) sumWith: (ORRational(^)(ORRational value,int idx))block;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORDoubleArrayI : ORObject<NSCoding,ORDoubleArray>
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb value: (ORDouble) v;
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb with: (ORDouble(^)(ORInt)) clo;
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORDouble) v;
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (ORDouble(^)(ORInt)) clo;
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with:(ORDouble(^)(ORInt,ORInt)) clo;
-(void) dealloc;
-(ORDouble) at: (ORInt) value;
-(void) set: (ORDouble) value at:(ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(ORDouble) max;
-(ORDouble) min;
-(ORDouble) average;
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(ORDouble obj,int idx))block;
-(ORDouble) sumWith: (ORDouble(^)(ORDouble value,int idx))block;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORLDoubleArrayI : ORObject<NSCoding,ORLDoubleArray>
-(ORLDoubleArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb value: (ORLDouble) v;
-(ORLDoubleArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb with: (ORLDouble(^)(ORInt)) clo;
-(ORLDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORLDouble) v;
-(ORLDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (ORLDouble(^)(ORInt)) clo;
-(ORLDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with:(ORLDouble(^)(ORInt,ORInt)) clo;
-(void) dealloc;
-(ORLDouble) at: (ORInt) value;
-(void) set: (ORLDouble) value at:(ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(ORLDouble) max;
-(ORLDouble) min;
-(ORLDouble) average;
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
-(void)enumerateWith:(void(^)(ORLDouble obj,int idx))block;
-(ORLDouble) sumWith: (ORLDouble(^)(ORLDouble value,int idx))block;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORIdArrayI : ORObject<NSCoding,NSCopying,ORIdArray>
-(ORIdArrayI*) initORIdArray: (id<ORTracker>)tracker range: (id<ORIntRange>) range;
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(ORBool) contains: (id)obj;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(id obj,int idx))block;
-(id<ORIdArray>) map:(id(^)(id obj, int idx))block;
-(NSArray*) toNSArray;
-(void)encodeWithCoder: (NSCoder*) aCoder;
-(id)initWithCoder: (NSCoder*) aDecoder;
-(void)visit:(ORVisitor*)v;
-(id*)base;
@end


@interface ORIntMatrixI : ORObject<ORIntMatrix,NSCoding>
-(ORIntMatrixI*) initORIntMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
-(ORIntMatrixI*) initORIntMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 with: (ORIntxInt2Int)block;
-(ORIntMatrixI*) initORIntMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
-(ORIntMatrixI*) initORIntMatrix: (id<ORTracker>) tracker with: (ORIntMatrixI*) matrix;
-(void) dealloc;
-(ORInt) at: (ORInt) i0 : (ORInt) i1;
-(ORInt) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1;
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger) count;
-(id<ORTracker>) tracker;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id)initWithCoder: (NSCoder*) aDecoder;
@end


@interface ORIdMatrixI : ORObject<NSCoding,ORIdMatrix>
{
   id<ORTracker>  _tracker;
}
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker arity: (ORInt) ar ranges: (id<ORIntRange>*) rs;
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker with: (ORIdMatrixI*) matrix;
-(void) dealloc;
-(ORInt) arity;
-(id) flat:(ORInt)i;
-(void) setFlat:(id) x at:(ORInt)i;
-(id) at: (ORInt) i0 : (ORInt) i1;
-(id) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i0 : (ORInt) i1;
-(void) set: (id) x at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(id<ORExpr>) elt: (id<ORExpr>) idx i1:(ORInt)i1;
-(id<ORExpr>) at: (ORInt) i0       elt:(id<ORExpr>)e1;
-(id<ORExpr>) elt: (id<ORExpr>)e0  elt:(id<ORExpr>)e1;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger) count;
-(void)encodeWithCoder: (NSCoder*) aCoder;
-(id)initWithCoder: (NSCoder*) aDecoder;
-(void)visit:(ORVisitor*)v;
-(id<ORIdArray>) flatten;
@end

