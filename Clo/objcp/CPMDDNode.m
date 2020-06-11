#import <objcp/CPMDDNode.h>

@implementation MDDNode
-(id) initSinkNode:(id<ORTrail>)trail defaultBottomUpState:(MDDStateValues*)bottomUpState layer:(int)layer numTopDownBytes:(size_t)numTopDownBytes hashWidth:(int)hashWidth {
    self = [super init];
    
    _trail = trail;
    
    _layer = layer;
    _indexOnLayer = makeTRInt(_trail, 0);
    
    _minChildIndex = 0;
    _maxChildIndex = 0;
    _numChildren = makeTRInt(_trail, 0);
    _children = NULL;
    
    _numParents = makeTRInt(_trail, 0);
    _maxNumParents = makeTRInt(_trail,10);
    _parents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumParents._val];
    
    _topDownState = [[MDDStateValues alloc] initState:malloc(numTopDownBytes) numBytes:numTopDownBytes hashWidth:hashWidth trail:_trail];
    _bottomUpState = [bottomUpState retain];
    [_bottomUpState setNode:self];
    
    _isMergedNode = makeTRInt(_trail, 0);
    _isDeleted = makeTRInt(_trail, 0);
    
    _inTopDownQueue = false;
    _inBottomUpQueue = false;
    
    return self;
}
-(id) initNode: (id<ORTrail>)trail minChildIndex:(int)minChildIndex maxChildIndex:(int)maxChildIndex state:(MDDStateValues*)state layer:(int)layer indexOnLayer:(int)indexOnLayer numBottomUpBytes:(size_t)numBottomUpBytes hashWidth:(int)hashWidth {
    self = [super init];
    
    _trail = trail;
    
    _layer = layer;
    _indexOnLayer = makeTRInt(_trail, indexOnLayer);
    
    _minChildIndex = minChildIndex;
    _maxChildIndex = maxChildIndex;
    _numChildren = makeTRInt(_trail, 0);
    _children = (id __strong *)calloc(sizeof(TRId), _maxChildIndex-_minChildIndex +1);
    _children -= _minChildIndex;
    for (int i = _minChildIndex; i <= maxChildIndex; i++) {
        _children[i] = makeTRId(_trail, nil);
    }
    
    _numParents = makeTRInt(_trail, 0);
    _maxNumParents = makeTRInt(_trail,(_maxChildIndex-_minChildIndex+1));
    _parents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumParents._val];
    
    _topDownState = [state retain];
    [_topDownState setNode:self];
    _bottomUpState = [[MDDStateValues alloc] initState:malloc(numBottomUpBytes * sizeof(char)) numBytes:numBottomUpBytes hashWidth:hashWidth trail:trail];
    [_bottomUpState setNode:self];
    
    _isMergedNode = makeTRInt(_trail, 0);
    _isDeleted = makeTRInt(_trail, 0);
    
    _inTopDownQueue = false;
    _inBottomUpQueue = false;
    
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
                _children[i] = nil;
            }
        }
        _children += _minChildIndex;
        free(_children);
    }
    [super dealloc];
}

-(void) updateTopDownState:(char*)topDownState {
    [_topDownState replaceStateWith:topDownState trail:_trail];
}
-(void) updateBottomUpState:(char*)bottomUpState {
    [_bottomUpState replaceStateWith:bottomUpState trail:_trail];
}

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
-(void) removeParent:(MDDArc*)parentArc inPost:(bool)inPost {
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

-(void) addChild:(MDDArc*)childArc at:(int)index inPost:(bool)inPost {
    if (inPost) {
        _numChildren = makeTRInt(_trail, _numChildren._val+1);
        _children[index] = makeTRId(_trail, [childArc retain]);
    } else {
        if (_children[index] == NULL) {
            assignTRInt(&_numChildren, _numChildren._val+1, _trail);
        }
        assignTRId(&_children[index], childArc, _trail);
    }
}
-(void) removeChildAt:(int)index inPost:(bool)inPost {
    if (inPost) {
        _children[index] = makeTRId(_trail, nil);
        _numChildren = makeTRInt(_trail, _numChildren._val-1);
    } else {
        assignTRId(&_children[index], NULL, _trail);
        assignTRInt(&_numChildren, _numChildren._val-1, _trail);
    }
}

-(bool) inQueue:(bool)topDown {
    return topDown ? _inTopDownQueue : _inBottomUpQueue;
}
-(bool) inTopDownQueue {
    return _inTopDownQueue;
}
-(bool) inBottomUpQueue {
    return _inBottomUpQueue;
}
-(void) addToQueue:(bool)topDown {
    if (topDown) {
        _inTopDownQueue = true;
    } else {
        _inBottomUpQueue = true;
    }
}
-(void) addToTopDownQueue {
    _inTopDownQueue = true;
}
-(void) addToBottomUpQueue {
    _inBottomUpQueue = true;
}
-(void) removeFromQueue:(bool)topDown {
    if (topDown) {
        _inTopDownQueue = false;
    } else {
        _inBottomUpQueue = false;
    }
}

-(int) layer { return _layer; }
-(int) indexOnLayer { return _indexOnLayer._val; }
-(void) updateIndexOnLayer:(int)index { assignTRInt(&_indexOnLayer,index,_trail); }
-(TRId*) children { return _children; }
-(int) numChildren { return _numChildren._val; }
-(bool) isChildless { return !_numChildren._val; }
-(ORTRIdArrayI*) parents { return _parents; }
-(int) numParents { return _numParents._val; }
-(bool) isParentless { return !_numParents._val; }
-(bool) isMerged { return _isMergedNode._val; }
-(void) setIsMergedNode:(bool)isMergedNode { assignTRInt(&_isMergedNode, isMergedNode, _trail); }
-(bool) isDeleted { return _isDeleted._val; }
-(void) deleteNode {
    assignTRInt(&_isDeleted, true, _trail);
    assignTRInt(&_indexOnLayer, -1, _trail);
}
-(bool) candidateForSplitting { return _isMergedNode._val && _numParents._val > 1; }
@end

@implementation MDDArc
-(id) initArc:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost state:(char*)state numTopDownByte:(size_t)numTopDownBytes {
    self = [super init];
    
    _trail = trail;
    
    _parent = parent;
    _arcValue = arcValue;
    [_parent addChild:self at:arcValue inPost:inPost];
    
    _child = makeTRId(_trail, [child retain]);
    _parentArcIndex = makeTRInt(_trail, [_child numParents]);
    [_child addParent:self inPost:inPost];
    
    _numTopDownBytes = numTopDownBytes;
    _passedTopDownState = state;
    _topDownMagic = malloc(_numTopDownBytes/[MDDStateSpecification bytesPerMagic] * sizeof(ORUInt));
    for (int i = 0; i < (_numTopDownBytes/[MDDStateSpecification bytesPerMagic]); i++) {
        _topDownMagic[i] = [trail magic];
    }
    
    [self release];
    
    return self;
}

-(void) dealloc {
    free(_passedTopDownState);
    free(_topDownMagic);
    [super dealloc];
}

-(void) updateChildTo:(MDDNode *)child inPost:(bool)inPost {
    [_child removeParent:self inPost:inPost];
    [self setChild:child inPost:inPost];
    [self updateParentArcIndex:[child numParents] inPost:inPost];
    [child addParent:self inPost:inPost];
}
-(void) setChild:(MDDNode*)child inPost:(bool)inPost {
    if (inPost) {
        [_child release];
        _child = makeTRId(_trail, [child retain]);
    } else {
        assignTRId(&_child, child, _trail);
    }
}
-(void) updateParentArcIndex:(int)parentArcIndex inPost:(bool)inPost {
    if (inPost) {
        _parentArcIndex = makeTRInt(_trail, parentArcIndex);
    } else {
        assignTRInt(&_parentArcIndex, parentArcIndex, _trail);
    }
}
-(void) deleteArc:(bool)inPost {
    [_child removeParent:self inPost:inPost];
    [_parent removeChildAt:_arcValue inPost:inPost];
}

-(void) replaceTopDownStateWith:(char *)newState trail:(id<ORTrail>)trail {
    ORUInt magic = [trail magic];
    for (int byteIndex = 0; byteIndex < _numTopDownBytes; byteIndex+=[MDDStateSpecification bytesPerMagic]) {
        size_t magicIndex = byteIndex/[MDDStateSpecification bytesPerMagic];
        switch ([MDDStateSpecification bytesPerMagic]) {
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

-(MDDNode*) parent { return _parent; }
-(MDDNode*) child { return _child; }
-(int) arcValue { return _arcValue; }
-(int) parentArcIndex { return _parentArcIndex._val; }
-(char*) topDownState { return _passedTopDownState; }
@end
