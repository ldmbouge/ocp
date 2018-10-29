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
-(id) initState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax;
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue;
-(char*) stateChar;
-(int) variableIndex;
-(int) domainMin;
-(int) domainMax;
-(void) mergeStateWith:(CustomState*)other;
-(int) numPathsWithNextVariable:(int)variable;
-(bool) canChooseValue:(int)value forVariable:(int)variable;
@end

@implementation CustomState
-(id) initState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax {
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    return self;
}
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {   //Need to check this.  I think it's assigning PARENT's variable to edgeValue, not variableIndex
    return [self initState:variableIndex domainMin:[parentNodeState domainMin] domainMax:[parentNodeState domainMax]];
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
    for (int value = _domainMin; value <= _domainMax; value++) {
        if ([self canChooseValue:value forVariable:variable]) {
            count++;
        }
    }
    return count;
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    return true;
}
@end

@interface AllDifferentMDDState : CustomState {
@protected
    bool* _state;
}
-(bool*) state;
-(int) numPathsWithNextVariable:(int)variable;
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable;
-(void) undoChanges:(NSArray*)savedChanges;
@end

@implementation AllDifferentMDDState
-(id) initState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax{
    self = [super initState:variableIndex domainMin:domainMin domainMax:domainMax];
    _state = malloc((domainMax - domainMin +1) * sizeof(bool));
    _state -= domainMin;
    _stateChar = malloc((domainMax - domainMin +1) * sizeof(char));
    _stateChar -= domainMin;
    for (int stateIndex = domainMin; stateIndex <= domainMax; stateIndex++) {
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

-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    NSArray* savedChanges = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt: value], [NSNumber numberWithBool: _state[value]], nil];
    _state[value] = false;
    return savedChanges;
}

-(void) undoChanges:(NSArray*)savedChanges {
    for (int changeIndex = 0; changeIndex < [savedChanges count]; changeIndex+=2) {
        _state[[savedChanges[changeIndex] integerValue]] = [savedChanges[changeIndex +1] boolValue];
    }
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    return _state[value];
}
@end

@interface JointState : CustomState {
@protected
    NSMutableArray* _states;
}
+(void) addStateClass:(Class)stateClass;
+(void) stateClassesInit;
@end

@implementation JointState
static NSMutableArray* _stateClasses;

-(id) initState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax{
    self = [super initState:variableIndex domainMin:domainMin domainMax:domainMax];
    _states = [[NSMutableArray alloc] init];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        Class stateClass = [_stateClasses objectAtIndex:stateIndex];
        CustomState* state = [[stateClass alloc] initState:variableIndex domainMin:_domainMin domainMax:_domainMax];
        [_states addObject: state];
    }
    return self;
}
-(id) initState:(AllDifferentMDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _states = [[NSMutableArray alloc] init];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        Class stateClass = [_stateClasses objectAtIndex:stateIndex];
        CustomState* state = [[stateClass alloc] initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
        [_states addObject: state];
    }
    return self;
}

+(void) addStateClass:(Class)stateClass { [_stateClasses addObject:stateClass]; }
+(void) stateClassesInit { _stateClasses = [[NSMutableArray alloc] init]; }

-(NSMutableArray*) state { return _states; }

-(void) mergeStateWith:(JointState*)other {
    NSMutableArray* otherStates = [other state];
    
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
    [JointState addStateClass: [AllDifferentMDDState class]];
    if ([_mddConstraints count] == 1) {
        _variables = (id<ORIntVarArray>)[cstr array];
    }
    //for (int variableIndex = 1; variableIndex <= [variables count]; variableIndex++) {
    //    id<ORIntVar> variable = (id<ORIntVar>)[variables at: variableIndex];
    //    if (![_variables contains: variable]) {
    //        [_variables setObject:variable atIndexedSubscript:[_variables count]];
    //    }
    //}
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
