/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORObject.h"
#import "ORExpr.h"
#import "ORArray.h"
#import "ORData.h"
#import "ORSet.h"
#import "ORModel.h"
#import "ORVisit.h"

@interface ORExprI: ORModelingObjectI<ORExpr,NSCoding>

-(id<ORExpr>) abs;
-(id<ORExpr>) plus: (id<ORExpr>) e;
-(id<ORExpr>) sub: (id<ORExpr>) e;
-(id<ORExpr>) mul: (id<ORExpr>) e;
-(id<ORExpr>) muli: (ORInt) e;
-(id<ORRelation>) eq: (id<ORExpr>) e;
-(id<ORRelation>) eqi: (ORInt) e;
-(id<ORRelation>) neq: (id<ORExpr>) e;
-(id<ORRelation>) neqi: (ORInt) e;
-(id<ORRelation>) leq: (id<ORExpr>) e;
-(id<ORRelation>) leqi: (ORInt) e;
-(id<ORRelation>) geq: (id<ORExpr>) e;
-(id<ORRelation>) geqi: (ORInt) e;
-(id<ORRelation>) lt: (id<ORExpr>) e;
-(id<ORRelation>) lti: (ORInt) e;
-(id<ORRelation>) gt: (id<ORExpr>) e;
-(id<ORRelation>) gti: (ORInt) e;
-(id<ORExpr>) and:(id<ORRelation>) e;
-(id<ORExpr>) or:(id<ORRelation>) e;
-(id<ORExpr>) imply:(id<ORRelation>) e;
-(void) encodeWithCoder:(NSCoder*) aCoder;
-(id) initWithCoder:(NSCoder*) aDecoder;
-(void) visit: (id<ORVisitor>)v;
-(enum ORRelationType) type;
@end

@interface ORExprBinaryI : ORExprI<ORExpr,NSCoding>
{
   ORExprI* _left;
   ORExprI* _right;
   id<ORTracker> _tracker;
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
-(void) visit:(id<ORVisitor>)v;
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
-(void) visit:(id<ORVisitor>) v;
@end

@interface ORExprPlusI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprPlusI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit:(id<ORVisitor>)v;
@end

@interface ORExprMulI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprMulI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprMinusI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprMinusI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprEqualI : ORExprBinaryI<ORRelation,NSCoding> 
-(id<ORExpr>) initORExprEqualI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(enum ORRelationType)type;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprNotEqualI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORExprNotEqualI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(enum ORRelationType)type;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprLEqualI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORExprLEqualI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(enum ORRelationType)type;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprSumI : ORExprI<ORExpr,NSCoding> {
   id<ORExpr> _e;
}
-(id<ORExpr>) initORExprSumI: (id<ORTracker>) tracker over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
-(id<ORExpr>) initORExprSumI: (id<ORExpr>) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(BOOL) isConstant;
-(NSString *) description;
-(void) visit: ORVisitorI;
@end

@interface ORExprAggOrI : ORExprI<ORRelation,NSCoding> {
   id<ORExpr> _e;
}
-(id<ORExpr>) initORExprAggOrI: (id<ORTracker>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;
-(id<ORExpr>) initORExprAggOrI: (id<ORExpr>) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(BOOL) isConstant;
-(NSString *) description;
-(void) visit: ORVisitorI;
@end

@interface ORDisjunctI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORDisjunctI: (id<ORExpr>) left or: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(enum ORRelationType)type;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORConjunctI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORConjunctI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(enum ORRelationType)type;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORImplyI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORImplyI: (id<ORExpr>) left imply: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(enum ORRelationType)type;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprVarSubI : ORExprI<ORExpr,NSCoding> {
   id<ORIntVarArray> _array;
   ORExprI*          _index;
}
-(id<ORExpr>) initORExprVarSubI: (id<ORIntVarArray>) array elt:(id<ORExpr>) op;
-(id<ORTracker>) tracker;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORExprI*) index;
-(id<ORIntVarArray>)array;
-(BOOL) isConstant;
-(void) visit:(id<ORVisitor>) v;
@end



