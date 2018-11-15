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


@interface CustomState : NSObject {
@protected
    int _variableIndex;
    char* _stateChar;
    int _domainMin;
    int _domainMax;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax;
-(id) initState:(CustomState*)classState variableIndex:(int)variableIndex;
-(id) initState:(CustomState*)parentNodeState assignedValue:(int)edgeValue variableIndex:(int)variableIndex;
-(char*) stateChar;
-(int) variableIndex;
-(int) domainMin;
-(int) domainMax;
-(void) mergeStateWith:(CustomState*)other;
-(int) numPathsWithNextVariable:(int)variable;
-(NSArray*) tempAlterStateAssigningValue:(int)value withNextVariable:(int)nextVariable;
-(void) undoChanges:(NSArray*)savedChanges;
-(bool) canChooseValue:(int)value forVariable:(int)variable;
@end

@implementation CustomState
-(id) initClassState:(int)domainMin domainMax:(int)domainMax {
    _domainMin = domainMin;
    _domainMax = domainMax;
    return self;
}
-(id) initState:(CustomState*)classState variableIndex:(int)variableIndex {
    _domainMin = [classState domainMin];
    _domainMax = [classState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(id) initState:(CustomState*)parentNodeState assignedValue:(int)edgeValue variableIndex:(int)variableIndex {
    return [self initState:parentNodeState variableIndex:variableIndex];
}

-(char*) stateChar { return _stateChar; }
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
@end

@interface CustomBDDState : CustomState {   //A state with a list of booleans corresponding to whether or not each variable can be assigned 1
@protected
    bool* _state;
}
-(bool*) state;
@end

@implementation CustomBDDState
-(id) initState:(CustomBDDState*)classState variableIndex:(int)variableIndex {
    self = [super initState:classState variableIndex:variableIndex];
    _state = malloc((_domainMax - _domainMin +1) * sizeof(bool));
    _state -= _domainMin;
    _stateChar = malloc((_domainMax - _domainMin +1) * sizeof(char));
    _stateChar -= _domainMin;
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        _state[stateIndex] = true;
        _stateChar[stateIndex] = '1';
    }
    return self;
}
-(id) initState:(CustomBDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {    //Bad naming I think.  Parent is actually the one assigned that value, not the variableIndex
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    bool* parentState = [parentNodeState state];
    char* parentStateChar = [parentNodeState stateChar];
    
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        if (stateIndex == [parentNodeState variableIndex]) {
            _state[stateIndex] = false;
            _stateChar[stateIndex] = '0';
        } else {
            _state[stateIndex] = parentState[stateIndex];
            _stateChar[stateIndex] = parentStateChar[stateIndex];
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

-(id) initState:(KnapsackBDDState*)classState variableIndex:(int)variableIndex {
    self = [super initState:classState variableIndex:variableIndex];
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
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
        for (int digit = 1; digit <= _capacityNumDigits; digit++) {
            _stateChar[_domainMax + 1 + (_capacityNumDigits - digit)] = (char)((int)(_weightSum/pow(10,digit-1)) % 10 + (int)'0');
            
        }
    }
    else {
        _weightSum = [parent weightSum];
        for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex];
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
        for (int digit = 1; digit <= _capacityNumDigits; digit++) {
            _stateChar[_domainMax + digit] = [parent stateChar][_domainMax + digit];
        }
    }
    _state[variable] = false;
    _stateChar[variable] = '0';
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
            _stateChar[variable] = _state[variable] ? '1' : '0';
        }
        for (int digit = 1; digit <= _capacityNumDigits; digit++) {
            _stateChar[_domainMax + digit] = [other stateChar][_domainMax + digit];
        }
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
-(id) initState:(AllDifferentMDDState*)classState variableIndex:(int)variableIndex {
    self = [super initState:classState variableIndex:variableIndex];
    _state = malloc((_domainMax - _domainMin +1) * sizeof(bool));
    _state -= _domainMin;
    _stateChar = malloc((_domainMax - _domainMin +1) * sizeof(char));
    _stateChar -= _domainMin;
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        _state[stateIndex] = true;
        _stateChar[stateIndex] = '1';
    }
    return self;
}
-(id) initState:(AllDifferentMDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    bool* parentState = [parentNodeState state];
    char* parentStateChar = [parentNodeState stateChar];
    
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        if (stateIndex == edgeValue) {
            _state[stateIndex] = false;
            _stateChar[stateIndex] = '0';
        } else {
            _state[stateIndex] = parentState[stateIndex];
            _stateChar[stateIndex] = parentStateChar[stateIndex];
        }
    }
    return self;
}

-(bool*) state { return _state; }

-(void) mergeStateWith:(AllDifferentMDDState*)other {
    bool* otherState = [other state];
    
    for (int stateIndex = _domainMin; stateIndex <= _domainMax; stateIndex++) {
        _state[stateIndex] = _state[stateIndex] || otherState[stateIndex];
        _stateChar[stateIndex] = (_state[stateIndex] ? '1' : '0');
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

-(bool) canChooseValue:(int)value {
    return _state[value];
}
@end

@interface JointState : CustomState {
@protected
    NSMutableArray* _states;
}
+(void) addStateClass:(CustomState*)stateClass;
+(void) stateClassesInit;
@end

@implementation JointState
static NSMutableArray* _stateClasses;

-(id) initState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax{
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    _states = [[NSMutableArray alloc] init];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        CustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        CustomState* state = [[[stateClass class] alloc] initState:stateClass variableIndex:variableIndex];
        [_states addObject: state];
    }
    return self;
}
-(id) initState:(JointState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _states = [[NSMutableArray alloc] init];
    NSMutableArray* parentStates = [parentNodeState states];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        CustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        CustomState* state = [[[stateClass class] alloc] initState:[parentStates objectAtIndex:stateIndex] assigningVariable:variableIndex withValue:edgeValue];
        [_states addObject: state];
    }
    return self;
}

+(void) addStateClass:(CustomState*)stateClass { [_stateClasses addObject:stateClass]; }
+(void) stateClassesInit { _stateClasses = [[NSMutableArray alloc] init]; }

-(NSMutableArray*) states { return _states; }

-(void) mergeStateWith:(JointState*)other {
    NSMutableArray* otherStates = [other states];
    
    for (int stateIndex = 0; stateIndex <= [_states count]; stateIndex++) {
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

-(char*) stateChar {
    char** stateChars = malloc([_states count] * sizeof(char*));
    int size = 0;
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        stateChars[stateIndex] = [[_states objectAtIndex:stateIndex] stateChar];
        size += strlen(stateChars[stateIndex]);
    }
    char* stateChar = malloc(1 + size);
    strcpy(stateChar, stateChars[0]);
    for (int stateIndex = 1; stateIndex < [_states count]; stateIndex++) {
        strcat(stateChar, stateChars[stateIndex]);
    }
    
    return stateChar;
}

-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    NSMutableArray* savedChanges = [[NSMutableArray alloc] init];
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        NSArray* stateSavedChanges = [[_states objectAtIndex:stateIndex] tempAlterStateAssigningVariable:variable value:value toTestVariable:toVariable];
        
        [savedChanges addObject:stateSavedChanges];
    }
    return savedChanges;
}

-(void) undoChanges:(NSArray*)savedChanges {
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [[_states objectAtIndex: stateIndex] undoChanges: [savedChanges objectAtIndex:stateIndex]];
    }
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if (![[_states objectAtIndex:stateIndex] canChooseValue:value forVariable:variable]) {
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
    
    id<ORConstraint> mddConstraint;
    if (_hasObjective) {
        mddConstraint = [ORFactory RelaxedCustomMDDWithObjective:m var:_variables size:15 objective: _objectiveVar maximize:_maximize stateClass:[JointState class]];
    } else {
        mddConstraint = [ORFactory RelaxedCustomMDD:m var:_variables size:15 stateClass:[JointState class]];
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
    [_mddConstraints addObject: cstr];
    [JointState addStateClass: [[AllDifferentMDDState alloc] initClassState:[(id<ORIntVarArray>)[cstr array] low] domainMax:[(id<ORIntVarArray>)[cstr array] up]]];
    if ([_mddConstraints count] == 1) {
        _variables = [ORFactory intVarArray:(id<ORIntVarArray>)[cstr array]];
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
    [_mddConstraints addObject: cstr];
    [JointState addStateClass: [[KnapsackBDDState alloc] initClassState:[(id<ORIntVar>)[cstr allVars] low] domainMax: [(id<ORIntVar>)[cstr allVars] up] capacity:[cstr capacity] weights:[cstr weight]]]; //minDomain and maxDomain are poor names as shown here
    //why is capacity a variable for ORKnapsack?
    
    if ([_mddConstraints count] == 1) {
        _variables = (id<ORIntVarArray>)[cstr allVars]; //MIGHT NOT WORK
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
