/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORArray.h>

@protocol ORIntVarArray;
@protocol ORVarArray;
@protocol ORExpr;
@protocol ORIntVar;
@protocol ORBitVar;
@protocol OREngine;
@protocol ORSearchEngine;
@protocol ORObjectiveFunction;
@protocol ORSolution;
@protocol ORSolutionPool;

@protocol ORBasicModel
-(id<ORObjectiveFunction>) objective;
-(id<ORIntVarArray>)intVars;
-(NSArray*) variables;
-(NSArray*) constraints;
-(NSArray*) mutables;
-(NSArray*) immutables;
@end

@protocol ORConstraint <ORObject>
-(ORUInt)getId;
@end

@protocol ORConstraintSet <NSObject>
-(void)addConstraint:(id<ORConstraint>)c;
-(ORInt) size;
-(void)enumerateWith:(void(^)(id<ORConstraint>))block;
@end

enum ORGroupType {
   DefaultGroup = 0,
   BergeGroup = 1
};

@protocol ORGroup <ORObject,ORConstraint>
-(id<ORConstraint>)add:(id<ORConstraint>)c;
-(void)enumerateObjectWithBlock:(void(^)(id<ORConstraint>))block;
-(enum ORGroupType)type;
@end

@protocol ORFail <ORConstraint>
@end

@protocol ORRestrict <ORConstraint>
-(id<ORIntVar>)var;
-(id<ORIntSet>)restriction;
@end

@protocol  OREqualc <ORConstraint>
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@protocol  ORNEqualc <ORConstraint>
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@protocol  ORLEqualc <ORConstraint>
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@protocol  ORGEqualc <ORConstraint>
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@protocol  OREqual <ORConstraint>
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt) cst;
-(ORAnnotation) annotation;
@end

@protocol  ORAffine <ORConstraint>
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt)coef;
-(ORInt)cst;
-(ORAnnotation) annotation;
@end

@protocol  ORNEqual <ORConstraint>
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt) cst;
@end

@protocol  ORLEqual <ORConstraint>
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt) cst;
@end

@protocol  ORPlus <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORAnnotation) annotation;
@end

@protocol ORMult <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@protocol ORSquare<ORConstraint>
-(id<ORIntVar>)res;
-(id<ORIntVar>)op;
-(ORAnnotation) annotation;
@end

@protocol ORMod <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@protocol ORModc <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(ORInt) right;
-(ORAnnotation) annotation;
@end

@protocol ORAbs <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(ORAnnotation) annotation;
@end

@protocol OROr <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@protocol ORAnd <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@protocol ORImply <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@protocol ORElementCst <ORConstraint>
-(id<ORIntArray>) array;
-(id<ORIntVar>)   idx;
-(id<ORIntVar>)   res;
-(ORAnnotation)annotation;
@end

@protocol ORElementVar <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORIntVar>)   idx;
-(id<ORIntVar>)   res;
-(ORAnnotation)annotation;
@end

@protocol ORReify <ORConstraint>
@end

@protocol ORReifyEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@protocol ORReifyNEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@protocol ORReifyEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORAnnotation) annotation;
@end

@protocol ORReifyNEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORAnnotation) annotation;
@end

@protocol ORReifyLEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@protocol ORReifyLEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORAnnotation) annotation;
@end

@protocol ORReifyGEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@protocol ORReifyGEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORAnnotation) annotation;
@end

@protocol ORSumBoolEqc <ORConstraint>
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@protocol ORSumBoolLEqc <ORConstraint>
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@protocol ORSumBoolGEqc <ORConstraint>
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@protocol ORSumEqc <ORConstraint>
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@protocol ORSumGEqc <ORConstraint>
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@protocol ORSumLEqc <ORConstraint>
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@protocol ORLinearGeq <ORConstraint>
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@protocol ORLinearLeq <ORConstraint>
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@protocol ORLinearEq <ORConstraint>
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@protocol ORFloatLinearEq <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@protocol ORFloatLinearLeq <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@protocol ORAlldifferent <ORConstraint>
-(id<ORIntVarArray>) array;
-(ORAnnotation) annotation;
@end

@protocol ORAlgebraicConstraint <ORConstraint>
-(id<ORExpr>) expr;
-(ORAnnotation)annotation;
@end

@protocol ORTableConstraint <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORTable>) table;
@end

@protocol ORCardinality <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORIntArray>) low;
-(id<ORIntArray>) up;
-(ORAnnotation) annotation;
@end

@protocol ORLexLeq <ORConstraint>
-(id<ORIntVarArray>)x;
-(id<ORIntVarArray>)y;
@end

@protocol ORCircuit <ORConstraint>
-(id<ORIntVarArray>) array;
@end

@protocol ORNoCycle <ORConstraint>
-(id<ORIntVarArray>) array;
@end

@protocol ORPackOne <ORConstraint>
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(ORInt) bin;
-(id<ORIntVar>) binSize;
@end

@protocol ORPacking <ORConstraint>
-(id<ORIntVarArray>) item;
-(id<ORIntArray>)   itemSize;
-(id<ORIntVarArray>) binSize;
@end

@protocol ORKnapsack <ORConstraint>
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) weight;
-(id<ORIntVar>) capacity;
@end

@protocol ORAssignment <ORConstraint>
-(id<ORIntVarArray>) x;
-(id<ORIntMatrix>) matrix;
-(id<ORIntVar>) cost;
@end

@protocol ORObjectiveValue <ORObject>
-(id<ORObjectiveValue>) best: (id<ORObjectiveValue>) other;
-(ORInt) compare: (id<ORObjectiveValue>) other;
//-(ORInt) intValue;
//-(ORFloat) floatValue;
@end

@protocol ORObjectiveValueInt <ORObjectiveValue>
-(ORInt) value;
@end

@protocol ORObjectiveValueFloat <ORObjectiveValue>
-(ORFloat) value;
@end

@protocol ORObjectiveFunction <ORObject>
-(id<ORObjectiveValue>) value;
@end

@protocol ORObjectiveFunctionVar <ORObjectiveFunction>
-(id<ORIntVar>) var;
@end

@protocol ORObjectiveFunctionExpr <ORObjectiveFunction>
-(id<ORExpr>) expr;
@end

@protocol ORObjectiveFunctionLinear <ORObjectiveFunction>
-(id<ORVarArray>) array;
-(id<ORFloatArray>) coef;
@end

@protocol ORSearchObjectiveFunction <NSObject,ORObjectiveFunction>
-(ORStatus) check;
-(id<ORObjectiveValue>) primalBound;
-(void)     updatePrimalBound;
-(void)     tightenPrimalBound: (id<ORObjectiveValue>) newBound;
@end

// pvh: to reconsider the solution pool in this interface; not sure I like them here
@protocol ORASolver <NSObject,ORTracker>
-(id<ORSearchObjectiveFunction>) objective;
-(void)               close;
-(id<OREngine>)       engine;
-(id<ORSolutionPool>) solutionPool;          
@end

// ====== Bit Constraints =====================================

@protocol  ORBitEqual <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitOr <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitAnd <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitNot <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitXor <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitShiftL <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(ORInt) places;
@end

@protocol  ORBitRotateL <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(ORInt) places;
@end

@protocol  ORBitSum <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) in;
-(id<ORBitVar>) out;
@end

@protocol  ORBitIf <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) trueIf;
-(id<ORBitVar>) equals;
-(id<ORBitVar>) zeroIfXEquals;
@end