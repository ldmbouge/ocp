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
@private
    TRInt* _childEdgeWeights;
    TRId* _children;
    TRInt _numChildren;
    int _minChildIndex;
    int _maxChildIndex;
    TRId* *_parents;
    TRInt _numParents;
    int _value;
    bool _isSink;
    bool _isSource;
    id<ORTrail> _trail;
    int* _objectiveValues;
    TRInt _longestPath;
    Node* *_longestPathParents;
    TRInt _numLongestPathParents;
    TRInt _shortestPath;
    Node* *_shortestPathParents;
    TRInt _numShortestPathParents;
    
    TRInt _reverseLongestPath;
    TRInt _reverseShortestPath;
    
    id _state;
}
-(id) initNode: (id<ORTrail>) trail maxParents:(int)maxParents;
-(id) initNode: (id<ORTrail>) trail maxParents:(int)maxParents minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state objectiveValues:(int*)objectiveValues;
-(void) dealloc;
-(id) getState;
-(int) value;
-(int) minChildIndex;
-(int) maxChildIndex;
-(Node**) children;
-(int) getObjectiveValueFor: (int)index;
-(int) getNodeObjectiveValue: (int)value;
-(void) addChild:(Node*)child at:(int)index;
-(void) removeChildAt: (int) index;
-(int) findChildIndex: (Node*) child;
-(int) longestPath;
-(bool) hasLongestPathParent: (Node*)parent;
-(int) shortestPath;
-(bool) hasShortestPathParent: (Node*)parent;
-(TRId**) parents;
-(int) numParents;
-(void) addParent: (Node*) parent;
-(void) updateBoundsWithParent: (Node*) parent;
-(void) findNewLongestPath;
-(void) findNewShortestPath;
-(void) removeParentValue: (Node*) parent;
-(bool) isVital;
-(bool) isNonVitalAndChildless;
-(bool) isNonVitalAndParentless;
-(void) mergeWith:(Node*)other;
-(void) takeParentsFrom:(Node*)other;
-(bool) canChooseValue:(int)value;
-(void) mergeStateWith:(Node*)other;
@end

@interface GeneralState : NSObject {
@private
    int _variableIndex;
}
-(id) initState:(int)variableIndex;
-(id) initState:(GeneralState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue;
-(id) state;
-(char*) stateChar;
-(int) variableIndex;
-(bool) canChooseValue:(int)value;
-(void) mergeStateWith:(GeneralState*)other;
-(bool) stateAllows:(int)variable;
-(int) numPathsForVariable:(int)variable;
-(int) numPathsWithNextVariable:(int)variable;
@end

@interface AllDifferentState : NSObject {
@private
    NSMutableArray* _state;
    int _minValue;
    int _maxValue;
}
-(id) initAllDifferentState:(int)minValue :(int)maxValue;
-(id) initAllDifferentState:(int)minValue :(int)maxValue parentNodeState:(AllDifferentState*)parentNodeState withValue:(int)edgeValue;
-(id) state;
-(bool) canChooseValue:(int)value;
-(void) mergeStateWith:(AllDifferentState*)other;
-(bool) stateAllows:(int)variable;
@end

@interface MISPState : NSObject {
@private
    bool* _state;
    char* _stateChar;
    int _variableIndex;
    int _minValue;
    int _maxValue;
    bool** _adjacencyMatrix;
}
-(id) initState:(int)variableIndex :(int)minValue :(int)maxValue adjacencies:(bool**)adjacencyMatrix;
-(id) initState:(int)minValue :(int)maxValue parentNodeState:(MISPState*)parentNodeState withVariableIndex:(int)variableIndex withValue:(int)edgeValue adjacencies:(bool**)adjacencyMatrix;
-(bool*) state;
-(char*) stateChar;
-(int) variableIndex;
-(bool) canChooseValue:(int)value;
-(void) mergeStateWith:(MISPState*)other;
-(bool) stateAllows:(int)variable;
@end

@interface CPMDD : CPCoreConstraint {
@private
    TRInt **layer_variable_count;
    int _max_nodes_per_layer;
    bool _reduced;
    bool _maximize;
    int* _variable_to_layer;
    int* _layer_to_variable;
    bool* _variableUsed;
    Class _stateClass;
@protected
    id<CPIntVar> _objective;
    id<CPIntVarArray> _x;
    TRInt *layer_size;
    TRInt *max_layer_size;
    Node* **layers;
    int min_domain_val;
    int max_domain_val;
}
-(id) initCPMDD:(id<CPEngine>) engine over:(id<CPIntVarArray>)x reduced:(bool)reduced;
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize;
-(id) initCPMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(NSString*) description;
-(id<CPIntVarArray>) x;
-(void) post;
-(int) layerIndexForVariable:(int)variableIndex;
-(int) variableIndexForLayer:(int)layer;
-(int*) getObjectiveValuesForLayer:(int)layer;
-(void) createRootAndSink;
-(void) cleanLayer:(int)layer;
-(void) buildNewLayerUnder:(int)layer;
-(void) createChildrenForNode:(Node*)parentNode;
-(void) addPropagationsAndTrimValues;
-(void) trimValuesFromLayer:(ORInt)layer;
-(void) addPropagationToLayer:(ORInt)layer;
-(id) generateRootState:(int)variableValue;
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value;
-(void) addNode:(Node*)node toLayer:(int)layer_index;
-(void) removeNode: (Node*) node;
-(void) removeChildlessNodeFromMDD:(Node*)node trimmingVariables:(bool)trimming;
-(void) removeParentlessNodeFromMDD:(Node*)node trimmingVariables:(bool)trimming;
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value;

-(ORInt) recommendationFor: (ORInt) variableIndex;

-(void) printGraph;
@end

@interface CPMDDReduction : CPMDD
-(id) initCPMDDReduction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x;
@end

@interface CPMDDRestriction : CPMDD {
@private
    int restricted_size;
}
-(id) initCPMDDRestriction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize reduced:(bool)reduced;
-(id) initCPMDDRestriction: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize;
-(void) removeANodeFromLayer:(int)layer;
-(Node*) findNodeToRemove:(int)layer;
@end

@interface CPMDDRelaxation : CPMDD {
@private
    bool _relaxed;
    int relaxed_size;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass;
-(void) mergeTwoNodesOnLayer:(int)layer;
-(void) findNodesToMerge:(int)layer first:(Node**)first second:(Node**)second;
@end




@interface CPExactMDDAllDifferent : CPMDD
-(id) initCPExactMDDAllDifferent: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced;
@end

@interface CPRestrictedMDDAllDifferent : CPMDDRestriction
-(id) initCPRestrictedMDDAllDifferent: (id<CPEngine>) engine over: (id<CPIntVarArray>) x restrictionSize:(ORInt)restrictionSize reduced:(bool)reduced;
@end

@interface CPRelaxedMDDAllDifferent : CPMDDRelaxation
-(id) initCPRelaxedMDDAllDifferent: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced;
@end

@interface CPExactMDDMISP : CPMDD {
@private
    bool** _adjacencyMatrix;
    id<ORIntArray> _weights;
}
-(id) initCPExactMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<CPIntVar>)objectiveValue;
@end

@interface CPRestrictedMDDMISP : CPMDDRestriction {
@private
    bool** _adjacencyMatrix;
    id<ORIntArray> _weights;
}
-(id) initCPRestrictedMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x size:(ORInt)restrictionSize reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<CPIntVar>)objectiveValue;
@end

@interface CPRelaxedMDDMISP : CPMDDRelaxation {
@private
    bool** _adjacencyMatrix;
    id<ORIntArray> _weights;
}
-(id) initCPRelaxedMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x size:(ORInt)relaxationSize reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<CPIntVar>)objectiveValue;
@end

@interface CPCustomMDD : CPMDDRelaxation
-(id) initCPCustomMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize stateClass:(Class)stateClass;
@end

@interface CPCustomMDDWithObjective : CPMDDRelaxation
-(id) initCPCustomMDDWithObjective: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objectiveValue maximize:(bool)maximize stateClass:(Class)stateClass;
@end
