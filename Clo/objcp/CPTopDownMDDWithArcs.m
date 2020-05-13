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
@implementation CPMDDWithArcs
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x spec:(MDDStateSpecification *)spec  gamma:(id*)gamma {
    self = [super initCPMDD:engine over:x spec:spec gamma:gamma];
    _nodeClass = [MDDNode class];
    return self;
}
-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:[(MDDStateValues*)getTopDownState(child) stateValues] numTopDownBytes:_numTopDownBytes];
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
    [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:[(MDDStateValues*)getTopDownState(child) stateValues] numTopDownBytes:_numTopDownBytes];
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
-(id) initCPMDDRelaxation:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec equalBuckets:(bool)equalBuckets usingSlack:(bool)usingSlack recommendationStyle:(MDDRecommendationStyle)recommendationStyle gamma:(id*)gamma {
    self = [super initCPMDDRelaxation:engine over:x relaxationSize:relaxationSize spec:spec equalBuckets:equalBuckets usingSlack:usingSlack recommendationStyle:recommendationStyle gamma:gamma];
    _nodeClass = [MDDNode class];
    return self;
}

-(void) buildLastLayer {
    int parentLayer = (int)_numVariables-1;
    int minDomain = _min_domain_for_layer[parentLayer];
    int maxDomain = _max_domain_for_layer[parentLayer];
    int parentVariableIndex = _layer_to_variable[parentLayer];
    int parentLayerSize = layer_size[parentLayer]._val;
    id<CPIntVar> parentVariable = _x[parentVariableIndex];
    ORTRIdArrayI* parentNodes = [self getLayer:parentLayer];
    MDDNode* sink = [[self getLayer:(int)_numVariables] at: 0];
    char* sinkTopDown = malloc(_numTopDownBytes * sizeof(char));
    bool firstArc = true;
    for (int edgeValue = minDomain; edgeValue <= maxDomain; edgeValue++) {
        if ([parentVariable member: edgeValue]) {
            for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
                MDDNode* parentNode = [parentNodes at: parentNodeIndex];
                MDDStateValues* parentState = getTopDownState(parentNode);
                char* arcState;
                if(_canCreateState(_spec, _canCreateStateSel, &arcState, parentState, parentVariableIndex, edgeValue, _fixpointMinValues, _fixpointMaxValues)) {
                    if (firstArc) {
                        memcpy(sinkTopDown, arcState, _numTopDownBytes);
                        firstArc = false;
                    } else {
                        [_spec mergeTempStateProperties:sinkTopDown with:arcState];
                    }
                    [[MDDArc alloc] initArc:_trail from:parentNode to:sink value:edgeValue inPost:_inPost state:arcState numTopDownBytes:_numTopDownBytes];
                    assignTRInt(&layer_variable_count[parentLayer][edgeValue], layer_variable_count[parentLayer][edgeValue]._val+1, _trail);
                }
            }
        } else {
            _valueNotMember[parentVariableIndex][edgeValue] = makeTRInt(_trail, 1);
        }
    }
    MDDStateValues* sinkTopDownState = [[MDDStateValues alloc] initState:sinkTopDown numBytes:_numTopDownBytes hashWidth:_hashWidth trail:_trail];
    [sink initializeTopDownState:sinkTopDownState];
    for (int parentNodeIndex = 0; parentNodeIndex < parentLayerSize; parentNodeIndex++) {
        Node* parentNode = [parentNodes at: parentNodeIndex];
        if ([parentNode isChildless]) {
            [self removeChildlessNodeFromMDD:parentNode fromLayer:parentLayer];
            parentNodeIndex--;
            parentLayerSize--;
        }
    }
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
            transitionFunctions[propertyIndex](newState, parentProperties, nil, variable, value);
        }
    } else {
        memcpy(newState, parentProperties, _numTopDownBytes);
        bool* propertyUsed = [_spec topDownPropertiesUsed:variable];
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                transitionFunctions[propertyIndex](newState, parentProperties, nil, variable, value);
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
-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    MDDStateValues* childState = getTopDownState(child);
    if (childState == nil) {
        [[MDDArc alloc] initArcToSink:_trail from:parent to:child value:value inPost:_inPost];
    } else {
        char* arcState = malloc(_numTopDownBytes * sizeof(char));
        memcpy(arcState, [childState stateValues], _numTopDownBytes);
        [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:arcState numTopDownBytes:_numTopDownBytes];
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
                    newNode = [[MDDNode alloc] initNode:_trail minChildIndex:minDomain maxChildIndex:maxDomain state:newState hashWidth:_hashWidth];
                    
                    nodeHasChildren = false;
                    for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
                        MDDArc* existingChildArc = existingNodeChildrenArcs[domainVal];
                        if (existingChildArc != nil) {
                            if ([_spec canChooseValue:domainVal forVariable:variableIndex fromParent:newProperties toChild:nil]) {
                                if (!nodeHasChildren) {
                                    [_trail trailRelease:newNode];
                                    [_trail trailRelease:newState];
                                    //Need to make sure newNode is on trailRelease since its inner values are about to be changed (which are trailables)
                                }
                                MDDNode* child = [existingChildArc child];
                                if (childLayer == (int)_numVariables) {
                                    [[MDDArc alloc] initArcToSink:_trail from:newNode to:child value:domainVal inPost:_inPost];
                                } else {
                                    [[MDDArc alloc] initArc:_trail from:newNode to:child value:domainVal inPost:_inPost state:_computeStateFromProperties(_spec, _computeStateFromPropertiesSel, newProperties, variableIndex, domainVal) numTopDownBytes:_numTopDownBytes];
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
-(char*) calculateStateFromParentsOf:(MDDNode*)node onLayer:(int)layer isMerged:(bool*)isMergedNode {
    if (layer == (int)_numVariables-1) {
        return [self calculateSinkStateIsMerged:isMergedNode];
    }
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
-(char*) calculateSinkStateIsMerged:(bool*)isMergedNode {
    *isMergedNode = false;
    int parentLayerIndex = (int)_numVariables-1;
    int parentVariable = _layer_to_variable[parentLayerIndex];
    int numParents = layer_size[parentLayerIndex]._val;
    ORTRIdArrayI* parentLayer = [self getLayer:parentLayerIndex];
    int minChildIndex = _min_domain_for_layer[parentLayerIndex];
    int maxChildIndex = _max_domain_for_layer[parentLayerIndex];
    bool first = true;
    char* newStateProperties = malloc(_numTopDownBytes * sizeof(char));
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        MDDNode* parent = [parentLayer at:parentIndex];
        char* parentState = [getTopDownState(parent) stateValues];
        Node** children = [parent children];
        for (int childIndex = minChildIndex; childIndex <= maxChildIndex; childIndex++) {
            if (children[childIndex] != nil) {
                char* passedState = [_spec computeTopDownStateFromProperties:parentState assigningVariable:parentVariable withValue:childIndex];
                if (first) {
                    memcpy(newStateProperties, passedState, _numTopDownBytes);
                    first = false;
                } else {
                    if (*isMergedNode) {
                        [_spec mergeTempStateProperties:newStateProperties with:passedState];
                    } else if (memcmp(newStateProperties, passedState, _numTopDownBytes) != 0) {
                        *isMergedNode = true;
                        [_spec mergeTempStateProperties:newStateProperties with:passedState];
                    }
                }
                free(passedState);
            }
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
