

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
    _minVar = [vars low];
    _numVars = (int)[vars count];
    _relaxed = relaxed;
    _stateDescriptor = [[MDDStateDescriptor alloc] initMDDStateDescriptor:numProperties];
    _arcExists = malloc(numSpecs * sizeof(DDClosure));
    _transitionFunctions = calloc(numProperties, sizeof(DDClosure));
    if (_relaxed) {
        _relaxationFunctions = calloc(numProperties, sizeof(DDMergeClosure));
        _differentialFunctions = calloc(numProperties, sizeof(DDMergeClosure));
    }
    _numPropertiesAdded = 0;
    _numSpecsAdded = 0;
    _stateValueIndicesForVariable = malloc([vars count] * sizeof(bool*));
    _stateValueIndicesForVariable -= _minVar;
    for (int varIndex = _minVar; varIndex <= [vars up]; varIndex++) {
        _stateValueIndicesForVariable[varIndex] = calloc(numProperties, sizeof(bool));
    }
    _arcExistsForVariable = calloc(_numVars, sizeof(DDClosure));
    _arcExistsForVariable -= _minVar;
    return self;
}
-(id) initMDDStateSpecification:(int)numSpecs numProperties:(int)numProperties relaxed:(bool)relaxed vars:(id<ORIntVarArray>)vars stateDescriptor:(MDDStateDescriptor*)stateDescriptor {
    _minVar = [vars low];
    _numVars = (int)[vars count];
    _relaxed = relaxed;
    _stateDescriptor = stateDescriptor;
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
    for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
        _stateValueIndicesForVariable[varIndex] = calloc(numProperties, sizeof(bool));
    }
    _arcExistsForVariable = calloc(_numVars, sizeof(DDClosure));
    _arcExistsForVariable -= _minVar;
    return self;
}
-(void) dealloc {
    _stateValueIndicesForVariable += _minVar;
    for (int i = 0; i < _numVars; i++) {
        free(_stateValueIndicesForVariable[i]);
    }
    _arcExistsForVariable += _minVar;
    free(_arcExistsForVariable);
    [_stateDescriptor release];
    [super dealloc];
}

-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping {
    for (int i = 0; i < numProperties; i++) {
        [_stateDescriptor addStateProperty:stateProperties[i]];
        _transitionFunctions[_numPropertiesAdded] = transitionFunctions[i];
        for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
            _stateValueIndicesForVariable[mapping[varIndex]][_numPropertiesAdded] = true;
        }
        _numPropertiesAdded++;
    }
    for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
        int mappedVarIndex = mapping[varIndex];
        if (_arcExistsForVariable[mappedVarIndex] == nil) {
            _arcExistsForVariable[mappedVarIndex] = arcExists;
        } else {
            DDClosure oldClosure = [_arcExistsForVariable[mappedVarIndex] copy];
            _arcExistsForVariable[mappedVarIndex] = [(id)^(char* state,ORInt variable, ORInt value) {
                return arcExists(state,variable,value) && oldClosure(state,variable,value);
            } copy];
        }
    }
    _numSpecsAdded++;
}
-(void) addMDDSpec:(MDDPropertyDescriptor**)stateProperties arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions numProperties:(int)numProperties variables:(id<ORIntVarArray>)vars mapping:(int*)mapping {
    for (int i = 0; i < numProperties; i++) {
        [_stateDescriptor addStateProperty:stateProperties[i]];
        _transitionFunctions[_numPropertiesAdded] = transitionFunctions[i];
        _relaxationFunctions[_numPropertiesAdded] = relaxationFunctions[i];
        _differentialFunctions[_numPropertiesAdded] = differentialFunctions[i];
        for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
            _stateValueIndicesForVariable[mapping[varIndex]][_numPropertiesAdded] = true;
        }
        _numPropertiesAdded++;
    }
    for (int varIndex = [vars low]; varIndex <= [vars up]; varIndex++) {
        int mappedVarIndex = mapping[varIndex];
        if (_arcExistsForVariable[mappedVarIndex] == nil) {
            _arcExistsForVariable[mappedVarIndex] = arcExists;
        } else {
            DDClosure oldClosure = [_arcExistsForVariable[mappedVarIndex] copy];
            _arcExistsForVariable[mappedVarIndex] = [(id)^(char* state,ORInt variable, ORInt value) {
                return arcExists(state,variable,value) && oldClosure(state,variable,value);
            } copy];
        }
    }
    _numSpecsAdded++;
}
-(void) addMDDSpec:(ORMDDSpecs*)MDDSpec mapping:(int*)mapping {
    DDClosure* newTransitionClosures = [MDDSpec transitionClosures];
    DDMergeClosure* newRelaxationClosures = [MDDSpec relaxationClosures];
    DDMergeClosure* newDifferentialClosures = [MDDSpec differentialClosures];
    int numNewProperties = [MDDSpec numProperties];
    id<ORIntVarArray> otherVars = [MDDSpec vars];
    for (int i = 0; i < numNewProperties; i++) {
        _transitionFunctions[_numPropertiesAdded] = newTransitionClosures[i];
        if (_relaxed) {
            _relaxationFunctions[_numPropertiesAdded] = newRelaxationClosures[i];
            _differentialFunctions[_numPropertiesAdded] = newDifferentialClosures[i];
        }
        for (int varIndex = [otherVars low]; varIndex <= [otherVars up]; varIndex++) {
            _stateValueIndicesForVariable[mapping[varIndex]][_numPropertiesAdded] = true;
        }
        _numPropertiesAdded++;
    }
    //_arcExists[_numSpecsAdded] = [MDDSpec arcExistsClosure];
    //NSNumber* arcExistsIndex = [NSNumber numberWithInt:_numSpecsAdded];
    DDClosure newArcExistsClosure = [MDDSpec arcExistsClosure];
    for (int varIndex = [otherVars low]; varIndex <= [otherVars up]; varIndex++) {
        int mappedVarIndex = mapping[varIndex];
        if (_arcExistsForVariable[mappedVarIndex] == nil) {
            _arcExistsForVariable[mappedVarIndex] = newArcExistsClosure;
        } else {
            DDClosure oldClosure = [_arcExistsForVariable[mappedVarIndex] copy];
            _arcExistsForVariable[mappedVarIndex] = [(id)^(char* state,ORInt variable, ORInt value) {
                return newArcExistsClosure(state,variable,value) && oldClosure(state,variable,value);
            } copy];
        }
    }
    
    _numSpecsAdded++;
}
-(MDDStateValues*) createRootState:(int)variable {
    char* rootState = malloc(_numBytes * sizeof(char));
    [_stateDescriptor initializeState:rootState];
    return [[MDDStateValues alloc] initState:rootState numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
}
-(MDDStateValues*) createStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value {
    return [[MDDStateValues alloc] initState:[self computeStateFrom:parent assigningVariable:variable withValue:value] numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
}
-(MDDStateValues*) createStateWith:(char*)stateProperties {
    return [[MDDStateValues alloc] initState:stateProperties numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
}
-(MDDStateValues*) createTempStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value {
    return [[MDDStateValues alloc] initState:[self computeStateFrom:parent assigningVariable:variable withValue:value] numBytes:_numBytes];
}
-(char*) computeStateFrom:(MDDStateValues*)parent assigningVariable:(int)variable withValue:(int)value {
    char* parentState = parent.state;
    char* newState = malloc(_numBytes * sizeof(char));
    int newValue;
    for (int propertyIndex = 0; propertyIndex < _numPropertiesAdded; propertyIndex++) {
        MDDPropertyDescriptor* property = _properties[propertyIndex];
        if (_stateValueIndicesForVariable[variable][propertyIndex]) {
            newValue = (int)_transitionFunctions[propertyIndex](parentState, variable, value);
        } else {
            newValue = [property get:parentState];
            //newValue = [_stateDescriptor getProperty:propertyIndex forState:parentState];
        }
        [property set:newValue forState:newState];
        //[_stateDescriptor setProperty:propertyIndex to:newValue forState:newState];
    }
    return newState;
}
-(char*) computeStateFromProperties:(char*)parentState assigningVariable:(int)variable withValue:(int)value {
    char* newState = malloc(_numBytes * sizeof(char));
    int newValue;
    for (int propertyIndex = 0; propertyIndex < _numPropertiesAdded; propertyIndex++) {
        //MDDPropertyDescriptor* property = _properties[propertyIndex];
        if (_stateValueIndicesForVariable[variable][propertyIndex]) {
            newValue = (int)_transitionFunctions[propertyIndex](parentState, variable, value);
        } else {
            newValue = [_properties[propertyIndex] get:parentState];
            //newValue = [_stateDescriptor getProperty:propertyIndex forState:parentState];
        }
        [_properties[propertyIndex] set:newValue forState:newState];
        //[_stateDescriptor setProperty:propertyIndex to:newValue forState:newState];
    }
    return newState;
}
-(void) mergeState:(MDDStateValues*)left with:(MDDStateValues*)right {
    char* leftState = left.state;
    char* rightState = right.state;
    for (int propertyIndex = 0; propertyIndex < _numPropertiesAdded; propertyIndex++) {
        int mergedValue =(int)_relaxationFunctions[propertyIndex](leftState, rightState);
        if ([_stateDescriptor getProperty:propertyIndex forState:leftState] != mergedValue) {
            [left trailByte:[_stateDescriptor byteOffsetForProperty:propertyIndex] trail:_trail];
            [_stateDescriptor setProperty:propertyIndex to:mergedValue forState:leftState];
        }
    }
    [left recalcHash:_hashWidth trail:_trail];
}
-(void) replaceState:(MDDStateValues*)left with:(MDDStateValues*)right {
    char* leftState = left.state;
    char* rightState = right.state;
    for (int propertyIndex = 0; propertyIndex < _numPropertiesAdded; propertyIndex++) {
        int rightValue = [_stateDescriptor getProperty:propertyIndex forState:rightState];
        if ([_stateDescriptor getProperty:propertyIndex forState:leftState] != rightValue) {
            [left trailByte:[_stateDescriptor byteOffsetForProperty:propertyIndex] trail:_trail];
            [_stateDescriptor setProperty:propertyIndex to:rightValue forState:leftState];
        }
    }
    [left recalcHash:_hashWidth trail:_trail];
}
-(bool) canChooseValue:(int)value forVariable:(int)variable withState:(MDDStateValues*)stateValues {
    return _arcExistsForVariable[variable]([stateValues state],variable,value);
}
-(bool) canChooseValue:(int)value forVariable:(int)variable withStateProperties:(char*)state {
    return _arcExistsForVariable[variable](state,variable,value);
}
-(bool) canCreateState:(char**)newStateProperties fromParent:(MDDStateValues*)parentState assigningVariable:(int)variable toValue:(int)value {
    char* parState = [parentState state];
    
    if (!_arcExistsForVariable[variable](parState,variable,value)) {
        return false;
    }
    
    *newStateProperties = malloc(_numBytes * sizeof(char));
    int newValue;
    for (int propertyIndex = 0; propertyIndex < _numPropertiesAdded; propertyIndex++) {
        //MDDPropertyDescriptor* property = _properties[propertyIndex];
        if (_stateValueIndicesForVariable[variable][propertyIndex]) {
            newValue = (int)_transitionFunctions[propertyIndex](parState, variable, value);
        } else {
            newValue = [_properties[propertyIndex] get:parState];
            //newValue = [_stateDescriptor getProperty:propertyIndex forState:parentState];
        }
        [_properties[propertyIndex] set:newValue forState:*newStateProperties];
        //[_stateDescriptor setProperty:propertyIndex to:newValue forState:newState];
    }
    return true;
}
-(int) stateDifferential:(MDDStateValues*)left with:(MDDStateValues*)right {
    int differential = 0;
    char* leftState = left.state;
    char* rightState = right.state;
    for (int stateIndex = 0; stateIndex < _numPropertiesAdded; stateIndex++) {
        DDMergeClosure differentialFunction = _differentialFunctions[stateIndex];
        if (differentialFunction != nil) {
            differential += (int)differentialFunction(leftState,rightState);
         }
    }
    return differential;
}
-(int) numProperties { return _numPropertiesAdded; }
-(size_t) numBytes { return _numBytes; }
-(MDDStateDescriptor*) stateDescriptor { return _stateDescriptor; }
-(void) finalizeSpec:(id<ORTrail>) trail hashWidth:(int)width {
    _trail = trail;
    _hashWidth = width;
    _numBytes = [_stateDescriptor numBytes];
    short extraBytes = _numBytes % BytesPerMagic;
    if (extraBytes) {
        _numBytes = _numBytes - extraBytes + BytesPerMagic;
    }
    _properties = [_stateDescriptor properties];
}
-(NSUInteger) hashValueFor:(char*)stateProperties {
    //TODO: The following is currently in two places which isn't good practice.  Look into how MDDStateValues can use this function.
    const size_t numGroups = _numBytes/BytesPerMagic;
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
-(void) trailByte:(size_t)byteOffset trail:(id<ORTrail>)trail {
    if (!_tempState) {
        ORUInt magic = [trail magic];
        size_t magicIndex = byteOffset/BytesPerMagic;
        if (magic != _magic[magicIndex]) {
            switch (BytesPerMagic) {
                case 2:
                    [trail trailShort:(short*)&_state[magicIndex*BytesPerMagic]];
                    break;
                case 4:
                    [trail trailInt:(int*)&_state[magicIndex*BytesPerMagic]];
                    break;
                default:
                    @throw [[ORExecutionError alloc] initORExecutionError: "MDDStateValues: Method trailState not implemented for given BytesPerMagic"];
            }
            _magic[magicIndex] = magic;
        }
    }
}
-(char*) state { return _state; }
-(BOOL) isEqualToStateProperties:(char*)other {
    return memcmp(_state, other, _numBytes) == 0;
}
-(BOOL) isEqual:(MDDStateValues*)other {
    /*if (other == self) return YES;
    if (!other || ![other isKindOfClass:[self class]]) return NO;
    return [self isEqualToMDDStateValues:other];*/
    return memcmp(_state, other.state, _numBytes) == 0;
    /*char* other_state = [other state];
    for (int byteIndex = 0; byteIndex < _numBytes; byteIndex++) {
        if (_state[byteIndex] != other_state[byteIndex]) {
            return false;
        }
    }
    return true;*/
}
-(BOOL) isEqualToMDDStateValues:(MDDStateValues*)other {
    char* other_state = [other state];
    return memcmp(_state, other_state, _numBytes);
    /*for (int byteIndex = 0; byteIndex < _numBytes; byteIndex++) {
        if (_state[byteIndex] != other_state[byteIndex]) {
            return false;
        }
    }
    return true;*/
}
-(id) copyWithZone:(NSZone*) zone {
    char* newState = malloc(_numBytes * sizeof(char));
    memcpy(newState, _state, _numBytes);
    MDDStateValues* copy = [[MDDStateValues alloc] initState:newState numBytes:_numBytes];
    return copy;
}
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

    /*NSUInteger hashValue = 1;
    for (int byteIndex = 0; byteIndex < _numBytes; byteIndex++) {
        hashValue = hashValue * 256 + (int)_state[byteIndex];
    }
    return (int)(hashValue % width);*/
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
