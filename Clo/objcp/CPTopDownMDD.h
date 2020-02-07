/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPGroup.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>
#import "ORCustomMDDStates.h"

@class Node;
@interface NodeHashTable : NSObject {
    NSMutableArray** _nodeHashes;
    int _width;
}
-(id) initNodeHashTable:(int)width;
-(NSMutableArray*) findBucketForStateHash:(NSUInteger)stateHash;
-(Node*) nodeWithState:(id)state inBucket:(NSMutableArray*)bucket;
-(NSMutableArray**) hashTable;
@end

@interface NodeIndexHashTable : NSObject {
    NSMutableDictionary* _nodeHashes;
    NSMutableDictionary* _bucketSize;
    id<ORTrail> _trail;
    int _width;
}
-(id) initNodeIndexHashTable:(int)width trail:(id<ORTrail>)trail;
-(ORTRIntArrayI*) findBucketForStateHash:(NSUInteger)stateHash;
-(void) add:(int)index toHash:(NSUInteger)hash;
-(void) remove:(int)index withHash:(NSUInteger)hash;
@end

@interface Node : NSObject {
@public
    int _value;
    bool _isSink;
    bool _isSource;
    id<ORTrail> _trail;
    
    TRId* _children;
    TRInt _numChildren;
    int _minChildIndex;
    int _maxChildIndex;
    
    ORTRIdArrayI* _uniqueParents;
    ORTRIntArrayI* _parentCounts;
    TRInt _numUniqueParents;
    TRInt _maxNumUniqueParents;
    NodeIndexHashTable* _parentLookup;
    
    MDDStateValues* _state;
    TRInt _isMergedNode;
    TRInt _recalcRequired;
}
-(id) initNode: (id<ORTrail>) trail hashWidth:(int)hashWidth;
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(MDDStateValues*)state hashWidth:(int)hashWidth;
-(void) dealloc;
-(TRId) getState;
-(int) value;
-(bool) isMergedNode;
-(void) setIsMergedNode:(bool)isMergedNode;
-(bool) recalcRequired;
-(void) setRecalcRequired:(bool)recalcRequired;
-(bool) isVital;
-(void) setIsSource:(bool)isSource;
-(void) setIsSink:(bool)isSink;
-(bool) isNonVitalAndChildless;
-(bool) isNonVitalAndParentless;
-(TRId*) children;
-(int) numChildren;
-(void) addChild:(Node*)child at:(int)index;
-(void) removeChildAt: (int) index;
-(void) removeChild:(Node*)child numTimes:(int)childCount updating:(int*)variable_count;
-(void) removeChild:(Node*)child numTimes:(int)childCount updatingLVC:(TRInt*)variable_count;
-(void) replaceChild:(Node*)oldChild with:(Node*)newChild numTimes:(int)childCount;
-(bool) hasParents;
-(void) addParent: (Node*) parent;
-(bool) hasParent:(Node*)parent;
-(int) countForParent:(Node*)parent;
-(int) countForParentIndex:(int)parent_index;
-(int) findUniqueParentIndexFor:(Node*) parent addToHash:(bool)addToHash;
-(void) removeParentAt:(int)index;
-(void) removeParentOnce: (Node*) parent;
-(void) removeParentValue: (Node*) parent;
-(void) takeParentsFrom:(Node*)other;
-(int) hashValue;
@end
static inline id getState(Node* n) { return n->_state;}

@interface CPMDD : CPCoreConstraint {
@private
    Class _stateClass;
    int _nextVariable;
@protected
    id<CPIntVarArray> _x;
    NSUInteger _numVariables;
    int min_variable_index;
    MDDStateSpecification* _spec;
    
    ORTRIdArrayI* *layers;
    TRInt **layer_variable_count;
    TRInt *layer_size;
    TRInt *max_layer_size;
    int* _variable_to_layer;
    int* _layer_to_variable;
    int* _min_domain_for_layer;
    int* _max_domain_for_layer;
    int** _changesToLayerVariableCount;
}
-(id) initCPMDD:(id<CPEngine>) engine over:(id<CPIntVarArray>)x;
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x spec:(MDDStateSpecification*)spec;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(NSString*) description;
-(id<CPIntVarArray>) x;
-(void) post;
-(int) layerIndexForVariable:(int)variableIndex;
-(int) variableIndexForLayer:(int)layer;
-(void) createRootAndSink;
-(void) cleanLayer:(int)layer;
-(void) afterPropagation;
-(void) buildLayer:(int)layer;
-(void) createChildrenForNode:(Node*)parentNode parentLayer:(int)parentLayer nodeHashes:(NodeHashTable*)nodeHashTable;
-(void) addPropagationsAndTrimDomains;
-(void) trimDomainsFromLayer:(ORInt)layer;
-(void) addPropagationToLayer:(ORInt)layer;
-(int) modifiedLayerVariableCount:(int)layer value:(int)value;
-(id) generateRootState:(int)variableValue;
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value;
-(id) generateTempStateFromParent:(Node*)parentNode withValue:(int)value;
-(void) addNode:(Node*)node toLayer:(int)layer_index;
-(void) removeNodeAt:(int)index onLayer:(int)layer_index;
-(void) removeNode: (Node*) node;
-(int) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer;
-(int) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer inPost:(bool)inPost;
-(int) removeParentlessNodeFromMDD:(Node*)node fromLayer:(int)layer;
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value;
-(void) DEBUGTestLayerVariableCountCorrectness;
-(void) DEBUGTestParentChildParity;
-(ORInt) recommendationFor: (ORInt) variableIndex;
-(void) printGraph;
@end
@interface CPMDDRestriction : CPMDD {
@private
    int restricted_size;
}
-(id) initCPMDDRestriction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize;
-(void) removeANodeFromLayer:(int)layer;
-(Node*) findNodeToRemove:(int)layer;
@end
@interface CPMDDRelaxation : CPMDD {
@private
    int _relaxation_size;
    TRInt _first_relaxed_layer;
    TRInt _firstRelaxedLayer;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification*)spec;
-(void) rebuildFromLayer:(int)startingLayer;
-(void) splitNodesOnLayer:(int)layer;
-(void) recalcNodesOnLayer:(int)layer_index;
-(MDDStateValues*) calculateStateFromParentsOf:(Node*)node onLayer:(int)layer isMerged:(bool*)isMerged;
-(void) reevaluateChildrenAfterParentStateChange:(Node*)node onLayer:(int)layer_index andVariable:(int)variableIndex;
-(void) mergeNodesToWidthOnLayer:(int)layer;
-(int**) findSimilarityMatrix:(int)layer;
-(void) updateSimilarityMatrix:(int**)similarityMatrix afterMerging:(int)best_second_node_index into:(int)best_first_node_index onLayer:(int)layer;
@end
