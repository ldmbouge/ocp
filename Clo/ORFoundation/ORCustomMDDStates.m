#import <ORFoundation/ORCustomMDDStates.h>

const short BytesPerMagic = 4;

@implementation MDDStateSpecification {
@protected
    MDDPropertyDescriptor** _forwardProperties;
    MDDPropertyDescriptor** _reverseProperties;
    MDDPropertyDescriptor** _combinedProperties;
    DDArcSetTransitionClosure* _forwardTransitionFunctions;
    DDArcSetTransitionClosure* _reverseTransitionFunctions;
    DDMergeClosure* _forwardRelaxationFunctions;
    DDMergeClosure* _reverseRelaxationFunctions;
    DDUpdatePropertyClosure* _updatePropertyFunctions;
    
    DDArcExistsClosure* _arcExistFunctions;
    int** _arcExistFunctionIndicesForVariable;
    DDStateExistsClosure* _stateExistFunctions;
    
    id<ORIntVar>* _fixpointVars;
    DDFixpointBoundClosure* _fixpointMins;
    DDFixpointBoundClosure* _fixpointMaxes;
    
    DDNodeSplitValueClosure* _nodeSplitValueFunctions;
    DDCandidateSplitValueClosure* _candidateSplitValueFunctions;
    
    DDStateEquivalenceClassClosure* _approximateEquivalenceFunctions;
    
    int** _forwardPropertyImpact;
    int* _forwardPropertyImpactCount;
    int** _reversePropertyImpact;
    int* _reversePropertyImpactCount;
    
    
    
    char**** _mergeCacheLeft;
    char**** _mergeCacheRight;
    char**** _mergeCacheResult;
    int** _mergeCacheNumPerHash;
    int** _mergeCacheMaxPerHash;
    
    char**** _reverseMergeCacheLeft;
    char**** _reverseMergeCacheRight;
    char**** _reverseMergeCacheResult;
    int** _reverseMergeCacheNumPerHash;
    int** _reverseMergeCacheMaxPerHash;
    
    char*** _forwardTransitionCacheForward;
    char**** _forwardTransitionCacheResult;
    int* _forwardTransitionCacheNumPerHash;
    int* _forwardTransitionCacheMaxPerHash;
    
    int* _constraintPriorities;
    int _minConstraintPriority, _maxConstraintPriority;
    bool _singlePriority;
    int** _specsByPriority;
    int* _numSpecsByPriority;
    int* _maxSpecsByPriority;
}
-(id) initMDDStateSpecification:(int)numSpecs numForwardProperties:(int)numForwardProperties numReverseProperties:(int)numReverseProperties numCombinedProperties:(int)numCombinedProperties vars:(id<ORIntVarArray>)vars {
    self = [super init];
    _vars = vars;
    _minVar = [vars low];
    _maxVar = [vars up];
    _numVars = (int)[vars count];
    _minDom = [[vars at:_minVar] min];
    _maxDom = [[vars at:_maxVar] max];
    for (int i = _minVar+1; i <= _maxVar; i++) {
        int min = [[vars at:i] min];
        int max = [[vars at:i] max];
        if (_minDom > min) {
            _minDom = min;
        }
        if (_maxDom < max) {
            _maxDom = max;
        }
    }
    _domSize = _maxDom - _minDom + 1;
    _forwardStateDescriptor = [[MDDStateDescriptor alloc] initMDDStateDescriptor: numForwardProperties];
    _reverseStateDescriptor = [[MDDStateDescriptor alloc] initMDDStateDescriptor: numReverseProperties];
    _combinedStateDescriptor = [[MDDStateDescriptor alloc] initMDDStateDescriptor: numCombinedProperties];
    _forwardTransitionFunctions = malloc(numForwardProperties * sizeof(DDArcSetTransitionClosure));
    _forwardPropertyImpact = malloc(numForwardProperties * sizeof(int*));
    _forwardPropertyImpactCount = calloc(numForwardProperties, sizeof(int));
    _reverseTransitionFunctions = malloc(numReverseProperties * sizeof(DDArcSetTransitionClosure));
    _reversePropertyImpact = malloc(numReverseProperties * sizeof(int*));
    _reversePropertyImpactCount = calloc(numReverseProperties, sizeof(int));
    _forwardRelaxationFunctions = malloc(numForwardProperties * sizeof(DDMergeClosure));
    _reverseRelaxationFunctions = malloc(numReverseProperties * sizeof(DDMergeClosure));
    _updatePropertyFunctions = malloc(numCombinedProperties * sizeof(DDUpdatePropertyClosure));
    _numForwardPropertiesAdded = 0;
    _numReversePropertiesAdded = 0;
    _numSpecsAdded = 0;
    _forwardPropertiesUsedPerVariable = malloc([vars count] * sizeof(bool*));
    _reversePropertiesUsedPerVariable = malloc([vars count] * sizeof(bool*));
    for (int i = 0; i < _numVars; i++) {
        _forwardPropertiesUsedPerVariable[i] = calloc(numForwardProperties, sizeof(bool));
        _reversePropertiesUsedPerVariable[i] = calloc(numReverseProperties, sizeof(bool));
    }
    _forwardPropertiesUsedPerVariable -= _minVar;
    _reversePropertiesUsedPerVariable -= _minVar;
    
    _forwardPropertiesUsedPerSpec = malloc(numSpecs * sizeof(bool*));
    for (int i = 0; i < numSpecs; i++) {
        _forwardPropertiesUsedPerSpec[i] = calloc(numForwardProperties, sizeof(bool));
    }
    _reversePropertiesUsedPerSpec = malloc(numSpecs * sizeof(bool*));
    for (int i = 0; i < numSpecs; i++) {
        _reversePropertiesUsedPerSpec[i] = calloc(numReverseProperties, sizeof(bool));
    }
    
    _arcExistFunctionIndicesForVariable = calloc(_numVars, sizeof(int*));
    for (int i = 0; i < _numVars; i++) {
        _arcExistFunctionIndicesForVariable[i] = malloc(numSpecs * sizeof(int));
    }
    _arcExistFunctionIndicesForVariable -= _minVar;
    _arcExistFunctions = malloc(numSpecs * sizeof(DDArcExistsClosure));
    _stateExistFunctions = malloc(numSpecs * sizeof(DDStateExistsClosure));
    _numArcExistsForVariable = calloc(_numVars, sizeof(int));
    _numArcExistsForVariable -= _minVar;
    _dualDirectional = false;
    
    _fixpointVars = malloc(numSpecs * sizeof(id<ORIntVar>));
    _fixpointMins = malloc(numSpecs * sizeof(DDFixpointBoundClosure));
    _fixpointMaxes = malloc(numSpecs * sizeof(DDFixpointBoundClosure));
    
    _nodeSplitValueFunctions = malloc(numSpecs * sizeof(DDNodeSplitValueClosure));
    _candidateSplitValueFunctions = malloc(numSpecs * sizeof(DDCandidateSplitValueClosure));
    
    _approximateEquivalenceFunctions = malloc(numSpecs * sizeof(DDStateEquivalenceClassClosure));
    
    _constraintPriorities = malloc(numSpecs * sizeof(int));
    _minConstraintPriority = INT_MAX;
    _maxConstraintPriority = INT_MIN;
    
    _cachesUsed = false;
    
    return self;
}
-(void) dealloc {
    _forwardPropertiesUsedPerVariable += _minVar;
    _reversePropertiesUsedPerVariable += _minVar;
    _arcExistFunctionIndicesForVariable += _minVar;
    for (int i = 0; i < _numVars; i++) {
        free(_forwardPropertiesUsedPerVariable[i]);
        free(_reversePropertiesUsedPerVariable[i]);
        free(_arcExistFunctionIndicesForVariable[i]);
    }
    for (int i = 0; i < _numSpecsAdded; i++) {
        free(_forwardPropertiesUsedPerSpec[i]);
        free(_reversePropertiesUsedPerSpec[i]);
    }
    free(_forwardPropertiesUsedPerSpec);
    free(_reversePropertiesUsedPerSpec);
    _numArcExistsForVariable += _minVar;
    free(_numArcExistsForVariable);
    free(_arcExistFunctions);
    free(_stateExistFunctions);
    [_forwardStateDescriptor release];
    [_reverseStateDescriptor release];
    free(_forwardTransitionFunctions);
    for (int i = 0; i < _numForwardPropertiesAdded; i++) {
        if (_forwardPropertyImpactCount[i]) {
            free(_forwardPropertyImpact[i]);
        }
    }
    free(_forwardPropertyImpact);
    free(_forwardPropertyImpactCount);
    free(_reverseTransitionFunctions);
    for (int i = 0; i < _numReversePropertiesAdded; i++) {
        if (_reversePropertyImpactCount[i]) {
            free(_reversePropertyImpact[i]);
        }
    }
    free(_reversePropertyImpact);
    free(_reversePropertyImpactCount);
    free(_forwardRelaxationFunctions);
    free(_reverseRelaxationFunctions);
    free(_fixpointVars);
    free(_fixpointMins);
    free(_fixpointMaxes);
    free(_nodeSplitValueFunctions);
    free(_candidateSplitValueFunctions);
    free(_approximateEquivalenceFunctions);
    
    for (int i = 0; i < _mergeCacheHashWidth; i++) {
        for (int j = 0; j < _mergeCacheHashWidth; j++) {
            if (_mergeCacheMaxPerHash[i][j]) {
                for (int k = 0; k < _mergeCacheNumPerHash[i][j]; k++) {
                    free(_mergeCacheLeft[i][j][k]);
                    free(_mergeCacheRight[i][j][k]);
                    free(_mergeCacheResult[i][j][k]);
                }
                free(_mergeCacheLeft[i][j]);
                free(_mergeCacheRight[i][j]);
                free(_mergeCacheResult[i][j]);
            }
        }
        free(_mergeCacheLeft[i]);
        free(_mergeCacheRight[i]);
        free(_mergeCacheResult[i]);
        free(_mergeCacheMaxPerHash[i]);
        free(_mergeCacheNumPerHash[i]);
    }
    free(_mergeCacheMaxPerHash);
    free(_mergeCacheNumPerHash);
    free(_mergeCacheLeft);
    free(_mergeCacheRight);
    free(_mergeCacheResult);
    
    for (int i = 0; i < _mergeCacheHashWidth; i++) {
        for (int j = 0; j < _mergeCacheHashWidth; j++) {
            if (_reverseMergeCacheMaxPerHash[i][j]) {
                for (int k = 0; k < _reverseMergeCacheNumPerHash[i][j]; k++) {
                    free(_reverseMergeCacheLeft[i][j][k]);
                    free(_reverseMergeCacheRight[i][j][k]);
                    free(_reverseMergeCacheResult[i][j][k]);
                }
                free(_reverseMergeCacheLeft[i][j]);
                free(_reverseMergeCacheRight[i][j]);
                free(_reverseMergeCacheResult[i][j]);
            }
        }
        free(_reverseMergeCacheLeft[i]);
        free(_reverseMergeCacheRight[i]);
        free(_reverseMergeCacheResult[i]);
        free(_reverseMergeCacheMaxPerHash[i]);
        free(_reverseMergeCacheNumPerHash[i]);
    }
    free(_reverseMergeCacheMaxPerHash);
    free(_reverseMergeCacheNumPerHash);
    free(_reverseMergeCacheLeft);
    free(_reverseMergeCacheRight);
    free(_reverseMergeCacheResult);
    
    for (int hashIndex = 0; hashIndex < _transitionCacheHashWidth; hashIndex++) {
        if (_forwardTransitionCacheMaxPerHash[hashIndex]) {
            for (int forwardIndex = 0; forwardIndex < _forwardTransitionCacheNumPerHash[hashIndex]; forwardIndex++) {
                free(_forwardTransitionCacheForward[hashIndex][forwardIndex]);
                _forwardTransitionCacheResult[hashIndex][forwardIndex] += _minDom;
                for (int val = _minDom; val <= _maxDom; val++) {
                    free(_forwardTransitionCacheResult[hashIndex][forwardIndex][val]);
                }
                free(_forwardTransitionCacheResult[hashIndex][forwardIndex]);
            }
            free(_forwardTransitionCacheForward[hashIndex]);
            free(_forwardTransitionCacheResult[hashIndex]);
        }
    }
    free(_forwardTransitionCacheForward);
    free(_forwardTransitionCacheResult);
    free(_forwardTransitionCacheMaxPerHash);
    free(_forwardTransitionCacheNumPerHash);
    
    for (int i = _minConstraintPriority; i <= _maxConstraintPriority; i++) {
        free(_forwardPropertiesUsedPerPriority[i]);
        free(_reversePropertiesUsedPerPriority[i]);
    }
    _forwardPropertiesUsedPerPriority += _minConstraintPriority;
    _reversePropertiesUsedPerPriority += _minConstraintPriority;
    free(_forwardPropertiesUsedPerPriority);
    free(_reversePropertiesUsedPerPriority);
    
    free(_constraintPriorities);
    _specsByPriority += _minConstraintPriority;
    free(_specsByPriority);
    
    [super dealloc];
}

-(void) addMDDSpec:(id<ORMDDSpecs>)MDDSpec mapping:(int*)mapping {
    MDDPropertyDescriptor** forwardProperties = [MDDSpec forwardStateProperties];
    MDDPropertyDescriptor** reverseProperties = [MDDSpec reverseStateProperties];
    MDDPropertyDescriptor** combinedProperties = [MDDSpec combinedStateProperties];
    DDArcSetTransitionClosure* newForwardTransitionClosures = [MDDSpec forwardTransitionClosures];
    DDArcSetTransitionClosure* newReverseTransitionClosures = [MDDSpec reverseTransitionClosures];
    DDMergeClosure* newForwardRelaxationClosures = [MDDSpec forwardRelaxationClosures];
    DDMergeClosure* newReverseRelaxationClosures = [MDDSpec reverseRelaxationClosures];
    DDUpdatePropertyClosure* newUpdatePropertyClosures = [MDDSpec updatePropertyClosures];
    _dualDirectional |= [MDDSpec dualDirectional];
    int numNewForwardProperties = [MDDSpec numForwardProperties];
    int numNewReverseProperties = [MDDSpec numReverseProperties];
    int numNewCombinedProperties = [MDDSpec numCombinedProperties];
    id<ORIntVarArray> otherVars = [MDDSpec vars];
    int** forwardPropertyImpact = [MDDSpec forwardPropertyImpact];
    int* forwardPropertyImpactCount = [MDDSpec forwardPropertyImpactCount];
    int** reversePropertyImpact = [MDDSpec reversePropertyImpact];
    int* reversePropertyImpactCount = [MDDSpec reversePropertyImpactCount];
    for (int i = 0; i < numNewForwardProperties; i++) {
        [_forwardStateDescriptor addStateProperty:forwardProperties[i]];
        _forwardTransitionFunctions[_numForwardPropertiesAdded] = newForwardTransitionClosures[i];
        _forwardPropertyImpactCount[_numForwardPropertiesAdded] = forwardPropertyImpactCount[i];
        _forwardPropertyImpact[_numForwardPropertiesAdded] = malloc(forwardPropertyImpactCount[i] * sizeof(int));
        for (int p = 0; p < forwardPropertyImpactCount[i]; p++) {
            _forwardPropertyImpact[_numForwardPropertiesAdded][p] = (_numForwardPropertiesAdded - i) + forwardPropertyImpact[i][p];
        }
        _forwardRelaxationFunctions[_numForwardPropertiesAdded] = newForwardRelaxationClosures[i];
        for (int varIndex = [otherVars low]; varIndex <= [otherVars up]; varIndex++) {
            _forwardPropertiesUsedPerVariable[mapping[varIndex]][_numForwardPropertiesAdded] = true;
        }
        _forwardPropertiesUsedPerSpec[_numSpecsAdded][_numForwardPropertiesAdded] = true;
        _numForwardPropertiesAdded++;
    }
    for (int i = 0; i < numNewReverseProperties; i++) {
        [_reverseStateDescriptor addStateProperty:reverseProperties[i]];
        _reverseTransitionFunctions[_numReversePropertiesAdded] = newReverseTransitionClosures[i];
        _reversePropertyImpactCount[_numReversePropertiesAdded] = reversePropertyImpactCount[i];
        _reversePropertyImpact[_numReversePropertiesAdded] = malloc(reversePropertyImpactCount[i] * sizeof(int));
        for (int p = 0; p < reversePropertyImpactCount[i]; p++) {
            _reversePropertyImpact[_numReversePropertiesAdded][p] = (_numReversePropertiesAdded - i) + reversePropertyImpact[i][p];
        }
        _reverseRelaxationFunctions[_numReversePropertiesAdded] = newReverseRelaxationClosures[i];
        for (int varIndex = [otherVars low]; varIndex <= [otherVars up]; varIndex++) {
            _reversePropertiesUsedPerVariable[mapping[varIndex]][_numReversePropertiesAdded] = true;
        }
        _reversePropertiesUsedPerSpec[_numSpecsAdded][_numReversePropertiesAdded] = true;
        _numReversePropertiesAdded++;
    }
    for (int i = 0; i < numNewCombinedProperties; i++) {
        [_combinedStateDescriptor addStateProperty:combinedProperties[i]];
        _updatePropertyFunctions[_numCombinedPropertiesAdded] = newUpdatePropertyClosures[i];
        _numCombinedPropertiesAdded++;
    }
    DDArcExistsClosure newArcExistsClosure = [MDDSpec arcExistsClosure];
    DDStateExistsClosure newStateExistsClosure = [MDDSpec stateExistsClosure];
    if (!_numSpecsAdded) {
        _arcExists = newArcExistsClosure;
        _stateExists = newStateExistsClosure;
    }
    for (int varIndex = [otherVars low]; varIndex <= [otherVars up]; varIndex++) {
        int mappedVarIndex = mapping[varIndex];
        _arcExistFunctionIndicesForVariable[mappedVarIndex][_numArcExistsForVariable[mappedVarIndex]] = _numSpecsAdded;
        _numArcExistsForVariable[mappedVarIndex] += 1;
    }
    _arcExistFunctions[_numSpecsAdded] = newArcExistsClosure;
    _stateExistFunctions[_numSpecsAdded] = newStateExistsClosure;
    _fixpointVars[_numSpecsAdded] = [MDDSpec fixpointVar];
    _fixpointMins[_numSpecsAdded] = [MDDSpec fixpointMin];
    _fixpointMaxes[_numSpecsAdded] = [MDDSpec fixpointMax];
    _nodeSplitValueFunctions[_numSpecsAdded] = [MDDSpec nodeSplitValueClosure];
    _candidateSplitValueFunctions[_numSpecsAdded] = [MDDSpec candidateSplitValueClosure];
    _approximateEquivalenceFunctions[_numSpecsAdded] = [MDDSpec approximateEquivalenceClosure];
    
    int constraintPriority = [MDDSpec constraintPriority];
    if (constraintPriority < _minConstraintPriority) {
        _minConstraintPriority = constraintPriority;
    }
    if (constraintPriority > _maxConstraintPriority) {
        _maxConstraintPriority = constraintPriority;
    }
    _constraintPriorities[_numSpecsAdded] = constraintPriority;

    _numSpecsAdded++;
}

-(bool) dualDirectional { return _dualDirectional; }
-(int) minConstraintPriority { return _minConstraintPriority; }
-(int) maxConstraintPriority { return _maxConstraintPriority; }
-(MDDStateValues*) createRootState {
    char* defaultProperties = malloc(_numForwardBytes * sizeof(char));
    [_forwardStateDescriptor initializeState:defaultProperties];
    return [[MDDStateValues alloc] initState:defaultProperties numBytes:_numForwardBytes trail:_trail];
}
-(MDDStateValues*) createSinkState {
    char* defaultProperties = malloc(_numReverseBytes * sizeof(char));
    [_reverseStateDescriptor initializeState:defaultProperties];
    return [[MDDStateValues alloc] initState:defaultProperties numBytes:_numReverseBytes trail:_trail];
}
-(char*) computeForwardStateFromForward:(char*)forward combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom {
    char* newState = malloc(_numForwardBytes);
    memcpy(newState, forward, _numForwardBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            _forwardTransitionFunctions[propertyIndex](newState, forward, combined, valueSet, numArcs, minDom, maxDom);
        }
        return newState;
    }
    bool* propertyUsed = _forwardPropertiesUsedPerVariable[variable];
    for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
        if (propertyUsed[propertyIndex]) {
            _forwardTransitionFunctions[propertyIndex](newState, forward, combined, valueSet, numArcs, minDom, maxDom);
        }
    }
    return newState;
}
-(char*) computeForwardStateFromForward:(char*)forward combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom merged:(bool*)merged {
    char* newState = malloc(_numForwardBytes);
    memcpy(newState, forward, _numForwardBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            *merged = _forwardTransitionFunctions[propertyIndex](newState, forward, combined, valueSet, numArcs, minDom, maxDom) || *merged;
        }
        return newState;
    }
    bool* propertyUsed = _forwardPropertiesUsedPerVariable[variable];
    for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
        if (propertyUsed[propertyIndex]) {
            *merged = _forwardTransitionFunctions[propertyIndex](newState, forward, combined, valueSet, numArcs, minDom, maxDom) || *merged;
        }
    }
    return newState;
}
-(char*) updateForwardStateFromForward:(char*)forward combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState merged:(bool*)merged {
    char* newState = malloc(_numForwardBytes);
    memcpy(newState, oldState, _numForwardBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            if (properties[propertyIndex]) {
                *merged = _forwardTransitionFunctions[propertyIndex](newState, forward, combined, valueSet, numArcs, minDom, maxDom) || *merged;
            }
        }
        return newState;
    }
    bool* propertyUsed = _forwardPropertiesUsedPerVariable[variable];
    for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
        if (properties[propertyIndex]) {
            if (propertyUsed[propertyIndex]) {
                *merged = _forwardTransitionFunctions[propertyIndex](newState, forward, combined, valueSet, numArcs, minDom, maxDom) || *merged;
            } else {
                if ([_forwardProperties[propertyIndex] isKindOfClass:[MDDPBitSequence class]]) {
                    [(MDDPBitSequence*)_forwardProperties[propertyIndex] setBitSequence:[(MDDPBitSequence*)_forwardProperties[propertyIndex] getBitSequence:forward] forState:newState];
                } else {
                    [_forwardProperties[propertyIndex] set:[_forwardProperties[propertyIndex] get:forward] forState:newState];
                }
            }
        }
    }
    return newState;
}
-(char*) cachedComputeForwardStateFromForward:(char*)forward combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet minDom:(int)minDom maxDom:(int)maxDom {
    /*int forwardHash = [self forwardTransitionCacheHashValueFor:forward];
    int maxForwards = _forwardTransitionCacheMaxPerHash[forwardHash];
    int numForwards = _forwardTransitionCacheNumPerHash[forwardHash];
    char* cachedState = nil;
    
    if (maxForwards) {
        for (int forwardIndex = 0; forwardIndex < numForwards; forwardIndex++) {
            if (memcmp(forward, _forwardTransitionCacheForward[forwardHash][forwardIndex], _numForwardBytes) == 0) {
                if (_forwardTransitionCacheResult[forwardHash][forwardIndex][value] != nil) {
                    char* newState = malloc(_numForwardBytes);
                    memcpy(newState, _forwardTransitionCacheResult[forwardHash][forwardIndex][value], _numForwardBytes);
                    
                    char* actualNewState = [self computeForwardStateFromForward:forward combined:combined assigningVariable:variable withValue:value];
                    if (memcmp(newState, actualNewState, _numForwardBytes) != 0) {
                        int i =0;
                    }
                    free(actualNewState);
                    return newState;
                } else {
                    cachedState = malloc(_numForwardBytes);
                    _forwardTransitionCacheResult[forwardHash][forwardIndex][value] = cachedState;
                    break;
                }
            }
        }
        if (cachedState == nil) {   //Means forward state wasn't found
            if (numForwards == maxForwards) {
                int newMax = maxForwards * 2;
                _forwardTransitionCacheMaxPerHash[forwardHash] = newMax;
                
                char** newForwardTransitionCacheForward = malloc(newMax * sizeof(char*));
                char*** newForwardTransitionCacheResult = malloc(newMax * sizeof(char**));
                for (int i = 0; i < numForwards; i++) {
                    newForwardTransitionCacheForward[i] = _forwardTransitionCacheForward[forwardHash][i];
                    newForwardTransitionCacheResult[i] = _forwardTransitionCacheResult[forwardHash][i];
                }
                free(_forwardTransitionCacheForward[forwardHash]);
                free(_forwardTransitionCacheResult[forwardHash]);
                _forwardTransitionCacheForward[forwardHash] = newForwardTransitionCacheForward;
                _forwardTransitionCacheResult[forwardHash] = newForwardTransitionCacheResult;
            }
            _forwardTransitionCacheResult[forwardHash][numForwards] = calloc(_domSize, sizeof(char*));
            _forwardTransitionCacheResult[forwardHash][numForwards] -= _minDom;
            cachedState = malloc(_numForwardBytes);
            _forwardTransitionCacheResult[forwardHash][numForwards][value] = cachedState;
            char* cachedForward = malloc(_numForwardBytes);
            memcpy(cachedForward, forward, _numForwardBytes);
            _forwardTransitionCacheForward[forwardHash][numForwards] = cachedForward;
            _forwardTransitionCacheNumPerHash[forwardHash] = numForwards+1;
        }
    } else {
        _forwardTransitionCacheMaxPerHash[forwardHash] = 2;
        _forwardTransitionCacheNumPerHash[forwardHash] = 1;
        _forwardTransitionCacheForward[forwardHash] = malloc(2 * sizeof(char*));
        _forwardTransitionCacheResult[forwardHash] = malloc(2 * sizeof(char**));
        char* cachedForward = malloc(_numForwardBytes);
        memcpy(cachedForward, forward, _numForwardBytes);
        _forwardTransitionCacheForward[forwardHash][0] = cachedForward;
        cachedState = malloc(_numForwardBytes);
        _forwardTransitionCacheResult[forwardHash][numForwards] = calloc(_domSize, sizeof(char*));
        _forwardTransitionCacheResult[forwardHash][numForwards] -= _minDom;
        _forwardTransitionCacheResult[forwardHash][0][value] = cachedState;
    }
    
    memcpy(cachedState, forward, _numForwardBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            _forwardTransitionFunctions[propertyIndex](cachedState, forward, combined, value);
        }
    } else {
        bool* propertyUsed = _forwardPropertiesUsedPerVariable[variable];
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                _forwardTransitionFunctions[propertyIndex](cachedState, forward, combined, value);
            }
        }
    }
    char* newState = malloc(_numForwardBytes);
    memcpy(newState, cachedState, _numForwardBytes);*/
    return nil;
}
-(char*) computeReverseStateFromReverse:(char*)reverse combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom {
    char* newState = malloc(_numReverseBytes);
    memcpy(newState, reverse, _numReverseBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
            _reverseTransitionFunctions[propertyIndex](newState, reverse, combined, valueSet, numArcs, minDom, maxDom);
        }
        return newState;
    }
    bool* propertyUsed = _reversePropertiesUsedPerVariable[variable];
    for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
        if (propertyUsed[propertyIndex]) {
            _reverseTransitionFunctions[propertyIndex](newState, reverse, combined, valueSet, numArcs, minDom, maxDom);
        }
    }
    return newState;
}
-(char*) computeReverseStateFromProperties:(char*)reverse combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom merged:(bool*)merged {
    char* newState = malloc(_numReverseBytes);
    memcpy(newState, reverse, _numReverseBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
            *merged = _reverseTransitionFunctions[propertyIndex](newState, reverse, combined, valueSet, numArcs, minDom, maxDom) || *merged;
        }
        return newState;
    }
    bool* propertyUsed = _reversePropertiesUsedPerVariable[variable];
    for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
        if (propertyUsed[propertyIndex]) {
            *merged = _reverseTransitionFunctions[propertyIndex](newState, reverse, combined, valueSet, numArcs, minDom, maxDom) || *merged;
        }
    }
    return newState;
}
-(char*) updateReverseStateFromReverse:(char*)reverse combined:(char*)combined assigningVariable:(int)variable withValues:(bool*)valueSet numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState merged:(bool*)merged {
    char* newState = malloc(_numReverseBytes);
    memcpy(newState, oldState, _numReverseBytes);
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
            if (properties[propertyIndex]) {
                *merged = _reverseTransitionFunctions[propertyIndex](newState, reverse, combined, valueSet, numArcs, minDom, maxDom) || *merged;
            }
        }
        return newState;
    }
    bool* propertyUsed = _reversePropertiesUsedPerVariable[variable];
    for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
        if (properties[propertyIndex]) {
            if (propertyUsed[propertyIndex]) {
                *merged = _reverseTransitionFunctions[propertyIndex](newState, reverse, combined, valueSet, numArcs, minDom, maxDom) || *merged;
            } else {
                if ([_reverseProperties[propertyIndex] isKindOfClass:[MDDPBitSequence class]]) {
                    [(MDDPBitSequence*)_reverseProperties[propertyIndex] setBitSequence:[(MDDPBitSequence*)_reverseProperties[propertyIndex] getBitSequence:reverse] forState:newState];
                } else {
                    [_reverseProperties[propertyIndex] set:[_reverseProperties[propertyIndex] get:reverse] forState:newState];
                }
            }
        }
    }
    return newState;
}
-(char*) computeCombinedStateFromProperties:(char*)forward reverse:(char*)reverse {
    char* newState = malloc(_numCombinedBytes);
    for (int propertyIndex = 0; propertyIndex < _numCombinedPropertiesAdded; propertyIndex++) {
        _updatePropertyFunctions[propertyIndex](newState, forward, reverse);
    }
    return newState;
}
-(void) mergeStateProperties:(char*)leftState with:(char*)rightState {
    char* newState = malloc(_numForwardBytes * sizeof(char));
    for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
        _forwardRelaxationFunctions[propertyIndex](newState, leftState, rightState);
    }
    memcpy(leftState, newState, _numForwardBytes);
    free(newState);
}
-(void) mergeStateProperties:(char*)leftState with:(char*)rightState properties:(bool*)properties {
    char* newState = malloc(_numForwardBytes * sizeof(char));
    memcpy(newState, leftState, _numForwardBytes);
    for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
        if (properties[propertyIndex]) {
            _forwardRelaxationFunctions[propertyIndex](newState, leftState, rightState);
        }
    }
    memcpy(leftState, newState, _numForwardBytes);
    free(newState);
}
-(void) mergeReverseStateProperties:(char*)leftState with:(char*)rightState properties:(bool*)properties {
    char* newState = malloc(_numReverseBytes * sizeof(char));
    memcpy(newState, leftState, _numReverseBytes);
    for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
        if (properties[propertyIndex]) {
            _reverseRelaxationFunctions[propertyIndex](newState, leftState, rightState);
        }
    }
    memcpy(leftState, newState, _numReverseBytes);
    free(newState);
}
-(void) cachedMergeStateProperties:(char*)leftState with:(char*)rightState {
    int leftHash = [self forwardMergeCacheHashValueFor:leftState];
    int rightHash = [self forwardMergeCacheHashValueFor:rightState];
    
    char* stateA;
    char* stateB;
    int hashA, hashB;
    
    if (leftHash > rightHash) {
        hashA = rightHash;
        hashB = leftHash;
        stateA = rightState;
        stateB = leftState;
    } else {
        stateA = leftState;
        stateB = rightState;
        hashA = leftHash;
        hashB = rightHash;
    }
    if (_mergeCacheNumPerHash[hashA][hashB] > 0) {
        for (int i = 0; i < _mergeCacheNumPerHash[hashA][hashB]; i++) {
            if (memcmp(stateA, _mergeCacheLeft[hashA][hashB][i], _numForwardBytes) == 0 &&
                 memcmp(stateB, _mergeCacheRight[hashA][hashB][i], _numForwardBytes) == 0) {
                memcpy(leftState, _mergeCacheResult[hashA][hashB][i], _numForwardBytes);
                return;
            }
        }
    }
    //Result was not already cached
    char* newState = malloc(_numForwardBytes * sizeof(char));
    for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
        _forwardRelaxationFunctions[propertyIndex](newState, leftState, rightState);
    }
    
    if (_mergeCacheNumPerHash[hashA][hashB] == _mergeCacheMaxPerHash[hashA][hashB]) {
        if (_mergeCacheMaxPerHash[hashA][hashB] == 0) {
            _mergeCacheMaxPerHash[hashA][hashB] = 2;
            _mergeCacheLeft[hashA][hashB] = malloc(2 * sizeof(char**));
            _mergeCacheRight[hashA][hashB] = malloc(2 * sizeof(char**));
            _mergeCacheResult[hashA][hashB] = malloc(2 * sizeof(char**));
        } else {
            int newMax = _mergeCacheMaxPerHash[hashA][hashB] * 2;
            _mergeCacheMaxPerHash[hashA][hashB] = newMax;
            
            char** newMergeCacheLeft = malloc(newMax * sizeof(char**));
            char** newMergeCacheRight = malloc(newMax * sizeof(char**));
            char** newMergeCacheResult = malloc(newMax * sizeof(char**));
            for (int i = 0; i < _mergeCacheNumPerHash[hashA][hashB]; i++) {
                newMergeCacheLeft[i] = _mergeCacheLeft[hashA][hashB][i];
                newMergeCacheRight[i] = _mergeCacheRight[hashA][hashB][i];
                newMergeCacheResult[i] = _mergeCacheResult[hashA][hashB][i];
            }
            free(_mergeCacheLeft[hashA][hashB]);
            free(_mergeCacheRight[hashA][hashB]);
            free(_mergeCacheResult[hashA][hashB]);
            _mergeCacheLeft[hashA][hashB] = newMergeCacheLeft;
            _mergeCacheRight[hashA][hashB] = newMergeCacheRight;
            _mergeCacheResult[hashA][hashB] = newMergeCacheResult;
        }
    }
    char* cacheLeft = malloc(_numForwardBytes);
    char* cacheRight = malloc(_numForwardBytes);
    memcpy(cacheLeft, stateA, _numForwardBytes);
    memcpy(cacheRight, stateB, _numForwardBytes);
    _mergeCacheLeft[hashA][hashB][_mergeCacheNumPerHash[hashA][hashB]] = cacheLeft;
    _mergeCacheRight[hashA][hashB][_mergeCacheNumPerHash[hashA][hashB]] = cacheRight;
    _mergeCacheResult[hashA][hashB][_mergeCacheNumPerHash[hashA][hashB]] = newState;
    _mergeCacheNumPerHash[hashA][hashB] += 1;
    
    
    memcpy(leftState, newState, _numForwardBytes);
}
-(void) mergeReverseStateProperties:(char*)leftState with:(char*)rightState {
    char* newState = malloc(_numReverseBytes * sizeof(char));
    for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
        _reverseRelaxationFunctions[propertyIndex](newState, leftState, rightState);
    }
    memcpy(leftState, newState, _numReverseBytes);
    free(newState);
}
-(void) cachedMergeReverseStateProperties:(char*)leftState with:(char*)rightState {
    int leftHash = [self reverseMergeCacheHashValueFor:leftState];
    int rightHash = [self reverseMergeCacheHashValueFor:rightState];
    
    char* stateA;
    char* stateB;
    int hashA, hashB;
    
    if (leftHash > rightHash) {
        hashA = rightHash;
        hashB = leftHash;
        stateA = rightState;
        stateB = leftState;
    } else {
        stateA = leftState;
        stateB = rightState;
        hashA = leftHash;
        hashB = rightHash;
    }
    if (_reverseMergeCacheNumPerHash[hashA][hashB] > 0) {
        for (int i = 0; i < _reverseMergeCacheNumPerHash[hashA][hashB]; i++) {
            if (memcmp(stateA, _reverseMergeCacheLeft[hashA][hashB][i], _numReverseBytes) == 0 &&
                 memcmp(stateB, _reverseMergeCacheRight[hashA][hashB][i], _numReverseBytes) == 0) {
                memcpy(leftState, _reverseMergeCacheResult[hashA][hashB][i], _numReverseBytes);
                return;
            }
        }
    }
    //Result was not already cached
    char* newState = malloc(_numReverseBytes * sizeof(char));
    for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
        _reverseRelaxationFunctions[propertyIndex](newState, leftState, rightState);
    }
    
    if (_reverseMergeCacheNumPerHash[hashA][hashB] == _reverseMergeCacheMaxPerHash[hashA][hashB]) {
        if (_reverseMergeCacheMaxPerHash[hashA][hashB] == 0) {
            _reverseMergeCacheMaxPerHash[hashA][hashB] = 2;
            _reverseMergeCacheLeft[hashA][hashB] = malloc(2 * sizeof(char**));
            _reverseMergeCacheRight[hashA][hashB] = malloc(2 * sizeof(char**));
            _reverseMergeCacheResult[hashA][hashB] = malloc(2 * sizeof(char**));
        } else {
            int newMax = _reverseMergeCacheMaxPerHash[hashA][hashB] * 2;
            _reverseMergeCacheMaxPerHash[hashA][hashB] = newMax;
            
            char** newMergeCacheLeft = malloc(newMax * sizeof(char**));
            char** newMergeCacheRight = malloc(newMax * sizeof(char**));
            char** newMergeCacheResult = malloc(newMax * sizeof(char**));
            for (int i = 0; i < _reverseMergeCacheNumPerHash[hashA][hashB]; i++) {
                newMergeCacheLeft[i] = _reverseMergeCacheLeft[hashA][hashB][i];
                newMergeCacheRight[i] = _reverseMergeCacheRight[hashA][hashB][i];
                newMergeCacheResult[i] = _reverseMergeCacheResult[hashA][hashB][i];
            }
            free(_reverseMergeCacheLeft[hashA][hashB]);
            free(_reverseMergeCacheRight[hashA][hashB]);
            free(_reverseMergeCacheResult[hashA][hashB]);
            _reverseMergeCacheLeft[hashA][hashB] = newMergeCacheLeft;
            _reverseMergeCacheRight[hashA][hashB] = newMergeCacheRight;
            _reverseMergeCacheResult[hashA][hashB] = newMergeCacheResult;
        }
    }
    char* cacheLeft = malloc(_numReverseBytes);
    char* cacheRight = malloc(_numReverseBytes);
    memcpy(cacheLeft, stateA, _numReverseBytes);
    memcpy(cacheRight, stateB, _numReverseBytes);
    _reverseMergeCacheLeft[hashA][hashB][_reverseMergeCacheNumPerHash[hashA][hashB]] = cacheLeft;
    _reverseMergeCacheRight[hashA][hashB][_reverseMergeCacheNumPerHash[hashA][hashB]] = cacheRight;
    _reverseMergeCacheResult[hashA][hashB][_reverseMergeCacheNumPerHash[hashA][hashB]] = newState;
    _reverseMergeCacheNumPerHash[hashA][hashB] += 1;
    
    
    memcpy(leftState, newState, _numReverseBytes);
}
-(bool) canChooseValue:(int)value forVariable:(int)variable fromParentForward:(char*)parentForward combined:(char*)parentCombined toChildReverse:(char*)childReverse combined:(char*)childCombined {
    if (_numSpecsAdded == 1) {
        return _arcExists(parentForward, parentCombined,
                          childReverse, childCombined,
                          value,
                          INT_MIN,
                          INT_MAX);
    }
    int numArcExists = _numArcExistsForVariable[variable];
    int* arcExistFunctionIndices = _arcExistFunctionIndicesForVariable[variable];
    for (int i = 0; i < numArcExists; i++) {
        int specIndex = arcExistFunctionIndices[i];
        if (!_arcExistFunctions[specIndex](parentForward, parentCombined,
                                           childReverse, childCombined,
                                           value,
                                           INT_MIN,
                                           INT_MAX)) {
            return false;
        }
    }
    return true;
}
-(bool) canChooseValue:(int)value forVariable:(int)variable fromParentForward:(char*)parentForward combined:(char*)parentCombined toChildReverse:(char*)childReverse combined:(char*)childCombined objectiveMins:(TRInt*)objectiveMins objectiveMaxes:(TRInt*)objectiveMaxes {
    if (_numSpecsAdded == 1) {
        return _arcExists(parentForward, parentCombined,
                          childReverse, childCombined,
                          value,
                          objectiveMins == nil ? INT_MIN : objectiveMins[0]._val,
                          objectiveMaxes == nil ? INT_MAX : objectiveMaxes[0]._val);
    }
    int numArcExists = _numArcExistsForVariable[variable];
    int* arcExistFunctionIndices = _arcExistFunctionIndicesForVariable[variable];
    for (int i = 0; i < numArcExists; i++) {
        int specIndex = arcExistFunctionIndices[i];
        if (!_arcExistFunctions[specIndex](parentForward, parentCombined,
                                           childReverse, childCombined,
                                           value,
                                           objectiveMins == nil ? INT_MIN : objectiveMins[specIndex]._val,
                                           objectiveMaxes == nil ? INT_MAX : objectiveMaxes[specIndex]._val)) {
            return false;
        }
    }
    return true;
}
-(bool) canCreateState:(char**)newStateProperties forward:(char*)forward combined:(char*)combined assigningVariable:(int)variable toValue:(int)value {
    if (_numSpecsAdded == 1) {
        if (!_arcExists(forward, combined,
                        nil, nil,
                        value,
                        INT_MIN,
                        INT_MAX)) {
            return false;
        }
    } else {
        int numArcExists = _numArcExistsForVariable[variable];
        int* arcExistFunctionIndices = _arcExistFunctionIndicesForVariable[variable];
        for (int i = 0; i < numArcExists; i++) {
            int specIndex = arcExistFunctionIndices[i];
            if (!_arcExistFunctions[specIndex](forward, combined,
                                               nil, nil,
                                               value,
                                               INT_MIN,
                                               INT_MAX)) {
                return false;
            }
        }
    }
    
    bool* valueSet = malloc(sizeof(bool));
    valueSet[0] = true;
    valueSet -= value;
    *newStateProperties = malloc(_numForwardBytes * sizeof(char));
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            _forwardTransitionFunctions[propertyIndex](*newStateProperties, forward, combined, valueSet, 1, value, value);
        }
    } else {
        memcpy(*newStateProperties, forward, _numForwardBytes);
        bool* propertyUsed = _forwardPropertiesUsedPerVariable[variable];
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                _forwardTransitionFunctions[propertyIndex](*newStateProperties, forward, combined, valueSet, 1, value, value);
            }
        }
    }
    valueSet += value;
    free(valueSet);
    return true;
}
-(bool) canCreateState:(char**)newStateProperties forward:(char*)forward combined:(char*)combined assigningVariable:(int)variable toValue:(int)value objectiveMins:(TRInt*)objectiveMins objectiveMaxes:(TRInt*)objectiveMaxes {
    if (_numSpecsAdded == 1) {
        if (!_arcExists(forward, combined,
                        nil, nil,
                        value,
                        objectiveMins == nil ? INT_MIN : objectiveMins[0]._val,
                        objectiveMaxes == nil ? INT_MAX : objectiveMaxes[0]._val)) {
            return false;
        }
    } else {
        int numArcExists = _numArcExistsForVariable[variable];
        int* arcExistFunctionIndices = _arcExistFunctionIndicesForVariable[variable];
        for (int i = 0; i < numArcExists; i++) {
            int specIndex = arcExistFunctionIndices[i];
            if (!_arcExistFunctions[specIndex](forward, combined,
                                               nil, nil,
                                               value,
                                               objectiveMins == nil ? INT_MIN : objectiveMins[specIndex]._val,
                                               objectiveMaxes == nil ? INT_MAX : objectiveMaxes[specIndex]._val)) {
                return false;
            }
        }
    }
    
    bool* valueSet = malloc(sizeof(bool));
    valueSet[0] = true;
    valueSet -= value;
    *newStateProperties = malloc(_numForwardBytes * sizeof(char));
    if (_numSpecsAdded == 1) {
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            _forwardTransitionFunctions[propertyIndex](*newStateProperties, forward, combined, valueSet, 1, value, value);
        }
    } else {
        memcpy(*newStateProperties, forward, _numForwardBytes);
        bool* propertyUsed = _forwardPropertiesUsedPerVariable[variable];
        for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                _forwardTransitionFunctions[propertyIndex](*newStateProperties, forward, combined, valueSet, 1, value, value);
            }
        }
    }
    valueSet += value;
    free(valueSet);
    return true;
}
-(bool) stateExistsWithForward:(char*)forward reverse:(char*)reverse combined:(char*)combined {
    if (_numSpecsAdded == 1) {
        if (_stateExists != nil && !_stateExists(forward,reverse,combined,INT_MIN, INT_MAX)) {
            return false;
        }
    } else {
        for (int specIndex = 0; specIndex < _numSpecsAdded; specIndex++) {
            if (_stateExistFunctions[specIndex] != nil && !_stateExistFunctions[specIndex](forward,reverse,combined, INT_MIN, INT_MAX)) {
                return false;
            }
        }
    }
    return true;
}
-(bool) stateExistsWithForward:(char*)forward reverse:(char*)reverse combined:(char*)combined objectiveMins:(TRInt *)objectiveMins objectiveMaxes:(TRInt *)objectiveMaxes {
    if (_numSpecsAdded == 1) {
        if (_stateExists != nil && !_stateExists(forward,reverse,combined,objectiveMins == nil ? INT_MIN : objectiveMins[0]._val,objectiveMaxes == nil ? INT_MAX : objectiveMaxes[0]._val)) {
            return false;
        }
    } else {
        for (int specIndex = 0; specIndex < _numSpecsAdded; specIndex++) {
            if (_stateExistFunctions[specIndex] != nil && !_stateExistFunctions[specIndex](forward,reverse,combined,objectiveMins == nil ? INT_MIN : objectiveMins[specIndex]._val,objectiveMaxes == nil ? INT_MAX : objectiveMaxes[specIndex]._val)) {
                return false;
            }
        }
    }
    return true;
}
-(int) nodePriority:(char*)forward reverse:(char*)reverse combined:(char*)combined node:(MDDNode*)node constraintPriority:(int)constraintPriority {
    int sumOfPriorities = 0;
    int* specs = _specsByPriority[constraintPriority];
    int numSpecs = _numSpecsByPriority[constraintPriority];
    for (int i = 0; i < numSpecs; i++) {
        int specIndex = specs[i];
        if (_nodeSplitValueFunctions[specIndex] != nil) {
            //sumOfPriorities += _nodeSplitValueFunctions[specIndex](forward, reverse, combined, node);
            return _nodeSplitValueFunctions[specIndex](forward, reverse, combined, node);
        }
    }
    return sumOfPriorities;
}
-(int) candidatePriority:(NSArray*)candidate {
    int sumOfPriorities = 0;
    for (int i = 0; i < _numSpecsAdded; i++) {
        if (_candidateSplitValueFunctions[i] != nil) {
            //sumOfPriorities += _candidateSplitValueFunctions[i](candidate);
            return _candidateSplitValueFunctions[i](candidate);
        }
    }
    return sumOfPriorities;
}
-(bool*) diffForwardProperties:(char*)left to:(char*)right {
    bool* diff = malloc(_numForwardPropertiesAdded * sizeof(bool));
    for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
        diff[propertyIndex] = [_forwardProperties[propertyIndex] diff:left to:right];
    }
    return diff;
    /*
    int diffCount = 0;
    int maxDiffCount = 10;
    *diff = malloc(maxDiffCount * sizeof(int));
    for (int propertyIndex = 0; propertyIndex < _numForwardPropertiesAdded; propertyIndex++) {
        if ([_forwardProperties[propertyIndex] diff:left to:right]) {
            if (diffCount == maxDiffCount) {
                int newMaxDiffCount = maxDiffCount * 2;
                int* newDiff = malloc(newMaxDiffCount * sizeof(int));
                for (int i = 0; i < diffCount; i++) {
                    newDiff[i] = (*diff)[i];
                }
                free(*diff);
                *diff = newDiff;
                maxDiffCount = newMaxDiffCount;
            }
            (*diff)[diffCount] = propertyIndex;
            diffCount++;
        }
    }
    return diffCount;
    */
}
-(bool*) diffReverseProperties:(char*)left to:(char*)right {
    bool* diff = malloc(_numReversePropertiesAdded * sizeof(bool));
    if (left == nil) {
        for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
            diff[propertyIndex] = true;
        }
    } else {
        for (int propertyIndex = 0; propertyIndex < _numReversePropertiesAdded; propertyIndex++) {
            diff[propertyIndex] = [_reverseProperties[propertyIndex] diff:left to:right];
        }
    }
    return diff;
}
-(bool*) forwardPropertyImpactFrom:(bool**)parentDeltas numParents:(int)numParents variable:(int)variable {
    bool* propertyImpact = calloc(_numForwardPropertiesAdded, sizeof(bool));
    bool* propertyUsed = _forwardPropertiesUsedPerVariable[variable];
    for (int property = 0; property < _numForwardPropertiesAdded; property++) {
        for (int parent = 0; parent < numParents; parent++) {
            if (parentDeltas[parent][property]) {
                if (propertyUsed[property]) {
                    for (int i = 0; i < _forwardPropertyImpactCount[property]; i++) {
                        propertyImpact[_forwardPropertyImpact[property][i]] = true;
                    }
                } else {
                    propertyImpact[property] = true;
                }
                break;
            }
        }
    }
    return propertyImpact;
}
-(bool*) reversePropertyImpactFrom:(bool**)childDeltas numChildren:(int)numChildren variable:(int)variable {
    bool* propertyImpact = calloc(_numReversePropertiesAdded, sizeof(bool));
    bool* propertyUsed = _reversePropertiesUsedPerVariable[variable];
    for (int property = 0; property < _numReversePropertiesAdded; property++) {
        for (int child = 0; child < numChildren; child++) {
            if (childDeltas[child][property]) {
                if (propertyUsed[property]) {
                    for (int i = 0; i < _reversePropertyImpactCount[property]; i++) {
                        propertyImpact[_reversePropertyImpact[property][i]] = true;
                    }
                } else {
                    propertyImpact[property] = true;
                }
                break;
            }
        }
    }
    return propertyImpact;
}
-(int) numForwardBytes { return _numForwardBytes; }
-(int) numReverseBytes { return _numReverseBytes; }
-(int) numCombinedBytes { return _numCombinedBytes; }
-(int) numForwardProperties { return _numForwardPropertiesAdded; }
-(int) numReverseProperties { return _numReversePropertiesAdded; }
-(int) numCombinedProperties { return _numCombinedPropertiesAdded; }
-(int) numSpecs { return _numSpecsAdded; }
-(id<ORIntVarArray>) vars { return _vars; }
-(id<ORIntVar>*) fixpointVars { return _fixpointVars; }
-(DDFixpointBoundClosure*) fixpointMins { return _fixpointMins; }
-(DDFixpointBoundClosure*) fixpointMaxes { return _fixpointMaxes; }
-(void) finalizeSpec:(id<ORTrail>) trail hashWidth:(int)width {
    _trail = trail;
    _hashWidth = width;
    _numForwardBytes = [_forwardStateDescriptor numBytes];
    _numReverseBytes = [_reverseStateDescriptor numBytes];
    _numCombinedBytes = [_combinedStateDescriptor numBytes];
    short extraBytes = _numForwardBytes % BytesPerMagic;
    if (extraBytes) {
        _numForwardBytes = _numForwardBytes - extraBytes + BytesPerMagic;
    }
    extraBytes = _numReverseBytes % BytesPerMagic;
    if (extraBytes) {
        _numReverseBytes = _numReverseBytes - extraBytes + BytesPerMagic;
    }
    extraBytes = _numCombinedBytes % BytesPerMagic;
    if (extraBytes) {
        _numCombinedBytes = _numCombinedBytes - extraBytes + BytesPerMagic;
    }
    _forwardProperties = [_forwardStateDescriptor properties];
    _reverseProperties = [_reverseStateDescriptor properties];
    _combinedProperties = [_combinedStateDescriptor properties];
    
    //[self initializeCaches];
    
    int constraintPrioritySize = _maxConstraintPriority - _minConstraintPriority + 1;
    _specsByPriority = malloc(constraintPrioritySize * sizeof(int*));
    _specsByPriority -= _minConstraintPriority;
    _numSpecsByPriority = calloc(constraintPrioritySize, sizeof(int));
    _maxSpecsByPriority = calloc(constraintPrioritySize, sizeof(int));
    for (int i = 0; i < _numSpecsAdded; i++) {
        int priority = _constraintPriorities[i];
        if (_maxSpecsByPriority[priority] == _numSpecsByPriority[priority]) {
            if (_maxSpecsByPriority[priority] == 0) {
                _maxSpecsByPriority[priority] = 2;
                _specsByPriority[priority] = malloc(2 * sizeof(int));
            } else {
                _maxSpecsByPriority[priority] *= 2;
                int* newSpecsList = malloc(_maxSpecsByPriority[priority] * sizeof(int));
                for (int j = 0; j < _numSpecsByPriority[priority]; j++) {
                    newSpecsList[j] = _specsByPriority[priority][j];
                }
                free(_specsByPriority[priority]);
                _specsByPriority[priority] = newSpecsList;
            }
        }
        _specsByPriority[priority][_numSpecsByPriority[priority]] = i;
        _numSpecsByPriority[priority] += 1;
    }
    _singlePriority = _minConstraintPriority == _maxConstraintPriority;
    
    _forwardPropertiesUsedPerPriority = malloc((_maxConstraintPriority-_minConstraintPriority+1) * sizeof(bool*));
    _reversePropertiesUsedPerPriority =  malloc((_maxConstraintPriority-_minConstraintPriority+1) * sizeof(bool*));
    _forwardPropertiesUsedPerPriority -= _minConstraintPriority;
    _reversePropertiesUsedPerPriority -= _minConstraintPriority;
    for (int i = _minConstraintPriority; i <= _maxConstraintPriority; i++) {
        _forwardPropertiesUsedPerPriority[i] = calloc(_numForwardPropertiesAdded, sizeof(bool));
        _reversePropertiesUsedPerPriority[i] = calloc(_numReversePropertiesAdded, sizeof(bool));
    }
    for (int i = 0; i < _numSpecsAdded; i++) {
        int priority = _constraintPriorities[i];
        for (int j = 0; j < _numForwardPropertiesAdded; j++) {
            _forwardPropertiesUsedPerPriority[priority][j] |= _forwardPropertiesUsedPerSpec[i][j];
        }
        for (int j = 0; j < _numReversePropertiesAdded; j++) {
            _reversePropertiesUsedPerPriority[priority][j] |= _reversePropertiesUsedPerSpec[i][j];
        }
    }
}

-(void) initializeCaches {
    _cachesUsed = true;
    _transitionCacheHashWidth = _hashWidth * 10 - 1;
    _mergeCacheHashWidth = 929;
    _mergeCacheLeft = malloc(_mergeCacheHashWidth * sizeof(char***));
    _mergeCacheRight = malloc(_mergeCacheHashWidth * sizeof(char***));
    _mergeCacheResult = malloc(_mergeCacheHashWidth * sizeof(char***));
    _mergeCacheNumPerHash = calloc(_mergeCacheHashWidth, sizeof(int*));
    _mergeCacheMaxPerHash = calloc(_mergeCacheHashWidth, sizeof(int*));
    for (int i = 0; i < _mergeCacheHashWidth; i++) {
        _mergeCacheLeft[i] = malloc(_mergeCacheHashWidth * sizeof(char**));
        _mergeCacheRight[i] = malloc(_mergeCacheHashWidth * sizeof(char**));
        _mergeCacheResult[i] = malloc(_mergeCacheHashWidth * sizeof(char**));
        _mergeCacheNumPerHash[i] = calloc(_mergeCacheHashWidth, sizeof(int));
        _mergeCacheMaxPerHash[i] = calloc(_mergeCacheHashWidth, sizeof(int));
    }
    
    _reverseMergeCacheLeft = malloc(_mergeCacheHashWidth * sizeof(char***));
    _reverseMergeCacheRight = malloc(_mergeCacheHashWidth * sizeof(char***));
    _reverseMergeCacheResult = malloc(_mergeCacheHashWidth * sizeof(char***));
    _reverseMergeCacheNumPerHash = calloc(_mergeCacheHashWidth, sizeof(int*));
    _reverseMergeCacheMaxPerHash = calloc(_mergeCacheHashWidth, sizeof(int*));
    for (int i = 0; i < _mergeCacheHashWidth; i++) {
        _reverseMergeCacheLeft[i] = malloc(_mergeCacheHashWidth * sizeof(char**));
        _reverseMergeCacheRight[i] = malloc(_mergeCacheHashWidth * sizeof(char**));
        _reverseMergeCacheResult[i] = malloc(_mergeCacheHashWidth * sizeof(char**));
        _reverseMergeCacheNumPerHash[i] = calloc(_mergeCacheHashWidth, sizeof(int));
        _reverseMergeCacheMaxPerHash[i] = calloc(_mergeCacheHashWidth, sizeof(int));
    }
    
    _forwardTransitionCacheForward = malloc(_transitionCacheHashWidth * sizeof(char**));
    _forwardTransitionCacheResult = malloc(_transitionCacheHashWidth * sizeof(char***));
    _forwardTransitionCacheNumPerHash = calloc(_transitionCacheHashWidth, sizeof(int));
    _forwardTransitionCacheMaxPerHash = calloc(_transitionCacheHashWidth, sizeof(int));
}

-(int) forwardTransitionCacheHashValueFor:(char*)state {
    const int numGroups = _numForwardBytes/BytesPerMagic;
    int hashValue = 0;
    switch (BytesPerMagic) {
        case 2:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&state[s*BytesPerMagic];
            }
            break;
        case 4:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&state[s*BytesPerMagic];
            }
            break;
        default:
            @throw [[ORExecutionError alloc] initORExecutionError: "ORCustomMDDStates: Method hashValueFor not implemented for given BytesPerMagic"];
            break;
    }
    hashValue = hashValue % _transitionCacheHashWidth;
    if (hashValue < 0) hashValue += _transitionCacheHashWidth;
    return hashValue;
}
-(int) reverseTransitionCacheHashValueFor:(char*)state {
    const int numGroups = _numReverseBytes/BytesPerMagic;
    int hashValue = 0;
    switch (BytesPerMagic) {
        case 2:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&state[s*BytesPerMagic];
            }
            break;
        case 4:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&state[s*BytesPerMagic];
            }
            break;
        default:
            @throw [[ORExecutionError alloc] initORExecutionError: "ORCustomMDDStates: Method hashValueFor not implemented for given BytesPerMagic"];
            break;
    }
    hashValue = hashValue % _transitionCacheHashWidth;
    if (hashValue < 0) hashValue += _transitionCacheHashWidth;
    return hashValue;
}
-(int) forwardMergeCacheHashValueFor:(char*)state {
    const int numGroups = _numForwardBytes/BytesPerMagic;
    int hashValue = 0;
    switch (BytesPerMagic) {
        case 2:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&state[s*BytesPerMagic];
            }
            break;
        case 4:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&state[s*BytesPerMagic];
            }
            break;
        default:
            @throw [[ORExecutionError alloc] initORExecutionError: "ORCustomMDDStates: Method hashValueFor not implemented for given BytesPerMagic"];
            break;
    }
    hashValue = hashValue % _mergeCacheHashWidth;
    if (hashValue < 0) hashValue += _mergeCacheHashWidth;
    return hashValue;
}
-(int) reverseMergeCacheHashValueFor:(char*)state {
    const int numGroups = _numReverseBytes/BytesPerMagic;
    int hashValue = 0;
    switch (BytesPerMagic) {
        case 2:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&state[s*BytesPerMagic];
            }
            break;
        case 4:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&state[s*BytesPerMagic];
            }
            break;
        default:
            @throw [[ORExecutionError alloc] initORExecutionError: "ORCustomMDDStates: Method hashValueFor not implemented for given BytesPerMagic"];
            break;
    }
    hashValue = hashValue % _mergeCacheHashWidth;
    if (hashValue < 0) hashValue += _mergeCacheHashWidth;
    return hashValue;
}
-(int) hashValueForState:(char*)state {
    const int numGroups = _numForwardBytes/BytesPerMagic;
    int hashValue = 0;
    switch (BytesPerMagic) {
        case 2:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&state[s*BytesPerMagic];
            }
            break;
        case 4:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&state[s*BytesPerMagic];
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
-(int) hashValueForState:(char*)state priority:(int)priority {
    int hashValue = 0;
    for (int s = 0; s < _numForwardPropertiesAdded; s++) {
        if (_forwardPropertiesUsedPerPriority[priority][s]) {
            hashValue = hashValue * 255 + [_forwardStateDescriptor getProperty:s forState:state];
        }
    }
    hashValue = hashValue % _hashWidth;
    if (hashValue < 0) hashValue += _hashWidth;
    return hashValue;
}
-(int) hashValueForReverseState:(char*)state {
    const int numGroups = _numReverseBytes/BytesPerMagic;
    int hashValue = 0;
    switch (BytesPerMagic) {
        case 2:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&state[s*BytesPerMagic];
            }
            break;
        case 4:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&state[s*BytesPerMagic];
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
-(int) hashValueForReverseState:(char*)state priority:(int)priority {
    int hashValue = 0;
    for (int s = 0; s < _numReversePropertiesAdded; s++) {
        if (_reversePropertiesUsedPerPriority[priority][s]) {
            hashValue = hashValue * 255 + [_reverseStateDescriptor getProperty:s forState:state];
        }
    }
    hashValue = hashValue % _hashWidth;
    if (hashValue < 0) hashValue += _hashWidth;
    return hashValue;
}
-(bool) state:(char*)state equivalentTo:(char*)other forConstraint:(int)constraint {
    for (int s = 0; s < _numForwardPropertiesAdded; s++) {
        if (_forwardPropertiesUsedPerSpec[constraint][s]) {
            if ([_forwardStateDescriptor getProperty:s forState:state] != [_forwardStateDescriptor getProperty:s forState:other]) {
                return false;
            }
        }
    }
    return true;
}
-(bool) reverseState:(char*)state equivalentTo:(char*)other forConstraint:(int)constraint {
    for (int s = 0; s < _numReversePropertiesAdded; s++) {
        if (_reversePropertiesUsedPerSpec[constraint][s]) {
            if ([_reverseStateDescriptor getProperty:s forState:state] != [_reverseStateDescriptor getProperty:s forState:other]) {
                return false;
            }
        }
    }
    return true;
}
-(bool) checkForwardEquivalence:(MDDArc*)a withForward:(char*)forwardA reverse:(char*)reverseA to:(MDDArc*)b withForward:(char*)forwardB reverse:(char*)reverseB approximate:(bool)approximate priority:(int)priority {
    if (!approximate && _singlePriority) {
        return memcmp(forwardA, forwardB, _numForwardBytes) == 0;
    }
    int* specs = _specsByPriority[priority];
    int numSpecs = _numSpecsByPriority[priority];
    for (int i = 0; i < numSpecs; i++) {
        int specIndex = specs[i];
        if (approximate && _approximateEquivalenceFunctions[specIndex] != nil) {
            //if _cachedOnArc
            //if ([a equivalenceClassFor:i] != [b equivalenceClassFor:i]) {
            if (_approximateEquivalenceFunctions[specIndex](forwardA, reverseA) != _approximateEquivalenceFunctions[specIndex](forwardB, reverseB)) {
                return false;
            }
        } else if (!approximate) {
            if (![self state:forwardA equivalentTo:forwardB forConstraint:specIndex]) {
                return false;
            }
        }
    }
    return true;
}
-(bool) checkReverseEquivalence:(MDDArc*)a withForward:(char*)forwardA reverse:(char*)reverseA to:(MDDArc*)b withForward:(char*)forwardB reverse:(char*)reverseB approximate:(bool)approximate priority:(int)priority {
    if (!approximate && _singlePriority) {
        return memcmp(reverseA, reverseB, _numReverseBytes) == 0;
    }
    int* specs = _specsByPriority[priority];
    int numSpecs = _numSpecsByPriority[priority];
    for (int i = 0; i < numSpecs; i++) {
        int specIndex = specs[i];
        if (approximate && _approximateEquivalenceFunctions[specIndex] != nil) {
            //if _cachedOnArc
            //if ([a equivalenceClassFor:i] != [b equivalenceClassFor:i]) {
            if (_approximateEquivalenceFunctions[specIndex](forwardA, reverseA) != _approximateEquivalenceFunctions[specIndex](forwardB, reverseB)) {
                return false;
            }
        } else if (!approximate) {
            if (![self reverseState:reverseA equivalentTo:reverseB forConstraint:specIndex]) {
                return false;
            }
        }
    }
    return true;
}
-(bool) approximateEquivalenceUsedFor:(int)constraint {
    return _approximateEquivalenceFunctions[constraint] != nil;
}
-(bool)approximateEquivalenceUsed {
    for (int i = 0; i < _numSpecsAdded; i++) {
        if (_approximateEquivalenceFunctions[i] != nil) {
            return true;
        }
    }
    return false;
}
-(bool)nodePriorityUsed {
    for (int i = 0; i < _numSpecsAdded; i++) {
        if (_nodeSplitValueFunctions[i] != nil) {
            return true;
        }
    }
    return false;
}
-(bool)candidatePriorityUsed {
    for (int i = 0; i < _numSpecsAdded; i++) {
        if (_candidateSplitValueFunctions[i] != nil) {
            return true;
        }
    }
    return false;
}
-(bool)stateExistenceUsed {
    for (int i = 0; i < _numSpecsAdded; i++) {
        if (_stateExistFunctions[i] != nil) {
            return true;
        }
    }
    return false;
}
-(int) equivalenceClassFor:(char*)forward reverse:(char*)reverse constraint:(int)constraint {
    if (_approximateEquivalenceFunctions[constraint] == nil) {
        return 0;
    } else {
        return _approximateEquivalenceFunctions[constraint](forward, reverse);
    }
}
-(int) combinedEquivalenceClassFor:(char*)forward reverse:(char*)reverse priority:(int)priority {
    int combinedEquivalenceClass = 0;
    int numSpecs = _numSpecsByPriority[priority];
    int* specs = _specsByPriority[priority];
    for (int i = 0; i < numSpecs; i++) {
        int specIndex = specs[i];
        if (_approximateEquivalenceFunctions[specIndex] != nil) {
            combinedEquivalenceClass += _approximateEquivalenceFunctions[specIndex](forward, reverse);
        }
    }
    return combinedEquivalenceClass;
}
-(int) hashWidth { return _hashWidth; }
+(short) bytesPerMagic { return BytesPerMagic; }
@end

@implementation MDDStateValues
-(id) initState:(char*)stateValues numBytes:(int)numBytes trail:(id<ORTrail>)trail {
    self = [super init];
    _numBytes = numBytes;
    _state = stateValues;
    _magic = malloc(_numBytes/BytesPerMagic * sizeof(ORUInt));
    for (int i = 0; i < (_numBytes/BytesPerMagic); i++) {
        _magic[i] = [trail magic];
    }
    _defined = makeTRInt(trail, 1);
    return self;
}
-(id) initEmptyState:(char*)stateValues numBytes:(int)numBytes trail:(id<ORTrail>)trail {
    self = [super init];
    _numBytes = numBytes;
    _state = stateValues;
    _magic = malloc(_numBytes/BytesPerMagic * sizeof(ORUInt));
    for (int i = 0; i < (_numBytes/BytesPerMagic); i++) {
        _magic[i] = [trail magic];
    }
    _defined = makeTRInt(trail, 0);
    return self;
}
-(void) dealloc {
    free(_state);
    free(_magic);
    [super dealloc];
}
-(void) replaceUnusedStateWith:(char*)newState trail:(id<ORTrail>)trail {
    free(_state);
    _state = newState;
    _defined = makeTRInt(trail, 1);
}
-(void) replaceStateWith:(char *)newState trail:(id<ORTrail>)trail {
    ORUInt magic = [trail magic];
    int magicIndex = 0;
    for (int byteIndex = 0; byteIndex < _numBytes; byteIndex+=BytesPerMagic) {
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
        magicIndex++;
    }
    if (_defined._val == 0) {
        assignTRInt(&_defined, 1, trail);
    }
}
-(char*) stateValues {
    if (_defined._val == 0) {
        return nil;
    } else {
        return _state;
    }
}
-(void) setNode:(id)node { _node = node; }
-(id) node { return _node; }
@end
