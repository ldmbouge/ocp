/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORVisit.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORVisit.h>
#import "ORMDDVisitors.h"

@interface AltCustomState : NSObject {
@protected
    int _variableIndex;
    int _domainMin;
    int _domainMax;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax;
-(id) initRootState:(AltCustomState*)classState variableIndex:(int)variableIndex;
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax;
-(id) initSinkState:(AltCustomState*)classState;
-(id) initState:(AltCustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue;
-(id) initState:(AltCustomState*)parentNodeState variableIndex:(int)variableIndex;
-(void) setTopDownInfoFor:(AltCustomState*)parentInfo plusEdge:(int)edgeValue;
-(void) setBottomUpInfoFor:(AltCustomState*)childInfo plusEdge:(int)edgeValue;
-(void) mergeTopDownInfoWith:(AltCustomState*)other;
-(void) mergeBottomUpInfoWith:(AltCustomState*)other;
-(bool) canDeleteChild:(AltCustomState*)child atEdgeValue:(int)edgeValue;
-(bool) equivalentWithEdge:(int)edgeValue to:(AltCustomState*)other withEdge:(int)otherEdgeValue;
-(int) variableIndex;
-(int) domainMin;
-(int) domainMax;
+(void) setAsOnlyMDDWithClassState:(AltCustomState*)classState;
@end

@interface CustomState : NSObject {
@protected
    int _variableIndex;
    //    char* _stateChar;
    int _domainMin;
    int _domainMax;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax;
-(id) initRootState:(CustomState*)classState variableIndex:(int)variableIndex;
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax;
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue;
-(id) initState:(CustomState*)parentNodeState variableIndex:(int)variableIndex;
//-(char*) stateChar;
-(int) variableIndex;
-(int) domainMin;
-(int) domainMax;
-(void) mergeStateWith:(CustomState*)other;
-(int) numPathsWithNextVariable:(int)variable;
-(NSArray*) tempAlterStateAssigningValue:(int)value withNextVariable:(int)nextVariable;
-(void) undoChanges:(NSArray*)savedChanges;
-(bool) canChooseValue:(int)value forVariable:(int)variable;
-(int) stateDifferential:(CustomState*)other;
-(bool) equivalentTo:(CustomState*)other;
+(void) setAsOnlyMDDWithClassState:(CustomState*)classState;
@end

@interface MDDStateSpecification : CustomState {
@protected
    int* _state;
    DDClosure _arcExists;
    DDClosure* _transitionFunctions;
    DDMergeClosure* _relaxationFunctions;
    DDMergeClosure* _differentialFunctions;
    int _stateSize;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax state:(int*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions stateSize:(int)stateSize;
-(id) initClassState:(int)domainMin domainMax:(int)domainMax state:(int*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions stateSize:(int)stateSize;
-(id) initClassState:(int)domainMin domainMax:(int)domainMax state:(int*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions stateSize:(int)stateSize;
-(int*) state;
-(int) stateSize;
-(DDClosure)arcExistsClosure;
-(DDClosure*)transitionFunctions;
-(DDMergeClosure*) relaxationFunctions;
-(DDMergeClosure*) differentialFunctions;
-(bool) equivalentTo:(CustomState *)other;
@end
@interface AltMDDStateSpecification : AltCustomState {
@protected
    id _topDownInfo, _bottomUpInfo;
    AltMDDAddEdgeClosure _topDownEdgeAddition, _bottomUpEdgeAddition;
    AltMDDMergeInfoClosure _topDownMerge, _bottomUpMerge;
    AltMDDDeleteEdgeCheckClosure _edgeDeletionCheck;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax topDownInfo:(id)topDownInfo bottomUpInfo:(id)bottomUpInfo topDownEdgeAddition:(AltMDDAddEdgeClosure)topDownInfoEdgeAdditionClosure bottomUpEdgeAddition:(AltMDDAddEdgeClosure)bottomUpInfoEdgeAdditionClosure topDownMerge:(AltMDDMergeInfoClosure)topDownMergeClosure bottomUpMerge:(AltMDDMergeInfoClosure)bottomUpMergeClosure edgeDeletion:(AltMDDDeleteEdgeCheckClosure)edgeDeletionClosure;
-(id) initRootState:(AltMDDStateSpecification*)classState variableIndex:(int)variableIndex;
-(id) initSinkState:(AltMDDStateSpecification*)classState;
-(id) topDownInfo;
-(id) bottomUpInfo;
-(AltMDDAddEdgeClosure) topDownEdgeAddition;
-(AltMDDAddEdgeClosure) bottomUpEdgeAddition;
-(AltMDDMergeInfoClosure) topDownMerge;
-(AltMDDMergeInfoClosure) bottomUpMerge;
-(AltMDDDeleteEdgeCheckClosure) edgeDeletionCheck;
@end

@interface CustomBDDState : CustomState {   //A state with a list of booleans corresponding to whether or not each variable can be assigned 1
@protected
    bool* _state;
}
-(bool*) state;
@end

@interface KnapsackBDDState : CustomBDDState {
@protected
    int _weightSum;
    id<ORIntVar> _capacity;
//    int _capacityNumDigits;
    id<ORIntArray> _weights;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax capacity:(id<ORIntVar>)capacity weights:(id<ORIntArray>)weights;
-(int) weightSum;
-(int) getWeightForVariable:(int)variable;
-(int*) getWeightsForVariable:(int)variable;
-(id<ORIntVar>) capacity;
//-(int) capacityNumDigits;
-(id<ORIntArray>) weights;
@end

@interface AllDifferentMDDState : CustomState {
@protected
    bool* _state;
}
-(bool*) state;
@end

@interface AmongMDDState : CustomState {
@protected
    int _minState;
    int _maxState;
    ORInt _lowerBound;
    ORInt _upperBound;
    id<ORIntSet> _set;
    int _numVarsRemaining;
    
    //    ORInt _upperBoundNumDigits;
}
-(int)minState;
-(int)maxState;
-(int)lowerBound;
-(int)upperBound;
//-(int)numDigits;
-(id<ORIntSet>)set;
-(int)numVarsRemaining;
@end

@interface AltJointState : CustomState{
@protected
    NSMutableArray* _states;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax;
-(id) initSinkState:(int)domainMin domainMax:(int)domainMax;
+(void) addStateClass:(AltCustomState*)stateClass withVariables:(id<ORIntVarArray>)variables;
+(void) stateClassesInit;
+(int) numStates;
+(AltCustomState*) firstState;
-(NSMutableArray*) states;
@end

@interface JointState : CustomState {
@protected
    NSMutableArray* _states;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax;
+(void) addStateClass:(CustomState*)stateClass withVariables:(id<ORIntVarArray>)variables;
+(void) stateClassesInit;
+(int) numStates;
+(CustomState*) firstState;
-(NSMutableArray*) states;
@end

@interface ORMDDify : ORVisitor<ORModelTransformation>
-(id) initORMDDify: (id<ORAddToModel>) target;
-(id<ORAddToModel>) target;
-(NSDictionary*) checkForStateEquivalences:(id<ORMDDSpecs>)mergeInto and:(id<ORMDDSpecs>)other;
-(bool) areEquivalent:(id<ORMDDSpecs>)mergeInto atIndex:(int)index1 and:(id<ORMDDSpecs>)other atIndex:(int)index2 withDependentMapping:(NSMutableDictionary*)dependentMappings andConfirmedMapping:(NSMutableDictionary*)confirmedMappings equivalenceVisitor:(ORDDExpressionEquivalenceChecker*)equivalenceChecker candidates:(int**)candidates;
-(void) combineMDDSpecs;
@end
