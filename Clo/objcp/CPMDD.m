/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngineI.h>
#import "CPMDD.h"
#import "CPIntVarI.h"

static inline id getTopDownState(MDDNode* n) { return n->_topDownState;}
static inline id getBottomUpState(MDDNode* n) { return n->_bottomUpState;}
@implementation CPIRMDD
-(id) initCPIRMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec recommendationStyle:(MDDRecommendationStyle)recommendationStyle gamma:(id*)gamma {
    self = [super initCPCoreConstraint: engine];
    
    _engine = engine;
    
    //State/Spec info
    _spec = [spec retain];
    _hashWidth = relaxationSize * 2;
    [_spec finalizeSpec:_trail hashWidth:_hashWidth];
    _numSpecs = [_spec numSpecs];
    _numTopDownBytes = [_spec numTopDownBytes];
    _numBottomUpBytes = [_spec numBottomUpBytes];
    _dualDirectional = [_spec dualDirectional];
    
    //Variable info
    _x = x;
    _numVariables = [_x count];
    _nextVariable = _minVariableIndex = [_x low];
    
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
    _variableBitDomains = malloc(_numVariables * sizeof(TRInt*));
    _variableBitDomains -= _minVariableIndex;
    _layerBound = malloc(_numVariables * sizeof(TRInt));
    
    //Heuristic info
    _relaxationSize = relaxationSize;
    _recommendationStyle = recommendationStyle;
    _maxNumPasses = 5*_relaxationSize;
    _maxRebootDistance = 0;
    
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
    
    _topDownQueue = [[CPMDDQueue alloc] initCPMDDQueue:(int)_numVariables+1 width:_relaxationSize isTopDown:true];
    _bottomUpQueue = [[CPMDDQueue alloc] initCPMDDQueue:(int)_numVariables+1 width:_relaxationSize isTopDown:false];
    
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
        int varIndex = _layerToVariable[i];
        _variableBitDomains[varIndex] += _minDomainsByLayer[i];
        free(_variableBitDomains[varIndex]);
    }
    [_layers[_numVariables] release];
    free(_layers);
    free(_layerSize);
    free(_layerToVariable);
    _variableToLayer += _minVariableIndex;
    free(_variableToLayer);
    
    _variableBitDomains += _minVariableIndex;
    free(_variableBitDomains);
    free(_minDomainsByLayer);
    free(_maxDomainsByLayer);
    free(_layerBound);
    
    [_topDownQueue release];
    [_bottomUpQueue release];
    
    for (int i = 0; i < _numSpecs; i++) {
        _fixpointVars[i] = nil;
    }
    free(_fixpointVars);
    free(_fixpointMinValues);
    free(_fixpointMaxValues);
    
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
    MDDNode* root = [[MDDNode alloc] initNode:_trail minChildIndex:_minDomainsByLayer[0] maxChildIndex:_maxDomainsByLayer[0] state:rootState layer:0 indexOnLayer:0 numBottomUpBytes:_numBottomUpBytes hashWidth:_hashWidth];
    [self addNode:root toLayer:0];
    [rootState release];
    [root release];
    
    MDDStateValues* sinkState = [_spec createSinkState];
    MDDNode* sink = [[MDDNode alloc] initSinkNode:_trail defaultBottomUpState:sinkState layer:(int)_numVariables numTopDownBytes:_numTopDownBytes hashWidth:_hashWidth];
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
    _variableBitDomains[_nextVariable] = bitDomain;
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
    TRInt* bitDomain = _variableBitDomains[parentVariableIndex];
    id<CPIntVar> var = _x[parentVariableIndex];
    MDDNode* parentNode = [_layers[parentLayerIndex] at: 0];
    MDDStateValues* parentState = getTopDownState(parentNode);
    TRInt* variableCount = _layerVariableCount[parentLayerIndex];
    
    //Create new node and state
    char* newStateProperties = malloc(_numTopDownBytes);
    MDDNode* newNode;
    if (layerIndex == (int)_numVariables) {
        newNode = [_layers[layerIndex] at:0];
    } else {
        newNode = [self createNodeWithProperties:newStateProperties onLayer:layerIndex];
    }
    
    char* edgeProperties;
    bool firstState = true;
    for (int edgeValue = _minDomainsByLayer[parentLayerIndex]; edgeValue <= _maxDomainsByLayer[parentLayerIndex]; edgeValue++) {
        if (bitDomain[edgeValue]._val) {
            //Either add edge for that value or remove value from variable
            if ([_spec canCreateState:&edgeProperties fromParent:parentState assigningVariable:parentVariableIndex toValue:edgeValue objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
                [[MDDArc alloc] initArc:_trail from:parentNode to:newNode value:edgeValue inPost:_inPost state:edgeProperties numTopDownByte:_numTopDownBytes];
                assignTRInt(&variableCount[edgeValue],variableCount[edgeValue]._val+1, _trail);
                if (firstState) {
                    memcpy(newStateProperties, edgeProperties, _numTopDownBytes);
                    firstState = false;
                } else {
                    [_spec mergeTempStateProperties:newStateProperties with:edgeProperties];
                }
            } else {
                bitDomain[edgeValue] = makeTRInt(_trail, 0);
                [var remove:edgeValue];
            }
        }
    }
}
-(MDDNode*) createNodeWithProperties:(char*)properties onLayer:(int)layerIndex {
    MDDStateValues* state = [[MDDStateValues alloc] initState:properties numBytes:_numTopDownBytes hashWidth:_hashWidth trail:_trail];
    MDDNode* node = [[MDDNode alloc] initNode:_trail minChildIndex:_minDomainsByLayer[layerIndex] maxChildIndex:_maxDomainsByLayer[layerIndex] state:state layer:layerIndex indexOnLayer:_layerSize[layerIndex]._val numBottomUpBytes:_numBottomUpBytes hashWidth:_hashWidth];
    [self addNode:node toLayer:layerIndex];
    [state release];
    [node release];
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
        struct LayerInfo propagationLayerInfo = {.layerIndex = layerIndex, .variableIndex = variableIndex, .variableCount = _layerVariableCount[layerIndex], .bitDomain = _variableBitDomains[variableIndex], .minDomain = _minDomainsByLayer[layerIndex], .maxDomain = _maxDomainsByLayer[layerIndex]};
        [variable whenChangeDo:^() {
            [_topDownQueue clear];
            [_bottomUpQueue clear];
            if ([self updateLayer:propagationLayerInfo]) {
                [self updateAllLayers];
                //[self recordObjectiveBounds];
                [self fillQueues];
                int numPassesWithSplit = 0;
                while (!([_topDownQueue isEmpty] && [_bottomUpQueue isEmpty])) {
                    if (_dualDirectional) {
                        [_bottomUpQueue reboot];
                        [self bottomUpPass];
                    }
                    [_topDownQueue reboot];
                    if (numPassesWithSplit < _maxNumPasses) {
                        [self topDownPassWithSplit];
                        numPassesWithSplit++;
                    } else {
                        [self topDownPassWithoutSplit];
                    }
                    //[self updateObjectiveBounds];
                }
                //[self updateObjectiveVars];
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
            [_topDownQueue enqueue:node];
            if (_dualDirectional) {
                [_bottomUpQueue enqueue:node];
            }
        }
    }
}
-(void) updateAllLayers {
    for (int otherLayerIndex = 0; otherLayerIndex < _numVariables; otherLayerIndex++) {
        if (_layerBound[otherLayerIndex]._val) continue;
        struct LayerInfo layerInfo = {.layerIndex = otherLayerIndex, .variableIndex = _layerToVariable[otherLayerIndex], .variableCount = _layerVariableCount[otherLayerIndex], .bitDomain = _variableBitDomains[_layerToVariable[otherLayerIndex]], .minDomain = _minDomainsByLayer[otherLayerIndex], .maxDomain = _maxDomainsByLayer[otherLayerIndex]};
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
            }
            if ([node isChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layerIndex];
                nodeIndex--;
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
    TRInt* bitDomain = _variableBitDomains[variableIndex];
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


-(void) bottomUpPass {
    MDDNode* node;
    while ((node = [_bottomUpQueue dequeue]) != nil) {
        if ([node isDeleted] || [node layer] == _numVariables) continue;
        bool stateChanged = [self refreshBottomUpStateFor:node];
        if (stateChanged) {
            [_topDownQueue enqueue:node];
            [self enqueueRelativesOf:node];
        }
    }
}
-(void) topDownPassWithSplit {
    int splittingLayer = 1;
    MDDNode* node;
    while ((node = [_topDownQueue dequeue]) != nil) {
        int filterLayer = [node layer];
        if (splittingLayer < filterLayer) {
            [self splitLayer:splittingLayer];
            splittingLayer++;
            [_topDownQueue rebootTo:splittingLayer];
            if (![node isDeleted]) {
                [_topDownQueue enqueue:node];
            }
            continue;
        }
        bool stateChanged = [self refreshTopDownStateFor:node];
        stateChanged = [self refreshStateFor:node] || stateChanged;
        if (![self stateExistsFor:node]) {
            [self deleteInnerNode:node];
            continue;
        }
        [self updateChildrenOf:node stateChanged:stateChanged];
        if ([node isChildless]) {
            [self removeChildlessNodeFromMDD:node fromLayer:filterLayer];
        } else if (stateChanged) {
            [self enqueueRelativesOf:node];
        }
    }
}
-(void) topDownPassWithoutSplit {
    MDDNode* node;
    while ((node = [_topDownQueue dequeue]) != nil) {
        bool stateChanged = [self refreshTopDownStateFor:node];
        stateChanged = [self refreshStateFor:node] || stateChanged;
        if (![self stateExistsFor:node]) {
            [self deleteInnerNode:node];
            continue;
        }
        [self updateChildrenOf:node stateChanged:stateChanged];
        if ([node isChildless]) {
            [self removeChildlessNodeFromMDD:node fromLayer:[node layer]];
        } else if (stateChanged) {
            [self enqueueRelativesOf:node];
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
            [_topDownQueue enqueue:[children[i] child]];
            remainingChildren--;
        }
    }
}
-(void) enqueueParentsOf:(MDDNode*)node {
    if (_dualDirectional) {
        ORTRIdArrayI* parents = [node parents];
        int numParents = [node numParents];
        for (int i = 0; i < numParents; i++) {
            [_bottomUpQueue enqueue:[(MDDArc*)[parents at:i] parent]];
        }
    }
}
-(void) enqueueNode:(MDDNode*)node {
    [_topDownQueue enqueue:node];
    if (_dualDirectional) {
        [_bottomUpQueue enqueue:node];
    }
}
-(bool) refreshBottomUpStateFor:(MDDNode*)node {
    bool stateChanged = false;
    
    char* newValues = [self computeBottomUpStateFromChildrenOf:node];
    char* oldValues = [getBottomUpState(node) stateValues];
    if (memcmp(oldValues, newValues, _numBottomUpBytes) != 0) {
        stateChanged = true;
        [node updateBottomUpState:newValues];
    }
    free(newValues);
    return stateChanged;
}
-(bool) refreshTopDownStateFor:(MDDNode*)node {
    if ([node layer] == 0) return false;
    bool stateChanged = false;
    bool merged = false;
    int numParents = [node numParents];
    ORTRIdArrayI* parentArcs = [node parents];
    char* newValues = malloc(_numTopDownBytes * sizeof(char));
    MDDArc* firstParentArc = [parentArcs at:0];
    memcpy(newValues, [firstParentArc topDownState], _numTopDownBytes);
    for (int parentIndex = 1; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        char* arcState = [parentArc topDownState];
        if (merged) {
            [_spec mergeTempStateProperties:newValues with:arcState];
        } else if (memcmp(newValues, arcState, _numTopDownBytes) != 0) {
            merged = true;
            [_spec mergeTempStateProperties:newValues with:arcState];
        }
    }
    
    char* oldValues = [getTopDownState(node) stateValues];
    if (memcmp(oldValues, newValues, _numTopDownBytes) != 0) {
        stateChanged = true;
        [node updateTopDownState:newValues];
    }
    free(newValues);
    [node setIsMergedNode:merged];
    return stateChanged;
}
-(bool) refreshStateFor:(MDDNode*)node {
    //[_spec updateState:getTopDownState(node)];
    return false;
}
-(char*) computeBottomUpStateFromChildrenOf:(MDDNode*)node {
    int maxNumChildren = min([node numChildren],_layerSize[[node layer]+1]._val);
    MDDNode** childNodes = malloc(maxNumChildren * sizeof(MDDNode*));
    ORIntSetI** arcValuesByChild = malloc(maxNumChildren * sizeof(ORIntSetI*));
    int numChildNodes = [self fillNodeArcVarsFromChildrenOfNode:node childNodes:childNodes arcValuesByChild:arcValuesByChild];
    char* bottomUpStateValues = [self computeBottomUpStateFromChildren:childNodes arcValueSets:arcValuesByChild numChildren:numChildNodes];
    for (int i = 0; i < numChildNodes; i++) {
        [arcValuesByChild[i] release];
    }
    free(childNodes);
    free(arcValuesByChild);
    return bottomUpStateValues;
}
-(int) fillNodeArcVarsFromChildrenOfNode:(MDDNode*)node childNodes:(MDDNode**)childNodes arcValuesByChild:(ORIntSetI**)arcValuesByChild {
    TRId* childArcs = [node children];
    int layer = [node layer];
    int remainingChildren = [node numChildren];
    int numChildNodes = 0;
    for (int childIndex = _minDomainsByLayer[layer]; remainingChildren; childIndex++) {
        if (childArcs[childIndex] != nil) {
            MDDArc* childArc = childArcs[childIndex];
            int arcValue = [childArc arcValue];
            MDDNode* child = [childArc child];
            bool foundChild = false;
            for (int i = 0; i < numChildNodes; i++) {
                if (childNodes[i] == child) {
                    [arcValuesByChild[i] insert:arcValue];
                    foundChild = true;
                    break;
                }
            }
            if (!foundChild) {
                childNodes[numChildNodes] = child;
                arcValuesByChild[numChildNodes] = [[ORIntSetI alloc] initORIntSetI];
                [arcValuesByChild[numChildNodes] insert:arcValue];
                numChildNodes++;
            }
            remainingChildren--;
        }
    }
    return numChildNodes;
}
-(char*) computeBottomUpStateFromChildren:(MDDNode**)children arcValueSets:(ORIntSetI**)arcValuesByChild numChildren:(int)numChildNodes {
    char* stateValues = [self computeStateFromChild:children[0] arcValues:arcValuesByChild[0]];
    for (int childNodeIndex = 1; childNodeIndex < numChildNodes; childNodeIndex++) {
        char* otherStateValues = [self computeStateFromChild:children[childNodeIndex] arcValues:arcValuesByChild[childNodeIndex]];
        [_spec mergeTempBottomUpStateProperties:stateValues with:otherStateValues];
        free(otherStateValues);
    }
    return stateValues;
}
-(char*) computeStateFromChild:(MDDNode*)child arcValues:(ORIntSetI*)arcValues {
    return [_spec computeBottomUpStateFromProperties:[getTopDownState(child) stateValues] bottomUp:[getBottomUpState(child) stateValues] assigningVariable:_layerToVariable[[child layer]-1] withValues:arcValues];
}
-(bool) stateExistsFor:(MDDNode*)node {
    //return [_spec stateExistence:getTopDownState(node)];
    return true;
}
-(void) updateChildrenOf:(MDDNode*)node stateChanged:(bool)stateChanged {
    int layer = [node layer];
    if (layer == _numVariables) return;
    MDDStateValues* state = getTopDownState(node);
    char* stateValues = [state stateValues];
    TRId* childrenArcs = [node children];
    int remainingChildren = [node numChildren];
    int variableIndex = _layerToVariable[layer];
    TRInt* variableCount = _layerVariableCount[layer];
    for (int childIndex = _minDomainsByLayer[layer]; remainingChildren; childIndex++) {
        if (childrenArcs[childIndex] != nil) {
            MDDArc* childArc = childrenArcs[childIndex];
            MDDNode* child = [childArc child];
            if (![_spec canChooseValue:childIndex forVariable:variableIndex fromParent:stateValues toChild:[getBottomUpState(child) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
                [childArc deleteArc:_inPost];
                assignTRInt(&variableCount[childIndex], variableCount[childIndex]._val-1, _trail);
                if ([child isParentless]) {
                    [self removeParentlessNodeFromMDD:child fromLayer:layer+1];
                } else {
                    [_topDownQueue enqueue:child];
                }
            } else if (stateChanged) {
                char* oldState = [childArc topDownState];
                char* newState = [_spec computeTopDownStateFromProperties:stateValues assigningVariable:variableIndex withValue:childIndex];
                if (memcmp(newState, oldState, _numTopDownBytes) != 0) {
                    [childArc replaceTopDownStateWith:newState trail:_trail];
                }
                free(newState);
            }
            
            remainingChildren--;
        }
    }
}
-(void) splitLayer:(int)layer {
    int variableIndex = _layerToVariable[layer];
    ORTRIdArrayI* layerNodes = _layers[layer];
    struct LayerInfo layerInfo = {.layerIndex = layer, .variableIndex = variableIndex, .variableCount = _layerVariableCount[layer], .bitDomain = _variableBitDomains[variableIndex], .minDomain = _minDomainsByLayer[layer], .maxDomain = _maxDomainsByLayer[layer]};
    
    for (int nodeIndex = 0; nodeIndex < _layerSize[layer]._val && _layerSize[layer]._val < _relaxationSize; nodeIndex++) {
        MDDNode* node = [layerNodes at:nodeIndex];
        if ([node candidateForSplitting]) {
            [self enqueueChildrenOf:node];
            [self splitNode:node layerInfo:layerInfo];
            if ([node isDeleted]) {
                nodeIndex--;
            }
        }
    }
}
-(void) splitNode:(MDDNode*)node layerInfo:(struct LayerInfo)layerInfo {
    NodeHashTable* nodeHashTable = [[NodeHashTable alloc] initNodeHashTable:_hashWidth numBytes:_numTopDownBytes];
    ORTRIdArrayI* parentArcs = [node parents];
    TRId* children = [node children];
    char* bottomUp = [getBottomUpState(node) stateValues];
    
    while ([node numParents] && _layerSize[layerInfo.layerIndex]._val < _relaxationSize) {
        MDDArc* parentArc = [parentArcs at:0];
        MDDNode* parent = [parentArc parent];
        char* arcState = [parentArc topDownState];
        if (_dualDirectional) {
            [_bottomUpQueue enqueue:parent];
        }
        MDDNode* existingNode;
        if (![nodeHashTable hasNodeWithStateProperties:arcState hashValue:[_spec hashValueFor:arcState] node:&existingNode]) {
            [self splitArc:parentArc oldChildArcs:children layerInfo:layerInfo addToHashTable:nodeHashTable oldBottomUp:bottomUp];
        } else {
            [parentArc updateChildTo:existingNode inPost:_inPost];
        }
    }
    [self connectParents:parentArcs ofNode:node toEquivalentStatesIn:nodeHashTable];
    if ([node isParentless]) {
        [self removeParentlessNodeFromMDD:node fromLayer:layerInfo.layerIndex];
    } else {
        [self enqueueNode:node];
    }
    [nodeHashTable release];
}
-(void) splitArc:(MDDArc*)parentArc oldChildArcs:(MDDArc**)oldChildArcs layerInfo:(struct LayerInfo)layerInfo addToHashTable:(NodeHashTable*)nodeHashTable oldBottomUp:(char*)bottomUp {
    char* newProperties = malloc(_numTopDownBytes * sizeof(char));
    memcpy(newProperties, [parentArc topDownState], _numTopDownBytes);
    MDDStateValues* newState = [[MDDStateValues alloc] initState:newProperties numBytes:_numTopDownBytes hashWidth:_hashWidth trail:_trail];
    MDDNode* newNode = [[MDDNode alloc] initNode:_trail minChildIndex:layerInfo.minDomain maxChildIndex:layerInfo.maxDomain state:newState layer:layerInfo.layerIndex indexOnLayer:_layerSize[layerInfo.layerIndex]._val numBottomUpBytes:_numBottomUpBytes hashWidth:_hashWidth];
    
    if ([self checkChildrenOfNewNode:newNode withOldChildren:oldChildArcs layerInfo:layerInfo]) {
        [self addNode:newNode toLayer:layerInfo.layerIndex];
        [newNode updateBottomUpState:bottomUp];
        [parentArc updateChildTo:newNode inPost:_inPost];
        [nodeHashTable addState:newState];
    } else {
        int arcValue = [parentArc arcValue];
        assignTRInt(&_layerVariableCount[layerInfo.layerIndex-1][arcValue], _layerVariableCount[layerInfo.layerIndex-1][arcValue]._val-1, _trail);
        [parentArc deleteArc:_inPost];
        MDDNode* parent = [parentArc parent];
        if ([parent isChildless]) {
            [self removeChildlessNodeFromMDD:parent fromLayer:layerInfo.layerIndex-1];
        }
        [newNode release];
        [newState release];
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
    MDDStateValues* state = getTopDownState(node);
    char* properties = [state stateValues];
    int arcValue = [oldChildArc arcValue];
    MDDNode* child = [oldChildArc child];
    char* childBottomUp = [(MDDStateValues*)getBottomUpState(child) stateValues];
    if ([_spec canChooseValue:arcValue forVariable:layerInfo.variableIndex fromParent:properties toChild:childBottomUp objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues]) {
        if (!hasChildren) {
            [_trail trailRelease:state];
            [_trail trailRelease:node];
            //Need to make sure newNode is on trailRelease since its inner values are about to be changed (which are trailables)
        }
        [[MDDArc alloc] initArc:_trail from:node to:child value:arcValue inPost:_inPost state:[_spec computeTopDownStateFromProperties:properties assigningVariable:layerInfo.variableIndex withValue:arcValue] numTopDownByte:_numTopDownBytes];
        assignTRInt(&layerInfo.variableCount[arcValue], layerInfo.variableCount[arcValue]._val+1, _trail);
        hasChildren = true;
    }
    return hasChildren;
}
-(void) connectParents:(ORTRIdArrayI*)parentArcs ofNode:(MDDNode*)node toEquivalentStatesIn:(NodeHashTable*)nodeHashTable {
    int numParents = [node numParents];
    for (int parentIndex = 0; parentIndex < numParents; parentIndex++) {
        MDDArc* parentArc = [parentArcs at:parentIndex];
        char* arcState = [parentArc topDownState];
        NSUInteger hashValue = [_spec hashValueFor:arcState];
        MDDNode* existingNode;
        bool nodeExists = [nodeHashTable hasNodeWithStateProperties:arcState hashValue:hashValue node:&existingNode];
        if (nodeExists) {
            [parentArc updateChildTo:existingNode inPost:_inPost];
            parentIndex--;
            numParents--;
        }
    }
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
                [self DEBUGcheckNodeLayerIndexCorrectness];
                [_topDownQueue enqueue:child];
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
    TRInt* variableCount = _layerVariableCount[layer];
    
    while (![node isParentless]) {
        MDDArc* parentArc = [parents at: 0];
        int arcValue = [parentArc arcValue];
        MDDNode* parent = [parentArc parent];
        [parentArc deleteArc:_inPost];
        if ([parent isChildless]) {
            [self removeChildlessNodeFromMDD:parent fromLayer:layer];
        } else if (_dualDirectional) {
            [_bottomUpQueue enqueue:parent];
        }
        assignTRInt(&variableCount[arcValue], variableCount[arcValue]._val-1, _trail);
    }
}
-(void) removeNode:(MDDNode*)node onLayer:(int)layerIndex {
    [self removeNodeAt:[node indexOnLayer] onLayer:layerIndex];
}
-(void) removeNodeAt:(int)index onLayer:(int)layerIndex {
    ORTRIdArrayI* layer = _layers[layerIndex];
    MDDNode* node = [layer at:index];
    [_topDownQueue retract:node];
    [_bottomUpQueue retract:node];
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
    char* sinkState = [getTopDownState(sink) stateValues];
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
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTopDownMDD: Method recommendationFor needs better way to figure out correct variable."];
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
        TRInt* bitDomain = _variableBitDomains[variableId];
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
        TRInt* bitDomain = _variableBitDomains[variableId];
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
    }else if (_recommendationStyle == SmallestSlack) {
        ORTRIdArrayI* nextLayer = _layers[layer+1];
        int layerSize = _layerSize[layer+1]._val;
        MDDNode* bestNode = [nextLayer at:0];
        char* state = [(MDDStateValues*)getTopDownState(bestNode) stateValues];
        long lowestSlackValue;
        if (layerSize != 1) {
            lowestSlackValue = [_spec slack:state];
        }
        for (int i = 1; i < layerSize; i++) {
            MDDNode* node = [nextLayer at:i];
            state = [(MDDStateValues*)getTopDownState(node) stateValues];
            long slackValue = [_spec slack:state];
            if (slackValue < lowestSlackValue) {
                bestNode = node;
                if (slackValue == 0) {
                    break;
                }
            }
        }
        return [[[bestNode parents] at:0] arcValue];
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
@end

@implementation NodeHashTable
-(id) initNodeHashTable:(int)width numBytes:(size_t)numBytes {
    self = [super init];
    _width = width;
    _stateLists = malloc(_width * sizeof(MDDStateValues**));
    _statePropertiesLists = malloc(_width * sizeof(char**));
    _numPerHash = calloc(_width, sizeof(int));
    _maxPerHash = calloc(_width, sizeof(int));
    _numBytes = numBytes;
    return self;
}
-(bool) hasNodeWithStateProperties:(char*)stateProperties hashValue:(NSUInteger)hash node:(MDDNode**)existingNode {
    _lastCheckedHash = hash;
    int numWithHash = _numPerHash[_lastCheckedHash];
    if (!numWithHash) return false;
    char** propertiesList = _statePropertiesLists[_lastCheckedHash];
    bool foundNode;
    for (int i = 0; i < numWithHash; i++) {
        char* existingProperties = propertiesList[i];
        foundNode = true;
        for (int j = 0; j < _numBytes; j+=[MDDStateSpecification bytesPerMagic]) {
            if (*(int*)&stateProperties[j] != *(int*)&existingProperties[j]) {
                foundNode = false;
                break;
            }
        }
        if (foundNode) {
            *existingNode = (MDDNode*)[_stateLists[_lastCheckedHash][i] node];
            return true;
        }
    }
    return false;
}
-(void) addState:(MDDStateValues*)state {
    int numStates = _numPerHash[_lastCheckedHash];
    if (numStates == 0) {
        _maxPerHash[_lastCheckedHash] = 2;
        _stateLists[_lastCheckedHash] = malloc(2 * sizeof(MDDStateValues*));
        _statePropertiesLists[_lastCheckedHash] = malloc(2 * sizeof(char*));
    } else if (numStates == _maxPerHash[_lastCheckedHash]) {
        int newMax = _maxPerHash[_lastCheckedHash] * 2;
        _maxPerHash[_lastCheckedHash] = newMax;
        MDDStateValues** newList = malloc(newMax * sizeof(MDDStateValues*));
        char** newProperties = malloc(newMax * sizeof(char*));
        MDDStateValues** oldList = (MDDStateValues**)(_stateLists[_lastCheckedHash]);
        char** oldProperties = _statePropertiesLists[_lastCheckedHash];
        for (int i = 0; i < numStates; i++) {
            newList[i] = oldList[i];
            newProperties[i] = oldProperties[i];
        }
        free(oldList);
        free(oldProperties);
        _stateLists[_lastCheckedHash] = (MDDStateValues* __strong *)newList;
        _statePropertiesLists[_lastCheckedHash] = newProperties;
    }
    _stateLists[_lastCheckedHash][numStates] = state;
    _statePropertiesLists[_lastCheckedHash][numStates] = [state stateValues];
    _numPerHash[_lastCheckedHash] += 1;
    return;
}
-(void) dealloc {
    for (int i = 1; i < _width; i++) {
        if (_maxPerHash[i] > 0) {
            free(_stateLists[i]);
            free(_statePropertiesLists[i]);
        }
    }
    free(_stateLists);
    free(_statePropertiesLists);
    free(_numPerHash);
    free(_maxPerHash);
    [super dealloc];
}
@end
