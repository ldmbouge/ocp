/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORSet.h>

@protocol CPFloatVar;
@protocol ORExpr;
@protocol OREngine;
@protocol ORSearchEngine;
@protocol ORObjectiveFunction;
@protocol ORParameter;

@protocol ORVar;
@protocol ORIntVar;
@protocol ORRealVar;
@protocol ORFloatVar;
@protocol ORDoubleVar;
@protocol ORLDoubleVar;
@protocol ORBitVar;
@protocol ORIntMatrix;

@protocol ORIdArray;
@protocol ORVarArray;
@protocol ORExprArray;
@protocol ORIntVarArray;
@protocol ORIntVarMatrix;

@protocol ORAutomaton;
@protocol ORTable;

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
-(NSArray*)allVarsArray;
-(ORBool) memberVar:(id<ORVar>) x;
-(ORUInt) nbOccurences:(id<ORVar>)x;
-(ORBool) canLeadToAnAbsorption;
-(id<CPFloatVar>) varSubjectToAbsorption:(id<CPFloatVar>)x;
-(ORDouble) leadToACancellation:(id<ORVar>)x;
-(void) close;
@end

@protocol ORSoftConstraint <ORConstraint>
-(id<ORVar>)slack;
@end

@protocol ORPost<NSObject>
-(ORStatus)post:(id<ORConstraint>)c;
@end

@protocol ORConstraintSet <NSObject>
-(void)addConstraint:(id<ORConstraint>)c;
-(ORInt) size;
-(void) enumerateWith:(void(^)(id<ORConstraint>))block;
@end

@protocol OROrderedConstraintSet <ORConstraintSet>
-(id<ORConstraint>) at:(ORInt)index;
@end

enum ORGroupType {
   DefaultGroup = 0,
   BergeGroup = 1,
   GuardedGroup = 2,
   CDGroup = 3,
   Group3B = 4
};

@protocol ORGroup <ORObject,ORConstraint>
-(id<ORConstraint>)add:(id<ORConstraint>)c;
-(void)clear;
-(void)enumerateObjectWithBlock:(void(^)(id<ORConstraint>))block;
-(ORInt) size;
-(NSSet*) variables;
-(id<ORConstraint>) at: (ORInt) idx;
-(enum ORGroupType)type;
-(id<ORIntVar>)guard;
-(id<ORConstraint>)alphaVars:(id<ORVarArray>) xa;
@end

@protocol ORCDGroup <ORGroup>
-(NSArray*)varMap;
@end

@protocol OR3BGroup <ORGroup>
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

@protocol  ORFloatNEqualc <ORConstraint>
-(id<ORFloatVar>) left;
-(ORInt) cst;
@end

@protocol  ORFloatEqualc <ORConstraint>
-(id<ORFloatVar>) left;
-(ORInt) cst;
@end

@protocol  ORFloatAssignC <ORConstraint>
-(id<ORFloatVar>) left;
-(ORFloat) cst;
@end

@protocol  ORDoubleNEqualc <ORConstraint>
-(id<ORDoubleVar>) left;
-(ORDouble) cst;
@end

@protocol  ORDoubleEqualc <ORConstraint>
-(id<ORDoubleVar>) left;
-(ORDouble) cst;
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

@protocol ORSoftNEqual <ORNEqual, ORSoftConstraint>
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

@protocol ORBinImply <ORConstraint>
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

@protocol ORElementBitVar <ORConstraint>
-(id<ORIdArray>) array;
-(id<ORBitVar>)   idx;
-(id<ORBitVar>)   res;
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

@protocol ORClause <ORConstraint>
-(id<ORIntVarArray>)vars;
-(id<ORIntVar>)targetValue;
@end

@protocol ORSumBoolEqc <ORConstraint>
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@protocol ORSumBoolNEqc <ORConstraint>
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


@protocol ORFloatAssign <ORConstraint>
-(id<ORFloatVar>) left;
-(id<ORFloatVar>) right;
@end


@protocol ORFloatMult <ORConstraint>
-(id<ORFloatVar>) res;
-(id<ORFloatVar>) left;
-(id<ORFloatVar>) right;
@end

@protocol ORFloatDiv <ORConstraint>
-(id<ORFloatVar>) res;
-(id<ORFloatVar>) left;
-(id<ORFloatVar>) right;
@end

@protocol ORFloatLinearEq <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@protocol ORFloatLinearNEq <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@protocol ORFloatLinearLT <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@protocol ORFloatLinearGT <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@protocol ORFloatLinearLEQ <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@protocol ORFloatLinearGEQ <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@protocol ORFloatReifyEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@protocol ORFloatReifyNEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@protocol ORFloatReifyEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@protocol ORFloatReifyNEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@protocol ORFloatReifyLEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@protocol ORFloatReifyLEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@protocol ORFloatReifyLThen <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@protocol ORFloatReifyLThenc <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@protocol ORFloatReifyGEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@protocol ORFloatReifyGEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@protocol ORFloatReifyGThen <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@protocol ORFloatReifyGThenc <ORReify>
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end
//-----------
@protocol ORDoubleReifyEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@protocol ORDoubleReifyNEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@protocol ORDoubleReifyEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@protocol ORDoubleReifyNEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@protocol ORDoubleReifyLEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@protocol ORDoubleReifyLEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@protocol ORDoubleReifyLThen <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@protocol ORDoubleReifyLThenc <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@protocol ORDoubleReifyGEqualc <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@protocol ORDoubleReifyGEqual <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@protocol ORDoubleReifyGThen <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@protocol ORDoubleReifyGThenc <ORReify>
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end


@protocol ORDoubleAssign <ORConstraint>
-(id<ORDoubleVar>) left;
-(id<ORDoubleVar>) right;
@end


@protocol ORDoubleAssignC <ORConstraint>
-(id<ORDoubleVar>) left;
-(ORDouble) cst;
@end

//---------
@protocol ORDoubleMult <ORConstraint>
-(id<ORDoubleVar>) res;
-(id<ORDoubleVar>) left;
-(id<ORDoubleVar>) right;
@end

@protocol ORDoubleDiv <ORConstraint>
-(id<ORDoubleVar>) res;
-(id<ORDoubleVar>) left;
-(id<ORDoubleVar>) right;
@end

@protocol ORDoubleLinearEq <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@protocol ORDoubleLinearNEq <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@protocol ORDoubleLinearLT <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@protocol ORDoubleLinearGT <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@protocol ORDoubleLinearLEQ <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@protocol ORDoubleLinearGEQ <ORConstraint>
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
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

@protocol ORRealLinearGeq <ORConstraint>
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

// z = weight * x
@protocol ORWeightedVar <ORConstraint>
-(id<ORVar>) z;
-(id<ORVar>)x;
-(id<ORParameter>)weight;
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

@protocol ORSoftKnapsack <ORKnapsack, ORSoftConstraint>
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
-(id<ORObjectiveValue>) primalValue;
-(id<ORObjectiveValue>) dualValue;
-(id<ORObjectiveValue>) primalBound;
-(id<ORObjectiveValue>) dualBound;
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
-(void)     updatePrimalBound;
-(void)     updateDualBound;
-(void)     tightenPrimalBound: (id<ORObjectiveValue>) newBound;
-(ORStatus) tightenDualBound: (id<ORObjectiveValue>) newBound;
-(void)     tightenLocallyWithDualBound: (id<ORObjectiveValue>) newBound;
-(ORBool)   isBound;
-(ORBool)   isMinimization;
@end

@protocol ORModel;
@protocol ORSolution <NSObject>
-(id) value: (id) var;
-(ORInt) intValue: (id<ORIntVar>) var;
-(ORBool) boolValue: (id<ORIntVar>) var;
-(ORDouble) doubleValue: (id<ORRealVar>) var;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORModel>) model;
@end

@protocol ORSolutionPool <NSObject>
-(void) addSolution: (id<ORSolution>) s;
-(void) enumerateWith: (void(^)(id<ORSolution>)) block;
-(id) objectAtIndexedSubscript: (NSUInteger) key;
-(id<ORInformer>) solutionAdded;
-(id<ORSolution>) best;
-(void) emptyPool;
-(NSUInteger) count;
@end

// ====== Bit Constraints =====================================

@protocol ORBitEqualAt <ORConstraint>
-(id<ORBitVar>)left;
-(ORInt)cst;
-(ORInt)bit;
@end

@protocol ORBitEqualc <ORConstraint>
-(id<ORBitVar>)left;
-(ORInt)cst;
@end

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

@protocol  ORBitShiftRA <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(ORInt) places;
@end

@protocol  ORBitShiftRA_BV <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) places;
@end

@protocol  ORBitRotateL <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(ORInt) places;
@end


@protocol  ORBitNegative <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
@end

@protocol  ORBitSum <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) in;
-(id<ORBitVar>) out;
@end

@protocol  ORBitSubtract <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitMultiply <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitDivide <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) rem;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
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

@protocol ORBitChannel<ORConstraint>
-(id<ORBitVar>) left;
-(id<ORIntVar>) right;
@end

@protocol  ORBitZeroExtend <ORConstraint>
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitSignExtend <ORConstraint>
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

@protocol  ORBitSLE <ORConstraint>
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@protocol  ORBitSLT <ORConstraint>
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

@protocol  ORBitDistinct <ORConstraint>
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
