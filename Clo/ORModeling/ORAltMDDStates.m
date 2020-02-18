#import "ORAltMDDStates.h"

@implementation AltJointState
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
@end


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
