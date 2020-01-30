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
    id* _rootValues;
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
    
    int _minVar;
}
-(id) initMDDStateSpecification:(int)numSpecs numProperties:(int)numProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars;
-(void) addMDDSpec:(id*)rootValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(id*)rootValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(MDDStateValues*) createStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(void) replaceStateWith:(MDDStateValues*)left with:(MDDStateValues*)right;
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues;
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right;
-(int) numProperties;
-(id*) rootValues;
@end
    

@interface MDDStateValues : NSObject {
@protected
    id* _state;
    int _variableIndex;
    int _stateSize;
}
-(id) initRootState:(MDDStateSpecification*)stateSpecs variableIndex:(int)variableIndex trail:(id<ORTrail>)trail;
-(id) initState:(id*)stateValues stateSize:(int)size variableIndex:(int)variableIndex trail:(id<ORTrail>)trail;
-(int) variableIndex;
-(id*) state;
-(bool) equivalentTo:(MDDStateValues*)other;
-(NSUInteger) hashWithWidth:(int)mddWidth numVariables:(NSUInteger)numVariables;
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
