

#import "ORCustomMDDStates.h"

@implementation AltCustomState : NSObject
-(id) initClassState:(int)domainMin domainMax:(int)domainMax {
    _domainMin = domainMin;
    _domainMax = domainMax;
    return self;
}
-(id) initRootState:(AltCustomState*)classState variableIndex:(int)variableIndex trail:(id<ORTrail>)trail {
    _trail = trail;
    _domainMin = [classState domainMin];
    _domainMax = [classState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax trail:(id<ORTrail>)trail {
    _trail = trail;
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    return self;
}
-(id) initState:(AltCustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    _trail = [parentNodeState trail];
    _domainMin = [parentNodeState domainMin];
    _domainMax = [parentNodeState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(id) initState:(AltCustomState*)parentNodeState variableIndex:(int)variableIndex {
    _trail = [parentNodeState trail];
    _domainMin = [parentNodeState domainMin];
    _domainMax = [parentNodeState domainMax];
    _variableIndex = variableIndex;
    return self;
}
-(void) setTopDownInfo:(id)info
{
    return;
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
-(void) mergeTopDownInfoWith:(AltCustomState*)other withEdge:(int)edgeValue onVariable:(int)otherVariable
{
    return;
}
-(void) mergeBottomUpInfoWith:(AltCustomState*)other
{
    return;
}
-(void) mergeBottomUpInfoWith:(AltCustomState*)other withEdge:(int)edgeValue onVariable:(int)otherVariable
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
-(id) initSinkState:(AltCustomState *)classState trail:(id<ORTrail>)trail {
    _trail = trail;
    _domainMin = [classState domainMin];
    _domainMax = [classState domainMax];
    return self;
}
-(id<ORTrail>) trail { return _trail; }
-(int) variableIndex { return _variableIndex; }
-(int) domainMin { return _domainMin; }
-(int) domainMax { return _domainMax; }
-(bool) isObjective { return _objective; }
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
-(id) initClassState:(int)domainMin domainMax:(int)domainMax state:(id*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions stateSize:(int)stateSize;
{
    [super initClassState:domainMin domainMax:domainMax];
    _stateSize = stateSize;
    _state = calloc(_stateSize, sizeof(TRId));
    for (int i = 0; i < _stateSize; i++) {
        _state[i] = makeTRId(_trail, [stateValues[i] copy]);
    }
    _arcExists = arcExists;
    _transitionFunctions = transitionFunctions;
    return self;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax state:(id*)stateValues arcExists:(DDClosure)arcExists transitionFunctions:(DDClosure*)transitionFunctions relaxationFunctions:(DDMergeClosure*)relaxationFunctions differentialFunctions:(DDMergeClosure*)differentialFunctions stateSize:(int)stateSize;
{
    [super initClassState:domainMin domainMax:domainMax];
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
        DDClosure transitionFunction = _transitionFunctions[stateIndex];
        if (transitionFunction != NULL) {
            _state[stateIndex] = makeTRId(_trail, (id)transitionFunction(parentState, parentVar, edgeValue));
        }
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

//I don't think I use this and undoChanges now?  I hope I don't...
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    NSMutableArray* savedChanges = [[NSMutableArray alloc] init];
    for (int stateIndex = 0; stateIndex < _stateSize; stateIndex++) {
        DDClosure transitionFunction = _transitionFunctions[stateIndex];
        [savedChanges addObject: _state[stateIndex]];
        if (transitionFunction != NULL) {
            assignTRId(&_state[stateIndex], (id)transitionFunction(_state,variable,value),_trail);
        }
    }
    return savedChanges;
}

-(void) undoChanges:(NSArray*)savedChanges {
    for (int savedChangeIndex = 0; savedChangeIndex < [savedChanges count]; savedChangeIndex++) {
        assignTRId(&_state[savedChangeIndex], [savedChanges objectAtIndex: savedChangeIndex], _trail);
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
@end

@implementation AltMDDStateSpecification
static id TopDownInfo;
static id BottomUpInfo;
static AltMDDAddEdgeClosure TopDownEdgeAddition;
static AltMDDAddEdgeClosure MinTopDownEdgeAddition;
static AltMDDAddEdgeClosure MaxTopDownEdgeAddition;
static AltMDDAddEdgeClosure BottomUpEdgeAddition;
static AltMDDAddEdgeClosure MinBottomUpEdgeAddition;
static AltMDDAddEdgeClosure MaxBottomUpEdgeAddition;
static AltMDDMergeInfoClosure TopDownMerge;
static AltMDDMergeInfoClosure MinTopDownMerge;
static AltMDDMergeInfoClosure MaxTopDownMerge;
static AltMDDMergeInfoClosure BottomUpMerge;
static AltMDDMergeInfoClosure MinBottomUpMerge;
static AltMDDMergeInfoClosure MaxBottomUpMerge;
static AltMDDDeleteEdgeCheckClosure EdgeDeletionCheck;
static bool MinMaxState;

-(id) initClassState:(int)domainMin domainMax:(int)domainMax topDownInfo:(id)topDownInfo bottomUpInfo:(id)bottomUpInfo topDownEdgeAddition:(AltMDDAddEdgeClosure)topDownInfoEdgeAdditionClosure bottomUpEdgeAddition:(AltMDDAddEdgeClosure)bottomUpInfoEdgeAdditionClosure topDownMerge:(AltMDDMergeInfoClosure)topDownMergeClosure bottomUpMerge:(AltMDDMergeInfoClosure)bottomUpMergeClosure edgeDeletion:(AltMDDDeleteEdgeCheckClosure)edgeDeletionClosure objective:(bool)objective
{
    [super initClassState:domainMin domainMax:domainMax];
    _topDownInfo = topDownInfo;
    _bottomUpInfo = bottomUpInfo;
    _topDownEdgeAddition = topDownInfoEdgeAdditionClosure;
    _bottomUpEdgeAddition = bottomUpInfoEdgeAdditionClosure;
    _topDownMerge = topDownMergeClosure;
    _bottomUpMerge = bottomUpMergeClosure;
    _edgeDeletionCheck = edgeDeletionClosure;
    _objective = objective;
    
    _minMaxState = false;
    return self;
}
-(id) initMinMaxClassState:(int)domainMin domainMax:(int)domainMax minTopDownInfo:(id)minTopDownInfo maxTopDownInfo:(id)maxTopDownInfo minbottomUpInfo:(id)minBottomUpInfo maxBottomUpInfo:(id)maxBottomUpInfo minTopDownEdgeAddition:(AltMDDAddEdgeClosure)minTopDownInfoEdgeAdditionClosure maxTopDownEdgeAddition:(AltMDDAddEdgeClosure)maxTopDownInfoEdgeAdditionClosure minBottomUpEdgeAddition:(AltMDDAddEdgeClosure)minBottomUpInfoEdgeAdditionClosure maxBottomUpEdgeAddition:(AltMDDAddEdgeClosure)maxBottomUpInfoEdgeAdditionClosure minTopDownMerge:(AltMDDMergeInfoClosure)minTopDownMergeClosure maxTopDownMerge:(AltMDDMergeInfoClosure)maxTopDownMergeClosure minBottomUpMerge:(AltMDDMergeInfoClosure)minBottomUpMergeClosure maxBottomUpMerge:(AltMDDMergeInfoClosure)maxBottomUpMergeClosure edgeDeletion:(AltMDDDeleteEdgeCheckClosure)edgeDeletionClosure objective:(bool)objective
{
    [super initClassState:domainMin domainMax:domainMax];
    _topDownInfo = [[NSArray alloc] initWithObjects:minTopDownInfo, maxTopDownInfo, nil];
    _bottomUpInfo = [[NSArray alloc] initWithObjects:minBottomUpInfo, maxBottomUpInfo, nil];
    _minTopDownEdgeAddition = minTopDownInfoEdgeAdditionClosure;
    _maxTopDownEdgeAddition = maxTopDownInfoEdgeAdditionClosure;
    _minBottomUpEdgeAddition = minBottomUpInfoEdgeAdditionClosure;
    _maxBottomUpEdgeAddition = maxBottomUpInfoEdgeAdditionClosure;
    _minTopDownMerge = minTopDownMergeClosure;
    _maxTopDownMerge = maxTopDownMergeClosure;
    _minBottomUpMerge = minBottomUpMergeClosure;
    _maxBottomUpMerge = maxBottomUpMergeClosure;
    _edgeDeletionCheck = edgeDeletionClosure;
    _objective = objective;
    
    _minMaxState = true;
    return self;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax trail:(id<ORTrail>)trail
{
    _trail = trail;
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    _topDownInfo = makeTRId(_trail, TopDownInfo);
    _bottomUpInfo = makeTRId(_trail, NULL);
    _minMaxState = MinMaxState;
    if (_minMaxState) {
        _minTopDownEdgeAddition = MinTopDownEdgeAddition;
        _maxTopDownEdgeAddition = MaxTopDownEdgeAddition;
        _minBottomUpEdgeAddition = MinBottomUpEdgeAddition;
        _maxBottomUpEdgeAddition = MaxBottomUpEdgeAddition;
        _minTopDownMerge = MinTopDownMerge;
        _maxTopDownMerge = MaxTopDownMerge;
        _minBottomUpMerge = MinBottomUpMerge;
        _maxBottomUpMerge = MaxBottomUpMerge;
    } else {
        _topDownEdgeAddition = TopDownEdgeAddition;
        _bottomUpEdgeAddition = BottomUpEdgeAddition;
        _topDownMerge = TopDownMerge;
        _bottomUpMerge = BottomUpMerge;
    }
    _edgeDeletionCheck = EdgeDeletionCheck;
    return self;
}
-(id) initRootState:(AltMDDStateSpecification*)classState variableIndex:(int)variableIndex trail:(id<ORTrail>)trail
{
    self = [super initRootState:classState variableIndex:variableIndex trail:trail];
    
    _minMaxState = [classState minMaxState];
    _topDownInfo = makeTRId(_trail,[classState topDownInfo]);
    _bottomUpInfo = makeTRId(_trail,[classState bottomUpInfo]);
    if (_minMaxState) {
        _minTopDownEdgeAddition = [classState minTopDownEdgeAddition];
        _maxTopDownEdgeAddition = [classState maxTopDownEdgeAddition];
        _minBottomUpEdgeAddition = [classState minBottomUpEdgeAddition];
        _maxBottomUpEdgeAddition = [classState maxBottomUpEdgeAddition];
        _minTopDownMerge = [classState minTopDownMerge];
        _maxTopDownMerge = [classState maxTopDownMerge];
        _minBottomUpMerge = [classState minBottomUpMerge];
        _maxBottomUpMerge = [classState maxBottomUpMerge];
    } else {
        _topDownEdgeAddition = [classState topDownEdgeAddition];
        _bottomUpEdgeAddition = [classState bottomUpEdgeAddition];
        _topDownMerge = [classState topDownMerge];
        _bottomUpMerge = [classState bottomUpMerge];
    }
    _edgeDeletionCheck = [classState edgeDeletionCheck];
    _objective = [classState isObjective];
    return self;
}
-(id) initSinkState:(AltMDDStateSpecification*)classState trail:(id<ORTrail>)trail {
    _trail = trail;
    
    _minMaxState = [classState minMaxState];
    _topDownInfo = makeTRId(_trail,NULL);
    _bottomUpInfo = makeTRId(_trail,[classState bottomUpInfo]);
    if (_minMaxState) {
        _minTopDownEdgeAddition = [classState minTopDownEdgeAddition];
        _maxTopDownEdgeAddition = [classState maxTopDownEdgeAddition];
        _minBottomUpEdgeAddition = [classState minBottomUpEdgeAddition];
        _maxBottomUpEdgeAddition = [classState maxBottomUpEdgeAddition];
        _minTopDownMerge = [classState minTopDownMerge];
        _maxTopDownMerge = [classState maxTopDownMerge];
        _minBottomUpMerge = [classState minBottomUpMerge];
        _maxBottomUpMerge = [classState maxBottomUpMerge];
    } else {
        _topDownEdgeAddition = [classState topDownEdgeAddition];
        _bottomUpEdgeAddition = [classState bottomUpEdgeAddition];
        _topDownMerge = [classState topDownMerge];
        _bottomUpMerge = [classState bottomUpMerge];
    }
    _edgeDeletionCheck = [classState edgeDeletionCheck];
    _objective = [classState isObjective];
    return self;
}
-(id) initState:(AltMDDStateSpecification*)parentNodeState variableIndex:(int)variableIndex {
    self = [super initState:parentNodeState variableIndex:variableIndex];
    
    _minMaxState = [parentNodeState minMaxState];
    _topDownInfo = [parentNodeState topDownInfo];
    _bottomUpInfo = [parentNodeState bottomUpInfo];
    if (_minMaxState) {
        _minTopDownEdgeAddition = [parentNodeState minTopDownEdgeAddition];
        _maxTopDownEdgeAddition = [parentNodeState maxTopDownEdgeAddition];
        _minBottomUpEdgeAddition = [parentNodeState minBottomUpEdgeAddition];
        _maxBottomUpEdgeAddition = [parentNodeState maxBottomUpEdgeAddition];
        _minTopDownMerge = [parentNodeState minTopDownMerge];
        _maxTopDownMerge = [parentNodeState maxTopDownMerge];
        _minBottomUpMerge = [parentNodeState minBottomUpMerge];
        _maxBottomUpMerge = [parentNodeState maxBottomUpMerge];
    } else {
        _topDownEdgeAddition = [parentNodeState topDownEdgeAddition];
        _bottomUpEdgeAddition = [parentNodeState bottomUpEdgeAddition];
        _topDownMerge = [parentNodeState topDownMerge];
        _bottomUpMerge = [parentNodeState bottomUpMerge];
    }
    _edgeDeletionCheck = [parentNodeState edgeDeletionCheck];
    _objective = [parentNodeState isObjective];
    return self;
}
//Going to need to evaluate how this will be built.  Is the RootState creation any different than another state?  Not really.  All of them should be made the same way, but then just call functions that calculate and set the topDownInfo and bottomUpInfo sequentially through the tree.
+(void) setAsOnlyMDDWithClassState:(AltMDDStateSpecification*)classState
{
    MinMaxState = [classState minMaxState];
    TopDownInfo = [classState topDownInfo];
    BottomUpInfo = [classState bottomUpInfo];
    if (MinMaxState) {
        MinTopDownEdgeAddition = [classState minTopDownEdgeAddition];
        MaxTopDownEdgeAddition = [classState maxTopDownEdgeAddition];
        MinBottomUpEdgeAddition = [classState minBottomUpEdgeAddition];
        MaxBottomUpEdgeAddition = [classState maxBottomUpEdgeAddition];
        MinTopDownMerge = [classState minTopDownMerge];
        MaxTopDownMerge = [classState maxTopDownMerge];
        MinBottomUpMerge = [classState minBottomUpMerge];
        MaxBottomUpMerge = [classState maxBottomUpMerge];
    } else {
        TopDownEdgeAddition = [classState topDownEdgeAddition];
        BottomUpEdgeAddition = [classState bottomUpEdgeAddition];
        TopDownMerge = [classState topDownMerge];
        BottomUpMerge = [classState bottomUpMerge];
    }
    EdgeDeletionCheck = [classState edgeDeletionCheck];
}

-(void) setTopDownInfo:(id)info
{
    assignTRId(&_topDownInfo,info,_trail);
}
-(void) setTopDownInfoFor:(AltMDDStateSpecification*)parentInfo plusEdge:(int)edgeValue {
    if (_minMaxState) {
        assignTRId(&_topDownInfo, [[NSArray alloc] initWithObjects:_minTopDownEdgeAddition([[parentInfo topDownInfo] objectAtIndex:0], [parentInfo variableIndex], edgeValue),_maxTopDownEdgeAddition([[parentInfo topDownInfo] objectAtIndex:1], [parentInfo variableIndex], edgeValue), nil],_trail);
    } else {
        id newValue = _topDownEdgeAddition([[parentInfo topDownInfo] retain], [parentInfo variableIndex], edgeValue);
        assignTRId(&_topDownInfo,newValue ,_trail);
        assert([newValue retainCount] == 2);
        //[newValue release];
    }
}
-(void) setBottomUpInfoFor:(AltMDDStateSpecification*)childInfo plusEdge:(int)edgeValue {
    if (_minMaxState) {
        assignTRId(&_bottomUpInfo, [[NSArray alloc] initWithObjects:_minBottomUpEdgeAddition([[childInfo bottomUpInfo] objectAtIndex:0], [childInfo variableIndex], edgeValue),_maxBottomUpEdgeAddition([[childInfo bottomUpInfo] objectAtIndex:1], [childInfo variableIndex], edgeValue), nil],_trail);
    } else {
        id newValue =  _bottomUpEdgeAddition([[childInfo bottomUpInfo] retain], [childInfo variableIndex], edgeValue);
        assignTRId(&_bottomUpInfo,newValue,_trail);
    }
}
-(void) mergeTopDownInfoWith:(AltMDDStateSpecification*)other
{
    if (_minMaxState) {
        assignTRId(&_topDownInfo, [[NSArray alloc] initWithObjects:_minTopDownMerge([_topDownInfo objectAtIndex:0], [[other topDownInfo] objectAtIndex:0], _variableIndex),_maxTopDownMerge([_topDownInfo objectAtIndex:1], [[other topDownInfo] objectAtIndex:1], _variableIndex), nil],_trail);
    } else {
        assignTRId(&_topDownInfo,_topDownMerge(_topDownInfo,[other topDownInfo],_variableIndex),_trail);
    }
}
-(void) mergeTopDownInfoWith:(AltMDDStateSpecification*)other withEdge:(int)edgeValue onVariable:(int)otherVariable
{
    if (_minMaxState) {
        assignTRId(&_topDownInfo, [[NSArray alloc] initWithObjects:
                                   _minTopDownMerge([_topDownInfo objectAtIndex:0], _minTopDownEdgeAddition([[other topDownInfo] objectAtIndex:0],otherVariable,edgeValue), _variableIndex),
                                   _maxTopDownMerge([_topDownInfo objectAtIndex:1], _maxTopDownEdgeAddition([[other topDownInfo] objectAtIndex:1],otherVariable,edgeValue), _variableIndex), nil],_trail);
    } else {
        id newValue = _topDownMerge([_topDownInfo retain],
                                    _topDownEdgeAddition([other.topDownInfo retain],otherVariable,edgeValue),_variableIndex);
        //NSLog(@"RC: %lu",(unsigned long)[newValue retainCount]);
        assignTRId(&_topDownInfo,newValue,_trail);
        assert([newValue retainCount] == 2);
        //[newValue release];
    }
}
-(void) mergeBottomUpInfoWith:(AltMDDStateSpecification*)other
{
    if (_minMaxState) {
        assignTRId(&_bottomUpInfo, [[NSArray alloc] initWithObjects:_minBottomUpMerge([_bottomUpInfo objectAtIndex:0], [[other bottomUpInfo] objectAtIndex:0], _variableIndex),_maxBottomUpMerge([_bottomUpInfo objectAtIndex:1], [[other bottomUpInfo] objectAtIndex:1], _variableIndex), nil],_trail);
    } else {
        assignTRId(&_bottomUpInfo,_bottomUpMerge(_bottomUpInfo,[other bottomUpInfo],_variableIndex),_trail);
    }
}
-(void) mergeBottomUpInfoWith:(AltMDDStateSpecification*)other withEdge:(int)edgeValue onVariable:(int)otherVariable
{
    if (_minMaxState) {
        assignTRId(&_bottomUpInfo, [[NSArray alloc] initWithObjects:_minBottomUpMerge([_bottomUpInfo objectAtIndex:0], _minBottomUpEdgeAddition([[other bottomUpInfo] objectAtIndex:0],otherVariable,edgeValue), _variableIndex),_maxBottomUpMerge([_bottomUpInfo objectAtIndex:1], _maxBottomUpEdgeAddition([[other bottomUpInfo] objectAtIndex:1],otherVariable, edgeValue), _variableIndex), nil],_trail);
    } else {
        assignTRId(&_bottomUpInfo,_bottomUpMerge(_bottomUpInfo,_bottomUpEdgeAddition([other bottomUpInfo],otherVariable,edgeValue),_variableIndex),_trail);
    }
}
-(bool) canDeleteChild:(AltMDDStateSpecification*)child atEdgeValue:(int)edgeValue
{
    //if (_objective) {
    //    return false;
    //}
    return [_edgeDeletionCheck(_topDownInfo, [child bottomUpInfo], _variableIndex, edgeValue) boolValue];
}
-(bool) equivalentWithEdge:(int)edgeValue to:(AltMDDStateSpecification*)other withEdge:(int)otherEdgeValue
{
    if (_minMaxState) {
        id minSelfInfo = _minTopDownEdgeAddition([_topDownInfo objectAtIndex:0], _variableIndex, edgeValue);
        id maxSelfInfo = _maxTopDownEdgeAddition([_topDownInfo objectAtIndex:1], _variableIndex, edgeValue);
        id minOtherInfo = _minTopDownEdgeAddition([[other topDownInfo] objectAtIndex:0], _variableIndex, otherEdgeValue);
        id maxOtherInfo = _maxTopDownEdgeAddition([[other topDownInfo] objectAtIndex:1], _variableIndex, otherEdgeValue);
        if ([minSelfInfo class] == [NSMutableArray class]) {
            return [minSelfInfo isEqualToArray:minOtherInfo] && [maxSelfInfo isEqualToArray:maxOtherInfo];
        } else {
            return minSelfInfo == minOtherInfo && maxSelfInfo == maxOtherInfo;
        }
    } else {
        id selfInfo = _topDownEdgeAddition(_topDownInfo, _variableIndex, edgeValue);
        id otherInfo = _topDownEdgeAddition([other topDownInfo], _variableIndex, otherEdgeValue);
        if ([selfInfo class] == [NSMutableArray class]) {
            return [selfInfo isEqualToArray:otherInfo];
        } else {
            return selfInfo == otherInfo;
        }
    }
}
-(id) topDownInfo { return _topDownInfo; }
-(id) bottomUpInfo { return _bottomUpInfo; }
-(AltMDDAddEdgeClosure) topDownEdgeAddition { return _topDownEdgeAddition; }
-(AltMDDAddEdgeClosure) bottomUpEdgeAddition { return _bottomUpEdgeAddition; }
-(AltMDDMergeInfoClosure) topDownMerge { return _topDownMerge; }
-(AltMDDMergeInfoClosure) bottomUpMerge { return _bottomUpMerge; }
-(AltMDDAddEdgeClosure) minTopDownEdgeAddition { return _minTopDownEdgeAddition; }
-(AltMDDAddEdgeClosure) maxTopDownEdgeAddition { return _maxTopDownEdgeAddition; }
-(AltMDDAddEdgeClosure) minBottomUpEdgeAddition { return _minBottomUpEdgeAddition; }
-(AltMDDAddEdgeClosure) maxBottomUpEdgeAddition { return _maxBottomUpEdgeAddition; }
-(AltMDDMergeInfoClosure) minTopDownMerge { return _minTopDownMerge; }
-(AltMDDMergeInfoClosure) maxTopDownMerge { return _maxTopDownMerge; }
-(AltMDDMergeInfoClosure) minBottomUpMerge { return _minBottomUpMerge; }
-(AltMDDMergeInfoClosure) maxBottomUpMerge { return _maxBottomUpMerge; }
-(AltMDDDeleteEdgeCheckClosure) edgeDeletionCheck { return _edgeDeletionCheck; }
-(bool) minMaxState { return _minMaxState; }
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
    //   _upperBoundNumDigits = [parentNodeState numDigits];
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

/*@implementation AltJointState
static NSMutableArray* _stateClasses;
static NSMutableArray* _stateVariables;
static id<ORIntVarArray> _variables;
static bool _hasObjective = false;

-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax trail:(id<ORTrail>)trail
{
    _trail = trail;
    _variableIndex = variableIndex;
    _domainMin = domainMin;
    _domainMax = domainMax;
    _states = [[NSMutableArray alloc] init];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        AltCustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        AltCustomState* state = [[[stateClass class] alloc] initRootState:stateClass variableIndex:variableIndex trail:trail];
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
-(id) initState:(AltJointState*)parentNodeState variableIndex:(int)variableIndex
{
    self = [super initState:parentNodeState variableIndex:variableIndex];
    _trail = [parentNodeState trail];
    _states = [[NSMutableArray alloc] init];
    NSMutableArray* parentStates = [parentNodeState states];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        AltCustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        AltCustomState* state;
        state = [[[stateClass class] alloc] initState:[parentStates objectAtIndex:stateIndex] variableIndex:variableIndex];
        [_states addObject: state];
    }
    return self;
}
-(id) initSinkState:(int)domainMin domainMax:(int)domainMax trail:(id<ORTrail>)trail
{
    _trail = trail;
    _domainMin = domainMin;
    _domainMax = domainMax;
    _states = [[NSMutableArray alloc] init];
    for (int stateIndex = 0; stateIndex < [_stateClasses count]; stateIndex++) {
        AltCustomState* stateClass = [_stateClasses objectAtIndex:stateIndex];
        AltCustomState* state = [[[stateClass class] alloc] initSinkState:stateClass trail:trail];
        [_states addObject: state];
    }
    return self;
}
+(void) addStateClass:(AltCustomState*)stateClass withVariables:(id<ORIntVarArray>)variables {
    [_stateClasses addObject:stateClass];
    [_stateVariables addObject:variables];
    if ([stateClass isObjective]) {
        _hasObjective = true;
    }
}
-(void) setTopDownInfo:(NSArray*)info
{
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [[_states objectAtIndex:stateIndex] setTopDownInfo:[info objectAtIndex: stateIndex]];
    }
}
-(void) setTopDownInfoFor:(AltJointState*)parentInfo plusEdge:(int)edgeValue
{
    NSArray* parentStates = [parentInfo states];
    for (int stateIndex = 0; stateIndex < [parentStates count]; stateIndex++) {
        [_states[stateIndex] setTopDownInfoFor:parentStates[stateIndex] plusEdge:edgeValue];
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
-(void) mergeTopDownInfoWith:(AltJointState*)other withEdge:(int)edgeValue onVariable:(int)otherVariable
{
    NSArray* otherStates = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [_states[stateIndex] mergeTopDownInfoWith:otherStates[stateIndex] withEdge:edgeValue onVariable:otherVariable];
    }
}
-(void) mergeBottomUpInfoWith:(AltJointState*)other
{
    NSArray* otherStates = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [[_states objectAtIndex:stateIndex] mergeBottomUpInfoWith:[otherStates objectAtIndex:stateIndex]];
    }
}
-(void) mergeBottomUpInfoWith:(AltJointState*)other withEdge:(int)edgeValue onVariable:(int)otherVariable
{
    NSArray* otherStates = [other states];
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [[_states objectAtIndex:stateIndex] mergeBottomUpInfoWith:[otherStates objectAtIndex:stateIndex] withEdge:edgeValue onVariable:otherVariable];
    }
}
-(bool) canDeleteChild:(AltJointState*)child atEdgeValue:(int)edgeValue
{
    NSArray* childStates = [child states];
    for (int stateIndex = 0; stateIndex < _states.count; stateIndex++) {
        if ([_states[stateIndex] canDeleteChild:childStates[stateIndex] atEdgeValue:edgeValue]) {
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
-(id<ORTrail>) trail { return _trail; }
+(AltCustomState*) firstState { return [_stateClasses firstObject]; }
+(int) numStates { return (int)[_stateClasses count]; }
+(void) stateClassesInit { _stateClasses = [[NSMutableArray alloc] init]; _stateVariables = [[NSMutableArray alloc] init]; }
+(void) setVariables:(id<ORIntVarArray>)variables { _variables = variables; }
+(bool) hasObjective { return _hasObjective; }

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
-(id) topDownInfo {
    NSMutableArray* topDownInfo = [[NSMutableArray alloc] init];
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [topDownInfo addObject:[[_states objectAtIndex:stateIndex] topDownInfo]];
    }
    
    return topDownInfo;
}
-(id) bottomUpInfo {
    NSMutableArray* bottomUpInfo = [[NSMutableArray alloc] init];
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        [bottomUpInfo addObject:[[_states objectAtIndex:stateIndex] bottomUpInfo]];
    }
    
    return bottomUpInfo;
}
@end*/

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
    _domainMin = [classState domainMin];
    _domainMax = [classState domainMax];
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
    }/*
    for (int stateVarsIndex = 0; stateVarsIndex < [_stateVars count]; stateVarsIndex++) {
        id<ORIntVarArray> stateVarList = [_stateVars objectAtIndex:stateVarsIndex];
        for (id<ORIntVar> x in stateVarList) {
            [_statesForVariables[[x getId]] addObject:[NSNumber numberWithInt:stateVarsIndex]];
        }
    }*/
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
    /*NSMutableArray* savedChanges = [[NSMutableArray alloc] init];
    
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        NSArray* stateSavedChanges;
        if ([(id<ORIdArray>)_stateVariables[stateIndex] contains:[_vars at: variable]]) {
            stateSavedChanges = [[_states objectAtIndex:stateIndex] tempAlterStateAssigningVariable:variable value:value toTestVariable:toVariable];
        } else {
            stateSavedChanges = [[NSArray alloc] init];
        }
        
        [savedChanges addObject:stateSavedChanges];
    }
    return savedChanges;*/
    return nil;
}

-(void) undoChanges:(NSArray*)savedChanges {
    /*
    for (int stateIndex = 0; stateIndex < [_states count]; stateIndex++) {
        if ([[savedChanges objectAtIndex:stateIndex] count] > 0) {
            [[_states objectAtIndex: stateIndex] undoChanges: [savedChanges objectAtIndex:stateIndex]];
        }
    }*/
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
