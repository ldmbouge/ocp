/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORMDDify.h"
#import "ORModelI.h"
#import "ORVarI.h"
#import "ORDecompose.h"
#import "ORRealDecompose.h"

@implementation ORFactory(MDD)
+(void) sortIntVarArray:(NSMutableArray*)array first:(ORInt)first last:(ORInt)last {
    ORInt i, j, pivot;
    id<ORIntVar> temp;
    
    if(first<last){
        pivot=first;
        i=first;
        j=last;
        
        while(i<j){
            while([array objectAtIndex:i]<=[array objectAtIndex:pivot]&&i<last)
                i++;
            while([array objectAtIndex:j]>[array objectAtIndex:pivot])
                j--;
            if(i<j){
                temp=[array objectAtIndex:i];
                [array setObject: [array objectAtIndex:j] atIndexedSubscript:i];
                [array setObject:temp atIndexedSubscript:j];
            }
        }
        
        temp=[array objectAtIndex:pivot];
        [array setObject:[array objectAtIndex:j] atIndexedSubscript:pivot];
        [array setObject:temp atIndexedSubscript:j];
        [self sortIntVarArray: array first:first last:j-1];
        [self sortIntVarArray: array first:j+1 last:last];
    }
}


+(id<ORIntVarArray>) mergeIntVarArray:(id<ORIntVarArray>)x with:(id<ORIntVarArray>)y {
    NSMutableArray<id<ORIntVar>> *mergedTemp = [[NSMutableArray alloc] init];
    NSMutableArray<id<ORIntVar>> *sortedX = [[NSMutableArray alloc] init];
    NSMutableArray<id<ORIntVar>> *sortedY = [[NSMutableArray alloc] init];
    for (int i = 1; i <= [x count]; i++) {
        [sortedX addObject: x[i]];
    }
    for (int i = 1; i <= [y count]; i++) {
        [sortedY addObject: y[i]];
    }
    [self sortIntVarArray:sortedX first:0 last:(ORInt)([x count] - 1)];
    [self sortIntVarArray:sortedY first:0 last:(ORInt)([y count] - 1)];
    
    ORInt size = 0, xIndex = 0, yIndex = 0;
    
    while (xIndex < [x count] || yIndex < [y count]) {
        if (xIndex < [x count] && (yIndex >= [y count] || sortedX[xIndex] < sortedY[yIndex])) {
            [mergedTemp setObject:[sortedX objectAtIndex:xIndex] atIndexedSubscript:size];
            xIndex++;
            size++;
        } else if (xIndex >= [x count] || sortedX[xIndex] > sortedY[yIndex]) {
            [mergedTemp setObject:[sortedY objectAtIndex:yIndex] atIndexedSubscript:size];
            yIndex++;
            size++;
        } else {
            [mergedTemp setObject:[sortedX objectAtIndex:xIndex] atIndexedSubscript:size];
            xIndex++;
            yIndex++;
            size++;
        }
    }
    id<ORIntRange> range = RANGE([x tracker],1,size);
    id<ORIntVarArray> merged = [ORFactory intVarArray:[x tracker] range:range];
    for (int i = 1; i <= size; i++) {
        [merged setObject:mergedTemp[i - 1] atIndexedSubscript:i];
    }
    return merged;
}
@end

@interface CustomState : NSObject {
@protected
    int _variableIndex;
//    char* _stateChar;
    int _domainMin;
    int _domainMax;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax;
-(id) initRootState:(CustomState*)classState variableIndex:(int)variableIndex;
-(id) initState:(CustomState*)parentNodeState assignedValue:(int)edgeValue variableIndex:(int)variableIndex;
-(id) initState:(CustomState*)parentNodeState variableIndex:(int)variableIndex;
//-(char*) stateChar;
-(int) variableIndex;
-(int) domainMin;
-(int) domainMax;
-(void) mergeStateWith:(CustomState*)other;
-(int) numPathsWithNextVariable:(int)variable;
-(NSArray*) tempAlterStateAssigningValue:(int)value withNextVariable:(int)nextVariable;
-(void) undoChanges:(NSArray*)savedChanges;
-(bool) canChooseValue:(int)value forVariable:(int)variable;
-(int) stateDifferential:(CustomState*)other;
-(bool) equivalentTo:(CustomState*)other;
@end

@implementation CustomState
-(id) initClassState:(int)domainMin domainMax:(int)domainMax {
    _domainMin = domainMin;
    _domainMax = domainMax;
    return self;
}
-(id) initRootState:(CustomState*)classState variableIndex:(int)variableIndex {
    _domainMin = [classState domainMin];
    _domainMax = [classState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(id) initState:(CustomState*)parentNodeState assignedValue:(int)edgeValue variableIndex:(int)variableIndex {
    _domainMin = [parentNodeState domainMin];
    _domainMax = [parentNodeState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(id) initState:(CustomState*)parentNodeState variableIndex:(int)variableIndex {
    _domainMin = [parentNodeState domainMin];
    _domainMax = [parentNodeState domainMax];
    _variableIndex = variableIndex;
    return self;
}

//-(char*) stateChar { return _stateChar; }
-(int) variableIndex { return _variableIndex; }
-(int) domainMin { return _domainMin; }
-(int) domainMax { return _domainMax; }
-(void) mergeStateWith:(CustomState *)other {
    return;
}
-(int) numPathsWithNextVariable:(int)variable {
    int count = 0;
    for (int fromValue = _domainMin; fromValue <= _domainMax; fromValue++) {
        if ([self canChooseValue:fromValue forVariable:_variableIndex]) {
            NSArray* savedChanges = [self tempAlterStateAssigningValue:fromValue withNextVariable:variable];
            for (int toValue = _domainMin; toValue <= _domainMax; toValue++) {
                if ([self canChooseValue:toValue forVariable:variable]) {
                    count++;
                }
            }
            [self undoChanges:savedChanges];
        }
    }
    return count;
}
-(NSArray*) tempAlterStateAssigningValue:(int)value withNextVariable:(int)nextVariable {
    return [[NSArray alloc] init];
}
-(void) undoChanges:(NSArray*)savedChanges { return; }

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

@interface CustomBDDState : CustomState {   //A state with a list of booleans corresponding to whether or not each variable can be assigned 1
@protected
    bool* _state;
}
-(bool*) state;
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

@interface KnapsackBDDState : CustomBDDState {
@protected
    int _weightSum;
    int _capacity;
    int _capacityNumDigits;
    id<ORIntArray> _weights;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax capacity:(int)capacity weights:(id<ORIntArray>)weights;
-(int) weightSum;
-(int) getWeightForVariable:(int)variable;
-(int*) getWeightsForVariable:(int)variable;
-(int) capacity;
-(int) capacityNumDigits;
-(id<ORIntArray>) weights;
@end

@implementation KnapsackBDDState
-(id) initClassState:(int)domainMin domainMax:(int)domainMax capacity:(int)capacity weights:(id<ORIntArray>)weights {
    self = [super initClassState:domainMin domainMax:domainMax];
    _capacity = capacity;
    _capacityNumDigits = 0;
    int tempCapacity = _capacity;
    while (tempCapacity > 0) {
        _capacityNumDigits++;
        tempCapacity/=10;
    }
    _weights = weights;
    return self;
}

-(id) initRootState:(KnapsackBDDState*)classState variableIndex:(int)variableIndex {
    self = [super initRootState:classState variableIndex:variableIndex];
    _capacity = [classState capacity];
    _capacityNumDigits = [classState capacityNumDigits];
    _weights = [classState weights];
    _weightSum = 0;
    return self;
}
-(id) initState:(KnapsackBDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _capacity = [parentNodeState capacity];
    _capacityNumDigits = [parentNodeState capacityNumDigits];
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
            _state[stateIndex] = parentState[stateIndex] && ((_weightSum + [self getWeightForVariable:stateIndex]) <= _capacity);
//            _stateChar[stateIndex - _domainMin] = _state[stateIndex] ? '1':'0';
        }
        for (int digit = 1; digit <= _capacityNumDigits; digit++) {
//            _stateChar[_domainMax + 1 + (_capacityNumDigits - digit) - _domainMin] = (char)((int)(_weightSum/pow(10,digit-1)) % 10 + (int)'0');
            
        }
    }
    else {
        _weightSum = [parent weightSum];
        for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex];
//            _stateChar[stateIndex - _domainMin] = _state[stateIndex] ? '1':'0';
        }
        for (int digit = 1; digit <= _capacityNumDigits; digit++) {
//            _stateChar[_domainMax + digit - _domainMin] = [parent stateChar][_domainMax + digit - _domainMin];
        }
    }
    _state[variable] = false;
//    _stateChar[variable - _domainMin] = '0';
}
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    if (value == 1 && (_weightSum + [self getWeightForVariable:variable] + [self getWeightForVariable:toVariable]) > _capacity && _state[variable]) {
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
-(int) capacity { return _capacity; }
-(int) capacityNumDigits { return _capacityNumDigits; }
-(id<ORIntArray>) weights { return _weights; }
@end

@interface AllDifferentMDDState : CustomState {
@protected
    bool* _state;
}
-(bool*) state;
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
    self = [super initState:parentNodeState assignedValue:edgeValue variableIndex:variableIndex];
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

@interface AmongMDDState : CustomState {
@protected
    int _minState;
    int _maxState;
    ORInt _lowerBound;
    ORInt _upperBound;
    id<ORIntSet> _set;
    int _numVarsRemaining;
    
//    ORInt _upperBoundNumDigits;
}
-(int)minState;
-(int)maxState;
-(int)lowerBound;
-(int)upperBound;
//-(int)numDigits;
-(id<ORIntSet>)set;
-(int)numVarsRemaining;
@end

@implementation AmongMDDState
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
-(id) initState:(AmongMDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assignedValue:edgeValue variableIndex:variableIndex];
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
//    _upperBoundNumDigits = [parentNodeState numDigits];
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

@interface JointState : CustomState {
@protected
    NSMutableArray* _states;
}
+(void) addStateClass:(CustomState*)stateClass withVariables:(id<ORIntVarArray>)variables;
+(void) stateClassesInit;
@end

@implementation JointState
static NSMutableArray* _stateClasses;
static NSMutableArray* _stateVariables;
static id<ORIntVarArray> _variables;

-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax{
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    _states = [[NSMutableArray alloc] init];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        CustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        CustomState* state = [[[stateClass class] alloc] initRootState:stateClass variableIndex:variableIndex];
        [_states addObject: state];
    }
    return self;
}
-(id) initState:(JointState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assignedValue:edgeValue variableIndex:variableIndex];
    _states = [[NSMutableArray alloc] init];
    NSMutableArray* parentStates = [parentNodeState states];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        CustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        CustomState* state;
        if ([_stateVariables[stateIndex] contains:[_variables at: [parentNodeState variableIndex]]]) {
            state = [[[stateClass class] alloc] initState:[parentStates objectAtIndex:stateIndex] assigningVariable:variableIndex withValue:edgeValue];
        } else {
            state = [[[stateClass class] alloc] initState:[parentStates objectAtIndex:stateIndex] variableIndex:variableIndex];
        }
        [_states addObject: state];
    }
    return self;
}
+(void) addStateClass:(CustomState*)stateClass withVariables:(id<ORIntVarArray>)variables {
    [_stateClasses addObject:stateClass];
    [_stateVariables addObject:variables];
}
+(void) stateClassesInit { _stateClasses = [[NSMutableArray alloc] init]; _stateVariables = [[NSMutableArray alloc] init]; }
+(void) setVariables:(id<ORIntVarArray>)variables { _variables = variables; }

-(NSMutableArray*) states { return _states; }

-(void) mergeStateWith:(JointState*)other {
    NSMutableArray* otherStates = [other states];
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        CustomState* myState = [_states objectAtIndex:stateIndex];
        CustomState* otherState = [otherStates objectAtIndex:stateIndex];
        [myState mergeStateWith:otherState];
    }
}

-(int) numPathsWithNextVariable:(int)variable {
    int count = 0;
    for (int fromValue = _domainMin; fromValue <= _domainMax; fromValue++) {
        if ([self canChooseValue:fromValue forVariable:_variableIndex]) {
            NSArray* savedChanges = [self tempAlterStateAssigningVariable:_variableIndex value:fromValue toTestVariable:variable];
            for (int toValue = _domainMin; toValue <= _domainMax; toValue++) {
                if ([self canChooseValue:toValue forVariable:variable]) {
                    count++;
                }
            }
            [self undoChanges:savedChanges];
        }
    }
    return count;
}

/*-(char*) stateChar {
    char** stateChars = malloc([_states count] * sizeof(char*));
    int size = 0;
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        stateChars[stateIndex] = [[_states objectAtIndex:stateIndex] stateChar];
        size += strlen(stateChars[stateIndex]);
    }
    char* stateChar = malloc(size);
    strcpy(stateChar, stateChars[0]);
    for (int stateIndex = 1; stateIndex < [_states count]; stateIndex++) {
        strcat(stateChar, stateChars[stateIndex]);
    }
    
    return stateChar;
}*/

-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    NSMutableArray* savedChanges = [[NSMutableArray alloc] init];
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        NSArray* stateSavedChanges;
        if ([_stateVariables[stateIndex] contains:[_variables at: variable]]) {
            stateSavedChanges = [[_states objectAtIndex:stateIndex] tempAlterStateAssigningVariable:variable value:value toTestVariable:toVariable];
        } else {
            stateSavedChanges = [[NSArray alloc] init];
        }
        
        [savedChanges addObject:stateSavedChanges];
    }
    return savedChanges;
}

-(void) undoChanges:(NSArray*)savedChanges {
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if ([[savedChanges objectAtIndex:stateIndex] count] > 0) {
            [[_states objectAtIndex: stateIndex] undoChanges: [savedChanges objectAtIndex:stateIndex]];
        }
    }
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if ([_stateVariables[stateIndex] contains:[_variables at: variable]]) {
            if (![[_states objectAtIndex:stateIndex] canChooseValue:value forVariable:variable]) {
                return false;
            }
        }
    }
    return true;
}

-(int) stateDifferential:(JointState*)other {
    int differential = 0;
    NSMutableArray* other_states = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        differential += [[_states objectAtIndex:stateIndex] stateDifferential:[other_states objectAtIndex:stateIndex]];
    }
    return differential;
}
-(bool) equivalentTo:(JointState*)other {
    NSMutableArray* other_states = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if (![[_states objectAtIndex:stateIndex] equivalentTo:[other_states objectAtIndex:stateIndex]]) {
            return false;
        }
    }
    return true;
}
@end


@implementation ORMDDify {
@protected
    id<ORAddToModel> _into;
    id<ORAnnotation> _notes;
    id<ORIntVarArray> _variables;
    
    NSMutableArray* _mddConstraints;
    bool _hasObjective;
    id<ORIntVar> _objectiveVar;
    bool _maximize;
}

-(id)initORMDDify: (id<ORAddToModel>) into
{
    self = [super init];
    _into = into;
    _mddConstraints = [[NSMutableArray alloc] init];
    _variables = (id<ORIntVarArray>)[[ORObject alloc] init];
    _maximize = false;
    _hasObjective = false;
    return self;
}

-(void) apply:(id<ORModel>) m with:(id<ORAnnotation>)notes {
    _notes = notes;
    ORInt width = [_notes findGeneric: DDWidth];
    bool relaxed = [_notes findGeneric: DDRelaxed];
    [JointState stateClassesInit];
    [m applyOnVar: ^(id<ORVar> x) {
        [_into addVariable:x];
    }
       onMutables: ^(id<ORObject> x) {
           [_into addMutable: x];
       }
     onImmutables: ^(id<ORObject> x) {
         [_into addImmutable:x];
     }
     onConstraints: ^(id<ORConstraint> c) {
        [_into setCurrent:c];
         if (true) {
             [c visit: self];
         }  
        [_into setCurrent:nil];
    }
      onObjective: ^(id<ORObjectiveFunction> o) {
          [o visit: self];
      }];
    
    [JointState setVariables:_variables];
    
    id<ORConstraint> mddConstraint;
    if (_hasObjective) {
        mddConstraint = [ORFactory CustomMDDWithObjective:m var:_variables relaxed:relaxed size:width objective: _objectiveVar maximize:_maximize stateClass:[JointState class]];
    } else {
        mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:relaxed size:width stateClass:[JointState class]];
    }
    [_into addConstraint: mddConstraint];
    
    //if ([_mddConstraints count] == 1) {
    //    id<ORConstraint> preMDDConstraint = _mddConstraints[0];
    //
    //    id<ORConstraint> mddConstraint = [ORFactory RelaxedCustomMDD:m var:_variables size: 15 stateClass:[AllDifferentMDDState class]];
    //    [_into addConstraint: mddConstraint];
    //}
}

-(id<ORAddToModel>)target { return _into; }


-(void) visitAlldifferent:(id<ORAlldifferent>)cstr
{
    id<ORIntVarArray> cstrVars = (id<ORIntVarArray>)[cstr array];
    [_mddConstraints addObject: cstr];
    [JointState addStateClass: [[AllDifferentMDDState alloc] initClassState:[cstrVars low] domainMax:[cstrVars up]] withVariables:cstrVars];
    if ([_mddConstraints count] == 1) {
        _variables = cstrVars;
    } else {
        _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars];
    }
    //for (int variableIndex = 1; variableIndex <= [variables count]; variableIndex++) {
    //    id<ORIntVar> variable = (id<ORIntVar>)[variables at: variableIndex];
    //    if (![_variables contains: variable]) {
    //        [_variables setObject:variable atIndexedSubscript:[_variables count]];
    //    }
    //}
}
-(void) visitKnapsack:(id<ORKnapsack>)cstr
{
    id<ORIntVarArray> cstrVars = (id<ORIntVarArray>)[cstr allVars];
    [_mddConstraints addObject: cstr];
    [JointState addStateClass: [[KnapsackBDDState alloc] initClassState:[cstrVars low] domainMax: [cstrVars up] capacity:[cstr capacity] weights:[cstr weight]] withVariables:cstrVars]; //minDomain and maxDomain are poor names as shown here
    //why is capacity a variable for ORKnapsack?
    
    if ([_mddConstraints count] == 1) {
        _variables = cstrVars;
    } else {
        _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars];
    }
}
-(void) visitAmong:(id<ORAmong>)cstr
{
    id<ORIntVarArray> cstrVars = (id<ORIntVarArray>)[cstr array];
    [_mddConstraints addObject:cstr];
    [JointState addStateClass: [[AmongMDDState alloc] initClassState:[cstrVars low] domainMax: [cstrVars up] setValues:[cstr values] lowerBound:[cstr low] upperBound:[cstr up] numVars:[cstrVars count]] withVariables:cstrVars];
    if ([_mddConstraints count] == 1) {
        _variables = cstrVars;
    } else {
        _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars];
    }
}
-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
    [_into minimizeVar:[v var]];
    _objectiveVar = [v var];
    _maximize = false;
    _hasObjective = true;
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
    [_into maximizeVar:[v var]];
    _objectiveVar = [v var];
    _maximize = true;
    _hasObjective = true;
}
@end
