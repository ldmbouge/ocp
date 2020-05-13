/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngineI.h>
#import "CPDualDirectionalMDD.h"
#import "CPIntVarI.h"

static inline id getTopDownState(MDDNode* n) { return n->_topDownState;}
static inline id getBottomUpState(MDDNode* n) { return n->_bottomUpState;}
@implementation CPDualDirectionalMDD
-(id) initCPDualDirectionalMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec equalBuckets:(bool)equalBuckets usingSlack:(bool)usingSlack recommendationStyle:(MDDRecommendationStyle)recommendationStyle gamma:(id*)gamma {
    self = [super initCPMDDRelaxation:engine over:x relaxationSize:relaxationSize spec:spec equalBuckets:equalBuckets usingSlack:usingSlack recommendationStyle:recommendationStyle gamma:gamma];
    _numBottomUpBytes = [_spec numBottomUpBytes];
    return self;
}

-(MDDNode*) createNode:(MDDStateValues*)state minDomain:(int)minDomain maxDomain:(int)maxDomain {
    return [[_nodeClass alloc] initNode:_trail minChildIndex:minDomain maxChildIndex:maxDomain state:state hashWidth:_hashWidth numBottomUpBytes:_numBottomUpBytes];
}

-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    MDDStateValues* childState = getTopDownState(child);
    if (childState == nil) {
        [[MDDArc alloc] initArcToSink:_trail from:parent to:child value:value inPost:_inPost numBottomUpBytes:_numBottomUpBytes];
    } else {
        char* arcState = malloc(_numTopDownBytes * sizeof(char));
        memcpy(arcState, [childState stateValues], _numTopDownBytes);
        [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:arcState numTopDownBytes:_numTopDownBytes numBottomUpBytes:_numBottomUpBytes];
    }
}
-(void) recalcBottomUpArcCache:(MDDArc*)arc childTopDown:(char*)childTopDown childBottomUp:(char*)childBottomUp variable:(int)variable {
    char* arcState = arc.topDownState;
    int value = arc.arcValue;
    ORIntSetI* valueSet = [[ORIntSetI alloc] initORIntSetI];
    [valueSet insert:value];
    bool stateChanged = false;
    int numProperties = [_spec numBottomUpProperties];
    DDArcSetTransitionClosure* transitionFunctions = [_spec bottomUpTransitionFunctions];
    char* newState = malloc(_numBottomUpBytes * sizeof(char));
    if ([_spec numSpecs] == 1) {
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            transitionFunctions[propertyIndex](newState, childTopDown, childBottomUp, variable, valueSet);
        }
    } else {
        memcpy(newState, childBottomUp, _numBottomUpBytes);
        bool* propertyUsed = [_spec bottomUpPropertiesUsed:variable];
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                transitionFunctions[propertyIndex](newState, childTopDown, childBottomUp, variable, valueSet);
            }
        }
    }
    stateChanged = arcState == nil || memcmp(arcState, newState, _numBottomUpBytes) != 0;
    if (stateChanged) {
        [arc replaceBottomUpStateWith:newState trail:_trail];
        [[arc parent] setBottomUpRecalcRequired:true];
    }
    [valueSet release];
    free(newState);
}
-(bool) splitNodesOnLayer:(int)layer {
    bool changed = false;
    BetterNodeHashTable* nodeHashTable = [[BetterNodeHashTable alloc] initBetterNodeHashTable:_hashWidth numBytes:_numTopDownBytes];
    SEL hasNodeSel = @selector(hasNodeWithStateProperties:hash:node:);
    HasNodeIMP hasNode = (HasNodeIMP)[nodeHashTable methodForSelector:hasNodeSel];
    int minDomain = _min_domain_for_layer[layer];
    int maxDomain = _max_domain_for_layer[layer];
    int layerSize = layer_size[layer]._val;
    int childLayer = layer+1;
    int parentLayer = layer-1;
    int variableIndex = _layer_to_variable[layer];
    ORTRIdArrayI* layerNodes = [self getLayer:layer];
    TRInt* variableCount = layer_variable_count[layer];
    TRInt* parentVariableCount = layer_variable_count[parentLayer];
    bool nodeHasChildren;
    for (int nodeIndex = 0; nodeIndex < layerSize && layer_size[layer]._val < _relaxation_size; nodeIndex++) {
        MDDNode* node = [layerNodes at:nodeIndex];
        if ([node isMerged]) {
            changed = true;
            MDDArc** existingNodeChildrenArcs = [node children];
            ORTRIdArrayI* parentArcs = [node parents];
            while ([node numParents] && layer_size[layer]._val < _relaxation_size) {
                MDDArc* parentArc = [parentArcs at:0];
                MDDNode* parent = [parentArc parent];
                int arcValue = [parentArc arcValue];
                
                [node removeParentArc:parentArc inPost:_inPost];
                char* arcState = [parentArc topDownState];
                
                NSUInteger hashValue = _hashValueFor(_spec, _hashValueSel, arcState);
                MDDNode* newNode;
                bool nodeExists = hasNode(nodeHashTable, hasNodeSel, arcState, hashValue, &newNode);
                if (!nodeExists) {
                    char* newProperties = malloc(_numTopDownBytes * sizeof(char));
                    memcpy(newProperties, arcState, _numTopDownBytes);
                    MDDStateValues* newState = [[MDDStateValues alloc] initState:newProperties numBytes:_numTopDownBytes hashWidth:_hashWidth trail:_trail];
                    newNode = [[MDDNode alloc] initNode:_trail minChildIndex:minDomain maxChildIndex:maxDomain state:newState hashWidth:_hashWidth numBottomUpBytes:_numBottomUpBytes];
                    
                    nodeHasChildren = false;
                    for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
                        MDDArc* existingChildArc = existingNodeChildrenArcs[domainVal];
                        if (existingChildArc != nil) {
                            MDDNode* child = [existingChildArc child];
                            char* childBottomUp = [(MDDStateValues*)getBottomUpState(child) stateValues];
                            if ([_spec canChooseValue:domainVal forVariable:variableIndex fromParent:newProperties toChild:childBottomUp objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
                                if (!nodeHasChildren) {
                                    [_trail trailRelease:newNode];
                                    [_trail trailRelease:newState];
                                    //Need to make sure newNode is on trailRelease since its inner values are about to be changed (which are trailables)
                                }
                                if (childLayer == (int)_numVariables) {
                                    /*char* childTopDown = [(MDDStateValues*)getTopDownState(child) stateValues];
                                    [self recalcBottomUpArcCache:*/
                                    [[MDDArc alloc] initArcToSink:_trail from:newNode to:child value:domainVal inPost:_inPost numBottomUpBytes:_numBottomUpBytes]/* childTopDown:childTopDown childBottomUp:childBottomUp variable:variableIndex]*/;
                                } else {
                                    [[MDDArc alloc] initArc:_trail from:newNode to:child value:domainVal inPost:_inPost state:_computeStateFromProperties(_spec, _computeStateFromPropertiesSel, newProperties, variableIndex, domainVal) numTopDownBytes:_numTopDownBytes numBottomUpBytes:_numBottomUpBytes];
                                    
                                    [child setTopDownRecalcRequired:true];
                                }
                                assignTRInt(&variableCount[domainVal], variableCount[domainVal]._val+1, _trail);
                                nodeHasChildren = true;
                            }
                        }
                    }
                    if (nodeHasChildren) {
                        _lowestLayerChanged = max(_lowestLayerChanged, childLayer);
                        [self addNode:newNode toLayer:layer];
                        [parentArc setChild:newNode inPost:_inPost];
                        [parentArc updateParentArcIndex:0 inPost:_inPost];
                        [[parentArc parent] setBottomUpRecalcRequired:true];
                        [newNode addParent:parentArc inPost:_inPost];
                        [nodeHashTable addState:newState];
                    } else {
                        assignTRInt(&parentVariableCount[arcValue], parentVariableCount[arcValue]._val-1, _trail);
                        [parent removeChildAt:arcValue inPost:_inPost];
                        if ([parent isChildless]) {
                            [self removeChildlessNodeFromMDD:parent fromLayer:parentLayer];
                        } else {
                            [parent setBottomUpRecalcRequired:true];
                        }
                        [newNode release];
                        [newState release];
                    }
                } else {
                    [parentArc setChild:newNode inPost:_inPost];
                    [[parentArc parent] setBottomUpRecalcRequired:true];
                    [parentArc updateParentArcIndex:[newNode numParents] inPost:_inPost];
                    [newNode addParent:parentArc inPost:_inPost];
                }
            }
            //If the node still has parents, it means the relaxation size was hit.  Check if any arcs that would lead exactly to a newly created state can be transferred (aka arcs that were initially grouped in the reduction)
            if ([node numParents]) {
                int numParents = [node numParents];
                for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
                    MDDArc* parentArc = [parentArcs at:parentIndex];
                    char* arcState = [parentArc topDownState];
                    NSUInteger hashValue = _hashValueFor(_spec, _hashValueSel, arcState);
                    MDDNode* existingNode;
                    bool nodeExists = hasNode(nodeHashTable, hasNodeSel, arcState, hashValue, &existingNode);
                    if (nodeExists) {
                        [node removeParentArc:parentArc inPost:_inPost];
                        [parentArc setChild:existingNode inPost:_inPost];
                        [[parentArc parent] setBottomUpRecalcRequired:true];
                        [parentArc updateParentArcIndex:[existingNode numParents] inPost:_inPost];
                        [existingNode addParent:parentArc inPost:_inPost];
                        [[parentArc parent] setBottomUpRecalcRequired:true];
                        parentIndex--;
                        numParents--;
                    }
                }
            }
            //If after all of this, the node is parentless, we can remove it.  This means we will need to keep looping (because a node was just removed on this layer), so make sure the loop is going over the correct indices
            if ([node isParentless]) {
                _removeParentlessNode(self, _removeParentlessSel, node, layer);
                nodeIndex--;
                layerSize--;
            } else {
                //Otherwise, the node still has parents and we hit relaxation size.  The layer has been fully split.  Mark that the node will need its value recalculated since it lost parents.
                [node setTopDownRecalcRequired:true];
                [node setBottomUpRecalcRequired:true];
            }
        }
    }
    [nodeHashTable release];
    return changed;
}
-(char*) calculateStateFromCachelessChildrenOf:(MDDNode*)node onLayer:(int)layer {
    int variableIndex = _layer_to_variable[layer];
    int numChildren = [node numChildren];
    TRId* childArcs = [node children];
    int maxNumChildren = min(numChildren,layer_size[layer+1]._val);
    MDDNode** childNodes = malloc(maxNumChildren * sizeof(MDDNode*));
    ORIntSetI** arcValuesToChild = malloc(maxNumChildren * sizeof(ORIntSetI*));
    int numChildNodes = 0;
    for (int childIndex = _min_domain_for_layer[layer]; numChildren; childIndex++) {
        if (childArcs[childIndex] != nil) {
            MDDArc* childArc = childArcs[childIndex];
            int arcValue = [childArc arcValue];
            MDDNode* child = [childArc child];
            //TODO: Use hash instead
            bool foundChild = false;
            for (int i = 0; i < numChildNodes; i++) {
                if (childNodes[i] == child) {
                    [arcValuesToChild[i] insert:arcValue];
                    foundChild = true;
                    break;
                }
            }
            if (!foundChild) {
                childNodes[numChildNodes] = child;
                arcValuesToChild[numChildNodes] = [[ORIntSetI alloc] initORIntSetI];
                [arcValuesToChild[numChildNodes] insert:arcValue];
                numChildNodes++;
            }
            numChildren--;
        }
    }
    MDDNode* firstChildNode = childNodes[0];
    char* firstChildTopDown = [getTopDownState(firstChildNode) stateValues];
    char* firstChildBottomUp = [getBottomUpState(firstChildNode) stateValues];
    ORIntSetI* firstValueSet = arcValuesToChild[0];
    char* newStateProperties = [_spec computeBottomUpStateFromProperties:firstChildTopDown bottomUp:firstChildBottomUp assigningVariable:variableIndex withValues:firstValueSet];
    for (int childNodeIndex = 1; childNodeIndex < numChildNodes; childNodeIndex++) {
        MDDNode* childNode = childNodes[0];
        char* childTopDown = [getTopDownState(childNode) stateValues];
        char* childBottomUp = [getBottomUpState(childNode) stateValues];
        ORIntSetI* valueSet = arcValuesToChild[childNodeIndex];
        char* otherStateProperties = [_spec computeBottomUpStateFromProperties:childTopDown bottomUp:childBottomUp assigningVariable:variableIndex withValues:valueSet];
        [_spec mergeTempBottomUpStateProperties:newStateProperties with:otherStateProperties];
        free(otherStateProperties);
    }
    for (int i = 0; i < numChildNodes; i++) {
        [arcValuesToChild[i] release];
    }
    free(childNodes);
    free(arcValuesToChild);
    return newStateProperties;
}
-(void) performBottomUpWithoutCache {
    if (![_spec dualDirectional]) return;
    
    bool changedLayer;
    int highestLayer = INT_MAX, lowestLayer = INT_MIN;
    for (int layer_index = (int)_numVariables-1; layer_index > 0; layer_index--) {
        changedLayer = false;
        ORTRIdArrayI* layer = [self getLayer:layer_index];
        int layerSize = layer_size[layer_index]._val;
        for (int node_index = 0; node_index < layerSize; node_index++) {
            MDDNode* node = [layer at:node_index];
            //Recalc node's bottom-up info if needed
            if ([node bottomUpRecalcRequired]) {
                ORTRIdArrayI* parents = [node parents];
                int numParents = [node numParents];
                char* bottomUpStateValues = [self calculateStateFromCachelessChildrenOf:node onLayer:layer_index];
                char* oldValues = [getBottomUpState(node) stateValues];
                if (memcmp(oldValues, bottomUpStateValues, _numBottomUpBytes) != 0) {
                    changedLayer = true;
                    [node updateBottomUpState:bottomUpStateValues];
                    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
                        MDDArc* parentArc = [parents at:parentIndex];
                        [[parentArc parent] setBottomUpRecalcRequired:true];
                    }
                }
                free(bottomUpStateValues);
                [node setBottomUpRecalcRequired:false];
            }
        }
        if (changedLayer) {
            highestLayer = layer_index-1;
            if (lowestLayer == INT_MIN) {
                lowestLayer = layer_index+1;
            }
        }
    }
    _highestLayerChanged = min(_highestLayerChanged, highestLayer);
    _lowestLayerChanged = max(_lowestLayerChanged, lowestLayer);
}
-(char*) calculateStateFromChildrenOf:(MDDNode*)node onLayer:(int)layer {
    int numChildren = [node numChildren];
    TRId* childArcs = [node children];
    char* newStateProperties = malloc(_numBottomUpBytes * sizeof(char));
    bool first = true;
    for (int childIndex = _min_domain_for_layer[layer]; numChildren; childIndex++) {
        if (childArcs[childIndex] != nil) {
            MDDArc* childArc = childArcs[childIndex];
            char* passedBottomUpState = [childArc bottomUpState];
            if (first) {
                memcpy(newStateProperties, passedBottomUpState, _numBottomUpBytes);
                first = false;
            } else {
                [_spec mergeTempBottomUpStateProperties:newStateProperties with:passedBottomUpState];
            }
            numChildren--;
        }
    }
    return newStateProperties;
}
-(void) performBottomUpWithCache {
    if (![_spec dualDirectional]) return;
    MDDNode* sink = [[self getLayer:(int)_numVariables] at:0];
    if ([sink bottomUpRecalcRequired]) {
        char* sinkTopDown = [(MDDStateValues*)getTopDownState(sink) stateValues];
        char* sinkBottomUp = [(MDDStateValues*)getBottomUpState(sink) stateValues];
        ORTRIdArrayI* sinkArcs = [sink parents];
        int numSinkArcs = [sink numParents];
        for (int sinkArcIndex = 0; sinkArcIndex < numSinkArcs; sinkArcIndex++) {
            MDDArc* sinkArc = [sinkArcs at:sinkArcIndex];
            [self recalcBottomUpArcCache:sinkArc childTopDown:sinkTopDown childBottomUp:sinkBottomUp variable:[self variableIndexForLayer:(int)_numVariables-1]];
        }
        [sink setBottomUpRecalcRequired:false];
    }
    for (int layer_index = (int)_numVariables-1; layer_index > 0; layer_index--) {
        ORTRIdArrayI* layer = [self getLayer:layer_index];
        int layerSize = layer_size[layer_index]._val;
        int variableIndex = _layer_to_variable[layer_index-1];
        
        for (int node_index = 0; node_index < layerSize; node_index++) {
            MDDNode* node = [layer at:node_index];
            //Recalc node's bottom-up info if needed
            if ([node bottomUpRecalcRequired]) {
                char* nodeTopDownState = [(MDDStateValues*)getTopDownState(node) stateValues];
                ORTRIdArrayI* parents = [node parents];
                int numParents = [node numParents];
                char* bottomUpStateValues = [self calculateStateFromChildrenOf:node onLayer:layer_index];
                char* oldValues = [getBottomUpState(node) stateValues];
                if (memcmp(oldValues, bottomUpStateValues, _numBottomUpBytes) != 0) {
                    [node updateBottomUpState:bottomUpStateValues];
                    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
                        MDDArc* parentArc = [parents at:parentIndex];
                        [self recalcBottomUpArcCache:parentArc childTopDown:nodeTopDownState childBottomUp:bottomUpStateValues variable:variableIndex];
                    }
                }
                free(bottomUpStateValues);
                [node setBottomUpRecalcRequired:false];
            }
        }
    }
}

-(bool) reevaluateChildrenAfterParentStateChange:(MDDNode*)node onLayer:(int)layer_index andVariable:(int)variableIndex {
    bool changed = false;
    TRId* children = [node children];
    MDDStateValues* nodeState = getTopDownState(node);
    char* nodeProperties = [nodeState stateValues];
    TRInt* variable_count = layer_variable_count[layer_index];
    int childLayer = layer_index+1;
    int maxDomain = _max_domain_for_layer[layer_index];
    for (int child_index = _min_domain_for_layer[layer_index]; child_index <= maxDomain; child_index++) {
        MDDArc* child = children[child_index];
        if (child != nil) {
            if ([_spec canChooseValue:child_index forVariable:variableIndex fromParent:nodeProperties toChild:[getBottomUpState([child child]) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
                if (childLayer != (int)_numVariables) {
                    [self recalcArc:child parentProperties:nodeProperties variable:variableIndex];
                }
            } else {
                [node removeChildAt:child_index inPost:_inPost];
                [node setBottomUpRecalcRequired:true];
                [child removeParent:node inPost:_inPost];
                assignTRInt(&variable_count[child_index], variable_count[child_index]._val-1, _trail);
                if ([child isParentless]) {
                    [self removeParentlessFromMDD:child fromLayer:childLayer];
                } else {
                    [child setTopDownRecalcRequired:true];
                }
                changed = true;
            }
        }
    }
    return changed;
}
-(int) checkParentsOfChildlessNode:(MDDNode*)node parentLayer:(int)layer {
    int numParents = [node numParents];
    ORTRIdArrayI* parents = [node parents];
    int highestLayerChanged = layer;
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parents at: parentIndex];
        MDDNode* parent = [parentArc parent];
        [self removeChild:node fromParent:parentArc parentLayer:layer];
        if ([parent isChildless]) {
            highestLayerChanged = min(highestLayerChanged,[self removeChildlessNodeFromMDD:parent fromLayer:layer]);
        } else {
            [parent setBottomUpRecalcRequired:true];
        }
    }
    return highestLayerChanged;
}
-(bool) afterPropagation {
    [self performBottomUpWithoutCache];
    return [super afterPropagation];
}

-(bool) recheckArcsWithParentLayer:(int)layer_index {
    bool changed = false;
    int variableIndex = _layer_to_variable[layer_index];
    int childLayerIndex = layer_index+1;
    ORTRIdArrayI* childLayer = [self getLayer:childLayerIndex];
    int childLayerSize = layer_size[childLayerIndex]._val;
    TRInt* variableCount = layer_variable_count[layer_index];
    for (int child_index = 0; child_index < childLayerSize; child_index++) {
        MDDNode* child = [childLayer at:child_index];
        ORTRIdArrayI* parentArcs = [child parents];
        int numParents = [child numParents];
        char* childState = [getBottomUpState(child) stateValues];
        for (int parent_index = 0; parent_index < numParents; parent_index++) {
            MDDArc* parentArc = [parentArcs at:parent_index];
            MDDNode* parent = [parentArc parent];
            if (_objectiveBoundsChanged || [parent topDownStateChanged] || [child bottomUpStateChanged]) {
                char* parentState = [getTopDownState(parent) stateValues];
                int arcValue = [parentArc arcValue];
                if ([_spec canChooseValue:arcValue forVariable:variableIndex fromParent:parentState toChild:childState objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
                    if (childLayerIndex != (int)_numVariables && ([parent topDownStateChanged] || [child bottomUpStateChanged])) {
                        [self recalcArc:parentArc parentProperties:parentState variable:variableIndex];
                    }
                } else {
                    numParents--;
                    parent_index--;
                    [parent removeChildAt:arcValue inPost:_inPost];
                    [child removeParentArc:parentArc inPost:_inPost];
                    assignTRInt(&variableCount[arcValue], variableCount[arcValue]._val-1, _trail);
                    [parent setBottomUpRecalcRequired:true];
                    [child setTopDownRecalcRequired:true];
                    changed = true;
                }
            }
        }
    }
    [self removeParentlessAndChildlessNodesWithParentLayer:layer_index];
    return changed;
}
-(void) recalcArc:(MDDArc*)arc parentProperties:(char*)parentProperties variable:(int)variable {
    char* bottomUp = [getBottomUpState([arc parent]) stateValues];
    char* arcState = arc.topDownState;
    int value = arc.arcValue;
    bool stateChanged = false;
    int numProperties = [_spec numTopDownProperties];
    DDArcTransitionClosure* transitionFunctions = [_spec topDownTransitionFunctions];
    char* newState = malloc(_numTopDownBytes * sizeof(char));
    if ([_spec numSpecs] == 1) {
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            transitionFunctions[propertyIndex](newState, parentProperties, bottomUp, variable, value);
        }
    } else {
        memcpy(newState, parentProperties, _numTopDownBytes);
        bool* propertyUsed = [_spec topDownPropertiesUsed:variable];
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                transitionFunctions[propertyIndex](newState, parentProperties, bottomUp, variable, value);
            }
        }
    }
    stateChanged = memcmp(arcState, newState, _numTopDownBytes) != 0;
    if (stateChanged) {
        [arc replaceTopDownStateWith:newState trail:_trail];
        [[arc child] setTopDownRecalcRequired:true];
    }
    free(newState);
}
@end
