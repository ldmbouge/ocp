#import <objcp/CPMDDNode.h>

@implementation MDDNode
-(id) initSinkNode:(id<ORTrail>)trail defaultReverseState:(MDDStateValues*)reverseState layer:(int)layer numForwardBytes:(int)numForwardBytes numCombinedBytes:(int)numCombinedBytes {
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
    
    _forwardState = [[MDDStateValues alloc] initState:malloc(numForwardBytes) numBytes:numForwardBytes trail:_trail];
    _reverseState = [reverseState retain];
    [_reverseState setNode:self];
    _combinedState = [[MDDStateValues alloc] initState:malloc(numCombinedBytes) numBytes:numCombinedBytes trail:_trail];
    [_combinedState setNode:self];
    
    _isMergedNode = makeTRInt(_trail, 0);
    _isDeleted = makeTRInt(_trail, 0);
    
    _inForwardQueue = false;
    _inReverseQueue = false;
    
    return self;
}
-(id) initNode: (id<ORTrail>)trail minChildIndex:(int)minChildIndex maxChildIndex:(int)maxChildIndex state:(MDDStateValues*)state layer:(int)layer indexOnLayer:(int)indexOnLayer numReverseBytes:(int)numReverseBytes numCombinedBytes:(int)numCombinedBytes {
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
    
    _forwardState = [state retain];
    [_forwardState setNode:self];
    _reverseState = [[MDDStateValues alloc] initState:malloc(numReverseBytes) numBytes:numReverseBytes trail:trail];
    [_reverseState setNode:self];
    _combinedState = [[MDDStateValues alloc] initState:malloc(numCombinedBytes) numBytes:numCombinedBytes trail:trail];
    [_combinedState setNode:self];
    
    _isMergedNode = makeTRInt(_trail, 0);
    _isDeleted = makeTRInt(_trail, 0);
    
    _inForwardQueue = false;
    _inReverseQueue = false;
    
    return self;
}

-(void) dealloc {
    [_forwardState release];
    [_reverseState release];
    [_combinedState release];
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

-(void) updateForwardState:(char*)forwardState {
    [_forwardState replaceStateWith:forwardState trail:_trail];
}
-(void) updateReverseState:(char*)reverseState {
    [_reverseState replaceStateWith:reverseState trail:_trail];
}
-(void) updateCombinedState:(char*)combinedState {
    [_combinedState replaceStateWith:combinedState trail:_trail];
}

-(char*) reverseProperties {
    return [_reverseState stateValues];
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

-(bool) inQueue:(bool)forward {
    return forward ? _inForwardQueue : _inReverseQueue;
}
-(int) indexInQueue:(bool)forward {
    return forward ? _forwardQueueIndex : _reverseQueueIndex;
}
-(void) addToQueue:(bool)forward index:(int)index {
    if (forward) {
        _inForwardQueue = true;
        _forwardQueueIndex = index;
    } else {
        _inReverseQueue = true;
        _reverseQueueIndex = index;
    }
}
-(void) removeFromQueue:(bool)forward {
    if (forward) {
        _inForwardQueue = false;
    } else {
        _inReverseQueue = false;
    }
}

-(int) layer { return _layer; }
-(int) indexOnLayer { return _indexOnLayer._val; }
-(void) setIndexOnLayer:(int)index {_indexOnLayer = makeTRInt(_trail, index); }
-(void) updateIndexOnLayer:(int)index { assignTRInt(&_indexOnLayer,index,_trail); }
-(TRId*) children { return _children; }
-(int) numChildren { return _numChildren._val; }
-(bool) isChildless { return !_numChildren._val; }
-(ORTRIdArrayI*) parents { return _parents; }
-(int) numParents { return _numParents._val; }
-(bool) isParentless { return !_numParents._val; }
-(bool) isMerged { return _isMergedNode._val; }
-(void) setIsMergedNode:(bool)isMergedNode inCreation:(bool)inCreation {
    if (inCreation) {
        _isMergedNode = makeTRInt(_trail, isMergedNode);
    } else {
        assignTRInt(&_isMergedNode, isMergedNode, _trail);
    }
}
-(bool) isDeleted { return _isDeleted._val; }
-(void) deleteNode {
    assignTRInt(&_isDeleted, true, _trail);
    assignTRInt(&_indexOnLayer, -1, _trail);
}
-(bool) candidateForSplitting { return _isMergedNode._val && _numParents._val > 1; }
@end

@implementation MDDArc
-(id) initArc:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost state:(char*)state spec:(MDDStateSpecification*)spec {
    self = [super init];
    
    _spec = spec;
    
    _trail = trail;
    _hashWidth = [spec hashWidth];
    _bytesPerMagic = [MDDStateSpecification bytesPerMagic];
    
    _parent = parent;
    _arcValue = arcValue;
    [_parent addChild:self at:arcValue inPost:inPost];
    
    _child = makeTRId(_trail, [child retain]);
    _parentArcIndex = makeTRInt(_trail, [_child numParents]);
    [_child addParent:self inPost:inPost];
    
    _numForwardBytes = [_spec numForwardBytes];
    _passedForwardState = state;
    _forwardMagic = malloc(_numForwardBytes/_bytesPerMagic * sizeof(ORUInt));
    for (int i = 0; i < (_numForwardBytes/_bytesPerMagic); i++) {
        _forwardMagic[i] = [trail magic];
    }
    [self setHash];
    
    _equivalenceClasses = malloc([_spec numSpecs] * sizeof(TRInt));
    
    for (int i = 0; i < [_spec numSpecs]; i++) {
        _equivalenceClasses[i] = makeTRInt(_trail, 0);
    }
    _needToRecalcEquivalenceClasses = makeTRInt(_trail, 1);
    
    [self release];
    
    return self;
}

-(void) dealloc {
    free(_passedForwardState);
    free(_forwardMagic);
    free(_equivalenceClasses);
    [super dealloc];
}

-(void) updateChildTo:(MDDNode *)child inPost:(bool)inPost {
    [_child removeParent:self inPost:inPost];
    [self setChild:child inPost:inPost];
    [self updateParentArcIndex:[child numParents] inPost:inPost];
    [child addParent:self inPost:inPost];
    assignTRInt(&_needToRecalcEquivalenceClasses, 1, _trail);
}
-(void) setChild:(MDDNode*)child inPost:(bool)inPost {
    if (inPost) {
        [_child release];
        _child = makeTRId(_trail, [child retain]);
    } else {
        assignTRId(&_child, child, _trail);
    }
    assignTRInt(&_needToRecalcEquivalenceClasses, 1, _trail);
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

-(void) replaceForwardStateWith:(char *)newState trail:(id<ORTrail>)trail {
    ORUInt magic = [trail magic];
    for (int byteIndex = 0; byteIndex < _numForwardBytes; byteIndex+=_bytesPerMagic) {
        int magicIndex = byteIndex/_bytesPerMagic;
        switch (_bytesPerMagic) {
            case 2:
                if (*(short*)&_passedForwardState[byteIndex] != *(short*)&newState[byteIndex]) {
                    if (magic != _forwardMagic[magicIndex]) {
                        [trail trailShort:(short*)&_passedForwardState[byteIndex]];
                        _forwardMagic[magicIndex] = magic;
                    }
                    *(short*)&_passedForwardState[byteIndex] = *(short*)&newState[byteIndex];
                }
                break;
            case 4:
                if (*(int*)&_passedForwardState[byteIndex] != *(int*)&newState[byteIndex]) {
                    if (magic != _forwardMagic[magicIndex]) {
                        [trail trailInt:(int*)&_passedForwardState[byteIndex]];
                        _forwardMagic[magicIndex] = magic;
                    }
                    *(int*)&_passedForwardState[byteIndex] = *(int*)&newState[byteIndex];
                }
                break;
            default:
                @throw [[ORExecutionError alloc] initORExecutionError: "MDDArc: Method replaceStateWith not implemented for given BytesPerMagic"];
                break;
        }
    }
    [self updateHash];
    assignTRInt(&_needToRecalcEquivalenceClasses, 1, _trail);
}

-(MDDNode*) parent { return _parent; }
-(MDDNode*) child { return _child; }
-(int) arcValue { return _arcValue; }
-(int) parentArcIndex { return _parentArcIndex._val; }
-(char*) forwardState { return _passedForwardState; }


-(int) calcHash {
    const int numGroups = _numForwardBytes/_bytesPerMagic;
    int hashValue = 0;
    switch (_bytesPerMagic) {
        case 2:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 15 + *(short*)&_passedForwardState[s*_bytesPerMagic];
            }
            break;
        case 4:
            for (int s = 0; s < numGroups; s++) {
                hashValue = hashValue * 255 + *(int*)&_passedForwardState[s*_bytesPerMagic];
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
-(void) setHash { _forwardHash = makeTRInt(_trail, [self calcHash]); }
-(void) updateHash { assignTRInt(&_forwardHash, [self calcHash], _trail); }
-(int) hashValue { return _forwardHash._val; }

-(int) equivalenceClassFor:(int)constraint {
    if (_needToRecalcEquivalenceClasses._val) {
        for (int i = 0; i < [_spec numSpecs]; i++) {
            assignTRInt(&_equivalenceClasses[i], [_spec equivalenceClassFor:_passedForwardState reverse:[_child reverseProperties] constraint:i], _trail);
        }
        assignTRInt(&_needToRecalcEquivalenceClasses, 0, _trail);
    }
    return _equivalenceClasses[constraint]._val;
}
@end