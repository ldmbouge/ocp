/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPTopDownMDDWithArcs.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "ORMDDify.h"

static inline id getState(MDDNode* n) { return n->_state;}
@implementation CPMDDWithArcs
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
    //initial_layer_variable_count = malloc((_numVariables) * sizeof(int*));
    layer_variable_count = malloc((_numVariables) * sizeof(TRInt*));
    for (int layer = 0; layer <= _numVariables; layer++) {
        layer_size[layer] = makeTRInt(_trail,0);
        max_layer_size[layer] = makeTRInt(_trail,10);
        layers[layer] = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:max_layer_size[layer]._val];
    }
    
    _layer_to_variable = malloc((_numVariables) * sizeof(int));
    _variable_to_layer = malloc((_numVariables) * sizeof(int));
    
    _variable_to_layer -= [_x low];
    
    _nextVariable = [_x low];
    
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
    SEL buildLayerSel = @selector(buildLayerByValue:);
    BuildLayerByValueIMP buildLayerByValue = (BuildLayerByValueIMP)[self methodForSelector:buildLayerSel];
    
    _inPost = true;
    [self createRootAndSink];
    for (int layer = 1; layer < _numVariables; layer++) {
        assignVariableToLayer(self,assignVariableSel,layer);
        buildLayerByValue(self,buildLayerSel,layer);
        [self cleanLayer: layer];
    }
    [self buildLastLayer];
    //[self setLayerVariableCount];
    [self addPropagationsAndTrimDomains];
    _inPost = false;
    return;
}
/*-(void) setLayerVariableCount {
    for (int i = 0; i < _numVariables; i++) {
        int min_domain = _min_domain_for_layer[i];
        int max_domain = _max_domain_for_layer[i];
        int* initial_variable_count = initial_layer_variable_count[i];
        TRInt* variable_count = layer_variable_count[i];
        for (int j = min_domain; j <= max_domain; j++) {
            variable_count[j] = makeTRInt(_trail, initial_variable_count[j]);
        }
        initial_variable_count += min_domain;
        free(initial_variable_count);
    }
    free(initial_layer_variable_count);
}*/
-(void) assignVariableToLayer:(int)layer {
    _variable_to_layer[_nextVariable] = layer;
    _layer_to_variable[layer] = _nextVariable;
    id<CPIntVar> var = [_x at:_nextVariable];
    int minDomain = [var min];
    int maxDomain = [var max];
    layer_variable_count[layer] = malloc((maxDomain-minDomain+1) * sizeof(TRInt));
    layer_variable_count[layer] -= minDomain;
    //initial_layer_variable_count[layer] = calloc((maxDomain-minDomain+1), sizeof(int));
    //initial_layer_variable_count[layer] -= minDomain;
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
    MDDNode* sink = [[MDDNode alloc] initNode: _trail hashWidth:_hashWidth];
    [self addNode: sink toLayer:((int)_numVariables)];
    
    id state = [self generateRootState:_nextVariable];
    [self assignVariableToLayer:0];
    MDDNode* root = [[MDDNode alloc] initNode: _trail
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
-(void) buildLastLayer {
    int parentLayer = (int)_numVariables-1;
    int minDomain = _min_domain_for_layer[parentLayer];
    int maxDomain = _max_domain_for_layer[parentLayer];
    int parentVariableIndex = _layer_to_variable[parentLayer];
    int parentLayerSize = layer_size[parentLayer]._val;
    id<CPIntVar> parentVariable = _x[parentVariableIndex];
    ORTRIdArrayI* parentNodes = layers[parentLayer];
    MDDNode* sink = [layers[_numVariables] at: 0];
    for (int edgeValue = minDomain; edgeValue <= maxDomain; edgeValue++) {
        if ([parentVariable member: edgeValue]) {
            for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
                MDDNode* parentNode = [parentNodes at: parentNodeIndex];
                MDDStateValues* parentState = getState(parentNode);
                if([_spec canChooseValue:edgeValue forVariable:parentVariableIndex withState:parentState]) {
                    [[MDDArc alloc] initArc:_trail from:parentNode to:sink value:edgeValue inPost:_inPost];
                    //initial_layer_variable_count[parentLayer][edgeValue] += 1;
                    assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                }
            }
        }
    }
    for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
        MDDNode* parentNode = [parentNodes at: parentNodeIndex];
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
                MDDNode* parentNode = [parentNodes at: parentNodeIndex];
                MDDStateValues* parentState = getState(parentNode);
                char* newStateProperties;
                if (_canCreateState(_spec,_canCreateStateSel,&newStateProperties,parentState,parentVariableIndex,edgeValue)) {
                    NSUInteger hashValue = _hashValueFor(_spec,_hashValueSel,newStateProperties);
                //if ([_spec canCreateState:&newStateProperties fromParent:parentState assigningVariable:parentVariableIndex toValue:edgeValue]) {
                    //NSUInteger hashValue = [_spec hashValueFor:newStateProperties];
                    MDDNode* childNode;
                    //bool nodeExists = [nodeHashTable hasNodeWithStateProperties:newStateProperties hash:hashValue node:&childNode];
                    if (!hasNode(nodeHashTable,hasNodeSel,newStateProperties,hashValue,&childNode)) {
                        MDDStateValues* newState = [[MDDStateValues alloc] initState:newStateProperties numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
                        //MDDStateValues* newState = [_spec createStateWith:newStateProperties];
                        childNode = [[MDDNode alloc] initNode: _trail
                                             minChildIndex:childMinDomain
                                             maxChildIndex:childMaxDomain
                                                     state:newState
                                                 hashWidth:hashWidth];
                        [self addNode:childNode toLayer:layer];
                        [nodeHashTable addState:newState];
                        [newState release];
                        [childNode release];
                    } else {
                        free(newStateProperties);
                    }
                    [[MDDArc alloc] initArc:_trail from:parentNode to:childNode value:edgeValue inPost:_inPost];
                    //initial_layer_variable_count[parentLayer][edgeValue] += 1;
                    assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                }
            }
        }
    }
    if (!layer_size[layer]._val) {
        failNow();
    }
    [nodeHashTable release];
    if (layer != 1) {
        for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
            MDDNode* parentNode = [parentNodes at: parentNodeIndex];
            if ([parentNode isChildless]) {
                [self removeChildlessNodeFromMDDAtIndex:parentNodeIndex fromLayer:parentLayer];
                parentNodeIndex--;
                parentLayerSize--;
            }
        }
    }
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
                _lowestLayerChanged = min(_lowestLayerChanged,(int)_numVariables-1);
                for (int i = _highestLayerChanged; i <= _lowestLayerChanged; i++) {
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
-(MDDStateValues*) generateStateFromParent:(MDDNode*)parentNode assigningVariable:(int)variable withValue:(int)value
{
    MDDStateValues* parentState = getState(parentNode);
    return [_spec createStateFrom:parentState assigningVariable:variable withValue:value];
}
-(MDDStateValues*) generateTempStateFromParent:(MDDNode*)parentNode assigningVariable:(int)variable withValue:(int)value
{
    MDDStateValues* parentState = getState(parentNode);
    return [_spec createTempStateFrom:parentState assigningVariable:variable withValue:value];
}
-(void) addNode:(MDDNode*)node toLayer:(int)layer_index
{
    int layerSize = layer_size[layer_index]._val;
    if (max_layer_size[layer_index]._val == layerSize) {
        assignTRInt(&max_layer_size[layer_index], max_layer_size[layer_index]._val*2, _trail);
        [layers[layer_index] resize:max_layer_size[layer_index]._val];
    }
    [node setInitialLayerIndex:layerSize];
    [layers[layer_index] set:node at:layerSize inPost:_inPost];
    assignTRInt(&layer_size[layer_index], layerSize+1, _trail);
}
-(void) removeNode:(MDDNode*)node onLayer:(int)node_layer {
    [self removeNodeAt:[node layerIndex] onLayer:node_layer];
}
-(void) removeNodeAt:(int)index onLayer:(int)node_layer {
    ORTRIdArrayI* layer = layers[node_layer];
    
    int finalNodeIndex = layer_size[node_layer]._val-1;
    if (index != finalNodeIndex) {
        MDDNode* movedNode = [layer at:finalNodeIndex];
        [movedNode updateLayerIndex:index];
        [layer set:movedNode at:index inPost:_inPost];
    }
    //[layer set:NULL at:finalNodeIndex];
    assignTRInt(&layer_size[node_layer], finalNodeIndex,_trail);
}
-(int) removeChildlessNodeFromMDDAtIndex:(int)nodeIndex fromLayer:(int)layer {
    int highestLayerChanged = [self checkParentsOfChildlessNode:[layers[layer] at:nodeIndex] parentLayer:layer-1];
    [self removeNodeAt: nodeIndex onLayer:layer];
    return highestLayerChanged;
}
-(int) removeChildlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer {
    if (layer == 0) { failNow(); }
    int highestLayerChanged = [self checkParentsOfChildlessNode:node parentLayer:layer-1];
    [self removeNode: node onLayer:layer];
    return highestLayerChanged;
}
-(int) checkParentsOfChildlessNode:(MDDNode*)node parentLayer:(int)layer {
    int numParents = [node numParents];
    ORTRIdArrayI* parentArcs = [node parents];
    int highestLayerChanged = layer;
    //int* initial_variable_count = initial_layer_variable_count[layer];
    TRInt* variable_count = layer_variable_count[layer];
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        MDDArc* arc = [parentArcs at: parentIndex];
        MDDNode* parent = [arc parent];
        int arcValue = [arc arcValue];
        [parent removeChildAt:arcValue];
        //if (_inPost) {
        //    initial_variable_count[arcValue] -= 1;
        //} else {
            assignTRInt(&variable_count[arcValue], variable_count[arcValue]._val-1, _trail);
        //}
        if ([parent isChildless]) {
            highestLayerChanged = min(highestLayerChanged,[self removeChildlessNodeFromMDD:parent fromLayer:layer]);
        }
    }
    return highestLayerChanged;
}
-(void) removeParentlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer {
    if (layer == _numVariables) { failNow(); }
    MDDArc* *childrenArcs = [node children];
    int childLayer = layer+1;
    int numChildren = [node numChildren];
    TRInt* variable_count = layer_variable_count[layer];
    
    //Would it be better to have a collection of MDDArcs not indexed by domain value to improve this search?
    for (int child_index = _min_domain_for_layer[layer]; numChildren; child_index++) {
        MDDArc* childArc = childrenArcs[child_index];
        if (childArc != nil) {
            MDDNode* child = [childArc child];
            assignTRInt(&variable_count[child_index], variable_count[child_index]._val-1, _trail);
            if ([child numParents] == 1) {
                _removeParentlessNode(self,_removeParentlessSel,child,childLayer);
            } else {
                [child removeParentArc:childArc inPost:_inPost];
                if ([child isMergedNode]) {
                    [child setRecalcRequired:true];
                }
            }
            numChildren--;
        }
    }
    [self removeNode: node onLayer:layer];
    if (_lowestLayerChanged < childLayer) {
        _lowestLayerChanged = childLayer;
    }
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    ORTRIdArrayI* layer = layers[layer_index];
    int numEdgesToDelete = layer_variable_count[layer_index][value]._val;
    int highestLayerChanged = layer_index;
    int childLayer = layer_index+1;
    for (int node_index = 0; numEdgesToDelete; node_index++) {
        MDDNode* node = [layer at: node_index];
        MDDArc* childArc = [node children][value];
        if (childArc != NULL) {
            MDDNode* child = [childArc child];
            [node removeChildAt:value];
            [child removeParentArc:childArc inPost:_inPost];
            if ([child isParentless]) {
                _removeParentlessNode(self,_removeParentlessSel,child,childLayer);
                //lowestLayerChanged = max(lowestLayerChanged, [self removeParentlessNodeFromMDD:child fromLayer:(layer_index+1)]);
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
            MDDNode* node = [layers[layer] at: node_index];
            if (node != nil) {
                for (int child_index = _min_domain_for_layer[layer]; child_index <= _max_domain_for_layer[layer]; child_index++) {
                    MDDNode* child = [node children][child_index];
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
                MDDNode* node = [layers[layer_index] at: node_index];
                MDDNode** children = [node children];
                
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

@implementation CPMDDRestrictionWithArcs
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
    MDDNode* node = [self findNodeToRemove:layer];
    [self removeChildlessNodeFromMDD:node fromLayer:layer];
}
-(MDDNode*) findNodeToRemove:(int)layer
{
    return [layers[layer] at: 0];
}
-(NSString*)description
{
    return [NSMutableString stringWithFormat:@"<CPMDDRestriction:%02d %@>",_name,_x];
}
@end

@implementation CPMDDRelaxationWithArcs
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize {
    self = [super initCPMDD:engine over:x];
    _relaxation_size = relaxationSize;
    return self;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification*)spec {
    self = [super initCPMDD:engine over:x];
    _spec = [spec retain];
    _relaxation_size = relaxationSize;
    _hashWidth = relaxationSize * 2;
    [_spec finalizeSpec:_trail hashWidth:_hashWidth];
    _numBytes = [_spec numBytes];
    
    _hashValueFor = (HashValueIMP)[_spec methodForSelector:_hashValueSel];
    _canCreateState = (CanCreateStateIMP)[_spec methodForSelector:_canCreateStateSel];
    return self;
}
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value
{
    ORTRIdArrayI* layer = layers[layer_index];
    int numEdgesToDelete = layer_variable_count[layer_index][value]._val;
    int highestLayerChanged = layer_index;
    int childLayer = layer_index + 1;
    for (int node_index = 0; numEdgesToDelete; node_index++) {
        MDDNode* node = [layer at: node_index];
        MDDArc* childArc = [node children][value];
        if (childArc != NULL) {
            MDDNode* child = [childArc child];
            [node removeChildAt:value];
            [child removeParentArc:childArc inPost:_inPost];
            if ([child isParentless]) {
                _removeParentlessNode(self,_removeParentlessSel,child,childLayer);
                //lowestLayerChanged = max(lowestLayerChanged, [self removeParentlessNodeFromMDD:child fromLayer:(layer_index+1)]);
            } else if ([child isMergedNode]) {
                    [child setRecalcRequired:true];
            }
            if ([node isChildless]) {
                highestLayerChanged = min(highestLayerChanged, [self removeChildlessNodeFromMDD:node fromLayer:layer_index]);
                node_index--;
            }
            numEdgesToDelete--;
        }
    }
    _highestLayerChanged = min(_highestLayerChanged,highestLayerChanged);
    if (_lowestLayerChanged < childLayer) {
        _lowestLayerChanged = childLayer;
    }
    assignTRInt(&layer_variable_count[layer_index][value],0, _trail);
}
-(void) afterPropagation {
    [self rebuild];
}
-(void) rebuild
{
    void(*mth)(id,SEL,int) = [self methodForSelector:@selector(splitNodesOnLayer:)];
    for (int layer = _highestLayerChanged; layer <=  min(_lowestLayerChanged+1,(int)_numVariables-1); layer++) {
        mth(self,@selector(splitNodesOnLayer:),layer);
        if (layer_size[layer+1]._val == 0) {
            failNow();
        }
    }
    return;
}
-(void) splitNodesOnLayer:(int)layer
{
    //TODO:  Use BetterNodeHashTable if possible
    NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable:_hashWidth];
    int minDomain = _min_domain_for_layer[layer];
    int maxDomain = _max_domain_for_layer[layer];
    int initial_layer_size = layer_size[layer]._val;
    int variableIndex = [self variableIndexForLayer:layer];
    TRInt* variable_count = layer_variable_count[layer];
    int childLayer = layer + 1;
    bool addedNewNode,nodeHasChildren;
    for (int node_index = 0; node_index < initial_layer_size && layer_size[layer]._val < _relaxation_size; node_index++) {
        MDDNode* node = [layers[layer] at: node_index];
        if ([node isMergedNode]) { //Find a relaxed node to split
            addedNewNode = false;
            MDDArc** oldNodeChildren = [node children];
            ORTRIdArrayI* parents = [node parents];
            while ([node numParents] && layer_size[layer]._val < _relaxation_size) {
                MDDArc* parentArc = [parents at:0];
                MDDNode* parent = [parentArc parent];
                int arcValue = [parentArc arcValue];
                MDDStateValues* state = [self generateStateFromParent:parent assigningVariable:variableIndex withValue:arcValue];
                NSUInteger hashValue = [state hash];
                NSMutableArray* bucket = [nodeHashTable findBucketForStateHash:hashValue];
                MDDNode* newNode = (MDDNode*)[nodeHashTable nodeWithState:state inBucket:bucket];
                if (newNode == nil) {
                    newNode = [[MDDNode alloc] initNode: _trail
                                          minChildIndex:minDomain
                                          maxChildIndex:maxDomain
                                                  state:state
                                              hashWidth:_hashWidth];
                    
                    //New node copies children from node
                    nodeHasChildren = false;
                    for (int domain_val = minDomain; domain_val <= maxDomain; domain_val++) {
                        MDDArc* oldNodeChildArc = oldNodeChildren[domain_val];
                        if (oldNodeChildArc != nil) {
                            //Check if this arc should exist for the new state
                            if ([_spec canChooseValue:domain_val forVariable:variableIndex withState:state]) {
                                MDDNode* child = [oldNodeChildArc child];
                                [[MDDArc alloc] initArc:_trail from:newNode to:child value:domain_val inPost:_inPost];
                                assignTRInt(&variable_count[domain_val], variable_count[domain_val]._val+1, _trail);
                                [child setRecalcRequired:true];
                                _lowestLayerChanged = max(_lowestLayerChanged, childLayer);
                                nodeHasChildren = true;
                            }
                        }
                    }
                    if (nodeHasChildren) {
                        addedNewNode = true;
                        [self addNode:newNode toLayer:layer];
                        [[MDDArc alloc] initArc:_trail from:parent to:newNode value:arcValue inPost:_inPost];
                        //[_trail trailRelease:newNode];
                        [bucket addObject:newNode];
                    } else {
                        assignTRInt(&layer_variable_count[layer-1][arcValue], layer_variable_count[layer-1][arcValue]._val-1, _trail);
                        [parent removeChildAt:arcValue];
                        [newNode release];
                    }
                } else {
                    [[MDDArc alloc] initArc:_trail from:parent to:newNode value:arcValue inPost:_inPost];
                }
                [node removeParentArc:parentArc inPost:_inPost];
                [state release];
            }
            if (!addedNewNode) { //If the node was relaxed, but should be removed without any new nodes, need to decrement the for-loop counter
                for (int domain_val = _min_domain_for_layer[layer]; domain_val <= _max_domain_for_layer[layer]; domain_val++) {
                    MDDArc* oldNodeChildArc = oldNodeChildren[domain_val];
                    if (oldNodeChildArc != nil) {
                        MDDNode* child = [oldNodeChildArc child];
                        assignTRInt(&variable_count[domain_val], variable_count[domain_val]._val-1, _trail);
                        [node removeChildAt:domain_val];
                        [child removeParentArc:oldNodeChildArc inPost:_inPost];
                    }
                }
                [self removeNodeAt:node_index onLayer:layer];
                node_index--;
                initial_layer_size--;
            } else if ([node isParentless]) {
                for (int domain_val = _min_domain_for_layer[layer]; domain_val <= _max_domain_for_layer[layer]; domain_val++) {
                    MDDArc* oldNodeChildArc = oldNodeChildren[domain_val];
                    if (oldNodeChildArc != NULL) {
                        MDDNode* child = [oldNodeChildArc child];
                        assignTRInt(&variable_count[domain_val], variable_count[domain_val]._val-1, _trail);
                        //[node removeChildAt:domain_val];
                        [child removeParentArc:oldNodeChildArc inPost:_inPost];
                    }
                }
                [self removeNodeAt:node_index onLayer:layer];
            } else {
                [node setRecalcRequired:true];
            }
        }
    }

    //Does it actually have to check this so thoroughly each time?
    for (int node_index = 0; node_index < layer_size[childLayer]._val; node_index++) {
        MDDNode* node = [layers[childLayer] at: node_index];
        if ([node isParentless]) {
            _removeParentlessNode(self,_removeParentlessSel,node,childLayer);
            //_lowestLayerChanged = max(_lowestLayerChanged,[self removeParentlessNodeFromMDD:node fromLayer:childLayer]);
            node_index--;
        }
    }
    for (int node_index = 0; node_index < layer_size[layer]._val; node_index++) {
        OldNode* node = [layers[layer] at: node_index];
        if ([node isChildless]) {
            [self removeChildlessNodeFromMDDAtIndex:node_index fromLayer:layer];
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
    int parentLayer = layer_index-1;
    for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
        MDDNode* node = [layerArray at:node_index];
        if ([node recalcRequired]) {
            bool isMergedNode;
            MDDStateValues* oldState = getState(node);
            MDDStateValues* newState = [self calculateStateFromParentsOf:node onLayer:parentLayer isMerged:&isMergedNode];
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
-(MDDStateValues*) calculateStateFromParentsOf:(MDDNode*)node onLayer:(int)layer isMerged:(bool*)isMergedNode
{
    MDDStateValues* newState = nil;
    *isMergedNode = false;
    ORTRIdArrayI* parents = [node parents];
    int variableIndex = [self variableIndexForLayer:layer];
    for (int parent_index = 0; parent_index < [node numParents]; parent_index++) {
        MDDArc* parentArc = [parents at:parent_index];
        MDDNode* parent = [parentArc parent];
        int arcValue = [parentArc arcValue];
        MDDStateValues* tempState = [self generateTempStateFromParent:parent assigningVariable:variableIndex withValue:arcValue];
        if (newState == nil) {
            newState = tempState;
        } else {
            if (![newState isEqual:tempState]) {
                *isMergedNode = true;
                [_spec mergeState:newState with:tempState];
            }
            [tempState release];
        }
    }
    return newState;
}
-(void) reevaluateChildrenAfterParentStateChange:(MDDNode*)node onLayer:(int)layer_index andVariable:(int)variableIndex
{
    MDDArc* *childrenArcs = [node children];
    MDDStateValues* nodeState = getState(node);
    TRInt* variable_count = layer_variable_count[layer_index];
    int childLayer = layer_index+1;
    for (int child_index = _min_domain_for_layer[layer_index]; child_index <= _max_domain_for_layer[layer_index]; child_index++) {
        MDDArc* childArc = childrenArcs[child_index];
        if (childArc != NULL) {
            MDDNode* child = [childArc child];
            if ([_spec canChooseValue:child_index forVariable:variableIndex withState:nodeState]) {
                [child setRecalcRequired:true];
            } else {
                [node removeChildAt:child_index];
                [child removeParentArc:childArc inPost:_inPost];
                assignTRInt(&variable_count[child_index], variable_count[child_index]._val-1, _trail);
                if ([child isParentless]) {
                    _removeParentlessNode(self,_removeParentlessSel,child,childLayer);
                    //[self removeParentlessNodeFromMDD:child fromLayer:childLayer];
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
        MDDNode* first_node = [layerNodes at: best_first_node_index];
        MDDNode* second_node = [layerNodes at: best_second_node_index];
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
        MDDStateValues* first_node_state = getState([layerNodes at: first_node_index]);
        for (second_node_index = first_node_index +1; second_node_index < ls; second_node_index++) {
            MDDStateValues* second_node_state = getState([layerNodes at: second_node_index]);
            int state_differential = [_spec stateDifferential:first_node_state with:second_node_state];
            similarityMatrix[first_node_index][second_node_index] = state_differential;
        }
    }
    return similarityMatrix;
}
-(void) updateSimilarityMatrix:(int**)similarityMatrix afterMerging:(int)best_second_node_index into:(int)best_first_node_index onLayer:(int)layer
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

