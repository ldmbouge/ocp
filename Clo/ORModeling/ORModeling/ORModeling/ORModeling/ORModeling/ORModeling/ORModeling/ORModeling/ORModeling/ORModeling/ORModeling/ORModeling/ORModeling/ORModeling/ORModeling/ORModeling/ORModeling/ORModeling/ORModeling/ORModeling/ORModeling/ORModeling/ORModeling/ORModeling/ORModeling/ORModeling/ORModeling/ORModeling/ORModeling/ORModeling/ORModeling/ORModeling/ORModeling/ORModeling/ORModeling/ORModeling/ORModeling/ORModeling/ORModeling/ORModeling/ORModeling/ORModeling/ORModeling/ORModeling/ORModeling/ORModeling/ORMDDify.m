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
#import "ORMDDVisitors.h"


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

//This does end up creating sub-VarArrays and adding them to the model along the way.  Is this too costly?  Can it be avoided somehow?
+(id<ORIntVarArray>) mergeIntVarArray:(id<ORIntVarArray>)x with:(id<ORIntVarArray>)y tracker:(id<ORTracker>) t {
    NSMutableArray<id<ORIntVar>> *mergedTemp = [[NSMutableArray alloc] init];
    NSMutableArray<id<ORIntVar>> *sortedX = [[NSMutableArray alloc] init];
    NSMutableArray<id<ORIntVar>> *sortedY = [[NSMutableArray alloc] init];
    ORInt size = 0;
    
    if (x == NULL) {
        for (int i = 1; i <= [y count]; i++) {
            [sortedY addObject: y[i]];
        }
        [self sortIntVarArray:sortedY first:0 last:(ORInt)([y count] - 1)];
        size = (ORInt)[y count];
        id<ORIntRange> range = RANGE(t,1,size);
        id<ORIntVarArray> merged = [ORFactory intVarArray:t range:range];
        for (int i = 1; i <= size; i++) {
            [merged setObject:sortedY[i - 1] atIndexedSubscript:i];
        }
        return merged;
    }
    if (y == NULL) {
        for (int i = 1; i <= [x count]; i++) {
            [sortedX addObject: x[i]];
        }
        [self sortIntVarArray:sortedX first:0 last:(ORInt)([x count] - 1)];
        size = (ORInt)[x count];
        id<ORIntRange> range = RANGE(t,1,size);
        id<ORIntVarArray> merged = [ORFactory intVarArray:t range:range];
        for (int i = 1; i <= size; i++) {
            [merged setObject:sortedX[i - 1] atIndexedSubscript:i];
        }
        return merged;
    }
    
    for (int i = 1; i <= [x count]; i++) {
        [sortedX addObject: x[i]];
    }
    for (int i = 1; i <= [y count]; i++) {
        [sortedY addObject: y[i]];
    }
    [self sortIntVarArray:sortedX first:0 last:(ORInt)([x count] - 1)];
    [self sortIntVarArray:sortedY first:0 last:(ORInt)([y count] - 1)];
    
    ORInt xIndex = 0, yIndex = 0;
    
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
    id<ORIntRange> range = RANGE(t,1,size);
    id<ORIntVarArray> merged = [ORFactory intVarArray:t range:range];
    for (int i = 1; i <= size; i++) {
        [merged setObject:mergedTemp[i - 1] atIndexedSubscript:i];
    }
    return merged;
}
@end

@implementation AltCustomState : NSObject
-(id) initClassState:(int)domainMin domainMax:(int)domainMax {
    _domainMin = domainMin;
    _domainMax = domainMax;
    return self;
}
-(id) initRootState:(AltCustomState*)classState variableIndex:(int)variableIndex {
    _domainMin = [classState domainMin];
    _domainMax = [classState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax {
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    return self;
}
-(id) initState:(AltCustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    _domainMin = [parentNodeState domainMin];
    _domainMax = [parentNodeState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(id) initState:(AltCustomState*)parentNodeState variableIndex:(int)variableIndex {
    _domainMin = [parentNodeState domainMin];
    _domainMax = [parentNodeState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(void) setTopDownInfoFor:(AltCustomState*)parentInfo plusEdge:(int)edgeValue
{
    return;
}
-(void) setBottomUpInfoFor:(AltCustomState*)childInfo plusEdge:(int)edgeValue
{
    return;
}
-(void) mergeTopDownInfoWith:(AltCustomState*)other
{
    return;
}
-(void) mergeBottomUpInfoWith:(AltCustomState*)other
{
    return;
}
-(bool) canDeleteChild:(AltCustomState*)child atEdgeValue:(int)edgeValue
{
    return false;
}
-(bool) equivalentWithEdge:(int)edgeValue to:(AltCustomState*)other withEdge:(int)otherEdgeValue
{
    return true;
}
-(id) initSinkState:(AltCustomState *)classState {
    _domainMin = [classState domainMin];
    _domainMax = [classState domainMax];
    return self;
}
-(int) variableIndex { return _variableIndex; }
-(int) domainMin { return _domainMin; }
-(int) domainMax { return _domainMax; }
+(void) setAsOnlyMDDWithClassState:(AltCustomState*)classState
{
    return;
}
@end

@implementation CustomState
-(id) initClassState:(int)domainMin domainMax:(int)domainMax {
    _domainMin = domainMin;
    _domainMax = domainMax;
    return self;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax {
    _variableIndex = variableIndex;
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
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
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

+(void) setAsOnlyMDDWithClassState:(CustomState*)classState
{
    return;
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
    /*
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
     */
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

@implementation MDDStateSpecification
static int* StateValues;
static DDClosure ArcExists;
static DDClosure* TransitionFunctions;
static DDMergeClosure* RelaxationFunctions;
static DDMergeClosure* DifferentialFunctions;
static int StateSize;

-(id) initClassState:(int)domainMin domainMax:(int)domainMax state:(int*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions stateSize:(int)stateSize;
{
    [super initClassState:domainMin domainMax:domainMax];
    _state = stateValues;
    _arcExists = arcExists;
    _transitionFunctions = transitionFunctions;
    _stateSize = stateSize;
    return self;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax state:(int*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions stateSize:(int)stateSize;
{
    [super initClassState:domainMin domainMax:domainMax];
    _state = stateValues;
    _arcExists = arcExists;
    _transitionFunctions = transitionFunctions;
    _relaxationFunctions = relaxationFunctions;
    _stateSize = stateSize;
    return self;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax state:(int*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions stateSize:(int)stateSize;
{
    [super initClassState:domainMin domainMax:domainMax];
    _state = stateValues;
    _arcExists = arcExists;
    _transitionFunctions = transitionFunctions;
    _relaxationFunctions = relaxationFunctions;
    _differentialFunctions = differentialFunctions;
    _stateSize = stateSize;
    return self;
}

-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax{
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    _stateSize = StateSize;
    _state = StateValues;
    _arcExists = ArcExists;
    _transitionFunctions = TransitionFunctions;
    _relaxationFunctions = RelaxationFunctions;
    _differentialFunctions = DifferentialFunctions;
    return self;
}
-(id) initRootState:(MDDStateSpecification*)classState variableIndex:(int)variableIndex {
    self = [super initRootState:classState variableIndex:variableIndex];
    _stateSize = [classState stateSize];
    _state = [classState state];
    _arcExists = [classState arcExistsClosure];
    _transitionFunctions = [classState transitionFunctions];
    _relaxationFunctions = [classState relaxationFunctions];
    _differentialFunctions = [classState differentialFunctions];
    return self;
}

-(id) initState:(MDDStateSpecification*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _stateSize = [parentNodeState stateSize];
    int* parentState = [parentNodeState state];
    ORInt parentVar = [parentNodeState variableIndex];
    
    _state = malloc(_stateSize * sizeof(int));
    _arcExists = [parentNodeState arcExistsClosure];
    _transitionFunctions = [parentNodeState transitionFunctions];
    _relaxationFunctions = [parentNodeState relaxationFunctions];
    _differentialFunctions = [parentNodeState differentialFunctions];
    
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        DDClosure transitionFunction = _transitionFunctions[stateIndex];
        if (transitionFunction != NULL) {
            _state[stateIndex] = transitionFunction(parentState, parentVar, edgeValue);
        }
    }
    return self;
}
-(id) initState:(MDDStateSpecification*)parentNodeState variableIndex:(int)variableIndex {
    self = [super initState:parentNodeState variableIndex:variableIndex];
    int* parentState = [parentNodeState state];
    _stateSize = [parentNodeState stateSize];
    _state = malloc(_stateSize * sizeof(int));
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        _state[stateIndex] = parentState[stateIndex];
    }
    
    _arcExists = [parentNodeState arcExistsClosure];
    _transitionFunctions = [parentNodeState transitionFunctions];
    _relaxationFunctions = [parentNodeState relaxationFunctions];
    _differentialFunctions = [parentNodeState differentialFunctions];
    return self;
}

+(void) setAsOnlyMDDWithClassState:(MDDStateSpecification*)classState
{
    StateValues = [classState state];
    ArcExists = [classState arcExistsClosure];
    TransitionFunctions = [classState transitionFunctions];
    RelaxationFunctions = [classState relaxationFunctions];
    DifferentialFunctions = [classState differentialFunctions];
    StateSize = [classState stateSize];
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    return _arcExists(_state, variable, value);
}
-(void) mergeStateWith:(MDDStateSpecification*)other {
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        DDMergeClosure relaxationFunction = _relaxationFunctions[stateIndex];
        if (relaxationFunction != NULL) {
            _state[stateIndex] = relaxationFunction(_state, [other state]);
        }
    }
}

-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    NSMutableArray* savedChanges = [[NSMutableArray alloc] init];
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        DDClosure transitionFunction = _transitionFunctions[stateIndex];
        [savedChanges addObject: [[NSNumber alloc] initWithInt: _state[stateIndex]]];
        if (transitionFunction != NULL) {
            _state[stateIndex] = transitionFunction(_state,variable,value);
        }
    }
    return savedChanges;
}

-(void) undoChanges:(NSArray*)savedChanges {
    for (int savedChangeIndex = 0; savedChangeIndex < [savedChanges count]; savedChangeIndex++) {
        _state[savedChangeIndex] = [[savedChanges objectAtIndex: savedChangeIndex] intValue];
    }
}

-(int) stateDifferential:(MDDStateSpecification*)other {
    int differential = 0;
    int* other_state = [other state];
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        /*if (_differentialFunctions[stateIndex] != NULL) {
            differential += _differentialFunctions[stateIndex](_state,other_state);
        }*/
        
        //differential += pow(_state[stateIndex] - other_state[stateIndex],2);
        if (_state[stateIndex] != other_state[stateIndex]) {
            differential++;
        }
    }
    return differential;
}
-(bool) equivalentTo:(MDDStateSpecification*)other {
    int* other_state = [other state];
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        if (_state[stateIndex] != other_state[stateIndex]) {
            return false;
        }
    }
    return true;
}


-(int*) state { return _state; }
-(int) stateSize { return _stateSize; }
-(DDClosure)arcExistsClosure { return _arcExists; }
-(DDClosure*)transitionFunctions { return _transitionFunctions; }
-(DDMergeClosure*)relaxationFunctions { return _relaxationFunctions; }
-(DDMergeClosure*)differentialFunctions { return _differentialFunctions; }
@end

@implementation AltMDDStateSpecification
static id TopDownInfo;
static id BottomUpInfo;
static AltMDDAddEdgeClosure TopDownEdgeAddition;
static AltMDDAddEdgeClosure BottomUpEdgeAddition;
static AltMDDMergeInfoClosure TopDownMerge;
static AltMDDMergeInfoClosure BottomUpMerge;
static AltMDDDeleteEdgeCheckClosure EdgeDeletionCheck;

-(id) initClassState:(int)domainMin domainMax:(int)domainMax topDownInfo:(id)topDownInfo bottomUpInfo:(id)bottomUpInfo topDownEdgeAddition:(AltMDDAddEdgeClosure)topDownInfoEdgeAdditionClosure bottomUpEdgeAddition:(AltMDDAddEdgeClosure)bottomUpInfoEdgeAdditionClosure topDownMerge:(AltMDDMergeInfoClosure)topDownMergeClosure bottomUpMerge:(AltMDDMergeInfoClosure)bottomUpMergeClosure edgeDeletion:(AltMDDDeleteEdgeCheckClosure)edgeDeletionClosure
{
    [super initClassState:domainMin domainMax:domainMax];
    _topDownInfo = topDownInfo;
    _bottomUpInfo = bottomUpInfo;
    _topDownEdgeAddition = topDownInfoEdgeAdditionClosure;
    _bottomUpEdgeAddition = bottomUpInfoEdgeAdditionClosure;
    _topDownMerge = topDownMergeClosure;
    _bottomUpMerge = bottomUpMergeClosure;
    _edgeDeletionCheck = edgeDeletionClosure;
    return self;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax{
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    _topDownInfo = TopDownInfo;
    _bottomUpInfo = NULL;
    _topDownEdgeAddition = TopDownEdgeAddition;
    _bottomUpEdgeAddition = BottomUpEdgeAddition;
    _topDownMerge = TopDownMerge;
    _bottomUpMerge = BottomUpMerge;
    _edgeDeletionCheck = EdgeDeletionCheck;
    return self;
}
-(id) initRootState:(AltMDDStateSpecification*)classState variableIndex:(int)variableIndex {
    self = [super initRootState:classState variableIndex:variableIndex];
    _topDownInfo = [classState topDownInfo];
    _bottomUpInfo = [classState bottomUpInfo];
    _topDownEdgeAddition = [classState topDownEdgeAddition];
    _bottomUpEdgeAddition = [classState bottomUpEdgeAddition];
    _topDownMerge = [classState topDownMerge];
    _bottomUpMerge = [classState bottomUpMerge];
    _edgeDeletionCheck = [classState edgeDeletionCheck];
    return self;
}
-(id) initSinkState:(AltMDDStateSpecification*)classState {
    _bottomUpInfo = [classState bottomUpInfo];
    _topDownEdgeAddition = [classState topDownEdgeAddition];
    _bottomUpEdgeAddition = [classState bottomUpEdgeAddition];
    _topDownMerge = [classState topDownMerge];
    _bottomUpMerge = [classState bottomUpMerge];
    _edgeDeletionCheck = [classState edgeDeletionCheck];
    return self;
}
//Going to need to evaluate how this will be built.  Is the RootState creation any different than another state?  Not really.  All of them should be made the same way, but then just call functions that calculate and set the topDownInfo and bottomUpInfo sequentially through the tree.
+(void) setAsOnlyMDDWithClassState:(AltMDDStateSpecification*)classState
{
    TopDownInfo = [classState topDownInfo];
    BottomUpInfo = [classState bottomUpInfo];
    TopDownEdgeAddition = [classState topDownEdgeAddition];
    BottomUpEdgeAddition = [classState bottomUpEdgeAddition];
    TopDownMerge = [classState topDownMerge];
    BottomUpMerge = [classState bottomUpMerge];
    EdgeDeletionCheck = [classState edgeDeletionCheck];
}
-(void) setTopDownInfoFor:(AltMDDStateSpecification*)parentInfo plusEdge:(int)edgeValue {
    _topDownInfo = _topDownEdgeAddition([parentInfo topDownInfo], _variableIndex, edgeValue);
}
-(void) setBottomUpInfoFor:(AltMDDStateSpecification*)childInfo plusEdge:(int)edgeValue {
    _bottomUpInfo = _bottomUpEdgeAddition([childInfo bottomUpInfo], _variableIndex, edgeValue);
}
-(void) mergeTopDownInfoWith:(AltMDDStateSpecification*)other
{
    _topDownInfo = _topDownMerge(_topDownInfo,[other topDownInfo],_variableIndex);
}
-(void) mergeBottomUpInfoWith:(AltMDDStateSpecification*)other
{
    _bottomUpInfo = _bottomUpMerge(_bottomUpInfo,[other bottomUpInfo],_variableIndex);
}
-(bool) canDeleteChild:(AltMDDStateSpecification*)child atEdgeValue:(int)edgeValue
{
    return _edgeDeletionCheck(_topDownInfo, [child bottomUpInfo], _variableIndex, edgeValue);
}
-(bool) equivalentWithEdge:(int)edgeValue to:(AltMDDStateSpecification*)other withEdge:(int)otherEdgeValue
{
    id selfInfo = _topDownEdgeAddition(_topDownInfo, _variableIndex, edgeValue);
    id otherInfo = _topDownEdgeAddition([other topDownInfo], _variableIndex, otherEdgeValue);
    if ([selfInfo class] == [NSMutableArray class]) {
        return [selfInfo isEqualToArray:otherInfo];
    } else {
        return selfInfo == otherInfo;
    }
}
-(id) topDownInfo { return _topDownInfo; }
-(id) bottomUpInfo { return _bottomUpInfo; }
-(AltMDDAddEdgeClosure) topDownEdgeAddition { return _topDownEdgeAddition; }
-(AltMDDAddEdgeClosure) bottomUpEdgeAddition { return _bottomUpEdgeAddition; }
-(AltMDDMergeInfoClosure) topDownMerge { return _topDownMerge; }
-(AltMDDMergeInfoClosure) bottomUpMerge { return _bottomUpMerge; }
-(AltMDDDeleteEdgeCheckClosure) edgeDeletionCheck { return _edgeDeletionCheck; }
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
//    _upperBoundNumDigits = [parentNodeState numDigits];
    _set = [parentNodeState set];
//    _stateChar = malloc((_upperBoundNumDigits) * sizeof(char));
    
//    for (int digitIndex = 0; digitIndex < _upperBoundNumDigits; digitIndex++) {
//        _stateChar[digitIndex] = parentStateChar[digitIndex];
//    }
    _numVarsRemaining = [parentNodeState numVarsRemaining];
    return self;
}


+(void) setAsOnlyMDDWithClassState:(AmongMDDState*)classState
{
    MinState = [classState minState];
    MaxState = [classState maxState];
    LowerBound = [classState lowerBound];
    UpperBound = [classState upperBound];
    Set = [classState set];
    NumVarsRemaining = [classState numVarsRemaining];
    
    return;
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

@implementation AltJointState
static NSMutableArray* _stateClasses;
static NSMutableArray* _stateVariables;
static id<ORIntVarArray> _variables;

-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax{
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        AltCustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        AltCustomState* state = [[[stateClass class] alloc] initRootState:stateClass variableIndex:variableIndex];
        [_states addObject: state];
    }
    return self;
}
-(id) initState:(AltJointState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _states = [[NSMutableArray alloc] init];
    NSMutableArray* parentStates = [parentNodeState states];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        AltCustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        AltCustomState* state;
        if ([(id<ORIdArray>)(_stateVariables[stateIndex]) contains:[_variables at: [parentNodeState variableIndex]]]) {
            state = [[[stateClass class] alloc] initState:[parentStates objectAtIndex:stateIndex] assigningVariable:variableIndex withValue:edgeValue];
        } else {
            state = [[[stateClass class] alloc] initState:[parentStates objectAtIndex:stateIndex] variableIndex:variableIndex];
        }
        [_states addObject: state];
    }
    return self;
}
-(id) initSinkState:(int)domainMin domainMax:(int)domainMax {
    _domainMin = domainMin;
    _domainMax = domainMax;
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        AltCustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        AltCustomState* state = [[[stateClass class] alloc] initSinkState:stateClass];
        [_states addObject: state];
    }
    return self;
}
+(void) addStateClass:(AltCustomState*)stateClass withVariables:(id<ORIntVarArray>)variables {
    [_stateClasses addObject:stateClass];
    [_stateVariables addObject:variables];
}
-(void) setTopDownInfoFor:(AltJointState*)parentInfo plusEdge:(int)edgeValue
{
    NSArray* parentStates = [parentInfo states];
    for (int stateIndex = 0; stateIndex < [parentStates count]; stateIndex++) {
        [[_states objectAtIndex:stateIndex] setTopDownInfoFor:[parentStates objectAtIndex: stateIndex] plusEdge:edgeValue];
    }
}
-(void) setBottomUpInfoFor:(AltJointState*)childInfo plusEdge:(int)edgeValue
{
    NSArray* parentStates = [childInfo states];
    for (int stateIndex = 0; stateIndex < [parentStates count]; stateIndex++) {
        [[_states objectAtIndex:stateIndex] setBottomUpInfoFor:[parentStates objectAtIndex: stateIndex] plusEdge:edgeValue];
    }
}
-(void) mergeTopDownInfoWith:(AltJointState*)other
{
    NSArray* otherStates = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [[_states objectAtIndex:stateIndex] mergeTopDownInfoWith:[otherStates objectAtIndex:stateIndex]];
    }
}
-(void) mergeBottomUpInfoWith:(AltJointState*)other
{
    NSArray* otherStates = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [[_states objectAtIndex:stateIndex] mergeBottomUpInfoWith:[otherStates objectAtIndex:stateIndex]];
    }
}
-(bool) canDeleteChild:(AltJointState*)child atEdgeValue:(int)edgeValue
{
    NSArray* childStates = [child states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if ([[_states objectAtIndex: stateIndex] canDeleteChild:[childStates objectAtIndex:stateIndex] atEdgeValue:edgeValue]) {
            return true;
        }
    }
    return false;
}
-(bool) equivalentWithEdge:(int)edgeValue to:(AltJointState*)other withEdge:(int)otherEdgeValue
{
    NSArray* otherStates = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if (![[_states objectAtIndex: stateIndex] equivalentWithEdge:edgeValue to:[otherStates objectAtIndex:stateIndex] withEdge:otherEdgeValue]) {
            return false;
        }
    }
    return true;
}
+(AltCustomState*) firstState { return [_stateClasses firstObject]; }
+(int) numStates { return (int)[_stateClasses count]; }
+(void) stateClassesInit { _stateClasses = [[NSMutableArray alloc] init]; _stateVariables = [[NSMutableArray alloc] init]; }
+(void) setVariables:(id<ORIntVarArray>)variables { _variables = variables; }

-(NSMutableArray*) states { return _states; }

-(bool) equivalentTo:(AltJointState*)other {
    NSMutableArray* other_states = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if (![[_states objectAtIndex:stateIndex] equivalentTo:[other_states objectAtIndex:stateIndex]]) {
            return false;
        }
    }
    return true;
}
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
    self = [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    _states = [[NSMutableArray alloc] init];
    NSMutableArray* parentStates = [parentNodeState states];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        CustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        CustomState* state;
        if ([(id<ORIdArray>)(_stateVariables[stateIndex]) contains:[_variables at: [parentNodeState variableIndex]]]) {
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
+(CustomState*) firstState { return [_stateClasses firstObject]; }
+(int) numStates { return (int)[_stateClasses count]; }
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
    /*for (int fromValue = _domainMin; fromValue <= _domainMax; fromValue++) {
        if ([self canChooseValue:fromValue forVariable:_variableIndex]) {
            NSArray* savedChanges = [self tempAlterStateAssigningVariable:_variableIndex value:fromValue toTestVariable:variable];
            for (int toValue = _domainMin; toValue <= _domainMax; toValue++) {
                if ([self canChooseValue:toValue forVariable:variable]) {
                    count++;
                }
            }
            [self undoChanges:savedChanges];
        }
    }*/
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
        if ([(id<ORIdArray>)_stateVariables[stateIndex] contains:[_variables at: variable]]) {
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
        if ([(id<ORIdArray>)_stateVariables[stateIndex] contains:[_variables at: variable]]) {
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
    bool _relaxed;
    
    NSMutableArray* _mddSpecConstraints;
}

-(id)initORMDDify: (id<ORAddToModel>) into
{
    self = [super init];
    _into = into;
    _mddConstraints = [[NSMutableArray alloc] init];
    _mddSpecConstraints = [[NSMutableArray alloc] init];
    _variables = NULL;
    _maximize = false;
    _hasObjective = false;
    return self;
}

-(void) apply:(id<ORModel>) m with:(id<ORAnnotation>)notes {
    _notes = notes;
    ORInt width = [_notes findGeneric: DDWidth];
    _relaxed = [_notes findGeneric: DDRelaxed];
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
        if (true) { //Should check if c is MDDifiable.  aka if it has a visit function down below
        [c visit: self];
        }
        [_into setCurrent:nil];
    }
      onObjective: ^(id<ORObjectiveFunction> o) {
          [o visit: self];
      }];
    
    if ([_mddSpecConstraints count] > 0) {
        [self combineMDDSpecs];
    }
    
    id<ORConstraint> mddConstraint;
    
    if ([AltJointState numStates] > 0) {
        [AltJointState setVariables:_variables];
        //if ([AltJointState numStates] > 1) {
            mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:_relaxed size:width stateClass:[AltJointState class]];
        //} else {
        //    CustomState* onlyState = [JointState firstState];
        //    [[onlyState class] setAsOnlyMDDWithClassState: onlyState];
        //    mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:_relaxed size:width stateClass:[onlyState class]];
        //}
    } else {
        [JointState setVariables:_variables];
        
        if (_hasObjective) {
            mddConstraint = [ORFactory CustomMDDWithObjective:m var:_variables relaxed:_relaxed size:width objective: _objectiveVar maximize:_maximize stateClass:[JointState class]];
        } else {
            if ([JointState numStates] > 1) {
                mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:_relaxed size:width stateClass:[JointState class]];
            } else {
                CustomState* onlyState = [JointState firstState];
                [[onlyState class] setAsOnlyMDDWithClassState: onlyState];
                mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:_relaxed size:width stateClass:[onlyState class]];
            }
        }
    }
    
    [_into trackConstraintInGroup: mddConstraint];
    [_into addConstraint: mddConstraint];
    
    //if ([_mddConstraints count] == 1) {
    //    id<ORConstraint> preMDDConstraint = _mddConstraints[0];
    //
    //    id<ORConstraint> mddConstraint = [ORFactory RelaxedCustomMDD:m var:_variables size: 15 stateClass:[AllDifferentMDDState class]];
    //    [_into addConstraint: mddConstraint];
    //}
}

-(id<ORAddToModel>)target { return _into; }

-(NSDictionary*) checkForStateEquivalences:(id<ORMDDSpecs>)mergeInto and:(id<ORMDDSpecs>)other {
    NSMutableDictionary* mappings = [[NSMutableDictionary alloc] init];
    int stateSize1 = [mergeInto stateSize];
    int stateSize2 = [other stateSize];
    ORDDExpressionEquivalenceChecker* equivalenceChecker = [[ORDDExpressionEquivalenceChecker alloc] init];
    
    int** candidates = malloc(stateSize1 * sizeof(int*));
    for (int i = 0; i < stateSize1; i++) {
        candidates[i] = malloc(stateSize2 * sizeof(int));
        for (int j = 0; j < stateSize2; j++) {
            candidates[i][j] = true;
        }
    }
    
    for (int i = 0; i < stateSize1; i++) {
        for (int j = 0; j < stateSize2; j++) {
            if (candidates[i][j]) {
                NSMutableDictionary* dependentMappings = [[NSMutableDictionary alloc] init];
                if ([self areEquivalent:mergeInto atIndex:i and:other atIndex:j withDependentMapping:dependentMappings andConfirmedMapping:mappings equivalenceVisitor:equivalenceChecker candidates:candidates]) {
                    [mappings addEntriesFromDictionary:dependentMappings];
                    NSArray* keys = [dependentMappings allKeys];
                    for (NSNumber* key in keys) {
                        int otherIndex = [key intValue];
                        int mergeIntoIndex = [[dependentMappings objectForKey:key] intValue];
                        for (int index = i; index < stateSize1; index++) {
                            candidates[index][otherIndex] = false;
                        }
                        for (int index = j; index < stateSize2; index++) {
                            candidates[mergeIntoIndex][index] = false;
                        }
                    }
                } else {
                    candidates[i][j] = false;
                }
            }
        }
    }
    
    return mappings;
}

-(bool) areEquivalent:(id<ORMDDSpecs>)mergeInto atIndex:(int)index1 and:(id<ORMDDSpecs>)other atIndex:(int)index2 withDependentMapping:(NSMutableDictionary*)dependentMappings andConfirmedMapping:(NSMutableDictionary*)confirmedMappings equivalenceVisitor:(ORDDExpressionEquivalenceChecker*)equivalenceChecker candidates:(int**)candidates
{
    if ([mergeInto stateValues][index1] != [other stateValues][index2]) {   //Different initial value
        candidates[index1][index2] = false;
        return false;
    }
    
    id<ORExpr> mergeIntoTransitionFunction = [mergeInto transitionFunctions][index1];
    id<ORExpr> otherTransitionFunction = [other transitionFunctions][index2];
    NSMutableArray* dependencies = [equivalenceChecker checkEquivalence: mergeIntoTransitionFunction and:otherTransitionFunction];
    id<ORExpr> mergeIntoRelaxationFunction = [mergeInto relaxationFunctions][index1];
    id<ORExpr> otherRelaxationFunction = [other relaxationFunctions][index2];
    NSArray* relaxationDependencies = [equivalenceChecker checkEquivalence:mergeIntoRelaxationFunction and:otherRelaxationFunction];
    id<ORExpr> mergeIntoDifferentialFunction = [mergeInto differentialFunctions][index1];
    id<ORExpr> otherDifferentialFunction = [other differentialFunctions][index2];
    NSArray* differentialDependencies = [equivalenceChecker checkEquivalence:mergeIntoDifferentialFunction and:otherDifferentialFunction];
    [dependencies addObjectsFromArray:relaxationDependencies];
    [dependencies addObjectsFromArray:differentialDependencies];
    if (dependencies == NULL) { //Transition, relaxation, or differential function is different
        candidates[index1][index2] = false;
        return false;
    }
    [dependentMappings setObject:[[NSNumber alloc] initWithInt:index1] forKey:[[NSNumber alloc] initWithInt:index2]];
    for (id dependency in dependencies) {
        int mergeIntoDependency = [dependency[0] intValue];
        NSNumber* mergeIntoDependencyObj = [[NSNumber alloc] initWithInt: mergeIntoDependency];
        int otherDependency = [dependency[1] intValue];
        NSNumber* otherDependencyObj = [[NSNumber alloc] initWithInt: otherDependency];
        if (!([confirmedMappings objectForKey:otherDependencyObj] == mergeIntoDependencyObj ||
              [dependentMappings objectForKey:otherDependencyObj] == mergeIntoDependencyObj)) {
            //Not already a found mapping
            if (!candidates[mergeIntoDependency][otherDependency]) {
                //If already confirmed to not be a mapping
                return false;
            }
            
            if (![self areEquivalent:mergeInto atIndex:mergeIntoDependency and:other atIndex:otherDependency withDependentMapping:dependentMappings andConfirmedMapping:confirmedMappings equivalenceVisitor:equivalenceChecker candidates:candidates]) {
                return false;
            }
        }
    }
    return true;
}

-(void) combineMDDSpecs
{
    NSMutableArray* mainMDDSpecList = [[NSMutableArray alloc] initWithObjects:[_mddSpecConstraints objectAtIndex:0],nil];

    
    for (int mddSpecIndex = 1; mddSpecIndex < [_mddSpecConstraints count]; mddSpecIndex++) {
        id<ORMDDSpecs> mddSpec = [_mddSpecConstraints objectAtIndex:mddSpecIndex];
        
        bool sharedVarList = false;
        for (id<ORMDDSpecs> mainMDDSpec in mainMDDSpecList) {
            if ([mainMDDSpec vars] == [mddSpec vars]) {
                sharedVarList = true;
                int mainStateSize = [mainMDDSpec stateSize];
                
                int* stateValues = [mddSpec stateValues];
                int stateSize = [mddSpec stateSize];
                id<ORExpr>* transitionFunctions = [mddSpec transitionFunctions];
                id<ORExpr>* relaxationFunctions = [mddSpec relaxationFunctions];
                id<ORExpr>* differentialFunctions = [mddSpec differentialFunctions];
                
                NSDictionary* mergeMappings = [self checkForStateEquivalences:mainMDDSpec and:mddSpec];
                
                int numShared = (int)[mergeMappings count];
                int numToAdd = stateSize - numShared;
                int* separateStatesToAdd = malloc(numToAdd * sizeof(int));
                int* indicesToAdd = malloc(numToAdd * sizeof(int));
                
                NSMutableDictionary* totalMapping = [[NSMutableDictionary alloc] init];
                int newStateCount = 0;
                for (int index = 0; index < stateSize; index++) {
                    NSNumber* mergeMappingValue =[mergeMappings objectForKey:[[NSNumber alloc] initWithInt:index]];
                    if (mergeMappingValue == nil) {
                        [totalMapping setObject:[[NSNumber alloc] initWithInt: (newStateCount+mainStateSize)] forKey:[[NSNumber alloc] initWithInt: index]];
                        separateStatesToAdd[newStateCount] = stateValues[index];
                        indicesToAdd[newStateCount] = index;
                        newStateCount++;
                    }
                }
                [totalMapping addEntriesFromDictionary:mergeMappings];
                
                [mainMDDSpec addStates:separateStatesToAdd size:numToAdd];
                
                ORDDUpdateSpecs* updateFunctions = [[ORDDUpdateSpecs alloc] initORDDUpdateSpecs:totalMapping];
                
                for (int i = 0; i < numToAdd; i++) {
                    int index = indicesToAdd[i];
                    
                    [updateFunctions updateSpecs:transitionFunctions[index]];
                    [mainMDDSpec addTransitionFunction:transitionFunctions[index] toStateValue:(mainStateSize+i)];
                    
                    [updateFunctions updateSpecs:differentialFunctions[index]];
                    [mainMDDSpec addStateDifferentialFunction:differentialFunctions[index] toStateValue:(mainStateSize+i)];
                }
                if (_relaxed) {
                    for  (int i = 0; i < numToAdd; i++) {
                        int index = indicesToAdd[i];
                    
                        [updateFunctions updateSpecs:relaxationFunctions[index]];
                        [mainMDDSpec addRelaxationFunction:relaxationFunctions[index] toStateValue:(mainStateSize+i)];
                    }
                }
                id<ORExpr> oldArcExists = [mainMDDSpec arcExists];
                id<ORExpr> arcExists = [mddSpec arcExists];
                [updateFunctions updateSpecs:arcExists];
                id<ORExpr> newArcExists = [oldArcExists land:arcExists];
                [mainMDDSpec setArcExistsFunction:newArcExists];
                
                break;
                /*
                NSMutableDictionary* mergeMapping = [[NSMutableDictionary alloc] init];
                for (int mainStateIndex = 0; mainStateIndex < mainStateSize; mainStateIndex++) {
                    for (int stateIndex = 0; stateIndex < stateSize; stateIndex++) {
                        if (mainStateValues[mainStateIndex] == stateValues[stateIndex]) {   //Same initial value
                            NSArray* dependencies = [equivalenceChecker checkEquivalence: mainTransitionFunctions[mainStateIndex] and:transitionFunctions[stateIndex]];
                            if (dependencies != NULL) {
                                if ([dependencies count] == 0) {
                                    [mergeMapping setObject:[[NSNumber alloc] initWithInt:mainStateIndex] forKey:[[NSNumber alloc] initWithInt:stateIndex]];
                                } else {
                                    bool dependenciesAreValid = true;
                                    for (id dependency in dependencies) {
                                        int mainStateValue = [dependency[0] intValue];
                                        int stateValue = [dependency[1] intValue];
                                        if (mainStateValue < mainStateIndex || (mainStateValue == mainStateIndex && stateValue < stateIndex)) {
                                            //If we've already checked this potential mapping
                                            if ([mergeMapping objectForKey:dependency[1]] != dependency[0]) {
                                                //Mapping has been found to not hold
                                                dependenciesAreValid = false;
                                                break;
                                            }
                                        } else if (mainStateValue != mainStateIndex || stateValue != stateIndex) {
                                            //Is not one already checked and isn't just itself
                                            
                                            
                                        }
                                    }
                                    if (dependenciesAreValid) {
                                        [mergeMapping setObject:[[NSNumber alloc] initWithInt:mainStateIndex] forKey:[[NSNumber alloc] initWithInt: stateIndex]];
                                    }
                                }
                            }
                        }
                    }
                }*/
            }
        }
        if (!sharedVarList) {
            [mainMDDSpecList addObject:mddSpec];
        }
    }
    
    ORDDClosureGenerator *closureVisitor = [[ORDDClosureGenerator alloc] init];
    ORDDMergeClosureGenerator *mergeClosureVisitor = [[ORDDMergeClosureGenerator alloc] init];
    for (id<ORMDDSpecs> mddSpec in mainMDDSpecList) {
        id<ORIntVarArray> vars = [mddSpec vars];
        id<ORExpr> arcExists = [mddSpec arcExists];
        DDClosure arcExistsClosure = [closureVisitor computeClosure:arcExists];
        int* stateValues = [mddSpec stateValues];
        id<ORExpr>* transitionFunctions = [mddSpec transitionFunctions];
        id<ORExpr>* relaxationFunctions = [mddSpec relaxationFunctions];
        id<ORExpr>* differentialFunctions = [mddSpec differentialFunctions];
        int stateSize = [mddSpec stateSize];
        DDClosure* transitionFunctionClosures = malloc(stateSize * sizeof(DDClosure));
        DDMergeClosure* differentialFunctionClosures = malloc(stateSize * sizeof(DDMergeClosure));
        for (int transitionFunctionIndex = 0; transitionFunctionIndex < stateSize; transitionFunctionIndex++) {
            transitionFunctionClosures[transitionFunctionIndex] = [closureVisitor computeClosure: transitionFunctions[transitionFunctionIndex]];
            differentialFunctionClosures[transitionFunctionIndex] = [mergeClosureVisitor computeClosure: differentialFunctions[transitionFunctionIndex]];
        }
        
        if (_relaxed) {
            DDMergeClosure* relaxationFunctionClosures = malloc(stateSize * sizeof(DDMergeClosure));
            for (int relaxationFunctionIndex = 0; relaxationFunctionIndex < stateSize; relaxationFunctionIndex++) {
                relaxationFunctionClosures[relaxationFunctionIndex] = [mergeClosureVisitor computeClosure: relaxationFunctions[relaxationFunctionIndex]];
            }
            [JointState addStateClass: [[MDDStateSpecification alloc] initClassState:[vars low] domainMax:[vars up] state:stateValues arcExists:arcExistsClosure transitionFunctions:transitionFunctionClosures relaxationFunctions:relaxationFunctionClosures differentialFunctions:differentialFunctionClosures stateSize:stateSize] withVariables:vars];
        } else {
            [JointState addStateClass:[[MDDStateSpecification alloc] initClassState:[vars low] domainMax:[vars up] state:stateValues arcExists:arcExistsClosure transitionFunctions:transitionFunctionClosures stateSize:stateSize] withVariables:vars];
        }
        if ([_variables count] == 0) {
            _variables = vars;
        } else {
            _variables = [ORFactory mergeIntVarArray:_variables with:vars tracker:_into];
        }
    }
}

-(void) visitMDDSpecs:(id<ORMDDSpecs>)cstr
{
    [_mddSpecConstraints addObject:cstr];
    
    /*
    ORDDClosureGenerator *closureVisitor = [[ORDDClosureGenerator alloc] init];
    id<ORIntVarArray> cstrVars = [cstr vars];
    id<ORExpr> arcExists = [cstr arcExists];
    DDClosure arcExistsClosure = [closureVisitor computeClosure:arcExists];
    int* stateValues = [cstr stateValues];
    id<ORExpr>* transitionFunctions = [cstr transitionFunctions];
    int stateSize = [cstr stateSize];
    DDClosure* transitionFunctionClosures = malloc(stateSize * sizeof(DDClosure));
    for (int transitionFunctionIndex = 0; transitionFunctionIndex < stateSize; transitionFunctionIndex++) {
        transitionFunctionClosures[transitionFunctionIndex] = [closureVisitor computeClosure: transitionFunctions[transitionFunctionIndex]];
    }
    [JointState addStateClass: [[MDDStateSpecification alloc] initClassState:[cstrVars low] domainMax:[cstrVars up] state:stateValues arcExists:arcExistsClosure transitionFunctions:transitionFunctionClosures stateSize:stateSize] withVariables:cstrVars];
     _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker:_into];
     */
}
-(void) visitAltMDDSpecs:(id<ORAltMDDSpecs>)cstr
{
    id<ORIntVarArray> cstrVars = [cstr vars];
    id topDownInfo = [cstr topDownInfo];
    id bottomUpInfo = [cstr bottomUpInfo];
    id<ORExpr> edgeDeletionCondition = [cstr edgeDeletionCondition];
    id<ORExpr> topDownInfoEdgeAddition = [cstr topDownInfoEdgeAddition];
    id<ORExpr> bottomUpInfoEdgeAddition = [cstr bottomUpInfoEdgeAddition];
    id<ORExpr> topDownInfoMerge = [cstr topDownInfoMerge];
    id<ORExpr> bottomUpInfoMerge = [cstr bottomUpInfoMerge];
    
    ORAltMDDParentChildEdgeClosureGenerator* parentChildEdgeClosureVisitor = [[ORAltMDDParentChildEdgeClosureGenerator alloc] init];
    ORAltMDDLeftRightClosureGenerator* leftRightClosureVisitor = [[ORAltMDDLeftRightClosureGenerator alloc] init];
    ORAltMDDParentEdgeClosureGenerator* parentEdgeClosureVisitor = [[ORAltMDDParentEdgeClosureGenerator alloc] init];
    
    AltMDDDeleteEdgeCheckClosure edgeDeletionClosure = [parentChildEdgeClosureVisitor computeClosure: edgeDeletionCondition];
    AltMDDAddEdgeClosure topDownInfoEdgeAdditionClosure = [parentEdgeClosureVisitor computeClosure: topDownInfoEdgeAddition];
    AltMDDAddEdgeClosure bottomUpInfoEdgeAdditionClosure = [parentEdgeClosureVisitor computeClosure: bottomUpInfoEdgeAddition];
    AltMDDMergeInfoClosure topDownMergeClosure = [leftRightClosureVisitor computeClosure: topDownInfoMerge];
    AltMDDMergeInfoClosure bottomUpMergeClosure = [leftRightClosureVisitor computeClosure: bottomUpInfoMerge];
    [AltJointState addStateClass: [[AltMDDStateSpecification alloc] initClassState:[cstrVars low] domainMax:[cstrVars up] topDownInfo:topDownInfo bottomUpInfo:bottomUpInfo topDownEdgeAddition:topDownInfoEdgeAdditionClosure bottomUpEdgeAddition:bottomUpInfoEdgeAdditionClosure topDownMerge:topDownMergeClosure bottomUpMerge:bottomUpMergeClosure edgeDeletion:edgeDeletionClosure] withVariables:cstrVars];
    _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker:_into];
}


-(void) visitAlldifferent:(id<ORAlldifferent>)cstr
{
    id<ORIntVarArray> cstrVars = (id<ORIntVarArray>)[cstr array];
    [_mddConstraints addObject: cstr];
    [JointState addStateClass: [[AllDifferentMDDState alloc] initClassState:[cstrVars low] domainMax:[cstrVars up]] withVariables:cstrVars];
    _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker: _into];
    [_into addConstraint: cstr];
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
    [JointState addStateClass: [[KnapsackBDDState alloc] initClassState:[cstrVars low]
                                                              domainMax: [cstrVars up]
                                                               capacity:[cstr capacity]
                                                                weights:[cstr weight]]
                withVariables:cstrVars]; //minDomain and maxDomain are poor names as shown here
    //why is capacity a variable for ORKnapsack?
    
    _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker: _into];
    [_into addConstraint: cstr];
}
-(void) visitAmong:(id<ORAmong>)cstr
{
    id<ORIntVarArray> cstrVars = (id<ORIntVarArray>)[cstr array];
    [_mddConstraints addObject:cstr];
    [JointState addStateClass: [[AmongMDDState alloc] initClassState:[cstrVars low]
                                                           domainMax: [cstrVars up]
                                                           setValues:[cstr values]
                                                          lowerBound:[cstr low]
                                                          upperBound:[cstr up]
                                                             numVars:(ORInt)[cstrVars count]]
                withVariables:cstrVars];
    _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker: _into];
    [_into addConstraint: cstr];
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