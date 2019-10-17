/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORExpr.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORData.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORVisit.h>

@interface ORExprI: ORObject<ORExpr,NSCoding>
-(id<ORExpr>) abs;
-(id<ORExpr>) square;
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
-(id<ORExpr>) land:(id<ORRelation>) e;
-(id<ORExpr>) lor:(id<ORRelation>) e;
-(id<ORExpr>) imply:(id<ORRelation>) e;

-(id<ORExpr>) absTrack:(id<ORTracker>)t;
-(id<ORExpr>) squareTrack:(id<ORTracker>)t;
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
-(id<ORRelation>) land: (id<ORExpr>) e  track:(id<ORTracker>)t;
-(id<ORRelation>) lor: (id<ORExpr>) e track:(id<ORTracker>)t;
-(id<ORRelation>) imply:(id<ORExpr>)e  track:(id<ORTracker>)t;

-(id<ORExpr>) setUnion: (id<ORExpr>)e track:(id<ORTracker>)t;

-(void) encodeWithCoder:(NSCoder*) aCoder;
-(id) initWithCoder:(NSCoder*) aDecoder;
-(void) visit: (ORVisitor*)v;
-(DDClosure)visitClosure: (ORVisitor*)v;
-(ORRelationType) type;
-(ORVType) vtype;
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
-(ORVType) vtype;
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
-(void) visit:(ORVisitor*)v;
@end

@interface ORExprSquareI : ORExprI<ORExpr,NSCoding> {
   ORExprI* _op;
}
-(id<ORExpr>)initORExprSquareI:(id<ORExpr>) op;
-(id<ORTracker>) tracker;
-(ORInt) min;
-(ORInt) max;
-(NSString*) description;
-(ORExprI*)operand;
-(ORBool)isConstant;
-(void)visit:(ORVisitor*)v;
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
-(void) visit:(ORVisitor*) v;
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
-(void) visit:(ORVisitor*) v;
@end

@interface ORExprCstDoubleSubI : ORExprI<ORExpr,NSCoding> {
   id<ORDoubleArray> _array;
   ORExprI*         _index;
}
-(id<ORExpr>) initORExprCstDoubleSubI: (id<ORDoubleArray>) array index:(id<ORExpr>) op;
-(id<ORTracker>) tracker;
-(ORDouble) fmin;
-(ORDouble) fmax;
-(NSString *)description;
-(ORExprI*) index;
-(id<ORDoubleArray>)array;
-(ORBool) isConstant;
-(void) visit:(ORVisitor*) v;
@end

@interface ORExprSetContainsI : ORExprBinaryI<ORExpr, NSCoding> {
    id<ORIntSet> _set;
    id<ORExpr> _value;
}
-(id<ORExpr>) initORExprSetContainsI:(id<ORIntSet>)a value:(id<ORExpr>)value;
-(void) visit:(ORVisitor*) v;
-(id<ORIntSet>) set;
-(id<ORExpr>) value;
@end
@interface ORExprSetExprContainsI : ORExprBinaryI<ORExpr, NSCoding> {
    id<ORExpr> _set;
    id<ORExpr> _value;
}
-(id<ORExpr>) initORExprSetExprContainsI:(id<ORExpr>)a value:(id<ORExpr>)value;
-(void) visit:(ORVisitor*) v;
-(id<ORExpr>) set;
-(id<ORExpr>) value;
@end
@interface ORExprSetUnionI : ORExprBinaryI<ORExpr, NSCoding>
-(id<ORExpr>) initORExprSetUnionI:(id<ORExpr>)left and:(id<ORExpr>)right;
-(void) visit:(ORVisitor*) v;
@end
@interface ORExprIfThenElseI : ORExprI<ORExpr, NSCoding> {
    id<ORExpr> _if;
    id<ORExpr> _then;
    id<ORExpr> _else;
}
-(id<ORExpr>) initORExprIfThenElseI:(id<ORExpr>)i then:(id<ORExpr>)t elseReturn:(id<ORExpr>)e;
-(void) visit:(ORVisitor*) v;
-(id<ORExpr>) ifExpr;
-(id<ORExpr>) thenReturn;
-(id<ORExpr>) elseReturn;
@end
@interface ORExprArrayIndexI : ORExprI<ORExpr, NSCoding> {
    id<ORExpr> _array;
    id<ORExpr> _index;
}
-(id<ORExpr>) initORExprArrayIndexI:(id<ORExpr>)array index:(id<ORExpr>)index;
-(void) visit:(ORVisitor*) v;
-(id<ORExpr>) array;
-(id<ORExpr>) index;
@end
@interface ORExprAppendToArrayI : ORExprBinaryI<ORExpr, NSCoding>
-(id<ORExpr>) initORExprAppendToArrayI:(id<ORExpr>)left value:(id<ORExpr>)right;
-(void) visit:(ORVisitor*) v;
@end
@interface ORExprEachInSetPlusI : ORExprBinaryI<ORExpr, NSCoding>
-(id<ORExpr>) initORExprEachInSetPlusI:(id<ORExpr>)left and:(id<ORExpr>)right;
-(void) visit:(ORVisitor*) v;
@end
@interface ORExprMinBetweenArraysI : ORExprBinaryI<ORExpr, NSCoding>
-(id<ORExpr>) initORExprMinBetweenArrays:(id<ORExpr>)left and:(id<ORExpr>)right;
-(void) visit:(ORVisitor*) v;
@end
@interface ORExprMaxBetweenArraysI : ORExprBinaryI<ORExpr, NSCoding>
-(id<ORExpr>) initORExprMaxBetweenArrays:(id<ORExpr>)left and:(id<ORExpr>)right;
-(void) visit:(ORVisitor*) v;
@end
@interface ORExprEachInSetPlusEachInSetI : ORExprBinaryI<ORExpr, NSCoding>
-(id<ORExpr>) initORExprEachInSetPlusEachInSetI:(id<ORExpr>)left and:(id<ORExpr>)right;
-(void) visit:(ORVisitor*) v;
@end
@interface ORExprEachInSetLEQI: ORExprBinaryI<ORRelation, NSCoding>
-(id<ORExpr>) initORExprEachInSetLEQI:(id<ORExpr>)left and:(id<ORExpr>)right;
-(void) visit:(ORVisitor*) v;
@end
@interface ORExprEachInSetGEQI : ORExprBinaryI<ORRelation, NSCoding>
-(id<ORExpr>) initORExprEachInSetGEQI:(id<ORExpr>)left and:(id<ORExpr>)right;
-(void) visit:(ORVisitor*) v;
@end

@interface ORExprPlusI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprPlusI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit:(ORVisitor*)v;
@end

@interface ORExprMulI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprMulI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprDivI : ORExprBinaryI<ORExpr,NSCoding>
-(id<ORExpr>) initORExprDivI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprModI: ORExprBinaryI<ORExpr,NSCoding>
-(id<ORExpr>) initORExprModI: (id<ORExpr>) left mod: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprMinI: ORExprBinaryI<ORExpr,NSCoding>
-(id<ORExpr>) initORExprMinI: (id<ORExpr>) left min: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprMaxI: ORExprBinaryI<ORExpr,NSCoding>
-(id<ORExpr>) initORExprMaxI: (id<ORExpr>) left max: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprMinusI : ORExprBinaryI<ORExpr,NSCoding> 
-(id<ORExpr>) initORExprMinusI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprEqualI : ORExprBinaryI<ORRelation,NSCoding> 
-(id<ORExpr>) initORExprEqualI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
//-(ORRelationType)type;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprNotEqualI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORExprNotEqualI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORRelationType)type;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprLEqualI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORExprLEqualI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORRelationType)type;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprGEqualI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORExprGEqualI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORRelationType)type;
-(void) visit: (ORVisitor*)v;
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
-(void) visit:(ORVisitor*)v;
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
-(void) visit:(ORVisitor*)v;
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
-(void) visit:(ORVisitor*)v;
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
-(void) visit: (ORVisitor*)v;
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
-(void) visit: (ORVisitor*)v;
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
-(void) visit: (ORVisitor*)v;
@end

@interface ORDisjunctI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORDisjunctI: (id<ORExpr>) left or: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORRelationType)type;
-(void) visit: (ORVisitor*)v;
@end

@interface ORConjunctI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORConjunctI: (id<ORExpr>) left and: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORRelationType)type;
-(void) visit: (ORVisitor*)v;
@end

@interface ORImplyI : ORExprBinaryI<ORRelation,NSCoding>
-(id<ORExpr>) initORImplyI: (id<ORExpr>) left imply: (id<ORExpr>) right;
-(ORInt) min;
-(ORInt) max;
-(NSString *)description;
-(ORRelationType)type;
-(void) visit: (ORVisitor*)v;
@end

@interface ORExprNegateI : ORExprI<ORRelation,NSCoding> {
   id<ORExpr> _op;
}
-(id<ORExpr>)initORNegateI:(id<ORExpr>)op;
-(ORInt)min;
-(ORInt)max;
-(ORExprI*) operand;
-(NSString*)description;
-(void)visit:(ORVisitor*)v;
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
-(void) visit:(ORVisitor*) v;
@end


@interface ORExprValueAssignmentI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprValueAssignmentI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprLayerVariableI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprLayerVariableI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprSizeOfArrayI : ORExprI<ORExpr, NSCoding> {
    id<ORExpr> _array;
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprSizeOfArrayI:(id<ORExpr>)array track:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORExpr>) array;
-(id<ORTracker>) tracker;
@end
@interface ORExprParentInformationI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprParentInformationI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprMinParentInformationI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprMinParentInformationI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprMaxParentInformationI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprMaxParentInformationI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprChildInformationI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprChildInformationI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprMinChildInformationI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprMinChildInformationI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprMaxChildInformationI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprMaxChildInformationI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprLeftInformationI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprLeftInformationI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprRightInformationI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprRightInformationI:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end
@interface ORExprSingletonSetI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
    id<ORExpr> _value;
}
-(id<ORExpr>)initORExprSingletonSetI:(id<ORExpr>)value track:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORExpr>) value;
-(id<ORTracker>) tracker;
@end
@interface ORExprMinMaxSetFromI : ORExprBinaryI<ORExpr, NSCoding> {
    id<ORTracker> _t;
}
-(id<ORExpr>)initORExprMinMaxSetFromI:(id<ORExpr>)left and:(id<ORExpr>)right track:(id<ORTracker>)t;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end

@interface ORExprStateValueI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
    @public int _lookup;
    @public int _stateIndex;
    @public id<ORInteger> _arrayIndex;
}
-(id<ORExpr>)initORExprStateValueI:(id<ORTracker>)t lookup:(int)lookup;
-(id<ORExpr>)initORExprStateValueI:(id<ORTracker>)t lookup:(int)lookup arrayIndex:(id<ORInteger>)arrayIndex;
-(id<ORExpr>)initORExprStateValueI:(id<ORTracker>)t lookup:(int)lookup index:(int)index;
-(id<ORExpr>)initORExprStateValueI:(id<ORTracker>)t lookup:(int)lookup index:(int)index arrayIndex:(int)arrayIndex;
-(int) lookup;
-(int) index;
-(int) arrayIndex;
-(bool) isArray;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end

@interface ORExprStateValueExprI : ORExprI<ORExpr, NSCoding> {
    id<ORTracker> _t;
    id<ORExpr> _lookup;
@public int _stateIndex;
    id<ORInteger> _arrayIndex;
    NSDictionary* _mapping;
}
-(id<ORExpr>)initORExprStateValueExprI:(id<ORTracker>)t lookup:(id<ORExpr>)lookup;
-(id<ORExpr>)initORExprStateValueExprI:(id<ORTracker>)t lookup:(id<ORExpr>)lookup arrayIndex:(id<ORInteger>)arrayIndex;
-(id<ORExpr>)initORExprStateValueExprI:(id<ORTracker>)t lookup:(id<ORExpr>)lookup index:(int)index;
-(id<ORExpr>)initORExprStateValueExprI:(id<ORTracker>)t lookup:(id<ORExpr>)lookup index:(int)index arrayIndex:(int)arrayIndex mapping:(NSDictionary*) mapping;
-(id<ORExpr>) lookup;
-(int) index;
-(int) arrayIndex;
-(NSDictionary*) mapping;
-(bool) isArray;
-(void) visit:(ORVisitor*) v;
-(id<ORTracker>) tracker;
@end

//int getStateValueIndex(ORExprStateValueI* sv) { return sv->_stateIndex;}
//int getStateValueLookup(ORExprStateValueI* sv) { return sv->_lookup;}
