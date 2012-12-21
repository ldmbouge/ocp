/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORTypes.h"
#import "ORObject.h"
#import "ORData.h"
#import "ORTracker.h"
#import "ORArray.h"

@protocol ORVisitor;

@interface ORIntArrayI : ORDualUseObjectI<NSCoding,ORIntArray>
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
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(ORInt obj,int idx))block;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORIdArrayI : ORDualUseObjectI<NSCoding,ORIdArray>
{

}
-(ORIdArrayI*) initORIdArray: (id<ORTracker>)tracker range: (id<ORIntRange>) range;
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(void)enumerateWith:(void(^)(id obj,int idx))block;
-(void)encodeWithCoder: (NSCoder*) aCoder;
-(id)initWithCoder: (NSCoder*) aDecoder;
-(void)visit:(id<ORVisitor>)v;
@end


@interface ORIntMatrixI : ORDualUseObjectI<ORIntMatrix,NSCoding>
-(ORIntMatrixI*) initORIntMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
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


@interface ORIdMatrixI : ORModelingObjectI<NSCoding,ORIdMatrix>
{
   id<ORTracker>  _tracker;
}
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
-(void) dealloc;
-(ORInt) arity;
-(id) flat:(ORInt)i;
-(id) at: (ORInt) i0 : (ORInt) i1;
-(id) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i0 : (ORInt) i1;
-(void) set: (id) x at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger) count;
-(void)encodeWithCoder: (NSCoder*) aCoder;
-(id)initWithCoder: (NSCoder*) aDecoder;
-(void)visit:(id<ORVisitor>)v;
@end

