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

static inline id getState(Node* n) { return n->_state;}
@implementation CPMDD
-(id) initCPMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x
{
    self = [super initCPCoreConstraint: engine];
    _nodeClass = [Node class];
    _trail = [engine trail];
    _x = x;
    _numVariables = [_x count];
    min_variable_index = [_x low];
    _min_domain_for_layer = malloc(_numVariables * sizeof(int));
    _max_domain_for_layer = malloc(_numVariables * sizeof(int));
    
    layers = malloc((_numVariables+1) * sizeof(ORTRIdArrayI*));
    layer_size = malloc((_numVariables+1) * sizeof(TRInt));
    max_layer_size = malloc((_numVariables+1) * sizeof(TRInt));
    layer_variable_count = malloc((_numVariables) * sizeof(TRInt*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
        max_layer_size[layer] = makeTRInt(_trail,10);
        layers[layer] = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:max_layer_size[layer]._val];
    }
    
    _layer_to_variable = malloc((_numVariables) * sizeof(int));
    _variable_to_layer = malloc((_numVariables) * sizeof(int));
    
    _variable_to_layer -= min_variable_index;
    
    _nextVariable = min_variable_index;
    
    _valueNotMember = malloc(_numVariables * sizeof(TRInt*));
    _valueNotMember -= min_variable_index;
    _layerBound = malloc(_numVariables * sizeof(TRInt));
    
    _canCreateStateSel = @selector(canCreateState:fromParent:assigningVariable:toValue:);
    _hashValueSel = @selector(hashValueFor:);
    _removeParentlessSel = @selector(removeParentlessNodeFromMDD:fromLayer:);
    _removeParentlessNode = (RemoveParentlessIMP)[self methodForSelector:_removeParentlessSel];
    
    return self;
}
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x spec:(MDDStateSpecification*)spec {
    self = [self initCPMDD:engine over:x];
    _spec = [spec retain];
    _hashWidth = 100;
    [_spec finalizeSpec:_trail hashWidth:_hashWidth];
    _numBytes = [_spec numBytes];
    
    _hashValueFor = (HashValueIMP)[_spec methodForSelector:_hashValueSel];
    _canCreateState = (CanCreateStateIMP)[_spec methodForSelector:_canCreateStateSel];
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
    SEL assignVariableSel = @selector(assignVariableToLayer:);
    AssignVariableIMP assignVariableToLayer = (AssignVariableIMP)[self methodForSelector:assignVariableSel];
    SEL buildLayerSel = @selector(buildLayerByNode:);
    BuildLayerByValueIMP buildLayerByValue = (BuildLayerByValueIMP)[self methodForSelector:buildLayerSel];
    
    _inPost = true;
    [self createRootAndSink];
    for (int layer = 1; layer < _numVariables; layer++) {
        assignVariableToLayer(self,assignVariableSel,layer);
        buildLayerByValue(self,buildLayerSel,layer);
        [self cleanLayer: layer];
    }
    [self buildLastLayer];
    [self addPropagationsAndTrimDomains];
    /*NSMutableString* printOut = [NSMutableString string];
    //for (int i = 0; i < layer_size[_numVariables-1]._val; i++) {
    //    Node* node = [layers[_numVariables-1] at:i];
    //    [printOut appendString:[NSString stringWithFormat:@"Node %d:\n",i]];
    //    [printOut appendString:[node toString]];
    //}
    int totalNumEdges = 0;
    double totalConstraint1Range = 0.0;
    double totalConstraint2Range = 0.0;
    double totalConstraint3Range = 0.0;
    double totalConstraint4Range = 0.0;
    int totalNumMergedNodes = 0;
    int numMegedLayers = 0;
    for (int layer = 0; layer < _numVariables; layer++) {
        int numEdges = 0;
        int constraint1Range = 0;
        int constraint2Range = 0;
        int constraint3Range = 0;
        int constraint4Range = 0;
        int numMergedNodes = 0;
        int minDomain = _min_domain_for_layer[layer];
        int maxDomain = _max_domain_for_layer[layer];
        int layerSize = layer_size[layer]._val;
        TRInt* varCount = layer_variable_count[layer];
        ORTRIdArrayI* layerNodes = layers[layer];
        for (int nodeIndex = 0; nodeIndex < layerSize; nodeIndex++) {
            if ([[layerNodes at:nodeIndex] isMerged]) {
                numMergedNodes++;
            }
            if (layer != 0) {
                MDDStateValues* state = getState([layerNodes at:nodeIndex]);
                char* stateProperties = [state state];
                constraint1Range += (min(6,*(short*)&stateProperties[2]) - *(short*)&stateProperties[0]);
                constraint2Range += (min(6,*(short*)&stateProperties[8]) - *(short*)&stateProperties[6]);
                constraint3Range += (min(6,*(short*)&stateProperties[14]) - *(short*)&stateProperties[12]);
                constraint4Range += (min(6,*(short*)&stateProperties[20]) - *(short*)&stateProperties[18]);
            }
        }
        for (int i = minDomain; i <= maxDomain; i++) {
            numEdges += varCount[i]._val;
        }
        if (numMergedNodes) {
            totalNumMergedNodes += numMergedNodes;
            numMegedLayers++;
        }
        constraint1Range /= layerSize;
        constraint2Range /= layerSize;
        constraint3Range /= layerSize;
        constraint4Range /= layerSize;
        [printOut appendString:[NSString stringWithFormat:@"Average constraint ranges on layer %d: %d %d %d %d\n", layer, constraint1Range, constraint2Range, constraint3Range, constraint4Range]];
        [printOut appendString:[NSString stringWithFormat:@"# Edges on layer %d: %d\n",layer,numEdges]];
        totalNumEdges += numEdges;
        totalConstraint1Range += constraint1Range;
        totalConstraint2Range += constraint2Range;
        totalConstraint3Range += constraint3Range;
        totalConstraint4Range += constraint4Range;
    }
    totalConstraint1Range /= (_numVariables-1);
    totalConstraint2Range /= (_numVariables-1);
    totalConstraint3Range /= (_numVariables-1);
    totalConstraint4Range /= (_numVariables-1);
    [printOut appendString:[NSString stringWithFormat:@"Average constraint ranges: %f %f %f %f\n",totalConstraint1Range, totalConstraint2Range, totalConstraint3Range, totalConstraint4Range]];
    [printOut appendString:[NSString stringWithFormat:@"Average across ranges: %f \n",(totalConstraint1Range+ totalConstraint2Range+ totalConstraint3Range+ totalConstraint4Range)/4]];
    [printOut appendString:[NSString stringWithFormat:@"# Edges total: %d\n",totalNumEdges]];
    [printOut appendString:[NSString stringWithFormat:@"# Merged nodes: %d across %d layers\n",totalNumMergedNodes,numMegedLayers]];
    NSLog(@"%@",printOut);*/
    _inPost = false;
    return;
}
-(void) assignVariableToLayer:(int)layer {
    _variable_to_layer[_nextVariable] = layer;
    _layer_to_variable[layer] = _nextVariable;
    id<CPIntVar> var = [_x at:_nextVariable];
    int minDomain = [var min];
    int maxDomain = [var max];
    int domSize = maxDomain - minDomain + 1;
    TRInt* variable_count = malloc(domSize * sizeof(TRInt));
    variable_count -= minDomain;
    TRInt* valueNotMember = malloc(domSize * sizeof(TRInt));
    valueNotMember -= minDomain;
    for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
        variable_count[domainVal] = makeTRInt(_trail, 0);
        valueNotMember[domainVal] = makeTRInt(_trail, 0);
    }
    layer_variable_count[layer] = variable_count;
    _valueNotMember[_nextVariable] = valueNotMember;
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
    Node* sink = [[_nodeClass alloc] initNode: _trail hashWidth:_hashWidth];
    [self addNode: sink toLayer:((int)_numVariables)];
    
    id state = [self generateRootState:_nextVariable];
    [self assignVariableToLayer:0];
    Node* root = [[_nodeClass alloc] initNode: _trail
                          minChildIndex:_min_domain_for_layer[0]
                          maxChildIndex:_max_domain_for_layer[0]
                                  state:state
                              hashWidth:_hashWidth];
    [self addNode:root toLayer:0];
    [state release];
    [root release];
    [sink release];
}
-(void) cleanLayer:(int)layer { return; }
-(void) afterPropagation { return; }
-(void) connect:(Node*)parent to:(Node*)child value:(int)value {
    @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method connect not implemented"];
}
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
                    [self connect:parentNode to:sink value:edgeValue];
                    assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                }
            }
        } else {
            _valueNotMember[parentVariableIndex][edgeValue] = makeTRInt(_trail, 1);
        }
    }
    for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
        Node* parentNode = [parentNodes at: parentNodeIndex];
        if ([parentNode isChildless]) {
            [self removeChildlessNodeFromMDD:parentNode fromLayer:parentLayer];
            parentNodeIndex--;
            parentLayerSize--;
        }
    }
}
-(void) buildLayerByValue:(int)layer {
    int parentLayer = layer-1;
    int parentVariableIndex = _layer_to_variable[parentLayer];
    int minDomain = _min_domain_for_layer[parentLayer];
    int maxDomain = _max_domain_for_layer[parentLayer];
    int parentLayerSize = layer_size[parentLayer]._val;
    int hashWidth = _hashWidth;
    int childMinDomain = _min_domain_for_layer[parentLayer+1];
    int childMaxDomain = _max_domain_for_layer[parentLayer+1];
    id<CPIntVar> parentVariable = _x[parentVariableIndex];
    BetterNodeHashTable* nodeHashTable = [[BetterNodeHashTable alloc] initBetterNodeHashTable:_hashWidth numBytes:_numBytes];
    ORTRIdArrayI* parentNodes = layers[parentLayer];
    
    SEL hasNodeSel = @selector(hasNodeWithStateProperties:hash:node:);
    HasNodeIMP hasNode = (HasNodeIMP)[nodeHashTable methodForSelector:hasNodeSel];
    
    for (int edgeValue = minDomain; edgeValue <= maxDomain; edgeValue++) {
        if ([parentVariable member: edgeValue]) {
            for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
                Node* parentNode = [parentNodes at: parentNodeIndex];
                MDDStateValues* parentState = getState(parentNode);
                char* newStateProperties;
                if (_canCreateState(_spec, _canCreateStateSel, &newStateProperties, parentState, parentVariableIndex, edgeValue)) {
                    NSUInteger hashValue = _hashValueFor(_spec,_hashValueSel,newStateProperties);
                    Node* childNode;
                    bool nodeExists = hasNode(nodeHashTable, hasNodeSel, newStateProperties, hashValue, &childNode);
                    if (!nodeExists) {
                        MDDStateValues* newState = [[MDDStateValues alloc] initState:newStateProperties numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
                        childNode = [[_nodeClass alloc] initNode: _trail
                                             minChildIndex:childMinDomain
                                             maxChildIndex:childMaxDomain
                                                     state:newState
                                                 hashWidth:hashWidth];
                        [self addNode:childNode toLayer:layer];
                        [nodeHashTable addState:newState];
                        [newState release];
                        [childNode release];
                    }
                    [self connect:parentNode to:childNode value:edgeValue];
                    if (nodeExists) {
                        free(newStateProperties);
                    }
                    assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                }
            }
        } else {
            _valueNotMember[parentVariableIndex][edgeValue] = makeTRInt(_trail, 1);
        }
    }
    if (!layer_size[layer]._val) {
        failNow();
    }
    [nodeHashTable release];
    if (layer != 1) {
        for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
            Node* parentNode = [parentNodes at: parentNodeIndex];
            if ([parentNode isChildless]) {
                [self removeChildlessNodeFromMDD:parentNode fromLayer:parentLayer];
                parentNodeIndex--;
                parentLayerSize--;
            }
        }
    }
}
-(void) buildLayerByNode:(int)layer {
    int parentLayer = layer-1;
    int parentVariableIndex = _layer_to_variable[parentLayer];
    int minDomain = _min_domain_for_layer[parentLayer];
    int maxDomain = _max_domain_for_layer[parentLayer];
    int domSize = maxDomain - minDomain + 1;
    int parentLayerSize = layer_size[parentLayer]._val;
    int hashWidth = _hashWidth;
    int childMinDomain = _min_domain_for_layer[parentLayer+1];
    int childMaxDomain = _max_domain_for_layer[parentLayer+1];
    id<CPIntVar> parentVariable = _x[parentVariableIndex];
    BetterNodeHashTable* nodeHashTable = [[BetterNodeHashTable alloc] initBetterNodeHashTable:_hashWidth numBytes:_numBytes];
    ORTRIdArrayI* parentNodes = layers[parentLayer];
    
    SEL hasNodeSel = @selector(hasNodeWithStateProperties:hash:node:);
    HasNodeIMP hasNode = (HasNodeIMP)[nodeHashTable methodForSelector:hasNodeSel];
    
    bool* inDomain = calloc(domSize, sizeof(bool));
    inDomain -= minDomain;
    for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
        if ([parentVariable member:domainVal]) {
            inDomain[domainVal] = true;
        } else {
            _valueNotMember[parentVariableIndex][domainVal] = makeTRInt(_trail, 1);
        }
    }
    for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
        Node* parentNode = [parentNodes at: parentNodeIndex];
        MDDStateValues* parentState = getState(parentNode);
        for (int edgeValue = minDomain; edgeValue <= maxDomain; edgeValue++) {
            if (inDomain[edgeValue]) {
                char* newStateProperties;
                if (_canCreateState(_spec,_canCreateStateSel,&newStateProperties,parentState,parentVariableIndex,edgeValue)) {
                    NSUInteger hashValue = _hashValueFor(_spec,_hashValueSel,newStateProperties);
                    Node* childNode;
                    bool nodeExists = hasNode(nodeHashTable, hasNodeSel, newStateProperties, hashValue, &childNode);
                    if (!nodeExists) {
                        MDDStateValues* newState = [[MDDStateValues alloc] initState:newStateProperties numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
                        childNode = [[_nodeClass alloc] initNode: _trail
                                             minChildIndex:childMinDomain
                                             maxChildIndex:childMaxDomain
                                                     state:newState
                                                 hashWidth:hashWidth];
                        [self addNode:childNode toLayer:layer];
                        [nodeHashTable addState:newState];
                        [newState release];
                        [childNode release];
                    }
                    [self connect:parentNode to:childNode value:edgeValue];
                    if (nodeExists) {
                        free(newStateProperties);
                    }
                    assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                }
            }
        }
        if ([parentNode isChildless]) {
            [self removeChildlessNodeFromMDD:parentNode fromLayer:parentLayer];
            parentNodeIndex--;
            parentLayerSize--;
        }
    }
    inDomain += minDomain;
    free(inDomain);
    if (!layer_size[layer]._val) {
        failNow();
    }
    [nodeHashTable release];
}
-(void) addPropagationsAndTrimDomains
{
    for(ORInt layer = 0; layer < _numVariables; layer++) {
        [self trimDomainsFromLayer:layer];
        [self addPropagationToLayer: layer];
    }
}
-(void) trimDomainsFromLayer:(ORInt)layer
{
    int variableIndex = _layer_to_variable[layer];
    id<CPIntVar> variable = _x[variableIndex];
    TRInt* variable_count = layer_variable_count[layer];
    TRInt* valueNotMember = _valueNotMember[variableIndex];
    for (int value = _min_domain_for_layer[layer]; value <= _max_domain_for_layer[layer]; value++) {
        if (!variable_count[value]._val && [variable member:value]) {
            [variable remove: value];
            assignTRInt(&valueNotMember[value], 1, _trail);
        }
    }
}
-(void) addPropagationToLayer:(ORInt)layer
{
    int variableIndex = [self variableIndexForLayer:layer];
    id<CPIntVar> variable = _x[variableIndex];
    if (!bound((CPIntVar*)variable)) {
        _layerBound[layer] = makeTRInt(_trail, 0);
        TRInt* variable_count = layer_variable_count[layer];
        TRInt* valueNotMember = _valueNotMember[variableIndex];
        int maxDomain = _max_domain_for_layer[layer];
        [variable whenChangeDo:^() {
            _highestLayerChanged = (int)_numVariables+1;
            _lowestLayerChanged = 0;
            bool layerChanged = false;
            for (int domain_val = _min_domain_for_layer[layer]; domain_val <= maxDomain; domain_val++) {
                if (variable_count[domain_val]._val) {
                    //if valueNotMember[domain_val] is true, then we already trimmed that value
                    if (!valueNotMember[domain_val]._val && ![variable member:domain_val]) {
                        [self trimValueFromLayer: layer :domain_val ];
                        layerChanged = true;
                        assignTRInt(&valueNotMember[domain_val], 1, _trail);
                    }
                }
            }
            if (layerChanged) {
                for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
                    if (_layerBound[layer_index]._val) continue;
                    int trimmingVariableIndex = _layer_to_variable[layer_index];
                    TRInt* trimmingVariableCount = layer_variable_count[layer_index];
                    id<CPIntVar> variableForTrimming = _x[trimmingVariableIndex];
                    TRInt* trimmingValueNotMember = _valueNotMember[trimmingVariableIndex];
                    int trimmingMaxDomain = _max_domain_for_layer[layer_index];
                    for (int domain_val = _min_domain_for_layer[layer]; domain_val <= trimmingMaxDomain; domain_val++) {
                        if (trimmingVariableCount[domain_val]._val) {
                            if (!trimmingValueNotMember[domain_val]._val && ![variableForTrimming member:domain_val]) {
                                [self trimValueFromLayer: layer_index :domain_val ];
                                assignTRInt(&trimmingValueNotMember[domain_val], 1, _trail);
                            }
                        }
                    }
                }
                [self afterPropagation];
                if (_lowestLayerChanged == _numVariables) {
                    _lowestLayerChanged--;
                }
                for (int i = _highestLayerChanged; i <= _lowestLayerChanged; i++) {
                    if (!_layerBound[i]._val) {
                        [self trimDomainsFromLayer:i];
                        int varInd = _layer_to_variable[i];
                        id<CPIntVar> var = _x[varInd];
                        if (bound((CPIntVar*)var)) {
                            assignTRInt(&_layerBound[i], 1, _trail);
                        }
                    }
                }
            }
            //_todo = CPChecked;
        } onBehalf:self];
    } else {
        _layerBound[layer] = makeTRInt(_trail, 1);
    }
}
-(id) generateRootState:(int)variableValue
{
    return [_spec createRootState:variableValue];
}
-(void) addNode:(Node*)node toLayer:(int)layer_index
{
    int layerSize = layer_size[layer_index]._val;
    if (max_layer_size[layer_index]._val == layerSize) {
        assignTRInt(&max_layer_size[layer_index], max_layer_size[layer_index]._val*2, _trail);
        [layers[layer_index] resize:max_layer_size[layer_index]._val inPost:_inPost];
    }
    [node setInitialLayerIndex:layerSize];
    [layers[layer_index] set:node at:layerSize inPost:_inPost];
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
        if (_inPost) {
            [movedNode setInitialLayerIndex:index];
        } else {
            [movedNode updateLayerIndex:index];
        }
        [layer set:movedNode at:index inPost:_inPost];
    }
    [layer set:nil at:finalNodeIndex inPost:_inPost];
    assignTRInt(&layer_size[node_layer], finalNodeIndex,_trail);
}
-(int) removeChildlessNodeFromMDDAtIndex:(int)nodeIndex fromLayer:(int)layer {
    int highestLayerChanged = [self checkParentsOfChildlessNode:[layers[layer] at:nodeIndex] parentLayer:layer-1];
    [self removeNodeAt: nodeIndex onLayer:layer];
    return highestLayerChanged;
}
-(int) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer {
    if (layer_size[layer]._val == 1) {
        failNow();
    }
    int highestLayerChanged = [self checkParentsOfChildlessNode:node parentLayer:layer-1];
    [self removeNode: node onLayer:layer];
    return highestLayerChanged;
}
-(void) removeChild:(Node*)node fromParent:(id)parent parentLayer:(int)parentLayer {
    @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method removeParent not implemented"];
}
-(bool) parentIsChildless:(id)parent {
    @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method parentIsChildless not implemented"];
    return false;
}
-(int) checkParentsOfChildlessNode:(Node*)node parentLayer:(int)layer {
    int numParents = [node numParents];
    ORTRIdArrayI* parents = [node parents];
    int highestLayerChanged = layer;
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        id parent = [parents at: parentIndex];
        [self removeChild:node fromParent:parent parentLayer:layer];
        if ([self parentIsChildless:parent]) {
            highestLayerChanged = min(highestLayerChanged,[self removeChildlessFromMDD:parent fromLayer:layer]);
        }
    }
    return highestLayerChanged;
}
-(void) removeParentlessFromMDD:(id)node fromLayer:(int)layer {
    @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method removeParentlessFromMDD not implemented"];
}
-(int) removeChildlessFromMDD:(id)node fromLayer:(int)layer {
    @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method removeChildlessFromMDD not implemented"];
}
-(void) removeParentlessNodeFromMDD:(Node*)node fromLayer:(int)layer {
    if (layer_size[layer]._val == 1) { failNow(); }
    TRId* children = [node children];
    int childLayer = layer+1;
    int numChildren = [node numChildren];
    TRInt* variable_count = layer_variable_count[layer];
    
    for (int child_index = _min_domain_for_layer[layer]; numChildren; child_index++) {
        id child = children[child_index];
        if (child != nil) {
            [child removeParent:node inPost:_inPost];
            assignTRInt(&variable_count[child_index], variable_count[child_index]._val-1, _trail);
            if ([child isParentless]) {
                [self removeParentlessFromMDD:child fromLayer:childLayer];
            } else if ([child isMerged]) {
                [child setRecalcRequired:true];
            }
            numChildren--;
        }
    }
    if (_lowestLayerChanged < childLayer) {
        _lowestLayerChanged = childLayer;
    }
    [self removeNode: node onLayer:layer];
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    ORTRIdArrayI* layer = layers[layer_index];
    int numEdgesToDelete = layer_variable_count[layer_index][value]._val;
    int highestLayerChanged = layer_index;
    int childLayer = layer_index+1;
    for (int node_index = 0; numEdgesToDelete; node_index++) {
        Node* node = [layer at: node_index];
        id child = [node children][value];
        if (child != NULL) {
            [node removeChildAt:value inPost:_inPost];
            [child removeParent:node inPost:_inPost];
            if ([child isParentless]) {
                [self removeParentlessFromMDD:child fromLayer:childLayer];
            }
            if ([node isChildless]) {
                highestLayerChanged = max(highestLayerChanged, [self removeChildlessNodeFromMDD:node fromLayer:layer_index]);
                node_index--;
            }
            numEdgesToDelete--;
        }
    }
    _highestLayerChanged = min(_highestLayerChanged,highestLayerChanged);
    assignTRInt(&layer_variable_count[layer_index][value], 0, _trail);
}
-(void) dealloc {
    for (int i = 0; i < _numVariables; i++) {
        [layers[i] release];
        if (min_variable_index + i < _nextVariable) {
            layer_variable_count[i] += _min_domain_for_layer[i];
            free(layer_variable_count[i]);
        }
    }
    [layers[_numVariables] release];
    free(layers);
    free(layer_size);
    free(max_layer_size);
    int maxVarIndex = min_variable_index + (int)_numVariables;
    for (int i = min_variable_index; i < maxVarIndex; i++) {
        if (i < _nextVariable) {
            _valueNotMember[i] += _min_domain_for_layer[_variable_to_layer[i]];
            free(_valueNotMember[i]);
        } else {
            break;
        }
    }
    _valueNotMember += min_variable_index;
    free(_valueNotMember);
    free(_layer_to_variable);
    _variable_to_layer += min_variable_index;
    free(_variable_to_layer);
    free(_min_domain_for_layer);
    free(_max_domain_for_layer);
    free(_layerBound);
    [_spec release];
    [super dealloc];
}

-(ORInt) recommendationFor:(id<CPIntVar>)x
{
    //int variableId = [x getId] + min_variable_index;
    int variableId = -1;
    for (int i = min_variable_index; i < min_variable_index + _numVariables; i++) {
        if (_x[i] == x) {
            variableId = i;
            break;
        }
    }
    int layer = _variable_to_layer[variableId];
    int minDomain = [x min];
    int maxDomain = [x max];
    if (_x[variableId] != x) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method recommendationFor needs better way to figure out correct variable."];
    }
    
    if (_recommendationStyle == MinDomain) {
        return [x min];
    } else if (_recommendationStyle == FewestArcs) {
        TRInt* variableCount = layer_variable_count[layer];
        int bestDomainValue = minDomain;
        int bestValueNumEdges = variableCount[minDomain]._val;
        TRInt* valueNotMember = _valueNotMember[variableId];
        for (int i = minDomain+1; i <= maxDomain; i++) {
            if (bestValueNumEdges == 1) {
                return bestDomainValue;
            }
            if (!valueNotMember[i]._val || [x member:i]) {
                int numEdges = variableCount[i]._val;
                if (numEdges && numEdges < bestValueNumEdges) {
                    bestValueNumEdges = numEdges;
                    bestDomainValue = i;
                }
            }
        }
        return bestDomainValue;
    } else if (_recommendationStyle == MostArcs) {
        int layerSize = layer_size[layer]._val;
        TRInt* variableCount = layer_variable_count[layer];
        int bestDomainValue = minDomain;
        int bestValueNumEdges = variableCount[minDomain]._val;
        TRInt* valueNotMember = _valueNotMember[variableId];
        for (int i = minDomain+1; i <= maxDomain; i++) {
            if (bestValueNumEdges == layerSize) {
                return bestDomainValue;
            }
            if (!valueNotMember[i]._val || [x member:i]) {
                int numEdges = variableCount[i]._val;
                if (numEdges && numEdges > bestValueNumEdges) {
                    bestValueNumEdges = numEdges;
                    bestDomainValue = i;
                }
            }
        }
        return bestDomainValue;
    } else if (_recommendationStyle == MostArcsIntoNonMerged) {
        int layerSize = layer_size[layer]._val;
        int* exactArcsPerDomain = calloc((maxDomain - minDomain + 1), sizeof(int));
        exactArcsPerDomain -= minDomain;
        ORTRIdArrayI* layerNodes = layers[layer];
        for (int i = 0; i < layerSize; i++) {
            TRId* children = [(Node*)[layerNodes at:i] children];
            for (int d = minDomain; d <= maxDomain; d++) {
                if (children[d] != nil && ![children[d] isMerged]) {
                    exactArcsPerDomain[d] += 1;
                }
            }
        }
        int bestDomainVal = minDomain;
        int bestNumArcs = exactArcsPerDomain[minDomain];
        for (int d = minDomain+1; d <= maxDomain; d++) {
            if (bestNumArcs < exactArcsPerDomain[d]) {
                bestDomainVal = d;
                bestNumArcs = exactArcsPerDomain[d];
            }
        }
        exactArcsPerDomain += minDomain;
        free(exactArcsPerDomain);
        return bestDomainVal;
    } else if (_recommendationStyle == FewestArcsIntoMerged) {
        int layerSize = layer_size[layer]._val;
        int* mergedArcsPerDomain = calloc((maxDomain - minDomain + 1), sizeof(int));
        mergedArcsPerDomain -= minDomain;
        ORTRIdArrayI* layerNodes = layers[layer];
        for (int i = 0; i < layerSize; i++) {
            TRId* children = [(Node*)[layerNodes at:i] children];
            for (int d = minDomain; d <= maxDomain; d++) {
                if (children[d] != nil && [children[d] isMerged]) {
                    mergedArcsPerDomain[d] += 1;
                }
            }
        }
        int bestDomainVal = minDomain;
        int bestNumArcs = INT_MAX;
        TRInt* variableCount = layer_variable_count[layer];
        for (int d = minDomain; d <= maxDomain; d++) {
            int mergedArcs = mergedArcsPerDomain[d];
            if (bestNumArcs > mergedArcs && variableCount[d]._val - mergedArcs > 0) {
                //Finding domain with fewest merged arcs s.t. at least one exact arc
                bestDomainVal = d;
                bestNumArcs = mergedArcsPerDomain[d];
            }
        }
        mergedArcsPerDomain += minDomain;
        free(mergedArcsPerDomain);
        return bestDomainVal;
    }else if (_recommendationStyle == SmallestSlack) {
        ORTRIdArrayI* nextLayer = layers[layer+1];
        int layerSize = layer_size[layer+1]._val;
        Node* bestNode = [nextLayer at:0];
        char* state = [(MDDStateValues*)getState(bestNode) state];
        long lowestSlackValue;
        if (layerSize != 1) {
            lowestSlackValue = [_spec slack:state];
        }
        for (int i = 1; i < layerSize; i++) {
            Node* node = [nextLayer at:i];
            state = [(MDDStateValues*)getState(node) state];
            long slackValue = [_spec slack:state];
            if (slackValue < lowestSlackValue) {
                bestNode = node;
                if (slackValue == 0) {
                    break;
                }
            }
        }
        if ([bestNode isMemberOfClass:[OldNode class]]) {
            OldNode* parent = [[bestNode parents] at:0];
            TRId* children = [parent children];
            for (int i = minDomain; i <= maxDomain; i++) {
                if (children[i] == bestNode) {
                    return i;
                }
            }
        } else {
            return [[[bestNode parents] at:0] arcValue];
        }
    } else {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Recommendation Style not yet implemented."];
    }
    return [x min];
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

-(void) DEBUGTestNodeLayerIndexCorrectness
{
    for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
        ORTRIdArrayI* layer = layers[layer_index];
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            OldNode* node = [layer at:node_index];
            int nodesLayerIndex = [node layerIndex];
            if (node_index != nodesLayerIndex) {
                int i =0;
            }
        }
    }
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
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize {
    self = [super initCPMDD:engine over:x];
    _relaxation_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification*)spec equalBuckets:(bool)equalBuckets usingSlack:(bool)usingSlack recommendationStyle:(MDDRecommendationStyle)recommendationStyle {
    self = [super initCPMDD:engine over:x];
    _spec = [spec retain];
    _relaxation_size = relaxationSize;
    _equalBuckets = equalBuckets;
    _usingSlack = usingSlack;
    _recommendationStyle = recommendationStyle;
    _hashWidth = relaxationSize * 2;
    [_spec finalizeSpec:_trail hashWidth:_hashWidth];
    _numBytes = [_spec numBytes];
    
    _splitNodesOnLayerSel = @selector(splitNodesOnLayer:);
    _splitNodesOnLayer = (SplitNodesOnLayerIMP)[self methodForSelector:_splitNodesOnLayerSel];
    _hashValueFor = (HashValueIMP)[_spec methodForSelector:_hashValueSel];
    _canCreateState = (CanCreateStateIMP)[_spec methodForSelector:_canCreateStateSel];
    _computeStateFromPropertiesSel = @selector(computeStateFromProperties:assigningVariable:withValue:);
    _computeStateFromProperties = (ComputeStateFromPropertiesIMP)[_spec methodForSelector:_computeStateFromPropertiesSel];
    _calculateStateFromParentsSel = @selector(calculateStateFromParentsOf:onLayer:isMerged:);
    _calculateStateFromParents = (CalculateStateFromParentsIMP)[self methodForSelector:_calculateStateFromParentsSel];
    return self;
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    ORTRIdArrayI* layer = layers[layer_index];
    int numEdgesToDelete = layer_variable_count[layer_index][value]._val;
    int highestLayerChanged = layer_index;
    int childLayer = layer_index + 1;
    for (int node_index = 0; numEdgesToDelete; node_index++) {
        Node* node = [layer at: node_index];
        id child = [node children][value];
        if (child != NULL) {
            [node removeChildAt:value inPost:_inPost];
            [child removeParent:node inPost:_inPost];
            if ([child isParentless]) {
                [self removeParentlessFromMDD:child fromLayer:childLayer];
            } else if ([child isMerged]) {
                [child setRecalcRequired:true];
                if (_lowestLayerChanged < childLayer) {
                    _lowestLayerChanged = childLayer;
                }
            }
            if ([node isChildless]) {
                highestLayerChanged = max(highestLayerChanged, [self removeChildlessNodeFromMDD:node fromLayer:layer_index]);
                node_index--;
            }
            numEdgesToDelete--;
        }
    }
    _highestLayerChanged = min(_highestLayerChanged,highestLayerChanged);
    assignTRInt(&layer_variable_count[layer_index][value],0, _trail);
}
-(void) afterPropagation {
    [self rebuild];
}
-(void) rebuild
{
    for (int layer = _highestLayerChanged; layer <=  min(_lowestLayerChanged+1,(int)_numVariables-1); layer++) {
        [self recalcNodesOnLayer:layer];
        _splitNodesOnLayer(self,_splitNodesOnLayerSel,layer);
        [self recalcNodesOnLayer:layer];
        
        if (layer_size[layer+1]._val == 0) {
            failNow();
        }
    }
    return;
}
-(void) splitNodesOnLayer:(int)layer {
    @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method splitNodesOnLayer not implemented"];
}
-(void) recalcNode:(Node*)node onLayer:(int)layer {
    ORInt variableIndex = [self variableIndexForLayer:layer];
    bool isMergedNode;
    MDDStateValues* nodeState = getState(node);
    char* oldStateProperties = [nodeState state];
    char* newStateProperties = _calculateStateFromParents(self, _calculateStateFromParentsSel, node, layer-1, &isMergedNode);
    [node setIsMergedNode:isMergedNode];
    if (memcmp(oldStateProperties, newStateProperties, _numBytes) != 0) {
        [nodeState replaceStateWith:newStateProperties trail:_trail];
        [self reevaluateChildrenAfterParentStateChange:node onLayer:layer andVariable:variableIndex];
        _lowestLayerChanged = max(_lowestLayerChanged, layer+1);
    }
    free(newStateProperties);
}
-(void) recalcNodesOnLayer:(int)layer
{
    ORTRIdArrayI* layerArray = layers[layer];
    int layerSize = layer_size[layer]._val;
    for (int node_index = 0; node_index < layerSize; node_index++) {
        Node* node = [layerArray at:node_index];
        if ([node recalcRequired]) {
            [self recalcNode:node onLayer:layer];
            if ([node isChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layer];
                node_index--;
                layerSize--;
            } else {
                [node setRecalcRequired:false];
            }
        }
    }
}
-(char*) calculateStateFromParentsOf:(Node*)node onLayer:(int)layer isMerged:(bool*)isMergedNode {
    @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method calculateStateFromParentsOf not implemented"];
}
-(void) recalcFor:(id)child parentProperties:(char*)nodeProperties variable:(int)variableIndex {
    @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method recalcFor not implemented"];
}
-(void) reevaluateChildrenAfterParentStateChange:(Node*)node onLayer:(int)layer_index andVariable:(int)variableIndex {
    TRId* children = [node children];
    MDDStateValues* nodeState = getState(node);
    char* nodeProperties = [nodeState state];
    TRInt* variable_count = layer_variable_count[layer_index];
    int childLayer = layer_index+1;
    int maxDomain = _max_domain_for_layer[layer_index];
    for (int child_index = _min_domain_for_layer[layer_index]; child_index <= maxDomain; child_index++) {
        id child = children[child_index];
        if (child != NULL) {
            if ([_spec canChooseValue:child_index forVariable:variableIndex withState:nodeState]) {
                if (childLayer != (int)_numVariables) {
                    [self recalcFor:child parentProperties:nodeProperties variable:variableIndex];
                }
            } else {
                [node removeChildAt:child_index inPost:_inPost];
                [child removeParent:node inPost:_inPost];
                assignTRInt(&variable_count[child_index], variable_count[child_index]._val-1, _trail);
                if ([child isParentless]) {
                    [self removeParentlessFromMDD:child fromLayer:childLayer];
                } else {
                    [child setRecalcRequired:true];
                }
            }
        }
    }
}
-(void) cleanLayer:(int)layer
{
    if (layer_size[layer]._val > _relaxation_size) {
        [self mergeNodesToWidthOnLayer: layer];
    }
}
-(void) mergeNodesToWidthOnLayer:(int)layer {
    /*int initialLayerSize = layer_size[layer]._val;
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
            OldNode* first_node = [layerNodes at: best_first_node_index];
            OldNode* second_node = [layerNodes at: best_second_node_index];
            [_spec mergeState:getState(first_node) with:getState(second_node)];
            [first_node takeParentsFrom:second_node];
            [first_node setIsMergedNode:true];
            [self removeNode:second_node onLayer:layer];
            if (layer_size[layer]._val > _relaxation_size) {
                [self updateSimilarityMatrix: similarityMatrix afterMerging:best_second_node_index into:best_first_node_index onLayer:layer];
            }
        }
        for (int i = 0; i < initialLayerSize; i++) {
            free(similarityMatrix[i]);
        }
    return;*/
    
    //Could also have property to determine if it recomputes innerProduct/slack for newNode and adds it back to list to reorder. Only makes sense for Inequal Buckets (You wouldn't ever rearrange list in Equal Buckets)
    
    ORTRIdArrayI* layerNodes = layers[layer];
    int layerSize = layer_size[layer]._val;
    int minDomain = _min_domain_for_layer[layer];
    int maxDomain = _max_domain_for_layer[layer];
    //srandom(100);
    //int referenceIndex = random() % layerSize;
    int referenceIndex = arc4random_uniform(layerSize);
    Node* referenceNode = [layerNodes at:referenceIndex];
    MDDStateValues* referenceState = getState(referenceNode);
    char* referenceStateProperties = malloc(_numBytes * sizeof(char));
    memcmp(referenceStateProperties,[referenceState state],_numBytes);
    
    //NSMutableString* printOut = [NSMutableString string];
    //[printOut appendString:[NSString stringWithFormat:@"Reference Node:\n"]];
    //[printOut appendString:[referenceNode toString]];
    //NSLog(@"%@",printOut);
    
    
    NormNodePair** normNodePairs = malloc(layerSize * sizeof(NormNodePair*));
    for (int nodeIndex = 0; nodeIndex < layerSize; nodeIndex++) {
        Node* node = [layerNodes at:nodeIndex];
        MDDStateValues* state = getState(node);
        char* stateProperties = [state state];
        unsigned long innerProduct = 0;
        if (_usingSlack) {
            innerProduct = [_spec slack:stateProperties];
        } else {
            for(int k=0;k < _numBytes; k+=4) {
                innerProduct <<= 1;
                innerProduct += __builtin_popcount(~(*(int*)&referenceStateProperties[k] ^ *(int*)&stateProperties[k]));
                
                //innerProduct *= 10;
                //innerProduct += (float)(referenceStateProperties[k] + 1) * (stateProperties[k] + 1);
            }
        }
        normNodePairs[nodeIndex] = [[NormNodePair alloc] initNormNodePair:innerProduct node:node];
    }
    if (_usingSlack) {
        qsort_b(normNodePairs, layerSize, sizeof(NormNodePair*), ^(const void* a, const void* b) {
            NormNodePair* a0 = *(NormNodePair**)a;
            NormNodePair* b0 = *(NormNodePair**)b;
            long aNorm = a0->norm;
            long bNorm = b0->norm;
            if (aNorm > bNorm) return -1;
            return aNorm < bNorm ? 1 : 0;
        });
    } else {
        qsort_b(normNodePairs, layerSize, sizeof(NormNodePair*), ^(const void* a, const void* b) {
            NormNodePair* a0 = *(NormNodePair**)a;
            NormNodePair* b0 = *(NormNodePair**)b;
            long aNorm = a0->norm;
            long bNorm = b0->norm;
            if (aNorm < bNorm) return -1;
            return aNorm > bNorm ? 1 : 0;
        });
    }
    int mergesPerRelaxation;
    if (_equalBuckets) {
        mergesPerRelaxation = layerSize/_relaxation_size - 1;
    } else {
        mergesPerRelaxation = layerSize - _relaxation_size;
    }
    int extraNodes = layerSize % _relaxation_size;
    int numNewNodesAdded = 0;
    
    Node** newNodes = malloc(_relaxation_size * sizeof(Node*));
    int nodeIndex = 0;
    while (nodeIndex < layerSize - (_equalBuckets ? 0 : _relaxation_size)) {
        //NSMutableString* printOut = [NSMutableString string];
        Node* existingNode = (Node*)normNodePairs[nodeIndex]->node;
        MDDStateValues* existingState = getState(existingNode);
        char* newProperties = malloc(_numBytes * sizeof(char));
        memcpy(newProperties,[existingState state],_numBytes);
        
        
        //[printOut appendString:[NSString stringWithFormat:@"Node:\n"]];
        //[printOut appendString:[existingNode toString]];
        
        
        MDDStateValues* newState = [[MDDStateValues alloc] initState:newProperties numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
        Node* newNode = [[_nodeClass alloc] initNode:_trail minChildIndex:minDomain maxChildIndex:maxDomain state:newState hashWidth:_hashWidth];
        [_trail trailRelease:newState];
        [_trail trailRelease:newNode];
        [newNode takeParentsFrom:existingNode];
        int lastNodeToMerge;
        if (_equalBuckets) {
            lastNodeToMerge = nodeIndex + mergesPerRelaxation;
            if (extraNodes) {
                lastNodeToMerge++;
                extraNodes--;
            }
        } else {
            lastNodeToMerge = nodeIndex + mergesPerRelaxation;
        }
        while (nodeIndex++ < lastNodeToMerge) {
            Node* nodeToMerge = (Node*)normNodePairs[nodeIndex]->node;
            MDDStateValues* stateToMerge = getState(nodeToMerge);
            [_spec mergeState:newState with:stateToMerge];
            [newNode takeParentsFrom:nodeToMerge];

            
            //[printOut appendString:[NSString stringWithFormat:@"Merged with:\n"]];
            //[printOut appendString:[nodeToMerge toString]];
        }
        //NSLog(@"%@",printOut);
        
        
        [newNode setIsMergedNode:true];
        [newState recalcHash:_hashWidth trail:_trail];
        [newNode setInitialLayerIndex:numNewNodesAdded];
        newNodes[numNewNodesAdded++] = newNode;
    }
    if (!_equalBuckets) {
        for (; nodeIndex < layerSize; nodeIndex++) {
            Node* existingNode = (Node*)normNodePairs[nodeIndex]->node;
            MDDStateValues* existingState = getState(existingNode);
            char* newProperties = malloc(_numBytes * sizeof(char));
            memcpy(newProperties,[existingState state],_numBytes);
            MDDStateValues* newState = [[MDDStateValues alloc] initState:newProperties numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
            Node* newNode = [[_nodeClass alloc] initNode:_trail minChildIndex:minDomain maxChildIndex:maxDomain state:newState hashWidth:_hashWidth];
            [_trail trailRelease:newState];
            [_trail trailRelease:newNode];
            [newNode takeParentsFrom:existingNode];
            [newNode setInitialLayerIndex:numNewNodesAdded];
            newNodes[numNewNodesAdded++] = newNode;
        }
    }
    for (nodeIndex = 0; nodeIndex < _relaxation_size; nodeIndex++) {
        [layerNodes set:newNodes[nodeIndex] at:nodeIndex inPost:_inPost];
        [newNodes[nodeIndex] release];
    }
    free(newNodes);
    for (; nodeIndex < layerSize; nodeIndex++) {
        [layerNodes set:nil at:nodeIndex inPost:_inPost];
    }
    assignTRInt(&layer_size[layer],_relaxation_size,_trail);
    for (int i = 0; i < layerSize; i++) {
        [normNodePairs[i] release];
    }
    free(normNodePairs);
    
    free(referenceStateProperties);
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
        MDDStateValues* first_node_state = getState([layerNodes at: first_node_index]);
        for (second_node_index = first_node_index +1; second_node_index < ls; second_node_index++) {
            MDDStateValues* second_node_state = getState([layerNodes at: second_node_index]);
            int state_differential = [_spec stateDifferential:first_node_state with:second_node_state];
            similarityMatrix[first_node_index][second_node_index] = state_differential;
        }
    }
    return similarityMatrix;
}
-(void) updateSimilarityMatrix:(int**)similarityMatrix afterMerging:(int)best_second_node_index into:(int)best_first_node_index onLayer:(int)
layer
{
    ORTRIdArrayI* layerNodes = layers[layer];
    MDDStateValues* first_node_state = getState([layerNodes at: best_first_node_index]);
    for (int second_node_index = 0; second_node_index < layer_size[layer]._val; second_node_index++) {
        MDDStateValues* second_node_state = getState([layerNodes at: second_node_index]);
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

