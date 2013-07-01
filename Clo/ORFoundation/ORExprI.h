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
#import "ORConstraint.h"
#import "ORVisit.h"

@interface ORExprI: ORObject<ORExpr,NSCoding>
-(id<ORExpr>) abs;
-(id<ORExpr>) plus: (id) e;
-(id<ORExpr>) sub: (id) e;
-(id<ORExpr>) mul: (id) e;
-(id<ORExpr>) div: (id) e;
-(id<ORExpr>) mod: (id) e;
-(id<ORExpr>) min: (id) e;
-(id<ORExpr>) max: (id) e;
-(id<ORRelation>) eq: (id) e;
-(id<ORRelation>) neq: (id) e;
-(id<ORRelation>) leq: (id) e;
-(id<ORRelation>) geq: (id) e;
-(id<ORRelation>) lt: (id) e;
-(id<ORRelation>) gt: (id) e;
-(id<ORExpr>) neg;
-(id<ORExpr>) and:(id<ORRelation>) e;
-(id<ORExpr>) or:(id<ORRelation>) e;
-(id<ORExpr>) imply:(id<ORRelation>) e;

-(id<ORExpr>) absTrack:(id<ORTracker>)t;
-(id<ORExpr>) plus: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) sub: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) mul: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) div: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) mod: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) min: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) max: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) eq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) neq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) leq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) geq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) lt: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) gt: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) negTrack:(id<ORTracker>)t;
-(id<ORRelation>) and: (id<ORExpr>) e  track:(id<ORTracker>)t;
-(id<ORRelation>) or: (id<ORExpr>) e track:(id<ORTracker>)t;
-(id<ORRelation>) imply:(id<ORExpr>)e  track:(id<ORTracker>)t;

-(void) encodeWithCoder:(NSCoder*) aCoder;
-(id) initWithCoder:(NSCoder*) aDecoder;
-(void) visit: (id<ORVisitor>)v;
-(enum ORRelationType) type;
-(NSSet*)allVars;
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
-(ORBool) isConstant;
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
-(ORBool) isConstant;
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
-(ORBool) isConstant;
-(void) visit:(id<ORVisitor>) v;
@end

@interface ORExprMatrixVarSubI : ORExprI<ORExpr,NSCoding> {
   id<ORIntVarMatrix> _m;
   ORExprI*  _i0;
   ORExprI*  _i1;
}
-(id<ORExpr>)initORExprMatrixVarSubI:(id<ORIntVarMatrix>)m elt:(id<ORExpr>)i0 elt:(id<ORExpr>)i1;
-(id<ORTracker>)tracker;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORExprI*) index0;
-(ORExprI*) index1;
-(id<ORIntVarMatrix>)matrix;
-(ORBool) isConstant;
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

@interface ORExprDivI : ORExprBinaryI<ORExpr,NSCoding>
-(id<ORExpr>) initORExprDivI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprModI: ORExprBinaryI<ORExpr,NSCoding>
-(id<ORExpr>) initORExprModI: (id<ORExpr>) left mod: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprMinI: ORExprBinaryI<ORExpr,NSCoding>
-(id<ORExpr>) initORExprMinI: (id<ORExpr>) left min: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprMaxI: ORExprBinaryI<ORExpr,NSCoding>
-(id<ORExpr>) initORExprMaxI: (id<ORExpr>) left max: (id<ORExpr>) right;
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
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S1 over: (id<ORIntIterable>) S2 suchThat: (ORIntxInt2Bool) f of: (ORIntxInt2Expr) e;
-(id<ORExpr>) init: (id<ORExpr>) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(ORBool) isConstant;
-(NSString *) description;
-(void) visit:(id<ORVisitor>)v;
@end

@interface ORExprAggMinI : ORExprI<ORExpr,NSCoding> {
   id<ORExpr> _e;
}
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
-(id<ORExpr>) init: (id<ORExpr>) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(ORBool) isConstant;
-(NSString *) description;
-(void) visit:(id<ORVisitor>)v;
@end

@interface ORExprAggMaxI : ORExprI<ORExpr,NSCoding> {
   id<ORExpr> _e;
}
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
-(id<ORExpr>) init: (id<ORExpr>) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(ORBool) isConstant;
-(NSString *) description;
-(void) visit:(id<ORVisitor>)v;
@end

@interface ORExprProdI : ORExprI<ORExpr,NSCoding> {
   id<ORExpr> _e;
}
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
-(id<ORExpr>) init: (id<ORExpr>) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(ORBool) isConstant;
-(NSString *) description;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprAggOrI : ORExprI<ORRelation,NSCoding> {
   id<ORExpr> _e;
}
-(id<ORExpr>) init: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;
-(id<ORExpr>) init: (id<ORExpr>) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(ORBool) isConstant;
-(NSString *) description;
-(void) visit: (id<ORVisitor>)v;
@end

@interface ORExprAggAndI : ORExprI<ORRelation,NSCoding> {
   id<ORExpr> _e;
}
-(id<ORExpr>) init: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;
-(id<ORExpr>) init: (id<ORExpr>) e;
-(void) dealloc;
-(ORInt) min;
-(ORInt) max;
-(id<ORTracker>) tracker;
-(ORExprI*) expr;
-(ORBool) isConstant;
-(NSString *) description;
-(void) visit: (id<ORVisitor>)v;
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

@interface ORExprNegateI : ORExprI<ORRelation,NSCoding> {
   id<ORExpr> _op;
}
-(id<ORExpr>)initORNegateI:(id<ORExpr>)op;
-(ORInt)min;
-(ORInt)max;
-(ORExprI*) operand;
-(NSString*)description;
-(void)visit:(id<ORVisitor>)v;
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
-(ORBool) isConstant;
-(void) visit:(id<ORVisitor>) v;
@end



