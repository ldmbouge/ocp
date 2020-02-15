/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPTopDownMDD.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "ORMDDify.h"

@implementation BetterNodeHashTable
-(id) initBetterNodeHashTable:(int)width {
    self = [super init];
    _width = width;
    //_nodeHashes = calloc(_width, sizeof(NSMutableArray<MDDStateValues*>*));
    _stateLists = malloc(_width * sizeof(MDDStateValues**));
    _numPerHash = calloc(_width, sizeof(int));
    _maxPerHash = calloc(_width, sizeof(int));
    return self;
}
-(bool) hasNodeWithStateProperties:(char*)stateProperties hash:(NSUInteger)hash node:(Node**)existingNode {
    _lastCheckedHash = hash;
    if (_numPerHash[_lastCheckedHash] == 0) return false;
    MDDStateValues** stateList = _stateLists[_lastCheckedHash];
    for (int i = 0; i < _numPerHash[_lastCheckedHash]; i++) {
        if ([stateList[i] isEqualToStateProperties:stateProperties]) {
            *existingNode = [stateList[i] node];
            return true;
        }
    }
    return false;
}
-(bool) hasNodeWithState:(MDDStateValues*)state node:(Node**)existingNode {
    _lastCheckedHash = [state hash];
    if (_numPerHash[_lastCheckedHash] == 0) return false;
    MDDStateValues** stateList = _stateLists[_lastCheckedHash];
    for (int i = 0; i < _numPerHash[_lastCheckedHash]; i++) {
        if ([state isEqual:stateList[i]]) {
            *existingNode = [stateList[i] node];
            return true;
        }
    }
    return false;
    
    
    /*NSMutableArray* bucket = _nodeHashes[_lastCheckedHash];
    if (bucket == nil) return false;
    for (MDDStateValues* existingState in bucket) {
        if ([state isEqual:existingState]) {
            *existingNode = [existingState node];
            return true;
        }
    }
    return false;*/
    /*for (int bucket_index = 0; bucket_index < [bucket count]; bucket_index++) {
        Node* bucketNode = bucket[bucket_index];
        id bucketState = [bucketNode getState];
        if ([state isEqual:bucketState]) {
            return bucketNode;
        }
    }
    return nil;*/
}
-(void) addState:(MDDStateValues*)state {
    int numStates = _numPerHash[_lastCheckedHash];
    if (numStates == 0) {
        _maxPerHash[_lastCheckedHash] = 2;
        _stateLists[_lastCheckedHash] = malloc(2 * sizeof(MDDStateValues*));
    } else if (numStates == _maxPerHash[_lastCheckedHash]) {
        _maxPerHash[_lastCheckedHash] *= 2;
        MDDStateValues** newList = malloc(_maxPerHash[_lastCheckedHash] * sizeof(MDDStateValues*));
        MDDStateValues** oldList = _stateLists[_lastCheckedHash];
        for (int i = 0; i < numStates; i++) {
            newList[i] = oldList[i];
        }
        free(oldList);
        _stateLists[_lastCheckedHash] = newList;
    }
    _stateLists[_lastCheckedHash][numStates] = state;
    _numPerHash[_lastCheckedHash] += 1;
    return;
    
    
    /*NSMutableArray* bucket = _nodeHashes[_lastCheckedHash];
    if (bucket == nil) {
        bucket = [[NSMutableArray alloc] initWithObjects:state, nil];
        _nodeHashes[_lastCheckedHash] = bucket;
        return;
    }
    [bucket addObject:state];
    return;*/
}
-(void) dealloc {
    for (int i = 1; i < _width; i++) {
        if (_maxPerHash[i] > 0) {
            free(_stateLists[i]);
        }
    }
    free(_stateLists);
    free(_numPerHash);
    free(_maxPerHash);
    
    
    /*for (int i = 0; i < _width; i++) {
        [_nodeHashes[i] release];
    }
    free(_nodeHashes);*/
    [super dealloc];
}
@end

@implementation NodeHashTable
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
/*
@implementation NodeIndexHashTable
-(id) initNodeIndexHashTable:(int)width trail:(id<ORTrail>)trail {
    [super init];
    _width = width;
    _trail = trail;
    _nodeHashes = calloc(_width,sizeof(ORTRIntArrayI*));
    _bucketSize = calloc(_width,sizeof(TRInt));
    for (int i = 0; i < _width; i++) {
        _bucketSize[i] = makeTRInt(_trail,0);
        _nodeHashes[i] = nil;
    }
    return self;
}
-(ORTRIntArrayI*) findBucketForStateHash:(NSUInteger)stateHash {
    if (_nodeHashes[stateHash] == nil) {
        _nodeHashes[stateHash] = [[ORTRIntArrayI alloc] initORTRIntArrayWithTrail:_trail low:0 up:3 defaultValue:-1];
    }
    return _nodeHashes[stateHash];
}
-(void) add:(int)index toHash:(NSUInteger)hash {
    ORTRIntArrayI* bucket = _nodeHashes[hash];
    int bucketSize = _bucketSize[hash]._val;
    if (bucketSize == [bucket up]+1) {
        [bucket resize:bucketSize*2];
    }
    [bucket set:index at:bucketSize];
    assignTRInt(&_bucketSize[hash], bucketSize + 1, _trail);
}
-(void) remove:(int)index withHash:(NSUInteger)hash {
    ORTRIntArrayI* bucket = _nodeHashes[hash];
    int bucketSize = _bucketSize[hash]._val;
    for (int i = 0; i < bucketSize; i++) {
        if ([bucket at:i] == index) {
            [bucket set:[bucket at: bucketSize-1] at:i];
            [bucket set:-1 at:bucketSize-1];
            assignTRInt(&_bucketSize[hash],bucketSize-1,_trail);
            return;
        }
    }
}
-(void) dealloc {
    for (int i = 0; i < _width; i++) {
        [_nodeHashes[i] release];
    }
    free(_nodeHashes);
    free(_bucketSize);
        
    [super dealloc];
}
@end*/


@implementation Node
-(id) initNode: (id<ORTrail>) trail hashWidth:(int)hashWidth
{
    self = [super init];
    _trail = trail;
    _children = NULL;
    _numChildren = makeTRInt(_trail, 0);
    _minChildIndex = 0;
    _maxChildIndex = 0;
    _maxNumUniqueParents = makeTRInt(_trail,10);
    _uniqueParents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumUniqueParents._val];
    _parentCounts = [[ORTRIntArrayI alloc] initORTRIntArrayWithTrail:_trail range:[[ORIntRangeI alloc] initORIntRangeI:0 up:_maxNumUniqueParents._val]];
    _numUniqueParents = makeTRInt(_trail, 0);
    //_parentLookup = [[NodeIndexHashTable alloc] initNodeIndexHashTable:hashWidth trail:_trail];
    //Does parentLookup need to initialize all bucket values as ORTRIntArrayI at this point?  Does the whole NodeHashTable's array need to be trailable?  I think this ends up being too costly.
    _value = -1;
    
    _isMergedNode = makeTRInt(_trail, 0);
    _recalcRequired = false;
    
    return self;
}
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(MDDStateValues*)state hashWidth:(int)hashWidth
{
    self = [super init];
    _trail = trail;
    _minChildIndex = minChildIndex;
    _maxChildIndex = maxChildIndex;
    _value = value;
    _children = malloc((_maxChildIndex-_minChildIndex +1) * sizeof(TRId));
    _children -= _minChildIndex;
    for (int child = _minChildIndex; child <= maxChildIndex; child++) {
        _children[child] = makeTRId(_trail, nil);
    }
    
    _state = [state retain];
    
    _numChildren = makeTRInt(_trail, 0);
    _maxNumUniqueParents = makeTRInt(_trail,(maxChildIndex-minChildIndex+1));
    _uniqueParents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumUniqueParents._val];
    _parentCounts = [[ORTRIntArrayI alloc] initORTRIntArrayWithTrail:_trail range:[[[ORIntRangeI alloc] initORIntRangeI:0 up:_maxNumUniqueParents._val] autorelease]];
    _numUniqueParents = makeTRInt(_trail, 0);
    //_parentLookup = [[NodeIndexHashTable alloc] initNodeIndexHashTable:hashWidth trail:_trail];
    _value = value;
    
    _isMergedNode = makeTRInt(_trail, 0);
    _recalcRequired = false;
    [_state setNode:self];
    return self;
}
-(void) dealloc {
    [_state release];
    [_uniqueParents release];
    [_parentCounts release];
    if (_children != nil) {
        /*for (int i = _minChildIndex; i <= _maxChildIndex; i++) {
            [_children[i] release];
        }*/
        _children += _minChildIndex;
        free(_children);
    }
    //[_parentLookup release];
    [super dealloc];
}

-(int) layerIndex { return _layerIndex._val; }
-(void) setInitialLayerIndex:(int)index {
    _layerIndex = makeTRInt(_trail, index);
}
-(void) updateLayerIndex:(int)index {
    assignTRInt(&_layerIndex,index,_trail);
}
-(TRId) getState {
    return _state;
}
-(int) value {
    return _value;
}
-(TRId*) children {
    return _children;
}
-(int) numChildren {
    return _numChildren._val;
}
-(bool) recalcRequired {
    return _recalcRequired;
}
-(void) setRecalcRequired:(bool)value {
    _recalcRequired = value;
}
-(void) addChild:(Node*)child at:(int)index inPost:(bool)inPost {
    if (inPost) {
        assignTRInt(&_numChildren, _numChildren._val +1, _trail);
        _children[index] = makeTRId(_trail, child);
    } else {
        if (_children[index] == NULL) {
            assignTRInt(&_numChildren, _numChildren._val +1, _trail);
        }
        assignTRId(&_children[index], child, _trail);
    }
}
-(void) removeChildAt: (int) index {
    assignTRId(&_children[index], NULL, _trail);
    assignTRInt(&_numChildren, _numChildren._val -1, _trail);
}
-(void) removeChild:(Node*)child numTimes:(int)childCount updatingLVC:(TRInt*)variable_count {
    assignTRInt(&_numChildren, _numChildren._val - childCount, _trail);
    for (int child_index = _minChildIndex; childCount > 0; child_index++) {
        if (_children[child_index] == child) {
            assignTRId(&_children[child_index], NULL, _trail);
            assignTRInt(&variable_count[child_index],variable_count[child_index]._val-1,_trail);
            childCount--;
        }
    }
}
-(ORTRIdArrayI*) uniqueParents {
    return _uniqueParents;
}
-(ORTRIntArrayI*) parentCounts {
    return _parentCounts;
}
-(bool) hasParents {
    return _numUniqueParents._val;
}
-(int) numUniqueParents {
    return _numUniqueParents._val;
}
-(void) addFirstParent:(Node*)parent {
    [_uniqueParents set:parent at:0];
    [_parentCounts set:1 at:0];
    assignTRInt(&_numUniqueParents,1,_trail);
}
-(void) addParent: (Node*) parent {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:true];
    if (parentIndex >= 0) {
        [_parentCounts set:([_parentCounts at:parentIndex] + 1) at:parentIndex];
    } else {
        if (_maxNumUniqueParents._val == _numUniqueParents._val) {
            assignTRInt(&_maxNumUniqueParents, _maxNumUniqueParents._val * 2, _trail);
            [_uniqueParents resize:_maxNumUniqueParents._val];
            [_parentCounts resize:_maxNumUniqueParents._val];
        }
        [_uniqueParents set:parent at:_numUniqueParents._val];
        [_parentCounts set:1 at:_numUniqueParents._val];
        assignTRInt(&_numUniqueParents,_numUniqueParents._val+1,_trail);
    }
}
-(void) addParent: (Node*) parent count:(int)count {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:true];
    if (parentIndex >= 0) {
        [_parentCounts set:([_parentCounts at:parentIndex] + count) at:parentIndex];
    } else {
        if (_maxNumUniqueParents._val == _numUniqueParents._val) {
            assignTRInt(&_maxNumUniqueParents, _maxNumUniqueParents._val * 2, _trail);
            [_uniqueParents resize:_maxNumUniqueParents._val];
            [_parentCounts resize:_maxNumUniqueParents._val];
        }
        [_uniqueParents set:parent at:_numUniqueParents._val];
        [_parentCounts set:count at:_numUniqueParents._val];
        assignTRInt(&_numUniqueParents,_numUniqueParents._val+1,_trail);
    }
}
-(void) removeParentAt:(int)index {
    int finalParentIndex = _numUniqueParents._val-1;
    assignTRInt(&_numUniqueParents,finalParentIndex,_trail);
    //[_parentLookup remove:index withHash:[[_uniqueParents at:index] hashValue]];
    [_uniqueParents set:[_uniqueParents at:finalParentIndex] at:index];
    [_parentCounts set:[_parentCounts at:finalParentIndex] at:index];
    [_uniqueParents set:nil at:finalParentIndex];
    [_parentCounts set:0 at:finalParentIndex];
}
-(void) removeParentOnce: (Node*) parent {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:false];
    if (parentIndex >= 0) {
        int newCount = [_parentCounts at:parentIndex]-1;
        if (newCount == 0) {
            [self removeParentAt:parentIndex];
        } else {
            [_parentCounts set:newCount at:parentIndex];
        }
    }
}
-(void) removeParentValue: (Node*) parent {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:false];
    if (parentIndex >= 0) {
        [self removeParentAt:parentIndex];
    }
}
-(bool) isChildless {
    return !_numChildren._val;
}
-(bool) isParentless {
    return !_numUniqueParents._val;
}
-(bool) hasParent:(Node*)parent {
    return [self findUniqueParentIndexFor:parent addToHash:false] >= 0;
}
-(int) countForParent:(Node*)parent {
    int parentIndex = [self findUniqueParentIndexFor:parent addToHash:false];
    if (parentIndex < 0) {
        return 0;
    }
    return [self countForParentIndex:parentIndex];
}
-(int) countForParentIndex:(int)parent_index {
    return [_parentCounts at:parent_index];
}
-(void) takeParentsFrom:(Node*)other {
    ORTRIdArrayI* otherParents = [other uniqueParents];
    ORTRIntArrayI* otherParentCounts = [other parentCounts];
    for (int parentIndex = 0; parentIndex < [other numUniqueParents]; parentIndex++) {
        Node* parent = (Node*)[otherParents at:parentIndex];
        int count = [otherParentCounts at:parentIndex];
        [self addParent:parent count:count];
        [parent replaceChild:other with:self numTimes:count];
    }
}
-(void) replaceChild:(Node*)oldChild with:(Node*)newChild numTimes:(int)childCount {
    for (int child_index = _minChildIndex; childCount; child_index++) {
        if (_children[child_index] == oldChild) {
            assignTRId(&_children[child_index], newChild, _trail);
            childCount--;
        }
    }
}
-(int) findUniqueParentIndexFor:(Node*) parent addToHash:(bool)addToHash {
    for (int i = 0; i < _numUniqueParents._val; i++) {
        if ([_uniqueParents at:i] == parent) {
            return i;
        }
    }
    return -1;
    
    /*
    int hashValue = [parent hashValue];
    ORTRIntArrayI* bucket = [_parentLookup findBucketForStateHash:hashValue];
    
    for (int i = 0; i <= [bucket up]; i++) {
        int parentIndex = [bucket at:i];
        if (parentIndex == -1) {
            break;
        }
        if ([_uniqueParents at: parentIndex] == parent) {
            return parentIndex;
        }
    }
    if (addToHash) {
        [_parentLookup add:_numUniqueParents._val toHash:hashValue];
    }
    return -1;*/
}
-(bool) isMergedNode { return _isMergedNode._val; }
-(void) setIsMergedNode:(bool)isMergedNode { assignTRInt(&_isMergedNode, isMergedNode, _trail); }
@end

@implementation CPMDD
-(id) initCPMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x
{
    self = [super initCPCoreConstraint: engine];
    _trail = [engine trail];
    _x = x;
    _numVariables = [_x count];
    min_variable_index = [_x low];
    _min_domain_for_layer = malloc(_numVariables * sizeof(int));
    _max_domain_for_layer = malloc(_numVariables * sizeof(int));
    
    layers = malloc((_numVariables+1) * sizeof(ORTRIdArrayI*));
    layer_size = malloc((_numVariables+1) * sizeof(TRInt));
    max_layer_size = malloc((_numVariables+1) * sizeof(TRInt));
    layer_variable_count = malloc((_numVariables+1) * sizeof(TRInt*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
        max_layer_size[layer] = makeTRInt(_trail,10);
        layers[layer] = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:max_layer_size[layer]._val];
    }
    
    _layer_to_variable = malloc((_numVariables+1) * sizeof(int));
    _variable_to_layer = malloc((_numVariables+1) * sizeof(int));
    
    _variable_to_layer -= [_x low];
    
    _nextVariable = [_x low];
    
    return self;
}
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x spec:(MDDStateSpecification*)spec {
    self = [self initCPMDD:engine over:x];
    _spec = [spec retain];
    [_spec finalizeSpec:_trail hashWidth:100];
    return self;
}
-(NSSet*)allVars
{
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    ORUInt nb = 0;
    for(ORInt var = 0; var< _numVariables; var++)
        nb += !bound((CPIntVar*)[_x at: var]);
    return nb;
}
-(id<CPIntVarArray>) x
{
    return _x;
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPMDD:%02d %@>",_name,_x];
}
-(void) post
{
    _inPost = true;
    [self createRootAndSink];
    for (int layer = 1; layer < _numVariables; layer++) {
        [self assignVariableToLayer:layer];
        [self buildLayerByValue:layer];
        //[self buildLayer:layer];
        [self cleanLayer: layer];
    }
    [self buildLastLayer];
    //[self buildLayer:(int)_numVariables];
    [self addPropagationsAndTrimDomains];
    _inPost = false;
    return;
}
-(void) assignVariableToLayer:(int)layer {
    _variable_to_layer[_nextVariable] = layer;
    _layer_to_variable[layer] = _nextVariable;
    id<CPIntVar> var = [_x at:_nextVariable];
    int minDomain = [var min];
    int maxDomain = [var max];
    layer_variable_count[layer] = malloc((maxDomain-minDomain+1) * sizeof(TRInt));
    layer_variable_count[layer] -= minDomain;
    for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
        layer_variable_count[layer][domainVal] = makeTRInt(_trail, 0);
    }
    _min_domain_for_layer[layer] = minDomain;
    _max_domain_for_layer[layer] = maxDomain;
    _nextVariable++;
}
-(int) layerIndexForVariable:(int)variableIndex {
    return _variable_to_layer[variableIndex];
}
-(int) variableIndexForLayer:(int)layer {
    return _layer_to_variable[layer];
}
-(void) createRootAndSink
{
    Node *sink = [[Node alloc] initNode: _trail hashWidth:[_spec hashWidth]];
    [self addNode: sink toLayer:((int)_numVariables)];
    
    id state = [self generateRootState:_nextVariable];
    [self assignVariableToLayer:0];
    Node* root = [[Node alloc] initNode: _trail
                          minChildIndex:_min_domain_for_layer[0]
                          maxChildIndex:_max_domain_for_layer[0]
                                  value:[self variableIndexForLayer:0]
                                  state:state
                              hashWidth:[_spec hashWidth]];
    [self addNode:root toLayer:0];
    [state release];
    [root release];
    [sink release];
}
-(void) cleanLayer:(int)layer { return; }
-(void) afterPropagation { return; }
/*-(void) buildLayer:(int)layer
{
    int parentLayer = layer-1;
    //NSMutableDictionary<MDDStateValues*,Node*> *stateToNodeDict = [[NSMutableDictionary alloc] init];
    BetterNodeHashTable* nodeHashTable = [[BetterNodeHashTable alloc] initBetterNodeHashTable:[_spec hashWidth]];
    ORTRIdArrayI* parentNodes = layers[parentLayer];
    for (int parentNodeIndex = 0; parentNodeIndex < layer_size[parentLayer]._val; parentNodeIndex++) {
        Node* parentNode = [parentNodes at: parentNodeIndex];
        //[self createChildrenForNode:parentNode parentLayer:parentLayer stateToNodeDict:stateToNodeDict];
        [self createChildrenForNode:parentNode parentLayer:parentLayer nodeHashTable:nodeHashTable];
        if ([parentNode isNonVitalAndChildless]) {
            [self removeChildlessNodeFromMDD:parentNode fromLayer:parentLayer inPost:true];
            parentNodeIndex--;
        }
    }
    if (!layer_size[layer]._val) {
        failNow();
    }
    //[stateToNodeDict release];
    [nodeHashTable release];
}*/
-(void) buildLastLayer {
    int parentLayer = (int)_numVariables-1;
    int minDomain = _min_domain_for_layer[parentLayer];
    int maxDomain = _max_domain_for_layer[parentLayer];
    int parentVariableIndex = _layer_to_variable[parentLayer];
    int parentLayerSize = layer_size[parentLayer]._val;
    id<CPIntVar> parentVariable = _x[parentVariableIndex];
    ORTRIdArrayI* parentNodes = layers[parentLayer];
    Node* sink = [layers[_numVariables] at: 0];
    for (int edgeValue = minDomain; edgeValue <= maxDomain; edgeValue++) {
        if ([parentVariable member: edgeValue]) {
            for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
                Node* parentNode = [parentNodes at: parentNodeIndex];
                MDDStateValues* parentState = getState(parentNode);
                if([_spec canChooseValue:edgeValue forVariable:parentVariableIndex withState:parentState]) {
                    [sink addParent:parentNode];
                    [parentNode addChild:sink at:edgeValue inPost:_inPost];
                    assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                }
            }
        }
    }
    for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
        Node* parentNode = [parentNodes at: parentNodeIndex];
        if ([parentNode isChildless]) {
            [self removeChildlessNodeFromMDDAtIndex:parentNodeIndex fromLayer:parentLayer];
            parentNodeIndex--;
            parentLayerSize--;
        }
    }
}
-(void) buildLayerByValue:(int)layer {
    int parentLayer = layer-1;
    int parentVariableIndex = _layer_to_variable[parentLayer];
    int childVariableIndex = _layer_to_variable[layer];
    int minDomain = _min_domain_for_layer[parentLayer];
    int maxDomain = _max_domain_for_layer[parentLayer];
    int parentLayerSize = layer_size[parentLayer]._val;
    int hashWidth = [_spec hashWidth];
    int childMinDomain = _min_domain_for_layer[parentLayer+1];
    int childMaxDomain = _max_domain_for_layer[parentLayer+1];
    id<CPIntVar> parentVariable = _x[parentVariableIndex];
    BetterNodeHashTable* nodeHashTable = [[BetterNodeHashTable alloc] initBetterNodeHashTable:[_spec hashWidth]];
    //NSMapTable<MDDStateValues*,Node*> *stateToNodeMap = [[NSMapTable alloc] init];
    ORTRIdArrayI* parentNodes = layers[parentLayer];
    for (int edgeValue = minDomain; edgeValue <= maxDomain; edgeValue++) {
        if ([parentVariable member: edgeValue]) {
            for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
                Node* parentNode = [parentNodes at: parentNodeIndex];
                MDDStateValues* parentState = getState(parentNode);
                char* newStateProperties;
                if ([_spec canCreateState:&newStateProperties fromParent:parentState assigningVariable:parentVariableIndex toValue:edgeValue]) {
                    NSUInteger hashValue = [_spec hashValueFor:newStateProperties];
                    Node* childNode;
                    bool nodeExists = [nodeHashTable hasNodeWithStateProperties:newStateProperties hash:hashValue node:&childNode];
                    //childNode = [stateToNodeMap objectForKey:newState];
                    if (!nodeExists) {
                        MDDStateValues* newState = [_spec createStateWith:newStateProperties];
                        childNode = [[Node alloc] initNode: _trail
                                             minChildIndex:childMinDomain
                                             maxChildIndex:childMaxDomain
                                                     value:childVariableIndex
                                                     state:newState
                                                 hashWidth:hashWidth];
                        [self addNode:childNode toLayer:layer];
                        [nodeHashTable addState:newState];
                        //[stateToNodeMap setObject:childNode forKey:newState];
                        [childNode addFirstParent:parentNode];
                        [parentNode addChild:childNode at:edgeValue inPost:_inPost];
                        assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                        [newState release];
                        [childNode release];
                    } else {
                        free(newStateProperties);
                        [childNode addParent:parentNode];
                        [parentNode addChild:childNode at:edgeValue inPost:_inPost];
                        assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                    }
                }
            }
        }
    }
    if (!layer_size[layer]._val) {
        failNow();
    }
    [nodeHashTable release];
    //[stateToNodeMap release];
    if (layer != 1) {
        for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
            Node* parentNode = [parentNodes at: parentNodeIndex];
            if ([parentNode isChildless]) {
                [self removeChildlessNodeFromMDDAtIndex:parentNodeIndex fromLayer:parentLayer];
                parentNodeIndex--;
                parentLayerSize--;
            }
        }
    }
}
//-(void) createChildrenForNode:(Node*)parentNode parentLayer:(int)parentLayer stateToNodeDict:(NSMutableDictionary<MDDStateValues*,Node*>*)stateToNodeDict
/*-(void) createChildrenForNode:(Node*)parentNode parentLayer:(int)parentLayer nodeHashTable:(BetterNodeHashTable*)nodeHashTable
{
    int minDomain = _min_domain_for_layer[parentLayer];
    int maxDomain = _max_domain_for_layer[parentLayer];
    int childMinDomain, childMaxDomain;
    int parentValue = _layer_to_variable[parentLayer];
    MDDStateValues* parentState = [parentNode getState];
    bool lastLayer = (parentLayer == _numVariables-1);
    if (!lastLayer) {
        childMinDomain = _min_domain_for_layer[parentLayer+1];
        childMaxDomain = _max_domain_for_layer[parentLayer+1];
    }
    for (int edgeValue = minDomain; edgeValue <= maxDomain; edgeValue++) {
        if ([_x[parentValue] member: edgeValue]) {
            MDDStateValues* newState;
            bool canCreateState = [_spec canCreateState:&newState fromParent:parentState assigningVariable:parentValue toValue:edgeValue];
            if (canCreateState) {
                Node* childNode = nil;
                if (!lastLayer) {
                    //childNode = [stateToNodeDict objectForKey:newState];
                    bool nodeExists = [nodeHashTable hasNodeWithState:newState node:&childNode];
                    if (!nodeExists) {
                        childNode = [[Node alloc] initNode: _trail
                                             minChildIndex:childMinDomain
                                             maxChildIndex:childMaxDomain
                                                     value:[self variableIndexForLayer:parentLayer + 1]
                                                     state:newState
                                                 hashWidth:[_spec hashWidth]];
                        [self addNode:childNode toLayer:parentLayer+1];
                        //[stateToNodeDict setObject:childNode forKey:newState];
                        [nodeHashTable addState:newState];
                        [childNode release];
                    }
                } else {
                    childNode = [layers[_numVariables] at: 0];
                }
                [newState release];
                [parentNode addChild:childNode at:edgeValue];
                [childNode addParent:parentNode];
                assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
            }
        }
    }
}*/
-(void) addPropagationsAndTrimDomains
{
    for(ORInt layer = 0; layer < _numVariables; layer++) {
        [self trimDomainsFromLayer:layer];
        [self addPropagationToLayer: layer];
    }
}
-(void) trimDomainsFromLayer:(ORInt)layer
{
    id<CPIntVar> variable = _x[[self variableIndexForLayer:layer]];
    TRInt* variable_count = layer_variable_count[layer];
    for (int value = _min_domain_for_layer[layer]; value <= _max_domain_for_layer[layer]; value++) {
        if (!variable_count[value]._val && [variable member:value]) {
            [variable remove: value];
        }
    }
}
-(void) addPropagationToLayer:(ORInt)layer
{
    int variableIndex = [self variableIndexForLayer:layer];
    if (!bound((CPIntVar*)_x[variableIndex])) {
        [_x[variableIndex] whenChangeDo:^() {
            _highestLayerChanged = (int)_numVariables+1;
            _lowestLayerChanged = 0;
            
            bool layerChanged = false;
            for (int domain_val = _min_domain_for_layer[layer]; domain_val <= _max_domain_for_layer[layer]; domain_val++) {
                if (![_x[variableIndex] member:domain_val] && layer_variable_count[layer][domain_val]._val) {
                    [self trimValueFromLayer: layer :domain_val ];
                    layerChanged = true;
                }
            }
            if (layerChanged) {
                for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
                    int variableForTrimming = [self variableIndexForLayer:layer_index];
                    for (int domain_val = _min_domain_for_layer[layer]; domain_val <= _max_domain_for_layer[layer]; domain_val++) {
                        if (![_x[variableForTrimming] member:domain_val] && layer_variable_count[layer_index][domain_val]._val) {
                            [self trimValueFromLayer: layer_index :domain_val ];
                        }
                    }
                }
                [self afterPropagation];
                for (int i = _highestLayerChanged; i <= min(_lowestLayerChanged,(int)_numVariables-1); i++) {
                    [self trimDomainsFromLayer:i];
                }
            }
            //_todo = CPChecked;
        } onBehalf:self];
    }
}
-(id) generateRootState:(int)variableValue
{
    return [_spec createRootState:variableValue];
}
-(MDDStateValues*) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    MDDStateValues* parentState = getState(parentNode);
    return [_spec createStateFrom:parentState assigningVariable:[parentNode value] withValue:value];
}
-(MDDStateValues*) generateTempStateFromParent:(Node*)parentNode withValue:(int)value
{
    MDDStateValues* parentState = getState(parentNode);
    return [_spec createTempStateFrom:parentState assigningVariable:[parentNode value] withValue:value];
}
-(void) addNode:(Node*)node toLayer:(int)layer_index
{
    int layerSize = layer_size[layer_index]._val;
    if (max_layer_size[layer_index]._val == layerSize) {
        assignTRInt(&max_layer_size[layer_index], max_layer_size[layer_index]._val*2, _trail);
        [layers[layer_index] resize:max_layer_size[layer_index]._val];
    }
    [node setInitialLayerIndex:layerSize];
    [layers[layer_index] set:node at:layerSize];
    assignTRInt(&layer_size[layer_index], layerSize+1, _trail);
}
-(void) removeNode:(Node*)node onLayer:(int)node_layer {
    [self removeNodeAt:[node layerIndex] onLayer:node_layer];
}
-(void) removeNodeAt:(int)index onLayer:(int)node_layer {
    ORTRIdArrayI* layer = layers[node_layer];
    
    int finalNodeIndex = layer_size[node_layer]._val-1;
    if (index != finalNodeIndex) {
        Node* movedNode = [layer at:finalNodeIndex];
        [movedNode updateLayerIndex:index];
        [layer set:movedNode at:index];
    }
    [layer set:NULL at:finalNodeIndex];
    assignTRInt(&layer_size[node_layer], finalNodeIndex,_trail);
}
-(int) removeChildlessNodeFromMDDAtIndex:(int)nodeIndex fromLayer:(int)layer {
    int highestLayerChanged = [self checkParentsOfChildlessNode:[layers[layer] at:nodeIndex] parentLayer:layer-1];
    [self removeNodeAt: nodeIndex onLayer:layer];
    return highestLayerChanged;
}
-(int) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer {
    if (layer == 0) { failNow(); }
    int highestLayerChanged = [self checkParentsOfChildlessNode:node parentLayer:layer-1];
    [self removeNode: node onLayer:layer];
    return highestLayerChanged;
}
-(int) checkParentsOfChildlessNode:(Node*)node parentLayer:(int)layer {
    int numUniqueParents = [node numUniqueParents];
    ORTRIdArrayI* parents = [node uniqueParents];
    int highestLayerChanged = layer;
    
    for (int parentIndex = 0; parentIndex < numUniqueParents; parentIndex++) {
        Node* parent = [parents at: parentIndex];
        int countForParent = [node countForParentIndex:parentIndex];
        [parent removeChild:node numTimes:countForParent updatingLVC:layer_variable_count[layer]];
        if ([parent isChildless]) {
            highestLayerChanged = min(highestLayerChanged,[self removeChildlessNodeFromMDD:parent fromLayer:layer]);
        }
    }
    return highestLayerChanged;
}
-(int) removeParentlessNodeFromMDD:(Node*)node fromLayer:(int)layer {
    //TODO: Improve this function (may be improved with using real edges?).  Ideally only iterate over actual children.  Currently has to iterate over all domain vals, then for each domain val with a child, need to iterate over all of that child's parents
    if (layer == _numVariables) { failNow(); }
    Node* *children = [node children];
    int childLayer = layer+1;
    int numChildren = [node numChildren];
    int lowestLayerChanged = layer;
    
    for (int child_index = _min_domain_for_layer[layer]; numChildren; child_index++) {
        Node* childNode = children[child_index];
        if (childNode != NULL) {
            [node removeChildAt: child_index];
            [childNode removeParentOnce: node];
            assignTRInt(&layer_variable_count[layer][child_index], layer_variable_count[layer][child_index]._val-1, _trail);
            if ([childNode isParentless]) {
                lowestLayerChanged = max(lowestLayerChanged, [self removeParentlessNodeFromMDD:childNode fromLayer:childLayer]);
            } else {
                if ([childNode isMergedNode]) {
                    lowestLayerChanged = max(lowestLayerChanged,childLayer);
                    [childNode setRecalcRequired:true];
                }
            }
            numChildren--;
        }
    }
    [self removeNode: node onLayer:layer];
    return lowestLayerChanged;
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    ORTRIdArrayI* layer = layers[layer_index];
    int numEdgesToDelete = layer_variable_count[layer_index][value]._val;
    int highestLayerChanged = layer_index;
    int lowestLayerChanged = layer_index;
    for (int node_index = 0; numEdgesToDelete; node_index++) {
        Node* node = [layer at: node_index];
        Node* childNode = [node children][value];
        if (childNode != NULL) {
            [childNode removeParentOnce:node];
            if ([childNode isParentless]) {
                lowestLayerChanged = max(lowestLayerChanged, [self removeParentlessNodeFromMDD:childNode fromLayer:(layer_index+1)]);
            }
            if ([node isChildless]) {
                highestLayerChanged = max(highestLayerChanged, [self removeChildlessNodeFromMDD:node fromLayer:layer_index]);
                node_index--;
            }
            numEdgesToDelete--;
        }
    }
    _highestLayerChanged = min(_highestLayerChanged,highestLayerChanged);
    _lowestLayerChanged = max(_lowestLayerChanged,lowestLayerChanged);
    assignTRInt(&layer_variable_count[layer_index][value], 0, _trail);
}
-(void) dealloc {
    for (int i = 0; i < _numVariables; i++) {
        [layers[i] release];
        layer_variable_count[i] += _min_domain_for_layer[i];
        free(layer_variable_count[i]);
    }
    [layers[_numVariables] release];
    free(layers);
    free(layer_size);
    free(max_layer_size);
    free(_layer_to_variable);
    _variable_to_layer += min_variable_index;
    free(_variable_to_layer);
    free(_min_domain_for_layer);
    free(_max_domain_for_layer);
    [_spec release];
    [super dealloc];
}

-(ORInt) recommendationFor: (ORInt) variableIndex
{
    return [_x[variableIndex] min];
}

-(void) printGraph {
    //[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat: @"/Users/rebeccagentzel/graphs/%d.dot", ] contents:nil attributes:nil];
    NSMutableDictionary* nodeNames = [[NSMutableDictionary alloc] init];
    
    NSMutableString* output = [NSMutableString stringWithFormat: @"\ndigraph {\n"];
    
    for (int layer = 0; layer < _numVariables; layer++) {
        for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
            Node* node = [layers[layer] at: node_index];
            if (node != nil) {
                for (int child_index = _min_domain_for_layer[layer]; child_index <= _max_domain_for_layer[layer]; child_index++) {
                    Node* child = [node children][child_index];
                    if (child != nil) {
                        NSValue* nodePointerValue = [NSValue valueWithPointer:node];
                        NSValue* childPointerValue = [NSValue valueWithPointer:child];
                        
                        if (![nodeNames objectForKey:[NSValue valueWithPointer: node]]) {
                            [nodeNames setObject:[NSNumber numberWithInt: (int)[nodeNames count]] forKey:nodePointerValue];
                        }
                        if (![nodeNames objectForKey:[NSValue valueWithPointer: child]]) {
                            [nodeNames setObject:[NSNumber numberWithInt: (int)[nodeNames count]] forKey:childPointerValue];
                        }
                        if (child_index == 0) {
                        [output appendString: [NSString stringWithFormat: @"%d -> %d [label=\"%d\" style=dotted];\n", [nodeNames[nodePointerValue] intValue], [nodeNames[childPointerValue] intValue], child_index]];
                        } else {
                            [output appendString: [NSString stringWithFormat: @"%d -> %d [label=\"%d\"];\n", [nodeNames[nodePointerValue] intValue], [nodeNames[childPointerValue] intValue], child_index]];
                        }
                        //[output appendString: [NSString stringWithFormat: @"%d -> %d [label=\"%d,%d\"];\n", [nodeNames[nodePointerValue] intValue], [nodeNames[childPointerValue] intValue], [child shortestPath], [child longestPath]]];
                    }
                }
            }
        }
    }
    [output appendString: @"}\n"];
    
    int numBound = 0;
    for (int var_index=[_x low]; var_index <= [_x up]; var_index++) {
        numBound += [_x[var_index] bound];
    }
    
    [output writeToFile: [NSString stringWithFormat: @"/Users/rebeccagentzel/graphs/%d.dot", numBound] atomically: YES encoding:NSUTF8StringEncoding error: nil];
    [nodeNames release];
}

-(void) DEBUGTestLayerVariableCountCorrectness
{
    //DEBUG code:  Checks if layer_variable_count correctly represents the edges on the layer.
    for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
        for (int domain_val = _min_domain_for_layer[layer_index]; domain_val <= _max_domain_for_layer[layer_index]; domain_val++) {
            int count = 0;
            for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
                Node* node = [layers[layer_index] at: node_index];
                Node** children = [node children];
                
                if (children[domain_val] != NULL) {
                    count++;
                }
            }
            if (layer_variable_count[layer_index][domain_val]._val != count) {
                int i =0;
            }
        }
    }
}

-(void) DEBUGTestParentChildParity
{
    //DEBUG code:  Checks if every node's parent-child connections are mirrored.  That is, if a parent has a child, the child has the parent, and vice-versa.
    
    
    for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable:[_spec hashWidth]];
            Node* node = [layers[layer_index] at: node_index];
            Node** children = [node children];
            for (int child_index = _min_domain_for_layer[layer_index]; child_index <= _max_domain_for_layer[layer_index]; child_index++) {
                bool added = false;
                Node* child = children[child_index];
                
                if (child != NULL) {
                    NSUInteger hashValue = [child hash];
                    NSMutableArray* bucket = [nodeHashTable findBucketForStateHash:hashValue];
                    for (int bucket_index = 0; bucket_index < [bucket count]; bucket_index++) {
                        NSMutableArray* nodeCountPair = bucket[bucket_index];
                        Node* bucketNode = [nodeCountPair objectAtIndex:0];
                        int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                        if ([bucketNode isEqual:child]) {
                            [bucket setObject:[[NSMutableArray alloc] initWithObjects:bucketNode,[NSNumber numberWithInt:(bucketCount+1)], nil] atIndexedSubscript:bucket_index];
                            added=true;
                            break;
                        }
                    }
                    if (!added) {
                        NSArray* nodeCountPair = [[NSArray alloc] initWithObjects:child, [NSNumber numberWithInt:1], nil];
                        [bucket addObject:nodeCountPair];
                    }
                }
            }
            
            NSMutableArray** hashTable = [nodeHashTable hashTable];
            for (int i = 0; i < [_spec hashWidth]; i++) {
                NSArray* bucket = hashTable[i];
                for (NSArray* nodeCountPair in bucket) {
                    Node* bucketNode = [nodeCountPair objectAtIndex:0];
                    int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                    
                    if ([bucketNode countForParent:node] != bucketCount) {
                        int i =0;
                    }
                }
            }
            [nodeHashTable release];
        }
    }
}
@end

@implementation CPMDDRestriction
-(id) initCPMDDRestriction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize
{
    self = [super initCPMDD:engine over:x];
    restricted_size = restrictionSize;
    return self;
}
-(void) cleanLayer:(int)layer
{
    while (layer_size[layer]._val > restricted_size) {
        [self removeANodeFromLayer: layer];
    }
}
-(void) removeANodeFromLayer:(int)layer
{
    Node* node = [self findNodeToRemove:layer];
    [self removeChildlessNodeFromMDD:node fromLayer:layer];
}
-(Node*) findNodeToRemove:(int)layer
{
    return [layers[layer] at: 0];
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPMDDRestriction:%02d %@>",_name,_x];
}
@end

@implementation CPMDDRelaxation
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize
{
    self = [super initCPMDD:engine over:x];
    _relaxation_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification*)spec {
    self = [super initCPMDD:engine over:x];
    _spec = [spec retain];
    _relaxation_size = relaxationSize;
    [_spec finalizeSpec:_trail hashWidth:relaxationSize*2];
    return self;
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    ORTRIdArrayI* layer = layers[layer_index];
    int numEdgesToDelete = layer_variable_count[layer_index][value]._val;
    int highestLayerChanged = layer_index;
    int lowestLayerChanged = layer_index;
    
    for (int node_index = 0; numEdgesToDelete; node_index++) {
        Node* node = [layer at: node_index];
        Node* childNode = [node children][value];
        if (childNode != NULL) {
            [node removeChildAt: value];
            [childNode removeParentOnce:node];
            if ([childNode isParentless]) {
                lowestLayerChanged = max(lowestLayerChanged, [self removeParentlessNodeFromMDD:childNode fromLayer:(layer_index+1)]);
            } else {
                if ([childNode isMergedNode]) {
                    lowestLayerChanged = max(lowestLayerChanged, layer_index+1);
                    [childNode setRecalcRequired:true];
                }
            }
            if ([node isChildless]) {
                highestLayerChanged = min(highestLayerChanged, [self removeChildlessNodeFromMDD:node fromLayer:layer_index]);
                node_index--;
            }
            numEdgesToDelete--;
        }
    }
    _highestLayerChanged = min(_highestLayerChanged,highestLayerChanged);
    _lowestLayerChanged = max(_lowestLayerChanged,lowestLayerChanged);
    assignTRInt(&layer_variable_count[layer_index][value],0, _trail);
}
-(void) afterPropagation {
    [self rebuild];
}
-(void) rebuild
{
    void(*mth)(id,SEL,int) = [self methodForSelector:@selector(splitNodesOnLayer:)];
    for (int layer = _highestLayerChanged; layer <=  min(_lowestLayerChanged,(int)_numVariables-1); layer++) {
        mth(self,@selector(splitNodesOnLayer:),layer);
        if (layer_size[layer+1]._val == 0) {
            failNow();
        }
    }
    return;
}
-(void) splitNodesOnLayer:(int)layer
{
    NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable:[_spec hashWidth]];
    int minDomain = _min_domain_for_layer[layer];
    int maxDomain = _max_domain_for_layer[layer];
    int initial_layer_size = layer_size[layer]._val;
    bool addedNewNode;
    for (int node_index = 0; node_index < initial_layer_size && layer_size[layer]._val < _relaxation_size; node_index++) {
        Node* node = [layers[layer] at: node_index];
        if ([node isMergedNode]) { //Find a relaxed node to split
            addedNewNode = false;
            Node** oldNodeChildren = [node children];
            ORTRIdArrayI* parents = [node uniqueParents];
            while (layer_size[layer]._val < _relaxation_size && [node hasParents]) {
                //All edges going into this node should be examined.  To get these edges, look at the parents
                Node* parent = [parents at:0];
                Node** parentsChildren = [parent children];
                for (int child_index = _min_domain_for_layer[layer-1]; child_index <= _max_domain_for_layer[layer-1] && [node hasParents] && layer_size[layer]._val < _relaxation_size; child_index++) {
                    Node* parentsChild = parentsChildren[child_index];
                    if ([node isEqual:parentsChild]) { //Found an edge that was going into a relaxed node.  Recreate a node for it.
                        MDDStateValues* state = [self generateStateFromParent:parent withValue:child_index];
                        NSUInteger hashValue = [state hash];
                        NSMutableArray* bucket = [nodeHashTable findBucketForStateHash:hashValue];
                        Node* newNode = [nodeHashTable nodeWithState:state inBucket:bucket];
                        if (newNode == nil) {
                            newNode = [[Node alloc] initNode: _trail
                                               minChildIndex:minDomain
                                               maxChildIndex:maxDomain
                                                       value:[self variableIndexForLayer:layer]
                                                       state:state
                                                   hashWidth:[_spec hashWidth]];
                            [self addNode:newNode toLayer:layer];
                            [state release];
                            //[_trail trailRelease:newNode];
                            [newNode release];
                            for (int domain_val = minDomain; domain_val <= maxDomain; domain_val++) {
                                Node* oldNodeChild = oldNodeChildren[domain_val];
                                if (oldNodeChild != NULL) {
                                    if ([_spec canChooseValue:domain_val forVariable:[self variableIndexForLayer:layer] withState:state]) {
                                        //Check if this arc should exist from the old state
                                        [newNode addChild:oldNodeChild at:domain_val inPost:_inPost];
                                        [oldNodeChild addParent: newNode];
                                        assignTRInt(&layer_variable_count[layer][domain_val], layer_variable_count[layer][domain_val]._val+1, _trail);
                                        [oldNodeChild setRecalcRequired:true];
                                        _lowestLayerChanged = max(_lowestLayerChanged, layer+1);
                                    }
                                }
                            }
                            addedNewNode = true;
                            [bucket addObject:newNode];
                        }
                        [parent addChild:newNode at:child_index inPost:_inPost];
                        [newNode addParent:parent];
                        [node removeParentOnce:parent];
                    }
                }
            }
            if (!addedNewNode) { //If the node was relaxed, but should be removed without any new nodes, need to decrement the for-loop counter
                for (int domain_val = _min_domain_for_layer[layer]; domain_val <= _max_domain_for_layer[layer]; domain_val++) {
                    Node* oldNodeChild = oldNodeChildren[domain_val];
                    if (oldNodeChild != NULL) {
                        assignTRInt(&layer_variable_count[layer][domain_val], layer_variable_count[layer][domain_val]._val-1, _trail);
                        [node removeChildAt:domain_val];
                        [oldNodeChild removeParentOnce:node];
                    }
                }
                [self removeNodeAt:node_index onLayer:layer];
                node_index--;
                initial_layer_size--;
            } else if ([node isParentless]) {
                for (int domain_val = _min_domain_for_layer[layer]; domain_val <= _max_domain_for_layer[layer]; domain_val++) {
                    Node* oldNodeChild = oldNodeChildren[domain_val];
                    if (oldNodeChild != NULL) {
                        [node removeChildAt:domain_val];
                        [oldNodeChild removeParentOnce:node];
                        assignTRInt(&layer_variable_count[layer][domain_val], layer_variable_count[layer][domain_val]._val-1, _trail);
                    }
                }
                [self removeNodeAt:node_index onLayer:layer];
            } else {
                [node setRecalcRequired:true];
            }
        }
    }

    //Does it actually have to check this so thoroughly each time?
    for (int node_index = 0; node_index < layer_size[layer+1]._val; node_index++) {
        Node* node = [layers[layer+1] at: node_index];
        if ([node isParentless]) {
            _lowestLayerChanged = max(_lowestLayerChanged,[self removeParentlessNodeFromMDD:node fromLayer:layer+1]);
            node_index--;
        }
    }
    
    [self recalcNodesOnLayer:layer];
    
    [nodeHashTable release];
}
-(void) recalcNodesOnLayer:(int)layer_index
{
    ORInt variableIndex = [self variableIndexForLayer:layer_index];
    ORTRIdArrayI* layerArray = layers[layer_index];
    for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
        Node* node = [layerArray at:node_index];
        if ([node recalcRequired]) {
            bool isMergedNode;
            MDDStateValues* oldState = getState(node);
            MDDStateValues* newState = [self calculateStateFromParentsOf:node onLayer:layer_index isMerged:&isMergedNode];
            [node setIsMergedNode:isMergedNode];
            if (![oldState isEqual:newState]) {
                [_spec replaceState:oldState with:newState];
                [self reevaluateChildrenAfterParentStateChange:node onLayer:layer_index andVariable:variableIndex];
                _lowestLayerChanged = max(_lowestLayerChanged, layer_index+1);
            }
            [node setRecalcRequired:false];
            [newState release];
        }
    }
}
-(MDDStateValues*) calculateStateFromParentsOf:(Node*)node onLayer:(int)layer isMerged:(bool*)isMergedNode
{
    MDDStateValues* newState = nil;
    *isMergedNode = false;
    ORTRIdArrayI* parents = [node uniqueParents];
    for (int parent_index = 0; parent_index < [node numUniqueParents]; parent_index++) {
        Node* parent = [parents at:parent_index];
        TRId* children = [parent children];
        int countForParent = [node countForParentIndex:parent_index];
        for (int child_index = _min_domain_for_layer[layer]; countForParent > 0; child_index++) {
            Node* child = children[child_index];
            if ([child isEqual:node]) {
                MDDStateValues* tempState = [self generateTempStateFromParent:parent withValue:child_index];
                if (newState == nil) {
                    newState = tempState;
                } else {
                    if (![newState isEqual:tempState]) {
                        *isMergedNode = true;
                        [_spec mergeState:newState with:tempState];
                    }
                    [tempState release];
                }
                countForParent--;
            }
        }
    }
    return newState;
}
-(void) reevaluateChildrenAfterParentStateChange:(Node*)node onLayer:(int)layer_index andVariable:(int)variableIndex
{
    Node* *children = [node children];
    MDDStateValues* nodeState = getState(node);
    for (int child_index = _min_domain_for_layer[layer_index]; child_index <= _max_domain_for_layer[layer_index]; child_index++) {
        Node* child = children[child_index];
        if (child != NULL) {
            if ([_spec canChooseValue:child_index forVariable:variableIndex withState:nodeState]) {
                [child setRecalcRequired:true];
            } else {
                [node removeChildAt:child_index];
                [child removeParentOnce:node];
                assignTRInt(&layer_variable_count[layer_index][child_index], layer_variable_count[layer_index][child_index]._val-1, _trail);
                if ([child isParentless]) {
                    [self removeParentlessNodeFromMDD:child fromLayer:layer_index+1];
                }
            }
        }
    }
}
-(void) cleanLayer:(int)layer
{
    [self mergeNodesToWidthOnLayer: layer];
}
-(void) mergeNodesToWidthOnLayer:(int)layer
{
    int initialLayerSize = layer_size[layer]._val;
    ORTRIdArrayI* layerNodes = layers[layer];
    int** similarityMatrix = [self findSimilarityMatrix:layer];
    while (layer_size[layer]._val  > _relaxation_size) {
        int best_similarity = similarityMatrix[0][1];
        int first_node_index, second_node_index;
        int best_first_node_index = 0, best_second_node_index = 1;
        for (first_node_index = 0; first_node_index < layer_size[layer]._val-1; first_node_index++) {
            for (second_node_index = first_node_index +1; second_node_index < layer_size[layer]._val; second_node_index++) {
                if (similarityMatrix[first_node_index][second_node_index] < best_similarity) {
                    best_first_node_index = first_node_index;
                    best_second_node_index = second_node_index;
                }
            }
        }
        Node* first_node = [layerNodes at: best_first_node_index];
        Node* second_node = [layerNodes at: best_second_node_index];
        [_spec mergeState:getState(first_node) with:getState(second_node)];
        [first_node takeParentsFrom:second_node];
        [first_node setIsMergedNode:true];
        [self removeNode:second_node onLayer:layer];
        if (layer_size[layer]._val > _relaxation_size) {
            //free(similarityMatrix);
            //similarityMatrix = [self findSimilarityMatrix:layer];
            [self updateSimilarityMatrix: similarityMatrix afterMerging:best_second_node_index into:best_first_node_index onLayer:layer];
        }
    }
    for (int i = 0; i < initialLayerSize; i++) {
        free(similarityMatrix[i]);
    }
}
-(int**) findSimilarityMatrix:(int)layer
{
    int ls = layer_size[layer]._val;
    int** similarityMatrix = malloc(ls * sizeof(int*));
    for (int i = 0; i < ls; i++) {
        similarityMatrix[i] = malloc(ls * sizeof(int));
        for (int j = 0; j < ls; j++) {
            similarityMatrix[i][j] = INT_MAX;
        }
    }
    ORTRIdArrayI* layerNodes = layers[layer];
    int first_node_index, second_node_index;
    for (first_node_index = 0; first_node_index < ls-1; first_node_index++) {
        MDDStateValues* first_node_state = [[layerNodes at: first_node_index] getState];
        for (second_node_index = first_node_index +1; second_node_index < ls; second_node_index++) {
            MDDStateValues* second_node_state = [[layerNodes at: second_node_index] getState];
            int state_differential = [_spec stateDifferential:first_node_state with:second_node_state];
            similarityMatrix[first_node_index][second_node_index] = state_differential;
        }
    }
    return similarityMatrix;
}
-(void) updateSimilarityMatrix:(int**)similarityMatrix afterMerging:(int)best_second_node_index into:(int)best_first_node_index onLayer:(int)layer
{
    ORTRIdArrayI* layerNodes = layers[layer];
    MDDStateValues* first_node_state = [[layerNodes at: best_first_node_index] getState];
    for (int second_node_index = 0; second_node_index < layer_size[layer]._val; second_node_index++) {
        MDDStateValues* second_node_state = [[layerNodes at: second_node_index] getState];
        int newSimilarity = [_spec stateDifferential:first_node_state with:second_node_state];
        if (second_node_index < best_first_node_index) {
            similarityMatrix[second_node_index][best_first_node_index] = newSimilarity;
        } else {
            similarityMatrix[best_first_node_index][second_node_index] = newSimilarity;
        }
    }
    for (int first_node_index = best_second_node_index; first_node_index < layer_size[layer]._val; first_node_index++) {
        for (int second_node_index = 0; second_node_index < layer_size[layer]._val; second_node_index++) {
            similarityMatrix[first_node_index][second_node_index] = similarityMatrix[first_node_index][second_node_index+1];
        }
    }
    for (int second_node_index = best_second_node_index; second_node_index < layer_size[layer]._val; second_node_index++) {
        for (int first_node_index = 0; first_node_index < layer_size[layer]._val; first_node_index++) {
            similarityMatrix[first_node_index][second_node_index] = similarityMatrix[first_node_index][second_node_index+1];
        }
    }
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPMDDRelaxation:%02d %@>",_name,_x];
}
@end
