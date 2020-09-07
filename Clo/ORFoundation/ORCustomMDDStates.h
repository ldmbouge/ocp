#import <ORFoundation/ORFoundation.h>


@interface MDDStateValues : NSObject {
@protected
    char* _state;
    ORUInt* _magic;
    int _numBytes;
    bool _tempState;
    id _node;
}
-(id) initState:(char*)stateValues numBytes:(int)numBytes;
-(id) initState:(char*)stateValues numBytes:(int)numBytes trail:(id<ORTrail>)trail;
-(char*) stateValues;
-(void) replaceUnusedStateWith:(char*)newState trail:(id<ORTrail>)trail;
-(void) replaceStateWith:(char*)newState trail:(id<ORTrail>)trail;
-(void) setNode:(id)node;
-(id) node;
@end


@interface MDDStateSpecification : NSObject {
@protected
    MDDStateDescriptor* _forwardStateDescriptor;
    MDDStateDescriptor* _reverseStateDescriptor;
    MDDStateDescriptor* _combinedStateDescriptor;
    DDArcExistsClosure _arcExists;
    DDStateExistsClosure _stateExists;
    id<ORTrail> _trail;
    id<ORIntVarArray> _vars;
    
    bool** _forwardPropertiesUsedPerVariable;
    bool** _reversePropertiesUsedPerVariable;
    
    bool** _forwardPropertiesUsedPerSpec;
    
    int* _numArcExistsForVariable;
    
    int _numForwardPropertiesAdded, _numReversePropertiesAdded, _numCombinedPropertiesAdded;
    int _numSpecsAdded;
    int _numForwardBytes, _numReverseBytes, _numCombinedBytes;
    
    int _minVar;
    int _maxVar;
    int _numVars;
    int _minDom;
    int _maxDom;
    int _domSize;
    int _hashWidth;
    int _mergeCacheHashWidth;
    int _transitionCacheHashWidth;
    
    bool _dualDirectional;
}
-(id) initMDDStateSpecification:(int)numSpecs numForwardProperties:(int)numForwardProperties numReverseProperties:(int)numReverseProperties numCombinedProperties:(int)numCombinedProperties vars:(id<ORIntVarArray>)vars;
-(void) addMDDSpec:(id<ORMDDSpecs>)MDDSpec mapping:(int*)mapping;
-(bool) dualDirectional;
-(MDDStateValues*) createRootState;
-(MDDStateValues*) createSinkState;
-(char*) cachedComputeForwardStateFromForward:(char*)forward combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet minDom:(int)minDom maxDom:(int)maxDom;
-(char*) computeForwardStateFromForward:(char*)forward combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom;
-(char*) computeForwardStateFromForward:(char*)forward combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom merged:(bool*)merged;
-(char*) updateForwardStateFromForward:(char*)forward combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState merged:(bool*)merged;
-(char*) computeReverseStateFromProperties:(char*)reverse combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom;
-(char*) updateReverseStateFromReverse:(char*)reverse combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState;
-(char*) computeCombinedStateFromProperties:(char*)forward reverse:(char*)reverse;
-(void) cachedMergeStateProperties:(char*)leftState with:(char*)rightState;
-(void) mergeStateProperties:(char*)leftState with:(char*)rightState;
-(void) mergeStateProperties:(char*)leftState with:(char*)rightState properties:(bool*)properties;
-(void) mergeReverseStateProperties:(char*)leftState with:(char*)rightState properties:(bool*)properties;
-(void) cachedMergeReverseStateProperties:(char*)leftState with:(char*)rightState;
-(void) mergeReverseStateProperties:(char*)leftState with:(char*)rightState;
-(bool) canChooseValue:(int)value forVariable:(int)variable fromParentForward:(char*)parentForward combined:(char*)parentCombined toChildReverse:(char*)childReverse combined:(char*)childCombined objectiveMins:(TRInt*)objectiveMins objectiveMaxes:(TRInt*)objectiveMaxes;
-(bool) canCreateState:(char**)newState forward:(char*)forward combined:(char*)combined assigningVariable:(int)variable toValue:(int)value objectiveMins:(TRInt*)objectiveMins objectiveMaxes:(TRInt*)objectiveMaxes;
-(bool) stateExistsWithForward:(char*)forward reverse:(char*)reverse combined:(char*)combined objectiveMins:(TRInt*)objectiveMins objectiveMaxes:(TRInt*)objectiveMaxes;
-(int) nodePriority:(char*)forward reverse:(char*)reverse combined:(char*)combined;
-(int) nodePriority:(char*)forward reverse:(char*)reverse combined:(char*)combined forConstraint:(int)constraintIndex;
-(int) arcPriority:(char*)parentForward parentCombined:(char*)parentCombined childReverse:(char*)childReverse childCombined:(char*)childCombined arcValue:(int)value;
-(bool*) diffForwardProperties:(char*)left to:(char*)right;
-(bool*) diffReverseProperties:(char*)left to:(char*)right;
-(bool*) forwardPropertyImpactFrom:(bool**)parentDeltas numParents:(int)numParents variable:(int)variable;
-(bool*) reversePropertyImpactFrom:(bool**)childDeltas numChildren:(int)numChildren variable:(int)variable;
-(int) numForwardBytes;
-(int) numReverseBytes;
-(int) numCombinedBytes;
-(int) numForwardProperties;
-(int) numReverseProperties;
-(int) numCombinedProperties;
-(int) numSpecs;
-(id<ORIntVarArray>) vars;
-(id<ORIntVar>*) fixpointVars;
-(DDFixpointBoundClosure*) fixpointMins;
-(DDFixpointBoundClosure*) fixpointMaxes;
-(void) finalizeSpec:(id<ORTrail>) trail hashWidth:(int)width;
-(int) hashWidth;
-(int) hashValueForState:(char*)state;
-(int) hashValueForState:(char*)state constraint:(int)constraint;
-(bool) state:(char*)state equivalentTo:(char*)other forConstraint:(int)constraint;
-(bool) approximateEquivalenceUsedFor:(int)constraint;
-(int) equivalenceClassFor:(char*)forward reverse:(char*)reverse constraint:(int)constraint;
+(short) bytesPerMagic;
@end
