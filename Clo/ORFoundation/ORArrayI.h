/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORTypes.h"
#import "ORData.h"
#import "ORTracker.h"
#import "ORArray.h"

@interface ORIntArrayI : NSObject<NSCoding,ORIntArray> {
   id<ORTracker> _tracker;
   ORInt*          _array;
   ORInt             _low;
   ORInt              _up;
   ORInt              _nb;
   ORRange         _range;
}
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb value: (ORInt) v;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb with: (ORInt(^)(ORInt)) clo;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) range value: (ORInt) v;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) range with: (ORInt(^)(ORInt)) clo;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) r1 range: (ORRange) r2 with:(ORInt(^)(ORInt,ORInt)) clo;
-(void) dealloc;
-(ORInt) at: (ORInt) value;
-(void) set: (ORInt) value at:(ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(ORRange) range;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORIdArrayI : NSObject<NSCoding,ORIdArray> {
   id<ORTracker>  _tracker;
   id*              _array;
   ORInt              _low;
   ORInt               _up;
   ORInt               _nb;
   ORRange          _range;
}
-(ORIdArrayI*)initORIdArray: (id<ORTracker>)tracker range:(ORRange)range;
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(ORRange) range;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
-(id)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id)newValue atIndexedSubscript:(NSUInteger)idx;
-(void)encodeWithCoder:(NSCoder*) aCoder;
-(id)initWithCoder:(NSCoder*) aDecoder;
@end

@interface ORIdMatrixI : NSObject<NSCoding,ORIdMatrix> {
   id<ORTracker> _tracker;
   id*              _flat;
   ORInt           _arity;
   ORRange*        _range;
   ORInt*            _low;
   ORInt*             _up;
   ORInt*           _size;
   ORInt*              _i;
   ORInt              _nb;
}
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker range: (ORRange) r0 : (ORRange) r1;
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker range: (ORRange) r0 : (ORRange) r1 : (ORRange) r2;
-(void) dealloc;
-(ORInt) arity;
-(id) flat:(ORInt)i;
-(id) at: (ORInt) i0 : (ORInt) i1;
-(id) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i0 : (ORInt) i1;
-(void) set: (id) x at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(ORRange) range: (ORInt) i;
-(NSUInteger)count;
-(id<ORTracker>) tracker;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

