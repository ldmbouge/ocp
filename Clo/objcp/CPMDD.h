/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/objcp.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPGroup.h>

@class NodeHashTable;
@interface CPIRMDD : CPCoreConstraint {
@protected
    id<CPEngine> _engine;
    
    //State/Spec info
    MDDStateSpecification* _spec;
    size_t _numTopDownBytes;
    size_t _numBottomUpBytes;
    int _numSpecs;
    int _hashWidth;
    bool _dualDirectional;
    
    //Variable info
    id<CPIntVarArray> _x;
    NSUInteger _numVariables;
    int _minVariableIndex;
    int _nextVariable;

    //Layer info
    ORTRIdArrayI* __strong *_layers;
    int* _variableToLayer;
    int* _layerToVariable;
    TRInt** _layerVariableCount;
    TRInt* _layerSize;
    
    //Domain info
    int* _minDomainsByLayer;
    int* _maxDomainsByLayer;
    TRInt** _variableBitDomains;
    TRInt* _layerBound;
    
    //Propagation info
    bool _inPost;
    CPMDDQueue* _topDownQueue;
    CPMDDQueue* _bottomUpQueue;

    //Heuristic info
    int _relaxationSize;
    MDDRecommendationStyle _recommendationStyle;
    int _maxNumPasses;
    int _maxRebootDistance;
    
    //Objective info
    TRInt* _fixpointMinValues;
    TRInt* _fixpointMaxValues;
    id<CPIntVar> __strong *_fixpointVars;
    DDFixpointBoundClosure __strong *_fixpointMinFunctions;
    DDFixpointBoundClosure __strong *_fixpointMaxFunctions;
    bool _objectiveBoundsChanged;
}
-(id) initCPIRMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec recommendationStyle:(MDDRecommendationStyle)recommendationStyle gamma:(id*)gamma;
//Constraint info
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(NSString*) description;
-(id<CPIntVarArray>) x;

//MDD Creation
-(void) post;
-(void) setInitialFixpointRanges;
-(void) createRootAndSink;
-(void) assignVariableToLayer:(int)layer;
-(void) setDomainInfoForLayer:(int)layer;
-(int) pickNextVariable;
-(void) addNode:(MDDNode*)node toLayer:(int)layerIndex;
-(void) buildLayer:(int)layerIndex;
-(MDDNode*) createNodeWithProperties:(char*)properties onLayer:(int)layerIndex;

//Propagation
struct LayerInfo {
    int layerIndex;
    int variableIndex;
    TRInt* variableCount;
    TRInt* bitDomain;
    int minDomain;
    int maxDomain;
};
-(void) addPropagators;
-(void) addPropagatorForLayer:(int)layerIndex;
-(void) fillQueues;
-(void) updateAllLayers;
-(bool) updateLayer:(struct LayerInfo)info;
-(void) trimValue:(int)value fromLayer:(ORInt)layer_index;
-(void) updateVariableDomainForLayer:(ORInt)layer;
-(void) updateVariableDomains;

//Passes
-(void) bottomUpPass;
-(void) topDownPassWithSplit;
-(void) topDownPassWithoutSplit;
-(void) enqueueRelativesOf:(MDDNode*)node;
-(void) enqueueChildrenOf:(MDDNode*)node;
-(void) enqueueParentsOf:(MDDNode*)node;
-(void) enqueueNode:(MDDNode*)node;
-(bool) refreshBottomUpStateFor:(MDDNode*)node;
-(bool) refreshTopDownStateFor:(MDDNode*)node;
-(bool) refreshStateFor:(MDDNode*)node;
-(char*) computeBottomUpStateFromChildrenOf:(MDDNode*)node;
-(int) fillNodeArcVarsFromChildrenOfNode:(MDDNode*)node childNodes:(MDDNode**)childNodes arcValuesByChild:(ORIntSetI**)arcValuesByChild;
-(char*) computeBottomUpStateFromChildren:(MDDNode**)children arcValueSets:(ORIntSetI**)arcValuesByChild numChildren:(int)numChildNodes;
-(char*) computeStateFromChild:(MDDNode*)child arcValues:(ORIntSetI*)arcValues;
-(bool) stateExistsFor:(MDDNode*)node;
-(void) updateChildrenOf:(MDDNode*)node stateChanged:(bool)stateChanged;
-(void) splitLayer:(int)layer;
-(void) splitNode:(MDDNode*)node layerInfo:(struct LayerInfo)layerInfo;
-(void) splitArc:(MDDArc*)parentArc oldChildArcs:(MDDArc**)oldChildArcs layerInfo:(struct LayerInfo)layerInfo addToHashTable:(NodeHashTable*)nodeHashTable oldBottomUp:(char*)bottomUp;
-(bool) checkChildrenOfNewNode:(MDDNode*)node withOldChildren:(MDDArc**)oldChildArcs layerInfo:(struct LayerInfo)layerInfo;
-(bool) checkChildOfNewNode:(MDDNode*)node oldArc:(MDDArc*)oldChildArc alreadyFoundChildren:(bool)hasChildren layerInfo:(struct LayerInfo)layerInfo;
-(void) connectParents:(ORTRIdArrayI*)parentArcs ofNode:(MDDNode*)node toEquivalentStatesIn:(NodeHashTable*)nodeHashTable;


//Node removal
-(void) deleteInnerNode:(MDDNode*)node;
-(void) removeParentlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer;
-(void) checkChildrenOfParentlessNode:(MDDNode*)node parentLayer:(int)layer;
-(void) removeChildlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer;
-(void) checkParentsOfChildlessNode:(MDDNode*)node parentLayer:(int)layer;
-(void) removeNode:(MDDNode*)node onLayer:(int)layerIndex;
-(void) removeNodeAt:(int)index onLayer:(int)layerIndex;

//Objective values
-(void) recordObjectiveBounds;
-(void) updateObjectiveBounds;
-(void) updateObjectiveVars;

-(ORInt) recommendationFor:(id<CPIntVar>)x;

//Debug functions
-(void) DEBUGcheckNodeLayerIndexCorrectness;
@end

@interface NodeHashTable : NSObject {
    char** *_statePropertiesLists;
    int* _numPerHash;
    int* _maxPerHash;
    int _width;
    NSUInteger _lastCheckedHash;
    size_t _numBytes;
}
@property MDDStateValues* __strong **stateLists;
-(id) initNodeHashTable:(int)width numBytes:(size_t)numBytes;
-(bool) hasNodeWithStateProperties:(char*)stateProperties hashValue:(NSUInteger)hash node:(MDDNode**)existingNode;
-(void) addState:(MDDStateValues*)state;
@end
