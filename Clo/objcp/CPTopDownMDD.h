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
@protected
    Class _nodeClass;
    
    int _nextVariable;
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
    int _highestLayerChanged;
    int _lowestLayerChanged;
    bool _inPost;
    int _hashWidth;
    size_t _numBytes;
    MDDRecommendationStyle _recommendationStyle;
    
    TRInt** _valueNotMember;
    TRInt* _layerBound;
    
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
-(void) removeChild:(Node*)node fromParent:(id)parent parentLayer:(int)parentLayer;
-(int) layerIndexForVariable:(int)variableIndex;
-(int) variableIndexForLayer:(int)layer;
-(void) createRootAndSink;
-(void) cleanLayer:(int)layer;
-(void) afterPropagation;
-(void) connect:(Node*)parent to:(Node*)child value:(int)value;
-(void) buildLastLayer;
-(void) buildLayerByValue:(int)layer;
-(void) buildLayerByNode:(int)layer;
-(void) addPropagationsAndTrimDomains;
-(void) trimDomainsFromLayer:(ORInt)layer;
-(void) addPropagationToLayer:(ORInt)layer;
-(id) generateRootState:(int)variableValue;
-(void) addNode:(Node*)node toLayer:(int)layer_index;
-(void) removeNodeAt:(int)index onLayer:(int)node_layer;
-(void) removeNode: (Node*) node onLayer:(int)node_layer;
-(int) removeChildlessNodeFromMDDAtIndex:(int)nodeIndex fromLayer:(int)layer;
-(int) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer;
-(int) checkParentsOfChildlessNode:(Node*)node parentLayer:(int)layer;
-(void) removeParentlessFromMDD:(id)child fromLayer:(int)layer;
-(int) removeChildlessFromMDD:(id)node fromLayer:(int)layer;
-(void) removeParentlessNodeFromMDD:(Node*)node fromLayer:(int)layer;
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value;
-(void) DEBUGTestLayerVariableCountCorrectness;
-(ORInt) recommendationFor:(id<CPIntVar>)x;
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
    TRInt _first_relaxed_layer;
    TRInt _firstRelaxedLayer;
    SEL _calculateStateFromParentsSel;
    CalculateStateFromParentsIMP _calculateStateFromParents;
@protected
    int _relaxation_size;
    bool _equalBuckets;
    bool _usingSlack;
    SEL _computeStateFromPropertiesSel, _splitNodesOnLayerSel;
    ComputeStateFromPropertiesIMP _computeStateFromProperties;
    SplitNodesOnLayerIMP _splitNodesOnLayer;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification*)spec equalBuckets:(bool)equalBuckets usingSlack:(bool)usingSlack recommendationStyle:(MDDRecommendationStyle)recommendationStyle;
-(void) rebuild;
-(void) splitNodesOnLayer:(int)layer;
-(void) recalcNode:(Node*)node onLayer:(int)layer;
-(void) recalcNodesOnLayer:(int)layer_index;
-(char*) calculateStateFromParentsOf:(Node*)node onLayer:(int)layer isMerged:(bool*)isMerged;
-(void) reevaluateChildrenAfterParentStateChange:(Node*)node onLayer:(int)layer_index andVariable:(int)variableIndex;
-(void) mergeNodesToWidthOnLayer:(int)layer;
@end
