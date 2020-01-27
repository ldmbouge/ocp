

#import "ORHardCodedMDDStates.h"

@implementation KnapsackBDDState    //Not fully implemented yet
-(id) initClassState:(int)domainMin domainMax:(int)domainMax capacity:(id<ORIntVar>)capacity weights:(id<ORIntArray>)weights {
    self = [super initClassState:domainMin domainMax:domainMax];
    _capacity = capacity;
    //    _capacityNumDigits = 0;
    //    int tempCapacity = [_capacity up];
    //    while (tempCapacity > 0) {
    //        _capacityNumDigits++;
    //        tempCapacity/=10;
    //    }
    _weights = weights;
    return self;
}

-(id) initRootState:(KnapsackBDDState*)classState variableIndex:(int)variableIndex {
    self = [super initRootState:classState variableIndex:variableIndex];
    _capacity = [classState capacity];
    //    _capacityNumDigits = [classState capacityNumDigits];
    _weights = [classState weights];
    _weightSum = 0;
    return self;
}
-(id) initState:(KnapsackBDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _capacity = [parentNodeState capacity];
    //    _capacityNumDigits = [parentNodeState capacityNumDigits];
    _weights = [parentNodeState weights];
    [self writeStateFromParent:parentNodeState assigningValue:edgeValue];
    return self;
}
-(int) weightSum { return _weightSum; }
-(void) writeStateFromParent:(KnapsackBDDState*)parent assigningValue:(int)value {
    int variable = [parent variableIndex];
    bool* parentState = [parent state];
    if (value == 1) {
        _weightSum = [parent weightSum] + [self getWeightForVariable:variable];
        for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex] && ((_weightSum + [self getWeightForVariable:stateIndex]) <= [_capacity up]);
            //            _stateChar[stateIndex - _domainMin] = _state[stateIndex] ? '1':'0';
        }
        //        for (int digit = 1; digit <= _capacityNumDigits; digit++) {
        //            _stateChar[_domainMax + 1 + (_capacityNumDigits - digit) - _domainMin] = (char)((int)(_weightSum/pow(10,digit-1)) % 10 + (int)'0');
        //        }
    }
    else {
        _weightSum = [parent weightSum];
        for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex];
            //            _stateChar[stateIndex - _domainMin] = _state[stateIndex] ? '1':'0';
        }
        //        for (int digit = 1; digit <= _capacityNumDigits; digit++) {
        //            _stateChar[_domainMax + digit - _domainMin] = [parent stateChar][_domainMax + digit - _domainMin];
        //        }
    }
    _state[variable] = false;
    //    _stateChar[variable - _domainMin] = '0';
}
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    if (value == 1 && (_weightSum + [self getWeightForVariable:variable] + [self getWeightForVariable:toVariable]) > [_capacity up] && _state[variable]) {
        return [[NSArray alloc] initWithObjects:[NSNumber numberWithInt: variable], nil];
    } else {
        return [[NSArray alloc] init];
    }
}
-(void) mergeStateWith:(KnapsackBDDState*)other {
    if (_weightSum < [other weightSum]) {
        _weightSum = [other weightSum];
        bool* otherState = [other state];
        for (int variable = _domainMin; variable <= _domainMax; variable++) {
            _state[variable] = otherState[variable];
            //            _stateChar[variable - _domainMin] = _state[variable - _domainMin] ? '1' : '0';
        }
        //        for (int digit = 1; digit <= _capacityNumDigits; digit++) {
        //            _stateChar[_domainMax + digit - _domainMin] = [other stateChar][_domainMax + digit - _domainMin];
        //        }
    }
}
-(int) getWeightForVariable:(int)variable {
    return [_weights at: variable];
}
-(int*) getWeightsForVariable:(int)variable {
    int* values = malloc(2 * sizeof(int));
    values[0] = 0;
    values[1] = [self getWeightForVariable:variable];
    return values;
}
-(id<ORIntVar>) capacity { return _capacity; }
//-(int) capacityNumDigits { return _capacityNumDigits; }
-(id<ORIntArray>) weights { return _weights; }
@end

@implementation AllDifferentMDDState
-(id) initRootState:(AllDifferentMDDState*)classState variableIndex:(int)variableIndex {
    self = [super initRootState:classState variableIndex:variableIndex];
    _state = malloc((_domainMax - _domainMin +1) * sizeof(bool));
    _state -= _domainMin;
    //    _stateChar = malloc((_domainMax - _domainMin +1) * sizeof(char));
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        _state[stateIndex] = true;
        //        _stateChar[stateIndex - _domainMin] = '1';
    }
    return self;
}
-(id) initState:(AllDifferentMDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    bool* parentState = [parentNodeState state];
    //    char* parentStateChar = [parentNodeState stateChar];
    _state = malloc((_domainMax - _domainMin +1) * sizeof(bool));
    _state -= _domainMin;
    //    _stateChar = malloc((_domainMax - _domainMin +1) * sizeof(char));
    
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        if (stateIndex == edgeValue) {
            _state[stateIndex] = false;
            //            _stateChar[stateIndex - _domainMin] = '0';
        } else {
            _state[stateIndex] = parentState[stateIndex];
            //            _stateChar[stateIndex - _domainMin] = parentStateChar[stateIndex - _domainMin];
        }
    }
    return self;
}
-(id) initState:(AllDifferentMDDState*)parentNodeState variableIndex:(int)variableIndex {
    self = [super initState:parentNodeState variableIndex:variableIndex];
    bool* parentState = [parentNodeState state];
    //    char* parentStateChar = [parentNodeState stateChar];
    _state = malloc((_domainMax - _domainMin +1) * sizeof(bool));
    _state -= _domainMin;
    //    _stateChar = malloc((_domainMax - _domainMin +1) * sizeof(char));
    
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        _state[stateIndex] = parentState[stateIndex];
        //        _stateChar[stateIndex - _domainMin] = parentStateChar[stateIndex - _domainMin];
    }
    return self;
}

-(bool*) state { return _state; }

-(void) mergeStateWith:(AllDifferentMDDState*)other {
    bool* otherState = [other state];
    
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        _state[stateIndex] = _state[stateIndex] || otherState[stateIndex];
        //        _stateChar[stateIndex - _domainMin] = (_state[stateIndex] ? '1' : '0');
    }
}

-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    NSArray* savedChanges = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt: value], nil];
    _state[value] = false;
    return savedChanges;
}

-(void) undoChanges:(NSArray*)savedChanges {
    _state[[savedChanges[0] integerValue]] = true;
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    return _state[value];
}

-(int) stateDifferential:(AllDifferentMDDState*)other {
    int differential = 0;
    bool* other_state = [other state];
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        if (_state[stateIndex] != other_state[stateIndex]) {
            differential++;
        }
    }
    return differential;
}
-(bool) equivalentTo:(AllDifferentMDDState*)other {
    bool* other_state = [other state];
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        if (_state[stateIndex] != other_state[stateIndex]) {
            return false;
        }
    }
    return true;
}
@end

@implementation AmongMDDState
static int MinState;
static int MaxState;
static ORInt LowerBound;
static ORInt UpperBound;
static id<ORIntSet> Set;
static int NumVarsRemaining;

-(id) initClassState:(int)domainMin domainMax:(int)domainMax setValues:(id<ORIntSet>)set lowerBound:(ORInt)lowerBound upperBound:(ORInt)upperBound numVars:(ORInt)numVars {
    self = [super initClassState:domainMin domainMax:domainMax];
    _lowerBound = lowerBound;
    _upperBound = upperBound;
    //    _upperBoundNumDigits = 0;
    //    while (upperBound > 0) {
    //        _upperBoundNumDigits++;
    //        upperBound/=10;
    //    }
    _set = set;
    _numVarsRemaining = numVars;
    return self;
}
-(id) initRootState:(AmongMDDState*)classState variableIndex:(int)variableIndex {
    self = [super initRootState:classState variableIndex:variableIndex];
    _minState = 0;
    _maxState = 0;
    _lowerBound = [classState lowerBound];
    _upperBound = [classState upperBound];
    //    _upperBoundNumDigits = [classState numDigits];
    _set = [classState set];
    //    _stateChar = malloc((_upperBoundNumDigits) * sizeof(char));
    //    for (int digitIndex = 0; digitIndex < _upperBoundNumDigits; digitIndex++) {
    //        _stateChar[digitIndex] = '0';
    //    }
    _numVarsRemaining = [classState numVarsRemaining];
    return self;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax {
    self = [super initRootState:variableIndex domainMin:domainMin domainMax:domainMax];
    _minState = MinState;
    _maxState = MaxState;
    _lowerBound = LowerBound;
    _upperBound = UpperBound;
    _set = Set;
    _numVarsRemaining = NumVarsRemaining;
    return self;
}
-(id) initState:(AmongMDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    int parentMinState = [parentNodeState minState];
    int parentMaxState = [parentNodeState maxState];
    //    char* parentStateChar = [parentNodeState stateChar];
    _minState = parentMinState;
    _maxState = parentMaxState;
    _lowerBound = [parentNodeState lowerBound];
    _upperBound = [parentNodeState upperBound];
    //    _upperBoundNumDigits = [parentNodeState numDigits];
    _set = [parentNodeState set];
    //    _stateChar = malloc((_upperBoundNumDigits) * sizeof(char));
    
    if ([_set member: edgeValue]) {
        _minState++;
        _maxState++;
    }
    /*    int temp = _state;
     bool changedDigits = true;
     //stateChar is in reverse order of digits for convenience sake
     for (int digitIndex = 0; digitIndex < _upperBoundNumDigits; digitIndex++) {
     if (changedDigits) {
     _stateChar[digitIndex] = (char) ((int)'0' + temp % 10);
     if (temp % 10 != 0) {
     changedDigits = false;
     }
     } else {
     _stateChar[digitIndex] = parentStateChar[digitIndex];
     }
     }*/
    _numVarsRemaining = [parentNodeState numVarsRemaining] -1;
    return self;
}
-(id) initState:(AmongMDDState*)parentNodeState variableIndex:(int)variableIndex {
    self = [super initState:parentNodeState variableIndex:variableIndex];
    int parentMinState = [parentNodeState minState];
    int parentMaxState = [parentNodeState maxState];
    //    char* parentStateChar = [parentNodeState stateChar];
    _minState = parentMinState;
    _maxState = parentMaxState;
    _lowerBound = [parentNodeState lowerBound];
    _upperBound = [parentNodeState upperBound];
    //   _upperBoundNumDigits = [parentNodeState numDigits];
    _set = [parentNodeState set];
    //    _stateChar = malloc((_upperBoundNumDigits) * sizeof(char));
    
    //    for (int digitIndex = 0; digitIndex < _upperBoundNumDigits; digitIndex++) {
    //        _stateChar[digitIndex] = parentStateChar[digitIndex];
    //    }
    _numVarsRemaining = [parentNodeState numVarsRemaining];
    return self;
}

-(int) minState { return _minState; }
-(int) maxState { return _maxState; }
-(int) lowerBound { return _lowerBound; }
-(int) upperBound { return _upperBound; }
//-(int) numDigits { return _upperBoundNumDigits; }
-(id<ORIntSet>) set { return _set; }
-(int) numVarsRemaining { return _numVarsRemaining; }

-(void) mergeStateWith:(AmongMDDState*)other {  //When doing relaxations, will need to complete this.  Need to change class to have the state variable contain its own lower and upper value containing the lowest-most merged value and greatest merged value.  For canChooseValue, compare lowest-most against upperbound and greatest against lower bound to see feasibility
    int otherMinState = [other minState];
    int otherMaxState = [other maxState];
    
    _minState = min(_minState, otherMinState);
    _maxState = max(_maxState, otherMaxState);
}

-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    ORBool contained = [_set member:value];
    NSArray* savedChanges = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool: (contained)], nil];
    if (contained) {
        _minState++;
        _maxState++;
    }
    return savedChanges;
}

-(void) undoChanges:(NSArray*)savedChanges {
    if ([savedChanges[0] boolValue]) {
        _minState--;
        _maxState--;
    }
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    int addition = [_set member:value] ? 1:0;
    return (_minState + addition <= _upperBound) && (_maxState + addition + _numVarsRemaining -1 >= _lowerBound);
}

-(int) stateDifferential:(AmongMDDState*)other {
    int minStateDifferential;
    int maxStateDifferential;
    int otherMinState = [other minState];
    int otherMaxState = [other maxState];
    
    /*if (max(_minState, otherMinState) + _numVarsRemaining <= _upperBound) {
     minStateDifferential = 0;
     } else {
     int canAdd = _upperBound - _minState;
     int otherCanAdd = _upperBound - otherMinState;
     minStateDifferential = abs(canAdd - otherCanAdd);
     }
     if (min(_maxState, [other maxState]) >= _lowerBound) {
     maxStateDifferential = 0;
     } else {
     int mustAdd = max(_lowerBound - _maxState, 0);  //Possible that one of the two states doesn't *have* to add any more.  This would cause lb - state to be negative
     int otherMustAdd = max(_lowerBound - otherMaxState, 0);
     maxStateDifferential = abs(mustAdd - otherMustAdd);
     }*/
    minStateDifferential = abs(_minState - otherMinState)*2;
    maxStateDifferential = abs(_maxState - otherMaxState)*2;
    
    int differential = minStateDifferential + maxStateDifferential + (_maxState - _minState) + (otherMaxState - otherMinState);
    
    //could add tie-breakers based on where in potential range the states lie
    //Example:  If lb is 1 and up is 3, and nodes are compared with states 1, 2, and 3, then depending on numVarsRemaining, it may be preferred to join 1 & 2 vs 2 & 3 despite having the same differential as how it's currently calculated.  If there were only one numVarsRemaining, then 1 & 2 can be combined for free actually.  If there are a lot of variables remaining, it may be better to join 2 & 3. Not positive.
    
    return differential;
}
-(bool) equivalentTo:(AmongMDDState*)other {
    int otherMinState = [other minState];
    int otherMaxState = [other maxState];
    
    if ((_minState == otherMinState && _maxState == otherMaxState) || (min(_maxState, otherMaxState) >= _lowerBound && max(_minState, otherMinState) +  _numVarsRemaining <= _upperBound)) {
        //Either same state OR both states are able to select any subset of subsequent variable due to numVarsRemaining being small enough while already meeting lowerBound
        return true;
    }
    return false;
}
@end

@implementation CustomBDDState
-(id) initRootState:(CustomBDDState*)classState variableIndex:(int)variableIndex {
    self = [super initRootState:classState variableIndex:variableIndex];
    _state = malloc((_domainMax - _domainMin +1) * sizeof(bool));
    _state -= _domainMin;
    //    _stateChar = malloc((_domainMax - _domainMin +1) * sizeof(char));
    
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        _state[stateIndex] = true;
        //        _stateChar[stateIndex - _domainMin] = '1';
    }
    return self;
}
-(id) initState:(CustomBDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {    //Bad naming I think.  Parent is actually the one assigned that value, not the variableIndex
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    bool* parentState = [parentNodeState state];
    //    char* parentStateChar = [parentNodeState stateChar];
    
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        if (stateIndex == [parentNodeState variableIndex]) {
            _state[stateIndex] = false;
            //            _stateChar[stateIndex - _domainMin] = '0';
        } else {
            _state[stateIndex] = parentState[stateIndex];
            //            _stateChar[stateIndex - _domainMin] = parentStateChar[stateIndex];
        }
    }
    return self;
}

-(bool*) state {
    return _state;
}

-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    if (_state[variable] != value) {
        _state[variable] = value;
        return [[NSArray alloc] initWithObjects:[NSNumber numberWithInt: variable], nil];
    } else {
        return [[NSArray alloc] init];
    }
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    if (value == 0) return true;
    return _state[variable];
}
-(void) undoChanges:(NSArray*)savedChanges {
    for (int index = 0; index < [savedChanges count]; index++) {
        _state[[savedChanges[index] intValue]] = !(_state[[savedChanges[index] intValue]]);
    }
}
@end
