#import "ORCustomMDDStates.h"

//These methods are going to be pretty badly out of date and won't work without a lot of TLC

@interface AltCustomState : NSObject {
@protected
    id<ORTrail> _trail;
    int _variableIndex;
    int _domainMin;
    int _domainMax;
    bool _objective;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax;
-(id) initRootState:(AltCustomState*)classState variableIndex:(int)variableIndex trail:(id<ORTrail>)trail;
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax trail:(id<ORTrail>)trail;
-(id) initSinkState:(AltCustomState*)classState trail:(id<ORTrail>)trail;
-(id) initState:(AltCustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue;
-(id) initState:(AltCustomState*)parentNodeState variableIndex:(int)variableIndex;
-(void) setTopDownInfo:(id)info;
-(void) setTopDownInfoFor:(AltCustomState*)parentInfo plusEdge:(int)edgeValue;
-(void) setBottomUpInfoFor:(AltCustomState*)childInfo plusEdge:(int)edgeValue;
-(void) mergeTopDownInfoWith:(AltCustomState*)other;
-(void) mergeTopDownInfoWith:(AltCustomState*)other withEdge:(int)edgeValue onVariable:(int)otherVariable;
-(void) mergeBottomUpInfoWith:(AltCustomState*)other;
-(void) mergeBottomUpInfoWith:(AltCustomState*)other withEdge:(int)edgeValue onVariable:(int)otherVariable;
-(bool) canDeleteChild:(AltCustomState*)child atEdgeValue:(int)edgeValue;
-(bool) equivalentWithEdge:(int)edgeValue to:(AltCustomState*)other withEdge:(int)otherEdgeValue;
-(int) variableIndex;
-(id<ORTrail>) trail;
-(int) domainMin;
-(int) domainMax;
-(bool) isObjective;
@end

@interface AltMDDStateSpecification : AltCustomState {
@protected
    TRId _topDownInfo, _bottomUpInfo;
    AltMDDAddEdgeClosure _topDownEdgeAddition, _bottomUpEdgeAddition;
    AltMDDAddEdgeClosure _minTopDownEdgeAddition, _minBottomUpEdgeAddition;
    AltMDDAddEdgeClosure _maxTopDownEdgeAddition, _maxBottomUpEdgeAddition;
    AltMDDMergeInfoClosure _topDownMerge, _bottomUpMerge;
    AltMDDMergeInfoClosure _minTopDownMerge, _minBottomUpMerge;
    AltMDDMergeInfoClosure _maxTopDownMerge, _maxBottomUpMerge;
    AltMDDDeleteEdgeCheckClosure _edgeDeletionCheck;
    bool _minMaxState;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax topDownInfo:(id)topDownInfo bottomUpInfo:(id)bottomUpInfo topDownEdgeAddition:(AltMDDAddEdgeClosure)topDownInfoEdgeAdditionClosure bottomUpEdgeAddition:(AltMDDAddEdgeClosure)bottomUpInfoEdgeAdditionClosure topDownMerge:(AltMDDMergeInfoClosure)topDownMergeClosure bottomUpMerge:(AltMDDMergeInfoClosure)bottomUpMergeClosure edgeDeletion:(AltMDDDeleteEdgeCheckClosure)edgeDeletionClosure objective:(bool)objective;
-(id) initRootState:(AltMDDStateSpecification*)classState variableIndex:(int)variableIndex trail:(id<ORTrail>)trail;
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax trail:(id<ORTrail>)trail;
-(id) initSinkState:(AltMDDStateSpecification*)classState trail:(id<ORTrail>)trail;
-(id) initState:(AltMDDStateSpecification*)parentNodeState variableIndex:(int)variableIndex;
-(id) initMinMaxClassState:(int)domainMin domainMax:(int)domainMax minTopDownInfo:(id)minTopDownInfo maxTopDownInfo:(id)maxTopDownInfo minbottomUpInfo:(id)minBottomUpInfo maxBottomUpInfo:(id)maxBottomUpInfo minTopDownEdgeAddition:(AltMDDAddEdgeClosure)minTopDownInfoEdgeAdditionClosure maxTopDownEdgeAddition:(AltMDDAddEdgeClosure)maxTopDownInfoEdgeAdditionClosure minBottomUpEdgeAddition:(AltMDDAddEdgeClosure)minBottomUpInfoEdgeAdditionClosure maxBottomUpEdgeAddition:(AltMDDAddEdgeClosure)maxBottomUpInfoEdgeAdditionClosure minTopDownMerge:(AltMDDMergeInfoClosure)minTopDownMergeClosure maxTopDownMerge:(AltMDDMergeInfoClosure)maxTopDownMergeClosure minBottomUpMerge:(AltMDDMergeInfoClosure)minBottomUpMergeClosure maxBottomUpMerge:(AltMDDMergeInfoClosure)maxBottomUpMergeClosure edgeDeletion:(AltMDDDeleteEdgeCheckClosure)edgeDeletionClosure objective:(bool)objective;
-(id) topDownInfo;
-(id) bottomUpInfo;
-(AltMDDAddEdgeClosure) topDownEdgeAddition;
-(AltMDDAddEdgeClosure) bottomUpEdgeAddition;
-(AltMDDMergeInfoClosure) topDownMerge;
-(AltMDDMergeInfoClosure) bottomUpMerge;
-(AltMDDAddEdgeClosure) minTopDownEdgeAddition;
-(AltMDDAddEdgeClosure) maxTopDownEdgeAddition;
-(AltMDDAddEdgeClosure) minBottomUpEdgeAddition;
-(AltMDDAddEdgeClosure) maxBottomUpEdgeAddition;
-(AltMDDMergeInfoClosure) minTopDownMerge;
-(AltMDDMergeInfoClosure) maxTopDownMerge;
-(AltMDDMergeInfoClosure) minBottomUpMerge;
-(AltMDDMergeInfoClosure) maxBottomUpMerge;
-(AltMDDDeleteEdgeCheckClosure) edgeDeletionCheck;
-(bool) minMaxState;
@end

@interface AltJointState : AltCustomState{
@protected
    NSMutableArray* _states;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax trail:(id<ORTrail>)trail;
-(id) initSinkState:(int)domainMin domainMax:(int)domainMax trail:(id<ORTrail>)trail;
+(void) addStateClass:(AltCustomState*)stateClass withVariables:(id<ORIntVarArray>)variables;
+(void) stateClassesInit;
+(int) numStates;
+(AltCustomState*) firstState;
-(NSMutableArray*) states;
+(void) setVariables:(id<ORIntVarArray>)variables;
+(bool) hasObjective;
@end
