/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngineI.h>
#import <objcp/CPMDD.h>

static inline id getForwardState(MDDNode* n) { return n->_forwardState;}
static inline id getReverseState(MDDNode* n) { return n->_reverseState;}
static inline id getCombinedState(MDDNode* n) { return n->_combinedState;}
@implementation CPIRMDD
-(id) initCPIRMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec recommendationStyle:(MDDRecommendationStyle)recommendationStyle gamma:(id*)gamma {
    self = [super initCPCoreConstraint: engine];
    
    _engine = engine;
    
    //State/Spec info
    _spec = [spec retain];
    _hashWidth = relaxationSize * 2;
    [_spec finalizeSpec:_trail hashWidth:_hashWidth];
    _numSpecs = [_spec numSpecs];
    _numForwardBytes = [_spec numForwardBytes];
    _numReverseBytes = [_spec numReverseBytes];
    _numCombinedBytes = [_spec numCombinedBytes];
    _dualDirectional = [_spec dualDirectional];
    
    //Variable info
    _x = x;
    _numVariables = [_x count];
    _nextVariable = _minVariableIndex = [_x low];
    _firstMergedLayer = makeTRInt(_trail, 1);
    _lastMergedLayer = makeTRInt(_trail, (int)_numVariables-1);
    
    //Layer info
    _layers = (ORTRIdArrayI* __strong *)calloc(sizeof(ORTRIdArrayI*), _numVariables+1);
    _layerToVariable = malloc((_numVariables) * sizeof(int));
    _variableToLayer = malloc((_numVariables) * sizeof(int));
    _variableToLayer -= _minVariableIndex;
    _layerVariableCount = malloc((_numVariables) * sizeof(TRInt*));
    _layerSize = malloc((_numVariables+1) * sizeof(TRInt));
    for (int i = 0; i <= _numVariables; i++) {
        _layerSize[i] = makeTRInt(_trail,0);
        _layers[i] = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:relaxationSize];
    }
    
    //Domain info
    _minDomainsByLayer = malloc(_numVariables * sizeof(int));
    _maxDomainsByLayer = malloc(_numVariables * sizeof(int));
    _layerBitDomains = malloc(_numVariables * sizeof(TRInt*));
    _layerBound = malloc(_numVariables * sizeof(TRInt));
    
    //Splitting queues
    _candidateSplits = [[ORPQueue alloc] init:^BOOL(NSNumber* a, NSNumber* b) {
        return [a intValue] >= [b intValue];
    }];
    _splittableNodes = [[ORPQueue alloc] init:^BOOL(NSNumber* a, NSNumber* b) {
        return [a intValue] >= [b intValue];
    }];
    
    //Heuristic info
    _relaxationSize = relaxationSize;
    _recommendationStyle = recommendationStyle;
    _maxNumPasses = 5*_relaxationSize;
    _maxRebootDistance = 0;
    
    _splitAllLayersBeforeFiltering = false;
    _splitByConstraint = false;
    _fullySplitNodeFirst = true;
    _rankNodesForSplitting = true;
    _useDefaultNodeRank = true;
    _rankArcsForSplitting = false;
    _useDefaultArcRank = true;
    _approximateEquivalenceClasses = true;
    
    //Objective info
    _fixpointMinValues = malloc(_numSpecs * sizeof(TRInt));
    _fixpointMaxValues = malloc(_numSpecs * sizeof(TRInt));
    id<ORIntVar>* fixpointVars = [_spec fixpointVars];
    _fixpointVars = (id<CPIntVar> __strong *)calloc(sizeof(id<CPIntVar>), _numSpecs);
    for (int i = 0; i < _numSpecs; i++) {
        if (fixpointVars[i] != nil) {
            _fixpointVars[i] = gamma[[fixpointVars[i] getId]];
        }
    }
    _fixpointMinFunctions = (DDFixpointBoundClosure __strong *)[_spec fixpointMins];
    _fixpointMaxFunctions = (DDFixpointBoundClosure __strong *)[_spec fixpointMaxes];
    
    _forwardQueue = [[CPMDDQueue alloc] initCPMDDQueue:(int)_numVariables+1 width:_relaxationSize isForward:true];
    _reverseQueue = [[CPMDDQueue alloc] initCPMDDQueue:(int)_numVariables+1 width:_relaxationSize isForward:false];
    
    return self;
}
-(void) dealloc {
    [_spec release];
    
    for (int i = 0; i < _numVariables; i++) {
        if (_layers[i] == nil) break;
        [_layers[i] release];
        _layers[i] = nil;
        _layerVariableCount[i] += _minDomainsByLayer[i];
        free(_layerVariableCount[i]);
        free(_layerBitDomains[i]);
    }
    [_layers[_numVariables] release];
    free(_layers);
    free(_layerSize);
    free(_layerToVariable);
    _variableToLayer += _minVariableIndex;
    free(_variableToLayer);
    
    free(_layerBitDomains);
    free(_minDomainsByLayer);
    free(_maxDomainsByLayer);
    free(_layerBound);
    
    [_forwardQueue release];
    [_reverseQueue release];
    
    for (int i = 0; i < _numSpecs; i++) {
        _fixpointVars[i] = nil;
    }
    free(_fixpointVars);
    free(_fixpointMinValues);
    free(_fixpointMaxValues);
    
    [_candidateSplits release];
    [_splittableNodes release];
    
    [super dealloc];
}



-(NSSet*)allVars { return [[[NSSet alloc] initWithObjects:_x,nil] autorelease]; }
-(ORUInt)nbUVars {
    ORUInt nb = 0;
    for(ORInt var = 0; var< _numVariables; var++)
        nb += !bound((CPIntVar*)[_x at: var]);
    return nb;
}
-(id<CPIntVarArray>) x { return _x; }
-(NSString*)description { return [NSMutableString stringWithFormat:@"<CPMDD:%02d %@>",_name,_x]; }



-(void) post {
    _inPost = true;
    
    [self setInitialFixpointRanges];
    [self createRootAndSink];
    int layer;
    for (layer = 1; layer < _numVariables; layer++) {
        [self assignVariableToLayer:layer];
        [self buildLayer:layer];
    }
    [self buildLayer:layer];
    
    [self fillQueues];
    [self reversePass];
    
    [self addPropagators];
    
    _inPost = false;
    return;
}
-(void) setInitialFixpointRanges {
    for (int i = 0; i < _numSpecs; i++) {
        if (_fixpointVars[i] != nil) {
            _fixpointMinValues[i] = makeTRInt(_trail, [_fixpointVars[i] min]);
            _fixpointMaxValues[i] = makeTRInt(_trail, [_fixpointVars[i] max]);
        } else {
            _fixpointMinValues[i] = makeTRInt(_trail, INT_MIN);
            _fixpointMaxValues[i] = makeTRInt(_trail, INT_MAX);
        }
    }
}
-(void) createRootAndSink {
    [self assignVariableToLayer:0];
    
    MDDStateValues* rootState = [_spec createRootState];
    MDDNode* root = [[MDDNode alloc] initNode:_trail minChildIndex:_minDomainsByLayer[0] maxChildIndex:_maxDomainsByLayer[0] state:rootState layer:0 indexOnLayer:0 numReverseBytes:_numReverseBytes numCombinedBytes:_numCombinedBytes];
    [self addNode:root toLayer:0];
    [rootState release];
    [root release];
    
    MDDStateValues* sinkState = [_spec createSinkState];
    MDDNode* sink = [[MDDNode alloc] initSinkNode:_trail defaultReverseState:sinkState layer:(int)_numVariables numForwardBytes:_numForwardBytes numCombinedBytes:_numCombinedBytes];
    [self addNode:sink toLayer:((int)_numVariables)];
    [sinkState release];
    [sink release];
}
-(void) assignVariableToLayer:(int)layer {
    _variableToLayer[_nextVariable] = layer;
    _layerToVariable[layer] = _nextVariable;
    
    [self setDomainInfoForLayer:layer];
    
    _nextVariable = [self pickNextVariable];
}
-(void) setDomainInfoForLayer:(int)layer {
    id<CPIntVar> var = [_x at:_nextVariable];
    int minDomain = [var min];
    int maxDomain = [var max];
    int domSize = maxDomain - minDomain + 1;
    
    TRInt* variableCount = malloc(domSize * sizeof(TRInt));
    variableCount -= minDomain;
    TRInt* bitDomain = malloc(domSize * sizeof(TRInt));
    bitDomain -= minDomain;
    
    for (int domainVal = minDomain; domainVal <= maxDomain; domainVal++) {
        variableCount[domainVal] = makeTRInt(_trail, 0);
        bitDomain[domainVal] = makeTRInt(_trail, [var member:domainVal]);
    }
    
    _layerVariableCount[layer] = variableCount;
    _layerBitDomains[layer] = bitDomain;
    _minDomainsByLayer[layer] = minDomain;
    _maxDomainsByLayer[layer] = maxDomain;
}
-(int) pickNextVariable { return _nextVariable + 1; }
-(void) addNode:(MDDNode*)node toLayer:(int)layerIndex {
    int layerSize = _layerSize[layerIndex]._val;
    [_layers[layerIndex] set:node at:layerSize inPost:_inPost];
    assignTRInt(&_layerSize[layerIndex], layerSize+1, _trail);
}
-(void) buildLayer:(int)layerIndex {
    int parentLayerIndex = layerIndex-1;
    int parentVariableIndex = _layerToVariable[parentLayerIndex];
    TRInt* bitDomain = _layerBitDomains[parentLayerIndex];
    id<CPIntVar> var = _x[parentVariableIndex];
    MDDNode* parentNode = [_layers[parentLayerIndex] at: 0];
    char* parentProperties = [getForwardState(parentNode) stateValues];
    TRInt* variableCount = _layerVariableCount[parentLayerIndex];
    
    //Create new node and state
    char* newStateProperties = malloc(_numForwardBytes);
    MDDNode* newNode;
    if (layerIndex == (int)_numVariables) {
        newNode = [_layers[layerIndex] at:0];
    } else {
        newNode = [self createNodeWithProperties:newStateProperties onLayer:layerIndex];
        [self addNode:newNode toLayer:layerIndex];
        [getForwardState(newNode) release];
        [newNode release];
    }
    
    char* edgeProperties;
    bool firstState = true;
    for (int edgeValue = _minDomainsByLayer[parentLayerIndex]; edgeValue <= _maxDomainsByLayer[parentLayerIndex]; edgeValue++) {
        if (bitDomain[edgeValue]._val) {
            //Either add edge for that value or remove value from variable
            if ([_spec canCreateState:&edgeProperties forward:parentProperties combined:nil assigningVariable:parentVariableIndex toValue:edgeValue objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
                [[MDDArc alloc] initArc:_trail from:parentNode to:newNode value:edgeValue inPost:_inPost state:edgeProperties spec:_spec];
                assignTRInt(&variableCount[edgeValue],variableCount[edgeValue]._val+1, _trail);
                if (firstState) {
                    memcpy(newStateProperties, edgeProperties, _numForwardBytes);
                    firstState = false;
                } else {
                    [_spec mergeStateProperties:newStateProperties with:edgeProperties];
                }
            } else {
                bitDomain[edgeValue] = makeTRInt(_trail, 0);
                [var remove:edgeValue];
            }
        }
    }
    [newNode setIsMergedNode:true inCreation:true];
}
-(MDDNode*) createNodeWithProperties:(char*)properties onLayer:(int)layerIndex {
    MDDStateValues* state = [[MDDStateValues alloc] initState:properties numBytes:_numForwardBytes trail:_trail];
    MDDNode* node = [[MDDNode alloc] initNode:_trail minChildIndex:_minDomainsByLayer[layerIndex] maxChildIndex:_maxDomainsByLayer[layerIndex] state:state layer:layerIndex indexOnLayer:_layerSize[layerIndex]._val numReverseBytes:_numReverseBytes numCombinedBytes:_numCombinedBytes];
    return node;
}

-(void) addPropagators {
    for (int i = 0; i < _numVariables; i++) {
        [self addPropagatorForLayer:i];
    }
}
-(void) addPropagatorForLayer:(int)layerIndex {
    int variableIndex = _layerToVariable[layerIndex];
    id<CPIntVar> variable = _x[variableIndex];
    if (!bound((CPIntVar*)variable)) {
        _layerBound[layerIndex] = makeTRInt(_trail, 0);
        struct LayerInfo propagationLayerInfo = {.layerIndex = layerIndex, .variableIndex = variableIndex, .variableCount = _layerVariableCount[layerIndex], .bitDomain = _layerBitDomains[layerIndex], .minDomain = _minDomainsByLayer[layerIndex], .maxDomain = _maxDomainsByLayer[layerIndex]};
        [variable whenChangeDo:^() {
            [_forwardQueue clear];
            [_reverseQueue clear];
            if ([self updateLayer:propagationLayerInfo]) {
                [self updateAllLayers];
                [self recordObjectiveBounds];
                //[self fillQueues];
                int numPassesWithSplit = 0;
                while (!([_forwardQueue isEmpty] && [_reverseQueue isEmpty])) {
                    if (_dualDirectional) {
                        [_reverseQueue reboot];
                        [self reversePass];
                    }
                    [_forwardQueue reboot];
                    if (numPassesWithSplit < _maxNumPasses) {
                        if (_splitAllLayersBeforeFiltering) {
                            [self forwardPassOnlySplit];
                            [self forwardPassWithoutSplit];
                        } else {
                            [self forwardPassWithSplit];
                        }
                        numPassesWithSplit++;
                    } else {
                        [self forwardPassWithoutSplit];
                    }
                    [self updateObjectiveBounds];
                }
                [self updateObjectiveVars];
                [self updateVariableDomains];
            }
            //_todo = CPChecked;
        } onBehalf:self];
    } else {
        _layerBound[layerIndex] = makeTRInt(_trail, 1);
    }
}
-(void) fillQueues {
    for (int i = 0; i <= _numVariables; i++) {
        ORTRIdArrayI* layerNodes = _layers[i];
        int layerSize = _layerSize[i]._val;
        for (int j = 0; j < layerSize; j++) {
            MDDNode* node = [layerNodes at:j];
            [self enqueueNode:node];
        }
    }
}
-(void) updateAllLayers {
    for (int otherLayerIndex = 0; otherLayerIndex < _numVariables; otherLayerIndex++) {
        if (_layerBound[otherLayerIndex]._val) continue;
        struct LayerInfo layerInfo = {.layerIndex = otherLayerIndex, .variableIndex = _layerToVariable[otherLayerIndex], .variableCount = _layerVariableCount[otherLayerIndex], .bitDomain = _layerBitDomains[otherLayerIndex], .minDomain = _minDomainsByLayer[otherLayerIndex], .maxDomain = _maxDomainsByLayer[otherLayerIndex]};
        [self updateLayer:layerInfo];
    }
}
-(bool) updateLayer:(struct LayerInfo)info {
    bool layerChanged = false;
    id<CPIntVar> variable = _x[info.variableIndex];
    for (int domainVal = info.minDomain; domainVal <= info.maxDomain; domainVal++) {
        if (info.variableCount[domainVal]._val) {
            if (info.bitDomain[domainVal]._val && ![variable member:domainVal]) {
                [self trimValue:domainVal fromLayer:info.layerIndex];
                layerChanged = true;
                assignTRInt(&info.bitDomain[domainVal], 0, _trail);
            }
        }
    }
    return layerChanged;
}
-(void) trimValue:(int)value fromLayer:(ORInt)layerIndex {
    ORTRIdArrayI* layer = _layers[layerIndex];
    int numEdgesToDelete = _layerVariableCount[layerIndex][value]._val;
    int childLayer = layerIndex + 1;
    for (int nodeIndex = 0; numEdgesToDelete; nodeIndex++) {
        MDDNode* node = [layer at: nodeIndex];
        MDDArc* childArc = [node children][value];
        if (childArc != NULL) {
            MDDNode* child = [childArc child];
            [childArc deleteArc:_inPost];
            if ([child isParentless]) {
                [self removeParentlessNodeFromMDD:child fromLayer:childLayer];
            } else {
                [_forwardQueue enqueue:child];
            }
            if ([node isChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layerIndex];
                nodeIndex--;
            } else if (_dualDirectional) {
                [_reverseQueue enqueue:node];
            }
            numEdgesToDelete--;
        }
    }
    assignTRInt(&_layerVariableCount[layerIndex][value],0, _trail);
}
-(void) updateVariableDomainForLayer:(ORInt)layer {
    int variableIndex = _layerToVariable[layer];
    id<CPIntVar> variable = _x[variableIndex];
    TRInt* variableCount = _layerVariableCount[layer];
    TRInt* bitDomain = _layerBitDomains[layer];
    for (int value = _minDomainsByLayer[layer]; value <= _maxDomainsByLayer[layer]; value++) {
        if (!variableCount[value]._val && [variable member:value]) {
            [variable remove: value];
            assignTRInt(&bitDomain[value], 1, _trail);
        }
    }
    if (bound((CPIntVar*)variable)) {
        assignTRInt(&_layerBound[layer], 1, _trail);
    }
}
-(void) updateVariableDomains {
    for (int i = 0; i < _numVariables; i++) {
        if (!_layerBound[i]._val) {
            [self updateVariableDomainForLayer:i];
        }
    }
}


-(void) reversePass {
    MDDNode* node;
    while ((node = [_reverseQueue dequeue]) != nil) {
        if ([node isDeleted] || [node layer] == _numVariables) continue;
        bool reverseStateChanged = [self refreshReverseStateFor:node];
        if (reverseStateChanged) {
            bool combinedStateChanged = [self updateCombinedStateFor:node];
            if (combinedStateChanged) {
                [self enqueueRelativesOf:node]; //Only enqueue children if the combined state changes
                [_forwardQueue enqueue:node];
            } else {
                [self enqueueParentsOf:node];
            }
        }
    }
}
-(void) forwardPassOnlySplit {
    for (int layerIndex = _firstMergedLayer._val; layerIndex <= _lastMergedLayer._val; layerIndex++) {
        [self splitLayer:layerIndex];
    }
}
-(void) forwardPassWithSplit {
    int splittingLayer = _firstMergedLayer._val;
    MDDNode* node;
    while ((node = [_forwardQueue dequeue]) != nil) {
        int filterLayer = [node layer];
        if (splittingLayer < filterLayer) {
            if (splittingLayer == _lastMergedLayer._val + 1) {
                splittingLayer = (int)_numVariables+1;
            } else {
                [self splitLayer:splittingLayer];
                splittingLayer++;
                [_forwardQueue rebootTo:splittingLayer];
                if (![node isDeleted]) {
                    [_forwardQueue enqueue:node];
                }
                continue;
            }
        }
        bool forwardStateChanged = [self refreshForwardStateFor:node];
        bool combinedStateChanged = false;
        if (forwardStateChanged || _objectiveBoundsChanged) {
            [self updateCombinedStateFor:node];
        }
        [self updateChildrenOf:node stateChanged:(forwardStateChanged || combinedStateChanged)];
        if ([node isChildless]) {
            [self removeChildlessNodeFromMDD:node fromLayer:filterLayer];
        } else if (combinedStateChanged) {
            if (![self stateExistsFor:node]) {
                [self deleteInnerNode:node];
                continue;
            }
            [self enqueueRelativesOf:node];
            [_reverseQueue enqueue:node];
        } else if (forwardStateChanged) {
            [self enqueueChildrenOf:node];
        }
    }
}
-(void) forwardPassWithoutSplit {
    MDDNode* node;
    while ((node = [_forwardQueue dequeue]) != nil) {
        bool forwardStateChanged = [self refreshForwardStateFor:node];
        bool combinedStateChanged = false;
        if (forwardStateChanged || _objectiveBoundsChanged) {
            [self updateCombinedStateFor:node];
        }
        [self updateChildrenOf:node stateChanged:(forwardStateChanged || combinedStateChanged)];
        if ([node isChildless]) {
            [self removeChildlessNodeFromMDD:node fromLayer:[node layer]];
        } else if (combinedStateChanged) {
            if (![self stateExistsFor:node]) {
                [self deleteInnerNode:node];
                continue;
            }
            [self enqueueRelativesOf:node];
        } else if (forwardStateChanged) {
            [self enqueueChildrenOf:node];
        }
    }
}
-(void) enqueueRelativesOf:(MDDNode*)node {
    if ([node layer] < _numVariables) {
        [self enqueueChildrenOf:node];
    }
    [self enqueueParentsOf:node];
}
-(void) enqueueChildrenOf:(MDDNode*)node {
    TRId* children = [node children];
    int minDomain = _minDomainsByLayer[[node layer]];
    int remainingChildren = [node numChildren];
    for (int i = minDomain; remainingChildren; i++) {
        if (children[i] != nil) {
            [_forwardQueue enqueue:[children[i] child]];
            remainingChildren--;
        }
    }
}
-(void) enqueueParentsOf:(MDDNode*)node {
    if (_dualDirectional) {
        ORTRIdArrayI* parents = [node parents];
        int numParents = [node numParents];
        for (int i = 0; i < numParents; i++) {
            [_reverseQueue enqueue:[(MDDArc*)[parents at:i] parent]];
        }
    }
}
-(void) enqueueNode:(MDDNode*)node {
    [_forwardQueue enqueue:node];
    if (_dualDirectional) {
        [_reverseQueue enqueue:node];
    }
}
-(bool) refreshReverseStateFor:(MDDNode*)node {
    bool stateChanged = false;
    
    char* newValues = [self computeReverseStateFromChildrenOf:node];
    char* oldValues = [getReverseState(node) stateValues];
    if (memcmp(oldValues, newValues, _numReverseBytes) != 0) {
        stateChanged = true;
        [node updateReverseState:newValues];
    }
    free(newValues);
    return stateChanged;
}
-(bool) refreshForwardStateFor:(MDDNode*)node {
    if ([node layer] == 0) return false;
    bool stateChanged = false;
    bool merged = false;
    
    char* newValues = [self computeForwardStateFromParentsOf:node isMerged:&merged];
    char* oldValues = [getForwardState(node) stateValues];
    if (memcmp(oldValues, newValues, _numForwardBytes) != 0) {
        stateChanged = true;
        [node updateForwardState:newValues];
    }
    free(newValues);
    [node setIsMergedNode:merged inCreation:false];
    return stateChanged;
}
-(bool) updateCombinedStateFor:(MDDNode*)node {
    char* oldCombinedState = [getCombinedState(node) stateValues];
    char* newCombinedState = [_spec computeCombinedStateFromProperties:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues]];
    if (memcmp(oldCombinedState, newCombinedState, _numCombinedBytes) != 0) {
        [node updateCombinedState:newCombinedState];
        free(newCombinedState);
        return true;
    }
    free(newCombinedState);
    return false;
}
-(char*) computeForwardStateFromArcs:(NSArray*)arcs isMerged:(bool*)merged {
    char* newValues = malloc(_numForwardBytes * sizeof(char));
    bool firstArc = true;
    for (MDDArc* arc in arcs) {
        if (firstArc) {
            memcpy(newValues, [arc forwardState], _numForwardBytes);
            firstArc = false;
        } else {
            char* arcState = [arc forwardState];
            if (*merged) {
                [_spec mergeStateProperties:newValues with:arcState];
            } else if (memcmp(newValues, arcState, _numForwardBytes) != 0) {
                *merged = true;
                [_spec mergeStateProperties:newValues with:arcState];
            }
        }
    }
    return newValues;
}
-(char*) computeForwardStateFromParentsOf:(MDDNode*)node isMerged:(bool*)merged {
    int numParents = [node numParents];
    ORTRIdArrayI* parentArcs = [node parents];
    char* newValues = malloc(_numForwardBytes * sizeof(char));
    MDDArc* firstParentArc = [parentArcs at:0];
    memcpy(newValues, [firstParentArc forwardState], _numForwardBytes);
    for (int parentIndex = 1; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        char* arcState = [parentArc forwardState];
        if (*merged) {
            [_spec mergeStateProperties:newValues with:arcState];
        } else if (memcmp(newValues, arcState, _numForwardBytes) != 0) {
            *merged = true;
            [_spec mergeStateProperties:newValues with:arcState];
        }
    }
    return newValues;
}
-(char*) computeReverseStateFromChildrenOf:(MDDNode*)node {
    int nodeLayer = [node layer];
    int maxNumChildren = min([node numChildren],_layerSize[[node layer]+1]._val);
    MDDNode** childNodes = malloc(maxNumChildren * sizeof(MDDNode*));
    int domainSize = _maxDomainsByLayer[nodeLayer] - _minDomainsByLayer[nodeLayer] + 1;
    bool** arcValuesByChild = malloc(maxNumChildren * sizeof(domainSize * sizeof(bool)));
    int numChildNodes = [self fillNodeArcVarsFromChildrenOfNode:node childNodes:childNodes arcValuesByChild:arcValuesByChild];
    char* reverseStateValues = [self computeReverseStateFromChildren:childNodes arcValueSets:arcValuesByChild numChildren:numChildNodes minDom:_minDomainsByLayer[nodeLayer] maxDom:_maxDomainsByLayer[nodeLayer]];
    for (int i = 0; i < numChildNodes; i++) {
        free(arcValuesByChild[i]);
    }
    free(childNodes);
    free(arcValuesByChild);
    return reverseStateValues;
}
-(int) fillNodeArcVarsFromChildrenOfNode:(MDDNode*)node childNodes:(MDDNode**)childNodes arcValuesByChild:(bool**)arcValuesByChild {
    TRId* childArcs = [node children];
    int layer = [node layer];
    int remainingChildren = [node numChildren];
    int numChildNodes = 0;
    int domSize = _maxDomainsByLayer[[node layer]] - _minDomainsByLayer[[node layer]]+1;
    for (int childIndex = _minDomainsByLayer[layer]; remainingChildren; childIndex++) {
        if (childArcs[childIndex] != nil) {
            MDDArc* childArc = childArcs[childIndex];
            int arcValue = [childArc arcValue];
            MDDNode* child = [childArc child];
            bool foundChild = false;
            for (int i = 0; i < numChildNodes; i++) {
                if (childNodes[i] == child) {
                    arcValuesByChild[i][arcValue] = true;
                    foundChild = true;
                    break;
                }
            }
            if (!foundChild) {
                childNodes[numChildNodes] = child;
                arcValuesByChild[numChildNodes] = calloc(domSize, sizeof(bool));
                arcValuesByChild[numChildNodes] -= _minDomainsByLayer[[node layer]];
                arcValuesByChild[numChildNodes][arcValue] = true;
                numChildNodes++;
            }
            remainingChildren--;
        }
    }
    return numChildNodes;
}
-(char*) computeReverseStateFromChildren:(MDDNode**)children arcValueSets:(bool**)arcValuesByChild numChildren:(int)numChildNodes minDom:(int)minDom maxDom:(int)maxDom {
    char* stateValues = [self computeStateFromChild:children[0] arcValues:arcValuesByChild[0] minDom:minDom maxDom:maxDom];
    for (int childNodeIndex = 1; childNodeIndex < numChildNodes; childNodeIndex++) {
        char* otherStateValues = [self computeStateFromChild:children[childNodeIndex] arcValues:arcValuesByChild[childNodeIndex] minDom:minDom maxDom:maxDom];
        [_spec mergeReverseStateProperties:stateValues with:otherStateValues];
        free(otherStateValues);
    }
    return stateValues;
}
-(char*) computeStateFromChild:(MDDNode*)child arcValues:(bool*)arcValues minDom:(int)minDom maxDom:(int)maxDom {
    return [_spec computeReverseStateFromProperties:[getReverseState(child) stateValues] combined:[getCombinedState(child) stateValues] assigningVariable:_layerToVariable[[child layer]-1] withValues:arcValues minDom:minDom maxDom:maxDom];
}
-(bool) stateExistsFor:(MDDNode*)node {
    return [_spec stateExistsWithForward:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues] combined:[getCombinedState(node) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues];
}
-(void) updateChildrenOf:(MDDNode*)node stateChanged:(bool)stateChanged {
    int layer = [node layer];
    if (layer == _numVariables) return;
    MDDStateValues* state = getForwardState(node);
    char* stateValues = [state stateValues];
    TRId* childrenArcs = [node children];
    int remainingChildren = [node numChildren];
    int variableIndex = _layerToVariable[layer];
    TRInt* variableCount = _layerVariableCount[layer];
    for (int childIndex = _minDomainsByLayer[layer]; remainingChildren; childIndex++) {
        if (childrenArcs[childIndex] != nil) {
            MDDArc* childArc = childrenArcs[childIndex];
            MDDNode* child = [childArc child];
            if (![_spec canChooseValue:childIndex forVariable:variableIndex fromParent:stateValues toChild:[getReverseState(child) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
                [childArc deleteArc:_inPost];
                assignTRInt(&variableCount[childIndex], variableCount[childIndex]._val-1, _trail);
                if ([child isParentless]) {
                    [self removeParentlessNodeFromMDD:child fromLayer:layer+1];
                } else {
                    [_forwardQueue enqueue:child];
                }
            } else if (stateChanged) {
                char* oldState = [childArc forwardState];
                char* newState = [_spec computeForwardStateFromForward:stateValues combined:[getCombinedState(node) stateValues] assigningVariable:variableIndex withValue:childIndex];
                if (memcmp(newState, oldState, _numForwardBytes) != 0) {
                    [childArc replaceForwardStateWith:newState trail:_trail];
                }
                free(newState);
            }
            
            remainingChildren--;
        }
    }
}
-(void) splitLayer:(int)layer {
    int variableIndex = _layerToVariable[layer];
    struct LayerInfo layerInfo = {.layerIndex = layer, .variableIndex = variableIndex, .variableCount = _layerVariableCount[layer], .bitDomain = _layerBitDomains[layer], .minDomain = _minDomainsByLayer[layer], .maxDomain = _maxDomainsByLayer[layer]};
    
    [self emptySplittingQueues];

    if (_rankNodesForSplitting) {
        if (!_fullySplitNodeFirst) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPMDD: Settings require ranking nodes for splitting, but not fully splitting a node.  This is not implemented as it is not clear how this would behave.  Either turn on fullySplitNodeFirst or turn of rankNodesForSplitting"];
        }
        if (_splitByConstraint) {
            for (int c = 0; c < _numSpecs && _layerSize[layer]._val < _relaxationSize; c++) {
                [self splitRankedLayer:layerInfo forConstraint:c];
            }
        } else {
            [self splitRankedLayer:layerInfo forConstraint:-1];
        }
    } else if (_splitByConstraint) {
        for (int c = 0; c < _numSpecs && _layerSize[layer]._val < _relaxationSize; c++) {
            [self splitLayer:layerInfo forConstraint:c];
        }
    } else {
        [self splitLayer:layerInfo forConstraint:-1];
    }
    if (layer == _firstMergedLayer._val) {
        if ([self noMergedNodesOnLayer:layer]) {
            int newFirstMergedLayer = layer+1;
            while (newFirstMergedLayer < _numVariables && [self noMergedNodesOnLayer:newFirstMergedLayer]) {
                newFirstMergedLayer++;
            }
            assignTRInt(&_firstMergedLayer, newFirstMergedLayer, _trail);
        }
    }
    if (layer == _lastMergedLayer._val) {
        if ([self noMergedNodesOnLayer:layer]) {
            int newLastMergedLayer = layer-1;
            while (newLastMergedLayer > 0 && [self noMergedNodesOnLayer:newLastMergedLayer]) {
                newLastMergedLayer--;
            }
            assignTRInt(&_lastMergedLayer, newLastMergedLayer, _trail);
        }
    }
}
-(bool) noMergedNodesOnLayer:(int)layerIndex {
    int layerSize = _layerSize[layerIndex]._val;
    ORTRIdArrayI* layer = _layers[layerIndex];
    for (int n = 0; n < layerSize; n++) {
        if ([[layer at:n] isMerged]) {
            return false;
        }
    }
    return true;
}
-(void) emptySplittingQueues {
    while (![_candidateSplits empty]) {
        [[_candidateSplits extractBest] release];
    }
    while (![_splittableNodes empty]) {
        [[_splittableNodes extractBest] release];
    }
}
-(void) splitLayer:(struct LayerInfo)layerInfo forConstraint:(int)c {
    ORTRIdArrayI* layerNodes = _layers[layerInfo.layerIndex];
    for (int nodeIndex = 0; nodeIndex < _layerSize[layerInfo.layerIndex]._val && _layerSize[layerInfo.layerIndex]._val < _relaxationSize; nodeIndex++) {
        MDDNode* node = [layerNodes at:nodeIndex];
        if ([node candidateForSplitting]) {
            [self splitNode:node layerInfo:layerInfo forConstraint:c];
            if (_fullySplitNodeFirst) {
                [self enqueueChildrenOf:node];
                if (_rankArcsForSplitting) {
                    [_candidateSplits buildHeap];
                }
                [self splitCandidatesOnLayer:layerInfo];
            }
        }
    }
    if (!_fullySplitNodeFirst) {
        [self splitCandidatesOnLayer:layerInfo];
    }
}
-(void) splitRankedLayer:(struct LayerInfo)layerInfo forConstraint:(int)c {
    ORTRIdArrayI* layerNodes = _layers[layerInfo.layerIndex];
    
    for (int nodeIndex = 0; nodeIndex < _layerSize[layerInfo.layerIndex]._val && _layerSize[layerInfo.layerIndex]._val < _relaxationSize; nodeIndex++) {
        MDDNode* node = [layerNodes at:nodeIndex];
        if ([node candidateForSplitting]) {
            NSNumber* key = [self keyForNode:node constraint:c];
            [_splittableNodes addObject:node forKey:key];
            [key release];
        }
    }
    [_splittableNodes buildHeap];
    while (![_splittableNodes empty] && _layerSize[layerInfo.layerIndex]._val < _relaxationSize) {
        MDDNode* node = [_splittableNodes extractBest];
        [self enqueueChildrenOf:node];
        
        [self splitNode:node layerInfo:layerInfo forConstraint:c];
        if (_rankArcsForSplitting) {
            [_candidateSplits buildHeap];
        }
        [self splitCandidatesOnLayer:layerInfo];
        if (![node isDeleted]) {
            [_forwardQueue enqueue:node];
        }
    }
}
-(void) splitNode:(MDDNode *)node layerInfo:(struct LayerInfo)layerInfo forConstraint:(int)c {
    ArcHashTable* arcHashTable = [[ArcHashTable alloc] initArcHashTable:_hashWidth numBytes:_numForwardBytes constraint:c spec:_spec];
    [arcHashTable setMatchingRule:_splitByConstraint approximate:_approximateEquivalenceClasses];
    if (_approximateEquivalenceClasses) {
        [arcHashTable setReverse:[getReverseState(node) stateValues]];
    }
    ORTRIdArrayI* parentArcs = [node parents];
    int numParents = [node numParents];
    char* childReverse = [getReverseState(node) stateValues];
    char* childCombined = [getCombinedState(node) stateValues];
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        char* arcState = [parentArc forwardState];
        NSMutableArray* existingArcList;
        if (![arcHashTable hasMatchingStateProperties:parentArc hashValue:[parentArc hashValue] arcList:&existingArcList]) {
            NSNumber* key;
            if (_rankArcsForSplitting) {
                MDDNode* parent = [parentArc parent];
                if (_useDefaultArcRank) {
                    key = [NSNumber numberWithInt:[parent numParents]];
                } else {
                    char* parentCombined = [getCombinedState(parent) stateValues];
                    key = [NSNumber numberWithInt:[_spec arcPriority:arcState parentCombined:parentCombined childReverse:childReverse childCombined:childCombined arcValue:[parentArc arcValue]]];
                }
            } else {
                key = [NSNumber numberWithInt:0];
            }
            NSArray* candidate = [arcHashTable addArc:parentArc];
            [_candidateSplits addObject:candidate forKey:key];
            [key release];
        } else {
            [existingArcList addObject:parentArc];
        }
    }
    [arcHashTable release];
}
-(MDDNode*) splitArc:(char*)arcState layerInfo:(struct LayerInfo)layerInfo {
    char* newProperties = malloc(_numForwardBytes * sizeof(char));
    memcpy(newProperties, arcState, _numForwardBytes);
    MDDStateValues* newState = [[MDDStateValues alloc] initState:newProperties numBytes:_numForwardBytes trail:_trail];
    return [[MDDNode alloc] initNode:_trail minChildIndex:layerInfo.minDomain maxChildIndex:layerInfo.maxDomain state:newState layer:layerInfo.layerIndex indexOnLayer:_layerSize[layerInfo.layerIndex]._val numReverseBytes:_numReverseBytes numCombinedBytes:_numCombinedBytes];
}
-(void) splitCandidatesOnLayer:(struct LayerInfo)layerInfo {
    while (![_candidateSplits empty] && _layerSize[layerInfo.layerIndex]._val < _relaxationSize) {
        NSArray* candidate = [_candidateSplits extractBest];
        char* newForwardProperties = malloc(_numForwardBytes);
        MDDNode* newNode = [self createNodeWithProperties:newForwardProperties onLayer:layerInfo.layerIndex];
        MDDNode* oldChild = [[candidate firstObject] child];
        char* reverse = [getReverseState(oldChild) stateValues];
        [_forwardQueue enqueue:oldChild];
        //[self enqueueChildrenOf:oldChild];
        TRId* children = [oldChild children];
        bool merged = false;
        char* computedForwardProperties = [self computeForwardStateFromArcs:candidate isMerged:&merged];
        [getForwardState(newNode) replaceUnusedStateWith:computedForwardProperties trail:_trail];
        [newNode setIsMergedNode:merged inCreation:true];
        if ([self checkChildrenOfNewNode:newNode withOldChildren:children layerInfo:layerInfo]) {
            for (MDDArc* arc in candidate) {
                [arc updateChildTo:newNode inPost:_inPost];
            }
            [newNode updateReverseState:reverse];
            if (_dualDirectional) {
                [_reverseQueue enqueue:newNode];
            }
        } else {
            [getForwardState(newNode) release];
            [newNode release];
            for (MDDArc* arc in candidate) {
                [self deleteArcWhileCheckingParent:arc parentLayer:layerInfo.layerIndex-1];
            }
        }
        if ([oldChild isParentless]) {
            [self removeParentlessNodeFromMDD:oldChild fromLayer:layerInfo.layerIndex];
        }
        [candidate release];
    }
}
-(NSNumber*) keyForNode:(MDDNode*)node constraint:(int)constraint {
    if (_useDefaultNodeRank) {
        return [NSNumber numberWithInt:[node numParents]];
    } else if (_splitByConstraint) {
        return [NSNumber numberWithInt:[_spec nodePriority:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues] combined:[getCombinedState(node) stateValues]]];
    } else {
        return [NSNumber numberWithInt:[_spec nodePriority:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues] combined:[getCombinedState(node) stateValues] forConstraint:constraint]];
    }
}
-(bool) checkChildrenOfNewNode:(MDDNode*)node withOldChildren:(MDDArc**)oldChildArcs layerInfo:(struct LayerInfo)layerInfo {
    bool hasChildren = false;
    for (int domainVal = layerInfo.minDomain; domainVal <= layerInfo.maxDomain; domainVal++) {
        MDDArc* existingChildArc = oldChildArcs[domainVal];
        if (existingChildArc != nil) {
            hasChildren = [self checkChildOfNewNode:node oldArc:existingChildArc alreadyFoundChildren:hasChildren layerInfo:layerInfo];
        }
    }
    return hasChildren;
}
-(bool) checkChildOfNewNode:(MDDNode*)node oldArc:(MDDArc*)oldChildArc alreadyFoundChildren:(bool)hasChildren layerInfo:(struct LayerInfo)layerInfo {
    MDDStateValues* state = getForwardState(node);
    char* properties = [state stateValues];
    int arcValue = [oldChildArc arcValue];
    MDDNode* child = [oldChildArc child];
    char* childReverse = [(MDDStateValues*)getReverseState(child) stateValues];
    if ([_spec canChooseValue:arcValue forVariable:layerInfo.variableIndex fromParent:properties toChild:childReverse objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
        if (!hasChildren) {
            [self addNode:node toLayer:layerInfo.layerIndex];
            [_trail trailRelease:state];
            [_trail trailRelease:node];
            //Need to make sure newNode is on trailRelease since its inner values are about to be changed (which are trailables)
        }
        [[MDDArc alloc] initArc:_trail from:node to:child value:arcValue inPost:_inPost state:[_spec computeForwardStateFromForward:properties combined:[getCombinedState(node) stateValues] assigningVariable:layerInfo.variableIndex withValue:arcValue] spec:_spec];
        assignTRInt(&layerInfo.variableCount[arcValue], layerInfo.variableCount[arcValue]._val+1, _trail);
        hasChildren = true;
    }
    return hasChildren;
}



-(void) deleteInnerNode:(MDDNode*)node {
    return;
}
-(void) removeParentlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer {
    if (_layerSize[layer]._val == 1) { failNow(); }
    [self checkChildrenOfParentlessNode:node parentLayer:layer];
    [self removeNode: node onLayer:layer];
}
-(void) checkChildrenOfParentlessNode:(MDDNode*)node parentLayer:(int)layer {
    TRId* children = [node children];
    int childLayer = layer+1;
    int numChildren = [node numChildren];
    TRInt* variableCount = _layerVariableCount[layer];
    
    for (int childIndex = _minDomainsByLayer[layer]; numChildren; childIndex++) {
        id childArc = children[childIndex];
        if (childArc != nil) {
            MDDNode* child = [childArc child];
            [childArc deleteArc:_inPost];
            assignTRInt(&variableCount[childIndex], variableCount[childIndex]._val-1, _trail);
            if ([child isParentless]) {
                [self removeParentlessNodeFromMDD:child fromLayer:childLayer];
            } else if ([child isMerged]) {
                [_forwardQueue enqueue:child];
            }
            numChildren--;
        }
    }
}
-(void) removeChildlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer {
    if (layer == _numVariables) return;
    if (_layerSize[layer]._val == 1) { failNow(); }
    [self checkParentsOfChildlessNode:node parentLayer:layer-1];
    [self removeNode: node onLayer:layer];
}
-(void) checkParentsOfChildlessNode:(MDDNode*)node parentLayer:(int)layer {
    ORTRIdArrayI* parents = [node parents];
    
    while (![node isParentless]) {
        MDDArc* parentArc = [parents at: 0];
        [self deleteArcWhileCheckingParent:parentArc parentLayer:layer];
    }
}
-(void) deleteArcWhileCheckingParent:(MDDArc*)arc parentLayer:(int)layer {
    int arcValue = [arc arcValue];
    MDDNode* parent = [arc parent];
    [arc deleteArc:_inPost];
    if ([parent isChildless]) {
        [self removeChildlessNodeFromMDD:parent fromLayer:layer];
    } else if (_dualDirectional) {
        [_reverseQueue enqueue:parent];
    }
    assignTRInt(&_layerVariableCount[layer][arcValue], _layerVariableCount[layer][arcValue]._val-1, _trail);
}
-(void) removeNode:(MDDNode*)node onLayer:(int)layerIndex {
    [self removeNodeAt:[node indexOnLayer] onLayer:layerIndex];
}
-(void) removeNodeAt:(int)index onLayer:(int)layerIndex {
    ORTRIdArrayI* layer = _layers[layerIndex];
    MDDNode* node = [layer at:index];
    [_forwardQueue retract:node];
    [_reverseQueue retract:node];
    [node deleteNode];
    
    int finalNodeIndex = _layerSize[layerIndex]._val-1;
    if (index != finalNodeIndex) {
        MDDNode* movedNode = [layer at:finalNodeIndex];
        [movedNode updateIndexOnLayer:index];
        [layer set:movedNode at:index inPost:_inPost];
    }
    [layer set:nil at:finalNodeIndex inPost:_inPost];
    assignTRInt(&_layerSize[layerIndex], finalNodeIndex,_trail);
}

-(void) recordObjectiveBounds {
    _objectiveBoundsChanged = false;
    for (int i = 0; i < _numSpecs; i++) {
        if (_fixpointVars[i] != nil) {
            int newMin = [_fixpointVars[i] min];
            int newMax = [_fixpointVars[i] max];
            if (_fixpointMinValues[i]._val != newMin) {
                assignTRInt(&_fixpointMinValues[i], newMin, _trail);
                _objectiveBoundsChanged = true;
            }
            if (_fixpointMaxValues[i]._val != newMax) {
                assignTRInt(&_fixpointMaxValues[i], newMax, _trail);
                _objectiveBoundsChanged = true;
            }
        }
    }
}
-(void) updateObjectiveBounds {
    _objectiveBoundsChanged = false;
    MDDNode* sink = [_layers[(int)_numVariables] at:0];
    char* sinkState = [getForwardState(sink) stateValues];
    for (int i = 0; i < _numSpecs; i++) {
        if (_fixpointVars[i] != nil) {
            int newMin = _fixpointMinFunctions[i](sinkState);
            int newMax = _fixpointMaxFunctions[i](sinkState);
            if (_fixpointMinValues[i]._val < newMin) {
                assignTRInt(&_fixpointMinValues[i], newMin, _trail);
                _objectiveBoundsChanged = true;
            }
            if (_fixpointMaxValues[i]._val > newMax) {
                assignTRInt(&_fixpointMaxValues[i], newMax, _trail);
                _objectiveBoundsChanged = true;
            }
        }
    }
    if (_objectiveBoundsChanged) {
        [self fillQueues];
    }
}
-(void) updateObjectiveVars {
    for (int i = 0; i < _numSpecs; i++) {
        if (_fixpointVars[i] != nil) {
            [_fixpointVars[i] updateMin:_fixpointMinValues[i]._val];
            [_fixpointVars[i] updateMax:_fixpointMaxValues[i]._val];
        }
    }
}


-(ORInt) recommendationFor:(id<CPIntVar>)x {
    //int variableId = [x getId] + min_variable_index;
    int variableId = -1;
    for (int i = _minVariableIndex; i < _minVariableIndex + _numVariables; i++) {
        if (_x[i] == x) {
            variableId = i;
            break;
        }
    }
    if (_x[variableId] != x) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPMDD: Method recommendationFor needs better way to figure out correct variable."];
    }
    
    int layer = _variableToLayer[variableId];
    int minDomain = [x min];
    int maxDomain = [x max];
   
    if (_recommendationStyle == MinDomain) {
        return [x min];
    } else if (_recommendationStyle == FewestArcs) {
        TRInt* variableCount = _layerVariableCount[layer];
        int bestDomainValue = minDomain;
        int bestValueNumEdges = variableCount[minDomain]._val;
        TRInt* bitDomain = _layerBitDomains[layer];
        for (int i = minDomain+1; i <= maxDomain; i++) {
            if (bestValueNumEdges == 1) {
                return bestDomainValue;
            }
            if (!bitDomain[i]._val || [x member:i]) {
                int numEdges = variableCount[i]._val;
                if (numEdges && numEdges < bestValueNumEdges) {
                    bestValueNumEdges = numEdges;
                    bestDomainValue = i;
                }
            }
        }
        return bestDomainValue;
    } else if (_recommendationStyle == MostArcs) {
        int layerSize = _layerSize[layer]._val;
        TRInt* variableCount = _layerVariableCount[layer];
        int bestDomainValue = minDomain;
        int bestValueNumEdges = variableCount[minDomain]._val;
        TRInt* bitDomain = _layerBitDomains[layer];
        for (int i = minDomain+1; i <= maxDomain; i++) {
            if (bestValueNumEdges == layerSize) {
                return bestDomainValue;
            }
            if (!bitDomain[i]._val || [x member:i]) {
                int numEdges = variableCount[i]._val;
                if (numEdges && numEdges > bestValueNumEdges) {
                    bestValueNumEdges = numEdges;
                    bestDomainValue = i;
                }
            }
        }
        return bestDomainValue;
    } else if (_recommendationStyle == MostArcsIntoNonMerged) {
        int layerSize = _layerSize[layer]._val;
        int* exactArcsPerDomain = calloc((maxDomain - minDomain + 1), sizeof(int));
        exactArcsPerDomain -= minDomain;
        ORTRIdArrayI* layerNodes = _layers[layer];
        for (int i = 0; i < layerSize; i++) {
            TRId* children = [(MDDNode*)[layerNodes at:i] children];
            for (int d = minDomain; d <= maxDomain; d++) {
                if (children[d] != nil && ![children[d] isMerged]) {
                    exactArcsPerDomain[d] += 1;
                }
            }
        }
        int bestDomainVal = minDomain;
        int bestNumArcs = exactArcsPerDomain[minDomain];
        for (int d = minDomain+1; d <= maxDomain; d++) {
            if (bestNumArcs < exactArcsPerDomain[d]) {
                bestDomainVal = d;
                bestNumArcs = exactArcsPerDomain[d];
            }
        }
        exactArcsPerDomain += minDomain;
        free(exactArcsPerDomain);
        return bestDomainVal;
    } else if (_recommendationStyle == FewestArcsIntoMerged) {
        int layerSize = _layerSize[layer]._val;
        int* mergedArcsPerDomain = calloc((maxDomain - minDomain + 1), sizeof(int));
        mergedArcsPerDomain -= minDomain;
        ORTRIdArrayI* layerNodes = _layers[layer];
        for (int i = 0; i < layerSize; i++) {
            TRId* children = [(MDDNode*)[layerNodes at:i] children];
            for (int d = minDomain; d <= maxDomain; d++) {
                if (children[d] != nil && [children[d] isMerged]) {
                    mergedArcsPerDomain[d] += 1;
                }
            }
        }
        int bestDomainVal = minDomain;
        int bestNumArcs = INT_MAX;
        TRInt* variableCount = _layerVariableCount[layer];
        for (int d = minDomain; d <= maxDomain; d++) {
            int mergedArcs = mergedArcsPerDomain[d];
            if (bestNumArcs > mergedArcs && variableCount[d]._val - mergedArcs > 0) {
                //Finding domain with fewest merged arcs s.t. at least one exact arc
                bestDomainVal = d;
                bestNumArcs = mergedArcsPerDomain[d];
            }
        }
        mergedArcsPerDomain += minDomain;
        free(mergedArcsPerDomain);
        return bestDomainVal;
    } else {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Recommendation Style not yet implemented."];
    }
    return [x min];
}


-(void) DEBUGcheckNodeLayerIndexCorrectness {
    for (int l = 0; l <= _numVariables; l++) {
        ORTRIdArrayI* layer = _layers[l];
        for (int n = 0; n < _layerSize[l]._val; n++) {
            MDDNode* node = [layer at:n];
            if ([node layer] != l || [node indexOnLayer] != n) {
                @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Node's layers and indexOnLayers are not correct."];
            }
        }
    }
}
-(void) DEBUGcheckQueueCounts {
    for (int l = 0; l <= _numVariables; l++) {
        int numInForwardQueue = 0;
        int numInReverseQueue = 0;
        ORTRIdArrayI* layer = _layers[l];
        for (int n = 0; n < _layerSize[l]._val; n++) {
            MDDNode* node = [layer at:n];
            if ([node inQueue:true]) {
                numInForwardQueue++;
            }
            if ([node inQueue:false]) {
                numInReverseQueue++;
            }
        }
        if (numInForwardQueue != [_forwardQueue numOnLayer:l]) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Forward queue has incorrect number of nodes."];
        }
        if (numInReverseQueue != [_reverseQueue numOnLayer:l]) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Reverse queue has incorrect number of nodes."];
        }
    }
}
-(void) DEBUGcheckArcPointerConsistency {
    for (int l = 0; l <= _numVariables; l++) {
        ORTRIdArrayI* layer = _layers[l];
        for (int n = 0; n < _layerSize[l]._val; n++) {
            MDDNode* node = [layer at:n];
            ORTRIdArrayI* parents = [node parents];
            int numParents = [node numParents];
            for (int p = 0; p < numParents; p++) {
                MDDArc* parentArc = [parents at:p];
                if ([parentArc child] != node) {
                    @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Node has parent arc that doesn't recognize it."];
                }
                if (parentArc != [[parentArc parent] children][[parentArc arcValue]]) {
                    @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Node has parent arc with incorrect parent."];
                }
            }
            if (l != _numVariables) {
                TRId* children = [node children];
                for (int c = _minDomainsByLayer[l]; c <= _maxDomainsByLayer[l]; c++) {
                    if (children[c] != nil) {
                        MDDArc* childArc = children[c];
                        if ([childArc parent] != node) {
                            @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Node has child arc that doesn't recognize it."];
                        }
                        if (childArc != [[[childArc child] parents] at:[childArc parentArcIndex]]) {
                            @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Node has child arc with incorrect child."];
                        }
                    }
                }
            }
        }
    }
}
-(void) DEBUGcheckQueuesHaveNoDeletedNodes {
    for (int l = 0; l <= _numVariables; l++) {
        if ([_forwardQueue hasDeletedNodeOnLayer:l]) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Forward queue has deleted node."];
        }
        if ([_reverseQueue hasDeletedNodeOnLayer:l]) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Reverse queue has deleted node."];
        }
    }
}
-(void) DEBUGcheckNodesInQueueMarkedInQueue {
    for (int l = 0; l <= _numVariables; l++) {
        if ([_forwardQueue hasUnmarkedNodeOnLayer:l]) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Forward queue has node that doesn't think it's in the queu."];
        }
        if ([_reverseQueue hasUnmarkedNodeOnLayer:l]) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Reverse queue has node that doesn't think it's in the queue."];
        }
    }
}
@end
