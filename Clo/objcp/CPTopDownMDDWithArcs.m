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
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x spec:(MDDStateSpecification *)spec {
    self = [super initCPMDD:engine over:x spec:spec];
    _nodeClass = [MDDNode class];
    return self;
}
-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:[(MDDStateValues*)getState(child) state] numBytes:_numBytes];
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
@end

@implementation CPMDDRestrictionWithArcs
-(id) initCPMDDRestriction:(id<CPEngine>)engine over:(id<CPIntVarArray>)x restrictionSize:(ORInt)restrictionSize {
    self = [super initCPMDDRestriction:engine over:x restrictionSize:restrictionSize];
    _nodeClass = [MDDNode class];
    return self;
}
-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:[(MDDStateValues*)getState(child) state] numBytes:_numBytes];
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
@end

@implementation CPMDDRelaxationWithArcs
-(id) initCPMDDRelaxation:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec equalBuckets:(bool)equalBuckets usingSlack:(bool)usingSlack recommendationStyle:(MDDRecommendationStyle)recommendationStyle {
    self = [super initCPMDDRelaxation:engine over:x relaxationSize:relaxationSize spec:spec equalBuckets:equalBuckets usingSlack:usingSlack recommendationStyle:recommendationStyle];
    _nodeClass = [MDDNode class];
    _replaceArcStateSel = @selector(replaceArcState:withParentProperties:variable:);
    _replaceArcState = (ReplaceArcStateIMP)[_spec methodForSelector:_replaceArcStateSel];
    return self;
}
-(void) recalcArc:(MDDArc*)arc parentPropertes:(char*)parentProperties variable:(int)variable {
    char* arcState = arc.state;
    int value = arc.arcValue;
    bool stateChanged = false;
    int numProperties = [_spec numProperties];
    DDNewStateClosure* transitionFunctions = [_spec transitionFunctions];
    char* newState = malloc(_numBytes * sizeof(char));
    if ([_spec numSpecs] == 1) {
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            transitionFunctions[propertyIndex](newState, parentProperties, variable, value);
        }
    } else {
        memcpy(newState, parentProperties, _numBytes);
        bool* propertyUsed = [_spec propertiesUsed:variable];
        for (int propertyIndex = 0; propertyIndex < numProperties; propertyIndex++) {
            if (propertyUsed[propertyIndex]) {
                transitionFunctions[propertyIndex](newState, parentProperties, variable, value);
            }
        }
    }
    stateChanged = memcmp(arcState, newState, _numBytes) != 0;
    [arc replaceStateWith:newState trail:_trail];
    free(newState);
    if (stateChanged) {
        [[arc child] setRecalcRequired:true];
    }
}
-(void) connect:(MDDNode*)parent to:(MDDNode*)child value:(int)value {
    //Note that this only works if child is a newly created, exact node
    MDDStateValues* childState = getState(child);
    if (childState == nil) {
        [[MDDArc alloc] initArcToSink:_trail from:parent to:child value:value inPost:_inPost];
    } else {
        char* arcState = malloc(_numBytes * sizeof(char));
        memcpy(arcState, [childState state], _numBytes);
        [[MDDArc alloc] initArc:_trail from:parent to:child value:value inPost:_inPost state:arcState numBytes:_numBytes];
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
    BetterNodeHashTable* nodeHashTable = [[BetterNodeHashTable alloc] initBetterNodeHashTable:_hashWidth numBytes:_numBytes];
    SEL hasNodeSel = @selector(hasNodeWithStateProperties:hash:node:);
    HasNodeIMP hasNode = (HasNodeIMP)[nodeHashTable methodForSelector:hasNodeSel];
    int minDomain = _min_domain_for_layer[layer];
    int maxDomain = _max_domain_for_layer[layer];
    int layerSize = layer_size[layer]._val;
    int variableIndex = _layer_to_variable[layer];
    int childLayer = layer+1;
    int parentLayer = layer-1;
    ORTRIdArrayI* layerNodes = layers[layer];
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
                char* arcState = [parentArc state];
                
                NSUInteger hashValue = _hashValueFor(_spec, _hashValueSel, arcState);
                MDDNode* newNode;
                bool nodeExists = hasNode(nodeHashTable, hasNodeSel, arcState, hashValue, &newNode);
                if (!nodeExists) {
                    char* newProperties = malloc(_numBytes * sizeof(char));
                    memcpy(newProperties, arcState, _numBytes);
                    MDDStateValues* newState = [[MDDStateValues alloc] initState:newProperties numBytes:_numBytes hashWidth:_hashWidth trail:_trail];
                    newNode = [[MDDNode alloc] initNode:_trail minChildIndex:minDomain maxChildIndex:maxDomain state:newState hashWidth:_hashWidth];
                    
                    nodeHasChildren = false;
                    for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
                        MDDArc* existingChildArc = existingNodeChildrenArcs[domainVal];
                        if (existingChildArc != nil) {
                            if ([_spec canChooseValue:domainVal forVariable:variableIndex withStateProperties:newProperties]) {
                                if (!nodeHasChildren) {
                                    [_trail trailRelease:newNode];
                                    [_trail trailRelease:newState];
                                    //Need to make sure newNode is on trailRelease since its inner values are about to be changed (which are trailables)
                                }
                                MDDNode* child = [existingChildArc child];
                                [[MDDArc alloc] initArc:_trail from:newNode to:child value:domainVal inPost:_inPost state:_computeStateFromProperties(_spec, _computeStateFromPropertiesSel, newProperties, variableIndex, domainVal) numBytes:_numBytes];
                                assignTRInt(&variableCount[domainVal], variableCount[domainVal]._val+1, _trail);
                                [child setRecalcRequired:true];
                                nodeHasChildren = true;
                            }
                        }
                    }
                    if (nodeHasChildren) {
                        _lowestLayerChanged = max(_lowestLayerChanged, childLayer);
                        [self addNode:newNode toLayer:layer];
                        [parentArc setChild:newNode inPost:_inPost];
                        [parentArc updateParentArcIndex:0 inPost:_inPost];
                        [newNode addParent:parentArc inPost:_inPost];
                        [nodeHashTable addState:newState];
                    } else {
                        assignTRInt(&parentVariableCount[arcValue], parentVariableCount[arcValue]._val-1, _trail);
                        [parent removeChildAt:arcValue inPost:_inPost];
                        if ([parent isChildless]) {
                            [self removeChildlessNodeFromMDD:parent fromLayer:parentLayer];
                        }
                        [newNode release];
                        [newState release];
                    }
                } else {
                    [parentArc setChild:newNode inPost:_inPost];
                    [parentArc updateParentArcIndex:[newNode numParents] inPost:_inPost];
                    [newNode addParent:parentArc inPost:_inPost];
                }
            }
            //If the node still has parents, it means the relaxation size was hit.  Check if any arcs that would lead exactly to a newly created state can be transferred (aka arcs that were initially grouped in the reduction)
            if ([node numParents]) {
                int numParents = [node numParents];
                for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
                    MDDArc* parentArc = [parentArcs at:parentIndex];
                    char* arcState = [parentArc state];
                    NSUInteger hashValue = _hashValueFor(_spec, _hashValueSel, arcState);
                    MDDNode* existingNode;
                    bool nodeExists = hasNode(nodeHashTable, hasNodeSel, arcState, hashValue, &existingNode);
                    if (nodeExists) {
                        [node removeParentArc:parentArc inPost:_inPost];
                        [parentArc setChild:existingNode inPost:_inPost];
                        [parentArc updateParentArcIndex:[existingNode numParents] inPost:_inPost];
                        [existingNode addParent:parentArc inPost:_inPost];
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
                [node setRecalcRequired:true];
            }
        }
    }
    [nodeHashTable release];
}
-(char*) calculateStateFromParentsOf:(MDDNode*)node onLayer:(int)layer isMerged:(bool*)isMergedNode {
    *isMergedNode = false;
    int numParents = [node numParents];
    ORTRIdArrayI* parentArcs = [node parents];
    char* newStateProperties = malloc(_numBytes * sizeof(char));
    MDDArc* firstParentArc = [parentArcs at:0];
    memcpy(newStateProperties, [firstParentArc state], _numBytes);
    for (int parentIndex = 1; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        char* arcState = [parentArc state];
        if (*isMergedNode) {
            [_spec mergeTempStateProperties:newStateProperties with:arcState];
        } else if (memcmp(newStateProperties, arcState, _numBytes) != 0) {
            *isMergedNode = true;
            [_spec mergeTempStateProperties:newStateProperties with:arcState];
        }
    }
    return newStateProperties;
}
-(void) recalcFor:(MDDArc*)child parentProperties:(char*)nodeProperties variable:(int)variableIndex {
    [self recalcArc:child parentPropertes:nodeProperties variable:variableIndex];
}

-(void) DEBUGTestParentArcIndices {
    for (int layerIndex = 1; layerIndex <= (int)_numVariables; layerIndex++) {
        ORTRIdArrayI* layer = layers[layerIndex];
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

