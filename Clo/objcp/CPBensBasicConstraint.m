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

//I think I'm missing some assignTRIds

@implementation CPFiveGreater

-(id) initCPFiveGreater: (id<CPIntVar>) x and: (id<CPIntVar>) y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x[0];
   _y = y[0];
   return self;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(void) post
{
   if (![_x bound] || ![_y bound]) {
       [_x whenChangeBoundsPropagate: self];
       [_y whenChangeBoundsPropagate: self];
   }
   [self propagate];
}

-(void) propagate
{
    if (bound(_x))
       bindDom(_y,minDom(_x) - 5);
    else if (bound(_y))
       bindDom(_x,minDom(_y) + 5);
    else {
       updateMinAndMaxOfDom(_x, minDom(_y)+5, maxDom(_y)+5);
       updateMinAndMaxOfDom(_y, minDom(_x)-5, maxDom(_x)-5);
    }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFiveGreater:%02d %@ == %@ + 5>",_name,_x,_y];
}
@end

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
    _numParents = makeTRInt(_trail, 0);
    _value = -1;
    _isSink = false;
    _isSource = false;
    
    _weights = NULL;
    _longestPath = makeTRInt(_trail, -32768);
    _longestPathParents = malloc((maxParents) * sizeof(Node*));
    _numLongestPathParents = makeTRInt(_trail, 0);
    _shortestPath = makeTRInt(_trail, 32767);
    _shortestPathParents = malloc((maxParents) * sizeof(Node*));
    _numShortestPathParents = makeTRInt(_trail, 0);
    
    return self;
}
-(id) initNode: (id<ORTrail>) trail maxParents:(int)maxParents minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state weights:(int*)weights
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
    _numParents = makeTRInt(_trail, 0);
    _value = value;
    _isSink = false;
    _isSource = false;
    _weights = weights;
    _longestPath = makeTRInt(_trail, -32768);
    _longestPathParents = malloc((maxParents) * sizeof(Node*));
    _numLongestPathParents = makeTRInt(_trail, 0);
    _shortestPath = makeTRInt(_trail, 32767);
    _shortestPathParents = malloc((maxParents) * sizeof(Node*));
    _numShortestPathParents = makeTRInt(_trail, 0);
    
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
-(int) getWeightFor: (int)index {
    return _weights[index];
}
-(int) getNodeObjectiveValue: (int)value {
    return _childEdgeWeights[value]._val;
}
-(void) addChild:(Node*)child at:(int)index {
    _children[index] = child;
    [self setNumChildren:_numChildren._val+1];
    assignTRInt(&_numChildren, _numChildren._val, _trail);
    assignTRInt(&_childEdgeWeights[index], [self getWeightFor: index], _trail);
}
-(void) removeChildAt: (int) index {
    assignTRId(&_children[index], NULL, _trail);
    assignTRInt(&_numChildren, _numChildren._val -1, _trail);
    assignTRInt(&_childEdgeWeights[index], 0, _trail);
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
-(Node**) parents {
    return _parents;
}
-(int) numParents {
    return _numParents._val;
}
-(void) addParent: (Node*) parent {
    _parents[_numParents._val] = parent;
    assignTRInt(&_numParents,_numParents._val+1,_trail);
    [self updateBoundsWithParent: parent];
}
-(void) updateBoundsWithParent: (Node*) parent {
    int parentLongestPath = [parent longestPath];
    int parentShortestPath = [parent shortestPath];
    
    for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
        if ([parent children][childIndex] == self) {
            int candidateLongestPath = parentLongestPath + [parent getWeightFor:childIndex];
            int candidateShortestPath = parentShortestPath + [parent getWeightFor:childIndex];
            
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
    
    for (int parentIndex = 0; parentIndex < _numLongestPathParents._val; parentIndex++) {
        Node* parent = _longestPathParents[parentIndex];
        int parentLongestPath = [parent longestPath];
        
        for (int childIndex = [parent minChildIndex]; childIndex <= [parent maxChildIndex]; childIndex++) {
            if ([parent children][childIndex] == self) {
                int candidateLongestPath = parentLongestPath + [parent getWeightFor:childIndex];
                
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
    
    if (!_isSink) {
        for (int childIndex = _minChildIndex; childIndex <= _maxChildIndex; childIndex++) {
            Node* child = _children[childIndex];
            
            if (child != NULL && [child hasLongestPathParent: self]) {
                [child removeLongestPathParent: self];
            }
        }
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
                int candidateShortestPath = parentShortestPath + [parent getWeightFor:childIndex];
                
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
        if (_parents[parentIndex] == parent) {
            assignTRInt(&_numParents,_numParents._val-1,_trail);
           _parents[parentIndex] = _parents[_numParents._val];
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
-(void) takeParentsFrom:(Node*)other {
    for (int parentIndex = 0; parentIndex < [other numParents]; parentIndex++) {
        Node* parent = [other parents][parentIndex];
        
        int child_index = [parent findChildIndex: other];
        while(child_index != -1) {
            [parent addChild: self at:child_index];
            
            child_index = [parent findChildIndex: other];
        }
        [self addParent: parent];
    }
}
-(bool) canChooseValue:(int)value {
    return [_state canChooseValue: value];
}
-(void) mergeStateWith:(Node*)other {
    [_state mergeStateWith: [other getState]];
}
@end

@implementation GeneralState
-(id) initGeneralState {
    _state = [[NSMutableArray alloc] init];
    return self;
}
-(id) initGeneralState:(GeneralState*)parentNodeState withValue:(int)edgeValue {
    _state = [[NSMutableArray alloc] initWithArray:[parentNodeState state]];
    NSMutableSet* newStateValue = [[NSMutableSet alloc] init];
    [newStateValue addObject:[NSNumber numberWithInt:edgeValue]];
    [_state addObject: newStateValue];
    return self;
}
-(id) state {
    return _state;
}
-(bool) canChooseValue:(int)value {
    //constraint-specific here
    return true;
}
-(void) mergeStateWith:(GeneralState *)other {
    for (int stateValue = 0; stateValue < [_state count]; stateValue++) {
        for (int otherValue = 0; otherValue < [[other state][stateValue] count]; otherValue++) {
            [_state[stateValue] addObject: [NSNumber numberWithInt:(int)[other state][stateValue][otherValue]]];
        }
    }
}
-(bool) stateAllows:(int)variable {
    return true;
}
-(BOOL) isEqual:(GeneralState*)object {
    return [_state isEqual:[object state]];
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
-(BOOL) isEqual:(AllDifferentState*)object {
    return [_state isEqual:[object state]];
}
@end

@implementation MISPState
-(id) initMISPState:(int)variableIndex :(int)minValue :(int)maxValue adjacencies:(bool**)adjacencyMatrix {
    _variableIndex = variableIndex;
    _minValue = minValue;
    _maxValue = maxValue;
    _adjacencyMatrix = adjacencyMatrix;
    _state = malloc((_maxValue - _minValue +1) * sizeof(bool));
    _state -= _minValue;
    
    for (int stateValue = _minValue; stateValue <= _maxValue; stateValue++) {
        _state[stateValue] = true;
    }
    
    return self;
}
-(id) initMISPState:(int)minValue :(int)maxValue parentNodeState:(MISPState*)parentNodeState withVariableIndex:(int)variableIndex withValue:(int)edgeValue adjacencies:(bool**)adjacencyMatrix{
    _variableIndex = variableIndex;
    _minValue = minValue;
    _maxValue = maxValue;
    _adjacencyMatrix = adjacencyMatrix;
    _state = malloc((_maxValue - _minValue +1) * sizeof(bool));
    _state -= _minValue;
    
    bool* parentState = [parentNodeState state];
    int parentVariable = [parentNodeState variableIndex];
    bool* parentAdjacencies = adjacencyMatrix[parentVariable];
    
    if (edgeValue == 1) {
        for (int stateIndex = _minValue; stateIndex <= _maxValue; stateIndex++) {
            _state[stateIndex] = !parentAdjacencies[stateIndex] && parentState[stateIndex];
        }
    }
    else {
        for (int stateIndex = _minValue; stateIndex <= _maxValue; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex];
        }
    }
    _state[parentVariable] = false;

    return self;
}
-(bool*) state { return _state; }
-(int) variableIndex { return _variableIndex; }
-(bool) canChooseValue:(int)value {
    if (value == 0) return true;
    return _state[_variableIndex];
}
-(void) mergeStateWith:(MISPState *)other {
    for (int value = _minValue; value <= _maxValue; value++) {
        bool combinedStateValue = [self canChooseValue: value] || [other canChooseValue:value];
        _state[value] = combinedStateValue;
    }
}
-(bool) stateAllows:(int)variable {
    if (!_state[variable]) {
        return false;
    }
    //if (value == 0) {
    //    return true;
    //}
    return !_adjacencyMatrix[_variableIndex][variable];
}
-(BOOL) isEqual:(MISPState*)object {
    bool* otherState = [object state];
    for (int stateIndex = _minValue; stateIndex <= _maxValue; stateIndex++) {
        if (_state[stateIndex] != otherState[stateIndex]) {
            return false;
        }
    }
    return true;
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
    
    _max_nodes_per_layer = 200;
    //for (int variable = [_x low]; variable <= [_x up]; variable++) {
    //    _max_nodes_per_layer *= [_x[variable] domsize];
    //}
    
    layer_size = malloc(([_x count]+1) * sizeof(TRInt));
    for (int layer = 0; layer <= [_x count]; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
    }
    
    min_domain_val = [_x[[_x low]] min];
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
        layers[layer] = malloc(_max_nodes_per_layer * sizeof(Node*));
    }
    
    _layer_to_variable = malloc(([_x count]+1) * sizeof(int));
    _variable_to_layer = malloc(([_x count]+1) * sizeof(int));
    
    _variable_to_layer -= [_x low];
    
    _variableUsed = malloc([_x count] * sizeof(bool));
    _variableUsed -= [_x low];
    for (int variableIndex = [_x low]; variableIndex <= [_x up]; variableIndex++) {
        _variableUsed[variableIndex] = false;
    }
    
    
    totalWC = 0;
    totalCPU = 0;
    return self;
}
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize
{
    self = [self initCPMDD:engine over:x reduced:reduced];
    _objective = objective;
    _maximize = maximize;
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
        [self cleanLayer: layer];       //~ 50 CPU
        
        int next_variable = [self pickVariableBelowLayer:layer];    //~ 65 CPU
        
        _variable_to_layer[next_variable] = layer+1;
        _layer_to_variable[layer+1] = next_variable;
        _variableUsed[next_variable] = true;
        
        [self buildNewLayerUnder:layer];    //~ 135 CPU
    }
    
    printf("CPU: %lld\n",totalCPU);
    printf("WC: %lld\n",totalWC);
    //[self printGraph];
    [self addPropagationsAndTrimValues];
    
    //[self printGraph];
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
                GeneralState* state = [node getState];
    
                if ([state stateAllows: variable_index]) {
                    variableCount[variable_index]++;
                }
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
-(int*) getWeightsForLayer:(int)layer
{
    int* weights = malloc((max_domain_val - min_domain_val + 1) * sizeof(int));
    weights -= min_domain_val;
    for (int index = min_domain_val; index <= max_domain_val; index++) {
        weights[index] = 0;
    }
    
    return weights;
}
-(void) createRootAndSink
{
    Node *sink = [[Node alloc] initNode: _trail maxParents:(_max_nodes_per_layer * (max_domain_val - min_domain_val +1))];
    [sink setIsSink: true];
    [self addNode: sink toLayer:([_x count])];
    
    id state = [self generateRootState: [_x low]];
    _variable_to_layer[[_x low]] = 0;
    _layer_to_variable[0] = [_x low];
    
    Node* root =[[Node alloc] initNode: _trail
                            maxParents:(_max_nodes_per_layer * (max_domain_val - min_domain_val +1))
                         minChildIndex:min_domain_val
                         maxChildIndex:max_domain_val
                                 value:[_x low]
                                 state:state
                               weights:[self getWeightsForLayer:0]];
    [root setIsSource:true];
    [self addNode:root toLayer:0];
    _variableUsed[[_x low]] = true;
}
-(void) reduceLayer:(int)layer {
    NSMutableDictionary* foundStates = [[NSMutableDictionary alloc] init];
    
    for (int nodeIndex = 0; nodeIndex < layer_size[layer]._val; nodeIndex++) {
        Node* node= layers[layer][nodeIndex];
        bool* state = [[node getState] state];

        NSString* stateKey = [[NSString alloc] initWithString:@""];
        for (int stateVal = [_x low]; stateVal <= [_x up]; stateVal++) {
            stateKey = [stateKey stringByAppendingString: state[stateVal] ? @"1" : @"0"];
        }
        
        if ([foundStates objectForKey:stateKey]) {     //BIG SLOWDOWN DUE TO NSMUTABLEDICTIONARY
            [foundStates[stateKey] takeParentsFrom:node];
            [self removeChildlessNodeFromMDD:node trimmingVariables:false];
        
            nodeIndex--;
        } else {
            [foundStates setObject:node forKey:stateKey];
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
        [self createChildrenForNode:parentNode];    //~140 CPU
    }
}
-(void) createChildrenForNode:(Node*)parentNode
{
    int parentValue = [parentNode value];
    int parentLayer = [self layerIndexForVariable:parentValue];
    for (int edgeValue = [parentNode minChildIndex]; edgeValue <= [parentNode maxChildIndex]; edgeValue++) {
        if ([parentNode canChooseValue: edgeValue]) {
            Node* childNode;
            
            id state = [self generateStateFromParent:parentNode withValue:edgeValue];   //~ 60 CPU
            if (parentLayer != [_x count]-1) {
                childNode = [[Node alloc] initNode: _trail
                                        maxParents:(_max_nodes_per_layer * (max_domain_val - min_domain_val +1))
                                     minChildIndex:min_domain_val
                                     maxChildIndex:max_domain_val
                                             value:[self variableIndexForLayer:parentLayer + 1]
                                             state:state
                                           weights:[self getWeightsForLayer:parentLayer+1]];
                
                [self addNode:childNode toLayer:parentLayer+1];
            } else {
                childNode = layers[[_x count]][0];
            }
            
            [parentNode addChild:childNode at:edgeValue];
            [childNode addParent:parentNode];   //~ 60 CPU
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
    return NULL;
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    return NULL;
}
-(void) addNode:(Node*)node toLayer:(int)layer_index
{
    layers[layer_index][layer_size[layer_index]._val] = node;
    assignTRInt(&layer_size[layer_index], layer_size[layer_index]._val+1, _trail);
}
-(void) removeNode: (Node*) node {
    int node_layer = [self layerIndexForVariable:node.value];
    Node* *layer = layers[node_layer];
    
    for (int node_index = 0; node_index < layer_size[node_layer]._val; node_index++) {
        if (layer[node_index] != NULL && layer[node_index] == node) {
            int finalNodeIndex = layer_size[node_layer]._val-1;
            assignTRId(&layer[node_index], layer[finalNodeIndex], _trail);
            assignTRId(&layer[finalNodeIndex], NULL, _trail);
            assignTRInt(&layer_size[node_layer], finalNodeIndex,_trail);
        }
    }
}
-(void) removeChildlessNodeFromMDD:(Node*)node trimmingVariables:(bool)trimming
{
    int parentLayer;
    for (int parentIndex = 0; parentIndex < [node numParents]; parentIndex++) {
        Node* parent = [node parents][parentIndex];
        
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
    relaxed_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize
{
    self = [super initCPMDD:engine over:x reduced:reduced objective:objective maximize:maximize];
    relaxed_size = relaxationSize;
    return self;
}
-(void) cleanLayer:(int)layer
{
    while (layer_size[layer]._val > relaxed_size) {
        [self mergeTwoNodesOnLayer: layer];
    }
}
-(void) mergeTwoNodesOnLayer:(int)layer
{
    Node* first_node;
    Node* second_node;
    [self findNodesToMerge:layer first:&first_node second:&second_node];    //~ 15 CPU
    
    [first_node mergeWith: second_node];    //~ 30 CPU
    [self removeChildlessNodeFromMDD:second_node trimmingVariables:false];
}

//minLP
-(void) findNodesToMerge:(int)layer first:(Node**)first second:(Node**)second
{
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
-(int*) getWeightsForLayer:(int)layer
{
    int* weights = malloc(2 * sizeof(int));
    weights[0] = 0;
    weights[1] = (int)[_weights[[self variableIndexForLayer:layer]] longValue];
    
    return weights;
}
-(id) generateRootState:(int)variableValue
{
    return [[MISPState alloc] initMISPState:variableValue :[_x low] :[_x up] adjacencies:_adjacencyMatrix];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    MISPState* parentState = [parentNode getState];
    int parentLayer = [self layerIndexForVariable: [parentState variableIndex]];
    int variableIndex = [self variableIndexForLayer:parentLayer+1];
    return [[MISPState alloc] initMISPState:[_x low] :[_x up] parentNodeState:[parentNode getState] withVariableIndex:variableIndex withValue:value adjacencies:_adjacencyMatrix];

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
-(int*) getWeightsForLayer:(int)layer
{
    int* weights = malloc(2 * sizeof(int));
    weights[0] = 0;
    weights[1] = (int)[_weights[[self variableIndexForLayer:layer]] longValue];
    
    return weights;
}
-(id) generateRootState:(int)variableValue
{
    return [[MISPState alloc] initMISPState:variableValue :[_x low] :[_x up] adjacencies:_adjacencyMatrix];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    MISPState* parentState = [parentNode getState];
    int parentLayer = [self layerIndexForVariable: [parentState variableIndex]];
    int variableIndex = [self variableIndexForLayer:parentLayer+1];
    return [[MISPState alloc] initMISPState:[_x low] :[_x up] parentNodeState:[parentNode getState] withVariableIndex:variableIndex withValue:value adjacencies:_adjacencyMatrix];
    
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPExactMDDMISP:%02d %@>",_name,_x];
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
-(int*) getWeightsForLayer:(int)layer
{
    int* weights = malloc(2 * sizeof(int));
    weights[0] = 0;
    weights[1] = (int)[_weights[[self variableIndexForLayer:layer]] longValue];
    
    return weights;
}
-(id) generateRootState:(int)variableValue
{
    return [[MISPState alloc] initMISPState:variableValue :[_x low] :[_x up] adjacencies:_adjacencyMatrix];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    MISPState* parentState = [parentNode getState];
    int parentLayer = [self layerIndexForVariable: [parentState variableIndex]];
    int variableIndex = [self variableIndexForLayer:parentLayer+1];
    
    MISPState* state = [[MISPState alloc] initMISPState:[_x low] :[_x up] parentNodeState:[parentNode getState] withVariableIndex:variableIndex withValue:value adjacencies:_adjacencyMatrix];  //~ 50 CPU
    return state;
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPExactMDDMISP:%02d %@>",_name,_x];
}
@end
