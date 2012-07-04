/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORExpr.h"
#import "ORFoundation/ORArray.h"
#import "ORFoundation/ORData.h"

@protocol ORExprVisitor;

@interface ORExprI: NSObject<ORExpr,NSCoding>
-(id<ORExpr>) add: (id<ORExpr>) e; 
-(id<ORExpr>) sub: (id<ORExpr>) e;
-(id<ORExpr>) mul: (id<ORExpr>) e;
-(id<ORExpr>) muli: (ORInt) e;
-(id<ORRelation>) equal: (id<ORExpr>) e;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)visit:(id<ORExprVisitor>)v;
@end

@interface ORExprBinaryI : ORExprI<ORExpr,NSCoding> {
   ORExprI* _left;
   ORExprI* _right;
}
-(id<ORExpr>) initORExprBinaryI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(id<ORTracker>) tracker;
-(ORExprI*) left;
-(ORExprI*) right;
-(BOOL) isConstant;
@end

@interface ORExprAbsI : ORExprI<ORExpr,NSCoding> {
   ORExprI* _op;
}
-(id<ORExpr>) initORExprAbsI: (id<ORExpr>) op;
-(id<ORTracker>) tracker;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORExprI*) operand;
-(BOOL) isConstant;
-(void) visit:(id<ORExprVisitor>)v;
@end

@interface ORExprCstSubI : ORExprI<ORExpr,NSCoding> {
   id<ORIntArray> _array;
   ORExprI*       _index;
}
-(id<ORExpr>) initORExprCstSubI: (id<ORIntArray>) array index:(id<ORExpr>) op;
-(id<ORTracker>) tracker;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORExprI*) index;
-(id<ORIntArray>)array;
-(BOOL) isConstant;
-(void) visit:(id<ORExprVisitor>)v;
@end


@interface ORExprPlusI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprPlusI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit:(id<ORExprVisitor>)v;
@end

@interface ORExprMulI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprMulI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (id<ORExprVisitor>)v;
@end

@interface ORExprMinusI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprMinusI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (id<ORExprVisitor>)v;
@end


@interface ORExprEqualI : ORExprBinaryI<ORRelation,NSCoding> 
-(id<ORExpr>) initORExprEqualI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (id<ORExprVisitor>)v;
@end


@interface ORExprSumI : ORExprI<ORExpr,NSCoding> {
   id<ORExpr> _e;
}
-(id<ORExpr>) initORExprSumI: (id<ORTracker>)tracker range: (ORRange) r filteredBy: (ORInt2Bool) f of: (ORInt2Expr) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(BOOL) isConstant;
-(NSString *) description;
-(void) visit: ORExprVisitorI;
@end

@protocol ORExprVisitor
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprAbsI:(ORExprAbsI*) e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
@end

