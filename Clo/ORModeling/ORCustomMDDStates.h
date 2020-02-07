#import <ORFoundation/ORTrailI.h>
#import "ORMDDProperties.h"

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
/*
@interface MDDStateSpecification : CustomState {
@protected
    id* _state;
    DDClosure _arcExists;
    DDClosure* _transitionFunctions;
    DDMergeClosure* _relaxationFunctions;
    DDMergeClosure* _differentialFunctions;
    int _stateSize;
    id<ORTrail> _trail;
}
-(id) initClassState:(id*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions stateSize:(int)stateSize;
-(id) initClassState:(id*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions stateSize:(int)stateSize;
-(NSUInteger) hashWithWidth:(int)mddWidth numVariables:(NSUInteger)numVariables;
-(id*) state;
-(int) stateSize;
-(id<ORTrail>) trail;
-(DDClosure)arcExistsClosure;
-(DDClosure*)transitionFunctions;
-(DDMergeClosure*) relaxationFunctions;
-(DDMergeClosure*) differentialFunctions;
-(bool) equivalentTo:(CustomState *)other;
@end*/

@class MDDStateValues;
@interface MDDStateSpecification : NSObject {
@protected
    MDDStateDescriptor* _stateDescriptor;
    DDClosure* _arcExists;
    DDClosure* _transitionFunctions;
    DDMergeClosure* _relaxationFunctions;
    DDMergeClosure* _differentialFunctions;
    id<ORTrail> _trail;
    bool _relaxed;
    
    bool** _stateValueIndicesForVariable; //Used to know which properties require transition function for a given variable assignment
    NSMutableArray** _arcExistsIndicesForVariable;   //Used to know which arc exist functions must be called to test a given variable assignment
    
    int _numPropertiesAdded;
    int _numSpecsAdded;
    size_t _numBytes;
    
    int _minVar;
    int _numVars;
    int _hashWidth;
}
-(id) initMDDStateSpecification:(int)numSpecs numProperties:(int)numProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(MDDStateValues*) createRootState:(int)variable;
-(MDDStateValues*) createStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(MDDStateValues*) createTempStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(char*) computeStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(void) replaceState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues;
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right;
-(int) numProperties;
-(size_t) numBytes;
-(MDDStateDescriptor*) stateDescriptor;
-(void) finalizeSpec:(id<ORTrail>) trail hashWidth:(int)width;
-(int) hashWidth;
@end
    

@interface MDDStateValues : NSObject {
@protected
    char* _state;
    ORUInt* _magic;
    size_t _numBytes;
    TRInt _hashValue;
    bool _tempState;
}
-(id) initState:(char*)stateValues numBytes:(size_t)numBytes;
-(id) initState:(char*)stateValues numBytes:(size_t)numBytes hashWidth:(int)width trail:(id<ORTrail>)trail;
-(char*) state;
-(void) trailByte:(size_t)byteOffset trail:(id<ORTrail>)trail;
-(bool) equivalentTo:(MDDStateValues*)other;
-(int) hashValue;
-(int) calcHash:(int)width;
-(void) setHash:(int)width trail:(id<ORTrail>)trail;
-(void) recalcHash:(int)width trail:(id<ORTrail>)trail;
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

/*
@interface FlatJointState : CustomState {
@protected
    
}
-(id) initRootState:(FlatJointState*)classState variableIndex:(int)variableIndex trail:(id<ORTrail>)trail;
-(id) initClassState;
-(void) addClassState:(MDDStateSpecification*)stateClass withVariables:(id<ORIntVarArray>)variables;
-(int) numStates;
-(NSMutableArray*) stateVars;
-(NSMutableSet**) statesForVariables;
-(id<ORIntVarArray>) vars;
-(CustomState*) firstState;
-(NSMutableArray*) states;
-(void) setVariables:(id<ORIntVarArray>)variables;
@end
*/
