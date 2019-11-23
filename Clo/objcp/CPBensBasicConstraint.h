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
    ORTRIdArrayI* _parents;
    TRInt _numParents;
    TRInt _maxNumParents;
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
    
    TRInt _isRelaxed;
    
    TRId _state;
}
-(id) initNode: (id<ORTrail>) trail;
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state;
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state objectiveValues:(int*)objectiveValues;
-(void) dealloc;
-(id) getState;
-(int) value;
-(int) minChildIndex;
-(int) maxChildIndex;
-(TRId*) children;
-(int) getObjectiveValueFor: (int)index;
-(int) getNodeObjectiveValue: (int)value;
-(void) addChild:(Node*)child at:(int)index;
-(void) removeChildAt: (int) index;
-(int) findChildIndex: (Node*) child;
-(int) longestPath;
-(bool) hasLongestPathParent: (Node*)parent;
-(int) shortestPath;
-(bool) hasShortestPathParent: (Node*)parent;
-(ORTRIdArrayI*) parents;
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
-(void) setRelaxed:(bool)relaxed;
-(bool) isRelaxed;
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

@interface CPAltMDD : CPCoreConstraint {
@private
    bool _maximize;
@protected
    Class _stateClass;
    TRInt **layer_variable_count;
    int* _variable_to_layer;
    int* _layer_to_variable;
    bool* _variableUsed;
    bool _hasObjective;
    id<CPIntVarArray> _x;
    TRInt *layer_size;
    TRInt *max_layer_size;
    TRId **layers;
    int min_domain_val;
    int max_domain_val;
    NSUInteger _numVariables;
}
-(id) initCPAltMDD:(id<CPEngine>) engine over:(id<CPIntVarArray>)x;
-(id) initCPAltMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x stateClass:(Class)stateClass;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(NSString*) description;
-(id<CPIntVarArray>) x;
-(void) post;
-(bool) calculateTopDownInfoFor:(Node*)node onLayer:(int)layerIndex;
-(bool) calculateBottomUpInfoFor:(Node*)node onLayer:(int)layerIndex;
-(void) createWidthOneMDD;
-(void) buildOutMDD;
-(void) createRootAndSink;
-(void) buildNewLayerUnder:(int)layer;
-(void) addNode:(Node*)node toLayer:(int)layer_index;
-(int) layerIndexForVariable:(int)variableIndex;
-(int) variableIndexForLayer:(int)layer;
-(int) pickVariableBelowLayer:(int)layer;
-(void) removeNodeAt:(int)index onLayer:(int)layer_index;
-(void) removeNode: (Node*) node;
-(void) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming;
-(void) removeParentlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming;
-(void) addPropagationsAndTrimValues;
-(void) trimValuesFromLayer:(ORInt)layer;
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value;
@end
@interface CPMDD : CPCoreConstraint {
@private
    bool _maximize;
    Class _stateClass;
    int _nextVariable;
@protected
    int _hashTableSize;
    TRInt **layer_variable_count;
    int* _variable_to_layer;
    int* _layer_to_variable;
    bool* _variableUsed;
    id<CPIntVar> _objective;
    id<CPIntVarArray> _x;
    bool _reduced;
    TRInt *layer_size;
    TRInt *max_layer_size;
    TRId **layers;
    int min_domain_val;
    int max_domain_val;
    NSUInteger _numVariables;
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
-(int) pickVariableBelowLayer:(int)layer;
-(int*) getObjectiveValuesForLayer:(int)layer;
-(void) createRootAndSink;
-(void) cleanLayer:(int)layer;
-(void) buildNewLayerUnder:(int)layer;
-(void) createChildrenForNode:(Node*)parentNode nodeHashes:(NSDictionary*)hashValues;
-(void) addPropagationsAndTrimValues;
-(void) trimValuesFromLayer:(ORInt)layer;
-(void) addPropagationToLayer:(ORInt)layer;
-(id) generateRootState:(int)variableValue;
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value;
-(void) addNode:(Node*)node toLayer:(int)layer_index;
-(void) removeNodeAt:(int)index onLayer:(int)layer_index;
-(void) removeNode: (Node*) node;
-(void) removeChildlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming;
-(void) removeParentlessNodeFromMDD:(Node*)node fromLayer:(int)layer trimmingVariables:(bool)trimming;
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value;
-(void) DEBUGTestLayerVariableCountCorrectness;

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

@interface CPAltMDDRelaxation : CPAltMDD {
@private
    bool _relaxed;
    int _relaxation_size;
    TRInt *_layer_relaxed;
    TRInt **node_relaxed;
}
-(id) initCPAltMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize;
-(id) initCPAltMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass;
-(NSArray*) findEquivalenceClassesIntoNode:(int)nodeIndex onLayer:(int)layerIndex;
-(NSArray*) findEquivalenceClasses:(int)layerIndex;
@end

@interface CPMDDRelaxation : CPMDD {
@private
    bool _relaxed;
    int _relaxation_size;
    TRInt _first_relaxed_layer;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize stateClass:(Class)stateClass;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass;
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass;
-(void) mergeTwoNodesOnLayer:(int)layer;
-(void) findNodesToMerge:(int)layer first:(Node**)first second:(Node**)second;
//-(void) splitNodes:(int)layer;
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

@interface CPCustomAltMDD : CPAltMDDRelaxation
-(id) initCPCustomAltMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize stateClass:(Class)stateClass;
@end
@interface CPCustomMDD : CPMDDRelaxation
-(id) initCPCustomMDD: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize stateClass:(Class)stateClass;
@end

@interface CPCustomMDDWithObjective : CPMDDRelaxation
-(id) initCPCustomMDDWithObjective: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxed:(bool)relaxed size:(ORInt)relaxationSize reduced:(bool)reduced objective:(id<CPIntVar>)objectiveValue maximize:(bool)maximize stateClass:(Class)stateClass;
@end
