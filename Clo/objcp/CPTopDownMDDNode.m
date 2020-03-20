#import <objcp/CPTopDownMDDNode.h>

const short BytesPerMagic = 4;

@implementation Node {
@public
    TRId* _children;
}
-(id) initSinkNode: (id<ORTrail>) trail state:(MDDStateValues*)state hashWidth:(int)hashWidth
{
    self = [super init];
    _trail = trail;
    _children = NULL;
    _numChildren = makeTRInt(_trail, 0);
    _minChildIndex = 0;
    _maxChildIndex = 0;
    _maxNumParents = makeTRInt(_trail,10);
    _parents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumParents._val];
    _numParents = makeTRInt(_trail, 0);
    _isMergedNode = makeTRInt(_trail, 0);
    _topDownRecalcRequired = false;
    _bottomUpRecalcRequired = true;
    _bottomUpState = [state retain];
    
    return self;
}
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex state:(MDDStateValues*)state hashWidth:(int)hashWidth
{
    self = [super init];
    _trail = trail;
    _minChildIndex = minChildIndex;
    _maxChildIndex = maxChildIndex;
    _children = malloc((_maxChildIndex-_minChildIndex +1) * sizeof(TRId));
    _children -= _minChildIndex;
    for (int child = _minChildIndex; child <= maxChildIndex; child++) {
        _children[child] = makeTRId(_trail, nil);
    }
    
    _topDownState = [state retain];
    
    _numChildren = makeTRInt(_trail, 0);
    _maxNumParents = makeTRInt(_trail,(maxChildIndex-minChildIndex+1));
    _parents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumParents._val];
    _numParents = makeTRInt(_trail, 0);
    _isMergedNode = makeTRInt(_trail, 0);
    _topDownRecalcRequired = false;
    _bottomUpRecalcRequired = true;
    [_topDownState setNode:self];
    return self;
}
-(void) dealloc {
    [_topDownState release];
    [_bottomUpState release];
    [_parents release];
    if (_children != nil) {
        for (int i = _minChildIndex; i <= _maxChildIndex; i++) {
            if (_children[i] != nil) {
                [_children[i] release];
            }
        }
        _children += _minChildIndex;
        free(_children);
    }
    [super dealloc];
}

-(void) initializeBottomUpState:(MDDStateValues*)bottomUpState {
    _bottomUpState = bottomUpState;
}
-(void) updateBottomUpState:(char*)bottomUpState {
    [_bottomUpState replaceStateWith:bottomUpState trail:_trail];
}
-(void) addParent:(id) parent inPost:(bool)inPost {
    @throw [[ORExecutionError alloc] initORExecutionError: "Node: Method addParent not implemented"];
}
-(void) addChild:(id)childArc at:(int)index inPost:(bool)inPost {
    if (inPost) {
        _numChildren = makeTRInt(_trail, _numChildren._val+1);
        _children[index] = makeTRId(_trail, [childArc retain]);
        //assignTRInt(&_numChildren, _numChildren._val +1, _trail);
        //assignTRId(&_children[index],childArc,_trail);
    } else {
        if (_children[index] == NULL) {
            assignTRInt(&_numChildren, _numChildren._val +1, _trail);
        }
        assignTRId(&_children[index], childArc, _trail);
    }
}
-(void) removeChildAt: (int) index inPost:(bool)inPost {
    if (inPost) {
        _children[index] = makeTRId(_trail, nil);
        _numChildren = makeTRInt(_trail, _numChildren._val -1);
    } else {
        assignTRId(&_children[index], NULL, _trail);
        assignTRInt(&_numChildren, _numChildren._val -1, _trail);
    }
}
-(void) takeParentsFrom:(Node*)other {
    @throw [[ORExecutionError alloc] initORExecutionError: "Node: Method takeParentsFrom not implemented"];
}
-(int) layerIndex { return _layerIndex._val; }
-(void) setInitialLayerIndex:(int)index {
    _layerIndex = makeTRInt(_trail, index);
}
-(void) updateLayerIndex:(int)index {
    assignTRInt(&_layerIndex,index,_trail);
}
-(TRId) getState {
    return _topDownState;
}
-(TRId*) children {
    return _children;
}
-(int) numChildren {
    return _numChildren._val;
}
-(bool) isChildless {
    return !_numChildren._val;
}
-(bool) isParentless {
    return !_numParents._val;
}
-(bool) topDownRecalcRequired {
    return _topDownRecalcRequired;
}
-(void) setTopDownRecalcRequired:(bool)value {
    _topDownRecalcRequired = value;
}
-(bool) bottomUpRecalcRequired {
    return _bottomUpRecalcRequired;
}
-(void) setBottomUpRecalcRequired:(bool)value {
    _bottomUpRecalcRequired = value;
}
-(int) numParents {
    return _numParents._val;
}
-(ORTRIdArrayI*) parents {
    return _parents;
}
-(bool) isMerged { return _isMergedNode._val; }
-(void) setIsMergedNode:(bool)isMergedNode { assignTRInt(&_isMergedNode, isMergedNode, _trail); }

-(NSString*) toString {
    //Hard coded for among
    
    NSMutableString* printOut = [NSMutableString string];
    char* state = [_topDownState stateValues];
    short minC1, maxC1, rem1, minC2, maxC2, rem2, minC3, maxC3, rem3, minC4, maxC4, rem4;
    minC1 = *(short*)&state[0];
    maxC1 = *(short*)&state[2];
    rem1 = *(short*)&state[4];
    minC2 = *(short*)&state[6];
    maxC2 = *(short*)&state[8];
    rem2 = *(short*)&state[10];
    minC3 = *(short*)&state[12];
    maxC3 = *(short*)&state[14];
    rem3 = *(short*)&state[16];
    minC4 = *(short*)&state[18];
    maxC4 = *(short*)&state[20];
    rem4 = *(short*)&state[22];

    [printOut appendString: @"  Constraint 1:\n"];
    [printOut appendString: [NSString stringWithFormat: @"    minC: %d\n",minC1]];
    [printOut appendString: [NSString stringWithFormat: @"    maxC: %d\n",maxC1]];
    [printOut appendString: [NSString stringWithFormat: @"     rem: %d\n",rem1]];
    [printOut appendString: @"  Constraint 2:\n"];
    [printOut appendString: [NSString stringWithFormat: @"    minC: %d\n",minC2]];
    [printOut appendString: [NSString stringWithFormat: @"    maxC: %d\n",maxC2]];
    [printOut appendString: [NSString stringWithFormat: @"     rem: %d\n",rem2]];
    [printOut appendString: @"  Constraint 3:\n"];
    [printOut appendString: [NSString stringWithFormat: @"    minC: %d\n",minC3]];
    [printOut appendString: [NSString stringWithFormat: @"    maxC: %d\n",maxC3]];
    [printOut appendString: [NSString stringWithFormat: @"     rem: %d\n",rem3]];
    [printOut appendString: @"  Constraint 4:\n"];
    [printOut appendString: [NSString stringWithFormat: @"    minC: %d\n",minC4]];
    [printOut appendString: [NSString stringWithFormat: @"    maxC: %d\n",maxC4]];
    [printOut appendString: [NSString stringWithFormat: @"     rem: %d\n",rem4]];
    return printOut;
}
@end

@implementation OldNode
-(id) initSinkNode: (id<ORTrail>) trail state:(MDDStateValues*)state hashWidth:(int)hashWidth {
    self = [super initSinkNode:trail state:state hashWidth:hashWidth];
    _parentCounts = [[ORTRIntArrayI alloc] initORTRIntArrayWithTrail:_trail low:0 up:_maxNumParents._val];
    _lastAddedParentIndex = 0;
    return self;
}
-(id) initNode:(id<ORTrail>)trail minChildIndex:(int)minChildIndex maxChildIndex:(int)maxChildIndex state:(id)state hashWidth:(int)hashWidth {
    self = [super initNode:trail minChildIndex:minChildIndex maxChildIndex:maxChildIndex state:state hashWidth:hashWidth];
    _parentCounts = [[ORTRIntArrayI alloc] initORTRIntArrayWithTrail:_trail low:0 up:_maxNumParents._val];
    _lastAddedParentIndex = 0;
    return self;
}
-(void) removeChild:(Node*)child numTimes:(int)childCount updatingLVC:(TRInt*)variable_count inPost:(bool)inPost {
    if (inPost) {
        _numChildren = makeTRInt(_trail, _numChildren._val - childCount);
    } else {
        assignTRInt(&_numChildren, _numChildren._val - childCount, _trail);
    }
    for (int child_index = _minChildIndex; childCount > 0; child_index++) {
        if (_children[child_index] == child) {
            if (inPost) {
                _children[child_index] = makeTRId(_trail, nil);
            } else {
                assignTRId(&_children[child_index], NULL, _trail);
            }
            assignTRInt(&variable_count[child_index],variable_count[child_index]._val-1,_trail);
            childCount--;
        }
    }
}
-(ORTRIntArrayI*) parentCounts {
    return _parentCounts;
}
-(void) addParent: (OldNode*) parent inPost:(bool)inPost {
    int parentIndex;
    int numParents = _numParents._val;
    if (_lastAddedParentIndex < numParents &&  [_parents at:_lastAddedParentIndex] == parent) {
        parentIndex = _lastAddedParentIndex;
    } else {
        parentIndex = [self findUniqueParentIndexFor:parent addToHash:true];
    }
    if (parentIndex >= 0) {
        [_parentCounts set:([_parentCounts at:parentIndex] + 1) at:parentIndex inPost:inPost];
    } else {
        parentIndex = numParents;
        if (_maxNumParents._val == numParents) {
            int newMaxParents = _maxNumParents._val * 2;
            if (inPost) {
                _maxNumParents = makeTRInt(_trail, newMaxParents);
            } else {
                assignTRInt(&_maxNumParents, newMaxParents, _trail);
            }
            [_parents resize:newMaxParents inPost:inPost];
            [_parentCounts resize:newMaxParents inPost:inPost];
        }
        [_parents set:parent at:parentIndex inPost:inPost];
        [_parentCounts set:1 at:parentIndex inPost:inPost];
        if (inPost) {
            _numParents = makeTRInt(_trail, numParents+1);
        } else {
            assignTRInt(&_numParents,numParents+1,_trail);
        }
    }
    _lastAddedParentIndex = parentIndex;
}
-(void) addParent: (OldNode*) parent count:(int)count inPost:(bool)inPost {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:true];
    if (parentIndex >= 0) {
        [_parentCounts set:([_parentCounts at:parentIndex] + count) at:parentIndex inPost:inPost];
    } else {
        int numParents = _numParents._val;
        if (_maxNumParents._val == numParents) {
            int newMaxParents = _maxNumParents._val * 2;
            if (inPost) {
                _maxNumParents = makeTRInt(_trail, newMaxParents);
            } else {
                assignTRInt(&_maxNumParents, newMaxParents, _trail);
            }
            [_parents resize:newMaxParents inPost:inPost];
            [_parentCounts resize:newMaxParents inPost:inPost];
        }
        [_parents set:parent at:numParents inPost:inPost];
        [_parentCounts set:count at:numParents inPost:inPost];
        if (inPost) {
            _numParents = makeTRInt(_trail, numParents+1);
        } else {
            assignTRInt(&_numParents,numParents+1,_trail);
        }
    }
}
-(void) removeParentAt:(int)index inPost:(bool)inPost {
    int finalParentIndex = _numParents._val-1;
    if (inPost) {
        _numParents = makeTRInt(_trail, finalParentIndex);
    } else {
        assignTRInt(&_numParents,finalParentIndex,_trail);
    }
    if (finalParentIndex != index) {
        [_parents set:[_parents at:finalParentIndex] at:index inPost:inPost];
        [_parentCounts set:[_parentCounts at:finalParentIndex] at:index inPost:inPost];
    }
    [_parents set:nil at:finalParentIndex inPost:inPost];
}
-(void) removeParentOnce: (OldNode*) parent inPost:(bool)inPost {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:false];
    if (parentIndex >= 0) {
        int newCount = [_parentCounts at:parentIndex]-1;
        if (newCount == 0) {
            [self removeParentAt:parentIndex inPost:inPost];
        } else {
            [_parentCounts set:newCount at:parentIndex inPost:inPost];
        }
    }
}
-(void) removeParentOnceAtIndex:(int)parentIndex inPost:(bool)inPost {
    int newCount = [_parentCounts at:parentIndex]-1;
    if (newCount == 0) {
        [self removeParentAt:parentIndex inPost:inPost];
    } else {
        [_parentCounts set:newCount at:parentIndex inPost:inPost];
    }
}
-(void) removeParentValue: (OldNode*) parent inPost:(bool)inPost {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:false];
    if (parentIndex >= 0) {
        [self removeParentAt:parentIndex inPost:inPost];
    }
}
-(void) removeParent:(OldNode*)parent inPost:(bool)inPost {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:false];
    int newCount = [_parentCounts at:parentIndex]-1;
    if (newCount == 0) {
        [self removeParentAt:parentIndex inPost:inPost];
    } else {
        [_parentCounts set:newCount at:parentIndex inPost:inPost];
    }
}
-(bool) hasParent:(OldNode*)parent {
    return [self findUniqueParentIndexFor:parent addToHash:false] >= 0;
}
-(int) countForParent:(OldNode*)parent {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:false];
    if (parentIndex < 0) {
        return 0;
    }
    return [self countForParentIndex:parentIndex];
}
-(int) countForParentIndex:(int)parent_index {
    return [_parentCounts at:parent_index];
}
-(void) takeParentsFrom:(OldNode*)other {
    ORTRIdArrayI* otherParents = [other parents];
    ORTRIntArrayI* otherParentCounts = [other parentCounts];
    for (int parentIndex = 0; parentIndex < [other numParents]; parentIndex++) {
        OldNode* parent = (OldNode*)[otherParents at:parentIndex];
        int count = [otherParentCounts at:parentIndex];
        [self addParent:parent count:count inPost:true];
        [parent replaceChild:other with:self numTimes:count];
    }
}
-(void) replaceChild:(Node*)oldChild with:(Node*)newChild numTimes:(int)childCount {
    for (int child_index = _minChildIndex; childCount; child_index++) {
        if (_children[child_index] == oldChild) {
            _children[child_index] = makeTRId(_trail, [newChild retain]);
            //assignTRId(&_children[child_index], newChild, _trail);
            childCount--;
        }
    }
}
-(int) findUniqueParentIndexFor:(Node*) parent addToHash:(bool)addToHash {
    for (int i = 0; i < _numParents._val; i++) {
        if ([_parents at:i] == parent) {
            return i;
        }
    }
    return -1;
}
-(void) dealloc {
    [_parentCounts release];
    [super dealloc];
}
@end

@implementation MDDNode
-(void) addParent:(MDDArc*)parentArc inPost:(bool)inPost {
    int numParents = _numParents._val;
    if (_maxNumParents._val == numParents) {
        int newMaxParents = _maxNumParents._val * 2;
        if (inPost) {
            _maxNumParents = makeTRInt(_trail, newMaxParents);
        } else {
            assignTRInt(&_maxNumParents, newMaxParents, _trail);
        }
        [_parents resize:newMaxParents inPost:inPost];
    }
    [_parents set:parentArc at:numParents inPost:inPost];
    if (inPost) {
        _numParents = makeTRInt(_trail, numParents+1);
    } else {
        assignTRInt(&_numParents,numParents+1,_trail);
    }
}
-(void) removeParentArc:(MDDArc*)parentArc inPost:(bool)inPost {
    int parentArcIndex = [parentArc parentArcIndex];
    int finalParentIndex = _numParents._val-1;
    if (inPost) {
        _numParents = makeTRInt(_trail, finalParentIndex);
    } else {
        assignTRInt(&_numParents,finalParentIndex,_trail);
    }
    if (finalParentIndex != parentArcIndex) {
        MDDArc* movedArc = [_parents at:finalParentIndex];
        [_parents set:movedArc at:parentArcIndex inPost:inPost];
        [movedArc updateParentArcIndex:parentArcIndex inPost:inPost];
    }
    [_parents set:nil at:finalParentIndex inPost:inPost];
}
-(void) takeParentsFrom:(MDDNode*)other {
    ORTRIdArrayI* otherParentArcs = [other parents];
    for (int parentIndex = 0; parentIndex < [other numParents]; parentIndex++) {
        MDDArc* parentArc = [otherParentArcs at:parentIndex];
        [parentArc setChild:self inPost:true];
        [parentArc updateParentArcIndex:_numParents._val inPost:true];
        [self addParent:parentArc inPost:true];
    }
}
@end

@implementation MDDArc
-(id) initArcToSink:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost numBottomUpBytes:(size_t)numBottomUpBytes {
    self = [super init];
    _trail = trail;
    _parent = parent;
    _child = makeTRId(_trail, [child retain]);
    _arcValue = arcValue;
    _arcIndexForChild = makeTRInt(_trail, [_child numParents]);
    [_parent addChild:self at:arcValue inPost:inPost];
    [_child addParent:self inPost:inPost];
    _numBottomUpBytes = numBottomUpBytes;
    _passedBottomUpState = malloc(_numBottomUpBytes * sizeof(char));
    _bottomUpMagic = malloc(_numBottomUpBytes/BytesPerMagic * sizeof(ORUInt));
    for (int i = 0; i < (_numBottomUpBytes/BytesPerMagic); i++) {
        _bottomUpMagic[i] = [trail magic];
    }
    [self release];
    return self;
}
-(id) initArc:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost state:(char*)state numTopDownBytes:(size_t)numTopDownBytes numBottomUpBytes:(size_t)numBottomUpBytes {
    self = [super init];
    _trail = trail;
    _parent = parent;
    _child = makeTRId(_trail, [child retain]);
    _arcValue = arcValue;
    _arcIndexForChild = makeTRInt(_trail, [_child numParents]);
    [_parent addChild:self at:arcValue inPost:inPost];
    [_child addParent:self inPost:inPost];
    _numTopDownBytes = numTopDownBytes;
    _numBottomUpBytes = numBottomUpBytes;
    _passedTopDownState = state;
    _passedBottomUpState = malloc(_numBottomUpBytes * sizeof(char));
    _topDownMagic = malloc(_numTopDownBytes/BytesPerMagic * sizeof(ORUInt));
    _bottomUpMagic = malloc(_numBottomUpBytes/BytesPerMagic * sizeof(ORUInt));
    for (int i = 0; i < (_numTopDownBytes/BytesPerMagic); i++) {
        _topDownMagic[i] = [trail magic];
    }
    for (int i = 0; i < (_numBottomUpBytes/BytesPerMagic); i++) {
        _bottomUpMagic[i] = [trail magic];
    }
    [self release];
    return self;
}
-(MDDNode*) parent { return _parent; }
-(MDDNode*) child { return _child; }
-(void) setChild:(MDDNode*)child inPost:(bool)inPost {
    if (inPost) {
        [_child release];
        _child = makeTRId(_trail, [child retain]);
    } else {
        assignTRId(&_child, child, _trail);
    }
}
-(int) arcValue { return _arcValue; }
-(int) parentArcIndex { return _arcIndexForChild._val; }
-(void) updateParentArcIndex:(int)parentArcIndex inPost:(bool)inPost {
    if (inPost) {
        _arcIndexForChild = makeTRInt(_trail, parentArcIndex);
    } else {
        assignTRInt(&_arcIndexForChild, parentArcIndex, _trail);
    }
}
-(char*) topDownState { return _passedTopDownState; }
-(char*) bottomUpState { return _passedBottomUpState; }
-(void) replaceTopDownStateWith:(char *)newState trail:(id<ORTrail>)trail {
    ORUInt magic = [trail magic];
    for (int byteIndex = 0; byteIndex < _numTopDownBytes; byteIndex+=BytesPerMagic) {
        size_t magicIndex = byteIndex/BytesPerMagic;
        switch (BytesPerMagic) {
            case 2:
                if (*(short*)&_passedTopDownState[byteIndex] != *(short*)&newState[byteIndex]) {
                    if (magic != _topDownMagic[magicIndex]) {
                        [trail trailShort:(short*)&_passedTopDownState[byteIndex]];
                        _topDownMagic[magicIndex] = magic;
                    }
                    *(short*)&_passedTopDownState[byteIndex] = *(short*)&newState[byteIndex];
                }
                break;
            case 4:
                if (*(int*)&_passedTopDownState[byteIndex] != *(int*)&newState[byteIndex]) {
                    if (magic != _topDownMagic[magicIndex]) {
                        [trail trailInt:(int*)&_passedTopDownState[byteIndex]];
                        _topDownMagic[magicIndex] = magic;
                    }
                    *(int*)&_passedTopDownState[byteIndex] = *(int*)&newState[byteIndex];
                }
                break;
            default:
                @throw [[ORExecutionError alloc] initORExecutionError: "MDDArc: Method replaceStateWith not implemented for given BytesPerMagic"];
                break;
        }
    }
}
-(void) replaceBottomUpStateWith:(char*)newState trail:(id<ORTrail>)trail {
    ORUInt magic = [trail magic];
    for (int byteIndex = 0; byteIndex < _numBottomUpBytes; byteIndex+=BytesPerMagic) {
        size_t magicIndex = byteIndex/BytesPerMagic;
        switch (BytesPerMagic) {
            case 2:
                if (*(short*)&_passedBottomUpState[byteIndex] != *(short*)&newState[byteIndex]) {
                    if (magic != _bottomUpMagic[magicIndex]) {
                        [trail trailShort:(short*)&_passedBottomUpState[byteIndex]];
                        _bottomUpMagic[magicIndex] = magic;
                    }
                    *(short*)&_passedBottomUpState[byteIndex] = *(short*)&newState[byteIndex];
                }
                break;
            case 4:
                if (*(int*)&_passedBottomUpState[byteIndex] != *(int*)&newState[byteIndex]) {
                    if (magic != _bottomUpMagic[magicIndex]) {
                        [trail trailInt:(int*)&_passedBottomUpState[byteIndex]];
                        _bottomUpMagic[magicIndex] = magic;
                    }
                    *(int*)&_passedBottomUpState[byteIndex] = *(int*)&newState[byteIndex];
                }
                break;
            default:
                @throw [[ORExecutionError alloc] initORExecutionError: "MDDArc: Method replaceStateWith not implemented for given BytesPerMagic"];
                break;
        }
    }
}
-(void) removeParent:(Node*)parentArc inPost:(bool)inPost {
    [_child removeParentArc:self inPost:inPost];
}
-(bool) isParentless {
    return [_child isParentless];
}
-(bool) isMerged {
    return [_child isMerged];
}
-(void) setTopDownRecalcRequired:(bool)recalcRequired { [_child setTopDownRecalcRequired:recalcRequired]; }
-(void) setBottomUpRecalcRequired:(bool)recalcRequired { [_parent setBottomUpRecalcRequired:recalcRequired]; }
-(void) dealloc {
    free(_topDownMagic);
    free(_passedTopDownState);
    [super dealloc];
}
@end

@implementation BetterNodeHashTable {
    MDDStateValues** *_stateLists;
}
-(id) initBetterNodeHashTable:(int)width numBytes:(size_t)numBytes {
    self = [super init];
    _width = width;
    _stateLists = malloc(_width * sizeof(MDDStateValues**));
    _statePropertiesLists = malloc(_width * sizeof(char**));
    _numPerHash = calloc(_width, sizeof(int));
    _maxPerHash = calloc(_width, sizeof(int));
    _numBytes = numBytes;
    return self;
}
-(bool) hasNodeWithStateProperties:(char*)stateProperties hash:(NSUInteger)hash node:(Node**)existingNode {
    _lastCheckedHash = hash;
    int numWithHash = _numPerHash[_lastCheckedHash];
    if (!numWithHash) return false;
    char** propertiesList = _statePropertiesLists[_lastCheckedHash];
    bool foundNode;
    for (int i = 0; i < numWithHash; i++) {
        char* existingProperties = propertiesList[i];
        foundNode = true;
        for (int j = 0; j < _numBytes; j+=BytesPerMagic) {
            if (*(int*)&stateProperties[j] != *(int*)&existingProperties[j]) {
                foundNode = false;
                break;
            }
        }
        if (foundNode) {
            *existingNode = (Node*)[_stateLists[_lastCheckedHash][i] node];
            return true;
        }
        /*if (memcmp(stateProperties, propertiesList[i], _numBytes) == 0) {
            *existingNode = (Node*)[_stateLists[_lastCheckedHash][i] node];
            return true;
        }*/
    }
    return false;
}
-(void) addState:(MDDStateValues*)state {
    int numStates = _numPerHash[_lastCheckedHash];
    if (numStates == 0) {
        _maxPerHash[_lastCheckedHash] = 2;
        _stateLists[_lastCheckedHash] = malloc(2 * sizeof(MDDStateValues*));
        _statePropertiesLists[_lastCheckedHash] = malloc(2 * sizeof(char*));
    } else if (numStates == _maxPerHash[_lastCheckedHash]) {
        int newMax = _maxPerHash[_lastCheckedHash] * 2;
        _maxPerHash[_lastCheckedHash] = newMax;
        MDDStateValues** newList = malloc(newMax * sizeof(MDDStateValues*));
        char** newProperties = malloc(newMax * sizeof(char*));
        MDDStateValues** oldList = _stateLists[_lastCheckedHash];
        char** oldProperties = _statePropertiesLists[_lastCheckedHash];
        for (int i = 0; i < numStates; i++) {
            newList[i] = oldList[i];
            newProperties[i] = oldProperties[i];
        }
        free(oldList);
        free(oldProperties);
        _stateLists[_lastCheckedHash] = newList;
        _statePropertiesLists[_lastCheckedHash] = newProperties;
    }
    _stateLists[_lastCheckedHash][numStates] = state;
    _statePropertiesLists[_lastCheckedHash][numStates] = [state stateValues];
    _numPerHash[_lastCheckedHash] += 1;
    return;
}
-(void) dealloc {
    for (int i = 1; i < _width; i++) {
        if (_maxPerHash[i] > 0) {
            free(_stateLists[i]);
            free(_statePropertiesLists[i]);
        }
    }
    free(_stateLists);
    free(_statePropertiesLists);
    free(_numPerHash);
    free(_maxPerHash);
    [super dealloc];
}
@end

@implementation NormNodePair
-(id) initNormNodePair:(long)norm node:(Node *)node {
    self = [super init];
    self->norm = norm;
    self->node = node;
    return self;
}
@end

@implementation NodeHashTable {
    NSMutableArray** _nodeHashes;
}
-(id) initNodeHashTable:(int)width {
    [super init];
    _width = width;
    _nodeHashes = calloc(_width, sizeof(NSMutableArray*));
    return self;
}
-(NSMutableArray*) findBucketForStateHash:(NSUInteger)stateHash
{
    NSMutableArray* bucket = _nodeHashes[stateHash];
    if (bucket == NULL) {
        bucket = [[NSMutableArray alloc] init];
        _nodeHashes[stateHash] = bucket;
    }
    return bucket;
}
-(Node*) nodeWithState:(id)state inBucket:(NSMutableArray*)bucket {
    for (int bucket_index = 0; bucket_index < [bucket count]; bucket_index++) {
        Node* bucketNode = bucket[bucket_index];
        id bucketState = [bucketNode getState];
        if ([state isEqual:bucketState]) {
            return bucketNode;
        }
    }
    return nil;
}
-(NSMutableArray**) hashTable { return _nodeHashes; }
-(void) dealloc {
    for (int i = 0; i < _width; i++) {
        [_nodeHashes[i] release];
    }
    free(_nodeHashes);
        
    [super dealloc];
}
@end
