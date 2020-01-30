

#import "ORCustomMDDStates.h"

@implementation CustomState
-(id) initClassState {
    return self;
}
-(id) initRootState:(int)variableIndex {
    _variableIndex = variableIndex;
    return self;
}
-(id) initRootState:(CustomState*)classState variableIndex:(int)variableIndex {
    _variableIndex = variableIndex;
    return self;
}
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    _variableIndex = variableIndex;
    return self;
}
-(id) initState:(CustomState*)parentNodeState variableIndex:(int)variableIndex {
    _variableIndex = variableIndex;
    return self;
}
-(int) variableIndex { return _variableIndex; }
-(void) mergeStateWith:(CustomState *)other {
    return;
}
-(void) replaceStateWith:(CustomState *)other {
    return;
}
-(bool) canChooseValue:(int)value forVariable:(int)variable {
    return true;
}
-(int) stateDifferential:(CustomState*)other {
    return 1;
}
-(bool) equivalentTo:(CustomState*)other {
    return false;
}
@end
/*
@implementation MDDStateSpecification
-(id) initClassState:(id*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions stateSize:(int)stateSize;
{
    _stateSize = stateSize;
    _state = calloc(_stateSize, sizeof(TRId));
    for (int i = 0; i < _stateSize; i++) {
        _state[i] = makeTRId(_trail, [stateValues[i] copy]);
    }
    _arcExists = arcExists;
    _transitionFunctions = transitionFunctions;
    return self;
}
-(id) initClassState:(id*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions stateSize:(int)stateSize;
{
    _stateSize = stateSize;
    _state = calloc(_stateSize, sizeof(TRId));
    for (int i = 0; i < _stateSize; i++) {
        _state[i] = makeTRId(_trail, [stateValues[i] copy]);
    }
    _arcExists = arcExists;
    _transitionFunctions = transitionFunctions;
    _relaxationFunctions = relaxationFunctions;
    _differentialFunctions = differentialFunctions;
    return self;
}
-(id) initRootState:(MDDStateSpecification*)classState variableIndex:(int)variableIndex trail:(id<ORTrail>)trail {
    self = [super initRootState:classState variableIndex:variableIndex];
    _stateSize = [classState stateSize];
    _state = calloc(_stateSize, sizeof(TRId));
    id* classStateState = [classState state];
    _trail = trail;
    for (int i = 0; i < _stateSize; i++) {
        _state[i] = makeTRId(_trail, classStateState[i]);
    }
    _arcExists = [classState arcExistsClosure];
    _transitionFunctions = [classState transitionFunctions];
    _relaxationFunctions = [classState relaxationFunctions];
    _differentialFunctions = [classState differentialFunctions];
    return self;
}

-(id) initState:(MDDStateSpecification*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _stateSize = [parentNodeState stateSize];
    id* parentState = [parentNodeState state];
    ORInt parentVar = [parentNodeState variableIndex];
    
    _trail = [parentNodeState trail];
    _state = malloc(_stateSize * sizeof(TRId));
    _arcExists = [parentNodeState arcExistsClosure];
    _transitionFunctions = [parentNodeState transitionFunctions];
    _relaxationFunctions = [parentNodeState relaxationFunctions];
    _differentialFunctions = [parentNodeState differentialFunctions];
    
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        _state[stateIndex] = makeTRId(_trail, (id)_transitionFunctions[stateIndex](parentState, parentVar, edgeValue));
    }
    return self;
}
-(id) initState:(MDDStateSpecification*)parentNodeState variableIndex:(int)variableIndex {
    self = [super initState:parentNodeState variableIndex:variableIndex];
    id* parentState = [parentNodeState state];
    _trail = [parentNodeState trail];
    _stateSize = [parentNodeState stateSize];
    _state = malloc(_stateSize * sizeof(id));
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        _state[stateIndex] = makeTRId(_trail, [parentState[stateIndex] copy]);
    }
    
    _arcExists = [parentNodeState arcExistsClosure];
    _transitionFunctions = [parentNodeState transitionFunctions];
    _relaxationFunctions = [parentNodeState relaxationFunctions];
    _differentialFunctions = [parentNodeState differentialFunctions];
    return self;
}
-(void)dealloc
{
    //free(_state);
    [super dealloc];
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    return [(id)_arcExists(_state, variable, value) boolValue];
}
-(void) mergeStateWith:(MDDStateSpecification*)other {
    id* ptrOS = other.state;
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        DDMergeClosure relaxationFunction = _relaxationFunctions[stateIndex];
        if (relaxationFunction != NULL) {
            assignTRId(&_state[stateIndex], (id)relaxationFunction(_state, ptrOS), _trail);
        }
    }
}
-(void) replaceStateWith:(MDDStateSpecification*)other {
    id* ptrOS = other.state;
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        assignTRId(&_state[stateIndex], ptrOS[stateIndex], _trail);
    }
}
-(int) stateDifferential:(MDDStateSpecification*)other {
    int differential = 0;
    id* other_state = [other state];
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        if (_differentialFunctions[stateIndex] != NULL) {
            differential += [(id)_differentialFunctions[stateIndex](_state,other_state) intValue];
         }
        
        //differential += pow(_state[stateIndex] - other_state[stateIndex],2);
        //if (![_state[stateIndex] isEqual: other_state[stateIndex]]) {
        //    differential++;
        //}
    }
    return differential;
}
-(bool) equivalentTo:(MDDStateSpecification*)other {
    id* other_state = [other state];
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        if (![_state[stateIndex] isEqual: other_state[stateIndex]]) {
            return false;
        }
    }
    return true;
}

//Use size of sequence as 'prime' multiplier here.
//Use a number for the hash table size (to modulo by) that is twice the width of MDD
//Set up these hash tables for each layer
//Afterwards, should these hash tables be kept after creation?
-(NSUInteger) hashWithWidth:(int)mddWidth numVariables:(NSUInteger)numVariables {
    NSUInteger hashValue = 1;
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        hashValue = hashValue * numVariables + [_state[stateIndex] hash];
    }
    return (hashValue % (mddWidth * 2));
}
-(id*) state { return _state; }
-(int) stateSize { return _stateSize; }
-(id<ORTrail>) trail { return _trail; }
-(DDClosure)arcExistsClosure { return _arcExists; }
-(DDClosure*)transitionFunctions { return _transitionFunctions; }
-(DDMergeClosure*)relaxationFunctions { return _relaxationFunctions; }
-(DDMergeClosure*)differentialFunctions { return _differentialFunctions; }
@end*/

@implementation MDDStateSpecification
-(id) initMDDStateSpecification:(int)numSpecs numProperties:(int)numProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars {
    _relaxed = relaxed;
    _rootValues = malloc(numProperties * sizeof(TRId));
    _arcExists = malloc(numSpecs * sizeof(DDClosure));
    _transitionFunctions = calloc(numProperties, sizeof(DDClosure));
    if (_relaxed) {
        _relaxationFunctions = calloc(numProperties, sizeof(DDMergeClosure));
        _differentialFunctions = calloc(numProperties, sizeof(DDMergeClosure));
    }
    _numPropertiesAdded = 0;
    _numSpecsAdded = 0;
    _stateValueIndicesForVariable = malloc([vars count] * sizeof(bool*));
    _stateValueIndicesForVariable -= [vars low];
    _arcExistsIndicesForVariable = malloc([vars count] * sizeof(NSMutableArray*));
    _arcExistsIndicesForVariable -= [vars low];
    for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
        _stateValueIndicesForVariable[varIndex] = calloc(numProperties, sizeof(bool));
        _arcExistsIndicesForVariable[varIndex] = [[NSMutableArray alloc] init];
    }
    _minVar = [vars low];
    return self;
}
-(void) dealloc {
    _stateValueIndicesForVariable += _minVar;
    _arcExistsIndicesForVariable += _minVar;
    free(_stateValueIndicesForVariable);
    free(_arcExistsIndicesForVariable);
    [super dealloc];
}

-(void) addMDDSpec:(id*)rootValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping {
    for (int i = 0; i < numProperties; i++) {
        _rootValues[_numPropertiesAdded] = makeTRId(_trail, [rootValues[i] copy]);
        _transitionFunctions[_numPropertiesAdded] = transitionFunctions[i];
        for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
            _stateValueIndicesForVariable[mapping[varIndex]][_numPropertiesAdded] = true;
        }
        _numPropertiesAdded++;
    }
    _arcExists[_numSpecsAdded] = arcExists;
    NSNumber* arcExistsIndex = [NSNumber numberWithInt:_numSpecsAdded];
    for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
        [_arcExistsIndicesForVariable[mapping[varIndex]] addObject:arcExistsIndex];
    }
    _numSpecsAdded++;
}
-(void) addMDDSpec:(id*)rootValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping {
    for (int i = 0; i < numProperties; i++) {
        _rootValues[_numPropertiesAdded] = makeTRId(_trail, [rootValues[i] copy]);
        _transitionFunctions[_numPropertiesAdded] = transitionFunctions[i];
        _relaxationFunctions[_numPropertiesAdded] = relaxationFunctions[i];
        _differentialFunctions[_numPropertiesAdded] = differentialFunctions[i];
        for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
            _stateValueIndicesForVariable[mapping[varIndex]][_numPropertiesAdded] = true;
        }
        _numPropertiesAdded++;
    }
    _arcExists[_numSpecsAdded] = arcExists;
    NSNumber* arcExistsIndex = [NSNumber numberWithInt:_numSpecsAdded];
    for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
        [_arcExistsIndicesForVariable[mapping[varIndex]] addObject:arcExistsIndex];
    }
    _numSpecsAdded++;
}
-(MDDStateValues*) createStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value {
    id* parentState = parent.state;
    id* newState = malloc(_numPropertiesAdded * sizeof(TRId));
    for (int stateIndex = 0; stateIndex < _numPropertiesAdded; stateIndex++) {
        if (_stateValueIndicesForVariable[variable][stateIndex]) {
            newState[stateIndex] = makeTRId(_trail, (id)_transitionFunctions[stateIndex](parentState, variable, value));
        } else {
            newState[stateIndex] = makeTRId(_trail, [parentState[stateIndex] copy]);
        }
    }
    return [[MDDStateValues alloc] initState:newState stateSize:_numPropertiesAdded variableIndex:variable trail:_trail];
}
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right {
    id* leftState = left.state;
    id* rightState = right.state;
    for (int stateIndex = 0; stateIndex < _numPropertiesAdded; stateIndex++) {
        assignTRId(&leftState[stateIndex], (id)_relaxationFunctions[stateIndex](leftState, rightState), _trail);
    }
}
-(void) replaceStateWith:(MDDStateValues*)left with:(MDDStateValues*)right {
    id* leftState = left.state;
    id* rightState = right.state;
    for (int stateIndex = 0; stateIndex < _numPropertiesAdded; stateIndex++) {
        assignTRId(&leftState[stateIndex], rightState[stateIndex], _trail);
    }
}
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues {
    NSArray* arcExistIndices = _arcExistsIndicesForVariable[variable];
    id* state = [stateValues state];
    for (NSNumber* arcExistIndex in arcExistIndices) {
        if (![(id)_arcExists[[arcExistIndex intValue]](state,variable,value) boolValue]) {
            return false;
        }
    }
    return true;
}
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right {
    int differential = 0;
    id* leftState = left.state;
    id* rightState = right.state;
    for (int stateIndex = 0; stateIndex < _numPropertiesAdded; stateIndex++) {
        DDMergeClosure differentialFunction = _differentialFunctions[stateIndex];
        if (differentialFunction != nil) {
            differential += [(id)differentialFunction(leftState,rightState) intValue];
         }
    }
    return differential;
}
-(int) numProperties { return _numPropertiesAdded; }
-(id*) rootValues { return _rootValues; }
@end

@implementation MDDStateValues
-(id) initRootState:(MDDStateSpecification*)stateSpecs variableIndex:(int)variableIndex trail:(id<ORTrail>)trail {
    _stateSize = [stateSpecs numProperties];
    _variableIndex = variableIndex;
    id* rootState = [stateSpecs rootValues];
    _state = calloc(_stateSize, sizeof(TRId));
    for (int i = 0; i < _stateSize; i++) {
        _state[i] = makeTRId(trail, rootState[i]);
    }
    return self;
}
-(id) initState:(id*)stateValues stateSize:(int)size variableIndex:(int)variableIndex trail:(id<ORTrail>)trail {
    self = [super init];
    _stateSize = size;
    _variableIndex = variableIndex;
    _state = stateValues;   //This is only called from MDDStateSpecification which creates a wholly new id* which it passes to this.  No need to copy it all over and no danger of it being changed, deleted, or reused elsewhere.
    return self;
}
-(int) variableIndex { return _variableIndex; }
-(id*) state { return _state; }
-(bool) equivalentTo:(MDDStateValues*)other {
    id* other_state = [other state];
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        if (![_state[stateIndex] isEqual: other_state[stateIndex]]) {
            return false;
        }
    }
    return true;
}
-(NSUInteger) hashWithWidth:(int)mddWidth numVariables:(NSUInteger)numVariables {
    NSUInteger hashValue = 1;
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        hashValue = hashValue * numVariables + [_state[stateIndex] hash];
    }
    return (hashValue % (mddWidth * 2));
}
@end
/*
@implementation JointState
-(id) initClassState
{
    _states = [[NSMutableArray alloc] init];
    _stateVars = [[NSMutableArray alloc] init];
    return self;
}
-(void)dealloc
{
    [_states release];
    [super dealloc];
}
-(id) initRootState:(JointState*)classState variableIndex:(int)variableIndex trail:(id<ORTrail>)trail {
    _variableIndex = variableIndex;
    _states = [[NSMutableArray alloc] init];
    _stateVars = [classState stateVars];
    _vars = [classState vars];
    _statesForVariables = [classState statesForVariables];
    NSArray* classStateArray = [classState states];
    for (int stateIndex = 0; stateIndex < [classState numStates]; stateIndex++) {
        MDDStateSpecification* stateClass = [classStateArray objectAtIndex:stateIndex];
        MDDStateSpecification* state = [[MDDStateSpecification alloc] initRootState:stateClass variableIndex:variableIndex trail:trail];
        [_states addObject: state];
    }
    return self;
}
-(id) initState:(JointState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _states = [[NSMutableArray alloc] init];
    _stateVars = parentNodeState->_stateVars; //[parentNodeState stateVars];
    _vars = parentNodeState->_vars;//[parentNodeState vars];
    _statesForVariables = parentNodeState->_statesForVariables;//[parentNodeState statesForVariables];
    NSMutableArray* parentStates = parentNodeState->_states;//[parentNodeState states];
    NSMutableSet* statesForVariable = _statesForVariables[[parentNodeState variableIndex]];
    for (int stateIndex = 0; stateIndex < [parentStates count]; stateIndex++) {
        CustomState* stateClass = parentStates[stateIndex];
        CustomState* state;
        //if ([(id<ORIdArray>)(_stateVars[stateIndex]) contains:[_vars at: [parentNodeState variableIndex]]]) {
        if ([statesForVariable containsObject:[NSNumber numberWithInt:stateIndex]]) {
            state = [[[stateClass class] alloc] initState:stateClass assigningVariable:variableIndex withValue:edgeValue];
        } else {
            state = [[[stateClass class] alloc] initState:stateClass variableIndex:variableIndex];
        }
        [_states addObject: state];
    }
    return self;
}
-(void) addClassState:(CustomState*)stateClass withVariables:(id<ORIntVarArray>)variables {
    [_states addObject:stateClass];
    [_stateVars addObject:variables];
}
-(CustomState*) firstState { return [_states firstObject]; }
-(int) numStates { return (int)[_states count]; }
-(NSMutableArray*) stateVars { return _stateVars; }
-(NSMutableSet**) statesForVariables { return _statesForVariables; }
-(id<ORIntVarArray>) vars { return _vars; }
-(void) setVariables:(id<ORIntVarArray>)variables {
    _vars = variables;
    _statesForVariables = malloc([_vars count] * sizeof(NSMutableSet*));
     _statesForVariables -= [_vars low];
    for (int varIndex = [_vars low]; varIndex <= [_vars up]; varIndex++) {
        NSMutableSet* stateSet = [[NSMutableSet alloc] init];
        for (int stateVarsIndex = 0; stateVarsIndex < [_stateVars count]; stateVarsIndex++) {
            if ([_stateVars[stateVarsIndex] contains:_vars[varIndex]]) {
                [stateSet addObject:[NSNumber numberWithInt:stateVarsIndex]];
            }
        }
        _statesForVariables[varIndex] = stateSet;
    }
    //for (int stateVarsIndex = 0; stateVarsIndex < [_stateVars count]; stateVarsIndex++) {
    //    id<ORIntVarArray> stateVarList = [_stateVars objectAtIndex:stateVarsIndex];
    //    for (id<ORIntVar> x in stateVarList) {
    //        [_statesForVariables[[x getId]] addObject:[NSNumber numberWithInt:stateVarsIndex]];
    //    }
    //}
}

-(NSMutableArray*) states { return _states; }

-(void) mergeStateWith:(JointState*)other {
    NSMutableArray* otherStates = [other states];
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        CustomState* myState = [_states objectAtIndex:stateIndex];
        CustomState* otherState = [otherStates objectAtIndex:stateIndex];
        [myState mergeStateWith:otherState];
    }
}
-(void) replaceStateWith:(JointState*)other {
    NSMutableArray* otherStates = [other states];
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        CustomState* myState = [_states objectAtIndex:stateIndex];
        CustomState* otherState = [otherStates objectAtIndex:stateIndex];
        [myState replaceStateWith:otherState];
    }
}
-(bool) canChooseValue:(int)value forVariable:(int)variable {
    NSSet* statesForVariable = _statesForVariables[variable];
    for (NSNumber* number in statesForVariable) {
        int stateIndex = [number intValue];
        if (![[_states objectAtIndex:stateIndex] canChooseValue:value forVariable:variable]) {
            return false;
        }
    }
    return true;
}

-(int) stateDifferential:(JointState*)other {
    int differential = 0;
    NSMutableArray* other_states = other->_states;
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        differential += [_states[stateIndex] stateDifferential:other_states[stateIndex]];
    }
    return differential;
}
-(bool) equivalentTo:(JointState*)other {
    NSMutableArray* other_states = other->_states;
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if (![_states[stateIndex] equivalentTo:other_states[stateIndex]]) {
            return false;
        }
    }
    return true;
}

NSUInteger ipow(NSUInteger base,NSUInteger p) {
    if (p==0)
        return 1;
    else {
        NSUInteger r = ipow(base,p>>1);
        return r * r * (p & 1 ? base : 1);
    }
}

-(NSUInteger) hashWithWidth:(int)mddWidth numVariables:(NSUInteger)numVariables {
    NSUInteger hashValue = 0;
    int numStateProperties = 0;
    for(id state in _states) {
        hashValue = hashValue + ipow(numVariables,numStateProperties) * [state hashWithWidth:mddWidth numVariables:numVariables];
        numStateProperties += 1;
    }
    return (hashValue % (mddWidth * 2));
}
@end
*/
