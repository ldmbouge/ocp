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
    //int** initial_layer_variable_count;
    TRInt **layer_variable_count;
    TRInt *layer_size;
    TRInt *max_layer_size;
    int* _variable_to_layer;
    int* _layer_to_variable;
    int* _min_domain_for_layer;
    int* _max_domain_for_layer;
    int _highestLayerChanged;
    int _lowestLayerChanged;
    bool _inPost;
    int _hashWidth;
    size_t _numBytes;
    
    SEL _canCreateStateSel;
    CanCreateStateIMP _canCreateState;
    SEL _hashValueSel;
    HashValueIMP _hashValueFor;
    SEL _removeParentlessSel;
    RemoveParentlessIMP _removeParentlessNode;
}
-(id) initCPMDD:(id<CPEngine>) engine over:(id<CPIntVarArray>)x;
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x spec:(MDDStateSpecification*)spec;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(NSString*) description;
-(id<CPIntVarArray>) x;
-(void) post;
//-(void) setLayerVariableCount;
-(int) layerIndexForVariable:(int)variableIndex;
-(int) variableIndexForLayer:(int)layer;
-(void) createRootAndSink;
-(void) cleanLayer:(int)layer;
-(void) afterPropagation;
-(void) buildLastLayer;
//-(void) buildLayer:(int)layer;
-(void) buildLayerByValue:(int)layer;
//-(void) createChildrenForNode:(OldNode*)parentNode parentLayer:(int)parentLayer nodeHashTable:(BetterNodeHashTable*)nodeHashTable;
//-(void) createChildrenForNode:(OldNode*)parentNode parentLayer:(int)parentLayer stateToNodeDict:(NSMutableDictionary<MDDStateValues*,OldNode*>*)stateToNodeDict;
-(void) addPropagationsAndTrimDomains;
-(void) trimDomainsFromLayer:(ORInt)layer;
-(void) addPropagationToLayer:(ORInt)layer;
-(id) generateRootState:(int)variableValue;
-(id) generateStateFromParent:(OldNode*)parentNode assigningVariable:(int)variable withValue:(int)value;
-(id) generateTempStateFromParent:(OldNode*)parentNode assigningVariable:(int)variable withValue:(int)value;
-(void) addNode:(OldNode*)node toLayer:(int)layer_index;
-(void) removeNodeAt:(int)index onLayer:(int)node_layer;
-(void) removeNode: (OldNode*) node onLayer:(int)node_layer;
-(int) removeChildlessNodeFromMDDAtIndex:(int)nodeIndex fromLayer:(int)layer;
-(int) removeChildlessNodeFromMDD:(OldNode*)node fromLayer:(int)layer;
-(int) checkParentsOfChildlessNode:(OldNode*)node parentLayer:(int)layer;
-(void) removeParentlessNodeFromMDD:(OldNode*)node fromLayer:(int)layer;
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
-(OldNode*) findNodeToRemove:(int)layer;
@end
@interface CPMDDRelaxation : CPMDD {
@private
    int _relaxation_size;
    TRInt _first_relaxed_layer;
    TRInt _firstRelaxedLayer;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification*)spec;
-(void) rebuild;
-(void) splitNodesOnLayer:(int)layer;
-(void) recalcNodesOnLayer:(int)layer_index;
-(MDDStateValues*) calculateStateFromParentsOf:(OldNode*)node onLayer:(int)layer isMerged:(bool*)isMerged;
-(void) reevaluateChildrenAfterParentStateChange:(OldNode*)node onLayer:(int)layer_index andVariable:(int)variableIndex;
-(void) mergeNodesToWidthOnLayer:(int)layer;
-(int**) findSimilarityMatrix:(int)layer;
-(void) updateSimilarityMatrix:(int**)similarityMatrix afterMerging:(int)best_second_node_index into:(int)best_first_node_index onLayer:(int)layer;
@end
