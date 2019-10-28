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
-(id) initNode: (id<ORTrail>) trail
{
    [super init];
    _trail = trail;
    _childEdgeWeights = NULL;
    _children = NULL;
    _numChildren = makeTRInt(_trail, 0);
    _minChildIndex = 0;
    _maxChildIndex = 0;
    _maxNumParents = 1;
    _parents = malloc(_maxNumParents * sizeof(TRId));
    _numParents = makeTRInt(_trail, 0);
    _value = -1;
    _isSink = false;
    _isSource = false;
    
    _objectiveValues = NULL;
    _isRelaxed = false;
    /*
    _longestPath = makeTRInt(_trail, -32768);
    _longestPathParents = malloc((maxParents) * sizeof(Node*));
    _numLongestPathParents = makeTRInt(_trail, 0);
    _shortestPath = makeTRInt(_trail, 32767);
    _shortestPathParents = malloc((maxParents) * sizeof(Node*));
    _numShortestPathParents = makeTRInt(_trail, 0);
    
    _reverseLongestPath = makeTRInt(_trail, 0);
    _reverseShortestPath = makeTRInt(_trail, 0);*/
    
    return self;
}
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state
{
    [super init];
    _trail = trail;
    _minChildIndex = minChildIndex;
    _maxChildIndex = maxChildIndex;
    _value = value;
    _children = malloc((_maxChildIndex-_minChildIndex +1) * sizeof(TRId));
    _children -= _minChildIndex;
    for (int child = _minChildIndex; child <= maxChildIndex; child++) {
        _children[child] = makeTRId(_trail, nil);
    }
    
    _state = state;
    
    _numChildren = makeTRInt(_trail, 0);
    _maxNumParents = 1;
    _parents = malloc(_maxNumParents * sizeof(TRId));
    _numParents = makeTRInt(_trail, 0);
    _value = value;
    _isSink = false;
    _isSource = false;
    
    _childEdgeWeights = NULL;
    _objectiveValues = NULL;
    _isRelaxed = false;
    return self;
}
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state objectiveValues:(int*)objectiveValues
{
    self = [self initNode: trail minChildIndex:minChildIndex maxChildIndex:maxChildIndex value:value state:state];
    _objectiveValues = objectiveValues;
    
    _childEdgeWeights = malloc((_maxChildIndex-_minChildIndex +1) * sizeof(TRInt));
    _childEdgeWeights -= _minChildIndex;
    for (int child = _minChildIndex; child <= maxChildIndex; child++) {
        _childEdgeWeights[child] = makeTRInt(_trail, 0);
    }
    _longestPath = makeTRInt(_trail, -32768);
    _longestPathParents = NULL;
    _numLongestPathParents = makeTRInt(_trail, 0);
    _shortestPath = makeTRInt(_trail, 32767);
    _shortestPathParents = NULL;
    _numShortestPathParents = makeTRInt(_trail, 0);
    
    _reverseLongestPath = makeTRInt(_trail, 0);
    _reverseShortestPath = makeTRInt(_trail, 0);
    _isRelaxed = false;
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
    if (_isSource && _objectiveValues != NULL) {
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
-(TRId*) children {
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
    if (_objectiveValues != NULL) {
        assignTRInt(&_childEdgeWeights[index], [self getObjectiveValueFor: index], _trail);
    }
}
-(void) removeChildAt: (int) index {
    assignTRId(&_children[index], NULL, _trail);
    assignTRInt(&_numChildren, _numChildren._val -1, _trail);
    if (_objectiveValues != NULL) {
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

-(TRId*) parents {
    return _parents;
}
-(int) numParents {
    return _numParents._val;
}
-(void) addParent: (Node*) parent {
    if (_maxNumParents == _numParents._val) {
        TRId* temp = malloc(_maxNumParents * sizeof(TRId));
        for (int parent_index = 0; parent_index < _maxNumParents; parent_index++) {
            temp[parent_index] = makeTRId(_trail, _parents[parent_index]);
        }
        
        _maxNumParents *= 2;
        
        _parents = malloc(_maxNumParents * sizeof(TRId));
        for (int parent_index = 0; parent_index < _numParents._val; parent_index++) {
            _parents[parent_index] = makeTRId(_trail,temp[parent_index]);
        }
        for (int parent_index = _numParents._val; parent_index < _maxNumParents; parent_index++) {
            _parents[parent_index] = makeTRId(_trail, NULL);
        }
    }
    assignTRId(&_parents[_numParents._val], parent,_trail);
    assignTRInt(&_numParents,_numParents._val+1,_trail);
    if (_objectiveValues != NULL) {
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
-(void) removeParentOnce: (Node*) parent {
    for (int parentIndex = 0; parentIndex < _numParents._val; parentIndex++) {
        if ((Node*)_parents[parentIndex] == parent) {
            assignTRInt(&_numParents,_numParents._val-1,_trail);
            assignTRId(&_parents[parentIndex], _parents[_numParents._val],_trail);
            parentIndex--;
            break;
        }
    }
    if (![self isNonVitalAndParentless] && _objectiveValues != NULL) {
        if ([self hasLongestPathParent: parent]) {
            [self removeLongestPathParent: parent];
        }
        if ([self hasShortestPathParent: parent]) {
            [self removeShortestPathParent: parent];
        }
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
    if (![self isNonVitalAndParentless] && _objectiveValues != NULL) {
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
-(void) setRelaxed:(bool)relaxed {
    _isRelaxed = relaxed;
}
-(bool) isRelaxed { return _isRelaxed; }
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


@implementation CPAltMDD
-(id) initCPAltMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x
{
    self = [super initCPCoreConstraint: engine];
    _trail = [engine trail];
    _x = x;
    _numVariables = [_x count];
    _hasObjective = false;
    
    layer_size = malloc((_numVariables+1) * sizeof(TRInt));
    max_layer_size = malloc((_numVariables+1) * sizeof(TRInt));
    for (int layer = 0; layer <= _numVariables; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
        max_layer_size[layer] = makeTRInt(_trail,1);
    }
    
    min_domain_val = [_x[[_x low]] min];    //Not great
    max_domain_val = [_x[[_x low]] max];
    
    layer_variable_count = malloc((_numVariables+1) * sizeof(TRInt*));
    for (int layer = 0; layer < _numVariables +1; layer++) {
        layer_variable_count[layer] = malloc((max_domain_val - min_domain_val + 1) * sizeof(TRInt));
        for (int variable = 0; variable <= max_domain_val - min_domain_val; variable++) {
            layer_variable_count[layer][variable] = makeTRInt(_trail,0);
        }
        
        layer_variable_count[layer] -= min_domain_val;
    }
    
    layers = malloc((_numVariables+1) * sizeof(TRId*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        layers[layer] = malloc(1 * sizeof(TRId));
        layers[layer][0] = makeTRId(_trail, nil);
    }
    
    _layer_to_variable = malloc((_numVariables+1) * sizeof(int));
    _variable_to_layer = malloc((_numVariables+1) * sizeof(int));
    
    _variable_to_layer -= [_x low];
    
    _variableUsed = malloc(_numVariables * sizeof(bool));
    _variableUsed -= [_x low];
    for (int variableIndex = [_x low]; variableIndex <= [_x up]; variableIndex++) {
        _variableUsed[variableIndex] = false;
    }
    _stateClass = NULL;
    return self;
}
-(id) initCPAltMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x stateClass:(Class)stateClass
{
    self = [self initCPAltMDD:engine over:x];
    _stateClass = stateClass;
    _hasObjective = [stateClass hasObjective];
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
    return [NSMutableString stringWithFormat:@"<CPAltMDD:%02d %@>",_name,_x];
}
-(void) post
{
    [self createWidthOneMDD];
    [self buildOutMDD];
    
    if (_hasObjective) {
        for (int layer = (int)_numVariables; layer >= 0; layer--) {
            for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
                [layers[layer][node_index] updateReversePaths];
            }
        }
    }
    [self addPropagationsAndTrimValues];
    return;
}
-(void) createWidthOneMDD
{
    [self createRootAndSink];
    
    int last_variable = (int)_numVariables-1;
    
    for (int layer = 0; layer < _numVariables; layer++) {
        if (layer != last_variable) {
            int next_variable = [self pickVariableBelowLayer:layer];
            
            _variable_to_layer[next_variable] = layer+1;
            _layer_to_variable[layer+1] = next_variable;
            _variableUsed[next_variable] = true;
        }
        [self buildNewLayerUnder:layer];
    }
    [self setBottomUpInfoWidthOne];
}
-(void) createRootAndSink
{
    id sinkState = [self generateSinkState];
    Node* sink = [[Node alloc] initNode:_trail
                          minChildIndex:min_domain_val
                          maxChildIndex:max_domain_val
                                  value:-1
                                  state:sinkState];
    [sink setIsSink: true];
    [self addNode: sink toLayer:((int)_numVariables)];
    
    id rootState = [self generateRootState: [_x low]];
    _variable_to_layer[[_x low]] = 0;
    _layer_to_variable[0] = [_x low];
    
    Node* root;
    
    //if (_objective != nil) {
        /*root =[[Node alloc] initNode: _trail
                       minChildIndex:min_domain_val
                       maxChildIndex:max_domain_val
                               value:[_x low]
                               state:rootState
                     objectiveValues:[self getObjectiveValuesForLayer:0]];*/
    //} else {
        root =[[Node alloc] initNode: _trail
                       minChildIndex:min_domain_val
                       maxChildIndex:max_domain_val
                               value:[_x low]
                               state:rootState];
    //}
    [root setIsSource:true];
    [self addNode:root toLayer:0];
    _variableUsed[[_x low]] = true;
}
-(id) generateRootState:(int)variableValue
{
    return [[_stateClass alloc] initRootState:variableValue domainMin: min_domain_val domainMax: max_domain_val trail:_trail];
}
-(id) generateSinkState
{
    return [[_stateClass alloc] initSinkState: min_domain_val domainMax: max_domain_val trail:_trail];
}
-(void) buildNewLayerUnder:(int)layer
{
    Node* parentNode = layers[layer][0];
    int parentValue = [parentNode value];
    
    Node* childNode;
    id parentState = [parentNode getState];
    
    if (layer != _numVariables-1) {
        int variableIndex = [self variableIndexForLayer:layer+1];
        id state = [[_stateClass alloc] initState:parentState variableIndex:variableIndex];
        childNode = [[Node alloc] initNode:_trail minChildIndex:min_domain_val maxChildIndex:max_domain_val value:variableIndex state:state];
        [self addNode:childNode toLayer:layer+1];
    } else {
        childNode = layers[_numVariables][0];
    }
    
    bool first = true;
    id childState = [childNode getState];
    for (int edgeValue = [parentNode minChildIndex]; edgeValue <= [parentNode maxChildIndex]; edgeValue++) {
        if ([_x[parentValue] member: edgeValue]) {
            if (first) {
                [childState setTopDownInfoFor:parentState plusEdge:edgeValue];
                first = false;
            } else {
                /*id tempState = [[_stateClass alloc] initState:parentState variableIndex:parentValue];   //This feels like a bad way to do this. (probably cause it obviously is)
                [tempState setTopDownInfoFor:parentState plusEdge:edgeValue];
                [childState mergeTopDownInfoWith:tempState];
                */
                [childState mergeTopDownInfoWith:parentState withEdge:edgeValue onVariable:parentValue];
            }
            [parentNode addChild:childNode at:edgeValue];
            [childNode addParent:parentNode];
            assignTRInt(&layer_variable_count[layer][edgeValue], layer_variable_count[layer][edgeValue]._val+1, _trail);
        }
    }
}
-(void) setBottomUpInfoWidthOne
{
    for (int layer = (int)_numVariables; layer > 0; layer--) {
        [self setBottomUpInfoWidthOneFromLayer:layer];
    }
}
-(void) setBottomUpInfoWidthOneFromLayer:(int)layer
{
    Node* childNode = layers[layer][0];
    id childState = [childNode getState];
    Node* parentNode = layers[layer-1][0];
    id parentState = [parentNode getState];
    int parentValue = [parentNode value];
    
    bool first = true;
    for (int edgeValue = [parentNode minChildIndex]; edgeValue <= [parentNode maxChildIndex]; edgeValue++) {
        if ([_x[parentValue] member: edgeValue]) {
            if (first) {
                [parentState setBottomUpInfoFor:childState plusEdge:edgeValue];
                first = false;
            } else {
                id tempState = [[_stateClass alloc] initState:parentState variableIndex:[parentState variableIndex]];   //This feels like a bad way to do this. (probably cause it obviously is)
                [tempState setBottomUpInfoFor:childState plusEdge:edgeValue];
                [parentState mergeBottomUpInfoWith:tempState];
            }
        }
    }
}
-(void) buildOutMDD
{
    //This would be for an exact MDD.
    for (int layerIndex = 0; layerIndex < _numVariables; layerIndex++) {
        
    }
}
-(int) pickVariableBelowLayer:(int)layer {
    int selected_variable;
    
    /*int* variableCount = malloc(_numVariables * sizeof(int));
    variableCount -= [_x low];
    
    for (int variable_index = [_x low]; variable_index <= [_x up]; variable_index++) {
        variableCount[variable_index] = 0;
    }*/
    for (int variable_index = [_x low]; variable_index <= [_x up]; variable_index++) {
        if (!_variableUsed[variable_index]) {
            selected_variable = variable_index;
            return selected_variable;
            break;
        }
    }
    
    /*for (int variable_index = [_x low]; variable_index <= [_x up]; variable_index++) {
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
    }*/
    
    //variableCount += [_x low];
    return -1;
}
-(int) layerIndexForVariable:(int)variableIndex {
    return _variable_to_layer[variableIndex];
}
-(int) variableIndexForLayer:(int)layer {
    return _layer_to_variable[layer];
}
-(bool) calculateTopDownInfoFor:(Node*)node onLayer:(int)layerIndex
{
    int parentVarIndex = [self variableIndexForLayer:layerIndex-1];
    Node* *parents = [node parents];
    NSMutableSet* uniqueParents = [[NSMutableSet alloc] init];   //This is a bad way to do this.
    for (int parentIndex = 0; parentIndex < [node numParents]; parentIndex++) {
        [uniqueParents addObject:parents[parentIndex]];
    }
    bool first = true;
    id state = [node getState];
    id oldStateInfo = [[state topDownInfo] copy];
    for (Node* parent in uniqueParents) {
        id parentState = [parent getState];
        Node* *children = [parent children];
        for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
            if (children[childIndex] == node) {
                if (first) {
                    [state setTopDownInfoFor:parentState plusEdge:childIndex];
                    first = false;
                } else {
                    //id tempState = [[_stateClass alloc] initState:parentState variableIndex:parentVarIndex];   //This feels like a bad way to do this. (probably cause it obviously is)
                    //[tempState setTopDownInfoFor:parentState plusEdge:childIndex];
                    //[state mergeTopDownInfoWith:tempState];
                    
                    [state mergeTopDownInfoWith:parentState withEdge:childIndex onVariable:parentVarIndex];
                }

            }
        }
    }
    return ![[state topDownInfo] isEqual: oldStateInfo];
}
-(bool) calculateBottomUpInfoFor:(Node*)node onLayer:(int)layerIndex
{
    int varIndex = [self variableIndexForLayer:layerIndex];
    Node* *children = [node children];
    bool first = true;
    id state = [node getState];
    id oldStateInfo = [[state bottomUpInfo] copy];
    for (int childIndex = [node minChildIndex]; childIndex <= [node maxChildIndex]; childIndex++) {
        if (children[childIndex] != NULL) {
            Node* child = children[childIndex];
            id childState = [child getState];
            if (first) {
                [state setBottomUpInfoFor:childState plusEdge:childIndex];
                first = false;
            } else {
                //id tempState = [[_stateClass alloc] initState:childState variableIndex:varIndex];   //This feels like a bad way to do this. (probably cause it obviously is)
                //[tempState setBottomUpInfoFor:childState plusEdge:childIndex];
                //[state mergeBottomUpInfoWith:tempState];
                
                [state mergeBottomUpInfoWith:childState withEdge:childIndex onVariable:varIndex];
            }
        }
    }
    return ![[state bottomUpInfo] isEqual: oldStateInfo];
}
-(void) addPropagationsAndTrimValues
{
    for(ORInt layer = 0; layer < _numVariables; layer++) {
        [self trimValuesFromLayer:layer];
        [self addPropagationToLayer: layer];
    }
    
    if (_hasObjective) {
        //int longestPath = [layers[_numVariables][0] longestPath];
        //int shortestPath = [layers[_numVariables][0] shortestPath];
        
        /*if (_maximize) {
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
        }*/
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
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    Node* *layer = layers[layer_index];
    
    for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
        Node* node = layer[node_index];
        Node* childNode = [node children][value];
        
        if (childNode != NULL) {
            [node removeChildAt: value];
            if ([node findChildIndex:childNode] == -1) {
                [childNode removeParentValue:node];
            } else if (_hasObjective) {
                /*if ([childNode hasLongestPathParent: node] && value == 1) { //I think the 1/0 here is hardcoded for one objective.  Need to fix.
                    [childNode removeLongestPathParent: node];
                }
                if ([childNode hasShortestPathParent: node] && value == 0) {
                    [childNode removeShortestPathParent: node];
                }*/
            }
            
            if ([childNode isNonVitalAndParentless]) {
                [self removeParentlessNodeFromMDD:childNode fromLayer:(layer_index+1) trimmingVariables:true];
            }
            if ([node isNonVitalAndChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layer_index trimmingVariables:true];
                node_index--;
            } else {
                if (_hasObjective) {
                    [node updateReversePaths];
                }
            }
            
            if (node != NULL) {
                [self calculateBottomUpInfoFor: node onLayer: layer_index];
                
                if (layer_index > 0) {
                    Node* *parents = [node parents];
                    NSMutableSet* uniqueParents = [[NSMutableSet alloc] init];   //This is a bad way to do this.
                    for (int parentIndex = 0; parentIndex < [node numParents]; parentIndex++) {
                        [uniqueParents addObject:parents[parentIndex]];
                    }
                    for (Node* parent in uniqueParents) {
                        id parentState = [parent getState];
                        Node* *children = [parent children];
                        for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
                            Node* child = children[childIndex];
                            if (child == node) {
                                id childState = [child getState];
                                if ([parentState canDeleteChild:childState atEdgeValue:childIndex]) {
                                    [parent removeChildAt:childIndex];
                                    [child removeParentOnce:parent];
                                    assignTRInt(&layer_variable_count[layer_index-1][childIndex], layer_variable_count[layer_index-1][childIndex]._val-1, _trail);
                                    if (layer_variable_count[layer_index-1][childIndex]._val == 0) {
                                        [_x[[self variableIndexForLayer:layer_index-1]] remove: childIndex];
                                    }
                                    if ([child isNonVitalAndParentless]) {
                                        [self removeParentlessNodeFromMDD:child fromLayer:layer_index trimmingVariables:true];
                                    }
                                    if ([parent isNonVitalAndChildless]) {
                                        [self removeChildlessNodeFromMDD:parent fromLayer:layer_index-1 trimmingVariables:true];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (childNode != NULL) {
                [self calculateTopDownInfoFor: childNode onLayer: layer_index+1];
                
                if (layer_index < _numVariables-1) {
                    Node* parent = childNode;
                    id parentState = [parent getState];
                    Node* *children = [parent children];
                    for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
                        Node* child = children[childIndex];
                        if (child != NULL) {
                            id childState = [child getState];
                            if ([parentState canDeleteChild:childState atEdgeValue:childIndex]) {
                                [parent removeChildAt:childIndex];
                                [child removeParentOnce:parent];
                                assignTRInt(&layer_variable_count[layer_index+1][childIndex], layer_variable_count[layer_index+1][childIndex]._val-1, _trail);
                                if (layer_variable_count[layer_index+1][childIndex]._val == 0) {
                                    [_x[[self variableIndexForLayer:layer_index+1]] remove: childIndex];
                                }
                                if ([child isNonVitalAndParentless]) {
                                    [self removeParentlessNodeFromMDD:child fromLayer:layer_index+2 trimmingVariables:true];
                                }
                                if ([parent isNonVitalAndChildless]) {
                                    [self removeChildlessNodeFromMDD:parent fromLayer:layer_index+1 trimmingVariables:true];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    //[self printGraph];
    if (_hasObjective) {
        int longestPath = [layers[_numVariables][0] longestPath];
        int shortestPath = [layers[_numVariables][0] shortestPath];
        
        if (_maximize) {
            /*if (longestPath < [_objective min]) {
                failNow();
            }*/
        } else {
            /*if (shortestPath > [_objective max]) {
                failNow();
            }*/
        }
        if (shortestPath == longestPath) {
            //[_objective bind:shortestPath];
        }
    }
    /*
     TODO:
        Make it bind the min/max path whenever paths get removed
        Make it fail when no longer able to surpass current best (should be semi-functional above)
        Make way of retrieving the objective value from the specifications
     */
}
-(void) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming
{
    int parentLayer = layer-1;
    int numParents = [node numParents];
    Node* *parents = [node parents];
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        Node* parent = parents[parentIndex];
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
            [self removeChildlessNodeFromMDD:parent fromLayer:parentLayer trimmingVariables:trimming];
        } else {
            if (_hasObjective) {
                [parent updateReversePaths];
            }
        }
        
        if (parent != NULL) {
            [self calculateBottomUpInfoFor: parent onLayer: layer-1];
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
            }
        }
    }
    [self removeNode: node];
}
-(void) addNode:(Node*)node toLayer:(int)layer_index
{
    if (max_layer_size[layer_index]._val == layer_size[layer_index]._val) {
        TRId *temp = malloc(layer_size[layer_index]._val * sizeof(TRId));
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            temp[node_index] = makeTRId(_trail, layers[layer_index][node_index]);
        }
        
        assignTRInt(&max_layer_size[layer_index], max_layer_size[layer_index]._val*2, _trail);
        layers[layer_index] = malloc(max_layer_size[layer_index]._val * sizeof(TRId*));
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            layers[layer_index][node_index] = makeTRId(_trail, temp[node_index]);
        }
        for (int node_index = layer_size[layer_index]._val; node_index < max_layer_size[layer_index]._val; node_index++) {
            layers[layer_index][node_index] = makeTRId(_trail, NULL);
        }
    }
    assignTRId(&layers[layer_index][layer_size[layer_index]._val], node,_trail);
    assignTRInt(&layer_size[layer_index], layer_size[layer_index]._val+1, _trail);
}
-(void) removeNodeAt:(int)index onLayer:(int)layer_index {
    Node* *layer = layers[layer_index];
    
    int finalNodeIndex = layer_size[layer_index]._val-1;
    assignTRId(&layer[index], layer[finalNodeIndex], _trail);
    assignTRId(&layer[finalNodeIndex], NULL, _trail);
    assignTRInt(&layer_size[layer_index], finalNodeIndex,_trail);
}
-(void) removeNode: (Node*) node {
    int node_layer = [self layerIndexForVariable:node.value];
    Node* *layer = layers[node_layer];
    int currentLayerSize = layer_size[node_layer]._val;
    
    for (int node_index = 0; node_index < currentLayerSize; node_index++) {
        if (layer[node_index] == node) {
            [self removeNodeAt:node_index onLayer:node_layer];
            //node_index--;
            //currentLayerSize--;
            return; //Each node sould only be on a given layer once, right?
        }
    }
}
@end

@implementation CPMDD
-(id) initCPMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced
{
    self = [super initCPCoreConstraint: engine];
    _trail = [engine trail];
    _x = x;
    _numVariables = [_x count];
    _reduced = reduced;
    _objective = NULL;
    
    layer_size = malloc((_numVariables+1) * sizeof(TRInt));
    max_layer_size = malloc((_numVariables+1) * sizeof(TRInt));
    for (int layer = 0; layer <= _numVariables; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
        max_layer_size[layer] = makeTRInt(_trail,1);
    }
    
    min_domain_val = [_x[[_x low]] min];    //Not great
    max_domain_val = [_x[[_x low]] max];
    
    layer_variable_count = malloc((_numVariables+1) * sizeof(TRInt*));
    for (int layer = 0; layer < _numVariables +1; layer++) {
        layer_variable_count[layer] = malloc((max_domain_val - min_domain_val + 1) * sizeof(TRInt));
        for (int variable = 0; variable <= max_domain_val - min_domain_val; variable++) {
            layer_variable_count[layer][variable] = makeTRInt(_trail,0);
        }
        
        layer_variable_count[layer] -= min_domain_val;
    }
    
    layers = malloc((_numVariables+1) * sizeof(TRId*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        layers[layer] = malloc(1 * sizeof(TRId));
        layers[layer][0] = makeTRId(_trail, nil);
    }
    
    _layer_to_variable = malloc((_numVariables+1) * sizeof(int));
    _variable_to_layer = malloc((_numVariables+1) * sizeof(int));
    
    _variable_to_layer -= [_x low];
    
    _variableUsed = malloc(_numVariables * sizeof(bool));
    _variableUsed -= [_x low];
    for (int variableIndex = [_x low]; variableIndex <= [_x up]; variableIndex++) {
        _variableUsed[variableIndex] = false;
    }
    _stateClass = NULL;
    return self;
}
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize
{
    self = [self initCPMDD:engine over:x reduced:reduced];
    _objective = objective;
    _maximize = maximize;
    _stateClass = NULL;
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
    
    int last_variable = (int)_numVariables-1;
    
    for (int layer = 0; layer < _numVariables; layer++) {
        if (_reduced) {
            [self reduceLayer: layer];
        }
        [self cleanLayer: layer];
        
        if (layer != last_variable) {
            int next_variable = [self pickVariableBelowLayer:layer];
        
            _variable_to_layer[next_variable] = layer+1;
            _layer_to_variable[layer+1] = next_variable;
            _variableUsed[next_variable] = true;
        }
        [self buildNewLayerUnder:layer];
    }
    [self addPropagationsAndTrimValues];
    
    if (_objective != nil) {
        for (int layer = (int)_numVariables; layer >= 0; layer--) {
            for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
                [layers[layer][node_index] updateReversePaths];
            }
        }
    }
    return;
}
-(int) pickVariableBelowLayer:(int)layer {
    int selected_variable;
    
    int* variableCount = malloc(_numVariables * sizeof(int));
    variableCount -= [_x low];
    
    for (int variable_index = [_x low]; variable_index <= [_x up]; variable_index++) {
        variableCount[variable_index] = 0;
    }
    for (int variable_index = [_x low]; variable_index <= [_x up]; variable_index++) {
        if (!_variableUsed[variable_index]) {
            selected_variable = variable_index;
            return selected_variable;
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
    return 0;
    //return [_stateClass getObjectiveValuesForVariable: [self variableIndexForLayer:layer]];
}
-(void) createRootAndSink
{
    Node *sink = [[Node alloc] initNode: _trail];
    [sink setIsSink: true];
    [self addNode: sink toLayer:((int)_numVariables)];
    
    id state = [self generateRootState: [_x low]];
    _variable_to_layer[[_x low]] = 0;
    _layer_to_variable[0] = [_x low];
    
    Node* root;
    
    if (_objective != nil) {
        root =[[Node alloc] initNode: _trail
                             minChildIndex:min_domain_val
                            maxChildIndex:max_domain_val
                                     value:[_x low]
                                     state:state
                           objectiveValues:[self getObjectiveValuesForLayer:0]];
    } else {
        root =[[Node alloc] initNode: _trail
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
    int size_of_layer = layer_size[layer]._val;
    id* node_states = malloc(size_of_layer*sizeof(id));
    Node** layer_nodes = layers[layer];
    for (int node_index = 0; node_index < size_of_layer; node_index++) {
        node_states[node_index] = [layer_nodes[node_index] getState];
    }
    
    for (int first_node_index = 0; first_node_index < size_of_layer-1; first_node_index++) {
        Node* first_node = layer_nodes[first_node_index];
        id first_node_state = node_states[first_node_index];
        for (int second_node_index = first_node_index+1; second_node_index < size_of_layer; second_node_index++) {
            id second_node_state = node_states[second_node_index];
            
            if ([first_node_state equivalentTo: second_node_state]) {
                node_states[second_node_index] = node_states[size_of_layer-1];
                [first_node takeParentsFrom:layer_nodes[second_node_index]];
                [self removeNodeAt:second_node_index onLayer:layer];  //Should be both childless (since next layer isn't made yet) and parentless (since it just gave its parents to first_node)
                second_node_index--;
                size_of_layer--;
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
        if ([_x[parentValue] member: edgeValue] && [parentNode canChooseValue: edgeValue]) {
            Node* childNode;
            
            id state = [self generateStateFromParent:parentNode withValue:edgeValue];
            if (parentLayer != _numVariables-1) {
                if (_objective != nil) {
                    childNode = [[Node alloc] initNode: _trail
                                         minChildIndex:min_domain_val
                                         maxChildIndex:max_domain_val
                                                 value:[self variableIndexForLayer:parentLayer + 1]
                                                 state:state
                                       objectiveValues:[self getObjectiveValuesForLayer:parentLayer+1]];
                }
                else {
                    childNode = [[Node alloc] initNode: _trail
                                         minChildIndex:min_domain_val
                                         maxChildIndex:max_domain_val
                                                 value:[self variableIndexForLayer:parentLayer + 1]
                                                 state:state];
                }
                [self addNode:childNode toLayer:parentLayer+1];
            } else {
                childNode = layers[_numVariables][0];
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
    
    if (_objective != NULL) {
        int longestPath = [layers[_numVariables][0] longestPath];
        int shortestPath = [layers[_numVariables][0] shortestPath];
        
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
    return [[_stateClass alloc] initRootState:variableValue domainMin: min_domain_val domainMax: max_domain_val trail:_trail];
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
        TRId *temp = malloc(layer_size[layer_index]._val * sizeof(TRId));
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            temp[node_index] = makeTRId(_trail, layers[layer_index][node_index]);
        }
        
        assignTRInt(&max_layer_size[layer_index], max_layer_size[layer_index]._val*2, _trail);
        layers[layer_index] = malloc(max_layer_size[layer_index]._val * sizeof(TRId*));
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            layers[layer_index][node_index] = makeTRId(_trail, temp[node_index]);
        }
        for (int node_index = layer_size[layer_index]._val; node_index < max_layer_size[layer_index]._val; node_index++) {
            layers[layer_index][node_index] = makeTRId(_trail, NULL);
        }
    }
    assignTRId(&layers[layer_index][layer_size[layer_index]._val], node,_trail);
    assignTRInt(&layer_size[layer_index], layer_size[layer_index]._val+1, _trail);
}
-(void) removeNodeAt:(int)index onLayer:(int)layer_index {
    Node* *layer = layers[layer_index];
    
    int finalNodeIndex = layer_size[layer_index]._val-1;
    assignTRId(&layer[index], layer[finalNodeIndex], _trail);
    assignTRId(&layer[finalNodeIndex], NULL, _trail);
    assignTRInt(&layer_size[layer_index], finalNodeIndex,_trail);
}
-(void) removeNode: (Node*) node {
    int node_layer = [self layerIndexForVariable:node.value];
    Node* *layer = layers[node_layer];
    int currentLayerSize = layer_size[node_layer]._val;
    
    for (int node_index = 0; node_index < currentLayerSize; node_index++) {
        if (layer[node_index] == node) {
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
-(void) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming
{
    int parentLayer = layer-1;
    int numParents = [node numParents];
    Node* *parents = [node parents];
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        Node* parent = parents[parentIndex];
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
            [self removeChildlessNodeFromMDD:parent fromLayer:parentLayer trimmingVariables:trimming];
        } else {
            if (_objective != nil) {
                [parent updateReversePaths];
            }
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
            }
        }
    }
    [self removeNode: node];
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    Node* *layer = layers[layer_index];
    
    for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
        Node* node = layer[node_index];
        Node* childNode = [node children][value];
            
        if (childNode != NULL) {
            [node removeChildAt: value];
            if ([node findChildIndex:childNode] == -1) {
                [childNode removeParentValue:node];
            } else if (_objective != NULL) {
                if ([childNode hasLongestPathParent: node] && value == 1) { //I think the 1/0 here is hardcoded for one objective.  Need to fix.
                    [childNode removeLongestPathParent: node];
                }
                if ([childNode hasShortestPathParent: node] && value == 0) {
                    [childNode removeShortestPathParent: node];
                }
            }
                
            if ([childNode isNonVitalAndParentless]) {
                [self removeParentlessNodeFromMDD:childNode fromLayer:(layer_index+1) trimmingVariables:true];
            }
            if ([node isNonVitalAndChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layer_index trimmingVariables:true];
                node_index--;
            } else {
                if (_objective != NULL) {
                    [node updateReversePaths];
                }
            }
        }
    }
    //[self printGraph];
    if (_objective != NULL) {
        int longestPath = [layers[_numVariables][0] longestPath];
        int shortestPath = [layers[_numVariables][0] shortestPath];
    
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
            int optimal = [layers[_numVariables][0] longestPathContainingSelf];
            
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
    
    for (int layer = 0; layer < _numVariables; layer++) {
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
    [self removeChildlessNodeFromMDD:node fromLayer:layer trimmingVariables:false];
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

@implementation CPAltMDDRelaxation
-(id) initCPAltMDDRelaxation:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize
{
    self = [super initCPAltMDD:engine over:x];
    _relaxed = true;
    _relaxation_size = relaxationSize;
    _layer_relaxed = malloc((_numVariables+1) * sizeof(TRInt));
    for (int layer = 0; layer <= _numVariables; layer++) {
        _layer_relaxed[layer] = makeTRInt(_trail,1);
    }
    node_relaxed = malloc((_numVariables+1) * sizeof(TRId*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        node_relaxed[layer] = malloc(1 * sizeof(TRId));
        node_relaxed[layer][0] = makeTRInt(_trail, 0);
    }
    return self;
}
-(id) initCPAltMDDRelaxation:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass
{
    self = [super initCPAltMDD:engine over:x stateClass:stateClass];
    _relaxed = true;
    _relaxation_size = relaxationSize;
    _layer_relaxed = malloc((_numVariables+1) * sizeof(TRInt));
    for (int layer = 0; layer <= _numVariables; layer++) {
        _layer_relaxed[layer] = makeTRInt(_trail,1);
    }
    node_relaxed = malloc((_numVariables+1) * sizeof(TRId*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        node_relaxed[layer] = malloc(1 * sizeof(TRId));
        node_relaxed[layer][0] = makeTRInt(_trail, 0);
    }
    return self;
}
-(id) initCPAltMDDRelaxation:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass
{
    self = [super initCPAltMDD:engine over:x stateClass:stateClass];
    _relaxed = relaxed;
    _relaxation_size = relaxationSize;
    _layer_relaxed = malloc((_numVariables+1) * sizeof(TRInt));
    for (int layer = 0; layer <= _numVariables; layer++) {
        _layer_relaxed[layer] = makeTRInt(_trail,1);
    }
    node_relaxed = malloc((_numVariables+1) * sizeof(TRId*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        node_relaxed[layer] = malloc(1 * sizeof(TRId));
        node_relaxed[layer][0] = makeTRInt(_trail, 0);
    }
    return self;
}
-(void) removeChildlessNodeFromMDD:(Node *)node fromLayer:(int)layer trimmingVariables:(bool)trimming
{
    [super removeChildlessNodeFromMDD:node fromLayer:layer trimmingVariables:trimming];
    if (_relaxed) {
        if (_layer_relaxed[layer]._val) {
            assignTRInt(&_layer_relaxed[layer],0,_trail);
            for (int nodeIndex = 0; nodeIndex < layer_size[layer]._val; nodeIndex++) {
                if (node_relaxed[layer][nodeIndex]._val) {
                    assignTRInt(&_layer_relaxed[layer],1,_trail);
                    break;
                }
            }
        }
    }
}
-(void) removeNode: (Node*) node topDown:(bool**)recalcTopDown bottomUp:(bool**)recalcBottomUp {
    int node_layer = [self layerIndexForVariable:node.value];
    Node* *layer = layers[node_layer];
    int currentLayerSize = layer_size[node_layer]._val;
    
    for (int node_index = 0; node_index < currentLayerSize; node_index++) {
        if (layer[node_index] == node) {
            int finalNodeIndex = layer_size[node_layer]._val-1;
            recalcTopDown[node_layer][node_index] = recalcTopDown[node_layer][finalNodeIndex];
            recalcTopDown[node_layer][finalNodeIndex] = false;
            
            [self removeNodeAt:node_index onLayer:node_layer];
            return;
        }
    }
}
-(void) removeChildlessNodeFromMDD:(Node *)node fromLayer:(int)layer trimmingVariables:(bool)trimming topDown:(bool**)recalcTopDown bottomUp:(bool**)recalcBottomUp
{
    int parentLayer = layer-1;
    int numParents = [node numParents];
    Node* *parents = [node parents];
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        Node* parent = parents[parentIndex];
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
            [self removeChildlessNodeFromMDD:parent fromLayer:parentLayer trimmingVariables:trimming];
        } else {
            for (int parent_index = 0; parent_index < layer_size[parentLayer]._val; parent_index++) {
                if (layers[parentLayer][parent_index] == parent) {
                    recalcBottomUp[parentLayer][parent_index] = true;
                    break;
                }
            }/*
            if (_objective != nil) {
                [parent updateReversePaths];
            }*/
        }
    }
    [self removeNode: node topDown:recalcTopDown bottomUp:recalcBottomUp];
    
    
    
    
    if (_relaxed) {
        if (_layer_relaxed[layer]._val) {
            assignTRInt(&_layer_relaxed[layer],0,_trail);
            for (int nodeIndex = 0; nodeIndex < layer_size[layer]._val; nodeIndex++) {
                if (node_relaxed[layer][nodeIndex]._val) {
                    assignTRInt(&_layer_relaxed[layer],1,_trail);
                    break;
                }
            }
        }
    }
}
-(void) removeParentlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming topDown:(bool**)recalcTopDown bottomUp:(bool**)recalcBottomUp
{
    if (_relaxed) {
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
                    for (int childIndex = 0; childIndex < layer_size[childLayer]._val; childIndex++) {
                        if (layers[childLayer][childIndex] == childNode) {
                            recalcTopDown[childLayer][childIndex] = true;
                            break;
                        }
                    }
                }
            }
        }
        [self removeNode: node topDown:recalcTopDown bottomUp:recalcBottomUp];
        
        if (_layer_relaxed[layer]._val) {
            assignTRInt(&_layer_relaxed[layer],0,_trail);
            for (int nodeIndex = 0; nodeIndex < layer_size[layer]._val; nodeIndex++) {
                if (node_relaxed[layer][nodeIndex]._val) {
                    assignTRInt(&_layer_relaxed[layer],1,_trail);
                    break;
                }
            }
        }
    } else {
        [super removeParentlessNodeFromMDD:node fromLayer:layer trimmingVariables:trimming];
    }
}
-(void) addNode:(Node*)node toLayer:(int)layer_index
{
    if (_relaxed) {
        if (max_layer_size[layer_index]._val == layer_size[layer_index]._val) {
            TRInt *relaxed_temp = malloc(layer_size[layer_index]._val * sizeof(TRInt));
            for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
                relaxed_temp[node_index] = makeTRInt(_trail, node_relaxed[layer_index][node_index]._val);
            }
            node_relaxed[layer_index] = malloc(max_layer_size[layer_index]._val*2 * sizeof(TRInt*));
        
            for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
                node_relaxed[layer_index][node_index] = makeTRInt(_trail, relaxed_temp[node_index]._val);
            }
            for (int node_index = layer_size[layer_index]._val; node_index < max_layer_size[layer_index]._val*2; node_index++) {
                node_relaxed[layer_index][node_index] = makeTRInt(_trail, 0);
            }
        }
    }
    [super addNode:node toLayer:layer_index];
}
-(void) removeNodeAt:(int)index onLayer:(int)layer_index {
    if (_relaxed) {
        TRInt *relaxedLayer = node_relaxed[layer_index];
    
        int finalNodeIndex = layer_size[layer_index]._val-1;
        assignTRInt(&relaxedLayer[index], relaxedLayer[finalNodeIndex]._val, _trail);
        assignTRInt(&relaxedLayer[finalNodeIndex], 0, _trail);
    }
    [super removeNodeAt:index onLayer:layer_index];
}
typedef struct {
    Node* parentA;
    int valueA;
    Node* parentB;
    int valueB;
    Node* child;
} CandidateSplit;
-(NSArray*) findNodeSplitsOnLayer:(int)layerIndex
{
    NSMutableArray* candidateSplits = [[NSMutableArray alloc] init];
    Node* child;
    Node* parentA;
    Node* parentB;
    Node* *parents;
    int numParents;
    int nextLayerIndex = layerIndex+1;
    Node* *nextLayer = layers[nextLayerIndex];
    for (int nodeIndex = 0; nodeIndex < layer_size[nextLayerIndex]._val; nodeIndex++) {
        child = nextLayer[nodeIndex];
        numParents = [child numParents];
        parents = [child parents];
        for (int parentAIndex = 0; parentAIndex < numParents-1; parentAIndex++) {
            parentA = parents[parentAIndex];
            for (int parentBIndex = parentAIndex+1; parentBIndex < numParents; parentBIndex++) {
                parentB = parents[parentBIndex];
                for (int parentAValue = [parentA minChildIndex]; parentAValue <= [parentA maxChildIndex]; parentAValue++) {
                    if (parentA == parentB) {
                        for (int parentBValue = parentAValue+1; parentBValue <= [parentB maxChildIndex]; parentBValue++) {
                            if (![[parentA getState] equivalentWithEdge:parentAValue to:[parentB getState] withEdge:parentBValue]) { //Ends up calculating the same addEdge thing to get equivalence many times.  Could save time by just doing each once.
                                CandidateSplit split;
                                split.parentA = parentA;
                                split.parentB = parentB;
                                split.valueA = parentAValue;
                                split.valueB = parentBValue;
                                split.child = child;
                                [candidateSplits addObject:[NSValue valueWithBytes:&split objCType:@encode(CandidateSplit)]];
                            }
                        }
                    } else {
                        for (int parentBValue = [parentB minChildIndex]; parentBValue <= [parentB maxChildIndex]; parentBValue++) {
                            if (![[parentA getState] equivalentWithEdge:parentAValue to:[parentB getState] withEdge:parentBValue]) { //Ends up calculating the same addEdge thing to get equivalence many times.  Could save time by just doing each once.
                                CandidateSplit split;
                                split.parentA = parentA;
                                split.parentB = parentB;
                                split.valueA = parentAValue;
                                split.valueB = parentBValue;
                                split.child = child;
                                [candidateSplits addObject:[NSValue valueWithBytes:&split objCType:@encode(CandidateSplit)]];
                            }
                        }
                    }
                }
            }
        }
    }
    return candidateSplits;
}
typedef struct {
    Node* parent;
    int value;
    Node* child;
} Edge;
-(NSArray*) findEquivalenceClassesIntoNode:(int)nodeIndex onLayer:(int)layerIndex
{
    NSMutableArray* equivalenceClasses = [[NSMutableArray alloc] init];
    int parentLayerIndex = layerIndex-1;
    Node* *parentLayer = layers[parentLayerIndex];
    int childLayerIndex = layerIndex;
    Node* *childLayer = layers[childLayerIndex];
    Node* child = childLayer[nodeIndex];
    int variableIndex = [self variableIndexForLayer:childLayerIndex];
    Node* parent;
    id parentState;
    Node* *children;
    Node* testChild;
    
    for (int parentIndex = 0; parentIndex < layer_size[parentLayerIndex]._val; parentIndex++) {
        parent = parentLayer[parentIndex];
        parentState = [parent getState];
        children = [parent children];
        
        for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
            testChild = children[childIndex];
            if (testChild == child) {
                id tempState = [[_stateClass alloc] initState:parentState variableIndex:variableIndex];   //This feels like a bad way to do this. (probably cause it obviously is)
                [tempState setTopDownInfoFor:parentState plusEdge:childIndex];
                id topDownInfo = [tempState topDownInfo];
                bool foundEquivalence = false;
                
                Edge edge;
                edge.parent = parent;
                edge.value = childIndex;
                edge.child = child;
                for (int equivalenceIndex = 0; equivalenceIndex < [equivalenceClasses count]; equivalenceIndex++) {
                    id equivalenceClass = [equivalenceClasses objectAtIndex: equivalenceIndex];
                    if ([[equivalenceClass objectAtIndex: 0] isEqual: topDownInfo]) {       //May not work
                        [equivalenceClass addObject:[NSValue valueWithBytes:&edge objCType:@encode(Edge)]];
                        foundEquivalence = true;
                        break;
                    }
                }
                if (!foundEquivalence) {
                    NSMutableArray* equivalenceClass = [[NSMutableArray alloc] initWithObjects:topDownInfo, [NSValue valueWithBytes:&edge objCType:@encode(Edge)], nil];
                    [equivalenceClasses addObject:equivalenceClass];
                }
            }
        }
    }
    return equivalenceClasses;
}
-(NSArray*) findEquivalenceClasses:(int)layerIndex
{
    NSMutableArray* equivalenceClasses = [[NSMutableArray alloc] init];
    Node* child;
    Node* parent;
    Node* *children;
    int nextLayerIndex = layerIndex+1;
    Node* *layer = layers[layerIndex];
    int variableIndex = [self variableIndexForLayer:nextLayerIndex];
    id parentState;
    for (int nodeIndex = 0; nodeIndex < layer_size[layerIndex]._val; nodeIndex++) {
        parent = layer[nodeIndex];
        parentState = [parent getState];
        children = [parent children];
        for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
            child = children[childIndex];
            if (child != NULL) {
                id tempState = [[_stateClass alloc] initState:parentState variableIndex:variableIndex];   //This feels like a bad way to do this. (probably cause it obviously is)
                [tempState setTopDownInfoFor:parentState plusEdge:childIndex];
                id topDownInfo = [tempState topDownInfo];
                bool foundEquivalence = false;
                
                Edge edge;
                edge.parent = parent;
                edge.value = childIndex;
                edge.child = child;
                for (int equivalenceIndex = 0; equivalenceIndex < [equivalenceClasses count]; equivalenceIndex++) {
                    id equivalenceClass = [equivalenceClasses objectAtIndex: equivalenceIndex];
                    if ([[equivalenceClass objectAtIndex: 0] isEqual: topDownInfo]) {       //May not work
                        [equivalenceClass addObject:[NSValue valueWithBytes:&edge objCType:@encode(Edge)]];
                        foundEquivalence = true;
                        break;
                    }
                }
                if (!foundEquivalence) {
                    NSMutableArray* equivalenceClass = [[NSMutableArray alloc] initWithObjects:topDownInfo, [NSValue valueWithBytes:&edge objCType:@encode(Edge)], nil];
                    [equivalenceClasses addObject:equivalenceClass];
                }
            }
        }
    }
    return equivalenceClasses;
}
-(void) buildOutMDD
{
    int variable, nextLayerIndex=0;
    bool parentLayerShrunk;
    bool* hitMaxWidth = malloc(_numVariables * sizeof(bool));
    hitMaxWidth[0] = false;
    int lastRowToSplit = (int)_numVariables -1;
    Node* *layer;
    Node* *nextLayer;
    Edge edge;
    NSMutableArray* *equivalenceClassesIsolated = malloc(_numVariables * sizeof(NSMutableArray*));
    for (int layerIndex = 0; layerIndex < _numVariables; layerIndex++) {
        equivalenceClassesIsolated[layerIndex] = [[NSMutableArray alloc] init];
    }
    for (int layerIndex = 0; layerIndex < _numVariables; layerIndex++) {
        nextLayerIndex++;
        layer = layers[layerIndex];
        variable = [self variableIndexForLayer:nextLayerIndex];
        hitMaxWidth[nextLayerIndex] = false;
        parentLayerShrunk = false;
        id firstTopDown;
        assignTRInt(&_layer_relaxed[nextLayerIndex],0,_trail);
        if (layerIndex != lastRowToSplit) {
            NSArray* equivalenceClasses = [self findEquivalenceClasses:layerIndex];
            firstTopDown = [[equivalenceClasses objectAtIndex: 0] objectAtIndex: 0];
            NSMutableArray* isolated = equivalenceClassesIsolated[layerIndex];
            for (int equivalenceClassIndex = 1; equivalenceClassIndex < [equivalenceClasses count]; equivalenceClassIndex++) {  //Don't need to separate the first one.
                if (layer_size[nextLayerIndex]._val == _relaxation_size) {
                    hitMaxWidth[nextLayerIndex] = true;
                    assignTRInt(&_layer_relaxed[nextLayerIndex],1,_trail);
                    break;
                }
                NSArray* equivalenceClass = [equivalenceClasses objectAtIndex:equivalenceClassIndex];
                id topDownInfo = [equivalenceClass objectAtIndex: 0];
                if (![isolated containsObject:topDownInfo]) {
                    id state = [[_stateClass alloc] initState:[layer[0] getState] variableIndex:variable];
                    [state setTopDownInfo:topDownInfo];
                    Node* newNode = [[Node alloc] initNode:_trail minChildIndex:min_domain_val maxChildIndex:max_domain_val value:variable state:state];
                    [self addNode:newNode toLayer:nextLayerIndex];
                    for (int edgeIndex = 1; edgeIndex < [equivalenceClass count]; edgeIndex++) {
                        [[equivalenceClass objectAtIndex: edgeIndex] getValue:&edge];
                        
                        [edge.parent addChild:newNode at:edge.value];
                        [newNode addParent:edge.parent];
                        [edge.child removeParentOnce:edge.parent];
                    }
                    
                    Node* *childChildren = [edge.child children];
                    for (int childIndex = [edge.child minChildIndex]; childIndex <= [edge.child maxChildIndex]; childIndex++) {
                        [newNode addChild:childChildren[childIndex] at:childIndex];
                        [childChildren[childIndex] addParent:newNode];
                        assignTRInt(&layer_variable_count[nextLayerIndex][childIndex],layer_variable_count[nextLayerIndex][childIndex]._val+1,_trail);
                    }
                    
                    [isolated addObject:topDownInfo];
                }
            }
        }
        nextLayer = layers[nextLayerIndex];
        for (int nodeIndex = 0; nodeIndex < layer_size[nextLayerIndex]._val; nodeIndex++) {
            [self calculateBottomUpInfoFor:nextLayer[nodeIndex] onLayer:nextLayerIndex];
        }
        if (hitMaxWidth[nextLayerIndex]) {
            assignTRInt(&node_relaxed[nextLayerIndex][0], 1, _trail);
            [self calculateTopDownInfoFor:nextLayer[0] onLayer:nextLayerIndex]; //If isn't exact, need to recalc the top-down for the relaxed node(s).
        } else {
            assignTRInt(&node_relaxed[nextLayerIndex][0], 0, _trail);
            [[nextLayer[0] getState] setTopDownInfo:firstTopDown];
        }
        for (int nodeIndex = 0; nodeIndex < layer_size[layerIndex]._val; nodeIndex++) {
            Node* parent = layer[nodeIndex];
            id parentState = [parent getState];
            Node* *children = [parent children];
            for (int value = [parent minChildIndex]; value <= [parent maxChildIndex]; value++) {
                Node* child = children[value];
                if (child != NULL) {
                    id childState = [child getState];
                    if ([parentState canDeleteChild:childState atEdgeValue:value]) {
                        [parent removeChildAt:value];
                        [child removeParentOnce:parent];
                        assignTRInt(&layer_variable_count[layerIndex][value], layer_variable_count[layerIndex][value]._val-1, _trail);
                        if (layer_variable_count[layerIndex][value]._val == 0) {
                            [_x[[self variableIndexForLayer:layerIndex]] remove: value];
                        }
                        
                        if ([child isNonVitalAndParentless]) {
                            [self removeParentlessNodeFromMDD:child fromLayer:(nextLayerIndex) trimmingVariables:true];
                        }
                        if ([parent isNonVitalAndChildless]) {
                            [self removeChildlessNodeFromMDD:parent fromLayer:layerIndex trimmingVariables:true];
                            nodeIndex--;
                            parentLayerShrunk = true;
                        }
                    }
                }
            }
        }
        if (parentLayerShrunk && hitMaxWidth[layerIndex]) {
            layerIndex-=2;
            nextLayerIndex-=2;
            //Parent layer was shrunk after having hit max width.  Try to split on that layer again.  May want to check up even higher?
        } else if (hitMaxWidth[nextLayerIndex] && layer_size[nextLayerIndex]._val < _relaxation_size) {
            layerIndex--;
            nextLayerIndex--;
            //Repeat layer - removing edges made it no longer at max width
        }
    }
}

-(void) buildNewLayerUnder:(int)layer
{
    [super buildNewLayerUnder:layer];
    assignTRInt(&node_relaxed[layer][0],1,_trail);
}

-(void) trimValueFromLayer:(ORInt)layer_index :(int)value topDown:(bool**)recalcTopDown bottomUp:(bool**)recalcBottomUp
{
    Node* *layer = layers[layer_index];
    Node* *child_layer = layers[layer_index+1];
    
    for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
        Node* node = layer[node_index];
        Node* childNode = [node children][value];
        
        if (childNode != NULL) {
            [node removeChildAt: value];
            if ([node findChildIndex:childNode] == -1) {
                [childNode removeParentValue:node];
            }/* else if (_objective != NULL) {
                if ([childNode hasLongestPathParent: node] && value == 1) { //I think the 1/0 here is hardcoded for one objective.  Need to fix.
                    [childNode removeLongestPathParent: node];
                }
                if ([childNode hasShortestPathParent: node] && value == 0) {
                    [childNode removeShortestPathParent: node];
                }
            }*/
            
            if ([childNode isNonVitalAndParentless]) {
                [self removeParentlessNodeFromMDD:childNode fromLayer:(layer_index+1) trimmingVariables:true topDown:recalcTopDown bottomUp:recalcBottomUp];
            } else {
                for (int child_index = 0; child_index < layer_size[layer_index+1]._val; child_index++) {
                    if (child_layer[child_index] == childNode) {
                        recalcTopDown[layer_index+1][child_index] = true;
                        break;
                    }
                }
            }
            if ([node isNonVitalAndChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layer_index trimmingVariables:true topDown:recalcTopDown bottomUp:recalcBottomUp];
                node_index--;
            } else {
                recalcBottomUp[layer_index][node_index] = true;
                /*if (_objective != NULL) {
                    [node updateReversePaths];
                }*/
            }
            
            /*if (node != NULL) {
                [self calculateBottomUpInfoFor: node onLayer: layer_index];
                
                if (layer_index > 0) {
                    Node* *parents = [node parents];
                    NSMutableSet* uniqueParents = [[NSMutableSet alloc] init];   //This is a bad way to do this.
                    for (int parentIndex = 0; parentIndex < [node numParents]; parentIndex++) {
                        [uniqueParents addObject:parents[parentIndex]];
                    }
                    for (Node* parent in uniqueParents) {
                        id parentState = [parent getState];
                        Node* *children = [parent children];
                        for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
                            Node* child = children[childIndex];
                            if (child == node) {
                                id childState = [child getState];
                                if ([parentState canDeleteChild:childState atEdgeValue:childIndex]) {
                                    [parent removeChildAt:childIndex];
                                    [child removeParentOnce:parent];
                                    assignTRInt(&layer_variable_count[layer_index-1][childIndex], layer_variable_count[layer_index-1][childIndex]._val-1, _trail);
                                    if (layer_variable_count[layer_index-1][childIndex]._val == 0) {
                                        [_x[[self variableIndexForLayer:layer_index-1]] remove: childIndex];
                                    }
                                    if ([child isNonVitalAndParentless]) {
                                        [self removeParentlessNodeFromMDD:child fromLayer:layer_index trimmingVariables:true];
                                    }
                                    if ([parent isNonVitalAndChildless]) {
                                        [self removeChildlessNodeFromMDD:parent fromLayer:layer_index-1 trimmingVariables:true];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (childNode != NULL) {
                [self calculateTopDownInfoFor: childNode onLayer: layer_index+1];
                
                if (layer_index < _numVariables-1) {
                    Node* parent = childNode;
                    id parentState = [parent getState];
                    Node* *children = [parent children];
                    for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
                        Node* child = children[childIndex];
                        if (child != NULL) {
                            id childState = [child getState];
                            if ([parentState canDeleteChild:childState atEdgeValue:childIndex]) {
                                [parent removeChildAt:childIndex];
                                [child removeParentOnce:parent];
                                assignTRInt(&layer_variable_count[layer_index+1][childIndex], layer_variable_count[layer_index+1][childIndex]._val-1, _trail);
                                if (layer_variable_count[layer_index+1][childIndex]._val == 0) {
                                    [_x[[self variableIndexForLayer:layer_index+1]] remove: childIndex];
                                }
                                if ([child isNonVitalAndParentless]) {
                                    [self removeParentlessNodeFromMDD:child fromLayer:layer_index+2 trimmingVariables:true];
                                }
                                if ([parent isNonVitalAndChildless]) {
                                    [self removeChildlessNodeFromMDD:parent fromLayer:layer_index+1 trimmingVariables:true];
                                }
                            }
                        }
                    }
                }
            }*/
        }
    }
    
    
    
    //Maximize stuff
}

-(void) recalcAndRemoveEdgesWithTopDown:(bool**)recalcTopDown andBottomUp:(bool**)recalcBottomUp
{
    for (int buildingLayer = 1; buildingLayer <= _numVariables; buildingLayer++) {
        for (int nodeIndex = 0; nodeIndex < layer_size[buildingLayer]._val; nodeIndex++) {
            if ([self calculateTopDownInfoFor:layers[buildingLayer][nodeIndex] onLayer:buildingLayer] && buildingLayer < _numVariables) {
                Node* node = layers[buildingLayer][nodeIndex];
                for (int childNodeIndex = 0; childNodeIndex < layer_size[buildingLayer+1]._val; childNodeIndex++) {
                    if ([node findChildIndex:layers[buildingLayer+1][childNodeIndex]] != -1) {
                        recalcTopDown[buildingLayer+1][childNodeIndex] = true;
                    }
                }
            }
        }
    }
    for (int buildingLayer = (int)_numVariables; buildingLayer >= 0; buildingLayer--) {
        for (int nodeIndex = 0; nodeIndex < layer_size[buildingLayer]._val; nodeIndex++) {
            if ([self calculateBottomUpInfoFor:layers[buildingLayer][nodeIndex] onLayer:buildingLayer] && buildingLayer > 0) {
                Node* node = layers[buildingLayer][nodeIndex];
                for (int parentNodeIndex = 0; parentNodeIndex < layer_size[buildingLayer-1]._val; parentNodeIndex++) {
                    if ([node hasParent:layers[buildingLayer-1][parentNodeIndex]]) {
                        recalcBottomUp[buildingLayer-1][parentNodeIndex] = true;
                    }
                }
            }
        }
    }
    
    bool** followupRecalcTopDown = malloc((_numVariables+1)*sizeof(bool*));
    bool** followupRecalcBottomUp = malloc((_numVariables+1)*sizeof(bool*));
    
    for (int layerIndex = 0; layerIndex < _numVariables+1; layerIndex++) {
        followupRecalcTopDown[layerIndex] = malloc(layer_size[layerIndex]._val * sizeof(bool));
        followupRecalcBottomUp[layerIndex] = malloc(layer_size[layerIndex]._val * sizeof(bool));
        for (int nodeIndex = 0; nodeIndex < layer_size[layerIndex]._val; nodeIndex++) {
            followupRecalcTopDown[layerIndex][nodeIndex] = false;
            followupRecalcBottomUp[layerIndex][nodeIndex] = false;
        }
    }
    
    bool followupRecalc = false;
    
    for (int buildingLayer = 0; buildingLayer < _numVariables; buildingLayer++) {
        Node* *buildingLayerNodes = layers[buildingLayer];
        for (int nodeIndex = 0; nodeIndex < layer_size[buildingLayer]._val; nodeIndex++) {
            Node* parent = buildingLayerNodes[nodeIndex];
            id parentState = [parent getState];
            Node* *children = [parent children];
            for (int value = [parent minChildIndex]; value <= [parent maxChildIndex]; value++) {
                Node* child = children[value];
                if (child != NULL) {
                    id childState = [child getState];
                    int childLayerIndex;
                    for (int childNodeIndex = 0; childNodeIndex < layer_size[buildingLayer+1]._val; childNodeIndex++) {
                        if (layers[buildingLayer+1][childNodeIndex] == child) {
                            childLayerIndex = childNodeIndex;
                            break;
                        }
                    }
                    if ((recalcTopDown[buildingLayer][nodeIndex] || recalcBottomUp[buildingLayer+1][childLayerIndex]) && [parentState canDeleteChild:childState atEdgeValue:value]) {
                        followupRecalc = true;
                        followupRecalcTopDown[buildingLayer+1][childLayerIndex] = true;
                        followupRecalcBottomUp[buildingLayer][nodeIndex] = true;
                        [parent removeChildAt:value];
                        [child removeParentOnce:parent];
                        assignTRInt(&layer_variable_count[buildingLayer][value], layer_variable_count[buildingLayer][value]._val-1, _trail);
                        if (layer_variable_count[buildingLayer][value]._val == 0) {
                            [_x[[self variableIndexForLayer:buildingLayer]] remove: value];
                        }
                        
                        if ([child isNonVitalAndParentless]) {
                            [self removeParentlessNodeFromMDD:child fromLayer:buildingLayer+1 trimmingVariables:true topDown:followupRecalcTopDown bottomUp:followupRecalcBottomUp];
                        }
                        if ([parent isNonVitalAndChildless]) {
                            [self removeChildlessNodeFromMDD:parent fromLayer:buildingLayer trimmingVariables:true topDown:followupRecalcTopDown bottomUp:followupRecalcBottomUp];
                            nodeIndex--;
                        }
                    }
                }
            }
        }
    }
    
    if (followupRecalc) {
        [self recalcAndRemoveEdgesWithTopDown:followupRecalcTopDown andBottomUp:followupRecalcBottomUp];
    }
}

-(void) trimValueFromLayer:(ORInt)layer_index :(int)value
{
    int *old_layer_size = malloc(_numVariables * sizeof(int));   //This is a bad way to do this
    for (int i = 0; i < _numVariables; i++) {
        old_layer_size[i] = layer_size[i]._val;
    }
    
    bool** recalcTopDown;
    bool** recalcBottomUp;
    
    recalcTopDown = malloc((_numVariables+1)*sizeof(bool*));
    recalcBottomUp = malloc((_numVariables+1)*sizeof(bool*));
    
    for (int layerIndex = 0; layerIndex < _numVariables+1; layerIndex++) {
        recalcTopDown[layerIndex] = malloc(layer_size[layerIndex]._val * sizeof(bool));
        recalcBottomUp[layerIndex] = malloc(layer_size[layerIndex]._val * sizeof(bool));
        for (int nodeIndex = 0; nodeIndex < layer_size[layerIndex]._val; nodeIndex++) {
            recalcTopDown[layerIndex][nodeIndex] = false;
            recalcBottomUp[layerIndex][nodeIndex] = false;
        }
    }
    
    //[super trimValueFromLayer:layer_index :value];
    [self trimValueFromLayer:layer_index :value topDown:recalcTopDown bottomUp:recalcBottomUp];
    [self recalcAndRemoveEdgesWithTopDown:recalcTopDown andBottomUp:recalcBottomUp];
    
    
    
    /*if (_relaxed) {
    id firstTopDown;
    bool* hitMaxWidth = malloc(_numVariables * sizeof(bool));
    hitMaxWidth[0] = false;
    Edge edge;
        
        int firstChangedLayer = (int)_numVariables;
        int lastChangedLayer = -1;
        
        
        for (int i = 0; i < _numVariables; i++) {
            if (old_layer_size[i] != layer_size[i]._val) {
                if (firstChangedLayer == _numVariables) {
                    firstChangedLayer = i;
                }
                lastChangedLayer = i;
            }
        }
    
    for (int buildingLayer = 1; buildingLayer < _numVariables; buildingLayer++) {
        if (_layer_relaxed[buildingLayer]._val && layer_size[buildingLayer]._val < _relaxation_size) {
            int variable = [self variableIndexForLayer:buildingLayer];
            hitMaxWidth[buildingLayer] = false;
            for (int node_index = 0; node_index < layer_size[buildingLayer]._val; node_index++) {
                if (node_relaxed[buildingLayer][node_index]._val) {
                    NSArray* equivalenceClasses = [self findEquivalenceClassesIntoNode:node_index onLayer:buildingLayer];
                    firstTopDown = [[equivalenceClasses objectAtIndex: 0] objectAtIndex: 0];
                    for (int equivalenceClassIndex = 1; equivalenceClassIndex < [equivalenceClasses count]; equivalenceClassIndex++) {  //Don't need to separate the first one.
                        if (layer_size[buildingLayer]._val == _relaxation_size) {
                            hitMaxWidth[buildingLayer] = true;
                            
                            break;
                        }
                        NSArray* equivalenceClass = [equivalenceClasses objectAtIndex:equivalenceClassIndex];
                        id topDownInfo = [equivalenceClass objectAtIndex: 0];
                        id state = [[_stateClass alloc] initState:[layers[buildingLayer-1][0] getState] variableIndex:variable];
                        [state setTopDownInfo:topDownInfo];
                        Node* newNode = [[Node alloc] initNode:_trail minChildIndex:min_domain_val maxChildIndex:max_domain_val value:variable state:state];
                        [self addNode:newNode toLayer:buildingLayer];
                        for (int edgeIndex = 1; edgeIndex < [equivalenceClass count]; edgeIndex++) {
                            [[equivalenceClass objectAtIndex: edgeIndex] getValue:&edge];
                            
                            [edge.parent addChild:newNode at:edge.value];
                            [newNode addParent:edge.parent];
                            [edge.child removeParentOnce:edge.parent];
                        }
                        
                        Node* *childChildren = [edge.child children];
                        for (int childIndex = [edge.child minChildIndex]; childIndex <= [edge.child maxChildIndex]; childIndex++) {
                            if (childChildren[childIndex] != NULL) {
                                [newNode addChild:childChildren[childIndex] at:childIndex];
                                [childChildren[childIndex] addParent:newNode];
                                assignTRInt(&layer_variable_count[buildingLayer][childIndex],layer_variable_count[buildingLayer][childIndex]._val+1,_trail);
                            }
                        }
                        [self calculateBottomUpInfoFor:newNode onLayer:buildingLayer];
                    }
                    [self calculateBottomUpInfoFor:layers[buildingLayer][node_index] onLayer:buildingLayer];
                    if (hitMaxWidth[buildingLayer]) {
                        assignTRInt(&node_relaxed[buildingLayer][node_index], 1, _trail);
                        [self calculateTopDownInfoFor:layers[buildingLayer][node_index] onLayer:buildingLayer]; //If isn't exact, need to recalc the top-down for the relaxed node
                        assignTRInt(&_layer_relaxed[buildingLayer],1,_trail);
                        break;
                    } else {
                        assignTRInt(&node_relaxed[buildingLayer][node_index], 0, _trail);
                        assignTRInt(&_layer_relaxed[buildingLayer],0,_trail);
                        [[layers[buildingLayer][node_index] getState] setTopDownInfo:firstTopDown];
                    }
                }
            }
            int temp = buildingLayer;
            bool layerChanged = true;
            for (buildingLayer = temp; (buildingLayer < _numVariables) && layerChanged; buildingLayer++) {
                layerChanged = false;
                for (int nodeIndex = 0; nodeIndex < layer_size[buildingLayer]._val; nodeIndex++) {
                    if ([self calculateTopDownInfoFor:layers[buildingLayer][nodeIndex] onLayer:buildingLayer]) {    //True if changes state
                        layerChanged = true;
                    }
                }
            }
            int topDownLastChange = buildingLayer-1;
            layerChanged = true;
            for (buildingLayer = (int)temp+1; buildingLayer >= 0 && layerChanged; buildingLayer--) {
                layerChanged = false;
                for (int nodeIndex = 0; nodeIndex < (layer_size[buildingLayer]._val); nodeIndex++) {
                    if ([self calculateBottomUpInfoFor:layers[buildingLayer][nodeIndex] onLayer:buildingLayer]) {
                        layerChanged = true;
                    }
                }
            }
            int bottomUpLastChange = buildingLayer+1;
            for (buildingLayer = min(0,bottomUpLastChange); buildingLayer < max(topDownLastChange,bottomUpLastChange); buildingLayer++) {
            Node* *buildingLayerNodes = layers[buildingLayer];
            for (int nodeIndex = 0; nodeIndex < layer_size[buildingLayer]._val; nodeIndex++) {
                Node* parent = buildingLayerNodes[nodeIndex];
                id parentState = [parent getState];
                Node* *children = [parent children];
                for (int value = [parent minChildIndex]; value <= [parent maxChildIndex]; value++) {
                    Node* child = children[value];
                    if (child != NULL) {
                        id childState = [child getState];
                        if ([parentState canDeleteChild:childState atEdgeValue:value]) {
                            [parent removeChildAt:value];
                            [child removeParentOnce:parent];
                            assignTRInt(&layer_variable_count[buildingLayer][value], layer_variable_count[buildingLayer][value]._val-1, _trail);
                            if (layer_variable_count[buildingLayer][value]._val == 0) {
                                [_x[[self variableIndexForLayer:buildingLayer]] remove: value];
                            }
                            
                            if ([child isNonVitalAndParentless]) {
                                [self removeParentlessNodeFromMDD:child fromLayer:buildingLayer+1 trimmingVariables:true];
                            }
                            if ([parent isNonVitalAndChildless]) {
                                [self removeChildlessNodeFromMDD:parent fromLayer:buildingLayer trimmingVariables:true];
                                nodeIndex--;
                            }
                        }
                    }
                }
            }
            }
            buildingLayer = temp;
            //if (layer_size[buildingLayer-1]._val < _relaxation_size && _layer_relaxed[buildingLayer-1]._val) {
            //    buildingLayer-=2;
            //    //Parent layer was shrunk after having hit max width.  Try to split on that layer again.  May want to check up even higher?
            //} else if (hitMaxWidth[buildingLayer] && layer_size[buildingLayer]._val < _relaxation_size) {
            //    buildingLayer--;
            //    //Repeat layer - removing edges made it no longer at max width
            //}
        }
    }
    int lowestChangedLayer = 0;
    bool layerChanged = true;
    for (int buildingLayer = firstChangedLayer; (buildingLayer <= _numVariables) && (true || buildingLayer <= lastChangedLayer || layerChanged); buildingLayer++) {
        layerChanged = false;
        for (int nodeIndex = 0; nodeIndex < layer_size[buildingLayer]._val; nodeIndex++) {
            if ([self calculateTopDownInfoFor:layers[buildingLayer][nodeIndex] onLayer:buildingLayer]) {    //True if changes state
                layerChanged = true;
                lowestChangedLayer = buildingLayer;
            }
        }
    }
    int highestChangedLayer = (int)_numVariables;
    layerChanged = true;
    for (int buildingLayer = (int)_numVariables-1; buildingLayer >= 0 && (true || buildingLayer >= firstChangedLayer || layerChanged); buildingLayer--) {
        layerChanged = false;
        for (int nodeIndex = 0; nodeIndex < (layer_size[buildingLayer]._val); nodeIndex++) {
            if ([self calculateBottomUpInfoFor:layers[buildingLayer][nodeIndex] onLayer:buildingLayer]) {
                layerChanged = true;
                highestChangedLayer = buildingLayer;
            }
        }
    }
    for (int buildingLayer = min(firstChangedLayer,highestChangedLayer); buildingLayer < max(lastChangedLayer,lowestChangedLayer); buildingLayer++) {
        Node* *buildingLayerNodes = layers[buildingLayer];
        for (int nodeIndex = 0; nodeIndex < layer_size[buildingLayer]._val; nodeIndex++) {
            Node* parent = buildingLayerNodes[nodeIndex];
            id parentState = [parent getState];
            Node* *children = [parent children];
            for (int value = [parent minChildIndex]; value <= [parent maxChildIndex]; value++) {
                Node* child = children[value];
                if (child != NULL) {
                    id childState = [child getState];
                    if ([parentState canDeleteChild:childState atEdgeValue:value]) {
                        [parent removeChildAt:value];
                        [child removeParentOnce:parent];
                        assignTRInt(&layer_variable_count[buildingLayer][value], layer_variable_count[buildingLayer][value]._val-1, _trail);
                        if (layer_variable_count[buildingLayer][value]._val == 0) {
                            [_x[[self variableIndexForLayer:buildingLayer]] remove: value];
                        }
                        
                        if ([child isNonVitalAndParentless]) {
                            [self removeParentlessNodeFromMDD:child fromLayer:buildingLayer+1 trimmingVariables:true];
                        }
                        if ([parent isNonVitalAndChildless]) {
                            [self removeChildlessNodeFromMDD:parent fromLayer:buildingLayer trimmingVariables:true];
                            nodeIndex--;
                        }
                    }
                }
            }
        }
    }
    }*/
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPMDDRelaxation:%02d %@>",_name,_x];
}
@end

@implementation CPMDDRelaxation
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced
{
    self = [super initCPMDD:engine over:x reduced:reduced];
    _relaxed = true;
    _relaxation_size = relaxationSize;
    _first_relaxed_layer = makeTRInt(_trail, INT_MAX);
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objective maximize:maximize];
    _relaxed = true;
    _relaxation_size = relaxationSize;
    _first_relaxed_layer = makeTRInt(_trail, INT_MAX);
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass
{
    self = [super initCPMDD:engine over:x stateClass:stateClass];
    _relaxed = true;
    _relaxation_size = relaxationSize;
    _first_relaxed_layer = makeTRInt(_trail, INT_MAX);
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass
{
    self = [super initCPMDD:engine over:x stateClass:stateClass];
    _relaxed = relaxed;
    _relaxation_size = relaxationSize;
    _first_relaxed_layer = makeTRInt(_trail, INT_MAX);
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objective maximize:maximize stateClass:stateClass];
    _relaxed = true;
    _relaxation_size = relaxationSize;
    _first_relaxed_layer = makeTRInt(_trail, INT_MAX);
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objective maximize:maximize stateClass:stateClass];
    _relaxed = relaxed;
    _relaxation_size = relaxationSize;
    _first_relaxed_layer = makeTRInt(_trail, INT_MAX);
    return self;
}
/* A different attempt at this method where instead of building a new layer and shrinking it, it splits a layer out from a single node
  
-(void) post
{
    [self createRootAndSink];
    
    int last_variable = (int)_numVariables-1;
    
    for (int layer = 0; layer < _numVariables; layer++) {
        if (layer != last_variable) {
            int next_variable = [self pickVariableBelowLayer:layer];
            
            _variable_to_layer[next_variable] = layer+1;
            _layer_to_variable[layer+1] = next_variable;
            _variableUsed[next_variable] = true;
        }
        [self buildNewLayerUnder:layer];    //Make width 1
        
        if (layer != last_variable) {
            [self splitNodes: layer+1];    //Split
        }
    }
    [self addPropagationsAndTrimValues];
    
    if (_objective != nil) {
        for (int layer = (int)_numVariables; layer >= 0; layer--) {
            for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
                [layers[layer][node_index] updateReversePaths];
            }
        }
    }
    return;
}
-(void) createChildrenForNode:(Node *)parentNode
{
    int parentValue = [parentNode value];
    int parentLayer = [self layerIndexForVariable:parentValue];
    for (int edgeValue = [parentNode minChildIndex]; edgeValue <= [parentNode maxChildIndex]; edgeValue++) {
        if ([_x[parentValue] member: edgeValue] && [parentNode canChooseValue: edgeValue]) {
            Node* childNode;
            
            if (parentLayer != _numVariables-1 && layer_size[parentLayer+1]._val == 0) {    //Only create a single child for each layer
                id state = [self generateStateFromParent:parentNode withValue:edgeValue];
                childNode = [[Node alloc] initNode: _trail
                                     minChildIndex:min_domain_val
                                     maxChildIndex:max_domain_val
                                             value:[self variableIndexForLayer:parentLayer + 1]
                                             state:state];
                [self addNode:childNode toLayer:parentLayer+1];
            } else {
                childNode = layers[_numVariables][0];
            }
            
            [parentNode addChild:childNode at:edgeValue];
            [childNode addParent:parentNode];
            assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
        }
    }
}
-(void) splitNodes:(int)layer
{
    TRId *parent_layer = layers[layer-1];
    int variable_index = [self variableIndexForLayer:layer];
    for (int parent_index = 0; parent_index < layer_size[layer-1]._val; parent_index++) {
        Node* parent = parent_layer[parent_index];
        Node* *children = [parent children];
        for (int child_index = [parent minChildIndex]; child_index < [parent maxChildIndex]; child_index++) {
            Node* child = children[child_index];
            if (child != NULL) {
                id state = [self generateStateFromParent:parent withValue:child_index];
                Node* new_child = [[Node alloc] initNode: _trail
                                     minChildIndex:min_domain_val
                                     maxChildIndex:max_domain_val
                                             value:variable_index
                                             state:state];
                [self addNode:new_child toLayer:layer];
                [parent addChild:new_child at:child_index];
                [new_child addParent: parent];
                [child removeParentOnce:parent];
            }
        }
    }
}*/
-(void) addPropagationsAndTrimValues
{
    [super addPropagationsAndTrimValues];
    
    for(ORInt layer = 0; layer < _numVariables; layer++) {
        int variableIndex = [self variableIndexForLayer:layer];
        [_x[variableIndex] whenBindDo:^() {
            if (_first_relaxed_layer._val == layer+1) {
                if ([layers[_first_relaxed_layer._val][0] isRelaxed]) {
                    assignTRInt(&_first_relaxed_layer, INT_MAX, _trail);
                    [self rebuildFromLayer: layer];
                } else {
                    assignTRInt(&_first_relaxed_layer, _first_relaxed_layer._val +1, _trail);
                }
            }
            //if (_first_relaxed_layer._val == layer+1) {
            //    assignTRInt(&_first_relaxed_layer, INT_MAX, _trail);
            //    [self rebuildFromLayer: layer];
            //} else if (_first_relaxed_layer._val < layer+1) {
            //    int startingLayer = _first_relaxed_layer._val-1;
            //    assignTRInt(&_first_relaxed_layer, INT_MAX, _trail);
            //    [self rebuildFromLayer: startingLayer];
            //}
        } onBehalf:self];
    }
}
-(void) rebuildFromLayer:(int)startingLayer
{
    //for (int variableIndex = [_x low]; variableIndex <= [_x up]; variableIndex++) {
    //    _variableUsed[variableIndex] = false;
    //}
    //for (int layer = 0; layer <= startingLayer; layer++) {
    //    _variableUsed[[self variableIndexForLayer:layer]] = true;
    //}
    //for (int variable = min_domain_val; variable <= max_domain_val; variable++) {
    //    assignTRInt(&layer_variable_count[startingLayer][variable], 0, _trail);
    //}
    //assignTRInt(&layer_size[startingLayer+1], 0, _trail);
    //[self buildNewLayerUnder:startingLayer];
  
    for (int layer = startingLayer+1; layer < _numVariables; layer++) {
        assignTRInt(&layer_size[layer], 0, _trail);
        for (int variable = min_domain_val; variable <= max_domain_val; variable++) {
            assignTRInt(&layer_variable_count[layer][variable], 0, _trail);
        }
    }
    
    for (int layer = startingLayer; layer < _numVariables; layer++) {
        if (layer_size[layer]._val == 0) {
            failNow();
        }
        if (_reduced) {
            [self reduceLayer: layer];
        }
        [self cleanLayer: layer];
        
        [self buildNewLayerUnder:layer];
    }
    for(ORInt layer = startingLayer+1; layer < _numVariables; layer++) {
        [self trimValuesFromLayer:layer];
    }
    
    if (_objective != nil) {
        for (int layer = (int)_numVariables; layer >= 0; layer--) {
            for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
                [layers[layer][node_index] updateReversePaths];
            }
        }
    }
    return;
}
-(void) cleanLayer:(int)layer
{
    if (_relaxed) {
        if (layer_size[layer]._val > _relaxation_size && layer < _first_relaxed_layer._val) {
            assignTRInt(&_first_relaxed_layer, layer, _trail);
        }
        while (layer_size[layer]._val > _relaxation_size) {
            [self mergeTwoNodesOnLayer: layer];
        }
    }
}
-(void) mergeTwoNodesOnLayer:(int)layer
{
    Node* first_node;
    Node* second_node;
    //Heuristic 1 - First two nodes
    first_node = layers[layer][0];
    second_node = layers[layer][1];
    
    //Heuristic 2 - Last two nodes
    //first_node = layers[layer][layer_size[layer]._val-2];
    //second_node = layers[layer][layer_size[layer]._val-1];
    
    //[self findNodesToMerge:layer first:&first_node second:&second_node];
    
    [first_node mergeWith: second_node];
    [self removeNode:second_node];
    [first_node setRelaxed:true];
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
                    if (smallest_state_differential == 1) {
                        break;
                    }
                }
            }
            if (smallest_state_differential == 1){
                break;
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



@implementation CPCustomAltMDD
-(id) initCPCustomAltMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize stateClass:(Class)stateClass
{
    self = [super initCPAltMDDRelaxation:engine over:x relaxed:relaxed relaxationSize:relaxationSize stateClass:stateClass];
    _priority = HIGHEST_PRIO;
    return self;
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPCustomAltMDD:%02d %@>",_name,_x];
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
