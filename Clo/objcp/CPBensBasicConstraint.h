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

@interface CPFiveGreater : CPCoreConstraint {
@private
   CPIntVar*  _x;
   CPIntVar*  _y;
}
-(id) initCPFiveGreater: (id<CPIntVar>) x and: (id<CPIntVar>) y;
-(void) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface Node : NSObject {
@private
    Node* *_children;
    TRInt _numChildren;
    int _minChildIndex;
    int _maxChildIndex;
    NSMutableSet* _parents;  //Change this to an array of parents maybe?  Will be easy to do once we aren't doing an exact MDD
    int _value;
    bool _isSink;
    bool _isSource;
    id<ORTrail> _trail;
    
    id _state;
}
-(id) initNode: (id<ORTrail>) trail;
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex value:(int) value state:(id)state;
-(void) dealloc;
-(id) getState;
-(int) value;
-(Node**) children;
-(void) addChild:(Node*)child at:(int)index;
-(void) removeChildAt: (int) index;
-(int) findChildIndex: (Node*) child;
-(NSSet*) parents; //Probably a different structure
-(void) addParent: (Node*) parent;
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
    NSMutableArray* _state;
}
-(id) initGeneralState;
-(id) initGeneralState:(GeneralState*)parentNodeState withValue:(int)edgeValue;
-(id) state;
-(bool) canChooseValue:(int)value;
-(void) mergeStateWith:(GeneralState*)other;
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
@end

@interface MISPState : NSObject {
@private
    NSMutableArray* _state;
    int _layerValue;
    int _minValue;
    int _maxValue;
}
-(id) initMISPState:(int)layerValue :(int)minValue :(int)maxValue;
-(id) initMISPState:(int)minValue :(int)maxValue parentNodeState:(MISPState*)parentNodeState withValue:(int)edgeValue adjacencies:(bool**)adjacencyMatrix;
-(id) state;
-(int) layerValue;
-(bool) canChooseValue:(int)value;
-(void) mergeStateWith:(MISPState*)other;
@end

@interface CPMDD : CPCoreConstraint<ORSearchObjectiveFunction> {
@private
    TRInt **layer_variable_count;
    int _max_nodes_per_layer;
    bool _reduced;
@protected
    id<CPIntVarArray> _x;
    TRInt *layer_size;
    Node* **layers;
    int min_domain_val;
    int max_domain_val;
}
-(id) initCPMDD:(id<CPEngine>) engine over:(id<CPIntVarArray>)x reduced:(bool)reduced;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(NSString*) description;
-(id<CPIntVarArray>) x;
-(void) post;
-(void) createRootAndSink;
-(void) cleanLayer:(int)layer;
-(void) buildNewLayerUnder:(int)layer;
-(void) createChildrenForNode:(Node*)parentNode;
-(void) addPropagationsAndTrimValues;
-(void) trimValuesFromLayer:(ORInt)layer;
-(void) addPropagationToLayer:(ORInt)layer;
-(id) generateRootState:(int)layerValue;
-(id) generateStateFromParent:(Node*)parentNode withValue:(int)value;
-(void) addNode:(Node*)node toLayer:(int)layer_index;
-(void) removeNode: (Node*) node;
-(void) removeChildlessNodeFromMDD:(Node*)node trimmingVariables:(bool)trimming;
-(void) removeParentlessNodeFromMDD:(Node*)node trimmingVariables:(bool)trimming;
-(void) trimValueFromLayer: (ORInt) layer_index :(int) value;
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
-(void) removeANodeFromLayer:(int)layer;
-(Node*) findNodeToRemove:(int)layer;
@end

@interface CPMDDRelaxation : CPMDD {
@private
    int relaxed_size;
}
-(id) initCPMDDRelaxation: (id<CPEngine>) engine over: (id<CPIntVarArray>) x relaxationSize:(ORInt)relaxationSize reduced:(bool)reduced;
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
}
-(id) initCPExactMDDMISP: (id<CPEngine>) engine over: (id<CPIntVarArray>) x reduced:(bool)reduced adjacencies:(bool**)adjacencyMatrix;
@end
