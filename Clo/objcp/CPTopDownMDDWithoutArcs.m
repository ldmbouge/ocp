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
#import "CPTopDownMDDWithoutArcs.h"

static inline id getTopDownState(OldNode* n) { return n->_topDownState;}
@implementation CPMDDWithoutArcs
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x spec:(MDDStateSpecification *)spec {
    self = [super initCPMDD:engine over:x spec:spec];
    _nodeClass = [OldNode class];
    return self;
}
-(void) connect:(OldNode*)parent to:(OldNode*)child value:(int)value {
    [parent addChild:child at:value inPost:_inPost];
    [child addParent:parent inPost:_inPost];
}
-(void) removeParentlessFromMDD:(OldNode*)node fromLayer:(int)layer {
    [self removeParentlessNodeFromMDD:node fromLayer:layer];
}
-(int) removeChildlessFromMDD:(OldNode*)node fromLayer:(int)layer {
    return [self removeChildlessNodeFromMDD:node fromLayer:layer];
}
-(void) removeChild:(OldNode*)node fromParent:(OldNode*)parent parentLayer:(int)parentLayer {
    [parent removeChild:node numTimes:[node countForParent:parent] updatingLVC:layer_variable_count[parentLayer] inPost:_inPost];
}
-(bool) parentIsChildless:(OldNode*)parent {
    return [parent isChildless];
}
-(char*) childState:(OldNode*) child {
    return [(MDDStateValues*)[child getState] stateValues];
}
-(void) DEBUGTestParentChildParity
{
    //DEBUG code:  Checks if every node's parent-child connections are mirrored.  That is, if a parent has a child, the child has the parent, and vice-versa.
    
    
    for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable:_hashWidth];
            OldNode* node = [layers[layer_index] at: node_index];
            OldNode** children = [node children];
            for (int child_index = _min_domain_for_layer[layer_index]; child_index <= _max_domain_for_layer[layer_index]; child_index++) {
                bool added = false;
                OldNode* child = children[child_index];
                
                if (child != NULL) {
                    MDDStateValues* childState = [child getState];
                    NSUInteger hashValue = [childState hash];
                    NSMutableArray* bucket = [nodeHashTable findBucketForStateHash:hashValue];
                    for (int bucket_index = 0; bucket_index < [bucket count]; bucket_index++) {
                        NSMutableArray* nodeCountPair = bucket[bucket_index];
                        OldNode* bucketNode = [nodeCountPair objectAtIndex:0];
                        int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                        if ([bucketNode isEqual:child]) {
                            [bucket setObject:[[NSMutableArray alloc] initWithObjects:bucketNode,[NSNumber numberWithInt:(bucketCount+1)], nil] atIndexedSubscript:bucket_index];
                            added=true;
                            break;
                        }
                    }
                    if (!added) {
                        NSArray* nodeCountPair = [[NSArray alloc] initWithObjects:child, [NSNumber numberWithInt:1], nil];
                        [bucket addObject:nodeCountPair];
                    }
                }
            }
            
            NSMutableArray** hashTable = [nodeHashTable hashTable];
            for (int i = 0; i < _hashWidth; i++) {
                NSArray* bucket = hashTable[i];
                for (NSArray* nodeCountPair in bucket) {
                    OldNode* bucketNode = [nodeCountPair objectAtIndex:0];
                    int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                    
                    if ([bucketNode countForParent:node] != bucketCount) {
                        int i =0;
                    }
                }
            }
            [nodeHashTable release];
        }
    }
}
@end

@implementation CPMDDRestrictionWithoutArcs
-(id) initCPMDDRestriction:(id<CPEngine>)engine over:(id<CPIntVarArray>)x restrictionSize:(ORInt)restrictionSize {
    self = [super initCPMDDRestriction:engine over:x restrictionSize:restrictionSize];
    _nodeClass = [OldNode class];
    return self;
}
-(void) connect:(Node*)parent to:(Node*)child value:(int)value {
    [parent addChild:child at:value inPost:_inPost];
    [child addParent:parent inPost:_inPost];
}
-(void) removeParentlessFromMDD:(OldNode*)node fromLayer:(int)layer {
    [self removeParentlessNodeFromMDD:node fromLayer:layer];
}
-(int) removeChildlessFromMDD:(OldNode*)node fromLayer:(int)layer {
    return [self removeChildlessNodeFromMDD:node fromLayer:layer];
}
-(void) removeChild:(OldNode*)node fromParent:(OldNode*)parent parentLayer:(int)parentLayer {
    [parent removeChild:node numTimes:[node countForParent:parent] updatingLVC:layer_variable_count[parentLayer] inPost:_inPost];
}
-(bool) parentIsChildless:(OldNode*)parent {
    return [parent isChildless];
}
-(char*) childState:(OldNode*) child {
    return [(MDDStateValues*)[child getState] stateValues];
}

-(void) DEBUGTestParentChildParity
{
    //DEBUG code:  Checks if every node's parent-child connections are mirrored.  That is, if a parent has a child, the child has the parent, and vice-versa.
    
    
    for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable:_hashWidth];
            OldNode* node = [layers[layer_index] at: node_index];
            OldNode** children = [node children];
            for (int child_index = _min_domain_for_layer[layer_index]; child_index <= _max_domain_for_layer[layer_index]; child_index++) {
                bool added = false;
                OldNode* child = children[child_index];
                
                if (child != NULL) {
                    MDDStateValues* childState = [child getState];
                    NSUInteger hashValue = [childState hash];
                    NSMutableArray* bucket = [nodeHashTable findBucketForStateHash:hashValue];
                    for (int bucket_index = 0; bucket_index < [bucket count]; bucket_index++) {
                        NSMutableArray* nodeCountPair = bucket[bucket_index];
                        OldNode* bucketNode = [nodeCountPair objectAtIndex:0];
                        int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                        if ([bucketNode isEqual:child]) {
                            [bucket setObject:[[NSMutableArray alloc] initWithObjects:bucketNode,[NSNumber numberWithInt:(bucketCount+1)], nil] atIndexedSubscript:bucket_index];
                            added=true;
                            break;
                        }
                    }
                    if (!added) {
                        NSArray* nodeCountPair = [[NSArray alloc] initWithObjects:child, [NSNumber numberWithInt:1], nil];
                        [bucket addObject:nodeCountPair];
                    }
                }
            }
            
            NSMutableArray** hashTable = [nodeHashTable hashTable];
            for (int i = 0; i < _hashWidth; i++) {
                NSArray* bucket = hashTable[i];
                for (NSArray* nodeCountPair in bucket) {
                    OldNode* bucketNode = [nodeCountPair objectAtIndex:0];
                    int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                    
                    if ([bucketNode countForParent:node] != bucketCount) {
                        int i =0;
                    }
                }
            }
            [nodeHashTable release];
        }
    }
}
@end

@implementation CPMDDRelaxationWithoutArcs
-(id) initCPMDDRelaxation:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec equalBuckets:(bool)equalBuckets usingSlack:(bool)usingSlack recommendationStyle:(MDDRecommendationStyle)recommendationStyle {
    self = [super initCPMDDRelaxation:engine over:x relaxationSize:relaxationSize spec:spec equalBuckets:equalBuckets usingSlack:usingSlack recommendationStyle:recommendationStyle];
    _nodeClass = [OldNode class];
    _batchMergeStatesSel = @selector(batchMergeForStates:values:numEdgesPerParent:variable:isMerged:numParents:totalEdges:);
    _batchMergeStates = (BatchMergeStatesIMP)[_spec methodForSelector:_batchMergeStatesSel];
    
    return self;
}
-(void) connect:(Node*)parent to:(Node*)child value:(int)value {
    [parent addChild:child at:value inPost:_inPost];
    [child addParent:parent inPost:_inPost];
}
-(void) removeParentlessFromMDD:(OldNode*)node fromLayer:(int)layer {
    [self removeParentlessNodeFromMDD:node fromLayer:layer];
}
-(int) removeChildlessFromMDD:(OldNode*)node fromLayer:(int)layer {
    return [self removeChildlessNodeFromMDD:node fromLayer:layer];
}
-(void) removeChild:(OldNode*)node fromParent:(OldNode*)parent parentLayer:(int)parentLayer {
    [parent removeChild:node numTimes:[node countForParent:parent] updatingLVC:layer_variable_count[parentLayer] inPost:_inPost];
}
-(bool) parentIsChildless:(OldNode*)parent {
    return [parent isChildless];
}
-(void) splitNodesOnLayer:(int)layer {
    BetterNodeHashTable* nodeHashTable = [[BetterNodeHashTable alloc] initBetterNodeHashTable:_hashWidth numBytes:_numTopDownBytes];
    SEL hasNodeSel = @selector(hasNodeWithStateProperties:hash:node:);
    HasNodeIMP hasNode = (HasNodeIMP)[nodeHashTable methodForSelector:hasNodeSel];
    int minDomain = _min_domain_for_layer[layer];
    int maxDomain = _max_domain_for_layer[layer];
    int layerSize = layer_size[layer]._val;
    int variableIndex = _layer_to_variable[layer];
    int childLayer = layer+1;
    int parentLayer = layer-1;
    int parentMinDomain = _min_domain_for_layer[parentLayer];
    ORTRIdArrayI* layerNodes = layers[layer];
    TRInt* variableCount = layer_variable_count[layer];
    TRInt* parentVariableCount = layer_variable_count[parentLayer];
    bool nodeHasChildren;
    for (int nodeIndex = 0; nodeIndex < layerSize && layer_size[layer]._val < _relaxation_size; nodeIndex++) {
        OldNode* node = [layerNodes at:nodeIndex];
        if ([node isMerged]) {
            OldNode** existingNodeChildren = [node children];
            ORTRIdArrayI* parents = [node parents];
            while ([node numParents] && layer_size[layer]._val < _relaxation_size) {
                //[self DEBUGTestParentChildParity];
                OldNode* parent = [parents at:0];
                MDDStateValues* parentState = getTopDownState(parent);
                char* parentProperties = [parentState stateValues];
                int countForParent = [node countForParentIndex:0];
                OldNode** parentChildren = [parent children];
                for (int childIndex = parentMinDomain; countForParent && layer_size[layer]._val < _relaxation_size; childIndex++) {
                    OldNode* parentChild = parentChildren[childIndex];
                    if (node == parentChild) {
                        [node removeParentOnceAtIndex:0 inPost:_inPost];
                        countForParent--;
                        
                        char* newProperties = _computeStateFromProperties(_spec, _computeStateFromPropertiesSel, parentProperties, variableIndex, childIndex);
                        NSUInteger hashValue = _hashValueFor(_spec, _hashValueSel, newProperties);
                        OldNode* newNode;
                        bool nodeExists = hasNode(nodeHashTable, hasNodeSel, newProperties, hashValue, &newNode);
                        if (!nodeExists) {
                            MDDStateValues* newState = [[MDDStateValues alloc] initState:newProperties numBytes:_numTopDownBytes hashWidth:_hashWidth trail:_trail];
                            newNode = [[OldNode alloc] initNode:_trail minChildIndex:minDomain maxChildIndex:maxDomain state:newState hashWidth:_hashWidth];
                            
                            nodeHasChildren = false;
                            for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
                                OldNode* oldNodeChild = existingNodeChildren[domainVal];
                                if (oldNodeChild != nil) {
                                    if ([_spec canChooseValue:domainVal forVariable:variableIndex fromParent:newProperties toChild:[(MDDStateValues*)getTopDownState(oldNodeChild) stateValues]]) {
                                        if (!nodeHasChildren) {
                                            [_trail trailRelease:newNode];
                                            [_trail trailRelease:newState];
                                            //Need to make sure newNode is on trailRelease since its inner values are about to be changed (which are trailables)
                                        }
                                        [newNode addChild:oldNodeChild at:domainVal inPost:_inPost];
                                        [oldNodeChild addParent:newNode inPost:_inPost];
                                        assignTRInt(&variableCount[domainVal], variableCount[domainVal]._val+1, _trail);
                                        [oldNodeChild setTopDownRecalcRequired:true];
                                        nodeHasChildren = true;
                                    }
                                }
                            }
                            if (nodeHasChildren) {
                                _lowestLayerChanged = max(_lowestLayerChanged,childLayer);
                                [self addNode:newNode toLayer:layer];
                                [newNode setBottomUpRecalcRequired:true];
                                [parent addChild:newNode at:childIndex inPost:_inPost];
                                [newNode addParent:parent inPost:_inPost];
                                [nodeHashTable addState:newState];
                            } else {
                                assignTRInt(&parentVariableCount[childIndex], parentVariableCount[childIndex]._val-1, _trail);
                                [parent removeChildAt:childIndex inPost:_inPost];
                                if ([parent isChildless]) {
                                    [self removeChildlessNodeFromMDD:parent fromLayer:parentLayer];
                                }
                                [newState release];
                                [newNode release];
                            }
                        } else {
                            [parent addChild:newNode at:childIndex inPost:_inPost];
                            [newNode addParent:parent inPost:_inPost];
                            free(newProperties);
                        }
                    }
                }
            }
            if ([node numParents]) {
                int numParents = [node numParents];
                for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
                    OldNode* parent = [parents at:parentIndex];
                    MDDStateValues* parentState = getTopDownState(parent);
                    char* parentProperties = [parentState stateValues];
                    OldNode** parentChildren = [parent children];
                    
                    int countForParent = [node countForParentIndex:parentIndex];
                    int parentCountRemaining = countForParent;
                    for (int childIndex = parentMinDomain; countForParent; childIndex++) {
                        OldNode* parentChild = parentChildren[childIndex];
                        if (node == parentChild) {
                            //If an edge has been found
                            
                            char* newProperties = _computeStateFromProperties(_spec, _computeStateFromPropertiesSel, parentProperties, variableIndex, childIndex);
                            NSUInteger hashValue = _hashValueFor(_spec, _hashValueSel, newProperties);
                            OldNode* existingNode;
                            bool nodeExists = hasNode(nodeHashTable, hasNodeSel, newProperties, hashValue, &existingNode);
                            if (nodeExists) {
                                [node removeParentOnceAtIndex:parentIndex inPost:_inPost];
                                [parent addChild:existingNode at:childIndex inPost:_inPost];
                                [existingNode addParent:parent inPost:_inPost];
                                parentCountRemaining--;
                            }
                            free(newProperties);
                            
                            countForParent--;
                        }
                    }
                    if (!parentCountRemaining) {
                        numParents--;
                        parentIndex--;
                    }
                }
            }
            if ([node isParentless]) {
                _removeParentlessNode(self, _removeParentlessSel, node, layer);
                nodeIndex--;
                layerSize--;
            } else {
                [node setTopDownRecalcRequired:true];
                [node setBottomUpRecalcRequired:true];
            }
        }
    }
    [nodeHashTable release];
}
-(char*) calculateStateFromParentsOf:(OldNode*)node onLayer:(int)layer isMerged:(bool*)isMergedNode {
    *isMergedNode = false;
    ORTRIdArrayI* parents = [node parents];
    int numParents = [node numParents];
    char** parentStates = malloc(numParents * sizeof(char*));
    int** edgesUsedByParent = malloc(numParents * sizeof(int*));
    int* numEdgesPerParent = malloc(numParents * sizeof(int));
    int minDomain = _min_domain_for_layer[layer];
    int totalEdges = 0;
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        OldNode* parent = [parents at: parentIndex];
        MDDStateValues* parentState = getTopDownState(parent);
        char* parentProperties = [parentState stateValues];
        parentStates[parentIndex] = parentProperties;
        TRId* children = [parent children];
        int countForParent = [node countForParentIndex:parentIndex];
        numEdgesPerParent[parentIndex] = countForParent;
        int* usedEdges = malloc(countForParent * sizeof(int));
        for (int childIndex = minDomain; countForParent > 0; childIndex++) {
            OldNode* child = children[childIndex];
            if (child == node) {
                countForParent--;
                usedEdges[countForParent] = childIndex;
                totalEdges++;
            }
        }
        edgesUsedByParent[parentIndex] = usedEdges;
    }
    
    char* newStateProperties = _batchMergeStates(_spec, _batchMergeStatesSel, parentStates, edgesUsedByParent, numEdgesPerParent, _layer_to_variable[layer], isMergedNode, numParents, totalEdges);
    free(parentStates);
    for (int i = 0; i < numParents; i++) {
        free(edgesUsedByParent[i]);
    }
    free(numEdgesPerParent);
    return newStateProperties;
}
-(void) recalcFor:(OldNode*)child parentProperties:(char*)nodeProperties variable:(int)variableIndex {
    [child setTopDownRecalcRequired:true];
}
-(char*) childState:(OldNode*) child {
    return [(MDDStateValues*)[child getState] stateValues];
}

-(void) DEBUGTestParentChildParity
{
    //DEBUG code:  Checks if every node's children have it as a parent the correct number of times
    
    
    for (int layer_index = 0; layer_index < _numVariables; layer_index++) {
        for (int node_index = 0; node_index < layer_size[layer_index]._val; node_index++) {
            NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable:_hashWidth];
            OldNode* node = [layers[layer_index] at: node_index];
            OldNode** children = [node children];
            for (int child_index = _min_domain_for_layer[layer_index]; child_index <= _max_domain_for_layer[layer_index]; child_index++) {
                bool added = false;
                OldNode* child = children[child_index];
                
                if (child != NULL) {
                    MDDStateValues* childState = [child getState];
                    NSUInteger hashValue = [childState hash];
                    NSMutableArray* bucket = [nodeHashTable findBucketForStateHash:hashValue];
                    for (int bucket_index = 0; bucket_index < [bucket count]; bucket_index++) {
                        NSMutableArray* nodeCountPair = bucket[bucket_index];
                        OldNode* bucketNode = [nodeCountPair objectAtIndex:0];
                        int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                        if ([bucketNode isEqual:child]) {
                            [bucket setObject:[[NSMutableArray alloc] initWithObjects:bucketNode,[NSNumber numberWithInt:(bucketCount+1)], nil] atIndexedSubscript:bucket_index];
                            added=true;
                            break;
                        }
                    }
                    if (!added) {
                        NSArray* nodeCountPair = [[NSArray alloc] initWithObjects:child, [NSNumber numberWithInt:1], nil];
                        [bucket addObject:nodeCountPair];
                    }
                }
            }
            
            NSMutableArray** hashTable = [nodeHashTable hashTable];
            for (int i = 0; i < _hashWidth; i++) {
                NSArray* bucket = hashTable[i];
                for (NSArray* nodeCountPair in bucket) {
                    OldNode* bucketNode = [nodeCountPair objectAtIndex:0];
                    int bucketCount = [[nodeCountPair objectAtIndex:1] intValue];
                    
                    if ([bucketNode countForParent:node] != bucketCount) {
                        int i =0;
                    }
                }
            }
            [nodeHashTable release];
        }
    }
}
@end
