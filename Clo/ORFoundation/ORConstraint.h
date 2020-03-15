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

@protocol ORExpr;
@protocol OREngine;
@protocol ORSearchEngine;
@protocol ORObjectiveFunction;
@protocol ORParameter;

@protocol ORVar;
@protocol ORIntVar;
@protocol ORRealVar;
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
   CDGroup = 3
};

@protocol ORGroup <ORObject,ORConstraint>
-(id<ORConstraint>)add:(id<ORConstraint>)c;
-(void)clear;
-(void)enumerateObjectWithBlock:(void(^)(id<ORConstraint>))block;
-(ORInt) size;
-(id<ORConstraint>) at: (ORInt) idx;
-(enum ORGroupType)type;
-(id<ORIntVar>)guard;
-(id<ORConstraint>)alphaVars:(id<ORVarArray>) xa;
@end

@protocol ORCDGroup <ORGroup>
-(NSArray*)varMap;
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

@protocol ORAmong <ORConstraint>
-(id<ORExprArray>) array;
-(id<ORIntSet>) values;
-(ORInt) low;
-(ORInt) up;
@end
/*
@protocol ORExactMDDAllDifferent <ORConstraint>
-(id<ORIntVarArray>) vars;
-(bool) reduced;
@end

@protocol ORRestrictedMDDAllDifferent <ORConstraint>
-(id<ORIntVarArray>) vars;
-(ORInt)restrictionSize;
-(bool) reduced;
@end

@protocol ORRelaxedMDDAllDifferent <ORConstraint>
-(id<ORIntVarArray>) vars;
-(ORInt) relaxationSize;
-(bool) reduced;
@end

@protocol ORExactMDDMISP <ORConstraint>
-(id<ORIntVarArray>) vars;
-(id<ORIntVar>) objective;
-(bool) reduced;
-(bool**) adjacencyMatrix;
-(id<ORIntArray>) weights;
@end

@protocol ORRestrictedMDDMISP <ORConstraint>
-(id<ORIntVarArray>) vars;
-(id<ORIntVar>) objective;
-(ORInt) restrictionSize;
-(bool) reduced;
-(bool**) adjacencyMatrix;
-(id<ORIntArray>) weights;
@end

@protocol ORRelaxedMDDMISP <ORConstraint>
-(id<ORIntVarArray>) vars;
-(id<ORIntVar>) objective;
-(ORInt) relaxationSize;
-(bool) reduced;
-(bool**) adjacencyMatrix;
-(id<ORIntArray>) weights;
@end*/

@protocol ORMDDStateSpecification <ORConstraint>
-(id<ORIntVarArray>) vars;
-(bool) relaxed;
-(ORInt) relaxationSize;
-(id) specs;
-(bool) usingArcs;
-(bool) equalBuckets;
-(bool) usingSlack;
-(int) recommendationStyle;
@end

/*@protocol ORCustomAltMDD <ORConstraint>
-(id<ORIntVarArray>) vars;
-(bool) relaxed;
-(ORInt) relaxationSize;
-(Class) stateClass;
@end
@protocol ORCustomMDD <ORConstraint>
-(id<ORIntVarArray>) vars;
-(bool) relaxed;
-(ORInt) relaxationSize;
-(id) classState;
@end
@protocol ORCustomMDDWithObjective <ORConstraint>
-(id<ORIntVarArray>) vars;
-(id<ORIntVar>) objective;
-(ORInt) relaxationSize;
-(bool) relaxed;
-(bool) reduced;
-(bool) maximize;
-(Class) stateClass;
@end*/

@protocol MDDStateDescriptor <NSObject>
-(id) initMDDStateDescriptor;
-(id) initMDDStateDescriptor:(int)numProperties;
-(void) addNewProperties:(int)num;
-(int) numProperties;
-(void) initializeState:(char*)state;
-(int) getProperty:(int)propertyIndex forState:(char*)state;
-(void) setProperty:(int)propertyIndex to:(int)value forState:(char*)state;
-(size_t) byteOffsetForProperty:(int)propertyIndex;
-(size_t) numBytes;
@end

@protocol ORMDDSpecs <ORConstraint>
-(void) initializeClosures;
-(bool) dualDirectional;
-(id<ORIntVarArray>) vars;
-(void)addStateInt:(int)lookup withDefaultValue:(ORInt)value topDown:(bool)topDown;
-(void)addStateCounter:(int)lookup withDefaultValue:(ORInt)value topDown:(bool)topDown;
-(void)addStateBool:(ORInt)lookup withDefaultValue:(bool)value topDown:(bool)topDown;
-(void)addStateBitSequence:(ORInt)lookup withDefaultValue:(bool)value size:(int)size topDown:(bool)topDown;
-(void)setStateDescriptor:(id<MDDStateDescriptor>)stateDesc;
-(id<MDDStateDescriptor>)stateDescriptor;
-(bool)closuresDefined;
-(id<ORExpr>)arcExists;
-(DDArcClosure)topDownArcExistsClosure;
-(DDArcClosure)bottomUpArcExistsClosure;
-(id<ORExpr>*)transitionFunctions;
-(DDArcClosure*)topDownTransitionClosures;
-(DDArcClosure*)bottomUpTransitionClosures;
-(id<ORExpr>*)relaxationFunctions;
-(DDMergeClosure*)topDownRelaxationClosures;
-(DDMergeClosure*)bottomUpRelaxationClosures;
-(id<ORExpr>*)differentialFunctions;
-(DDMergeClosure*)differentialClosures;
-(DDSlackClosure)slackClosure;
-(int)numTopDownProperties;
-(int)numBottomUpProperties;
-(void)setArcExistsFunction:(id<ORExpr>)arcExists;
-(void)setTopDownArcExistsClosure:(DDArcClosure)arcExists;
-(void)setBottomUpArcExistsClosure:(DDArcClosure)arcExists;
-(void)setSlackClosure:(DDSlackClosure)slack;
-(void)setAsAmongConstraint:(id<ORIntRange>)range lb:(int)lb ub:(int)ub values:(id<ORIntSet>)values;
-(void) setAsSequenceConstraint:(id<ORIntRange>)range length:(int)length lb:(int)lb ub:(int)ub values:(id<ORIntSet>)values;
-(void) setAsSequenceConstraintWithBitSequence:(id<ORIntRange>)range length:(int)length lb:(int)lb ub:(int)ub values:(id<ORIntSet>)values;
-(void)setAsAllDifferent:(id<ORIntRange>)domain;
-(void) setAsDualDirectionalAllDifferent:(int)numVariables domain:(id<ORIntRange>)domain;
-(void)addTransitionFunction:(id<ORExpr>)transitionFunction toStateValue:(int)lookup;
-(void)addTransitionClosure:(DDArcClosure)transitionFunction toStateValue:(int)lookup;
-(void)addRelaxationFunction:(id<ORExpr>)relaxationFunction toStateValue:(int)lookup;
-(void)addRelaxationClosure:(DDMergeClosure)relaxationFunction toStateValue:(int)lookup;
-(void)addStateDifferentialFunction:(id<ORExpr>)differentialFunction toStateValue:(int)lookup;
-(void)addStateDifferentialClosure:(DDMergeClosure)differentialFunction toStateValue:(int)lookup;
-(id*)topDownStateProperties;
-(id*)bottomUpStateProperties;
-(void)addStates:(id*)states size:(int)size;
-(void)addStatesWithClosures:(int)size;
@end

/*@protocol ORAltMDDSpecs <ORConstraint>
-(id<ORIntVarArray>) vars;
-(void) setAsMaximize;
-(void) setAsMinimize;
-(void) setTopDownInformationAsSet;
-(void) setBottomUpInformationAsSet;
-(void) setTopDownInformationAsInt;
-(void) setBottomUpInformationAsInt;
-(void) setTopDownInformationAsArrayWithSize:(int)size andDefaultValue:(int)value;
-(void) setBottomUpInformationAsArrayWithSize:(int)size andDefaultValue:(int)value;
-(void) setTopDownInformationAsMinMaxArrayWithSize:(int)size andDefaultValue:(int)value;
-(void) setBottomUpInformationAsMinMaxArrayWithSize:(int)size andDefaultValue:(int)value;
-(void) addToTopDownInfoSet:(ORInt)value;
-(void) addToBottomUpInfoSet:(ORInt)value;
-(void) setEdgeDeletionCondition:(id<ORExpr>)deleteWhen;
-(void) setTopDownInfoEdgeAddition:(id<ORExpr>)topDownInfoEdge;
-(void) setBottomUpInfoEdgeAddition:(id<ORExpr>)bottomUpInfoEdge;
-(void) setTopDownInfoEdgeAdditionMin:(id<ORExpr>)minTopDownInfoEdge max:(id<ORExpr>)maxTopDownInfoEdge;
-(void) setBottomUpInfoEdgeAdditionMin:(id<ORExpr>)minBottomUpInfoEdge max:(id<ORExpr>)maxBottomUpInfoEdge;
-(void) setInformationMergeToUnion:(id<ORTracker>)t;
-(void) setInformationMergeToMax:(id<ORTracker>)t;
-(void) setInformationMergeToMin:(id<ORTracker>)t;
-(void) setInformationMergeToMinMaxSet:(id<ORTracker>)t;
-(void) setInformationMergeToMinAndMaxArrays:(id<ORTracker>)t;
-(bool) isMinMaxTopDownInfo;
-(bool) isMinMaxBottomUpInfo;
-(id) topDownInfo;
-(id) minTopDownInfo;
-(id) maxTopDownInfo;
-(id) bottomUpInfo;
-(id) minBottomUpInfo;
-(id) maxBottomUpInfo;
-(id<ORExpr>) edgeDeletionCondition;
-(id<ORExpr>) topDownInfoEdgeAddition;
-(id<ORExpr>) bottomUpInfoEdgeAddition;
-(id<ORExpr>) minTopDownInfoEdgeAddition;
-(id<ORExpr>) maxTopDownInfoEdgeAddition;
-(id<ORExpr>) minBottomUpInfoEdgeAddition;
-(id<ORExpr>) maxBottomUpInfoEdgeAddition;
-(id<ORExpr>) topDownInfoMerge;
-(id<ORExpr>) bottomUpInfoMerge;
-(id<ORExpr>) minTopDownInfoMerge;
-(id<ORExpr>) maxTopDownInfoMerge;
-(id<ORExpr>) minBottomUpInfoMerge;
-(id<ORExpr>) maxBottomUpInfoMerge;
-(bool) objective;
@end*/

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
