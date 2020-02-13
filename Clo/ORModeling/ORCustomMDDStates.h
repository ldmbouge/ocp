#import <ORFoundation/ORTrailI.h>
#import "ORMDDProperties.h"
#import "ORConstraintI.h"

@class MDDStateValues;
@interface Node : NSObject {
@public
    int _value;
    bool _isSink;
    bool _isSource;
    id<ORTrail> _trail;
    
    TRId* _children;
    TRInt _numChildren;
    int _minChildIndex;
    int _maxChildIndex;
    
    ORTRIdArrayI* _uniqueParents;
    ORTRIntArrayI* _parentCounts;
    TRInt _numUniqueParents;
    TRInt _maxNumUniqueParents;
    
    MDDStateValues* _state;
    TRInt _isMergedNode;
    bool _recalcRequired;
}
-(id) initNode: (id<ORTrail>) trail hashWidth:(int)hashWidth;
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(MDDStateValues*)state hashWidth:(int)hashWidth;
-(void) dealloc;
-(TRId) getState;
-(int) value;
-(bool) isMergedNode;
-(void) setIsMergedNode:(bool)isMergedNode;
-(bool) recalcRequired;
-(void) setRecalcRequired:(bool)recalcRequired;
-(bool) isVital;
-(void) setIsSource:(bool)isSource;
-(void) setIsSink:(bool)isSink;
-(bool) isNonVitalAndChildless;
-(bool) isNonVitalAndParentless;
-(TRId*) children;
-(int) numChildren;
-(void) addChild:(Node*)child at:(int)index;
-(void) removeChildAt: (int) index;
-(void) removeChild:(Node*)child numTimes:(int)childCount updatingLVC:(TRInt*)variable_count;
-(void) replaceChild:(Node*)oldChild with:(Node*)newChild numTimes:(int)childCount;
-(bool) hasParents;
-(void) addParent: (Node*) parent;
-(bool) hasParent:(Node*)parent;
-(int) countForParent:(Node*)parent;
-(int) countForParentIndex:(int)parent_index;
-(int) findUniqueParentIndexFor:(Node*) parent addToHash:(bool)addToHash;
-(void) removeParentAt:(int)index;
-(void) removeParentOnce: (Node*) parent;
-(void) removeParentValue: (Node*) parent;
-(void) takeParentsFrom:(Node*)other;
@end
static inline id getState(Node* n) { return n->_state;}

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
-(id) initMDDStateSpecification:(int)numSpecs numProperties:(int)numProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars stateDescriptor:(MDDStateDescriptor*)stateDescriptor;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping;
-(void) addMDDSpec:(ORMDDSpecs*)MDDSpec mapping:(int*)mapping;
-(MDDStateValues*) createRootState:(int)variable;
-(MDDStateValues*) createStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(MDDStateValues*) createTempStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(char*) computeStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value;
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(void) replaceState:(MDDStateValues*)left with:(MDDStateValues*)right;
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues;
-(bool) canCreateState:(MDDStateValues**)newState fromParent:(MDDStateValues*)parentState assigningVariable:(int)variable toValue:(int)value;
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right;
-(int) numProperties;
-(size_t) numBytes;
-(MDDStateDescriptor*) stateDescriptor;
-(void) finalizeSpec:(id<ORTrail>) trail hashWidth:(int)width;
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
