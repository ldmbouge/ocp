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
-(id) initNode: (id<ORTrail>) trail
{
    [super init];
    _trail = trail;
    _childEdgeWeights = NULL;
    _children = NULL;
    _numChildren = makeTRInt(_trail, 0);
    _minChildIndex = 0;
    _maxChildIndex = 0;
    _parents = [[NSMutableSet alloc] init];
    _value = -1;
    _isSink = false;
    _isSource = false;
    
    return self;
}
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state
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
    _parents = [[NSMutableSet alloc] init];
    _parents = [NSMutableSet set];
    _isSink = false;
    _isSource = false;
    
    return self;
}
-(void) dealloc {
//    [_parents release];
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
}
-(void) setNumChildren: (int) numChildren {
    assignTRInt(&_numChildren, numChildren, _trail);
}

-(int) value {
    return _value;
}
-(Node**) children {
    return _children;
}
-(int) getWeightFor: (int)index {
    return 0;
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

-(NSMutableSet*) parents {
    return _parents;
}
-(void) addParent: (Node*) parent {
    [_parents addObject: parent];
}
-(void) removeParentValue: (Node*) parent {
    NSMutableSet* newParents = [_parents mutableCopy];
    [newParents removeObject: parent];
    
    assignTRId(&_parents, newParents, _trail);
}

-(bool) isVital {
    return _isSource || _isSink;
}

-(bool) isNonVitalAndChildless {
    return !(_numChildren._val || [self isVital]);
}

-(bool) isNonVitalAndParentless {
    return !([_parents count] || [self isVital]);
}

-(void) mergeWith:(Node*)other {
    [self mergeStateWith: other];
    [self takeParentsFrom: other];
}
-(void) takeParentsFrom:(Node*)other {
    for (Node* parent in [other parents]) {
        [self addParent: parent];
        int child_index = [parent findChildIndex: other];
        while(child_index != -1) {
            [parent addChild: self at:child_index];
            
            child_index = [parent findChildIndex: other];
        }
        [other removeParentValue:parent];
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
-(BOOL) isEqual:(AllDifferentState*)object {
    return [_state isEqual:[object state]];
}
@end

@implementation MISPState
-(id) initMISPState:(int)layerValue :(int)minValue :(int)maxValue {
    _state = [[NSMutableArray alloc] init];
    _layerValue = layerValue;
    _minValue = minValue;
    _maxValue = maxValue;
    
    for (int stateValue = _minValue; stateValue <= _maxValue; stateValue++) {
        [_state addObject:@YES];
    }
    
    return self;
}
-(id) initMISPState:(int)minValue :(int)maxValue parentNodeState:(MISPState*)parentNodeState withValue:(int)edgeValue adjacencies:(bool**)adjacencyMatrix{
    _state = [[NSMutableArray alloc] init];
    
    int parentLayerValue = [parentNodeState layerValue];
    _layerValue = parentLayerValue+1;
    _minValue = minValue;
    _maxValue = maxValue;
    
    for (int stateIndex = _minValue; stateIndex <= _maxValue; stateIndex++) {
        if (stateIndex < _layerValue) { //If already chose a value for that layer, set it to NO, can't be chosen (this helps reduction work better)
            [_state addObject: @NO];
        } else {
            [_state addObject: [parentNodeState state][stateIndex - _minValue]];
        }
    }
    if (edgeValue == 1) {
        for (int index = _minValue; index <= _maxValue; index++) {
            if (adjacencyMatrix[parentLayerValue][index]) {
                [_state replaceObjectAtIndex:(index - _minValue) withObject:@NO];
            }
        }
    }

    return self;
}
-(id) state { return _state; }
-(int) layerValue { return _layerValue; }
-(bool) canChooseValue:(int)value {
    if (value == 0) return true;
    return [_state[_layerValue - _minValue] boolValue];
}
-(void) mergeStateWith:(MISPState *)other {
    for (int value = _minValue; value <= _maxValue; value++) {
        bool combinedStateValue = [self canChooseValue: value] || [other canChooseValue:value];
        [_state setObject: [NSNumber numberWithBool: combinedStateValue] atIndexedSubscript:value];
    }
}
-(BOOL) isEqual:(MISPState*)object {
    return [_state isEqual:[object state]];
}
@end


@implementation CPMDD
-(id) initCPMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced
{
    self = [super initCPCoreConstraint: engine];
    _trail = [engine trail];
    _x = x;
    _reduced = reduced;
    
    _max_nodes_per_layer = 1;
    for (int variable = [_x low]; variable <= [_x up]; variable++) {
        _max_nodes_per_layer *= [_x[variable] domsize];
    }
    
    layer_size = malloc(([_x count]+1) * sizeof(TRInt));
    for (int layer = 0; layer <= [_x count]; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
    }
    layer_size -= [_x low];
    
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
    layer_variable_count -= [_x low];

    layers = malloc(([_x count]+1) * sizeof(Node**));
    for (int layer = 0; layer <= [_x count]; layer++) {
        layers[layer] = malloc(_max_nodes_per_layer * sizeof(Node*));
    }
    layers -= [_x low];
    
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
    
    for (int layer = [_x low]; layer <= [_x up]; layer++) {
        if (_reduced) {
            [self reduceLayer: layer];
        }
        [self cleanLayer: layer];
        
        [self buildNewLayerUnder:layer];
    }
    
    [self addPropagationsAndTrimValues];
    
    [self printGraph];
    return;
}
-(void) createRootAndSink
{
    Node *sink = [[Node alloc] initNode: _trail];
    [sink setIsSink: true];
    [self addNode: sink toLayer:([_x up] +1)];
    
    id state = [self generateRootState: [_x low]];
    
    Node* root =[[Node alloc] initNode: _trail
                         minChildIndex:min_domain_val
                         maxChildIndex:max_domain_val
                                 value:[_x low]
                                 state:state];
    [root setIsSource:true];
    [self addNode:root toLayer:[_x low]];
}
-(void) reduceLayer:(int)layer {
    NSMutableDictionary* foundStates = [[NSMutableDictionary alloc] init];
    
    for (int nodeIndex = 0; nodeIndex < layer_size[layer]._val; nodeIndex++) {
        Node* node= layers[layer][nodeIndex];
        id state = [[node getState] state];
        
        if ([foundStates objectForKey:state]) {
            [foundStates[state] takeParentsFrom:node];
            [self removeChildlessNodeFromMDD:node trimmingVariables:false];
            
            nodeIndex--;
        } else {
            [foundStates setValue:node forKey:state];
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
    for (int edgeValue = [[_x at: parentValue] min]; edgeValue <= [[_x at: parentValue] max]; edgeValue++) {
        if ([parentNode canChooseValue: edgeValue]) {
            Node* childNode;
            id state = [self generateStateFromParent:parentNode withValue:edgeValue];
            if (parentValue != [_x up]) { //If not on layer before sink
                childNode = [[Node alloc] initNode: _trail
                                     minChildIndex:min_domain_val
                                     maxChildIndex:max_domain_val
                                             value:parentValue+1
                                             state:state];
                
                [self addNode:childNode toLayer:parentValue+1];
            } else {
                childNode = layers[[_x up] +1][0];
            }
            [parentNode addChild:childNode at:edgeValue];
            [childNode addParent:parentNode];
            assignTRInt(&layer_variable_count[parentValue][edgeValue], layer_variable_count[parentValue][edgeValue]._val+1, _trail);
        }
    }
}
-(void) addPropagationsAndTrimValues
{
    for(ORInt layer = [_x low]; layer <= [_x up]; layer++) {
        [self trimValuesFromLayer:layer];
        [self addPropagationToLayer: layer];
    }
}
-(void) trimValuesFromLayer:(ORInt)layer
{
    for (int value = min_domain_val; value <= max_domain_val; value++) {
        if (!layer_variable_count[layer][value]._val) {
            [_x[layer] remove: value];
        }
    }
}
-(void) addPropagationToLayer:(ORInt)layer
{
    if (!bound((CPIntVar*)_x[layer])) {
        [_x[layer] whenLoseValue:self do:^(ORInt value) {
            [self trimValueFromLayer: layer :value ];
        }];
    }
}
-(id) generateRootState:(int)layerValue
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
    Node* *layer = layers[node.value];
    
    for (int node_index = 0; node_index < layer_size[node.value]._val; node_index++) {
        if (layer[node_index] != NULL && layer[node_index] == node) {
            int finalNodeIndex = layer_size[node.value]._val-1;
            assignTRId(&layer[node_index], layer[finalNodeIndex], _trail);
            assignTRId(&layer[finalNodeIndex], NULL, _trail);
            assignTRInt(&layer_size[node.value], finalNodeIndex,_trail);
        }
    }
}
-(void) removeChildlessNodeFromMDD:(Node*)node trimmingVariables:(bool)trimming
{
    for (Node* parent in node.parents) {
        int child_index = [parent findChildIndex: node];
        while(child_index != -1) {
            [parent removeChildAt:child_index];
            
            assignTRInt(&layer_variable_count[[parent value]][child_index], layer_variable_count[[parent value]][child_index]._val -1, _trail);
            if (trimming && !layer_variable_count[[parent value]][child_index]._val) {
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
    for(int child_index = min_domain_val; child_index <= max_domain_val; child_index++) {
        Node* childNode = [node children][child_index];
        
        if (childNode != NULL) {
            [childNode removeParentValue: node];
            [node removeChildAt: child_index];
            
            assignTRInt(&layer_variable_count[[node value]][child_index], layer_variable_count[[node value]][child_index]._val -1, _trail);
            if (trimming & !layer_variable_count[[node value]][child_index]._val) {
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
}
-(void) printGraph {
    //[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat: @"/Users/ben/graphs/%d.dot", ] contents:nil attributes:nil];
    NSMutableDictionary* nodeNames = [[NSMutableDictionary alloc] init];
    
    NSMutableString* output = [NSMutableString stringWithFormat: @"\ndigraph {\n"];
    
    for (int layer = [_x low]; layer < [_x up]+1; layer++) {
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
                        [output appendString: [NSString stringWithFormat: @"%d -> %d [label=\"%d\"];\n", [nodeNames[nodePointerValue] intValue], [nodeNames[childPointerValue] intValue], child_index]];
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

//Use a good heuristic, may be based on constraint
-(Node*) findNodeToRemove:(int)layer
{
    int node_index = layer_size[layer]._val-1;
    Node* node = layers[layer][node_index];
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
    [self findNodesToMerge:layer first:&first_node second:&second_node];
    
    [first_node mergeWith: second_node];
    [self removeChildlessNodeFromMDD:second_node trimmingVariables:false];
}

//Use a good heuristic, may be based on constraint
-(void) findNodesToMerge:(int)layer first:(Node**)first second:(Node**)second
{
    int first_node_index = layer_size[layer]._val-1;
    int second_node_index = layer_size[layer]._val-2;
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
-(id) generateRootState:(int)layerValue
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
-(id) generateRootState:(int)layerValue
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
-(id) generateRootState:(int)layerValue
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
-(id) initCPExactMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix
{
    self = [super initCPMDD:engine over:x reduced:reduced];
    _adjacencyMatrix = adjacencyMatrix;
    return self;
}
-(id) generateRootState:(int)layerValue
{
    return [[MISPState alloc] initMISPState:layerValue :[_x low] :[_x up]];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    return [[MISPState alloc] initMISPState:[_x low] :[_x up] parentNodeState:[parentNode getState] withValue:value adjacencies:_adjacencyMatrix];

}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPExactMDDMISP:%02d %@>",_name,_x];
}
@end

@implementation CPRestrictedMDDMISP
-(id) initCPRestrictedMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x size:(ORInt)restrictionSize reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix
{
    self = [super initCPMDDRestriction:engine over:x restrictionSize:restrictionSize reduced:reduced];
    _adjacencyMatrix = adjacencyMatrix;
    return self;
}
-(id) generateRootState:(int)layerValue
{
    return [[MISPState alloc] initMISPState:layerValue :[_x low] :[_x up]];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    return [[MISPState alloc] initMISPState:[_x low] :[_x up] parentNodeState:[parentNode getState] withValue:value adjacencies:_adjacencyMatrix];
    
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPExactMDDMISP:%02d %@>",_name,_x];
}
@end

@implementation CPRelaxedMDDMISP
-(id) initCPRelaxedMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x size:(ORInt)relaxationSize reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix
{
    self = [super initCPMDDRelaxation:engine over:x relaxationSize:relaxationSize reduced:reduced];
    _adjacencyMatrix = adjacencyMatrix;
    return self;
}
-(id) generateRootState:(int)layerValue
{
    return [[MISPState alloc] initMISPState:layerValue :[_x low] :[_x up]];
}
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value
{
    return [[MISPState alloc] initMISPState:[_x low] :[_x up] parentNodeState:[parentNode getState] withValue:value adjacencies:_adjacencyMatrix];
    
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPExactMDDMISP:%02d %@>",_name,_x];
}
@end
