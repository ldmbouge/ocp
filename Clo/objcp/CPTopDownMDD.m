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

@implementation NodeHashTable
-(id) initNodeHashTable
{
    [super init];
    nodeHashes = [[NSMutableDictionary alloc] init];
    return self;
}
-(NSMutableArray*) findBucketForStateHash:(NSUInteger)stateHash
{
    NSMutableArray* bucket = [nodeHashes objectForKey:[NSNumber numberWithUnsignedLong:stateHash]];
    if (bucket == NULL) {
        bucket = [[NSMutableArray alloc] init];
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
-(NSMutableDictionary*) hashTable { return nodeHashes; }
@end

@implementation Node
-(id) initNode: (id<ORTrail>) trail
{
    [super init];
    _trail = trail;
    _children = NULL;
    _numChildren = makeTRInt(_trail, 0);
    _minChildIndex = 0;
    _maxChildIndex = 0;
    _maxNumParents = makeTRInt(_trail,10);
    _maxNumUniqueParents = makeTRInt(_trail,10);
    _parents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumParents._val];
    _uniqueParents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumUniqueParents._val];
    _parentCounts = [[ORTRIntArrayI alloc] initORTRIntArrayWithTrail:_trail range:[[ORIntRangeI alloc] initORIntRangeI:0 up:_maxNumUniqueParents._val]];
    _numParents = makeTRInt(_trail, 0);
    _numUniqueParents = makeTRInt(_trail, 0);
    _value = -1;
    _isSink = false;
    _isSource = false;
    
    _isRelaxed = makeTRInt(_trail, 0);
    _recalcRequired = makeTRInt(_trail, 0);
    
    return self;
}
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state
{
    [super init];
    _trail = trail;
    _minChildIndex = minChildIndex;
    _maxChildIndex = maxChildIndex;
    _value = value;
    _children = calloc((_maxChildIndex-_minChildIndex +1) , sizeof(TRId));
    _children -= _minChildIndex;
    for (int child = _minChildIndex; child <= maxChildIndex; child++) {
        _children[child] = makeTRId(_trail, nil);
    }
    
    _state = makeTRId(_trail, state);
    
    _numChildren = makeTRInt(_trail, 0);
    _maxNumParents = makeTRInt(_trail,(_maxChildIndex-_minChildIndex+1));
    _maxNumUniqueParents = makeTRInt(_trail,(maxChildIndex-minChildIndex+1));
    _parents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumParents._val];
    _uniqueParents = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_maxNumUniqueParents._val];
    _parentCounts = [[ORTRIntArrayI alloc] initORTRIntArrayWithTrail:_trail range:[[ORIntRangeI alloc] initORIntRangeI:0 up:_maxNumUniqueParents._val]];
    _numParents = makeTRInt(_trail, 0);
    _numUniqueParents = makeTRInt(_trail, 0);
    _value = value;
    _isSink = false;
    _isSource = false;
    
    _isRelaxed = makeTRInt(_trail, 0);
    _recalcRequired = makeTRInt(_trail, 0);
    return self;
}
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state relaxed:(bool)relaxed
{
    [self initNode:trail minChildIndex:minChildIndex maxChildIndex:maxChildIndex value:value state:state];
    assignTRInt(&_isRelaxed, relaxed, _trail);
    return self;
}
-(void) dealloc {
    [_parents dealloc];
    [_uniqueParents dealloc];
    [_parentCounts dealloc];
    [super dealloc];
}

-(TRId) getState {
    return _state;
}
//TODO: Don't allow setting of state like this.  Instead, needs to copy the values into the old state so only one state is used per node
-(void) setState:(id)newState {
    assignTRId(&_state, newState, _trail);
}
-(void) setIsSink: (bool) isSink {
    _isSink = isSink;
}
-(void) setIsSource: (bool) isSource {
    _isSource = isSource;
}
-(int) minChildIndex {
    return _minChildIndex;
}
-(int) maxChildIndex {
    return _maxChildIndex;
}
-(int) value {
    return _value;
}
-(TRId*) children {
    return _children;
}
-(bool) recalcRequired {
    return _recalcRequired._val;
}
-(void) setRecalcRequired:(bool)value {
    assignTRInt(&_recalcRequired, value, _trail);
}
-(void) addChild:(Node*)child at:(int)index {
    if (_children[index] == NULL) {
        assignTRInt(&_numChildren, _numChildren._val +1, _trail);
    }
    assignTRId(&_children[index], child, _trail);
}
-(void) removeChildAt: (int) index {
    assignTRId(&_children[index], NULL, _trail);
    assignTRInt(&_numChildren, _numChildren._val -1, _trail);
}
-(int) findChildIndex: (Node*) child {
    for (int child_index = _minChildIndex; child_index <= _maxChildIndex; child_index++) {
        if (_children[child_index] == child) {
            return child_index;
        }
    }
    return _minChildIndex-1;
}
-(ORTRIdArrayI*) parents {
    return _parents;
}
-(ORTRIdArrayI*) uniqueParents {
    return _uniqueParents;
}
-(ORTRIntArrayI*) parentCounts {
    return _parentCounts;
}
-(int) numParents {
    return _numParents._val;
}
-(int) numUniqueParents {
    return _numUniqueParents._val;
}
-(void) addParent: (Node*) parent {
    if (_maxNumParents._val == _numParents._val) {
        assignTRInt(&_maxNumParents, _maxNumParents._val * 2, _trail);
        [_parents resize:_maxNumParents._val];
    }
    [_parents set:parent at:_numParents._val];
    assignTRInt(&_numParents,_numParents._val+1,_trail);
    
    if([self hasParent:parent]) {
        int parentIndex = [self findUniqueParentIndexFor:parent];
        [_parentCounts set:([_parentCounts at:parentIndex]+1) at:parentIndex];
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
-(void) addParentToNonUniqueList:(Node*) parent {
    if (_maxNumParents._val == _numParents._val) {
        assignTRInt(&_maxNumParents, _maxNumParents._val * 2, _trail);
        [_parents resize:_maxNumParents._val];
    }
    [_parents set:parent at:_numParents._val];
    assignTRInt(&_numParents,_numParents._val+1,_trail);
}
-(void) addParent: (Node*) parent count:(int)count {
    if([self hasParent:parent]) {
        int parentIndex = [self findUniqueParentIndexFor:parent];
        [_parentCounts set:([_parentCounts at:parentIndex]+count) at:parentIndex];
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
-(void) removeParentOnce: (Node*) parent {
    int removed = false;
    for (int parentIndex = 0; parentIndex < _numParents._val; parentIndex++) {
        if ((Node*)[_parents at:parentIndex] == parent) {
            assignTRInt(&_numParents,_numParents._val-1,_trail);
            [_parents set:[_parents at:_numParents._val] at:parentIndex];
            removed = true;
            break;
        }
    }
    
    if (removed) {
        int parentIndex = [self findUniqueParentIndexFor:parent];
        [_parentCounts set:([_parentCounts at:parentIndex]-1) at:parentIndex];
        if (![_parentCounts at:parentIndex]) {
            assignTRInt(&_numUniqueParents,_numUniqueParents._val-1,_trail);
            [_uniqueParents set:[_uniqueParents at:_numUniqueParents._val] at:parentIndex];
            [_parentCounts set:[_parentCounts at:_numUniqueParents._val] at:parentIndex];
        }
    }
}
-(void) removeParentValue: (Node*) parent {
    int removed = false;
    for (int parentIndex = 0; parentIndex < _numParents._val; parentIndex++) {
        if ((Node*)[_parents at:parentIndex] == parent) {
            assignTRInt(&_numParents,_numParents._val-1,_trail);
            [_parents set:[_parents at:_numParents._val] at:parentIndex];
            parentIndex--;
            removed = true;
        }
    }
    
    if (removed) {
        int parentIndex = [self findUniqueParentIndexFor:parent];
        assignTRInt(&_numUniqueParents,_numUniqueParents._val-1,_trail);
        [_uniqueParents set:[_uniqueParents at:_numUniqueParents._val] at:parentIndex];
        [_parentCounts set:[_parentCounts at:_numUniqueParents._val] at:parentIndex];
    }
}
-(bool) isVital {
    return _isSource || _isSink;
}
-(bool) isNonVitalAndChildless {
    return !(_numChildren._val || [self isVital]);
}
-(bool) isNonVitalAndParentless {
    return !(_numUniqueParents._val || [self isVital]);
}
-(void) mergeWith:(Node*)other inPlace:(bool)inPlace layerVariableCount:(TRInt**)layerVariableCount layer:(int)layer {
    [self mergeStateWith: other];
    [self takeParentsFrom: other];
    if (inPlace) {
        [self mergeChildrenWith:other layerVariableCount:layerVariableCount layer:layer];
    }
    assignTRInt(&_isRelaxed, 1, _trail);
}
-(bool) hasParent:(Node*)parent {
    //This should be changed to use a hashtable
    
    for (int parentIndex = 0; parentIndex < _numUniqueParents._val; parentIndex++) {
        if ((Node*)[_uniqueParents at:parentIndex] == parent) {
            return true;
        }
    }
    return false;
}
-(int) countForParent:(Node*)parent {
    //This should be changed to use a hashtable
    
    for (int parentIndex = 0; parentIndex < _numUniqueParents._val; parentIndex++) {
        if ((Node*)[_uniqueParents at:parentIndex] == parent) {
            return [_parentCounts at:parentIndex];
        }
    }
    return 0;
}
-(void) takeParentsFrom:(Node*)other {
    ORTRIdArrayI* otherParents = [other parents];
    for (int parentIndex = 0; parentIndex < [other numParents]; parentIndex++) {
        Node* parent = (Node*)[otherParents at:parentIndex];
        
        int child_index = [parent findChildIndex: other];
        while(child_index >= _minChildIndex) {
            [parent addChild: self at:child_index];
            [self addParentToNonUniqueList: parent];
            child_index = [parent findChildIndex: other];
        }
    }
    
    //Once the above section is removed (if that happens), need to move the [parent addChild] to the following.
    for (int parentIndex = 0; parentIndex < [other numUniqueParents]; parentIndex++) {
        Node* parent = (Node*)[[other uniqueParents] at:parentIndex];
        int count = [[other parentCounts] at:parentIndex];
        [self addParent:parent count:count];
    }
}
-(void) mergeChildrenWith:(Node*)other layerVariableCount:(TRInt**)layerVariableCount layer:(int)layer {
    Node** otherChildren = [other children];
    for (int childIndex = _minChildIndex; childIndex <= _maxChildIndex; childIndex++) {
        Node* selfChild = _children[childIndex];
        Node* otherChild = otherChildren[childIndex];
        if (otherChild != nil) {
            if (selfChild == nil) {
                [self addChild:otherChild at:childIndex];
                [otherChild addParent:self];
            } else {
                assignTRInt(&layerVariableCount[layer][childIndex], layerVariableCount[layer][childIndex]._val-1, _trail);
                if (![selfChild isEqual:otherChild]) {
                    [selfChild mergeWith:otherChild inPlace:true layerVariableCount:layerVariableCount layer:layer+1];
                }
            }
            [other removeChildAt:childIndex];
            [otherChild removeParentValue:other];
        }
    }
}
-(int) findUniqueParentIndexFor:(Node*) parent {
    /*Need to use a hash table.
     In hash table would be nodes (parents).  Possibly actually pairs of (parent_node, count)
     Key for hash table is the hash of the parent node's state.
     Is there an easy way to iterate over a hash table like this or should it be kept separate?*/
    
    for (int parentIndex = 0; parentIndex < _numUniqueParents._val; parentIndex++) {
        if ((Node*)[_uniqueParents at:parentIndex] == parent) {
            return parentIndex;
        }
    }
    return -1;
}
-(bool) canChooseValue:(int)value {
    return [_state canChooseValue:value forVariable:_value];
}
-(void) mergeStateWith:(Node*)other {
    [_state mergeStateWith: getState(other)];
}
-(bool) isRelaxed { return _isRelaxed._val; }

-(int) DEBUGConfirmNumParentsEqualsSumOfParentCount {
    int countForUniqueParents = 0;
    for (int uniqueParentIndex = 0; uniqueParentIndex < _numUniqueParents._val; uniqueParentIndex++) {
        countForUniqueParents += [_parentCounts at:uniqueParentIndex];
    }
    if (countForUniqueParents != _numParents._val) {
        int i = 0;
    }
    return countForUniqueParents;
}
@end

@implementation CPMDD
-(id) initCPMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced
{
    self = [super initCPCoreConstraint: engine];
    _trail = [engine trail];
    _x = x;
    _numVariables = [_x count];
    
    min_domain_val = [_x[[_x low]] min];    //Not great.  If variables have different domains, this will be wrong.
    max_domain_val = [_x[[_x low]] max];
    
    layers = calloc((_numVariables+1) , sizeof(ORTRIdArrayI*));
    layer_size = calloc((_numVariables+1) , sizeof(TRInt));
    max_layer_size = calloc((_numVariables+1) , sizeof(TRInt));
    layer_variable_count = calloc((_numVariables+1) , sizeof(TRInt*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
        max_layer_size[layer] = makeTRInt(_trail,10);
        layers[layer] = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:max_layer_size[layer]._val];
        layer_variable_count[layer] = calloc((max_domain_val - min_domain_val + 1) , sizeof(TRInt));
        for (int variable = 0; variable <= max_domain_val - min_domain_val; variable++) {
            layer_variable_count[layer][variable] = makeTRInt(_trail,0);
        }
        
        layer_variable_count[layer] -= min_domain_val;
    }
    
    _layer_to_variable = malloc((_numVariables+1) * sizeof(int));
    _variable_to_layer = malloc((_numVariables+1) * sizeof(int));
    
    _variable_to_layer -= [_x low];
    
    _stateClass = NULL;
    _hashTableSize = 100;
    _nextVariable = [_x low];
    
    return self;
}
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x classState:(CustomState*)classState
{
    self = [self initCPMDD:engine over:x reduced:true];
    _stateClass = [classState class];
    _classState = classState;
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
    [self createRootAndSink];
    int last_variable_layer = (int)_numVariables-1;
    for (int layer = 0; layer < last_variable_layer; layer++) {
        _variable_to_layer[_nextVariable] = layer+1;
        _layer_to_variable[layer+1] = _nextVariable;
        _nextVariable++;
        [self buildNewLayerUnder:layer];
        [self cleanLayer: layer+1];
    }
    [self buildNewLayerUnder:last_variable_layer];
    [self addPropagationsAndTrimValues];
    return;
}
-(int) layerIndexForVariable:(int)variableIndex {
    return _variable_to_layer[variableIndex];
}
-(int) variableIndexForLayer:(int)layer {
    return _layer_to_variable[layer];
}
-(void) createRootAndSink
{
    Node *sink = [[Node alloc] initNode: _trail];
    [sink setIsSink: true];
    [self addNode: sink toLayer:((int)_numVariables)];
    
    id state = [self generateRootState: [_x low]];
    _variable_to_layer[_nextVariable] = 0;
    _layer_to_variable[0] = _nextVariable;
    _nextVariable++;
    
    Node* root = [[Node alloc] initNode: _trail
                          minChildIndex:min_domain_val
                          maxChildIndex:max_domain_val
                                  value:[_x low]
                                  state:state];
    [root setIsSource:true];
    [self addNode:root toLayer:0];
}
-(void) cleanLayer:(int)layer
{
    return;
}
-(void) buildNewLayerUnder:(int)layer
{
    NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable];
    for (int parentNodeIndex = 0; parentNodeIndex < layer_size[layer]._val; parentNodeIndex++) {
        Node* parentNode = [layers[layer] at: parentNodeIndex];
        [self createChildrenForNode:parentNode nodeHashes:nodeHashTable];
    }
    [nodeHashTable release];
}
-(void) createChildrenForNode:(Node*)parentNode nodeHashes:(NodeHashTable*)nodeHashTable
{
    int parentValue = [parentNode value];
    int parentLayer = [self layerIndexForVariable:parentValue];
    bool lastLayer = (parentLayer == _numVariables-1);
    bool parentRelaxed = [parentNode isRelaxed];
    for (int edgeValue = [parentNode minChildIndex]; edgeValue <= [parentNode maxChildIndex]; edgeValue++) {
        if ([_x[parentValue] member: edgeValue] && [parentNode canChooseValue: edgeValue]) {
            Node* childNode = nil;
            if (!lastLayer) {
                id state = [self generateStateFromParent:parentNode withValue:edgeValue];
                NSUInteger hashValue = [state hashWithWidth:_hashTableSize numVariables:(max_domain_val-min_domain_val+1)];
                NSMutableArray* bucket = [nodeHashTable findBucketForStateHash:hashValue];
                childNode = [nodeHashTable nodeWithState:state inBucket:bucket];
                if (childNode == nil) {
                    childNode = [[Node alloc] initNode: _trail
                                         minChildIndex:min_domain_val
                                         maxChildIndex:max_domain_val
                                                 value:[self variableIndexForLayer:parentLayer + 1]
                                                 state:state
                                               relaxed:parentRelaxed];
                    [self addNode:childNode toLayer:parentLayer+1];
                    [bucket addObject:childNode];
                }
            } else {
                childNode = [layers[_numVariables] at: 0];
            }
            [parentNode addChild:childNode at:edgeValue];
            [childNode addParent:parentNode];
            assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
        }
    }
}
-(void) addPropagationsAndTrimValues
{
    for(ORInt layer = 0; layer < _numVariables; layer++) {
        [self trimValuesFromLayer:layer];
        [self addPropagationToLayer: layer];
    }
}
-(void) trimValuesFromLayer:(ORInt)layer
{
    int variableIndex = [self variableIndexForLayer:layer];
    for (int value = min_domain_val; value <= max_domain_val; value++) {
        if (!layer_variable_count[layer][value]._val && [_x[variableIndex] member:value]) {
            [_x[variableIndex] remove: value];
        }
    }
}
-(void) addPropagationToLayer:(ORInt)layer
{
    int variableIndex = [self variableIndexForLayer:layer];
    if (!bound((CPIntVar*)_x[variableIndex])) {
        [_x[variableIndex] whenLoseValue:self do:^(ORInt value) {
            [self trimValueFromLayer: layer :value ];
        }];
    }
}
-(id) generateRootState:(int)variableValue
{
    return [[_stateClass alloc] initRootState:_classState variableIndex:variableValue trail:_trail];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    id parentState = getState(parentNode);
    int parentLayer = _variable_to_layer[[parentState variableIndex]];
    int variableIndex = _layer_to_variable[parentLayer+1];
    return [[_stateClass alloc] initState:parentState assigningVariable:variableIndex withValue:value];
}
-(void) addNode:(Node*)node toLayer:(int)layer_index
{
    if (max_layer_size[layer_index]._val == layer_size[layer_index]._val) {
        assignTRInt(&max_layer_size[layer_index], max_layer_size[layer_index]._val*2, _trail);
        [layers[layer_index] resize:max_layer_size[layer_index]._val];
    }
    [layers[layer_index] set:node at:layer_size[layer_index]._val];
    assignTRInt(&layer_size[layer_index], layer_size[layer_index]._val+1, _trail);
}
-(void) removeNodeAt:(int)index onLayer:(int)layer_index {
    ORTRIdArrayI* layer = layers[layer_index];
    
    int finalNodeIndex = layer_size[layer_index]._val-1;
    [layer set:[layer at:finalNodeIndex] at:index];
    [layer set:NULL at: finalNodeIndex];    //Is this necessary?
    assignTRInt(&layer_size[layer_index], finalNodeIndex,_trail);
}
-(void) removeNode: (Node*) node {
    int node_layer = [self layerIndexForVariable:node.value];
    ORTRIdArrayI* layer = layers[node_layer];
    int currentLayerSize = layer_size[node_layer]._val;
    
    for (int node_index = 0; node_index < currentLayerSize; node_index++) {
        if ([layer at: node_index] == node) {
            int finalNodeIndex = layer_size[node_layer]._val-1;
            [layer set:[layer at:finalNodeIndex] at:node_index];
            [layer set:NULL at:finalNodeIndex]; //Is this necessary?
            assignTRInt(&layer_size[node_layer], finalNodeIndex,_trail);
            return;
        }
    }
}
-(void) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming
{
    int parentLayer = layer-1;
    int numUniqueParents = [node numUniqueParents];
    ORTRIdArrayI* parents = [node parents];
    
    for (int parentIndex = 0; parentIndex < numUniqueParents; parentIndex++) {
        Node* parent = [parents at: parentIndex];
        int child_index = [parent findChildIndex: node];
        while(child_index >= min_domain_val) {
            [parent removeChildAt:child_index];
            [node removeParentOnce:parent];
            
            assignTRInt(&layer_variable_count[parentLayer][child_index], layer_variable_count[parentLayer][child_index]._val -1, _trail);
            if (trimming && !layer_variable_count[parentLayer][child_index]._val) {
                [_x[[parent value]] remove: child_index];
            }
            
            child_index = [parent findChildIndex: node];
        }
        if ([parent isNonVitalAndChildless]) {
            [self removeChildlessNodeFromMDD:parent fromLayer:parentLayer trimmingVariables:trimming];
        } 
    }
    [self removeNode: node];
}
-(void) removeParentlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming
{
    Node* *children = [node children];
    int childLayer = layer+1;
    for(int child_index = min_domain_val; child_index <= max_domain_val; child_index++) {
        Node* childNode = children[child_index];
        
        if (childNode != NULL) {
            [node removeChildAt: child_index];
            [childNode removeParentValue: node];
            
            assignTRInt(&layer_variable_count[layer][child_index], layer_variable_count[layer][child_index]._val -1, _trail);
            if (trimming & !layer_variable_count[layer][child_index]._val) {
                [_x[[node value]] remove: child_index];
            }
            
            if ([childNode isNonVitalAndParentless]) {
                [self removeParentlessNodeFromMDD:childNode fromLayer:childLayer trimmingVariables:trimming];
            } else {
                if ([childNode isRelaxed]) {
                    [childNode setRecalcRequired:true];
                }
            }
        }
    }
    [self removeNode: node];
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    ORTRIdArrayI* layer = layers[layer_index];
    
    for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
        Node* node = [layer at: node_index];
        Node* childNode = [node children][value];
            
        if (childNode != NULL) {
            [node removeChildAt: value];
            assignTRInt(&layer_variable_count[layer_index][value], layer_variable_count[layer_index][value]._val -1, _trail);
            if ([node findChildIndex:childNode] >= min_domain_val) {
                [childNode removeParentValue:node];
            }
            if ([childNode isNonVitalAndParentless]) {
                [self removeParentlessNodeFromMDD:childNode fromLayer:(layer_index+1) trimmingVariables:true];
            }
            if ([node isNonVitalAndChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layer_index trimmingVariables:true];
                node_index--;
            }
        }
    }
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
                for (int child_index = min_domain_val; child_index <= max_domain_val; child_index++) {
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
}

-(void) DEBUGTestLayerVariableCountCorrectness
{
    //DEBUG code:  Checks if layer_variable_count correctly represents the edges on the layer.
    for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
        for (int domain_val = min_domain_val; domain_val <= max_domain_val; domain_val++) {
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
            NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable];
            Node* node = [layers[layer_index] at: node_index];
            Node** children = [node children];
            for (int child_index = min_domain_val; child_index <= max_domain_val; child_index++) {
                bool added = false;
                Node* child = children[child_index];
                
                if (child != NULL) {
                    id state = [child getState];
                    NSUInteger hashValue = [state hashWithWidth:_hashTableSize numVariables:(max_domain_val-min_domain_val+1)];
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
            
            NSMutableDictionary* hashTable = [nodeHashTable hashTable];
            for (id key in hashTable) {
                NSArray* bucket = [hashTable objectForKey:key];
                for (NSArray* nodeCountPair in bucket) {
                    Node* bucketNode = [nodeCountPair objectAtIndex:0];
                    int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                    
                    if ([bucketNode countForParent:node] != bucketCount) {
                        int i =0;
                    }
                }
            }
            [hashTable release];
            [nodeHashTable release];
        }
    }
}
@end

@implementation CPMDDRestriction
-(id) initCPMDDRestriction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize reduced:(bool)reduced
{
    self = [super initCPMDD:engine over:x reduced:reduced];
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
    [self removeChildlessNodeFromMDD:node fromLayer:layer trimmingVariables:false];
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
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced
{
    self = [super initCPMDD:engine over:x reduced:reduced];
    _relaxed = true;
    _relaxation_size = relaxationSize;
    if (_relaxed) {
        _hashTableSize = _relaxation_size * 2;
    }
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize classState:(CustomState*)classState
{
    self = [super initCPMDD:engine over:x classState:classState];
    _relaxed = relaxed;
    _relaxation_size = relaxationSize;
    if (_relaxed) {
        _hashTableSize = _relaxation_size * 2;
    }
    return self;
}
-(void) addPropagationToLayer:(ORInt)layer
{
    int variableIndex = [self variableIndexForLayer:layer];
    if (!bound((CPIntVar*)_x[variableIndex])) {
        [_x[variableIndex] whenChangeDo:^() {
            bool layerChanged = false;
            for (int domain_val = min_domain_val; domain_val <= max_domain_val; domain_val++) {
                if (![_x[variableIndex] member:domain_val] && layer_variable_count[layer][domain_val]._val) {
                    [self trimValueFromLayer: layer :domain_val ];
                    layerChanged = true;
                }
            }
            if (layerChanged) {
                for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
                    int variableForTrimming = [self variableIndexForLayer:layer_index];
                    for (int domain_val = min_domain_val; domain_val <= max_domain_val; domain_val++) {
                        if (![_x[variableForTrimming] member:domain_val] && layer_variable_count[layer_index][domain_val]._val) {
                            [self trimValueFromLayer: layer_index :domain_val ];
                        }
                    }
                }
                [self rebuildFromLayer:0];
            }
            //_todo = CPChecked;
        } onBehalf:self];
    }
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    ORTRIdArrayI* layer = layers[layer_index];
    int numEdgesToDelete = layer_variable_count[layer_index][value]._val;
    
    for (int node_index = 0; numEdgesToDelete; node_index++) {
        Node* node = [layer at: node_index];
        Node* childNode = [node children][value];
        if (childNode != NULL) {
            [node removeChildAt: value];
            [childNode removeParentOnce:node];
            if ([childNode isNonVitalAndParentless]) {
                [self removeParentlessNodeFromMDD:childNode fromLayer:(layer_index+1) trimmingVariables:true];
            } else {
                if ([childNode isRelaxed]) {
                    [childNode setRecalcRequired:true];
                }
            }
            if ([node isNonVitalAndChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layer_index trimmingVariables:true];
                node_index--;
            }
            numEdgesToDelete--;
        }
    }
    assignTRInt(&layer_variable_count[layer_index][value], 0, _trail);
}
-(void) rebuildFromLayer:(int)startingLayer
{
    if (layer_size[startingLayer]._val == 0) {
        failNow();
    }
    void(*mth)(id,SEL,int) = [self methodForSelector:@selector(splitNodesOnLayer:)];
    for (int layer = startingLayer+1; layer < _numVariables; layer++) {
        if (_relaxed) {
            mth(self,@selector(splitNodesOnLayer:),layer);
        }
        if (layer_size[layer]._val == 0) {
            failNow();
        }
    }
    for(ORInt layer = startingLayer; layer < _numVariables; layer++) {
        [self trimValuesFromLayer:layer];
    }
    return;
}
-(void) splitNodesOnLayer:(int)layer
{
    NSMutableDictionary* nodeHashes = [[NSMutableDictionary alloc] init];
    
    int initial_layer_size = layer_size[layer]._val;
    bool firstNewNode;
    for (int node_index = 0; node_index < initial_layer_size && layer_size[layer]._val < _relaxation_size; node_index++) {
        Node* node = [layers[layer] at: node_index];
        if ([node isRelaxed]) { //Find a relaxed node to split
            firstNewNode = true;
            Node** oldNodeChildren = [node children];
            ORTRIdArrayI* parents = [node uniqueParents];
            while (layer_size[layer]._val < _relaxation_size && [node numParents]) {
                //All edges going into this node should be examined.  To get these edges, look at the parents
                Node* parent = [parents at:0];
                bool parentIsRelaxed = [parent isRelaxed];
                Node** parentsChildren = [parent children];
                for (int child_index = min_domain_val; child_index <= max_domain_val && [node numParents] && layer_size[layer]._val < _relaxation_size; child_index++) {
                    Node* parentsChild = parentsChildren[child_index];
                    if ([node isEqual:parentsChild]) { //Found an edge that was going into a relaxed node.  Recreate a node for it.
                        Node* newNode = NULL;
                        id state = [self generateStateFromParent:parent withValue:child_index];
                        NSUInteger hashValue = [state hashWithWidth:_hashTableSize numVariables:_numVariables];
                        NSMutableArray* bucket = [nodeHashes objectForKey:[NSNumber numberWithUnsignedLong:hashValue]];
                        if (bucket == NULL) {
                            bucket = [[NSMutableArray alloc] init];
                            [nodeHashes setObject:bucket forKey:[NSNumber numberWithUnsignedLong:hashValue]];
                        } else {
                            for (int bucket_index = 0; bucket_index < [bucket count]; bucket_index++) {
                                id bucketObjectState = [bucket[bucket_index] getState];
                                if ([bucketObjectState equivalentTo:state]) {
                                    newNode = bucket[bucket_index];
                                    [state release];
                                    break;
                                }
                            }
                        }
                        if (newNode == NULL) {
                            newNode = [[Node alloc] initNode: _trail
                                               minChildIndex:min_domain_val
                                               maxChildIndex:max_domain_val
                                                       value:[self variableIndexForLayer:layer]
                                                       state:state
                                                     relaxed:parentIsRelaxed];
                            [_trail trailRelease:newNode];
                            [self addNode:newNode toLayer:layer];
                            for (int domain_val = min_domain_val; domain_val <= max_domain_val; domain_val++) {
                                Node* oldNodeChild = oldNodeChildren[domain_val];
                                if (oldNodeChild != NULL) {
                                    if ([newNode canChooseValue: domain_val]) {
                                        //Check if this arc should exist from the old state
                                        [newNode addChild:oldNodeChild at:domain_val];
                                        [oldNodeChild addParent: newNode];
                                        assignTRInt(&layer_variable_count[layer][domain_val], layer_variable_count[layer][domain_val]._val+1, _trail);
                                    }
                                }
                            }
                            firstNewNode = false;
                        }
                        [parent addChild:newNode at:child_index];
                        [newNode addParent:parent];
                        [node removeParentOnce:parent];
                    }
                }
            }
            if (firstNewNode) { //If the node was relaxed, but should be removed without any new nodes, need to decrement the for-loop counter
                for (int domain_val = min_domain_val; domain_val <= max_domain_val; domain_val++) {
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
            } else if ([node isNonVitalAndParentless]) {
                for (int domain_val = min_domain_val; domain_val <= max_domain_val; domain_val++) {
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
        if ([node isNonVitalAndParentless]) {
            [self removeParentlessNodeFromMDD:node fromLayer:layer+1 trimmingVariables:true];
            node_index--;
        }
    }
    
    [self recalcNodesOnLayer:layer];
    
    [nodeHashes release];
}
-(void) recalcNodesOnLayer:(int)layer_index
{
    ORInt variableIndex = [self variableIndexForLayer:layer_index];
    ORTRIdArrayI* layerArray = layers[layer_index];
    for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
        Node* node =[layerArray at:node_index];
        if ([node recalcRequired]) {
            id newState = [self calculateStateFromParents:node];
            if (![getState(node) equivalentTo:newState]) {
                [node setState:newState];
                [_trail trailRelease:newState];
                [node setRecalcRequired:false];
                [self reevaluateChildrenAfterParentStateChange:node onLayer:layer_index andVariable:variableIndex];
            } else {
                free(newState);
            }
        }
    }
}
-(id) calculateStateFromParents:(Node*)node
{
    id newState = NULL;
    ORTRIdArrayI* parents = [node uniqueParents];
    for (int parent_index = 0; parent_index < [node numUniqueParents]; parent_index++) {
        Node* parent = [parents at:parent_index];
        TRId* children = [parent children];
        for (int child_index = min_domain_val; child_index <= max_domain_val; child_index++) {
            Node* child = children[child_index];
            if ([child isEqual:node]) {
                if (newState == NULL) {
                    newState = [self generateStateFromParent:parent withValue:child_index];
                } else {
                    id tempState = [self generateStateFromParent:parent withValue:child_index];
                    [newState mergeStateWith:tempState];
                    [tempState release];
                }
            }
        }
    }
    return newState;
}
-(void) reevaluateChildrenAfterParentStateChange:(Node*)node onLayer:(int)layer_index andVariable:(int)variableIndex
{
    Node* *children = [node children];
    for (int child_index = min_domain_val; child_index <= max_domain_val; child_index++) {
        Node* child = children[child_index];
        if (child != NULL) {
            if ([node canChooseValue:child_index]) {
                [child setRecalcRequired:true];
            } else {
                [node removeChildAt:child_index];
                [child removeParentOnce:node];
                assignTRInt(&layer_variable_count[layer_index][child_index], layer_variable_count[layer_index][child_index]._val-1, _trail);
                if (!layer_variable_count[layer_index][child_index]._val && [_x[variableIndex] member:child_index]) {
                    [_x[variableIndex] remove: child_index];
                }
                if ([child isNonVitalAndParentless]) {
                    [self removeParentlessNodeFromMDD:child fromLayer:layer_index+1 trimmingVariables:true];
                }
            }
        }
    }
}
-(void) cleanLayer:(int)layer
{
    if (_relaxed) {
        [self mergeNodesToWidthOnLayer: layer];
    }
}
-(void) mergeNodesToWidthOnLayer:(int)layer
{
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
        [first_node mergeWith: second_node inPlace:true layerVariableCount:layer_variable_count layer:layer];
        [self removeNode:second_node];
        if (layer_size[layer]._val > _relaxation_size) {
            //free(similarityMatrix);
            //similarityMatrix = [self findSimilarityMatrix:layer];
            [self updateSimilarityMatrix: similarityMatrix afterMerging:best_second_node_index into:best_first_node_index onLayer:layer];
        }
    }
    free(similarityMatrix);
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
    int first_node_index, second_node_index;
    for (first_node_index = 0; first_node_index < ls-1; first_node_index++) {
        CustomState* first_node_state = [[layers[layer] at: first_node_index] getState];
        for (second_node_index = first_node_index +1; second_node_index < ls; second_node_index++) {
            CustomState* second_node_state = [[layers[layer] at: second_node_index] getState];
            int state_differential = [first_node_state stateDifferential: second_node_state];
            similarityMatrix[first_node_index][second_node_index] = state_differential;
        }
    }
    return similarityMatrix;
}
-(void) updateSimilarityMatrix:(int**)similarityMatrix afterMerging:(int)best_second_node_index into:(int)best_first_node_index onLayer:(int)layer
{
    CustomState* first_node_state = [[layers[layer] at: best_first_node_index] getState];
    for (int second_node_index = 0; second_node_index < layer_size[layer]._val; second_node_index++) {
        CustomState* second_node_state = [[layers[layer] at: second_node_index] getState];
        int newSimilarity = [first_node_state stateDifferential: second_node_state];
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

@implementation CPCustomMDD
-(id) initCPCustomMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize classState:(CustomState*)classState
{
    self = [super initCPMDDRelaxation:engine over:x relaxed:relaxed relaxationSize:relaxationSize classState:classState];
    _priority = LOWEST_PRIO;
    return self;
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPCustomMDD:%02d %@>",_name,_x];
}
@end
