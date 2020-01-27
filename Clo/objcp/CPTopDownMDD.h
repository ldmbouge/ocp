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

@class CPIntVar;
@class ORIntSetI;
@class CPEngine;
@class CPBitDom;
@protocol CPIntVarArray;
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
    
    TRId _state;
    TRInt _isRelaxed;
    TRInt _recalcRequired;
}
-(id) initNode: (id<ORTrail>) trail;
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state;
-(void) dealloc;
-(TRId) getState;
-(int) value;
-(bool) isRelaxed;
-(bool) recalcRequired;
-(void) setRecalcRequired:(bool)recalcRequired;
-(bool) isVital;
-(void) setIsSource:(bool)isSource;
-(void) setIsSink:(bool)isSink;
-(bool) isNonVitalAndChildless;
-(bool) isNonVitalAndParentless;
-(int) minChildIndex;
-(int) maxChildIndex;
-(TRId*) children;
-(int) numChildren;
-(void) addChild:(Node*)child at:(int)index;
-(void) removeChildAt: (int) index;
-(void) removeChild:(Node*)child numTimes:(int)childCount updating:(TRInt*)variable_count;
-(void) replaceChild:(Node*)oldChild with:(Node*)newChild numTimes:(int)childCount;
-(bool) hasParents;
-(void) addParent: (Node*) parent;
-(bool) hasParent:(Node*)parent;
-(int) countForParent:(Node*)parent;
-(int) countForParentIndex:(int)parent_index;
-(void) removeParentOnce: (Node*) parent;
-(void) removeParentValue: (Node*) parent;
-(void) mergeWith:(Node*)other inPlace:(bool)inPlace layerVariableCount:(TRInt**)layerVariableCount layer:(int)layer;
-(void) mergeChildrenWith:(Node*)other layerVariableCount:(TRInt**)layerVariableCount layer:(int)layer;
-(void) takeParentsFrom:(Node*)other;
-(bool) canChooseValue:(int)value;
-(void) mergeStateWith:(Node*)other;
@end
static inline id getState(Node* n) { return n->_state;}

@interface NodeHashTable : NSObject {
    NSMutableDictionary* nodeHashes;
}
-(NSMutableArray*) findBucketForStateHash:(NSUInteger)stateHash;
-(Node*) nodeWithState:(id)state inBucket:(NSMutableArray*)bucket;
-(NSMutableDictionary*) hashTable;
@end

@interface CPMDD : CPCoreConstraint {
@private
    Class _stateClass;
    int _nextVariable;
@protected
    id<CPIntVarArray> _x;
    NSUInteger _numVariables;
    int min_domain_val;
    int max_domain_val;
    id _classState;
    
    ORTRIdArrayI* *layers;
    TRInt **layer_variable_count;
    TRInt *layer_size;
    TRInt *max_layer_size;
    int* _variable_to_layer;
    int* _layer_to_variable;
    
    int _hashTableSize;
}
-(id) initCPMDD:(id<CPEngine>) engine over:(id<CPIntVarArray>)x reduced:(bool)reduced;
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x classState:(id)classState;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(NSString*) description;
-(id<CPIntVarArray>) x;
-(void) post;
-(int) layerIndexForVariable:(int)variableIndex;
-(int) variableIndexForLayer:(int)layer;
-(void) createRootAndSink;
-(void) cleanLayer:(int)layer;
-(void) buildNewLayerUnder:(int)layer;
-(void) createChildrenForNode:(Node*)parentNode nodeHashes:(NodeHashTable*)nodeHashTable;
-(void) addPropagationsAndTrimValues;
-(void) trimValuesFromLayer:(ORInt)layer;
-(void) addPropagationToLayer:(ORInt)layer;
-(id) generateRootState:(int)variableValue;
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value;
-(void) addNode:(Node*)node toLayer:(int)layer_index;
-(void) removeNodeAt:(int)index onLayer:(int)layer_index;
-(void) removeNode: (Node*) node;
-(int) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer;
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
-(id) initCPMDDRestriction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize reduced:(bool)reduced;
-(void) removeANodeFromLayer:(int)layer;
-(Node*) findNodeToRemove:(int)layer;
@end
@interface CPMDDRelaxation : CPMDD {
@private
    bool _relaxed;
    int _relaxation_size;
    TRInt _first_relaxed_layer;
    int _firstChangedLayer, _lastChangedLayer;
    
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize classState:(id)classState;
-(void) rebuildFromLayer:(int)startingLayer;
-(void) splitNodesOnLayer:(int)layer;
-(void) recalcNodesOnLayer:(int)layer_index;
-(id) calculateStateFromParents:(Node*)node;
-(void) reevaluateChildrenAfterParentStateChange:(Node*)node onLayer:(int)layer_index andVariable:(int)variableIndex;
-(void) mergeNodesToWidthOnLayer:(int)layer;
-(int**) findSimilarityMatrix:(int)layer;
-(void) updateSimilarityMatrix:(int**)similarityMatrix afterMerging:(int)best_second_node_index into:(int)best_first_node_index onLayer:(int)layer;
@end
@interface CPCustomMDD : CPMDDRelaxation
-(id) initCPCustomMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize classState:(id)classState;
@end
