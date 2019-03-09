/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPBensBasicConstraint.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "ORMDDify.h"

@implementation Node
-(id) initNode: (id<ORTrail>) trail maxParents:(int)maxParents
{
    [super init];
    _trail = trail;
    _childEdgeWeights = NULL;
    _children = NULL;
    _numChildren = makeTRInt(_trail, 0);
    _minChildIndex = 0;
    _maxChildIndex = 0;
    _parents = malloc((maxParents) * sizeof(Node*));
    for (int parent = 0; parent <= maxParents; parent++) {
        _parents[parent] = NULL;
    }
    _numParents = makeTRInt(_trail, 0);
    _value = -1;
    _isSink = false;
    _isSource = false;
    
    _objectiveValues = NULL;
    _longestPath = makeTRInt(_trail, -32768);
    _longestPathParents = malloc((maxParents) * sizeof(Node*));
    _numLongestPathParents = makeTRInt(_trail, 0);
    _shortestPath = makeTRInt(_trail, 32767);
    _shortestPathParents = malloc((maxParents) * sizeof(Node*));
    _numShortestPathParents = makeTRInt(_trail, 0);
    
    _reverseLongestPath = makeTRInt(_trail, 0);
    _reverseShortestPath = makeTRInt(_trail, 0);
    
    return self;
}
-(id) initNode: (id<ORTrail>) trail maxParents:(int)maxParents minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state
{
    [super init];
    _trail = trail;
    _minChildIndex = minChildIndex;
    _maxChildIndex = maxChildIndex;
    _value = value;
    _children = malloc((_maxChildIndex-_minChildIndex +1) * sizeof(Node*));
    _children -= _minChildIndex;
    for (int child = _minChildIndex; child <= maxChildIndex; child++) {
        _children[child] = NULL;
    }
    
    _childEdgeWeights = malloc((_maxChildIndex-_minChildIndex +1) * sizeof(TRInt));
    _childEdgeWeights -= _minChildIndex;
    for (int child = _minChildIndex; child <= maxChildIndex; child++) {
        _childEdgeWeights[child] = makeTRInt(_trail, 0);
    }
    
    _state = state;
    
    _numChildren = makeTRInt(_trail, 0);
    _parents = malloc((maxParents) * sizeof(Node*));
    for (int parent = 0; parent < maxParents; parent++) {
        _parents[parent] = NULL;
    }
    _numParents = makeTRInt(_trail, 0);
    _value = value;
    _isSink = false;
    _isSource = false;
    _longestPath = makeTRInt(_trail, -32768);
    _longestPathParents = malloc((maxParents) * sizeof(Node*));
    _numLongestPathParents = makeTRInt(_trail, 0);
    _shortestPath = makeTRInt(_trail, 32767);
    _shortestPathParents = malloc((maxParents) * sizeof(Node*));
    _numShortestPathParents = makeTRInt(_trail, 0);
    
    _reverseLongestPath = makeTRInt(_trail, 0);
    _reverseShortestPath = makeTRInt(_trail, 0);
    return self;
}
-(id) initNode: (id<ORTrail>) trail maxParents:(int)maxParents minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state objectiveValues:(int*)objectiveValues
{
    self = [self initNode: trail maxParents:maxParents minChildIndex:minChildIndex maxChildIndex:maxChildIndex value:value state:state];
    _objectiveValues = objectiveValues;
    return self;
}
-(void) dealloc {
    [super dealloc];
}

-(id) getState {
    return _state;
}

-(void) setIsSink: (bool) isSink {
    _isSink = isSink;
}
-(void) setIsSource: (bool) isSource {
    _isSource = isSource;
    if (_isSource) {
        assignTRInt(&_longestPath, 0, _trail);
        assignTRInt(&_shortestPath, 0, _trail);
    }
}
-(void) setNumChildren: (int) numChildren {
    assignTRInt(&_numChildren, numChildren, _trail);
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
-(Node**) children {
    return _children;
}
-(int) getObjectiveValueFor: (int)index {
    return _objectiveValues[index];
}
-(int) getNodeObjectiveValue: (int)value {
    return _childEdgeWeights[value]._val;
}
-(void) addChild:(Node*)child at:(int)index {
    if (_children[index] == NULL) {
        [self setNumChildren:_numChildren._val+1];
    }
    assignTRId(&_children[index], child, _trail);
    if (_objectiveValues != nil) {
        assignTRInt(&_childEdgeWeights[index], [self getObjectiveValueFor: index], _trail);
    }
}
-(void) removeChildAt: (int) index {
    assignTRId(&_children[index], NULL, _trail);
    assignTRInt(&_numChildren, _numChildren._val -1, _trail);
    if (_objectiveValues != nil) {
        assignTRInt(&_childEdgeWeights[index], 0, _trail);
    }
}
-(int) findChildIndex: (Node*) child {
    for (int child_index = _minChildIndex; child_index <= _maxChildIndex; child_index++) {
        if (_children[child_index] == child) {
            return child_index;
        }
    }
    return -1;
}
-(int) longestPath {
    return _longestPath._val;
}
-(bool) hasLongestPathParent: (Node*)parent {
    for (int parentIndex = 0; parentIndex < _numLongestPathParents._val; parentIndex++) {
        if (_longestPathParents[parentIndex] == parent) {
            return true;
        }
    }
    return false;
}

-(int) longestPathContainingSelf {
    return _longestPath._val + _reverseLongestPath._val;
}

-(int) shortestPath {
    return _shortestPath._val;
}
-(bool) hasShortestPathParent:(Node *)parent {
    for (int parentIndex = 0; parentIndex < _numShortestPathParents._val; parentIndex++) {
        if (_shortestPathParents[parentIndex] == parent) {
            return true;
        }
    }
    return false;
}

-(int) shortestPathContainingSelf {
    return _shortestPath._val + _reverseShortestPath._val;
}

-(int) reverseLongestPath {
    return _reverseLongestPath._val;
}
-(int) reverseShortestPath {
    return _reverseShortestPath._val;
}
-(void) updateReversePaths {
    if (_isSink) {
        assignTRInt(&_reverseShortestPath, 0, _trail);
        assignTRInt(&_reverseLongestPath, 0, _trail);
        return;
    }
    int longest = -32767;
    int shortest = 32768;
    for (int child_index = _minChildIndex; child_index <= _maxChildIndex; child_index++) {
        if (_children[child_index] != NULL) {
            int childReverseLongestPath = [_children[child_index] reverseLongestPath];
            int childReverseShortestPath = [_children[child_index] reverseShortestPath];
            
            if (longest < childReverseLongestPath + [self getObjectiveValueFor: child_index]) {
                longest = childReverseLongestPath + [self getObjectiveValueFor: child_index];
            }
            if (shortest > childReverseShortestPath + [self getObjectiveValueFor: child_index]) {
                shortest = childReverseShortestPath + [self getObjectiveValueFor: child_index];
            }
        }
    }
    
    assignTRInt(&_reverseShortestPath, shortest, _trail);
    assignTRInt(&_reverseLongestPath, longest, _trail);
}

-(TRId**) parents {
    return _parents;
}
-(int) numParents {
    return _numParents._val;
}
-(void) addParent: (Node*) parent {
    assignTRId(&_parents[_numParents._val], parent,_trail);
    assignTRInt(&_numParents,_numParents._val+1,_trail);
    if (_objectiveValues != nil) {
        [self updateBoundsWithParent: parent];
    }
}
-(void) updateBoundsWithParent: (Node*) parent {
    int parentLongestPath = [parent longestPath];
    int parentShortestPath = [parent shortestPath];
    
    for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
        if ([parent children][childIndex] == self) {
            int candidateLongestPath = parentLongestPath + [parent getObjectiveValueFor:childIndex];
            int candidateShortestPath = parentShortestPath + [parent getObjectiveValueFor:childIndex];
            
            if (candidateLongestPath == _longestPath._val) {
                _longestPathParents[_numLongestPathParents._val] = parent;
                assignTRInt(&_numLongestPathParents,_numLongestPathParents._val+1,_trail);
            } else if (candidateLongestPath > _longestPath._val) {
                assignTRInt(&_longestPath, candidateLongestPath, _trail);
                _longestPathParents[0] = parent;
                assignTRInt(&_numLongestPathParents,1,_trail);
            }
            
            if (candidateShortestPath == _shortestPath._val) {
                _shortestPathParents[_numShortestPathParents._val] = parent;
                assignTRInt(&_numShortestPathParents,_numShortestPathParents._val+1,_trail);
            } else if (candidateShortestPath < _shortestPath._val) {
                assignTRInt(&_shortestPath, candidateShortestPath, _trail);
                _shortestPathParents[0] = parent;
                assignTRInt(&_numShortestPathParents,1,_trail);
            }
        }
    }
}
-(void) findNewLongestPath {
    assignTRInt(&_longestPath,-32768,_trail);
    
    if (_numLongestPathParents._val == 0) {
        for (int parentIndex = 0; parentIndex < _numParents._val; parentIndex++) {
            Node* parent = (Node*)_parents[parentIndex];
            int parentLongestPath = [parent longestPath];
        
            for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
                if ([parent children][childIndex] == self) {
                    int candidateLongestPath = parentLongestPath + [parent getObjectiveValueFor:childIndex];
                
                    if (candidateLongestPath == _longestPath._val) {
                        _longestPathParents[_numLongestPathParents._val] = parent;
                        assignTRInt(&_numLongestPathParents,_numLongestPathParents._val+1,_trail);
                    } else if (candidateLongestPath > _longestPath._val) {
                        assignTRInt(&_longestPath, candidateLongestPath, _trail);
                        _longestPathParents[0] = parent;
                        assignTRInt(&_numLongestPathParents,1,_trail);
                    }
                }
            }
        }
    }
    
    if (!_isSink) {
        for (int childIndex = _minChildIndex; childIndex <= _maxChildIndex; childIndex++) {
            Node* child = _children[childIndex];
            
            if (child != NULL && [child hasLongestPathParent: self]) {
                [child removeLongestPathParent: self];
            }
        }
    }
    if (_longestPath._val == -32768) {
        failNow();
    }
}
-(void) removeLongestPathParent:(Node*)parent {
    for (int parentIndex = 0; parentIndex < _numLongestPathParents._val; parentIndex++) {
        if (_longestPathParents[parentIndex] == parent) {
            assignTRInt(&_numLongestPathParents,_numLongestPathParents._val-1,_trail);
            _longestPathParents[parentIndex] = _longestPathParents[_numLongestPathParents._val];
            parentIndex--;
        }
    }
        
    if (_numLongestPathParents._val == 0) {
        [self findNewLongestPath];
    }
}
-(void) findNewShortestPath {
    assignTRInt(&_shortestPath,32767,_trail);
    
    for (int parentIndex = 0; parentIndex < _numShortestPathParents._val; parentIndex++) {
        Node* parent = _shortestPathParents[parentIndex];
        int parentShortestPath = [parent shortestPath];
        
        for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
            if ([parent children][childIndex] == self) {
                int candidateShortestPath = parentShortestPath + [parent getObjectiveValueFor:childIndex];
                
                if (candidateShortestPath == _shortestPath._val) {
                    _shortestPathParents[_numShortestPathParents._val] = parent;
                    assignTRInt(&_numShortestPathParents,_numShortestPathParents._val+1,_trail);
                } else if (candidateShortestPath < _shortestPath._val) {
                    assignTRInt(&_shortestPath, candidateShortestPath, _trail);
                    _shortestPathParents[0] = parent;
                    assignTRInt(&_numShortestPathParents,1,_trail);
                }
            }
        }
    }
    
    if (!_isSink) {
        for (int childIndex = _minChildIndex; childIndex <= _maxChildIndex; childIndex++) {
            Node* child = _children[childIndex];
        
            if (child != NULL && [child hasShortestPathParent: self]) {
                [child removeShortestPathParent: self];
            }
        }
    }
}
-(void) removeShortestPathParent:(Node*)parent {
    for (int parentIndex = 0; parentIndex < _numShortestPathParents._val; parentIndex++) {
        if (_shortestPathParents[parentIndex] == parent) {
            assignTRInt(&_numShortestPathParents,_numShortestPathParents._val-1,_trail);
            _shortestPathParents[parentIndex] = _shortestPathParents[_numShortestPathParents._val];
            parentIndex--;
        }
    }
    
    if (_numShortestPathParents._val == 0) {
        [self findNewShortestPath];
    }
}
-(void) removeParentValue: (Node*) parent {
    for (int parentIndex = 0; parentIndex < _numParents._val; parentIndex++) {
        if ((Node*)_parents[parentIndex] == parent) {
            assignTRInt(&_numParents,_numParents._val-1,_trail);
            assignTRId(&_parents[parentIndex], _parents[_numParents._val],_trail);
            parentIndex--;
        }
    }
    if (![self isNonVitalAndParentless]) {
        if ([self hasLongestPathParent: parent]) {
            [self removeLongestPathParent: parent];
        }
        if ([self hasShortestPathParent: parent]) {
            [self removeShortestPathParent: parent];
        }
    }
}

-(bool) isVital {
    return _isSource || _isSink;
}

-(bool) isNonVitalAndChildless {
    return !(_numChildren._val || [self isVital]);
}

-(bool) isNonVitalAndParentless {
    return !(_numParents._val || [self isVital]);
}

-(void) mergeWith:(Node*)other {
    [self mergeStateWith: other];
    [self takeParentsFrom: other];
}
-(bool) hasParent:(Node*)parent {
    for (int parentIndex = 0; parentIndex < _numParents._val; parentIndex++) {
        if ((Node*)_parents[parentIndex] == parent) {
            return true;
        }
    }
    return false;
}
-(void) takeParentsFrom:(Node*)other {
    for (int parentIndex = 0; parentIndex < [other numParents]; parentIndex++) {
        Node* parent = (Node*)[other parents][parentIndex];
        
        int child_index = [parent findChildIndex: other];
        while(child_index != -1) {
            [parent addChild: self at:child_index];
            child_index = [parent findChildIndex: other];
        }
        if (![self hasParent: parent]) {    //Is this needed?  Not sure
            [self addParent: parent];
        }
    }
}
-(bool) canChooseValue:(int)value {
    return [_state canChooseValue:value forVariable:_value];
}
-(void) mergeStateWith:(Node*)other {
    [_state mergeStateWith: [other getState]];
}
@end

@implementation GeneralState
-(id) initState:(int)variableIndex {
    return self;
}
-(id) initState:(GeneralState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    _variableIndex = variableIndex;
    return self;
}
-(id) state {
    return NULL;
}
-(char*) stateChar {
    return NULL;
}
-(int) variableIndex {
    return _variableIndex;
}
-(bool) canChooseValue:(int)value {
    return true;
}
-(void) mergeStateWith:(GeneralState *)other {
    return;
}
-(bool) stateAllows:(int)variable {
    return true;
}
-(int) numPathsForVariable:(int)variable {return 0; }
-(int) numPathsWithNextVariable:(int)variable {return 0; }
-(int*) getObjectiveValuesForVariable:(int)variable {
    return NULL;
}
@end

@implementation AllDifferentState
-(id) initAllDifferentState:(int)minValue :(int)maxValue {
    _state = [[NSMutableArray alloc] init];
    for (int stateValue = minValue; stateValue <= maxValue; stateValue++) {
        [_state addObject:@YES];
    }
    _minValue = minValue;
    _maxValue = maxValue;
    
    return self;
}
-(id) initAllDifferentState:(int)minValue :(int)maxValue parentNodeState:(AllDifferentState*)parentNodeState withValue:(int)edgeValue {
    _state = [[NSMutableArray alloc] init];
    for (int stateValue = minValue; stateValue <= maxValue; stateValue++) {
        if (stateValue != edgeValue) {
            [_state addObject: [NSNumber numberWithBool: [parentNodeState canChooseValue: stateValue]]];
        } else {
            [_state addObject: @NO];
        }
    }
    _minValue = minValue;
    _maxValue = maxValue;
    
    return self;
}
-(id) state
{
    return _state;
}
-(bool) canChooseValue:(int)value {
    return [_state[value - _minValue] boolValue];
}
-(void) mergeStateWith:(AllDifferentState*)other {
    for (int value = _minValue; value <= _maxValue; value++) {
        bool combinedStateValue = [self canChooseValue: value] || [other canChooseValue:value];
        [_state setObject: [NSNumber numberWithBool: combinedStateValue] atIndexedSubscript:value];
    }
}
-(bool) stateAllows:(int)variable {
    return [self canChooseValue:variable]; // TODO: FIX?
}
@end

@implementation MISPState
-(id) initState:(int)variableIndex :(int)minValue :(int)maxValue adjacencies:(bool**)adjacencyMatrix {
    _variableIndex = variableIndex;
    _minValue = minValue;
    _maxValue = maxValue;
    _adjacencyMatrix = adjacencyMatrix;
    
    _state = malloc((_maxValue - _minValue +1) * sizeof(bool));
    _state -= _minValue;
    _stateChar = malloc((_maxValue - _minValue +1) * sizeof(char));
    _stateChar -= _minValue;
    for (int stateValue = _minValue; stateValue <= _maxValue; stateValue++) {
        _state[stateValue] = true;
        _stateChar[stateValue] = '1';
    }
    
    return self;
}
-(id) initState:(int)minValue :(int)maxValue parentNodeState:(MISPState*)parentNodeState withVariableIndex:(int)variableIndex withValue:(int)edgeValue adjacencies:(bool**)adjacencyMatrix{
    _variableIndex = variableIndex;
    _minValue = minValue;
    _maxValue = maxValue;
    _adjacencyMatrix = adjacencyMatrix;
    
    _state = malloc((_maxValue - _minValue +1) * sizeof(bool));
    _state -= _minValue;
    bool* parentState = [parentNodeState state];
    int parentVariable = [parentNodeState variableIndex];
    bool* parentAdjacencies = adjacencyMatrix[parentVariable];
    _stateChar = malloc((_maxValue - _minValue +1) * sizeof(char));
    _stateChar -= _minValue;
    if (edgeValue == 1) {
        for (int stateIndex = _minValue; stateIndex <= _maxValue; stateIndex++) {
            _state[stateIndex] = !parentAdjacencies[stateIndex] && parentState[stateIndex];
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
    }
    else {
        for (int stateIndex = _minValue; stateIndex <= _maxValue; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex];
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
    }
    _state[parentVariable] = false;
    _stateChar[parentVariable] = '0';

    return self;
}
-(bool*) state { return _state; }
-(char*) stateChar { return _stateChar; }
-(int) variableIndex { return _variableIndex; }
-(bool) canChooseValue:(int)value {
    if (value == 0) return true;
    return _state[_variableIndex];
}
-(void) mergeStateWith:(MISPState *)other {
    for (int value = _minValue; value <= _maxValue; value++) {
        bool combinedStateValue = [self canChooseValue: value] || [other canChooseValue:value];
        _state[value] = [NSNumber numberWithBool: combinedStateValue];
    }
}
-(bool) stateAllows:(int)variable {
    if (!_state[variable]) {
        return false;
    }
    return !_adjacencyMatrix[_variableIndex][variable];
}
@end


@implementation CPMDD
-(id) initCPMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced
{
    self = [super initCPCoreConstraint: engine];
    _trail = [engine trail];
    _x = x;
    _reduced = reduced;
    _objective = NULL;
    
    _max_nodes_per_layer = 1000;
    
    layer_size = malloc(([_x count]+1) * sizeof(TRInt));
    max_layer_size = malloc(([_x count]+1) * sizeof(TRInt));
    for (int layer = 0; layer <= [_x count]; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
        max_layer_size[layer] = makeTRInt(_trail,1);
    }
    
    min_domain_val = [_x[[_x low]] min];    //Not great
    max_domain_val = [_x[[_x low]] max];
    
    layer_variable_count = malloc(([_x count]+1) * sizeof(TRInt*));
    for (int layer = 0; layer < [_x count] +1; layer++) {
        layer_variable_count[layer] = malloc((max_domain_val - min_domain_val + 1) * sizeof(TRInt));
        for (int variable = 0; variable <= max_domain_val - min_domain_val; variable++) {
            layer_variable_count[layer][variable] = makeTRInt(_trail,0);
        }
        
        layer_variable_count[layer] -= min_domain_val;
    }

    layers = malloc(([_x count]+1) * sizeof(Node**));
    for (int layer = 0; layer <= [_x count]; layer++) {
        layers[layer] = malloc(1 * sizeof(Node*));
    }
    
    _layer_to_variable = malloc(([_x count]+1) * sizeof(int));
    _variable_to_layer = malloc(([_x count]+1) * sizeof(int));
    
    _variable_to_layer -= [_x low];
    
    _variableUsed = malloc([_x count] * sizeof(bool));
    _variableUsed -= [_x low];
    for (int variableIndex = [_x low]; variableIndex <= [_x up]; variableIndex++) {
        _variableUsed[variableIndex] = false;
    }
    _stateClass = [GeneralState class];
    return self;
}
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize
{
    self = [self initCPMDD:engine over:x reduced:reduced];
    _objective = objective;
    _maximize = maximize;
    _stateClass = [GeneralState class];
    return self;
}
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x stateClass:(Class)stateClass
{
    self = [self initCPMDD:engine over:x reduced:true];
    _stateClass = stateClass;
    return self;
}
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass
{
    self = [self initCPMDD:engine over:x reduced:reduced];
    _objective = objective;
    _maximize = maximize;
    _stateClass = stateClass;
    return self;
}
-(NSSet*)allVars
{
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    ORUInt nb = 0;
    for(ORInt var = 0; var< [_x count]; var++)
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
    
    for (int layer = 0; layer < [_x count]; layer++) {
        if (_reduced) {
            [self reduceLayer: layer];
        }
        [self cleanLayer: layer];
        
        if (layer != [_x count] -1) {
            int next_variable = [self pickVariableBelowLayer:layer];
        
            _variable_to_layer[next_variable] = layer+1;
            _layer_to_variable[layer+1] = next_variable;
            _variableUsed[next_variable] = true;
        }
        [self buildNewLayerUnder:layer];
    }
    [self addPropagationsAndTrimValues];
    
    if (_objective != nil) {
        for (int layer = (int)[_x count]; layer >= 0; layer--) {
            for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
                [layers[layer][node_index] updateReversePaths];
            }
        }
    }
    return;
}
-(int) pickVariableBelowLayer:(int)layer {
    int selected_variable;
    
    int* variableCount = malloc([_x count] * sizeof(int));
    variableCount -= [_x low];
    
    for (int variable_index = [_x low]; variable_index <= [_x up]; variable_index++) {
        variableCount[variable_index] = 0;
    }
    for (int variable_index = [_x low]; variable_index <= [_x up]; variable_index++) {
        if (!_variableUsed[variable_index]) {
            selected_variable = variable_index;
            break;
        }
    }
    
    for (int variable_index = [_x low]; variable_index <= [_x up]; variable_index++) {
        if (!_variableUsed[variable_index]) {
            for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
                Node* node = layers[layer][node_index];
                id state = [node getState];
    
                //variableCount[variable_index] += [state numPathsForVariable:variable_index];
                variableCount[variable_index] += [state numPathsWithNextVariable:variable_index];
            }
            if (variableCount[variable_index] < variableCount[selected_variable]) {
                selected_variable = variable_index;
            }
        }
    }
    
    variableCount += [_x low];
    return selected_variable;
}
-(int) layerIndexForVariable:(int)variableIndex {
    return _variable_to_layer[variableIndex];
}
-(int) variableIndexForLayer:(int)layer {
    return _layer_to_variable[layer];
}
-(int*) getObjectiveValuesForLayer:(int)layer {
    return [_stateClass getObjectiveValuesForVariable: [self variableIndexForLayer:layer]];
}
-(void) createRootAndSink
{
    Node *sink = [[Node alloc] initNode: _trail maxParents:(_max_nodes_per_layer * (max_domain_val - min_domain_val +1))];
    [sink setIsSink: true];
    [self addNode: sink toLayer:((int)[_x count])];
    
    id state = [self generateRootState: [_x low]];
    _variable_to_layer[[_x low]] = 0;
    _layer_to_variable[0] = [_x low];
    
    Node* root;
    
    if (_objective != nil) {
        root =[[Node alloc] initNode: _trail
                                maxParents:(0 * (max_domain_val - min_domain_val +1))
                             minChildIndex:min_domain_val
                            maxChildIndex:max_domain_val
                                     value:[_x low]
                                     state:state
                           objectiveValues:[self getObjectiveValuesForLayer:0]];
    } else {
        root =[[Node alloc] initNode: _trail
                                maxParents:(0 * (max_domain_val - min_domain_val +1))
                             minChildIndex:min_domain_val
                             maxChildIndex:max_domain_val
                                     value:[_x low]
                                     state:state];
    }
    [root setIsSource:true];
    [self addNode:root toLayer:0];
    _variableUsed[[_x low]] = true;
}
-(void) reduceLayer:(int)layer {
    /*NSMutableDictionary* foundStates = [[NSMutableDictionary alloc] init];
    
    for (int nodeIndex = 0; nodeIndex < layer_size[layer]._val; nodeIndex++) {
        Node* node= layers[layer][nodeIndex];
        char* stateChar = [[node getState] stateChar];
        
        NSString* stateKey = [NSString stringWithCString:stateChar encoding:NSASCIIStringEncoding];
        
        if ([foundStates objectForKey:stateKey]) {
            [foundStates[stateKey] takeParentsFrom:node];
            [self removeChildlessNodeFromMDD:node trimmingVariables:false];
            nodeIndex--;
        } else {
            [foundStates setObject:node forKey:stateKey];
        }
    }*/
    for (int first_node_index = 0; first_node_index < layer_size[layer]._val-1; first_node_index++) {
        for (int second_node_index = first_node_index+1; second_node_index < layer_size[layer]._val; second_node_index++) {
            Node* first_node = layers[layer][first_node_index];
            Node* second_node = layers[layer][second_node_index];
            
            id first_node_state = [first_node getState];
            id second_node_state = [second_node getState];
            
            if ([first_node_state equivalentTo: second_node_state]) {
                [first_node takeParentsFrom:second_node];
                [self removeChildlessNodeFromMDD:second_node trimmingVariables:false];
                second_node_index--;
            }
        }
    }
}
-(void) cleanLayer:(int)layer
{
    return;
}
-(void) buildNewLayerUnder:(int)layer
{
    for (int parentNodeIndex = 0; parentNodeIndex < layer_size[layer]._val; parentNodeIndex++) {
        Node* parentNode = layers[layer][parentNodeIndex];
        [self createChildrenForNode:parentNode];
    }
}
-(void) createChildrenForNode:(Node*)parentNode
{
    int parentValue = [parentNode value];
    int parentLayer = [self layerIndexForVariable:parentValue];
    for (int edgeValue = [parentNode minChildIndex]; edgeValue <= [parentNode maxChildIndex]; edgeValue++) {
        if ([parentNode canChooseValue: edgeValue]) {
            Node* childNode;
            
            id state = [self generateStateFromParent:parentNode withValue:edgeValue];   //~ 50 CPU
            if (parentLayer != [_x count]-1) {
                if (_objective != nil) {
                    childNode = [[Node alloc] initNode: _trail
                                            maxParents:(max_layer_size[parentLayer]._val * (max_domain_val - min_domain_val +1))
                                         minChildIndex:min_domain_val
                                         maxChildIndex:max_domain_val
                                                 value:[self variableIndexForLayer:parentLayer + 1]
                                                 state:state
                                       objectiveValues:[self getObjectiveValuesForLayer:parentLayer+1]];
                }
                else {
                    childNode = [[Node alloc] initNode: _trail
                                            maxParents:(max_layer_size[parentLayer]._val * (max_domain_val - min_domain_val +1))
                                         minChildIndex:min_domain_val
                                         maxChildIndex:max_domain_val
                                                 value:[self variableIndexForLayer:parentLayer + 1]
                                                 state:state];
                }
                [self addNode:childNode toLayer:parentLayer+1];
            } else {
                childNode = layers[[_x count]][0];
            }
            
            [parentNode addChild:childNode at:edgeValue];
            [childNode addParent:parentNode];
            assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
        }
    }
}
-(void) addPropagationsAndTrimValues
{
    for(ORInt layer = 0; layer < [_x count]; layer++) {
        [self trimValuesFromLayer:layer];
        [self addPropagationToLayer: layer];
    }
    
    if (_objective != NULL) {
        int longestPath = [layers[[_x count]][0] longestPath];
        int shortestPath = [layers[[_x count]][0] shortestPath];
        
        if (_maximize) {
            if (longestPath < [_objective min]) {
                failNow();
            }
        } else {
            if (shortestPath > [_objective max]) {
                failNow();
            }
        }
        
        if ([_objective max] > longestPath) {
            [_objective updateMax: longestPath];
        }
        if ([_objective min] < shortestPath) {
            [_objective updateMin: shortestPath];
        }
    }
}
-(void) trimValuesFromLayer:(ORInt)layer
{
    int variableIndex = [self variableIndexForLayer:layer];
    for (int value = min_domain_val; value <= max_domain_val; value++) {
        if (!layer_variable_count[layer][value]._val) {
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
    return [[_stateClass alloc] initRootState:variableValue domainMin: min_domain_val domainMax: max_domain_val];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    id parentState = [parentNode getState];
    int parentLayer = [self layerIndexForVariable: [parentState variableIndex]];
    int variableIndex = [self variableIndexForLayer:parentLayer+1];
    
    return [[_stateClass alloc] initState:parentState assigningVariable:variableIndex withValue:value];
}
-(void) addNode:(Node*)node toLayer:(int)layer_index
{
    if (max_layer_size[layer_index]._val == layer_size[layer_index]._val) {
        Node* *temp = malloc(layer_size[layer_index]._val * sizeof(Node*));
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            temp[node_index] = layers[layer_index][node_index];
        }
        
        assignTRInt(&max_layer_size[layer_index], max_layer_size[layer_index]._val*2, _trail);
        layers[layer_index] = malloc(max_layer_size[layer_index]._val * sizeof(Node*));
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            layers[layer_index][node_index] = temp[node_index];
        }
    }
    layers[layer_index][layer_size[layer_index]._val] = node;
    assignTRInt(&layer_size[layer_index], layer_size[layer_index]._val+1, _trail);
}
-(void) removeNode: (Node*) node {
    int node_layer = [self layerIndexForVariable:node.value];
    Node* *layer = layers[node_layer];
    int currentLayerSize = layer_size[node_layer]._val;
    
    for (int node_index = 0; node_index < currentLayerSize; node_index++) {
        if (layer[node_index] != NULL && layer[node_index] == node) {
            int finalNodeIndex = layer_size[node_layer]._val-1;
            assignTRId(&layer[node_index], layer[finalNodeIndex], _trail);
            assignTRId(&layer[finalNodeIndex], NULL, _trail);
            assignTRInt(&layer_size[node_layer], finalNodeIndex,_trail);
            //node_index--;
            //currentLayerSize--;
            return; //Each node sould only be on a given layer once, right?
        }
    }
}
-(void) removeChildlessNodeFromMDD:(Node*)node trimmingVariables:(bool)trimming
{
    int parentLayer;
    int numParents = [node numParents];
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        Node* parent = (Node*)[node parents][parentIndex];
        
        parentLayer = [self layerIndexForVariable:[parent value]];
        int child_index = [parent findChildIndex: node];
        while(child_index != -1) {
            [parent removeChildAt:child_index];
            
            assignTRInt(&layer_variable_count[parentLayer][child_index], layer_variable_count[parentLayer][child_index]._val -1, _trail);
            if (trimming && !layer_variable_count[parentLayer][child_index]._val) {
                [_x[[parent value]] remove: child_index];
            }
            
            child_index = [parent findChildIndex: node];
        }
        if ([parent isNonVitalAndChildless]) {
            [self removeChildlessNodeFromMDD: parent trimmingVariables:trimming];
            //parentIndex--;
        } else {
            if (_objective != nil) {
                [parent updateReversePaths];
            }
        }
    }
    [self removeNode: node];
}
-(void) removeParentlessNodeFromMDD:(Node*)node trimmingVariables:(bool)trimming
{
    int nodeLayer = [self layerIndexForVariable:[node value]];
    for(int child_index = min_domain_val; child_index <= max_domain_val; child_index++) {
        Node* childNode = [node children][child_index];
        
        if (childNode != NULL) {
            [node removeChildAt: child_index];
            [childNode removeParentValue: node];
            
            assignTRInt(&layer_variable_count[nodeLayer][child_index], layer_variable_count[nodeLayer][child_index]._val -1, _trail);
            if (trimming & !layer_variable_count[nodeLayer][child_index]._val) {
                [_x[[node value]] remove: child_index];
            }
            
            if ([childNode isNonVitalAndParentless]) {
                [self removeParentlessNodeFromMDD:childNode trimmingVariables:trimming];
                child_index--;
            }
        }
    }
    [self removeNode: node];
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    Node* *layer = layers[layer_index];
    
    for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
        if (layer[node_index] != NULL) {
            Node* node = layer[node_index];
            Node* childNode = [node children][value];
            
            if (childNode != NULL) {
                [node removeChildAt: value];
                if ([node findChildIndex:childNode] == -1) {
                    [childNode removeParentValue:node];
                } else {
                    if ([childNode hasLongestPathParent: node] && value == 1) {
                        [childNode removeLongestPathParent: node];
                    }
                    if ([childNode hasShortestPathParent: node] && value == 0) {
                        [childNode removeShortestPathParent: node];
                    }
                }
                
                if ([childNode isNonVitalAndParentless]) {
                    [self removeParentlessNodeFromMDD:childNode trimmingVariables:true];
                }
                if ([node isNonVitalAndChildless]) {
                    [self removeChildlessNodeFromMDD: node trimmingVariables:true];
                    node_index--;
                } else {
                    if (_objective != nil) {
                        [node updateReversePaths];
                    }
                }
            }
        }
    }
    //[self printGraph];
    if (_objective != NULL) {
        int longestPath = [layers[[_x count]][0] longestPath];
        int shortestPath = [layers[[_x count]][0] shortestPath];
    
        if (_maximize) {
            if (longestPath < [_objective min]) {
                failNow();
            }
        } else {
            if (shortestPath > [_objective max]) {
                failNow();
            }
        }
        if (shortestPath == longestPath) {
            [_objective bind:shortestPath];
        }
    }
}

-(ORInt) recommendationFor: (ORInt) variableIndex
{
    if (_objective != NULL) {
        if (_maximize){
            int optimal = [layers[[_x count]][0] longestPathContainingSelf];
            
            int layer_index = [self layerIndexForVariable:variableIndex];
            for (int index = 0; index < layer_size[layer_index]._val; index++) {
                Node* node = layers[layer_index][index];
                if ([node longestPathContainingSelf] == optimal) {
                    Node** children = [node children];
                    for (int child_index = [node minChildIndex]; child_index <= [node maxChildIndex]; child_index++) {
                        Node* child = children[child_index];
                        if (child != NULL && ([node longestPath] + [node getObjectiveValueFor: child_index] + [child reverseLongestPath]) == optimal ) {
                            return child_index;
                        }
                    }
                }
            }
        } else {
        }
    }
    return [_x[variableIndex] min];
}

-(void) printGraph {
    //[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat: @"/Users/ben/graphs/%d.dot", ] contents:nil attributes:nil];
    NSMutableDictionary* nodeNames = [[NSMutableDictionary alloc] init];
    
    NSMutableString* output = [NSMutableString stringWithFormat: @"\ndigraph {\n"];
    
    for (int layer = 0; layer < [_x count]; layer++) {
        for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
            Node* node = layers[layer][node_index];
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
                        [output appendString: [NSString stringWithFormat: @"%d -> %d [label=\"%d,%d\"];\n", [nodeNames[nodePointerValue] intValue], [nodeNames[childPointerValue] intValue], [child shortestPath], [child longestPath]]];
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
    
    [output writeToFile: [NSString stringWithFormat: @"/Users/ben/graphs/%d.dot", numBound] atomically: YES encoding:NSUTF8StringEncoding error: nil];
}
@end

@implementation CPMDDRestriction
-(id) initCPMDDRestriction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize reduced:(bool)reduced
{
    self = [super initCPMDD:engine over:x reduced:reduced];
    restricted_size = restrictionSize;
    return self;
}
-(id) initCPMDDRestriction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objective maximize:maximize];
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
    [self removeChildlessNodeFromMDD:node trimmingVariables:false];
}

//minLP
-(Node*) findNodeToRemove:(int)layer
{
    int remove_index = 0;
    int remove_longestPath = [layers[layer][remove_index] longestPath];
    for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
        int node_longestPath = [layers[layer][node_index] longestPath];
        
        if (node_longestPath < remove_longestPath) {
            remove_index = node_index;
            remove_longestPath = node_longestPath;
        }
    }
    Node* node = layers[layer][remove_index];
    return node;
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
    relaxed_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objective maximize:maximize];
    _relaxed = true;
    relaxed_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass
{
    self = [super initCPMDD:engine over:x stateClass:stateClass];
    _relaxed = true;
    relaxed_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass
{
    self = [super initCPMDD:engine over:x stateClass:stateClass];
    _relaxed = relaxed;
    relaxed_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objective maximize:maximize stateClass:stateClass];
    _relaxed = true;
    relaxed_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objective maximize:maximize stateClass:stateClass];
    _relaxed = relaxed;
    relaxed_size = relaxationSize;
    return self;
}
-(void) cleanLayer:(int)layer
{
    if (_relaxed) {
        while (layer_size[layer]._val > relaxed_size) {
            [self mergeTwoNodesOnLayer: layer];
        }
    }
}
-(void) mergeTwoNodesOnLayer:(int)layer
{
    Node* first_node;
    Node* second_node;
    [self findNodesToMerge:layer first:&first_node second:&second_node];
    
    [first_node mergeWith: second_node];
    [self removeChildlessNodeFromMDD:second_node trimmingVariables:false];
}

-(void) findNodesToMerge:(int)layer first:(Node**)first second:(Node**)second
{
    if (_objective != NULL) {   //merge nodes with worst objective value - keeps added paths from affecting objective by much
        int first_node_index = 0;
        int first_node_longest_path = [layers[layer][first_node_index] longestPath];
        int second_node_index = 1;
        int second_node_longest_path = [layers[layer][second_node_index] longestPath];
        for (int node_index = 2; node_index < layer_size[layer]._val; node_index++) {
            int node_longest_path = [layers[layer][node_index] longestPath];
            if (node_longest_path < first_node_longest_path && node_longest_path < second_node_longest_path) {
                if (first_node_longest_path < second_node_longest_path) {
                    second_node_index = node_index;
                    second_node_longest_path = node_longest_path;
                } else {
                    first_node_index = node_index;
                    first_node_longest_path = node_longest_path;
                }
            } else if (node_longest_path < first_node_longest_path) {
                first_node_index = node_index;
                first_node_longest_path = node_longest_path;
            } else if (node_longest_path < second_node_longest_path) {
                second_node_index = node_index;
                second_node_longest_path = node_longest_path;
            }
        }
        *first = layers[layer][first_node_index];
        *second = layers[layer][second_node_index];
    } else {    //merge nodes with smallest state-difference - keeps relaxation from adding as many paths
        int first_node_index, second_node_index;
        int best_first_node_index = 0;
        int best_second_node_index = 1;
        int smallest_state_differential = INT_MAX;
        for (first_node_index = 0; first_node_index < layer_size[layer]._val -1; first_node_index++) {
            CustomState* first_node_state = [layers[layer][first_node_index] getState];
            for (second_node_index = first_node_index +1; second_node_index < layer_size[layer]._val; second_node_index++) {
                CustomState* second_node_state = [layers[layer][second_node_index] getState];
                int state_differential = [first_node_state stateDifferential: second_node_state];
                if (state_differential < smallest_state_differential) {
                    smallest_state_differential = state_differential;
                    best_first_node_index = first_node_index;
                    best_second_node_index = second_node_index;
                }
            }
        }
        
        *first = layers[layer][best_first_node_index];
        *second = layers[layer][best_second_node_index];
    }
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPMDDRelaxation:%02d %@>",_name,_x];
}
@end







@implementation CPExactMDDAllDifferent

-(id) initCPExactMDDAllDifferent: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced
{
    self = [super initCPMDD:engine over:x reduced:reduced];
    return self;
}
-(id) generateRootState:(int)variableValue
{
    return [[AllDifferentState alloc] initAllDifferentState:min_domain_val :max_domain_val];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    return [[AllDifferentState alloc] initAllDifferentState:min_domain_val :max_domain_val parentNodeState:[parentNode getState] withValue:value];
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPExactMDDAllDifferent:%02d %@>",_name,_x];
}
@end

@implementation CPRestrictedMDDAllDifferent
-(id) initCPRestrictedMDDAllDifferent: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize reduced:(bool)reduced
{
    self = [super initCPMDDRestriction:engine over:x restrictionSize:restrictionSize reduced:reduced];
    return self;
}
-(id) generateRootState:(int)variableValue
{
    return [[AllDifferentState alloc] initAllDifferentState:min_domain_val :max_domain_val];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    return [[AllDifferentState alloc] initAllDifferentState:min_domain_val :max_domain_val parentNodeState:[parentNode getState] withValue:value];
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPRestsrictedMDDAllDifferent:%02d %@>",_name,_x];
}
@end

@implementation CPRelaxedMDDAllDifferent
-(id) initCPRelaxedMDDAllDifferent: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced
{
    self = [super initCPMDDRelaxation:engine over:x relaxationSize:relaxationSize reduced:reduced];
    return self;
}
-(id) generateRootState:(int)variableValue
{
    return [[AllDifferentState alloc] initAllDifferentState:min_domain_val :max_domain_val];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    return [[AllDifferentState alloc] initAllDifferentState:min_domain_val :max_domain_val parentNodeState:[parentNode getState] withValue:value];
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPRelaxedMDDAllDifferent:%02d %@>",_name,_x];
}
@end

@implementation CPExactMDDMISP
-(id) initCPExactMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<CPIntVar>)objectiveValue
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objectiveValue maximize:true];
    _adjacencyMatrix = adjacencyMatrix;
    _weights = weights;
    return self;
}
-(int*) getObjectiveValuesForLayer:(int)layer
{
    int* objectiveValues = malloc(2 * sizeof(int));
    objectiveValues[0] = 0;
    objectiveValues[1] = (int)[_weights[[self variableIndexForLayer:layer]] longValue];
    
    return objectiveValues;
}
-(id) generateRootState:(int)variableValue
{
    return [[MISPState alloc] initState:variableValue :[_x low] :[_x up] adjacencies:_adjacencyMatrix];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    MISPState* parentState = [parentNode getState];
    int parentLayer = [self layerIndexForVariable: [parentState variableIndex]];
    int variableIndex = [self variableIndexForLayer:parentLayer+1];
    return [[MISPState alloc] initState:[_x low] :[_x up] parentNodeState:[parentNode getState] withVariableIndex:variableIndex withValue:value adjacencies:_adjacencyMatrix];

}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPExactMDDMISP:%02d %@>",_name,_x];
}
@end

@implementation CPRestrictedMDDMISP
-(id) initCPRestrictedMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x size:(ORInt)restrictionSize reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<CPIntVar>)objectiveValue
{
    self = [super initCPMDDRestriction:engine over:x restrictionSize:restrictionSize reduced:reduced objective:objectiveValue maximize:true];
    _adjacencyMatrix = adjacencyMatrix;
    _weights = weights;
    return self;
}
-(int*) getObjectiveValuesForLayer:(int)layer
{
    int* objectiveValues = malloc(2 * sizeof(int));
    objectiveValues[0] = 0;
    objectiveValues[1] = (int)[_weights[[self variableIndexForLayer:layer]] longValue];
    
    return objectiveValues;
}
-(id) generateRootState:(int)variableValue
{
    return [[MISPState alloc] initState:variableValue :[_x low] :[_x up] adjacencies:_adjacencyMatrix];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    MISPState* parentState = [parentNode getState];
    int parentLayer = [self layerIndexForVariable: [parentState variableIndex]];
    int variableIndex = [self variableIndexForLayer:parentLayer+1];
    return [[MISPState alloc] initState:[_x low] :[_x up] parentNodeState:[parentNode getState] withVariableIndex:variableIndex withValue:value adjacencies:_adjacencyMatrix];
    
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPRestrictedMDDMISP:%02d %@>",_name,_x];
}
@end

@implementation CPRelaxedMDDMISP
-(id) initCPRelaxedMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x size:(ORInt)relaxationSize reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<CPIntVar>)objectiveValue
{
    self = [super initCPMDDRelaxation:engine over:x relaxationSize:relaxationSize reduced:reduced objective:objectiveValue maximize:true];
    _adjacencyMatrix = adjacencyMatrix;
    _weights = weights;
    return self;
}
-(int*) getObjectiveValuesForLayer:(int)layer
{
    int* objectiveValues = malloc(2 * sizeof(int));
    objectiveValues[0] = 0;
    objectiveValues[1] = (int)[_weights[[self variableIndexForLayer:layer]] longValue];
    
    return objectiveValues;
}
-(id) generateRootState:(int)variableValue
{
    return [[MISPState alloc] initState:variableValue :[_x low] :[_x up] adjacencies:_adjacencyMatrix];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    MISPState* parentState = [parentNode getState];
    int parentLayer = [self layerIndexForVariable: [parentState variableIndex]];
    int variableIndex = [self variableIndexForLayer:parentLayer+1];
    
    MISPState* state = [[MISPState alloc] initState:[_x low] :[_x up] parentNodeState:[parentNode getState] withVariableIndex:variableIndex withValue:value adjacencies:_adjacencyMatrix];
    return state;
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPRelaxedMDDMISP:%02d %@>",_name,_x];
}
@end



@implementation CPCustomMDD
-(id) initCPCustomMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize stateClass:(Class)stateClass
{
    self = [super initCPMDDRelaxation:engine over:x relaxed:relaxed relaxationSize:relaxationSize stateClass:stateClass];
    _priority = HIGHEST_PRIO;
    return self;
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPCustomMDD:%02d %@>",_name,_x];
}
@end

@implementation CPCustomMDDWithObjective
-(id) initCPCustomMDDWithObjective: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objectiveValue maximize:(bool)maximize stateClass:(Class)stateClass
{
    self = [super initCPMDDRelaxation:engine over:x relaxed:relaxed relaxationSize:relaxationSize reduced:reduced objective:objectiveValue maximize:maximize stateClass:stateClass];
    return self;
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPCustomMDDWithObjective:%02d %@>",_name,_x];
}
@end
