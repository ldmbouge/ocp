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
#import <objcp/CPMDDNode.h>
#import <objcp/CPMDDHashTables.h>
#import <objcp/CPMDDQueue.h>

@interface CPIRMDD : CPCoreConstraint {
@protected
    id<CPEngine> _engine;
    
    //State/Spec info
    MDDStateSpecification* _spec;
    int _numForwardBytes;
    int _numReverseBytes;
    int _numCombinedBytes;
    int _numSpecs;
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
    
    //Domain info
    int* _minDomainsByLayer;
    int* _maxDomainsByLayer;
    TRInt** _layerBitDomains;
    TRInt* _layerBound;
    
    //Propagation info
    bool _inPost;
    CPMDDQueue* _forwardQueue;
    CPMDDQueue* _reverseQueue;
    
    //Splitting queues
    ORPQueue* _candidateSplits;
    ORPQueue* _splittableNodes;

    //Heuristic info
    int _relaxationSize;
    MDDRecommendationStyle _recommendationStyle;
    int _maxNumPasses;
    int _maxRebootDistance;
    
    //Split heuristic info
    bool _cacheForwardOnArcs;
    bool _splitAllLayersBeforeFiltering;
    bool _splitByConstraint;
    bool _fullySplitNodeFirst;
    bool _rankNodesForSplitting;
    bool _useDefaultNodeRank;
    bool _rankArcsForSplitting;
    bool _useDefaultArcRank;
    bool _approximateEquivalenceClasses;
    
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
-(void) reversePass;
-(void) forwardPassOnlySplit;
-(void) forwardPassWithSplit;
-(void) forwardPassWithoutSplit;
-(void) enqueueRelativesOf:(MDDNode*)node;
-(void) enqueueChildrenOf:(MDDNode*)node;
-(void) enqueueParentsOf:(MDDNode*)node;
-(void) enqueueNode:(MDDNode*)node;
-(bool) refreshReverseStateFor:(MDDNode*)node;
-(bool) refreshForwardStateFor:(MDDNode*)node;
-(bool) updateCombinedStateFor:(MDDNode*)node;
-(char*) computeForwardStateFromArcs:(NSArray*)arcs isMerged:(bool*)merged layerInfo:(struct LayerInfo)layerInfo;
-(char*) computeForwardStateFromParentsOf:(MDDNode*)node isMerged:(bool*)merged;
-(char*) computeReverseStateFromChildrenOf:(MDDNode*)node;
-(int) fillNodeArcVarsUsingArcs:(NSArray*)arcs parentNodes:(MDDNode**)parentNodes arcValuesByParent:(bool**)arcValuesByParent parentLayerIndex:(int)parentLayer;
-(int) fillNodeArcVarsFromParentsOfNode:(MDDNode*)node parentNodes:(MDDNode**)parentNodes arcValuesByParent:(bool**)arcValuesByParent;
-(char*) computeForwardStateFromParents:(MDDNode**)parents arcValueSets:(bool**)arcValuesByParent numParents:(int)numParentNodes minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged;
-(char*) computeStateFromParent:(MDDNode*)parent arcValues:(bool*)arcValues minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged;
-(int) fillNodeArcVarsFromChildrenOfNode:(MDDNode*)node childNodes:(MDDNode**)childNodes arcValuesByChild:(bool**)arcValuesByChild;
-(char*) computeReverseStateFromChildren:(MDDNode**)children arcValueSets:(bool**)arcValuesByChild numChildren:(int)numChildNodes minDom:(int)minDom maxDom:(int)maxDom;
-(char*) computeStateFromChild:(MDDNode*)child arcValues:(bool*)arcValues minDom:(int)minDom maxDom:(int)maxDom;
-(bool) stateExistsFor:(MDDNode*)node;
-(void) updateChildrenOf:(MDDNode*)node stateChanged:(bool)stateChanged;
-(void) splitLayer:(int)layer;
-(bool) noMergedNodesOnLayer:(int)layerIndex;
-(void) emptySplittingQueues;
-(void) splitLayer:(struct LayerInfo)layerInfo forConstraint:(int)c;
-(void) splitRankedLayer:(struct LayerInfo)layerInfo forConstraint:(int)c;
-(void) splitNode:(MDDNode *)node layerInfo:(struct LayerInfo)layerInfo forConstraint:(int)c;
-(MDDNode*) splitArc:(char*)arcState layerInfo:(struct LayerInfo)layerInfo;
-(void) splitCandidatesOnLayer:(struct LayerInfo)layerInfo;
-(MDDNode*)findExactMatchForState:(char*)state onLayer:(struct LayerInfo)layerInfo;
-(bool) checkChildrenOfNewNode:(MDDNode*)node withOldChildren:(MDDArc**)oldChildArcs layerInfo:(struct LayerInfo)layerInfo;
-(bool) checkChildOfNewNode:(MDDNode*)node oldArc:(MDDArc*)oldChildArc alreadyFoundChildren:(bool)hasChildren layerInfo:(struct LayerInfo)layerInfo;


//Node removal
-(void) deleteInnerNode:(MDDNode*)node;
-(void) removeParentlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer;
-(void) checkChildrenOfParentlessNode:(MDDNode*)node parentLayer:(int)layer;
-(void) removeChildlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer;
-(void) checkParentsOfChildlessNode:(MDDNode*)node parentLayer:(int)layer;
-(void) deleteArcWhileCheckingParent:(MDDArc*)arc parentLayer:(int)layer;
-(void) removeNode:(MDDNode*)node onLayer:(int)layerIndex;
-(void) removeNodeAt:(int)index onLayer:(int)layerIndex;

//Objective values
-(void) recordObjectiveBounds;
-(void) updateObjectiveBounds;
-(void) updateObjectiveVars;

-(ORInt) recommendationFor:(id<CPIntVar>)x;

//Debug functions
-(void) DEBUGcheckNodeLayerIndexCorrectness;
-(void) DEBUGcheckQueueCounts;
-(void) DEBUGcheckArcPointerConsistency;
-(void) DEBUGcheckQueuesHaveNoDeletedNodes;
-(void) DEBUGcheckNodesInQueueMarkedInQueue;
@end
