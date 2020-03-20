
#import <ORFoundation/ORFoundation.h>

@interface MDDStateValues : NSObject {
@protected
    char* _state;
    ORUInt* _magic;
    size_t _numBytes;
    TRInt _hashValue;
    bool _tempState;
    id _node;
}
-(id) initState:(char*)stateValues numBytes:(size_t)numBytes;
-(id) initState:(char*)stateValues numBytes:(size_t)numBytes hashWidth:(int)width trail:(id<ORTrail>)trail;
-(char*) stateValues;
-(void) replaceStateWith:(char*)newState trail:(id<ORTrail>)trail;
-(int) calcHash:(int)width;
-(void) setHash:(int)width trail:(id<ORTrail>)trail;
-(void) recalcHash:(int)width trail:(id<ORTrail>)trail;
-(void) setNode:(id)node;
-(id) node;
@end


@interface MDDStateSpecification : NSObject {
@protected
    MDDStateDescriptor* _topDownStateDescriptor;
    MDDStateDescriptor* _bottomUpStateDescriptor;
    DDArcExistsClosure _topDownArcExists;
    DDArcExistsClosure _bottomUpArcExists;
    id<ORTrail> _trail;
    bool _relaxed;
    id<ORIntVarArray> _vars;
    
    bool** _topDownPropertiesUsedPerVariable;
    bool** _bottomUpPropertiesUsedPerVariable;
    
    int* _numTopDownArcExistsForVariable;
    int* _numBottomUpArcExistsForVariable;
    
    int _numTopDownPropertiesAdded, _numBottomUpPropertiesAdded;
    int _numSpecsAdded;
    size_t _topDownNumBytes, _bottomUpNumBytes;
    
    int _minVar;
    int _numVars;
    int _hashWidth;
    
    bool _dualDirectional;
    bool singleState;
}
-(id) initMDDStateSpecification:(int)numSpecs numTopDownProperties:(int)topDownNumProperties numBottomUpProperties:(int)bottomUpNumProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars;
-(id) initMDDStateSpecification:(id<ORMDDSpecs>)MDDSpec relaxed:(bool)relaxed;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDArcExistsClosure)arcExists transitionFunctions:(DDArcTransitionClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDArcExistsClosure)arcExists transitionFunctions:(DDArcTransitionClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDOldMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(id<ORMDDSpecs>)MDDSpec mapping:(int*)mapping;
-(MDDStateValues*) createRootState;
-(MDDStateValues*) createSinkState;
-(char*) computeTopDownStateFromProperties:(char*)parentState assigningVariable:(int)variable withValue:(int)value;
-(char*) computeBottomUpStateFromProperties:(char*)childState assigningVariable:(int)variable withValue:(int)value;
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(void) mergeTempStateProperties:(char*)leftState with:(char*)rightState;
-(void) mergeTempBottomUpStateProperties:(char*)leftState with:(char*)rightState;
-(char*) batchMergeForStates:(char**)parentStates values:(int**)edgesUsedByParent numEdgesPerParent:(int*)numEdgesPerParent variable:(int)variableIndex isMerged:(bool*)isMerged numParents:(int)numParents totalEdges:(int)totalEdges;
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues;
-(bool) canChooseValue:(int)value forVariable:(int)variable withStateProperties:(char*)state;
-(bool) canChooseValue:(int)value forVariable:(int)variable fromParent:(char*)parentState toChild:(char*)childState;
-(bool) canCreateState:(char**)newState fromParent:(MDDStateValues*)parentState assigningVariable:(int)variable toValue:(int)value;
-(long) slack:(char*)stateProperties;
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right;
-(int) numTopDownProperties;
-(int) numBottomUpProperties;
-(size_t) numTopDownBytes;
-(size_t) numBottomUpBytes;
-(int) numSpecs;
-(id<ORIntVarArray>) vars;
-(MDDStateDescriptor*) stateDescriptor;
-(bool*) topDownPropertiesUsed:(int)variableIndex;
-(bool*) bottomUpPropertiesUsed:(int)variableIndex;
-(DDArcTransitionClosure*) topDownTransitionFunctions;
-(DDArcTransitionClosure*) bottomUpTransitionFunctions;
-(void) finalizeSpec:(id<ORTrail>) trail hashWidth:(int)width;
-(NSUInteger) hashValueFor:(char*)stateProperties;
-(int) hashWidth;
@end


/*
@interface CustomState : NSObject {
@protected
    int _variableIndex;
}
-(id) initClassState;
-(id) initRootState:(CustomState*)classState variableIndex:(int)variableIndex;
-(id) initRootState:(int)variableIndex;
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue;
-(id) initState:(CustomState*)parentNodeState variableIndex:(int)variableIndex;
-(int) variableIndex;
-(void) mergeStateWith:(CustomState*)other;
-(void) replaceStateWith:(CustomState*)other;
-(bool) canChooseValue:(int)value forVariable:(int)variable;
-(int) stateDifferential:(CustomState*)other;
-(bool) equivalentTo:(CustomState*)other;
@end
*/
