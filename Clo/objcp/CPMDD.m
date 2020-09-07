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
    
    _cacheForwardOnArcs = false;
    _splitAllLayersBeforeFiltering = true;
    _splitByConstraint = false;
    _fullySplitNodeFirst = true;
    _rankNodesForSplitting = true;
    _useDefaultNodeRank = true;
    _rankArcsForSplitting = true;
    _useDefaultArcRank = true;
    _approximateEquivalenceClasses = true;
    _twoPassSplit = false;
    _alwaysSplitLastArc = true;
    _useStateExistence = false;
    
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
    
    _diffForwardSel = @selector(diffForwardProperties:to:);
    _diffForward = (DiffPropertyIMP)[_spec methodForSelector:_diffForwardSel];
    _diffReverseSel = @selector(diffReverseProperties:to:);
    _diffReverse = (DiffPropertyIMP)[_spec methodForSelector:_diffReverseSel];
    
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
        //free(_layerBitDomains[i]);
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
    
    [self addPropagators];
    [self fillQueues];
    [self propagate];
    
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
                if (_cacheForwardOnArcs) {
                    [[MDDArc alloc] initArc:_trail from:parentNode to:newNode value:edgeValue inPost:_inPost state:edgeProperties spec:_spec];
                } else {
                    [[MDDArc alloc] initArcWithoutCache:_trail from:parentNode to:newNode value:edgeValue inPost:_inPost];
                }
                assignTRInt(&variableCount[edgeValue],variableCount[edgeValue]._val+1, _trail);
                if (firstState) {
                    memcpy(newStateProperties, edgeProperties, _numForwardBytes);
                    firstState = false;
                } else {
                    [_spec mergeStateProperties:newStateProperties with:edgeProperties];
                }
                if (!_cacheForwardOnArcs) {
                    free(edgeProperties);
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
                [self propagate];
            }
            //_todo = CPChecked;
        } onBehalf:self];
    } else {
        _layerBound[layerIndex] = makeTRInt(_trail, 1);
    }
}
-(void) propagate {
    _passIteration = 0;
    while (!([_forwardQueue isEmpty] && [_reverseQueue isEmpty])) {
        if (_dualDirectional) {
            [_reverseQueue reboot];
            [self reversePass];
        }
        [_forwardQueue reboot];
        if (_passIteration < _maxNumPasses) {
            if (_splitAllLayersBeforeFiltering) {
                [self forwardPassOnlySplit];
                [self forwardPassWithoutSplit];
            } else {
                [self forwardPassWithSplit];
            }
        } else {
            [self forwardPassWithoutSplit];
        }
        _passIteration++;
        [self updateObjectiveBounds];
    }
    [self updateObjectiveVars];
    [self updateVariableDomains];
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
            } else if ([child isMerged]) {
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
        [self updateNodeReverse:node layer:[node layer]];
    }
}
-(void) forwardPassOnlySplit {
    _splitPass = 1;
    for (int layerIndex = _firstMergedLayer._val; layerIndex <= _lastMergedLayer._val; layerIndex++) {
        int highestShrunkLayer = [self splitLayer:layerIndex];
        int jumpDistance = min(layerIndex - (highestShrunkLayer - 1), _maxRebootDistance);
        layerIndex -= jumpDistance;
    }
    if (_twoPassSplit) {
        _splitPass = 2;
        for (int layerIndex = _firstMergedLayer._val; layerIndex <= _lastMergedLayer._val; layerIndex++) {
            int highestShrunkLayer = [self splitLayer:layerIndex];
            int jumpDistance = min(layerIndex - (highestShrunkLayer - 1), _maxRebootDistance);
            layerIndex -= jumpDistance;
        }
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
        [self updateNodeForward:node layer:filterLayer];
    }
}
-(void) forwardPassWithoutSplit {
    MDDNode* node;
    while ((node = [_forwardQueue dequeue]) != nil) {
        [self updateNodeForward:node layer:[node layer]];
    }
}
-(void) updateNodeForward:(MDDNode*)node layer:(int)layer {
    bool forwardStateChanged = [self refreshForwardStateFor:node];
    if (forwardStateChanged || _objectiveBoundsChanged) {
        bool combinedStateChanged = [self updateCombinedStateFor:node];
        if (_useStateExistence && ![self stateExistsFor:node]) {
            [self deleteInnerNode:node];
            return;
        }
        if (combinedStateChanged || _objectiveBoundsChanged) {
            [self updateParentsOf:node];
            if ([node isParentless]) {
                [self removeParentlessNodeFromMDD:node fromLayer:layer];
            }
        }
        [self updateChildrenOf:node stateChanged:(forwardStateChanged || combinedStateChanged)];
        if ([node isChildless] && layer != _numVariables) {
            [self removeChildlessNodeFromMDD:node fromLayer:layer];
        }
    }
}
-(void) updateNodeReverse:(MDDNode*)node layer:(int)layer {
    bool reverseStateChanged = [self refreshReverseStateFor:node];
    if (reverseStateChanged || _objectiveBoundsChanged) {
        bool combinedStateChanged = [self updateCombinedStateFor:node];
        if (_useStateExistence && ![self stateExistsFor:node]) {
            [self deleteInnerNode:node];
            return;
        }
        if (combinedStateChanged || _objectiveBoundsChanged) {
            [self updateChildrenOf:node stateChanged:true];
            if ([node isChildless] && [node layer] != _numVariables) {
                [self removeChildlessNodeFromMDD:node fromLayer:[node layer]];
            }
        }
        [self updateParentsOf:node];
        if ([node isParentless] && [node layer] != 0) {
            [self removeParentlessNodeFromMDD:node fromLayer:[node layer]];
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
    
    char* newValues;
    if ([node childrenChanged]) {
        newValues = [self computeReverseStateFromChildrenOf:node];
    } else {
        newValues = [self updateReverseStateFromChildrenOf:node];
        if (newValues == nil) {
            return false;
        }
    }
    char* oldValues = [getReverseState(node) stateValues];
    if (memcmp(oldValues, newValues, _numReverseBytes) != 0) {
        stateChanged = true;
        bool* delta = _diffReverse(_spec, _diffReverseSel, oldValues, newValues);
        //bool* delta = [_spec diffReverseProperties:oldValues to:newValues];
        [node setReversePropertyDelta:delta passIteration:_passIteration];
        [node updateReverseState:newValues];
    }
    free(newValues);
    return stateChanged;
}
-(bool) refreshForwardStateFor:(MDDNode*)node {
    if ([node layer] == 0) return false;
    bool stateChanged = false;
    bool merged = false;
    char* newValues;
    if ([node parentsChanged]) {
        newValues = [self computeForwardStateFromParentsOf:node isMerged:&merged];
    } else {
        newValues = [self updateForwardStateFromParentsOf:node isMerged:&merged];
        if (newValues == nil) {
            return false;
        }
    }
    char* oldValues = [getForwardState(node) stateValues];
    if (memcmp(oldValues, newValues, _numForwardBytes) != 0) {
        stateChanged = true;
        bool* delta = _diffForward(_spec, _diffForwardSel, oldValues, newValues);
        //bool* delta = [_spec diffForwardProperties:oldValues to:newValues];
        [node setForwardPropertyDelta:delta passIteration:_passIteration];
        [node updateForwardState:newValues];
    }
    free(newValues);
    [node setIsMergedNode:merged inCreation:false];
    return stateChanged;
}
-(bool) updateCombinedStateFor:(MDDNode*)node {
    if (_numCombinedBytes == 0) return false;
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
-(char*) computeForwardStateFromArcs:(NSArray*)arcs isMerged:(bool*)merged layerInfo:(struct LayerInfo)layerInfo {
    char* newValues;
    bool firstArc = true;
    if (_cacheForwardOnArcs) {
        for (MDDArc* arc in arcs) {
            if (firstArc) {
                newValues = malloc(_numForwardBytes);
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
    } else {
        int parentLayerIndex = layerInfo.layerIndex-1;
        MDDNode** parentNodes = malloc(_layerSize[parentLayerIndex]._val * sizeof(MDDNode*));
        bool** arcValuesByParent = malloc(_layerSize[parentLayerIndex]._val * sizeof(bool*));
        int* numArcsPerParent = malloc(_layerSize[parentLayerIndex]._val * sizeof(int));
        int numParentNodes = [self fillNodeArcVarsUsingArcs:arcs parentNodes:parentNodes arcValuesByParent:arcValuesByParent numArcsPerParent:numArcsPerParent parentLayerIndex:parentLayerIndex];
        newValues = [self computeForwardStateFromParents:parentNodes arcValueSets:arcValuesByParent numParents:numParentNodes numArcsPerParent:numArcsPerParent minDom:_minDomainsByLayer[parentLayerIndex] maxDom:_maxDomainsByLayer[parentLayerIndex] isMerged:merged];
        for (int i = 0; i < numParentNodes; i++) {
            arcValuesByParent[i] += _minDomainsByLayer[parentLayerIndex];
            free(arcValuesByParent[i]);
        }
        free(parentNodes);
        free(numArcsPerParent);
        free(arcValuesByParent);
    }
    return newValues;
}
-(char*) computeForwardStateFromParentsOf:(MDDNode*)node isMerged:(bool*)merged {
    int parentLayer = [node layer]-1;
    int maxNumParents = min([node numParents],_layerSize[parentLayer]._val);
    MDDNode** parentNodes = malloc(maxNumParents * sizeof(MDDNode*));
    bool** arcValuesByParent = malloc(maxNumParents * sizeof(bool*));
    int* numArcsPerParent = malloc(maxNumParents * sizeof(int));
    int numParentNodes = [self fillNodeArcVarsFromParentsOfNode:node parentNodes:parentNodes arcValuesByParent:arcValuesByParent numArcsPerParent:numArcsPerParent];
    char* forwardStateValues = [self computeForwardStateFromParents:parentNodes arcValueSets:arcValuesByParent numParents:numParentNodes numArcsPerParent:numArcsPerParent minDom:_minDomainsByLayer[parentLayer] maxDom:_maxDomainsByLayer[parentLayer] isMerged:merged];
    for (int i = 0; i < numParentNodes; i++) {
        arcValuesByParent[i] += _minDomainsByLayer[parentLayer];
        free(arcValuesByParent[i]);
    }
    free(parentNodes);
    free(arcValuesByParent);
    free(numArcsPerParent);
    return forwardStateValues;
}
-(char*) updateForwardStateFromParentsOf:(MDDNode*)node isMerged:(bool*)merged {
    int parentLayer = [node layer]-1;
    int maxNumParents = min([node numParents],_layerSize[parentLayer]._val);
    MDDNode** parentNodes = malloc(maxNumParents * sizeof(MDDNode*));
    bool** arcValuesByParent = malloc(maxNumParents * sizeof(bool*));
    int* numArcsPerParent = malloc(maxNumParents * sizeof(int));
    int numParentNodes = [self fillNodeArcVarsFromParentsOfNode:node parentNodes:parentNodes arcValuesByParent:arcValuesByParent numArcsPerParent:numArcsPerParent];
    bool** parentDeltas = malloc(numParentNodes * sizeof(bool*));
    int numDeltas = 0;
    for (int i = 0; i < numParentNodes; i++) {
        bool* parentDelta = [parentNodes[i] forwardDeltaForPassIteration:_passIteration];
        if (parentDelta != nil) {
            parentDeltas[numDeltas] = parentDelta;
            numDeltas++;
        }
    }
    char* forwardStateValues;
    if (numDeltas) {
        bool* propertyImpact = [_spec forwardPropertyImpactFrom:parentDeltas numParents:numDeltas variable:_layerToVariable[parentLayer]];
        forwardStateValues = [self updateForwardStateFromParents:parentNodes arcValueSets:arcValuesByParent numParents:numParentNodes numArcsPerParent:numArcsPerParent minDom:_minDomainsByLayer[parentLayer] maxDom:_maxDomainsByLayer[parentLayer] properties:propertyImpact oldState:[getForwardState(node) stateValues] isMerged:merged];
        *merged = *merged || [node isMerged];
        free(propertyImpact);
    } else {
        forwardStateValues = nil;
    }
    for (int i = 0; i < numParentNodes; i++) {
        arcValuesByParent[i] += _minDomainsByLayer[parentLayer];
        free(arcValuesByParent[i]);
    }
    free(parentNodes);
    free(arcValuesByParent);
    free(numArcsPerParent);
    free(parentDeltas);
    return forwardStateValues;
}
-(char*) updateForwardStateFromParents:(MDDNode**)parents arcValueSets:(bool**)arcValuesByParent numParents:(int)numParentNodes numArcsPerParent:(int*)numArcsPerParent minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged {
    char* stateValues = [self updateStateFromParent:parents[0] arcValues:arcValuesByParent[0] numArcs:numArcsPerParent[0] minDom:minDom maxDom:maxDom properties:properties oldState:oldState isMerged:merged];
    for (int parentNodeIndex = 1; parentNodeIndex < numParentNodes; parentNodeIndex++) {
        char* otherStateValues = [self updateStateFromParent:parents[parentNodeIndex] arcValues:arcValuesByParent[parentNodeIndex] numArcs:numArcsPerParent[parentNodeIndex] minDom:minDom maxDom:maxDom properties:properties oldState:oldState isMerged:merged];
        if (memcmp(stateValues, otherStateValues, _numForwardBytes) != 0) {
            [_spec mergeStateProperties:stateValues with:otherStateValues properties:properties];
            *merged = true;
        }
        free(otherStateValues);
    }
    return stateValues;
}

-(char*) updateReverseStateFromChildrenOf:(MDDNode*)node {
    int nodeLayer = [node layer];
    int maxNumChildren = min([node numChildren],_layerSize[nodeLayer+1]._val);
    MDDNode** childNodes = malloc(maxNumChildren * sizeof(MDDNode*));
    bool** arcValuesByChild = malloc(maxNumChildren * sizeof(bool*));
    int* numArcsPerChild = malloc(maxNumChildren * sizeof(int));
    int numChildNodes = [self fillNodeArcVarsFromChildrenOfNode:node childNodes:childNodes arcValuesByChild:arcValuesByChild numArcsPerChild:numArcsPerChild];
    
    bool** childDeltas = malloc([node numChildren] * sizeof(bool*));
    int numDeltas = 0;
    for (int i = 0; i < numChildNodes; i++) {
        bool* childDelta = [childNodes[i] reverseDeltaForPassIteration:_passIteration];
        if (childDelta != nil) {
            childDeltas[numDeltas] = childDelta;
            numDeltas++;
        }
    }
    char* reverseStateValues;
    if (numDeltas) {
        bool* propertyImpact = [_spec reversePropertyImpactFrom:childDeltas numChildren:numDeltas variable:_layerToVariable[nodeLayer]];
        reverseStateValues = [self updateReverseStateFromChildren:childNodes arcValueSets:arcValuesByChild numChildren:numChildNodes numArcsPerChild:numArcsPerChild minDom:_minDomainsByLayer[nodeLayer] maxDom:_maxDomainsByLayer[nodeLayer] properties:propertyImpact oldState:[getReverseState(node) stateValues]];
        free(propertyImpact);
    } else {
        reverseStateValues = nil;
    }
    for (int i = 0; i < numChildNodes; i++) {
        arcValuesByChild[i] += _minDomainsByLayer[nodeLayer];
        free(arcValuesByChild[i]);
    }
    free(childNodes);
    free(arcValuesByChild);
    free(childDeltas);
    free(numArcsPerChild);
    return reverseStateValues;
}
-(char*) updateReverseStateFromChildren:(MDDNode**)children arcValueSets:(bool**)arcValuesByChild numChildren:(int)numChildNodes numArcsPerChild:(int*)numArcsPerChild minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState {
    char* stateValues = [self updateStateFromChild:children[0] arcValues:arcValuesByChild[0] numArcs:numArcsPerChild[0] minDom:minDom maxDom:maxDom properties:properties oldState:oldState];
    for (int childNodeIndex = 1; childNodeIndex < numChildNodes; childNodeIndex++) {
        char* otherStateValues = [self updateStateFromChild:children[childNodeIndex] arcValues:arcValuesByChild[childNodeIndex] numArcs:numArcsPerChild[childNodeIndex] minDom:minDom maxDom:maxDom properties:properties oldState:oldState];
        if (memcmp(stateValues, otherStateValues, _numReverseBytes) != 0) {
            [_spec mergeReverseStateProperties:stateValues with:otherStateValues properties:properties];
        }
        free(otherStateValues);
    }
    return stateValues;
}
-(char*) computeReverseStateFromChildrenOf:(MDDNode*)node {
    int nodeLayer = [node layer];
    int maxNumChildren = min([node numChildren],_layerSize[nodeLayer+1]._val);
    MDDNode** childNodes = malloc(maxNumChildren * sizeof(MDDNode*));
    bool** arcValuesByChild = malloc(maxNumChildren * sizeof(bool*));
    int* numArcsPerChild = malloc(maxNumChildren * sizeof(int));
    int numChildNodes = [self fillNodeArcVarsFromChildrenOfNode:node childNodes:childNodes arcValuesByChild:arcValuesByChild numArcsPerChild:numArcsPerChild];
    char* reverseStateValues = [self computeReverseStateFromChildren:childNodes arcValueSets:arcValuesByChild numChildren:numChildNodes numArcsPerChild:numArcsPerChild minDom:_minDomainsByLayer[nodeLayer] maxDom:_maxDomainsByLayer[nodeLayer]];
    for (int i = 0; i < numChildNodes; i++) {
        arcValuesByChild[i] += _minDomainsByLayer[nodeLayer];
        free(arcValuesByChild[i]);
    }
    free(childNodes);
    free(arcValuesByChild);
    free(numArcsPerChild);
    return reverseStateValues;
}
-(int) fillNodeArcVarsUsingArcs:(NSArray*)arcs parentNodes:(MDDNode**)parentNodes arcValuesByParent:(bool**)arcValuesByParent numArcsPerParent:(int*)numArcsPerParent parentLayerIndex:(int)parentLayer {
    int numParentNodes = 0;
    int domSize = _maxDomainsByLayer[parentLayer] - _minDomainsByLayer[parentLayer]+1;
    for (MDDArc* arc in arcs) {
        int arcValue = [arc arcValue];
        MDDNode* parent = [arc parent];
        bool foundParent = false;
        for (int i = 0; i < numParentNodes; i++) {
            if (parentNodes[i] == parent) {
                arcValuesByParent[i][arcValue] = true;
                foundParent = true;
                numArcsPerParent[i] = numArcsPerParent[i] + 1;
                break;
            }
        }
        if (!foundParent) {
            parentNodes[numParentNodes] = parent;
            arcValuesByParent[numParentNodes] = calloc(domSize, sizeof(bool));
            arcValuesByParent[numParentNodes] -= _minDomainsByLayer[parentLayer];
            arcValuesByParent[numParentNodes][arcValue] = true;
            numArcsPerParent[numParentNodes] = 1;
            numParentNodes++;
        }
    }
    return numParentNodes;
}
-(int) fillNodeArcVarsFromParentsOfNode:(MDDNode*)node parentNodes:(MDDNode**)parentNodes arcValuesByParent:(bool**)arcValuesByParent numArcsPerParent:(int*)numArcsPerParent {
    ORTRIdArrayI* parentArcs = [node parents];
    int parentLayer = [node layer]-1;
    int numParentNodes = 0;
    int domSize = _maxDomainsByLayer[parentLayer] - _minDomainsByLayer[parentLayer]+1;
    for (int parentIndex = 0; parentIndex < [node numParents]; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        int arcValue = [parentArc arcValue];
        MDDNode* parent = [parentArc parent];
        bool foundParent = false;
        for (int i = 0; i < numParentNodes; i++) {
            if (parentNodes[i] == parent) {
                arcValuesByParent[i][arcValue] = true;
                foundParent = true;
                numArcsPerParent[i] = numArcsPerParent[i] + 1;
                break;
            }
        }
        if (!foundParent) {
            parentNodes[numParentNodes] = parent;
            arcValuesByParent[numParentNodes] = calloc(domSize, sizeof(bool));
            arcValuesByParent[numParentNodes] -= _minDomainsByLayer[parentLayer];
            arcValuesByParent[numParentNodes][arcValue] = true;
            numArcsPerParent[numParentNodes] = 1;
            numParentNodes++;
        }
    }
    return numParentNodes;
}
-(int) fillNodeArcVarsFromChildrenOfNode:(MDDNode*)node childNodes:(MDDNode**)childNodes arcValuesByChild:(bool**)arcValuesByChild numArcsPerChild:(int*)numArcsPerChild {
    TRId* childArcs = [node children];
    int layer = [node layer];
    int remainingChildren = [node numChildren];
    int numChildNodes = 0;
    int domSize = _maxDomainsByLayer[layer] - _minDomainsByLayer[layer]+1;
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
                    numArcsPerChild[i] = numArcsPerChild[i] + 1;
                    break;
                }
            }
            if (!foundChild) {
                childNodes[numChildNodes] = child;
                arcValuesByChild[numChildNodes] = calloc(domSize, sizeof(bool));
                arcValuesByChild[numChildNodes] -= _minDomainsByLayer[layer];
                arcValuesByChild[numChildNodes][arcValue] = true;
                numArcsPerChild[numChildNodes] = 1;
                numChildNodes++;
            }
            remainingChildren--;
        }
    }
    return numChildNodes;
}
-(char*) computeForwardStateFromParents:(MDDNode**)parents arcValueSets:(bool**)arcValuesByParent numParents:(int)numParentNodes numArcsPerParent:(int*)numArcsPerParent minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged {
    char* stateValues = [self computeStateFromParent:parents[0] arcValues:arcValuesByParent[0] numArcs:numArcsPerParent[0] minDom:minDom maxDom:maxDom isMerged:merged];
    for (int parentNodeIndex = 1; parentNodeIndex < numParentNodes; parentNodeIndex++) {
        char* otherStateValues = [self computeStateFromParent:parents[parentNodeIndex] arcValues:arcValuesByParent[parentNodeIndex] numArcs:numArcsPerParent[parentNodeIndex] minDom:minDom maxDom:maxDom isMerged:merged];
        if (memcmp(stateValues, otherStateValues, _numForwardBytes) != 0) {
            [_spec mergeStateProperties:stateValues with:otherStateValues];
            *merged = true;
        }
        free(otherStateValues);
    }
    return stateValues;
}
-(char*) updateStateFromParent:(MDDNode*)parent arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged {
    return [_spec updateForwardStateFromForward:[getForwardState(parent) stateValues] combined:[getCombinedState(parent) stateValues] assigningVariable:_layerToVariable[[parent layer]] withValues:arcValues numArcs:numArcs minDom:minDom maxDom:maxDom properties:properties oldState:oldState merged:merged];
}
-(char*) computeStateFromParent:(MDDNode*)parent arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged {
    return [_spec computeForwardStateFromForward:[getForwardState(parent) stateValues] combined:[getCombinedState(parent) stateValues] assigningVariable:_layerToVariable[[parent layer]] withValues:arcValues numArcs:numArcs minDom:minDom maxDom:maxDom merged:merged];
}
-(char*) computeReverseStateFromChildren:(MDDNode**)children arcValueSets:(bool**)arcValuesByChild numChildren:(int)numChildNodes numArcsPerChild:(int*)numArcsPerChild minDom:(int)minDom maxDom:(int)maxDom {
    char* stateValues = [self computeStateFromChild:children[0] arcValues:arcValuesByChild[0] numArcs:numArcsPerChild[0] minDom:minDom maxDom:maxDom];
    for (int childNodeIndex = 1; childNodeIndex < numChildNodes; childNodeIndex++) {
        char* otherStateValues = [self computeStateFromChild:children[childNodeIndex] arcValues:arcValuesByChild[childNodeIndex] numArcs:numArcsPerChild[childNodeIndex] minDom:minDom maxDom:maxDom];
        [_spec mergeReverseStateProperties:stateValues with:otherStateValues];
        free(otherStateValues);
    }
    return stateValues;
}
-(char*) computeStateFromChild:(MDDNode*)child arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom {
    return [_spec computeReverseStateFromProperties:[getReverseState(child) stateValues] combined:[getCombinedState(child) stateValues] assigningVariable:_layerToVariable[[child layer]-1] withValues:arcValues numArcs:numArcs minDom:minDom maxDom:maxDom];
}
-(char*) updateStateFromChild:(MDDNode*)child arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState {
    return [_spec updateReverseStateFromReverse:[getReverseState(child) stateValues] combined:[getCombinedState(child) stateValues] assigningVariable:_layerToVariable[[child layer]-1] withValues:arcValues numArcs:numArcs minDom:minDom maxDom:maxDom properties:properties oldState:oldState];
}
-(bool) stateExistsFor:(MDDNode*)node {
    return [_spec stateExistsWithForward:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues] combined:[getCombinedState(node) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues];
}
-(void) updateParentsOf:(MDDNode*)node {
    int layer = [node layer];
    if (layer == 0) return;
    MDDStateValues* reverseState = getReverseState(node);
    char* reverseStateValues = [reverseState stateValues];
    MDDStateValues* combinedState = getCombinedState(node);
    char* combinedStateValues = [combinedState stateValues];
    ORTRIdArrayI* parentArcs = [node parents];
    int numParents = [node numParents];
    bool parentsChanged = false;
    int variableIndex = _layerToVariable[layer-1];
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        MDDNode* parent = [parentArc parent];
        int arcValue = [parentArc arcValue];
        if (![_spec canChooseValue:arcValue forVariable:variableIndex fromParentForward:[getForwardState(parent) stateValues] combined:[getCombinedState(parent) stateValues] toChildReverse:reverseStateValues combined:combinedStateValues objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
            [self deleteArcWhileCheckingParent:parentArc parentLayer:layer-1];
            parentsChanged = true;
            numParents--;
            parentIndex--;
        } else {
            [_reverseQueue enqueue:parent];
        }
    }
    if (parentsChanged) {
        [_forwardQueue enqueue:node];
    }
}
-(void) updateChildrenOf:(MDDNode*)node stateChanged:(bool)stateChanged {
    int layer = [node layer];
    if (layer == _numVariables) return;
    MDDStateValues* state = getForwardState(node);
    char* stateValues = [state stateValues];
    char* combinedState = [getCombinedState(node) stateValues];
    TRId* childrenArcs = [node children];
    int remainingChildren = [node numChildren];
    bool childrenChanged = false;
    int variableIndex = _layerToVariable[layer];
    for (int childIndex = _minDomainsByLayer[layer]; remainingChildren; childIndex++) {
        if (childrenArcs[childIndex] != nil) {
            MDDArc* childArc = childrenArcs[childIndex];
            MDDNode* child = [childArc child];
            if (![_spec canChooseValue:childIndex forVariable:variableIndex fromParentForward:stateValues combined:combinedState toChildReverse:[getReverseState(child) stateValues] combined:[getCombinedState(child) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
                [self deleteArcWhileCheckingChild:childArc childLayer:layer+1];
                childrenChanged = true;
            } else if (stateChanged) {
                if (_cacheForwardOnArcs) {
                    char* oldState = [childArc forwardState];
                    bool* arcValues = malloc(sizeof(bool));
                    arcValues[0] = true;
                    arcValues -= childIndex;
                    char* newState = [_spec computeForwardStateFromForward:stateValues combined:[getCombinedState(node) stateValues] assigningVariable:variableIndex withValues:arcValues numArcs:1  minDom:childIndex maxDom:childIndex];
                    if (memcmp(newState, oldState, _numForwardBytes) != 0) {
                        [childArc replaceForwardStateWith:newState trail:_trail];
                    }
                    arcValues += childIndex;
                    free(arcValues);
                    free(newState);
                }
                [_forwardQueue enqueue:child];
            }
            
            remainingChildren--;
        }
    }
    if (childrenChanged) {
        [_reverseQueue enqueue:node];
    }
}
-(int) splitLayer:(int)layer {
    int highestShrunkLayer = layer+1;
    int variableIndex = _layerToVariable[layer];
    struct LayerInfo layerInfo = {.layerIndex = layer, .variableIndex = variableIndex, .variableCount = _layerVariableCount[layer], .bitDomain = _layerBitDomains[layer], .minDomain = _minDomainsByLayer[layer], .maxDomain = _maxDomainsByLayer[layer]};
    
    [self emptySplittingQueues];

    if (_rankNodesForSplitting) {
        if (!_fullySplitNodeFirst) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPMDD: Settings require ranking nodes for splitting, but not fully splitting a node.  This is not implemented as it is not clear how this would behave.  Either turn on fullySplitNodeFirst or turn of rankNodesForSplitting"];
        }
        if (_splitByConstraint) {
            for (int c = 0; c < _numSpecs && _layerSize[layer]._val < _relaxationSize; c++) {
                highestShrunkLayer = min(highestShrunkLayer, [self splitRankedLayer:layerInfo forConstraint:c]);
            }
        } else {
            highestShrunkLayer = [self splitRankedLayer:layerInfo forConstraint:-1];
        }
    } else if (_splitByConstraint) {
        for (int c = 0; c < _numSpecs && _layerSize[layer]._val < _relaxationSize; c++) {
            highestShrunkLayer = min(highestShrunkLayer, [self splitLayer:layerInfo forConstraint:c]);
        }
    } else {
        highestShrunkLayer = [self splitLayer:layerInfo forConstraint:-1];
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
    return highestShrunkLayer;
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
-(int) splitLayer:(struct LayerInfo)layerInfo forConstraint:(int)c {
    int highestShrunkLayer = layerInfo.layerIndex + 1;
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
                highestShrunkLayer = min(highestShrunkLayer, [self splitCandidatesOnLayer:layerInfo]);
            }
        }
    }
    if (!_fullySplitNodeFirst) {
        highestShrunkLayer = min(highestShrunkLayer, [self splitCandidatesOnLayer:layerInfo]);
    }
    return highestShrunkLayer;
}
-(int) splitRankedLayer:(struct LayerInfo)layerInfo forConstraint:(int)c {
    int highestShrunkLayer = layerInfo.layerIndex + 1;
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
        if ([_candidateSplits size] == 1) {
            [[_candidateSplits extractBest] release];
            [node setIsMergedNode:false inCreation:_inPost];
        }
        if (_rankArcsForSplitting) {
            [_candidateSplits buildHeap];
        }
        highestShrunkLayer = min(highestShrunkLayer, [self splitCandidatesOnLayer:layerInfo]);
        if (![node isDeleted]) {
            [_forwardQueue enqueue:node];
        }
    }
    return highestShrunkLayer;
}
-(void) splitNode:(MDDNode *)node layerInfo:(struct LayerInfo)layerInfo forConstraint:(int)c {
    ArcHashTable* arcHashTable = [[ArcHashTable alloc] initArcHashTable:_hashWidth numBytes:_numForwardBytes constraint:c spec:_spec];
    [arcHashTable setMatchingRule:_splitByConstraint approximate:(_splitPass == 1 && _approximateEquivalenceClasses) cachedOnArc:_cacheForwardOnArcs];
    if (_splitPass == 1 && _approximateEquivalenceClasses) {
        [arcHashTable setReverse:[getReverseState(node) stateValues]];
    }
    ORTRIdArrayI* parentArcs = [node parents];
    int numParents = [node numParents];
    char* childReverse = [getReverseState(node) stateValues];
    char* childCombined = [getCombinedState(node) stateValues];
    
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        char* arcState;
        if (_cacheForwardOnArcs) {
            arcState = [parentArc forwardState];
        } else {
            bool* arcValues = malloc(sizeof(bool));
            arcValues[0] = true;
            arcValues -= [parentArc arcValue];
            arcState = [_spec computeForwardStateFromForward:[getForwardState([parentArc parent]) stateValues] combined:[getCombinedState([parentArc parent]) stateValues] assigningVariable:_layerToVariable[layerInfo.layerIndex-1] withValues:arcValues numArcs:1 minDom:[parentArc arcValue] maxDom:[parentArc arcValue]];
            arcValues += [parentArc arcValue];
            free(arcValues);
        }
        MDDNode* existingNode = [self findExactMatchForState:arcState onLayer:layerInfo];
        if (existingNode != nil && existingNode != node) {
            [parentArc updateChildTo:existingNode inPost:_inPost];
            if (!_cacheForwardOnArcs) {
                free(arcState);
            }
            parentIndex--;
            numParents--;
        } else {
            NSMutableArray* existingArcList;
            int arcHash;
            if (_cacheForwardOnArcs) {
                if (_splitPass == 1 && _approximateEquivalenceClasses && !_splitByConstraint) {
                    arcHash = [parentArc combinedEquivalenceClasses];
                } else {
                    arcHash = [parentArc hashValue];
                }
            } else {
                if (_splitByConstraint) {
                    arcHash = [_spec hashValueForState:arcState constraint:c];
                } else {
                    arcHash = [_spec hashValueForState:arcState];
                }
            }
            
            if (_alwaysSplitLastArc && parentIndex == numParents -1) {
                NSNumber* key = [NSNumber numberWithInt:INT_MAX];
                NSArray* candidate = [[NSMutableArray alloc] initWithObjects:parentArc, nil];
                [_candidateSplits addObject:candidate forKey:key];
                if (!_cacheForwardOnArcs) {
                    free(arcState);
                }
                [key release];
            } else if (![arcHashTable hasMatchingStateProperties:arcState forArc:parentArc hashValue:arcHash arcList:&existingArcList]) {
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
                NSArray* candidate = [arcHashTable addArc:parentArc withState:arcState];
                [_candidateSplits addObject:candidate forKey:key];
                [key release];
            } else {
                [existingArcList addObject:parentArc];
                if (!_cacheForwardOnArcs) {
                    free(arcState);
                }
            }
        }
    }
    [arcHashTable release];
    if ([node numParents] == 0) {
        [self removeParentlessNodeFromMDD:node fromLayer:layerInfo.layerIndex];
    }
}
-(MDDNode*) splitArc:(char*)arcState layerInfo:(struct LayerInfo)layerInfo {
    char* newProperties = malloc(_numForwardBytes * sizeof(char));
    memcpy(newProperties, arcState, _numForwardBytes);
    MDDStateValues* newState = [[MDDStateValues alloc] initState:newProperties numBytes:_numForwardBytes trail:_trail];
    return [[MDDNode alloc] initNode:_trail minChildIndex:layerInfo.minDomain maxChildIndex:layerInfo.maxDomain state:newState layer:layerInfo.layerIndex indexOnLayer:_layerSize[layerInfo.layerIndex]._val numReverseBytes:_numReverseBytes numCombinedBytes:_numCombinedBytes];
}
-(int) splitCandidatesOnLayer:(struct LayerInfo)layerInfo {
    int highestShrunkLayer = layerInfo.layerIndex+1;
    while (![_candidateSplits empty] && _layerSize[layerInfo.layerIndex]._val < _relaxationSize) {
        NSArray* candidate = [_candidateSplits extractBest];
        char* newForwardProperties = malloc(_numForwardBytes);
        MDDNode* newNode = [self createNodeWithProperties:newForwardProperties onLayer:layerInfo.layerIndex];
        MDDNode* oldChild = [[candidate firstObject] child];
        char* reverse = [getReverseState(oldChild) stateValues];
        [_forwardQueue enqueue:oldChild];
        TRId* children = [oldChild children];
        bool merged = false;
        char* computedForwardProperties = [self computeForwardStateFromArcs:candidate isMerged:&merged layerInfo:layerInfo];
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
                highestShrunkLayer = min(highestShrunkLayer, [self deleteArcWhileCheckingParent:arc parentLayer:layerInfo.layerIndex-1]);
            }
        }
        if ([oldChild isParentless]) {
            [self removeParentlessNodeFromMDD:oldChild fromLayer:layerInfo.layerIndex];
        }
        [candidate release];
    }
    return highestShrunkLayer;
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
-(MDDNode*)findExactMatchForState:(char*)state onLayer:(struct LayerInfo)layerInfo {
    ORTRIdArrayI* layer = _layers[layerInfo.layerIndex];
    for (int i = 0; i < _layerSize[layerInfo.layerIndex]._val; i++) {
        MDDNode* node = [layer at:i];
        char* otherState = [getForwardState(node) stateValues];
        if (memcmp(state, otherState, _numForwardBytes) == 0) {
            return node;
        }
    }
    return nil;
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
    if ([_spec canChooseValue:arcValue forVariable:layerInfo.variableIndex fromParentForward:properties combined:[getCombinedState(node) stateValues] toChildReverse:childReverse combined:[getCombinedState(child) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
        if (!hasChildren) {
            [self addNode:node toLayer:layerInfo.layerIndex];
            [_trail trailRelease:state];
            [_trail trailRelease:node];
            //Need to make sure newNode is on trailRelease since its inner values are about to be changed (which are trailables)
        }
        if (_cacheForwardOnArcs) {
            bool* arcValues = malloc(sizeof(bool));
            arcValues[0] = true;
            arcValues -= arcValue;
            [[MDDArc alloc] initArc:_trail from:node to:child value:arcValue inPost:_inPost state:[_spec computeForwardStateFromForward:properties combined:[getCombinedState(node) stateValues] assigningVariable:layerInfo.variableIndex withValues:arcValues numArcs:1 minDom:arcValue maxDom:arcValue] spec:_spec];
            arcValues += arcValue;
            free(arcValues);
        } else {
            [[MDDArc alloc] initArcWithoutCache:_trail from:node to:child value:arcValue inPost:_inPost];
        }
        assignTRInt(&layerInfo.variableCount[arcValue], layerInfo.variableCount[arcValue]._val+1, _trail);
        hasChildren = true;
    }
    return hasChildren;
}



-(void) deleteInnerNode:(MDDNode*)node {
    int layer = [node layer];
    if (layer == 0 || layer == _numVariables) failNow();
    [self checkChildrenOfParentlessNode:node parentLayer:layer-1];
    [self checkParentsOfChildlessNode:node parentLayer:layer-1];
    [self removeNode: node onLayer:layer];
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
    
    for (int childIndex = _minDomainsByLayer[layer]; numChildren; childIndex++) {
        id childArc = children[childIndex];
        if (childArc != nil) {
            [self deleteArcWhileCheckingChild:childArc childLayer:childLayer];
            numChildren--;
        }
    }
}
-(int) removeChildlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer {
    if (layer == _numVariables) return layer;
    if (_layerSize[layer]._val == 1) { failNow(); }
    int highestShrunkLayer = [self checkParentsOfChildlessNode:node parentLayer:layer-1];
    [self removeNode: node onLayer:layer];
    return highestShrunkLayer;
}
-(int) checkParentsOfChildlessNode:(MDDNode*)node parentLayer:(int)layer {
    int highestShrunkLayer = layer+1;
    ORTRIdArrayI* parents = [node parents];
    while (![node isParentless]) {
        MDDArc* parentArc = [parents at: 0];
        highestShrunkLayer = min(highestShrunkLayer, [self deleteArcWhileCheckingParent:parentArc parentLayer:layer]);
    }
    return highestShrunkLayer;
}
-(void) deleteArcWhileCheckingChild:(MDDArc*)arc childLayer:(int)layer {
    int arcValue = [arc arcValue];
    MDDNode* child = [arc child];
    [arc deleteArc:_inPost];
    if ([child isParentless]) {
        [self removeParentlessNodeFromMDD:child fromLayer:layer];
    } else if (_dualDirectional) {
        [_forwardQueue enqueue:child];
    }
    assignTRInt(&_layerVariableCount[layer-1][arcValue], _layerVariableCount[layer-1][arcValue]._val-1, _trail);
}
-(int) deleteArcWhileCheckingParent:(MDDArc*)arc parentLayer:(int)layer {
    int highestShrunkLayer = layer+2;
    int arcValue = [arc arcValue];
    MDDNode* parent = [arc parent];
    [arc deleteArc:_inPost];
    if ([parent isChildless]) {
        highestShrunkLayer = [self removeChildlessNodeFromMDD:parent fromLayer:layer];
    } else if (_dualDirectional) {
        [_reverseQueue enqueue:parent];
    }
    assignTRInt(&_layerVariableCount[layer][arcValue], _layerVariableCount[layer][arcValue]._val-1, _trail);
    return highestShrunkLayer;
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
