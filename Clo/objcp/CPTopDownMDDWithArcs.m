/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "CPTopDownMDDWithArcs.h"

static inline id getTopDownState(MDDNode* n) { return n->_topDownState;}
static inline id getBottomUpState(MDDNode* n) { return n->_bottomUpState;}
@implementation CPMDDWithArcs
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x spec:(MDDStateSpecification *)spec {
    self = [super initCPMDD:engine over:x spec:spec];
    _nodeClass = [MDDNode class];
    return self;
}
-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:[(MDDStateValues*)getTopDownState(child) stateValues] numTopDownBytes:_numTopDownBytes numBottomUpBytes:_numBottomUpBytes];
}
-(void) removeParentlessFromMDD:(MDDArc*)child fromLayer:(int)childLayer {
    [self removeParentlessNodeFromMDD:[child child] fromLayer:childLayer];
}
-(int) removeChildlessFromMDD:(MDDArc*)parent fromLayer:(int)layer {
    return [self removeChildlessNodeFromMDD:[parent parent] fromLayer:layer];
}
-(void) removeChild:(MDDNode*)node fromParent:(MDDArc*)parent parentLayer:(int)parentLayer {
    int arcValue = [parent arcValue];
    TRInt* variableCount = layer_variable_count[parentLayer];
    [[parent parent] removeChildAt:arcValue inPost:_inPost];
    assignTRInt(&variableCount[arcValue], variableCount[arcValue]._val-1, _trail);
}
-(bool) parentIsChildless:(MDDArc*)parent {
    return [[parent parent] isChildless];
}
-(char*) childState:(MDDArc*) child {
    return [(MDDStateValues*)[[child child] getState] stateValues];
}
@end

@implementation CPMDDRestrictionWithArcs
-(id) initCPMDDRestriction:(id<CPEngine>)engine over:(id<CPIntVarArray>)x restrictionSize:(ORInt)restrictionSize {
    self = [super initCPMDDRestriction:engine over:x restrictionSize:restrictionSize];
    _nodeClass = [MDDNode class];
    return self;
}
-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:[(MDDStateValues*)getTopDownState(child) stateValues] numTopDownBytes:_numTopDownBytes numBottomUpBytes:_numBottomUpBytes];
}
-(void) removeParentlessFromMDD:(MDDArc*)child fromLayer:(int)childLayer {
    [self removeParentlessNodeFromMDD:[child child] fromLayer:childLayer];
}
-(int) removeChildlessFromMDD:(MDDArc*)parent fromLayer:(int)layer {
    return [self removeChildlessNodeFromMDD:[parent parent] fromLayer:layer];
}
-(void) removeChild:(MDDNode*)node fromParent:(MDDArc*)parent parentLayer:(int)parentLayer {
    int arcValue = [parent arcValue];
    TRInt* variableCount = layer_variable_count[parentLayer];
    [[parent parent] removeChildAt:arcValue inPost:_inPost];
    assignTRInt(&variableCount[arcValue], variableCount[arcValue]._val-1, _trail);
}
-(bool) parentIsChildless:(MDDArc*)parent {
    return [[parent parent] isChildless];
}
-(char*) childState:(MDDArc*) child {
    return [(MDDStateValues*)[[child child] getState] stateValues];
}
@end

@implementation CPMDDRelaxationWithArcs
-(id) initCPMDDRelaxation:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec equalBuckets:(bool)equalBuckets usingSlack:(bool)usingSlack recommendationStyle:(MDDRecommendationStyle)recommendationStyle {
    self = [super initCPMDDRelaxation:engine over:x relaxationSize:relaxationSize spec:spec equalBuckets:equalBuckets usingSlack:usingSlack recommendationStyle:recommendationStyle];
    _nodeClass = [MDDNode class];
    return self;
}
-(void) recalcArc:(MDDArc*)arc parentProperties:(char*)parentProperties variable:(int)variable {
    char* arcState = arc.topDownState;
    int value = arc.arcValue;
    bool stateChanged = false;
    int numProperties = [_spec numTopDownProperties];
    DDArcTransitionClosure* transitionFunctions = [_spec topDownTransitionFunctions];
    char* newState = malloc(_numTopDownBytes * sizeof(char));
    if ([_spec numSpecs] == 1) {
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            transitionFunctions[propertyIndex](newState, parentProperties, variable, value);
        }
    } else {
        memcpy(newState, parentProperties, _numTopDownBytes);
        bool* propertyUsed = [_spec topDownPropertiesUsed:variable];
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                transitionFunctions[propertyIndex](newState, parentProperties, variable, value);
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
-(void) recalcArc:(MDDArc*)arc childProperties:(char*)childProperties variable:(int)variable {
    char* arcState = arc.topDownState;
    int value = arc.arcValue;
    bool stateChanged = false;
    int numProperties = [_spec numBottomUpProperties];
    DDArcTransitionClosure* transitionFunctions = [_spec bottomUpTransitionFunctions];
    char* newState = malloc(_numBottomUpBytes * sizeof(char));
    if ([_spec numSpecs] == 1) {
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            transitionFunctions[propertyIndex](newState, childProperties, variable, value);
        }
    } else {
        memcpy(newState, childProperties, _numBottomUpBytes);
        bool* propertyUsed = [_spec bottomUpPropertiesUsed:variable];
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                transitionFunctions[propertyIndex](newState, childProperties, variable, value);
            }
        }
    }
    stateChanged = arcState == nil || memcmp(arcState, newState, _numBottomUpBytes) != 0;
    if (stateChanged) {
        [arc replaceBottomUpStateWith:newState trail:_trail];
        [[arc parent] setBottomUpRecalcRequired:true];
    }
    free(newState);
}
-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    MDDStateValues* childState = getTopDownState(child);
    if (childState == nil) {
        [self recalcArc:[[MDDArc alloc] initArcToSink:_trail from:parent to:child value:value inPost:_inPost numBottomUpBytes:_numBottomUpBytes] childProperties:[getBottomUpState(child) stateValues] variable:_layer_to_variable[_numVariables-1]];
    } else {
        char* arcState = malloc(_numTopDownBytes * sizeof(char));
        memcpy(arcState, [childState stateValues], _numTopDownBytes);
        [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:arcState numTopDownBytes:_numTopDownBytes numBottomUpBytes:_numBottomUpBytes];
    }
}
-(void) removeParentlessFromMDD:(MDDArc*)child fromLayer:(int)childLayer {
    [self removeParentlessNodeFromMDD:[child child] fromLayer:childLayer];
}
-(int) removeChildlessFromMDD:(MDDArc*)parent fromLayer:(int)layer {
    return [self removeChildlessNodeFromMDD:[parent parent] fromLayer:layer];
}
-(void) removeChild:(MDDNode*)node fromParent:(MDDArc*)parent parentLayer:(int)parentLayer {
    int arcValue = [parent arcValue];
    TRInt* variableCount = layer_variable_count[parentLayer];
    [[parent parent] removeChildAt:arcValue inPost:_inPost];
    assignTRInt(&variableCount[arcValue], variableCount[arcValue]._val-1, _trail);
}
-(bool) parentIsChildless:(MDDArc*)parent {
    return [[parent parent] isChildless];
}
-(void) splitNodesOnLayer:(int)layer {
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
                    newNode = [[MDDNode alloc] initNode:_trail minChildIndex:minDomain maxChildIndex:maxDomain state:newState hashWidth:_hashWidth];
                    
                    nodeHasChildren = false;
                    for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
                        MDDArc* existingChildArc = existingNodeChildrenArcs[domainVal];
                        if (existingChildArc != nil) {
                            char* childState = [(MDDStateValues*)getBottomUpState([existingChildArc child]) stateValues];
                            if ([_spec canChooseValue:domainVal forVariable:variableIndex fromParent:newProperties toChild:childState]) {
                                if (!nodeHasChildren) {
                                    [_trail trailRelease:newNode];
                                    [_trail trailRelease:newState];
                                    //Need to make sure newNode is on trailRelease since its inner values are about to be changed (which are trailables)
                                }
                                MDDNode* child = [existingChildArc child];
                                if (childLayer == (int)_numVariables) {
                                    [self recalcArc:[[MDDArc alloc] initArcToSink:_trail from:newNode to:child value:domainVal inPost:_inPost numBottomUpBytes:_numBottomUpBytes] childProperties:childState variable:variableIndex];
                                } else {
                                    [self recalcArc:[[MDDArc alloc] initArc:_trail from:newNode to:child value:domainVal inPost:_inPost state:_computeStateFromProperties(_spec, _computeStateFromPropertiesSel, newProperties, variableIndex, domainVal) numTopDownBytes:_numTopDownBytes numBottomUpBytes:_numBottomUpBytes] childProperties:childState variable:variableIndex];
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
}
-(char*) calculateStateFromParentsOf:(MDDNode*)node onLayer:(int)layer isMerged:(bool*)isMergedNode {
    *isMergedNode = false;
    int numParents = [node numParents];
    ORTRIdArrayI* parentArcs = [node parents];
    char* newStateProperties = malloc(_numTopDownBytes * sizeof(char));
    MDDArc* firstParentArc = [parentArcs at:0];
    memcpy(newStateProperties, [firstParentArc topDownState], _numTopDownBytes);
    for (int parentIndex = 1; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        char* arcState = [parentArc topDownState];
        if (*isMergedNode) {
            [_spec mergeTempStateProperties:newStateProperties with:arcState];
        } else if (memcmp(newStateProperties, arcState, _numTopDownBytes) != 0) {
            *isMergedNode = true;
            [_spec mergeTempStateProperties:newStateProperties with:arcState];
        }
    }
    return newStateProperties;
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
-(void) recalcFor:(MDDArc*)child parentProperties:(char*)nodeProperties variable:(int)variableIndex {
    [self recalcArc:child parentProperties:nodeProperties variable:variableIndex];
}
-(char*) childState:(MDDArc*) child {
    return [(MDDStateValues*)[[child child] getState] stateValues];
}
-(void) performBottomUp {
    for (int layer_index = (int)_numVariables-1; layer_index > 0; layer_index--) {
        ORTRIdArrayI* layer = [self getLayer:layer_index];
        int layerSize = layer_size[layer_index]._val;
        TRInt* variableCount = layer_variable_count[layer_index-1];
        int variableIndex = _layer_to_variable[layer_index-1];
        
        for (int node_index = 0; node_index < layerSize; node_index++) {
            MDDNode* node = [layer at:node_index];
            ORTRIdArrayI* parents = [node parents];
            int numParents = [node numParents];
            char* bottomUpStateValues;
            bool needToFreeStateValues = false;
            bool stateChanged = false;
            
            //Recalc node's bottom-up info if needed
            if ([node bottomUpRecalcRequired]) {
                bottomUpStateValues = [self calculateStateFromChildrenOf:node onLayer:layer_index];
                if (getBottomUpState(node) == nil) {
                    MDDStateValues* bottomUpState = [[MDDStateValues alloc] initState:bottomUpStateValues numBytes:_numBottomUpBytes hashWidth:_hashWidth trail:_trail];
                    [node initializeBottomUpState:bottomUpState];
                    stateChanged = true;
                } else {
                    char* oldValues = [getBottomUpState(node) stateValues];
                    if (memcmp(oldValues, bottomUpStateValues, _numBottomUpBytes) != 0) {
                        [node updateBottomUpState:bottomUpStateValues];
                        stateChanged = true;
                    }
                    needToFreeStateValues = true;
                }
                [node setBottomUpRecalcRequired:false];
            } else {
                bottomUpStateValues = [getBottomUpState(node) stateValues];
            }

            //Check if every parent arc should still exist
            for (int parent_index = 0; parent_index < numParents; parent_index++) {
                MDDArc* parentArc = [parents at:parent_index];
                int arcValue = [parentArc arcValue];
                MDDNode* parent = [parentArc parent];
                if (![_spec canChooseValue:arcValue forVariable:variableIndex fromParent:[getTopDownState(parent) stateValues] toChild:bottomUpStateValues]) {
                    assignTRInt(&variableCount[arcValue], variableCount[arcValue]._val-1, _trail);
                    [parent removeChildAt:arcValue inPost:_inPost];
                    [node removeParentArc:parentArc inPost:_inPost];
                    parent_index--;
                    numParents--;
                    if ([parent isChildless]) {
                        [self removeChildlessNodeFromMDD:parent fromLayer:layer_index-1];
                    } else {
                        [parent setBottomUpRecalcRequired:true];
                    }
                } else if (stateChanged) {
                    [self recalcArc:parentArc childProperties:bottomUpStateValues variable:variableIndex];
                }
            }
            
            if (needToFreeStateValues) {
                free(bottomUpStateValues);
            }
            
            if ([node isParentless]) {
                [self removeParentlessNodeFromMDD:node fromLayer:layer_index];
                node_index--;
                layerSize--;
            } else {
                [node setTopDownRecalcRequired:true];
            }
        }
    }
}

-(void) DEBUGTestParentArcIndices {
    for (int layerIndex = 1; layerIndex <= (int)_numVariables; layerIndex++) {
        ORTRIdArrayI* layer = [self getLayer:layerIndex];
        int layerSize = layer_size[layerIndex]._val;
        for (int nodeIndex = 0; nodeIndex < layerSize; nodeIndex++) {
            MDDNode* node = [layer at:nodeIndex];
            ORTRIdArrayI* parentArcs = [node parents];
            int numParents = [node numParents];
            for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
                MDDArc* parentArc = [parentArcs at:parentIndex];
                int parentArcIndex = [parentArc parentArcIndex];
                if (parentIndex != parentArcIndex) {
                    int i =0;
                }
            }
        }
    }
}
@end

