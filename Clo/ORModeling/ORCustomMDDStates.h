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
    DDClosure* _arcExists;
    DDClosure* _transitionFunctions;
    DDMergeClosure* _relaxationFunctions;
    DDMergeClosure* _differentialFunctions;
    id<ORTrail> _trail;
    bool _relaxed;
    
    bool** _stateValueIndicesForVariable; //Used to know which properties require transition function for a given variable assignment
    DDClosure* _arcExistsForVariable;
    
    DDClosure** _arcExistsListsForVariable;
    int* _numArcExistsForVariable;
    
    int _numPropertiesAdded;
    int _numSpecsAdded;
    size_t _numBytes;
    
    int _minVar;
    int _numVars;
    int _hashWidth;
}
-(id) initMDDStateSpecification:(int)numSpecs numProperties:(int)numProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars;
-(id) initMDDStateSpecification:(int)numSpecs numProperties:(int)numProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars stateDescriptor:(MDDStateDescriptor*)stateDescriptor;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(ORMDDSpecs*)MDDSpec mapping:(int*)mapping;
-(MDDStateValues*) createRootState:(int)variable;
-(MDDStateValues*) createStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(MDDStateValues*) createStateWith:(char*)stateProperties;
-(MDDStateValues*) createTempStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(char*) computeStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(char*) computeStateFromProperties:(char*)parentState assigningVariable:(int)variable withValue:(int)value;
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(void) replaceState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues;
-(bool) canChooseValue:(int)value forVariable:(int)variable withStateProperties:(char*)state;
-(bool) canCreateState:(char**)newState fromParent:(MDDStateValues*)parentState assigningVariable:(int)variable toValue:(int)value;
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right;
-(int) numProperties;
-(size_t) numBytes;
-(MDDStateDescriptor*) stateDescriptor;
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
-(void) trailByte:(size_t)byteOffset trail:(id<ORTrail>)trail;
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
