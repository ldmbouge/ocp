

#import "ORCustomMDDStates.h"

const short BytesPerMagic = 4;

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

@implementation MDDStateSpecification
-(id) initMDDStateSpecification:(int)numSpecs numTopDownProperties:(int)numTopDownProperties numBottomUpProperties:(int)numBottomUpProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars {
    self = [super init];
    _vars = vars;
    _minVar = [vars low];
    _numVars = (int)[vars count];
    _relaxed = relaxed;
    _topDownStateDescriptor = [[MDDStateDescriptor alloc] initMDDStateDescriptor: numTopDownProperties];
    _bottomUpStateDescriptor = [[MDDStateDescriptor alloc] initMDDStateDescriptor: numBottomUpProperties];
    _topDownTransitionFunctions = calloc(numTopDownProperties, sizeof(DDArcClosure));
    _bottomUpTransitionFunctions = calloc(numBottomUpProperties, sizeof(DDArcClosure));
    if (_relaxed) {
        _topDownRelaxationFunctions = calloc(numTopDownProperties, sizeof(DDMergeClosure));
        _bottomUpRelaxationFunctions = calloc(numBottomUpProperties, sizeof(DDMergeClosure));
        _differentialFunctions = calloc(numTopDownProperties, sizeof(DDMergeClosure));
    }
    _numTopDownPropertiesAdded = 0;
    _numBottomUpPropertiesAdded = 0;
    _numSpecsAdded = 0;
    _topDownPropertiesUsedPerVariable = malloc([vars count] * sizeof(bool*));
    _bottomUpPropertiesUsedPerVariable = malloc([vars count] * sizeof(bool*));
    for (int i = 0; i < _numVars; i++) {
        _topDownPropertiesUsedPerVariable[i] = calloc(numTopDownProperties, sizeof(bool));
        _bottomUpPropertiesUsedPerVariable[i] = calloc(numBottomUpProperties, sizeof(bool));
    }
    _topDownPropertiesUsedPerVariable -= _minVar;
    _bottomUpPropertiesUsedPerVariable -= _minVar;
    
    _topDownArcExistsListsForVariable = calloc(_numVars, sizeof(DDArcClosure*));
    _bottomUpArcExistsListsForVariable = calloc(_numVars, sizeof(DDArcClosure*));
    for (int i = 0; i < _numVars; i++) {
        _topDownArcExistsListsForVariable[i] = malloc(numSpecs * sizeof(DDArcClosure));
        _bottomUpArcExistsListsForVariable[i] = malloc(numSpecs * sizeof(DDArcClosure));
    }
    _topDownArcExistsListsForVariable -= _minVar;
    _bottomUpArcExistsListsForVariable -= _minVar;
    _numTopDownArcExistsForVariable = calloc(_numVars, sizeof(int));
    _numTopDownArcExistsForVariable -= _minVar;
    _numBottomUpArcExistsForVariable = calloc(_numVars, sizeof(int));
    _numBottomUpArcExistsForVariable -= _minVar;
    _dualDirectional = false;
    
    _slackClosures = malloc(numSpecs * sizeof(DDSlackClosure));
    
    singleState = false;
    return self;
}
-(id) initMDDStateSpecification:(ORMDDSpecs*)MDDSpec relaxed:(bool)relaxed {
    self = [super init];
    _vars = [MDDSpec vars];
    _minVar = [_vars low];
    _numVars = (int)[_vars count];
    _relaxed = relaxed;
    _dualDirectional = [MDDSpec dualDirectional];
    _numTopDownPropertiesAdded = [MDDSpec numTopDownProperties];
    _numTopDownPropertiesAdded = [MDDSpec numBottomUpProperties];
    _topDownArcExists = [MDDSpec topDownArcExistsClosure];
    _bottomUpArcExists = [MDDSpec bottomUpArcExistsClosure];
    _topDownTransitionFunctions = calloc(_numTopDownPropertiesAdded, sizeof(DDArcClosure));
    _bottomUpTransitionFunctions = calloc(_numBottomUpPropertiesAdded, sizeof(DDArcClosure));
    DDArcClosure* topDownTransitionClosures = [MDDSpec topDownTransitionClosures];
    DDArcClosure* bottomUpTransitionClosures = [MDDSpec bottomUpTransitionClosures];
    _topDownStateDescriptor = [[MDDStateDescriptor alloc] initMDDStateDescriptor: _numTopDownPropertiesAdded];
    _bottomUpStateDescriptor = [[MDDStateDescriptor alloc] initMDDStateDescriptor: _numBottomUpPropertiesAdded];
    MDDPropertyDescriptor** topDownProperties = [MDDSpec topDownStateProperties];
    MDDPropertyDescriptor** bottomUpProperties = [MDDSpec bottomUpStateProperties];
    for (int i = 0; i < _numTopDownPropertiesAdded; i++) {
        [_topDownStateDescriptor addStateProperty: topDownProperties[i]];
        _topDownTransitionFunctions[i] = topDownTransitionClosures[i];
    }
    for (int i = 0; i < _numBottomUpPropertiesAdded; i++) {
        [_bottomUpStateDescriptor addStateProperty: bottomUpProperties[i]];
        _bottomUpTransitionFunctions[i] = bottomUpTransitionClosures[i];
    }
    if (_relaxed) {
        _topDownRelaxationFunctions = calloc(_numTopDownPropertiesAdded, sizeof(DDMergeClosure));
        _bottomUpRelaxationFunctions = calloc(_numBottomUpPropertiesAdded, sizeof(DDMergeClosure));
        _differentialFunctions = calloc(_numTopDownPropertiesAdded, sizeof(DDMergeClosure));
        DDMergeClosure* topDownRelaxationClosures = [MDDSpec topDownRelaxationClosures];
        DDMergeClosure* bottomUpRelaxationClosures = [MDDSpec bottomUpRelaxationClosures];
        DDMergeClosure* differentialClosures = [MDDSpec differentialClosures];
        for (int i = 0; i < _numTopDownPropertiesAdded; i++) {
            _topDownRelaxationFunctions[i] = topDownRelaxationClosures[i];
            _differentialFunctions[i] = differentialClosures[i];
        }
        for (int i = 0; i < _numBottomUpPropertiesAdded; i++) {
            _bottomUpRelaxationFunctions[i] = bottomUpRelaxationClosures[i];
            _differentialFunctions[i] = differentialClosures[i];
        }
    }
    _numSpecsAdded = 1;
    
    _slackClosures = malloc(sizeof(DDSlackClosure));
    _slackClosures[0] = [MDDSpec slackClosure];
    
    singleState = true;
    return self;
}
-(void) dealloc {
    if (!singleState) {
        _topDownPropertiesUsedPerVariable += _minVar;
        _bottomUpPropertiesUsedPerVariable += _minVar;
        _topDownArcExistsListsForVariable += _minVar;
        _bottomUpArcExistsListsForVariable += _minVar;
        for (int i = 0; i < _numVars; i++) {
            free(_topDownPropertiesUsedPerVariable[i]);
            free(_bottomUpPropertiesUsedPerVariable[i]);
            free(_topDownArcExistsListsForVariable[i]);
            free(_bottomUpArcExistsListsForVariable[i]);
        }
        _numTopDownArcExistsForVariable += _minVar;
        free(_numTopDownArcExistsForVariable);
        _numBottomUpArcExistsForVariable += _minVar;
        free(_numBottomUpArcExistsForVariable);
        [_topDownStateDescriptor release];
        [_bottomUpStateDescriptor release];
    }
    free(_topDownTransitionFunctions);
    free(_bottomUpTransitionFunctions);
    if (_relaxed) {
        free(_topDownRelaxationFunctions);
        free(_bottomUpRelaxationFunctions);
        free(_differentialFunctions);
    }
    free(_slackClosures);
    [super dealloc];
}

-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDArcClosure)arcExists transitionFunctions:(DDArcClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping {
    for (int i = 0; i < numProperties; i++) {
        [_topDownStateDescriptor addStateProperty:stateProperties[i]];
        _topDownTransitionFunctions[_numTopDownPropertiesAdded] = transitionFunctions[i];
        for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
            _topDownPropertiesUsedPerVariable[mapping[varIndex]][_numTopDownPropertiesAdded] = true;
        }
        _numTopDownPropertiesAdded++;
    }
    if (!_numSpecsAdded) {
        _topDownArcExists = arcExists;
    }
    for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
        int mappedVarIndex = mapping[varIndex];
        _topDownArcExistsListsForVariable[mappedVarIndex][_numTopDownArcExistsForVariable[mappedVarIndex]] = arcExists;
        _numTopDownArcExistsForVariable[mappedVarIndex] += 1;
    }
    _numSpecsAdded++;
}
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDArcClosure)arcExists transitionFunctions:(DDArcClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping {
    for (int i = 0; i < numProperties; i++) {
        [_topDownStateDescriptor addStateProperty:stateProperties[i]];
        _topDownTransitionFunctions[_numTopDownPropertiesAdded] = transitionFunctions[i];
        _topDownRelaxationFunctions[_numTopDownPropertiesAdded] = relaxationFunctions[i];
        _differentialFunctions[_numTopDownPropertiesAdded] = differentialFunctions[i];
        for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
            _topDownPropertiesUsedPerVariable[mapping[varIndex]][_numTopDownPropertiesAdded] = true;
        }
        _numTopDownPropertiesAdded++;
    }
    if (!_numSpecsAdded) {
        _topDownArcExists = arcExists;
    }
    for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
        int mappedVarIndex = mapping[varIndex]; _topDownArcExistsListsForVariable[mappedVarIndex][_numTopDownArcExistsForVariable[mappedVarIndex]] = arcExists;
        _numTopDownArcExistsForVariable[mappedVarIndex] += 1;
    }
    _numSpecsAdded++;
}
-(void) addMDDSpec:(ORMDDSpecs*)MDDSpec mapping:(int*)mapping {
    MDDPropertyDescriptor** topDownProperties = [MDDSpec topDownStateProperties];
    MDDPropertyDescriptor** bottomUpProperties = [MDDSpec bottomUpStateProperties];
    DDArcClosure* newTopDownTransitionClosures = [MDDSpec topDownTransitionClosures];
    DDArcClosure* newBottomUpTransitionClosures = [MDDSpec bottomUpTransitionClosures];
    DDMergeClosure* newTopDownRelaxationClosures = [MDDSpec topDownRelaxationClosures];
    DDMergeClosure* newBottomUpRelaxationClosures = [MDDSpec bottomUpRelaxationClosures];
    DDMergeClosure* newDifferentialClosures = [MDDSpec differentialClosures];
    _dualDirectional |= [MDDSpec dualDirectional];
    int numNewTopDownProperties = [MDDSpec numTopDownProperties];
    int numNewBottomUpProperties = [MDDSpec numBottomUpProperties];
    id<ORIntVarArray> otherVars = [MDDSpec vars];
    for (int i = 0; i < numNewTopDownProperties; i++) {
        [_topDownStateDescriptor addStateProperty:topDownProperties[i]];
        _topDownTransitionFunctions[_numTopDownPropertiesAdded] = newTopDownTransitionClosures[i];
        if (_relaxed) {
            _topDownRelaxationFunctions[_numTopDownPropertiesAdded] = newTopDownRelaxationClosures[i];
            _differentialFunctions[_numTopDownPropertiesAdded] = newDifferentialClosures[i];
        }
        for (int varIndex = [otherVars low]; varIndex <= [otherVars up]; varIndex++) {
            _topDownPropertiesUsedPerVariable[mapping[varIndex]][_numTopDownPropertiesAdded] = true;
        }
        _numTopDownPropertiesAdded++;
    }
    for (int i = 0; i < numNewBottomUpProperties; i++) {
        [_bottomUpStateDescriptor addStateProperty:bottomUpProperties[i]];
        _bottomUpTransitionFunctions[_numBottomUpPropertiesAdded] = newBottomUpTransitionClosures[i];
        if (_relaxed) {
            _bottomUpRelaxationFunctions[_numBottomUpPropertiesAdded] = newBottomUpRelaxationClosures[i];
        }
        for (int varIndex = [otherVars low]; varIndex <= [otherVars up]; varIndex++) {
            _bottomUpPropertiesUsedPerVariable[mapping[varIndex]][_numBottomUpPropertiesAdded] = true;
        }
        _numBottomUpPropertiesAdded++;
    }
    DDArcClosure newTopDownArcExistsClosure = [MDDSpec topDownArcExistsClosure];
    DDArcClosure newBottomUpArcExistsClosure = [MDDSpec bottomUpArcExistsClosure];
    if (!_numSpecsAdded) {
        _topDownArcExists = newTopDownArcExistsClosure;
        _bottomUpArcExists = newBottomUpArcExistsClosure;
    }
    for (int varIndex = [otherVars low]; varIndex <= [otherVars up]; varIndex++) {
        int mappedVarIndex = mapping[varIndex];
        _topDownArcExistsListsForVariable[mappedVarIndex][_numTopDownArcExistsForVariable[mappedVarIndex]] = newTopDownArcExistsClosure;
        _numTopDownArcExistsForVariable[mappedVarIndex] += 1;
        if (newBottomUpArcExistsClosure != nil) {
            _bottomUpArcExistsListsForVariable[mappedVarIndex][_numBottomUpArcExistsForVariable[mappedVarIndex]] = newBottomUpArcExistsClosure;
            _numBottomUpArcExistsForVariable[mappedVarIndex] += 1;
        }
    }
    
    _slackClosures[_numSpecsAdded] = [MDDSpec slackClosure];
    
    _numSpecsAdded++;
}
-(MDDStateValues*) createRootState {
    char* defaultProperties = malloc(_topDownNumBytes * sizeof(char));
    [_topDownStateDescriptor initializeState:defaultProperties];
    return [[MDDStateValues alloc] initState:defaultProperties numBytes:_topDownNumBytes hashWidth:_hashWidth trail:_trail];
}
-(MDDStateValues*) createSinkState {
    char* defaultProperties = malloc(_bottomUpNumBytes * sizeof(char));
    [_bottomUpStateDescriptor initializeState:defaultProperties];
    return [[MDDStateValues alloc] initState:defaultProperties numBytes:_bottomUpNumBytes hashWidth:_hashWidth trail:_trail];
}
-(char*) computeTopDownStateFromProperties:(char*)parentState assigningVariable:(int)variable withValue:(int)value {
    char* newState = malloc(_topDownNumBytes * sizeof(char));
    memcpy(newState, parentState, _topDownNumBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
            _topDownTransitionFunctions[propertyIndex](newState, parentState, variable, value);
        }
        return newState;
    }
    bool* propertyUsed = _topDownPropertiesUsedPerVariable[variable];
    for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
        if (propertyUsed[propertyIndex]) {
            _topDownTransitionFunctions[propertyIndex](newState, parentState, variable, value);
        }
    }
    return newState;
}
-(char*) computeBottomUpStateFromProperties:(char*)childState assigningVariable:(int)variable withValue:(int)value {
    char* newState = malloc(_bottomUpNumBytes * sizeof(char));
    memcpy(newState, childState, _bottomUpNumBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numBottomUpPropertiesAdded; propertyIndex++) {
            _bottomUpTransitionFunctions[propertyIndex](newState, childState, variable, value);
        }
        return newState;
    }
    bool* propertyUsed = _bottomUpPropertiesUsedPerVariable[variable];
    for (int propertyIndex = 0; propertyIndex < _numBottomUpPropertiesAdded; propertyIndex++) {
        if (propertyUsed[propertyIndex]) {
            _bottomUpTransitionFunctions[propertyIndex](newState, childState, variable, value);
        }
    }
    return newState;
}
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right {
    char* leftState = left.stateValues;
    char* rightState = right.stateValues;
    char* newState = malloc(_topDownNumBytes * sizeof(char));
    for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
        _topDownRelaxationFunctions[propertyIndex](newState, leftState, rightState);
    }
    [left replaceStateWith:newState trail:_trail];
    free(newState);
    //[left recalcHash:_hashWidth trail:_trail];
}
-(void) mergeTempStateProperties:(char*)leftState with:(char*)rightState {
    char* newState = malloc(_topDownNumBytes * sizeof(char));
    for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
        _topDownRelaxationFunctions[propertyIndex](newState, leftState, rightState);
    }
    memcpy(leftState, newState, _topDownNumBytes);
    free(newState);
}
-(void) mergeTempBottomUpStateProperties:(char*)leftState with:(char*)rightState {
    char* newState = malloc(_bottomUpNumBytes * sizeof(char));
    for (int propertyIndex = 0; propertyIndex < _numBottomUpPropertiesAdded; propertyIndex++) {
        _bottomUpRelaxationFunctions[propertyIndex](newState, leftState, rightState);
    }
    memcpy(leftState, newState, _bottomUpNumBytes);
    free(newState);
}
typedef void (*SetPropIMP)(id,SEL,int,char*);
typedef int (*GetPropIMP)(id,SEL,char*);
-(char*) batchMergeForStates:(char**)parentStates values:(int**)edgesUsedByParent numEdgesPerParent:(int*)numEdgesPerParent variable:(int)variableIndex isMerged:(bool*)isMerged numParents:(int)numParents totalEdges:(int)totalEdges {
    char** computedStates = malloc(totalEdges * sizeof(char*));
    for (int i = 0; i < totalEdges; i++) {
        computedStates[i] = malloc(_topDownNumBytes * sizeof(char));
    }
    int numEdgesAdded;
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
            numEdgesAdded = 0;
            DDArcClosure transitionFunction = _topDownTransitionFunctions[propertyIndex];
            for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
                char* parentState = parentStates[parentIndex];
                int* edgesUsed = edgesUsedByParent[parentIndex];
                int numEdges = numEdgesPerParent[parentIndex];
                for (int valueIndex = 0; valueIndex < numEdges; valueIndex++) {
                    transitionFunction(computedStates[numEdgesAdded++], parentState, variableIndex, edgesUsed[valueIndex]);
                }
            }
        }
        for (int i = 0; i < totalEdges-1; i++) {
            char* state1 = computedStates[i];
            for (int j = i+1; j < totalEdges; j++) {
                if (memcmp(state1, computedStates[j], _topDownNumBytes) != 0) {
                    *isMerged = true;
                    break;
                }
            }
            if (*isMerged) {
                break;
            }
        }
        char* mergedState = malloc(_topDownNumBytes * sizeof(char));
        memcpy(mergedState, computedStates[0], _topDownNumBytes);
        
        if (*isMerged) {
            for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
                for (int edgeIndex = 1; edgeIndex < totalEdges; edgeIndex++) {
                    _topDownRelaxationFunctions[propertyIndex](mergedState, mergedState, computedStates[edgeIndex]);
                }
            }
        }
        for (int i = 0; i < totalEdges; i++) {
            free(computedStates[i]);
        }
        return mergedState;
    }
    int counter = 0;
    for (int i = 0; i < numParents; i++) {
        for (int j = 0; j < numEdgesPerParent[i]; j++) {
            memcpy(computedStates[counter++], parentStates[i], _topDownNumBytes);
        }
    }
    bool* propertyUsed = _topDownPropertiesUsedPerVariable[variableIndex];
    for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
        numEdgesAdded = 0;
        if (propertyUsed[propertyIndex]) {
            for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
                char* parentState = parentStates[parentIndex];
                int* edgesUsed = edgesUsedByParent[parentIndex];
                int numEdges = numEdgesPerParent[parentIndex];
                for (int valueIndex = 0; valueIndex < numEdges; valueIndex++) {
                    _topDownTransitionFunctions[propertyIndex](computedStates[numEdgesAdded++], parentState, variableIndex, edgesUsed[valueIndex]);
                }
            }
        }
    }
    for (int i = 0; i < totalEdges-1; i++) {
        char* state1 = computedStates[i];
        for (int j = i+1; j < totalEdges; j++) {
            if (memcmp(state1, computedStates[j], _topDownNumBytes) != 0) {
                *isMerged = true;
                break;
            }
        }
        if (*isMerged) {
            break;
        }
    }
    char* mergedState = malloc(_topDownNumBytes * sizeof(char));
    memcpy(mergedState, computedStates[0], _topDownNumBytes);
    
    if (*isMerged) {
        for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
            for (int edgeIndex = 1; edgeIndex < totalEdges; edgeIndex++) {
                _topDownRelaxationFunctions[propertyIndex](mergedState, mergedState, computedStates[edgeIndex]);
            }
        }
    }
    for (int i = 0; i < totalEdges; i++) {
        free(computedStates[i]);
    }
    return mergedState;
}
-(bool) replaceArcState:(MDDArc*)arc withParentProperties:(char*)parentProperties variable:(int)variable {
    char* arcState = arc.topDownState;
    int value = arc.arcValue;
    bool stateChanged = false;
    char* newState = malloc(_topDownNumBytes * sizeof(char));
    memcpy(newState, arcState, _topDownNumBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
            _topDownTransitionFunctions[propertyIndex](newState, parentProperties, variable, value);
        }
    } else {
        bool* propertyUsed = _topDownPropertiesUsedPerVariable[variable];
        for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                _topDownTransitionFunctions[propertyIndex](newState, parentProperties, variable, value);
            }
        }
    }
    stateChanged = memcmp(arcState, newState, _topDownNumBytes) != 0;
    [arc replaceTopDownStateWith:newState trail:_trail];
    free(newState);
    return stateChanged;
}
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues {
    if (_numSpecsAdded == 1) {
        return _topDownArcExists([stateValues stateValues],nil,variable,value);
    }
    char* state = [stateValues stateValues];
    int numArcExists = _numTopDownArcExistsForVariable[variable];
    DDArcClosure* arcExistsList = _topDownArcExistsListsForVariable[variable];
    for (int i = 0; i < numArcExists; i++) {
        if (!arcExistsList[i](state,nil,variable,value)) {
            return false;
        }
    }
    return true;
}
-(bool) canChooseValue:(int)value forVariable:(int)variable withStateProperties:(char*)state {
    if (_numSpecsAdded == 1) {
        return _topDownArcExists(state,nil,variable,value);
    }
    int numArcExists = _numTopDownArcExistsForVariable[variable];
    DDArcClosure* arcExistsList = _topDownArcExistsListsForVariable[variable];
    for (int i = 0; i < numArcExists; i++) {
        if (!arcExistsList[i](state,nil,variable,value)) {
            return false;
        }
    }
    return true;
}
-(bool) canChooseValue:(int)value forVariable:(int)variable fromParent:(char*)parentState toChild:(char*)childState {
    if (_dualDirectional) {
        if (_numSpecsAdded == 1) {
            if (!_bottomUpArcExists(parentState,childState,variable,value)) {
                return false;
            }
        } else {
            int numArcExists = _numBottomUpArcExistsForVariable[variable];
            DDArcClosure* arcExistsList = _bottomUpArcExistsListsForVariable[variable];
            for (int i = 0; i < numArcExists; i++) {
                if (!arcExistsList[i](parentState,childState,variable,value)) {
                    return false;
                }
            }
        }
    }
    if (_numSpecsAdded == 1) {
        return _topDownArcExists(parentState,childState,variable,value);
    }
    int numArcExists = _numTopDownArcExistsForVariable[variable];
    DDArcClosure* arcExistsList = _topDownArcExistsListsForVariable[variable];
    for (int i = 0; i < numArcExists; i++) {
        if (!arcExistsList[i](parentState,childState,variable,value)) {
            return false;
        }
    }
    return true;
}
-(bool) canCreateState:(char**)newStateProperties fromParent:(MDDStateValues*)parentState assigningVariable:(int)variable toValue:(int)value {
    char* parState = [parentState stateValues];
    
    if (_numSpecsAdded == 1) {
        if (!_topDownArcExists(parState,nil,variable,value)) {
            return false;
        }
    } else {
        int numArcExists = _numTopDownArcExistsForVariable[variable];
        DDArcClosure* arcExistsList = _topDownArcExistsListsForVariable[variable];
        for (int i = 0; i < numArcExists; i++) {
            if (!arcExistsList[i](parState,nil,variable,value)) {
                return false;
            }
        }
    }
    
    *newStateProperties = malloc(_topDownNumBytes * sizeof(char));
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
            _topDownTransitionFunctions[propertyIndex](*newStateProperties, parState, variable, value);
        }
    } else {
        memcpy(*newStateProperties, parState, _topDownNumBytes);
        bool* propertyUsed = _topDownPropertiesUsedPerVariable[variable];
        for (int propertyIndex = 0; propertyIndex < _numTopDownPropertiesAdded; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                _topDownTransitionFunctions[propertyIndex](*newStateProperties, parState, variable, value);
            }
        }
    }
    return true;
}
-(long) slack:(char*)stateProperties {
    long slackValue = _slackClosures[0](stateProperties);
    for (int i = 1; i < _numSpecsAdded; i++) {
        //What should this shear be?  Max slack value???
        slackValue = slackValue * 205 + _slackClosures[i](stateProperties);
    }
    return slackValue;
}
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right {
    int differential = 0;
    char* leftState = left.stateValues;
    char* rightState = right.stateValues;
    for (int stateIndex = 0; stateIndex < _numTopDownPropertiesAdded; stateIndex++) {
        DDMergeClosure differentialFunction = _differentialFunctions[stateIndex];
        if (differentialFunction != nil) {
            differential += (int)differentialFunction(nil, leftState,rightState);
         }
    }
    return differential;
}
-(int) numTopDownProperties { return _numTopDownPropertiesAdded; }
-(int) numBottomUpProperties { return _numBottomUpPropertiesAdded; }
-(size_t) numTopDownBytes { return _topDownNumBytes; }
-(size_t) numBottomUpBytes { return _bottomUpNumBytes; }
-(int) numSpecs { return _numSpecsAdded; }
-(id<ORIntVarArray>) vars { return _vars; }
-(MDDStateDescriptor*) stateDescriptor { return _topDownStateDescriptor; }
-(bool*) topDownPropertiesUsed:(int)variableIndex { return _topDownPropertiesUsedPerVariable[variableIndex]; }
-(bool*) bottomUpPropertiesUsed:(int)variableIndex { return _bottomUpPropertiesUsedPerVariable[variableIndex]; }
-(DDArcClosure*) topDownTransitionFunctions { return _topDownTransitionFunctions; }
-(DDArcClosure*) bottomUpTransitionFunctions { return _bottomUpTransitionFunctions; }
-(void) finalizeSpec:(id<ORTrail>) trail hashWidth:(int)width {
    _trail = trail;
    _hashWidth = width;
    _topDownNumBytes = [_topDownStateDescriptor numBytes];
    _bottomUpNumBytes = [_bottomUpStateDescriptor numBytes];
    short extraBytes = _topDownNumBytes % BytesPerMagic;
    if (extraBytes) {
        _topDownNumBytes = _topDownNumBytes - extraBytes + BytesPerMagic;
    }
    extraBytes = _bottomUpNumBytes % BytesPerMagic;
    if (extraBytes) {
        _bottomUpNumBytes = _bottomUpNumBytes - extraBytes + BytesPerMagic;
    }
    _topDownProperties = [_topDownStateDescriptor properties];
    _bottomUpProperties = [_bottomUpStateDescriptor properties];
}
-(NSUInteger) hashValueFor:(char*)stateProperties {
    //TODO: The following is currently in two places which isn't good practice.  Look into how MDDStateValues can use this function.
    const size_t numGroups = _topDownNumBytes/BytesPerMagic;
    int hashValue = 0;
    switch (BytesPerMagic) {
        case 2:
            for (size_t s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&stateProperties[s*BytesPerMagic];
            }
            break;
        case 4:
            for (size_t s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&stateProperties[s*BytesPerMagic];
            }
            break;
        default:
            @throw [[ORExecutionError alloc] initORExecutionError: "MDDStateValues: Method calcHash not implemented for given BytesPerMagic"];
            break;
    }
    hashValue = hashValue % _hashWidth;
    if (hashValue < 0) hashValue += _hashWidth;
    return hashValue;
}
-(int) hashWidth { return _hashWidth; }
@end

@implementation MDDStateValues
-(id) initState:(char*)stateValues numBytes:(size_t)numBytes {
    self = [super init];
    _numBytes = numBytes;
    _state = stateValues;
    _tempState = true;
    return self;
}
-(id) initState:(char*)stateValues numBytes:(size_t)numBytes hashWidth:(int)width trail:(id<ORTrail>)trail {
    self = [super init];
    _numBytes = numBytes;
    _state = stateValues;
    [self setHash:width trail:trail];
    _magic = malloc(_numBytes/BytesPerMagic * sizeof(ORUInt));
    for (int i = 0; i < (_numBytes/BytesPerMagic); i++) {
        _magic[i] = [trail magic];
    }
    _tempState = false;
    return self;
}
-(void) dealloc {
    free(_state);
    if (!_tempState) {
        free(_magic);
    }
    [super dealloc];
}
-(void) replaceStateWith:(char *)newState trail:(id<ORTrail>)trail {
    ORUInt magic = [trail magic];
    for (int byteIndex = 0; byteIndex < _numBytes; byteIndex+=BytesPerMagic) {
        size_t magicIndex = byteIndex/BytesPerMagic;
        switch (BytesPerMagic) {
            case 2:
                if (*(short*)&_state[byteIndex] != *(short*)&newState[byteIndex]) {
                    if (magic != _magic[magicIndex]) {
                        [trail trailShort:(short*)&_state[byteIndex]];
                        _magic[magicIndex] = magic;
                    }
                    *(short*)&_state[byteIndex] = *(short*)&newState[byteIndex];
                }
                break;
            case 4:
                if (*(int*)&_state[byteIndex] != *(int*)&newState[byteIndex]) {
                    if (magic != _magic[magicIndex]) {
                        [trail trailInt:(int*)&_state[byteIndex]];
                        _magic[magicIndex] = magic;
                    }
                    *(int*)&_state[byteIndex] = *(int*)&newState[byteIndex];
                }
                break;
            default:
                @throw [[ORExecutionError alloc] initORExecutionError: "MDDStateValues: Method replaceStateWith not implemented for given BytesPerMagic"];
                break;
        }
    }
}
-(char*) stateValues { return _state; }
-(NSUInteger) hash { return _hashValue._val; }
-(int) calcHash:(int)width {
    const size_t numGroups = _numBytes/BytesPerMagic;
    int hashValue = 0;
    switch (BytesPerMagic) {
        case 2:
            for (size_t s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&_state[s*BytesPerMagic];
            }
            break;
        case 4:
            for (size_t s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&_state[s*BytesPerMagic];
            }
            break;
        default:
            @throw [[ORExecutionError alloc] initORExecutionError: "MDDStateValues: Method calcHash not implemented for given BytesPerMagic"];
            break;
    }
    hashValue = hashValue % width;
    if (hashValue < 0) hashValue += width;
    return hashValue;
}
-(void) setHash:(int)width trail:(id<ORTrail>)trail {
    _hashValue = makeTRInt(trail, [self calcHash:width]);
}
-(void) recalcHash:(int)width trail:(id<ORTrail>)trail {
    if (!_tempState) {
        assignTRInt(&_hashValue, [self calcHash:width], trail);
    }
}
-(void) setNode:(Node*)node { _node = node; }
-(Node*) node { return _node; }
@end
