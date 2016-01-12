/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORVar.h>
#import <ORFoundation/ORObject.h>

@protocol ORIntVarArray;
@protocol ORVarArray;
@protocol ORExprArray;
@protocol ORIntVarMatrix;
@protocol ORExpr;
@protocol ORVar;
@protocol ORIntVar;
@protocol ORBitVar;
@protocol ORRealVar;
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
-(NSSet*)allVars;
-(void) close;
@end

@protocol ORPost<NSObject>
-(ORStatus)post:(id<ORConstraint>)c;
@end

@protocol ORConstraintSet <NSObject>
-(void)addConstraint:(id<ORConstraint>)c;
-(ORInt) size;
-(void)enumerateWith:(void(^)(id<ORConstraint>))block;
@end

@protocol OROrderedConstraintSet <ORConstraintSet>
-(id<ORConstraint>) at:(ORInt)index;
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

@protocol  ORRealEqualc <ORConstraint>
-(id<ORRealVar>) left;
-(ORDouble) cst;
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
-(id<ORVar>) left;
-(id<ORVar>) right;
-(ORInt) cst;
@end

@protocol  ORAffine <ORConstraint>
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt)coef;
-(ORInt)cst;
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
-(ORInt) coefLeft;
-(ORInt) coefRight;
@end

@protocol  ORPlus <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@protocol ORMult <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@protocol ORSquare<ORConstraint>
-(id<ORVar>)res;
-(id<ORVar>)op;
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
@end

@protocol ORMin <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@protocol ORMax <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end


@protocol ORAbs <ORConstraint>
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
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
@end

@protocol ORElementVar <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORIntVar>)   idx;
-(id<ORIntVar>)   res;
@end

@protocol ORElementMatrixVar <ORConstraint>
-(id<ORIntVarMatrix>) matrix;
-(id<ORIntVar>) index0;
-(id<ORIntVar>) index1;
-(id<ORIntVar>) res;
@end

@protocol ORRealElementCst <ORConstraint>
-(id<ORDoubleArray>) array;
-(id<ORIntVar>)   idx;
-(id<ORRealVar>)   res;
@end

@protocol ORImplyEqualc <ORConstraint>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
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
@end

@protocol ORReifyNEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
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
@end

@protocol ORReifySumBoolEqc <ORConstraint>
-(id<ORIntVar>)b;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@protocol ORReifySumBoolGEqc <ORConstraint>
-(id<ORIntVar>)b;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
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
-(NSUInteger)count;
-(ORInt) cst;
@end

@protocol ORRealLinearEq <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@protocol ORRealLinearLeq <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@protocol ORAlldifferent <ORConstraint>
-(id<ORExprArray>) array;
@end

@protocol ORRegular<ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORAutomaton>)automaton;
@end

@protocol ORAlgebraicConstraint <ORConstraint>
-(id<ORExpr>) expr;
@end

@protocol ORTableConstraint <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORTable>) table;
@end

@protocol ORCardinality <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORIntArray>) low;
-(id<ORIntArray>) up;
@end

@protocol ORLexLeq <ORConstraint>
-(id<ORIntVarArray>)x;
-(id<ORIntVarArray>)y;
@end

@protocol ORCircuit <ORConstraint>
-(id<ORIntVarArray>) array;
@end

@protocol ORPath <ORConstraint>
-(id<ORIntVarArray>) array;
@end

@protocol ORSubCircuit <ORConstraint>
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

@protocol ORMultiKnapsack <ORConstraint>
-(id<ORIntVarArray>) item;
-(id<ORIntArray>)    itemSize;
-(id<ORIntArray>)    capacity;
@end

@protocol ORMultiKnapsackOne <ORConstraint>
-(id<ORIntVarArray>) item;
-(id<ORIntArray>)    itemSize;
-(ORInt)             bin;
-(ORInt)             capacity;
@end

@protocol ORMeetAtmost <ORConstraint>
-(id<ORIntVarArray>) x;
-(id<ORIntVarArray>) y;
-(ORInt) atmost;
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
-(NSComparisonResult) compare: (id<ORObjectiveValue>) other;
@optional-(ORInt) intValue;
-(ORDouble) doubleValue;
@end

@protocol ORObjectiveValueInt <ORObjectiveValue>
-(ORInt) value;
-(ORInt) intValue;
-(ORDouble)doubleValue;
@end

@protocol ORObjectiveValueReal <ORObjectiveValue>
-(ORDouble) value;
-(ORDouble)doubleValue;
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
-(id<ORDoubleArray>) coef;
@end

@protocol ORSearchObjectiveFunction <NSObject,ORObjectiveFunction>
-(ORStatus) check;
-(id<ORObjectiveValue>) primalBound;
-(void)     updatePrimalBound;
-(void)     tightenPrimalBound: (id<ORObjectiveValue>) newBound;
-(void)     tightenWithDualBound: (id<ORObjectiveValue>) newBound;
@end

// pvh: to reconsider the solution pool in this interface; not sure I like them here
@protocol ORASolver <NSObject,ORTracker,ORGamma>
-(void)               close;
-(id<OREngine>)       engine;
-(id) concretize: (id) o;
-(id<ORObjectiveValue>) objectiveValue;
@end

@protocol ORASearchSolver <ORASolver>
-(id<ORSearchObjectiveFunction>) objective;
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

@protocol  ORBitShiftL_BV <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) places;
@end

@protocol  ORBitShiftR <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(ORInt) places;
@end

@protocol  ORBitShiftR_BV <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) places;
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

@protocol  ORBitCount <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORIntVar>) right;
@end

@protocol  ORBitZeroExtend <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitConcat <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) res;
@end

@protocol  ORBitExtract <ORConstraint>
-(id<ORBitVar>) left;
-(ORUInt) lsb;
-(ORUInt) msb;
-(id<ORBitVar>) right;
@end

@protocol  ORBitLogicalEqual <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitLT <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitLE <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitITE <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right1;
-(id<ORBitVar>) right2;
@end

@protocol  ORBitLogicalAnd <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORVarArray>) left;
@end

@protocol  ORBitLogicalOr <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORVarArray>) left;
@end

@protocol  ORBitOrb <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitNotb <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
@end

@protocol  ORBitEqualb <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

// Root implementation class (needed so that sub-frameworks can write constraints)

@interface ORConstraintI : ORObject<ORConstraint,NSCoding>
-(ORConstraintI*) initORConstraintI;
-(NSString*) description;
-(void) close;
@end
