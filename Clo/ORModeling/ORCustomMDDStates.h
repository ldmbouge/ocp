#import <ORFoundation/ORTrailI.h>
#import "ORMDDProperties.h"
#import "ORConstraintI.h"
#import "CPTopDownMDDNode.h"

@class MDDStateValues;

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

@interface MDDStateSpecification : NSObject {
@protected
    MDDStateDescriptor* _stateDescriptor;
    MDDPropertyDescriptor** _properties;
    DDArcClosure _arcExists;
    DDNewStateClosure* _transitionFunctions;
    DDMergeClosure* _relaxationFunctions;
    DDMergeClosure* _differentialFunctions;
    DDSlackClosure* _slackClosures;
    id<ORTrail> _trail;
    bool _relaxed;
    id<ORIntVarArray> _vars;
    
    bool** _stateValueIndicesForVariable; //Used to know which properties require transition function for a given variable assignment
    DDArcClosure* _arcExistsForVariable;
    
    DDArcClosure** _arcExistsListsForVariable;
    int* _numArcExistsForVariable;
    
    int _numPropertiesAdded;
    int _numSpecsAdded;
    size_t _numBytes;
    
    int _minVar;
    int _numVars;
    int _hashWidth;
    
    bool singleState;
}
-(id) initMDDStateSpecification:(int)numSpecs numProperties:(int)numProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars;
-(id) initMDDStateSpecification:(ORMDDSpecs*)MDDSpec relaxed:(bool)relaxed;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDArcClosure)arcExists transitionFunctions:(DDNewStateClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDArcClosure)arcExists transitionFunctions:(DDNewStateClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(ORMDDSpecs*)MDDSpec mapping:(int*)mapping;
-(MDDStateValues*) createRootState:(int)variable;
-(char*) computeStateFromProperties:(char*)parentState assigningVariable:(int)variable withValue:(int)value;
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(void) mergeTempStateProperties:(char*)leftState with:(char*)rightState;
-(char*) batchMergeForStates:(char**)parentStates values:(int**)edgesUsedByParent numEdgesPerParent:(int*)numEdgesPerParent variable:(int)variableIndex isMerged:(bool*)isMerged numParents:(int)numParents totalEdges:(int)totalEdges;
-(bool) replaceArcState:(MDDArc*)arcState withParentProperties:(char*)parentProperties variable:(int)variable;
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues;
-(bool) canChooseValue:(int)value forVariable:(int)variable withStateProperties:(char*)state;
-(bool) canCreateState:(char**)newState fromParent:(MDDStateValues*)parentState assigningVariable:(int)variable toValue:(int)value;
-(long) slack:(char*)stateProperties;
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right;
-(int) numProperties;
-(size_t) numBytes;
-(int) numSpecs;
-(id<ORIntVarArray>) vars;
-(MDDStateDescriptor*) stateDescriptor;
-(bool*) propertiesUsed:(int)variableIndex;
-(DDNewStateClosure*) transitionFunctions;
-(void) finalizeSpec:(id<ORTrail>) trail hashWidth:(int)width;
-(NSUInteger) hashValueFor:(char*)stateProperties;
-(int) hashWidth;
@end
    

@interface MDDStateValues : NSObject<NSCopying> {
@protected
    char* _state;
    ORUInt* _magic;
    size_t _numBytes;
    TRInt _hashValue;
    bool _tempState;
    Node* _node;
}
-(id) initState:(char*)stateValues numBytes:(size_t)numBytes;
-(id) initState:(char*)stateValues numBytes:(size_t)numBytes hashWidth:(int)width trail:(id<ORTrail>)trail;
-(char*) state;
-(BOOL) isEqual:(MDDStateValues*)other;
-(void) replaceStateWith:(char*)newState trail:(id<ORTrail>)trail;
-(BOOL) isEqualToStateProperties:(char*)other;
-(BOOL) isEqualToMDDStateValues:(MDDStateValues*)other;
-(int) calcHash:(int)width;
-(void) setHash:(int)width trail:(id<ORTrail>)trail;
-(void) recalcHash:(int)width trail:(id<ORTrail>)trail;
-(void) setNode:(Node*)node;
-(Node*) node;
@end

@interface JointState : CustomState {
@protected
    NSMutableArray* _states;
    NSMutableArray* _stateVars;
    id<ORIntVarArray> _vars;
    NSMutableSet* *_statesForVariables;
}
-(id) initRootState:(JointState*)classState variableIndex:(int)variableIndex trail:(id<ORTrail>)trail;
-(id) initClassState;
-(void) addClassState:(CustomState*)stateClass withVariables:(id<ORIntVarArray>)variables;
-(int) numStates;
-(NSMutableArray*) stateVars;
-(NSMutableSet**) statesForVariables;
-(id<ORIntVarArray>) vars;
-(CustomState*) firstState;
-(NSMutableArray*) states;
-(void) setVariables:(id<ORIntVarArray>)variables;
@end
