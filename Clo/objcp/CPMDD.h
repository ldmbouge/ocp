/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPGroup.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPMDDQueue.h>

struct LayerInfo {
    int layerIndex;
    int variableIndex;
    TRInt* variableCount;
    TRInt* bitDomain;
    int minDomain;
    int maxDomain;
};

typedef bool* (*DiffPropertyIMP)(id,SEL,char*, char*);
@interface CPIRMDD : CPCoreConstraint {
@protected
    id<CPEngine> _engine;
    
    //State/Spec info
    MDDStateSpecification* _spec;
    int _numForwardBytes;
    int _numReverseBytes;
    int _numCombinedBytes;
    int _numSpecs;
    int _minConstraintPriority;
    int _maxConstraintPriority;
    int _hashWidth;
    bool _dualDirectional;
    
    //Variable info
    id<CPIntVarArray> _x;
    NSUInteger _numVariables;
    int _minVariableIndex;
    int _nextVariable;
    TRInt _firstMergedLayer;
    TRInt _lastMergedLayer;

    //Layer info
    ORTRIdArrayI* __strong *_layers;
    int* _variableToLayer;
    int* _layerToVariable;
    TRInt** _layerVariableCount;
    TRInt* _layerSize;
    struct LayerInfo* _layerInfos;
    
    //Domain info
    int* _minDomainsByLayer;
    int* _maxDomainsByLayer;
    TRInt** _layerBitDomains;
    TRInt* _layerBound;
    
    //Propagation info
    bool _inPost;
    CPMDDQueue* _forwardQueue;
    CPMDDQueue* _reverseQueue;
    CPMDDDeletionQueue* _forwardDeletionQueue;
    CPMDDDeletionQueue* _reverseDeletionQueue;
    
    //Reused variables
    MDDNode* __strong *_nodes;
    bool** _arcValuesByNode;
    int* _numArcsPerNode;
    bool** _deltas;
    
    //Splitting queues
    ORPQueue* _candidateSplits;
    ORPQueue* _splittableNodes;

    //Heuristic info
    int _relaxationSize;
    int* _relaxationSizes;
    MDDRecommendationStyle _recommendationStyle;
    int _passIteration;
    int _maxSplitIter;
    int _maxRebootDistance;
    
    //Split heuristic info
    bool _cacheForwardOnArcs;
    bool _cacheReverseOnArcs;
    bool _splitAllLayersBeforeFiltering;
    bool _useDefaultNodeRank;
    bool _useDefaultArcRank;
    bool _approximateEquivalenceClasses;
    bool _additionalExactSplit;
    bool _additionalSplitByLayer;
    bool _useStateExistence;
    int _numNodesSplitAtATime;
    bool _numNodesDefinedAsPercent;
    bool _variableRelaxationSize;
    
    ArcHashTable* _forwardArcHashTable;
    ArcHashTable* _reverseArcHashTable;
    int _splitPass;
    
    //Objective info
    bool _objectiveVarsUsed;
    TRInt* _fixpointMinValues;
    TRInt* _fixpointMaxValues;
    id<CPIntVar> __strong *_fixpointVars;
    DDFixpointBoundClosure __strong *_fixpointMinFunctions;
    DDFixpointBoundClosure __strong *_fixpointMaxFunctions;
    bool _objectiveBoundsChanged;
    
    //Function calls
    SEL _diffForwardSel;
    DiffPropertyIMP _diffForward;
    SEL _diffReverseSel;
    DiffPropertyIMP _diffReverse;
}
-(id) initCPIRMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec recommendationStyle:(MDDRecommendationStyle)recommendationStyle splitAllLayersBeforeFiltering:(bool)splitAllLayersBeforeFiltering maxSplitIter:(int)maxSplitIter maxRebootDistance:(int)maxRebootDistance useStateExistence:(bool)useStateExistence  numNodesSplitAtATime:(int)numNodesSplitAtATime numNodesDefinedAsPercent:(bool)numNodesDefinedAsPercent splittingStyle:(int)splittingStyle gamma:(id*)gamma;
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
-(MDDNode*) createNodeWithEmptyPropertiesOnLayer:(int)layerIndex;

//Propagation
-(void) addPropagators;
-(void) addPropagatorForLayer:(int)layerIndex;
-(void) propagate;
-(void) fillQueues;
-(void) updateAllLayers;
-(bool) updateLayer:(struct LayerInfo)info;
-(void) trimValue:(int)value fromLayer:(ORInt)layer_index;
-(void) updateVariableDomainForLayer:(ORInt)layer;
-(void) updateVariableDomains;

//Passes
-(void) reversePass;
-(void) reversePassOnlySplit;
-(void) forwardPassOnlySplit;
-(void) forwardPassWithSplit;
-(void) forwardPassWithoutSplit;
-(int) secondPassOnLayer:(int)layerIndex;
-(bool) candidateLayerForSplitting:(int)layer;
-(void) checkForwardDeletionOnLayer:(int)layer;
-(void) checkReverseDeletionOnLayer:(int)layer;
-(int) forwardPassCheckDeletion;
-(int) reversePassCheckDeletion;
-(void) updateNodeForward:(MDDNode*)node layer:(int)layer;
-(void) updateNodeReverse:(MDDNode*)node layer:(int)layer;
-(void) enqueueRelativesOf:(MDDNode*)node;
-(void) enqueueChildrenOf:(MDDNode*)node;
-(void) enqueueParentsOf:(MDDNode*)node;
-(void) enqueueNode:(MDDNode*)node;
-(bool) refreshReverseStateFor:(MDDNode*)node;
-(bool) refreshForwardStateFor:(MDDNode*)node;
-(bool) updateCombinedStateFor:(MDDNode*)node;
-(char*) computeForwardStateFromArcs:(NSArray*)arcs isMerged:(bool*)merged layerInfo:(struct LayerInfo)layerInfo;
-(char*) computeReverseStateFromArcs:(NSArray*)arcs isMerged:(bool*)merged layerInfo:(struct LayerInfo)layerInfo;
-(char*) computeForwardStateFromParentsOf:(MDDNode*)node isMerged:(bool*)merged;
-(char*) updateForwardStateFromParentsOf:(MDDNode*)node isMerged:(bool*)merged;
-(char*) computeReverseStateFromChildrenOf:(MDDNode*)node isMerged:(bool*)merged;
-(char*) updateReverseStateFromChildrenOf:(MDDNode*)node isMerged:(bool*)merged;
-(int) fillNodeArcVarsUsingArcs:(NSArray*)arcs parentLayerIndex:(int)parentLayer;
-(int) fillNodeArcVarsUsingArcs:(NSArray*)arcs childLayerIndex:(int)childLayer;
-(int) fillNodeArcVarsFromParentsOfNode:(MDDNode*)node;
-(char*) computeForwardStateFromNumParents:(int)numParentNodes minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged;
-(char*) updateForwardStateFromNumParents:(int)numParentNodes minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged;
-(char*) computeStateFromParent:(MDDNode*)parent arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged;
-(char*) updateStateFromParent:(MDDNode*)parent arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged;
-(int) fillNodeArcVarsFromChildrenOfNode:(MDDNode*)node;
-(char*) computeReverseStateFromNumChildren:(int)numChildNodes minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged;
-(char*) updateReverseStateFromNumChildren:(int)numChildNodes minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged;
-(char*) computeStateFromChild:(MDDNode*)child arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged;
-(char*) updateStateFromChild:(MDDNode*)child arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged;
-(bool) stateExistsFor:(MDDNode*)node;
-(void) updateParentsOf:(MDDNode*)node;
-(void) updateChildrenOf:(MDDNode*)node stateChanged:(bool)stateChanged;
-(void) splitLayer:(int)layer forward:(bool)forward;
-(void) updateFirstAndLastMergedLayersAfterSplitting:(int)layer;
-(bool) noMergedNodesOnLayer:(int)layerIndex;
-(void) emptySplittingQueues;
-(void) fillSplittableNodesForLayer:(int)layer atPriority:(int)priority forward:(bool)forward;
-(void) forwardSplitNode:(MDDNode *)node layerInfo:(struct LayerInfo)layerInfo priorityLevel:(int)c;
-(void) reverseSplitNode:(MDDNode *)node layerInfo:(struct LayerInfo)layerInfo priorityLevel:(int)c;
-(void) forwardSplitCandidatesOnLayer:(struct LayerInfo)layerInfo;
-(void) reverseSplitCandidatesOnLayer:(struct LayerInfo)layerInfo;
-(NSNumber*) keyForNode:(MDDNode*)node priority:(int)priority forward:(bool)forward;
-(MDDNode*)findExactMatchForState:(char*)state onLayer:(struct LayerInfo)layerInfo;
-(bool) checkChildrenOfNewNode:(MDDNode*)node withOldChildren:(MDDArc**)oldChildArcs layerInfo:(struct LayerInfo)layerInfo;
-(bool) checkChildOfNewNode:(MDDNode*)node oldArc:(MDDArc*)oldChildArc alreadyFoundChildren:(bool)hasChildren layerInfo:(struct LayerInfo)layerInfo;


//Node removal
-(void) deleteInnerNode:(MDDNode*)node;
-(void) removeParentlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer;
-(void) checkChildrenOfParentlessNode:(MDDNode*)node parentLayer:(int)layer;
-(void) removeChildlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer;
-(void) checkParentsOfChildlessNode:(MDDNode*)node parentLayer:(int)layer;
-(void) deleteArcWhileCheckingChild:(MDDArc*)arc childLayer:(int)layer;
-(void) deleteArcWhileCheckingParent:(MDDArc*)arc parentLayer:(int)layer;
-(void) removeNode:(MDDNode*)node onLayer:(int)layerIndex;
-(void) removeNodeAt:(int)index onLayer:(int)layerIndex;

//Objective values
-(void) recordObjectiveBounds;
-(void) updateObjectiveBounds;
-(void) updateObjectiveVars;

-(ORInt) recommendationFor:(id<CPIntVar>)x;

//Debug functions
-(void) DEBUGcheckLayerVariableCountCorrectness;
-(void) DEBUGcheckNodeLayerIndexCorrectness;
-(void) DEBUGcheckQueueCounts;
-(void) DEBUGcheckArcPointerConsistency;
-(void) DEBUGcheckQueuesHaveNoDeletedNodes;
-(void) DEBUGcheckNodesInQueueMarkedInQueue;
-(void) DEBUGcheckNoParentlessNodes;
-(void) DEBUGcheckNoChildlessNodes;
-(void) drawGraph;
@end
