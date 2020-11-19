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
-(id) initCPIRMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec recommendationStyle:(MDDRecommendationStyle)recommendationStyle splitAllLayersBeforeFiltering:(bool)splitAllLayersBeforeFiltering maxSplitIter:(int)maxSplitIter maxRebootDistance:(int)maxRebootDistance useStateExistence:(bool)useStateExistence  numNodesSplitAtATime:(int)numNodesSplitAtATime numNodesDefinedAsPercent:(bool)numNodesDefinedAsPercent splittingStyle:(int)splittingStyle gamma:(id*)gamma {
    self = [super initCPCoreConstraint: engine];
    
    _cacheForwardOnArcs = false;
    _cacheReverseOnArcs = false;
    
    if (splittingStyle == 0) {
        _additionalExactSplit = false;
        _additionalSplitByLayer = false;
    } else if (splittingStyle == 1) {
        _additionalExactSplit = true;
        _additionalSplitByLayer = false;
    } else {
        _additionalExactSplit = true;
        _additionalSplitByLayer = true;
    }
    
    _variableRelaxationSize = false;
    
    _useDefaultNodeRank = ![spec nodePriorityUsed];
    _useDefaultArcRank = ![spec candidatePriorityUsed];
    
    _numNodesSplitAtATime = numNodesSplitAtATime;
    _numNodesDefinedAsPercent = numNodesDefinedAsPercent;
    
    _approximateEquivalenceClasses = [spec approximateEquivalenceUsed];
    _useStateExistence = useStateExistence;
    
    _splitAllLayersBeforeFiltering = splitAllLayersBeforeFiltering;
    
    _engine = engine;
    
    //State/Spec info
    _spec = [spec retain];
    _hashWidth = relaxationSize * 2;
    [_spec finalizeSpec:_trail hashWidth:_hashWidth];
    _numSpecs = [_spec numSpecs];
    _minConstraintPriority = [_spec minConstraintPriority];
    _maxConstraintPriority = [_spec maxConstraintPriority];
    _numForwardBytes = [_spec numForwardBytes];
    _numReverseBytes = [_spec numReverseBytes];
    _numCombinedBytes = [_spec numCombinedBytes];
    _dualDirectional = [_spec dualDirectional];
    _forwardArcHashTable = [[ArcHashTable alloc] initArcHashTable:_hashWidth numBytes:_numForwardBytes spec:_spec singlePriority:(_minConstraintPriority == _maxConstraintPriority) cachedOnArc:_cacheForwardOnArcs forward:true];
    _reverseArcHashTable = [[ArcHashTable alloc] initArcHashTable:_hashWidth numBytes:_numReverseBytes spec:_spec singlePriority:(_minConstraintPriority == _maxConstraintPriority) cachedOnArc:_cacheReverseOnArcs forward:false];
    
    //Variable info
    _x = x;
    _numVariables = [_x count];
    _nextVariable = _minVariableIndex = [_x low];
    _firstMergedLayer = makeTRInt(_trail, 1);
    _lastMergedLayer = makeTRInt(_trail, (int)_numVariables-1);

    _relaxationSizes = malloc((_numVariables+1) * sizeof(int));
    _relaxationSizes[0] = 1;
    _relaxationSizes[_numVariables] = 1;
    if (_variableRelaxationSize) {
        //One new node per layer
        //Small on top, large on bottom
        /*if (_numVariables <= 2*relaxationSize) {
            int baseSize = relaxationSize - (int)_numVariables/2;
            for (int i = 1; i < _numVariables; i++) {
                _relaxationSizes[i] = baseSize + i;
            }
        } else {
            //Scaling at ends
            for (int i = 1; i < _numVariables; i++) {
                if (i <= relaxationSize) {
                    _relaxationSizes[i] = i;
                } else if (i >= _numVariables - relaxationSize) {
                    _relaxationSizes[i] = 2 * relaxationSize - ((int)_numVariables - i);
                } else {
                    _relaxationSizes[i] = relaxationSize;
                }
            }
            //Scaling at center
            for (int i = 1; i < _numVariables; i++) {
                if (i <= _numVariables/2 - relaxationSize) {
                    _relaxationSizes[i] = 1;
                } else if (i >= _numVariables/2 + relaxationSize) {
                    _relaxationSizes[i] = 2 * relaxationSize;
                } else {
                    _relaxationSizes[i] = relaxationSize + i - (int)_numVariables/2;
                }
            }
        }
        _relaxationSize = relaxationSize*2;*/
        //Small on ends, large in center
        if (relaxationSize < _numVariables/4) {
            for (int i = 1; i < _numVariables; i++) {
                if (i <= relaxationSize) {
                    _relaxationSizes[i] = i;
                } else if (i >= _numVariables - relaxationSize) {
                    _relaxationSizes[i] =  (int)_numVariables - i;
                } else {
                    _relaxationSizes[i] = relaxationSize;
                }
            }
            _relaxationSize = relaxationSize;
        } else {
            for (int i = 1; i < _numVariables; i++) {
                _relaxationSizes[i] = relaxationSize + (int)_numVariables/4 - abs((int)_numVariables/2 - i);
            }
            _relaxationSize = relaxationSize + (int)_numVariables/4;
        }
        
        //Blocks of four
        //Small on ends, large in middle
        /*for (int i = 1; i < _numVariables; i++) {
            if (i < _numVariables/4) {
                _relaxationSizes[i] = max(1, relaxationSize/2);
            } else if (i < _numVariables/2) {
                _relaxationSizes[i] = max(1, 3*relaxationSize/2);
            } else if (i < 3 * _numVariables/4) {
                _relaxationSizes[i] = max(1, 3*relaxationSize/2);
            } else {
                _relaxationSizes[i] = max(1, relaxationSize/2);
            }
        }
        _relaxationSize = 3 * relaxationSize/2;*/
        //Large on ends, small in middle
        /*for (int i = 1; i < _numVariables; i++) {
            if (i < _numVariables/4) {
                _relaxationSizes[i] = max(1, 3*relaxationSize/2);
            } else if (i < _numVariables/2) {
                _relaxationSizes[i] = max(1, relaxationSize/2);
            } else if (i < 3 * _numVariables/4) {
                _relaxationSizes[i] = max(1, relaxationSize/2);
            } else {
                _relaxationSizes[i] = max(1, 3*relaxationSize/2);
            }
        }
        _relaxationSize = 3*relaxationSize/2;*/
        //Large to small
        /*for (int i = 1; i < _numVariables; i++) {
            if (i < _numVariables/4) {
                _relaxationSizes[i] = max(1, relaxationSize*2);
            } else if (i < _numVariables/2) {
                _relaxationSizes[i] = max(1, relaxationSize);
            } else if (i < 3 * _numVariables/4) {
                _relaxationSizes[i] = max(1, relaxationSize/2);
            } else {
                _relaxationSizes[i] = max(1, relaxationSize/4);
            }
        }
        _relaxationSize = 2 * relaxationSize;*/
        //Small to Large
        /*for (int i = 1; i < _numVariables; i++) {
            if (i < _numVariables/4) {
                _relaxationSizes[i] = max(1, relaxationSize/4);
            } else if (i < _numVariables/2) {
                _relaxationSizes[i] = max(1, relaxationSize/2);
            } else if (i < 3 * _numVariables/4) {
                _relaxationSizes[i] = max(1, relaxationSize);
            } else {
                _relaxationSizes[i] = max(1, relaxationSize*2);
            }
        }
        _relaxationSize = 2 * relaxationSize;*/
    } else {
        for (int i = 1; i < _numVariables; i++) {
            _relaxationSizes[i] = relaxationSize;
        }
        _relaxationSize = relaxationSize;
    }
    
    //Layer info
    _layers = (ORTRIdArrayI* __strong *)calloc(sizeof(ORTRIdArrayI*), _numVariables+1);
    _layerToVariable = malloc((_numVariables) * sizeof(int));
    _variableToLayer = malloc((_numVariables) * sizeof(int));
    _variableToLayer -= _minVariableIndex;
    _layerVariableCount = malloc((_numVariables) * sizeof(TRInt*));
    _layerSize = malloc((_numVariables+1) * sizeof(TRInt));
    for (int i = 0; i <= _numVariables; i++) {
        _layerSize[i] = makeTRInt(_trail,0);
        _layers[i] = [[ORTRIdArrayI alloc] initORTRIdArray:_trail low:0 size:_relaxationSizes[i]];
    }
    
    //Domain info
    _minDomainsByLayer = malloc(_numVariables * sizeof(int));
    _maxDomainsByLayer = malloc(_numVariables * sizeof(int));
    _layerBitDomains = malloc(_numVariables * sizeof(TRInt*));
    _layerBound = malloc(_numVariables * sizeof(TRInt));
    
    _nodes = malloc(_relaxationSize * sizeof(MDDNode*));
    _arcValuesByNode = malloc(_relaxationSize * sizeof(bool*));
    _numArcsPerNode = malloc(_relaxationSize * sizeof(int));
    _deltas = malloc(_relaxationSize * sizeof(bool*));
    
    //Splitting queues
    _candidateSplits = [[ORPQueue alloc] init:^BOOL(NSNumber* a, NSNumber* b) {
        return [a intValue] >= [b intValue];
    }];
    _splittableNodes = [[ORPQueue alloc] init:^BOOL(NSNumber* a, NSNumber* b) {
        return [a intValue] >= [b intValue];
    }];
    
    //Heuristic info
    _recommendationStyle = recommendationStyle;
    _maxSplitIter = maxSplitIter;
    _maxRebootDistance = maxRebootDistance;
    
    //Objective info
    _objectiveVarsUsed = false;
    _fixpointMinValues = malloc(_numSpecs * sizeof(TRInt));
    _fixpointMaxValues = malloc(_numSpecs * sizeof(TRInt));
    id<ORIntVar>* fixpointVars = [_spec fixpointVars];
    _fixpointVars = (id<CPIntVar> __strong *)calloc(sizeof(id<CPIntVar>), _numSpecs);
    for (int i = 0; i < _numSpecs; i++) {
        if (fixpointVars[i] != nil) {
            _fixpointVars[i] = gamma[[fixpointVars[i] getId]];
            _objectiveVarsUsed = true;
        }
    }
    _fixpointMinFunctions = (DDFixpointBoundClosure __strong *)[_spec fixpointMins];
    _fixpointMaxFunctions = (DDFixpointBoundClosure __strong *)[_spec fixpointMaxes];
    
    //_forwardQueue = [[CPMDDQueue alloc] initCPMDDQueue:(int)_numVariables+1 width:_relaxationSize isForward:true];
    //_reverseQueue = [[CPMDDQueue alloc] initCPMDDQueue:(int)_numVariables+1 width:_relaxationSize isForward:false];
    //_forwardDeletionQueue = [[CPMDDDeletionQueue alloc] initCPMDDQueue:(int)_numVariables+1 width:_relaxationSize isForward:true];
    //_reverseDeletionQueue = [[CPMDDDeletionQueue alloc] initCPMDDQueue:(int)_numVariables+1 width:_relaxationSize isForward:false];
    _forwardQueue = [[CPMDDQueue alloc] initCPMDDQueue:(int)_numVariables+1 widths:_relaxationSizes isForward:true];
    _reverseQueue = [[CPMDDQueue alloc] initCPMDDQueue:(int)_numVariables+1 widths:_relaxationSizes isForward:false];
    _forwardDeletionQueue = [[CPMDDDeletionQueue alloc] initCPMDDQueue:(int)_numVariables+1 widths:_relaxationSizes isForward:true];
    _reverseDeletionQueue = [[CPMDDDeletionQueue alloc] initCPMDDQueue:(int)_numVariables+1 widths:_relaxationSizes isForward:false];
    
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
    
    free(_relaxationSizes);
    
    free(_layerBitDomains);
    free(_minDomainsByLayer);
    free(_maxDomainsByLayer);
    free(_layerBound);
    
    [_forwardQueue release];
    [_reverseQueue release];
    [_forwardDeletionQueue release];
    [_reverseDeletionQueue release];
    
    free(_nodes);
    free(_arcValuesByNode);
    free(_numArcsPerNode);
    free(_deltas);
    
    for (int i = 0; i < _numSpecs; i++) {
        _fixpointVars[i] = nil;
    }
    free(_fixpointVars);
    free(_fixpointMinValues);
    free(_fixpointMaxValues);
    
    [_candidateSplits release];
    [_splittableNodes release];
    
    [_forwardArcHashTable release];
    [_reverseArcHashTable release];
    
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
    
    if (_objectiveVarsUsed) {
        [self setInitialFixpointRanges];
    }
    [self createRootAndSink];
    int layer;
    for (layer = 1; layer < _numVariables; layer++) {
        [self assignVariableToLayer:layer];
        [self buildLayer:layer];
    }
    [self buildLayer:layer];
    
    [self setLayerInfos];
    
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
            if (_objectiveVarsUsed ? [_spec canCreateState:&edgeProperties forward:parentProperties combined:nil assigningVariable:parentVariableIndex toValue:edgeValue objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues] :
                [_spec canCreateState:&edgeProperties forward:parentProperties combined:nil assigningVariable:parentVariableIndex toValue:edgeValue]) {
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
    if (layerIndex == (int)_numVariables) {
        [getForwardState(newNode) replaceUnusedStateWith:newStateProperties trail:_trail];
    }
    [newNode setIsMergedForward:true inCreation:true];
    [newNode updateRelaxedForward];
    [self updateCombinedStateFor:newNode];
}
-(MDDNode*) createNodeWithProperties:(char*)properties onLayer:(int)layerIndex {
    MDDStateValues* state = [[MDDStateValues alloc] initState:properties numBytes:_numForwardBytes trail:_trail];
    MDDNode* node = [[MDDNode alloc] initNode:_trail minChildIndex:_minDomainsByLayer[layerIndex] maxChildIndex:_maxDomainsByLayer[layerIndex] state:state layer:layerIndex indexOnLayer:_layerSize[layerIndex]._val numReverseBytes:_numReverseBytes numCombinedBytes:_numCombinedBytes];
    return node;
}
-(MDDNode*) createNodeWithEmptyPropertiesOnLayer:(int)layerIndex {
    char* properties = malloc(_numForwardBytes);
    MDDStateValues* state = [[MDDStateValues alloc] initEmptyState:properties numBytes:_numForwardBytes trail:_trail];
    MDDNode* node = [[MDDNode alloc] initNode:_trail minChildIndex:_minDomainsByLayer[layerIndex] maxChildIndex:_maxDomainsByLayer[layerIndex] state:state layer:layerIndex indexOnLayer:_layerSize[layerIndex]._val numReverseBytes:_numReverseBytes numCombinedBytes:_numCombinedBytes];
    return node;
}

-(void) setLayerInfos {
    _layerInfos = malloc((_numVariables+1) * sizeof(struct LayerInfo));
    for (int i = 0; i < _numVariables; i++) {
        _layerInfos[i].layerIndex = i;
        _layerInfos[i].variableIndex = _layerToVariable[i];
        _layerInfos[i].variableCount = _layerVariableCount[i];
        _layerInfos[i].bitDomain = _layerBitDomains[i];
        _layerInfos[i].minDomain = _minDomainsByLayer[i];
        _layerInfos[i].maxDomain = _maxDomainsByLayer[i];
    }
    _layerInfos[_numVariables].layerIndex = (int)_numVariables;
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
        [variable whenChangeDo:^() {
            [_forwardQueue clear];
            [_reverseQueue clear];
            [_forwardDeletionQueue clear];
            [_reverseDeletionQueue clear];
            if ([self updateLayer:_layerInfos[layerIndex]]) {
                [self updateAllLayers];
                [_forwardDeletionQueue reboot];
                [self forwardPassCheckDeletion];
                [_reverseDeletionQueue reboot];
                [self reversePassCheckDeletion];
                if (_objectiveVarsUsed) {
                    [self recordObjectiveBounds];
                }
                [self propagate];
                //[self drawGraph];
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
        if (_passIteration < _maxSplitIter) {
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
        if (_objectiveVarsUsed) {
            [self updateObjectiveBounds];
        }
    }
    if (_objectiveVarsUsed) {
        [self updateObjectiveVars];
    }
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
        [self updateLayer:_layerInfos[otherLayerIndex]];
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
    for (int nodeIndex = 0; numEdgesToDelete; nodeIndex++) {
        MDDNode* node = [layer at: nodeIndex];
        MDDArc* childArc = [node children][value];
        if (childArc != NULL) {
            MDDNode* child = [childArc child];
            [childArc deleteArc:_inPost];
            /*if ([child isParentless]) {
                [self removeParentlessNodeFromMDD:child fromLayer:layerIndex+1];
            } else if ([child isMerged]) {
                [_forwardQueue enqueue:child];
            }
            if ([node isChildless]) {
                [self removeChildlessNodeFromMDD:node fromLayer:layerIndex];
                nodeIndex--;
            } else if (_dualDirectional) {
                [_reverseQueue enqueue:node];
            }*/
            [_forwardDeletionQueue enqueue:child];
            [_reverseDeletionQueue enqueue:node];
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
    int activeLayer = (int)_numVariables;
    MDDNode* node;
    while (true) {
        node = [_reverseQueue dequeue];
        if ([node isDeleted] || [node layer] == _numVariables) continue;
        int nodeLayer = [node layer];
        if (node == nil) {
            while (activeLayer >= 0 && [_reverseDeletionQueue numOnLayer:activeLayer] == 0) {
                activeLayer--;
            }
            if (activeLayer >= 0) {
                [self checkReverseDeletionOnLayer:activeLayer];
                [_reverseQueue rebootTo:activeLayer];
                continue;
            } else {
                return;
            }
        }
        if (activeLayer > nodeLayer) {
            //Move activeLayer to next layer that needs deletion check
            while (activeLayer > nodeLayer && [_reverseDeletionQueue numOnLayer:activeLayer] == 0) {
                activeLayer--;
            }
            [self checkReverseDeletionOnLayer:activeLayer];
            if (![node isDeleted]) {
                [_reverseQueue enqueue:node];
            }
            [_reverseQueue rebootTo:activeLayer];
        } else {
            if (nodeLayer == 50) {
                int i =0;
            }
            [self updateNodeReverse:node layer:nodeLayer];
        }
    }
}
-(void) forwardPassOnlySplit {
    _splitPass = 1;
    int layerIndex = _firstMergedLayer._val;
    int numSplits = 0;
    while (layerIndex <= _lastMergedLayer._val) {
        [self checkForwardDeletionOnLayer:layerIndex];
        if ([self candidateLayerForSplitting:layerIndex]) {
            numSplits++;
            [self splitLayer:layerIndex forward:true];
            [_reverseDeletionQueue rebootTo:layerIndex];
            int highestShrunkLayer = [self reversePassCheckDeletion];
            if (_maxRebootDistance && highestShrunkLayer < layerIndex) {
                layerIndex = max(highestShrunkLayer, layerIndex - _maxRebootDistance);
            } else {
                if (_additionalExactSplit && _additionalSplitByLayer && [self candidateLayerForSplitting:layerIndex]) {
                    layerIndex = [self secondPassOnLayer:layerIndex];
                } else {
                    layerIndex++;
                }
            }
        } else {
            layerIndex++;
        }
    }
    if (_additionalExactSplit && !_additionalSplitByLayer) {
        _splitPass = 2;
        layerIndex = _firstMergedLayer._val;
        while (layerIndex <= _lastMergedLayer._val) {
            [self checkForwardDeletionOnLayer:layerIndex];
            [self splitLayer:layerIndex forward:true];
            [_reverseDeletionQueue rebootTo:layerIndex];
            int highestShrunkLayer = [self reversePassCheckDeletion];
            if (_maxRebootDistance && highestShrunkLayer < layerIndex) {
                layerIndex = max(highestShrunkLayer, layerIndex - _maxRebootDistance);
            } else {
                layerIndex++;
            }
        }
    }
}
-(int) secondPassOnLayer:(int)layerIndex {
    _splitPass = 2;
    [self splitLayer:layerIndex forward:true];
    [_reverseDeletionQueue rebootTo:layerIndex];
    int highestShrunkLayer = [self reversePassCheckDeletion];
    _splitPass = 1;
    if (_maxRebootDistance && highestShrunkLayer < layerIndex) {
        return max(highestShrunkLayer, layerIndex - _maxRebootDistance);
    } else {
        return layerIndex + 1;
    }
}
-(bool) candidateLayerForSplitting:(int)layer {
    return _layerSize[layer]._val < _relaxationSizes[layer] && ![_x[_layerToVariable[layer]] bound];
}
-(void) reversePassOnlySplit {
    for (int layerIndex = (int)_numVariables-1; layerIndex > 0; layerIndex--) {
        [self checkReverseDeletionOnLayer:layerIndex];
        [self splitLayer:layerIndex forward:false];
        [_reverseDeletionQueue rebootTo:layerIndex];
        [self reversePassCheckDeletion];
    }
}
-(void) forwardPassWithSplit {
    int splittingLayer = _firstMergedLayer._val;
    int activeLayer = 0;
    MDDNode* node;
    while ((node = [_forwardQueue dequeue]) != nil) {
        int filterLayer = [node layer];
        if (activeLayer != filterLayer) {
            activeLayer = filterLayer;
            [self checkForwardDeletionOnLayer:activeLayer];
        }
        if (splittingLayer < filterLayer) {
            if (splittingLayer == _lastMergedLayer._val + 1) {
                splittingLayer = (int)_numVariables+1;
            } else {
                [self splitLayer:splittingLayer forward:true];
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
    int activeLayer = 0;
    MDDNode* node;
    while (true) {
        node = [_forwardQueue dequeue];
        if (node == nil) {
            while (activeLayer <= _numVariables && [_forwardDeletionQueue numOnLayer:activeLayer] == 0) {
                activeLayer++;
            }
            if (activeLayer <= _numVariables) {
                [self checkForwardDeletionOnLayer:activeLayer];
                [_forwardQueue rebootTo:activeLayer];
                continue;
            } else {
                return;
            }
        }
        int nodeLayer = [node layer];
        if (activeLayer < nodeLayer) {
            //Move activeLayer to next layer that needs deletion check
            while (activeLayer < nodeLayer && [_forwardDeletionQueue numOnLayer:activeLayer] == 0) {
                activeLayer++;
            }
            [self checkForwardDeletionOnLayer:activeLayer];
            if (![node isDeleted]) {
                [_forwardQueue enqueue:node];
            }
            [_forwardQueue rebootTo:activeLayer];
        } else {
            [self updateNodeForward:node layer:nodeLayer];
        }
    }
}
-(void) checkForwardDeletionOnLayer:(int)layer {
    [_forwardDeletionQueue rebootTo:layer];
    MDDNode* node;
    while ((node = [_forwardDeletionQueue dequeue]) != nil) {
        if ([node layer] != layer) {
            [_forwardDeletionQueue enqueue:node];
            return;
        }
        if ([node isParentless]) {
            [self removeParentlessNodeFromMDD:node fromLayer:layer];
        } else {
            [_forwardQueue enqueue:node];
        }
    }
}
-(void) checkReverseDeletionOnLayer:(int)layer {
    [_reverseDeletionQueue rebootTo:layer];
    MDDNode* node;
    while ((node = [_reverseDeletionQueue dequeue]) != nil) {
        if ([node layer] != layer) {
            [_reverseDeletionQueue enqueue:node];
            return;
        }
        if ([node isChildless]) {
            [self removeChildlessNodeFromMDD:node fromLayer:layer];
        } else if (_dualDirectional) {
            [_reverseQueue enqueue:node];
        }
    }
}
-(int) forwardPassCheckDeletion {
    int layer = 0;
    MDDNode* node;
    while ((node = [_forwardDeletionQueue dequeue]) != nil) {
        layer = [node layer];
        if ([node isParentless]) {
            [self removeParentlessNodeFromMDD:node fromLayer:layer];
        } else {
            [_forwardQueue enqueue:node];
        }
    }
    return layer;
}
-(int) reversePassCheckDeletion {
    int layer = INT_MAX;
    MDDNode* node;
    while ((node = [_reverseDeletionQueue dequeue]) != nil) {
        if ([node isChildless]) {
            layer = [node layer];
            [self removeChildlessNodeFromMDD:node fromLayer:layer];
        } else if (_dualDirectional) {
            [_reverseQueue enqueue:node];
        }
    }
    return layer;
}
-(void) updateNodeForward:(MDDNode*)node layer:(int)layer {
    bool forwardStateChanged = [self refreshForwardStateFor:node];
    if (forwardStateChanged || _objectiveBoundsChanged) {
        bool combinedStateChanged = [self updateCombinedStateFor:node];
        if (_useStateExistence && ![self stateExistsFor:node]) {
            [self deleteInnerNode:node];
            return;
        }
        if (layer != 0 && (combinedStateChanged || _objectiveBoundsChanged)) {
            [self updateParentsOf:node];
            if ([node isParentless]) {
                [self removeParentlessNodeFromMDD:node fromLayer:layer];
                return;
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
                return;
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
    bool merged = false;
    char* newValues;
    if ([node childrenChanged]) {
        newValues = [self computeReverseStateFromChildrenOf:node isMerged:&merged];
    } else {
        newValues = [self updateReverseStateFromChildrenOf:node isMerged:&merged];
        if (newValues == nil) {
            return false;
        }
    }
    char* oldValues = [getReverseState(node) stateValues];
    if (oldValues == nil || memcmp(oldValues, newValues, _numReverseBytes) != 0) {
        stateChanged = true;
        bool* delta = _diffReverse(_spec, _diffReverseSel, oldValues, newValues);
        //bool* delta = [_spec diffReverseProperties:oldValues to:newValues];
        [node setReversePropertyDelta:delta passIteration:_passIteration];
        [node updateReverseState:newValues];
    }
    free(newValues);
    [node setIsMergedReverse:merged inCreation:false];
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
    [node setIsMergedForward:merged inCreation:false];
    [node updateRelaxedForward];
    return stateChanged;
}
-(bool) updateCombinedStateFor:(MDDNode*)node {
    if (_numCombinedBytes == 0) return false;
    char* oldCombinedState = [getCombinedState(node) stateValues];
    char* newCombinedState = [_spec computeCombinedStateFromProperties:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues]];
    if (oldCombinedState == nil || memcmp(oldCombinedState, newCombinedState, _numCombinedBytes) != 0) {
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
        int numParentNodes = [self fillNodeArcVarsUsingArcs:arcs parentLayerIndex:parentLayerIndex];
        newValues = [self computeForwardStateFromNumParents:numParentNodes minDom:_minDomainsByLayer[parentLayerIndex] maxDom:_maxDomainsByLayer[parentLayerIndex] isMerged:merged];
        for (int i = 0; i < numParentNodes; i++) {
            _arcValuesByNode[i] += _minDomainsByLayer[parentLayerIndex];
            free(_arcValuesByNode[i]);
        }
    }
    return newValues;
}
-(char*) computeReverseStateFromArcs:(NSArray*)arcs isMerged:(bool*)merged layerInfo:(struct LayerInfo)layerInfo {
    char* newValues;
    //bool firstArc = true;
    if (_cacheReverseOnArcs) {
        return nil;
        /*for (MDDArc* arc in arcs) {
            if (firstArc) {
                newValues = malloc(_numReverseBytes);
                memcpy(newValues, [arc reverseState], _numReverseBytes);
                firstArc = false;
            } else {
                char* arcState = [arc reverseState];
                if (*merged) {
                    [_spec mergeStateProperties:newValues with:arcState];
                } else if (memcmp(newValues, arcState, _numReverseBytes) != 0) {
                    *merged = true;
                    [_spec mergeStateProperties:newValues with:arcState];
                }
            }
        }*/
    } else {
        int childLayerIndex = layerInfo.layerIndex+1;
        int numChildNodes = [self fillNodeArcVarsUsingArcs:arcs childLayerIndex:childLayerIndex];
        newValues = [self computeReverseStateFromNumChildren:numChildNodes minDom:_minDomainsByLayer[childLayerIndex] maxDom:_maxDomainsByLayer[childLayerIndex] isMerged:merged];
        for (int i = 0; i < numChildNodes; i++) {
            _arcValuesByNode[i] += _minDomainsByLayer[childLayerIndex];
            free(_arcValuesByNode[i]);
        }
    }
    return newValues;
}
-(char*) computeForwardStateFromParentsOf:(MDDNode*)node isMerged:(bool*)merged {
    int parentLayer = [node layer]-1;
    int numParentNodes = [self fillNodeArcVarsFromParentsOfNode:node];
    char* forwardStateValues = [self computeForwardStateFromNumParents:numParentNodes minDom:_minDomainsByLayer[parentLayer] maxDom:_maxDomainsByLayer[parentLayer] isMerged:merged];
    for (int i = 0; i < numParentNodes; i++) {
        _arcValuesByNode[i] += _minDomainsByLayer[parentLayer];
        free(_arcValuesByNode[i]);
    }
    return forwardStateValues;
}
-(char*) updateForwardStateFromParentsOf:(MDDNode*)node isMerged:(bool*)merged {
    int parentLayer = [node layer]-1;
    int numParentNodes = [self fillNodeArcVarsFromParentsOfNode:node];
    int numDeltas = 0;
    for (int i = 0; i < numParentNodes; i++) {
        bool* parentDelta = [_nodes[i] forwardDeltaForPassIteration:_passIteration];
        if (parentDelta != nil) {
            _deltas[numDeltas] = parentDelta;
            numDeltas++;
        }
    }
    char* forwardStateValues;
    if (numDeltas) {
        bool* propertyImpact = [_spec forwardPropertyImpactFrom:_deltas numParents:numDeltas variable:_layerToVariable[parentLayer]];
        forwardStateValues = [self updateForwardStateFromNumParents:numParentNodes minDom:_minDomainsByLayer[parentLayer] maxDom:_maxDomainsByLayer[parentLayer] properties:propertyImpact oldState:[getForwardState(node) stateValues] isMerged:merged];
        *merged = *merged || [node isMergedForward];
        free(propertyImpact);
    } else {
        forwardStateValues = nil;
    }
    for (int i = 0; i < numParentNodes; i++) {
        _arcValuesByNode[i] += _minDomainsByLayer[parentLayer];
        free(_arcValuesByNode[i]);
    }
    return forwardStateValues;
}
-(char*) updateForwardStateFromNumParents:(int)numParentNodes minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged {
    char* stateValues = [self updateStateFromParent:_nodes[0] arcValues:_arcValuesByNode[0] numArcs:_numArcsPerNode[0] minDom:minDom maxDom:maxDom properties:properties oldState:oldState isMerged:merged];
    for (int parentNodeIndex = 1; parentNodeIndex < numParentNodes; parentNodeIndex++) {
        char* otherStateValues = [self updateStateFromParent:_nodes[parentNodeIndex] arcValues:_arcValuesByNode[parentNodeIndex] numArcs:_numArcsPerNode[parentNodeIndex] minDom:minDom maxDom:maxDom properties:properties oldState:oldState isMerged:merged];
        if (memcmp(stateValues, otherStateValues, _numForwardBytes) != 0) {
            [_spec mergeStateProperties:stateValues with:otherStateValues properties:properties];
            *merged = true;
        }
        free(otherStateValues);
    }
    return stateValues;
}

-(char*) updateReverseStateFromChildrenOf:(MDDNode*)node isMerged:(bool*)merged {
    int nodeLayer = [node layer];
    int numChildNodes = [self fillNodeArcVarsFromChildrenOfNode:node];
    
    int numDeltas = 0;
    for (int i = 0; i < numChildNodes; i++) {
        bool* childDelta = [_nodes[i] reverseDeltaForPassIteration:_passIteration];
        if (childDelta != nil) {
            _deltas[numDeltas] = childDelta;
            numDeltas++;
        }
    }
    char* reverseStateValues;
    if (numDeltas) {
        bool* propertyImpact = [_spec reversePropertyImpactFrom:_deltas numChildren:numDeltas variable:_layerToVariable[nodeLayer]];
        reverseStateValues = [self updateReverseStateFromNumChildren:numChildNodes minDom:_minDomainsByLayer[nodeLayer] maxDom:_maxDomainsByLayer[nodeLayer] properties:propertyImpact oldState:[getReverseState(node) stateValues] isMerged:merged];
        *merged = *merged || [node isMergedReverse];
        free(propertyImpact);
    } else {
        reverseStateValues = nil;
    }
    for (int i = 0; i < numChildNodes; i++) {
        _arcValuesByNode[i] += _minDomainsByLayer[nodeLayer];
        free(_arcValuesByNode[i]);
    }
    return reverseStateValues;
}
-(char*) updateReverseStateFromNumChildren:(int)numChildNodes minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged {
    char* stateValues = [self updateStateFromChild:_nodes[0] arcValues:_arcValuesByNode[0] numArcs:_numArcsPerNode[0] minDom:minDom maxDom:maxDom properties:properties oldState:oldState isMerged:merged];
    for (int childNodeIndex = 1; childNodeIndex < numChildNodes; childNodeIndex++) {
        char* otherStateValues = [self updateStateFromChild:_nodes[childNodeIndex] arcValues:_arcValuesByNode[childNodeIndex] numArcs:_numArcsPerNode[childNodeIndex] minDom:minDom maxDom:maxDom properties:properties oldState:oldState isMerged:merged];
        if (memcmp(stateValues, otherStateValues, _numReverseBytes) != 0) {
            [_spec mergeReverseStateProperties:stateValues with:otherStateValues properties:properties];
            *merged = true;
        }
        free(otherStateValues);
    }
    return stateValues;
}
-(char*) computeReverseStateFromChildrenOf:(MDDNode*)node isMerged:(bool*)merged {
    int nodeLayer = [node layer];
    int numChildNodes = [self fillNodeArcVarsFromChildrenOfNode:node];
    char* reverseStateValues = [self computeReverseStateFromNumChildren:numChildNodes minDom:_minDomainsByLayer[nodeLayer] maxDom:_maxDomainsByLayer[nodeLayer] isMerged:merged];
    for (int i = 0; i < numChildNodes; i++) {
        _arcValuesByNode[i] += _minDomainsByLayer[nodeLayer];
        free(_arcValuesByNode[i]);
    }
    return reverseStateValues;
}
-(int) fillNodeArcVarsUsingArcs:(NSArray*)arcs parentLayerIndex:(int)parentLayer {
    int numParentNodes = 0;
    int domSize = _maxDomainsByLayer[parentLayer] - _minDomainsByLayer[parentLayer]+1;
    for (MDDArc* arc in arcs) {
        int arcValue = [arc arcValue];
        MDDNode* parent = [arc parent];
        bool foundParent = false;
        for (int i = 0; i < numParentNodes; i++) {
            if (_nodes[i] == parent) {
                _arcValuesByNode[i][arcValue] = true;
                foundParent = true;
                _numArcsPerNode[i] = _numArcsPerNode[i] + 1;
                break;
            }
        }
        if (!foundParent) {
            _nodes[numParentNodes] = parent;
            _arcValuesByNode[numParentNodes] = calloc(domSize, sizeof(bool));
            _arcValuesByNode[numParentNodes] -= _minDomainsByLayer[parentLayer];
            _arcValuesByNode[numParentNodes][arcValue] = true;
            _numArcsPerNode[numParentNodes] = 1;
            numParentNodes++;
        }
    }
    return numParentNodes;
}
-(int) fillNodeArcVarsUsingArcs:(NSArray*)arcs childLayerIndex:(int)childLayer {
    int numChildNodes = 0;
    int domSize = _maxDomainsByLayer[childLayer] - _minDomainsByLayer[childLayer]+1;
    for (MDDArc* arc in arcs) {
        int arcValue = [arc arcValue];
        MDDNode* child = [arc child];
        bool foundChild = false;
        for (int i = 0; i < numChildNodes; i++) {
            if (_nodes[i] == child) {
                _arcValuesByNode[i][arcValue] = true;
                foundChild = true;
                _numArcsPerNode[i] = _numArcsPerNode[i] + 1;
                break;
            }
        }
        if (!foundChild) {
            _nodes[numChildNodes] = child;
            _arcValuesByNode[numChildNodes] = calloc(domSize, sizeof(bool));
            _arcValuesByNode[numChildNodes] -= _minDomainsByLayer[childLayer];
            _arcValuesByNode[numChildNodes][arcValue] = true;
            _numArcsPerNode[numChildNodes] = 1;
            numChildNodes++;
        }
    }
    return numChildNodes;
}
-(int) fillNodeArcVarsFromParentsOfNode:(MDDNode*)node {
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
            if (_nodes[i] == parent) {
                _arcValuesByNode[i][arcValue] = true;
                foundParent = true;
                _numArcsPerNode[i] = _numArcsPerNode[i] + 1;
                break;
            }
        }
        if (!foundParent) {
            _nodes[numParentNodes] = parent;
            _arcValuesByNode[numParentNodes] = calloc(domSize, sizeof(bool));
            _arcValuesByNode[numParentNodes] -= _minDomainsByLayer[parentLayer];
            _arcValuesByNode[numParentNodes][arcValue] = true;
            _numArcsPerNode[numParentNodes] = 1;
            numParentNodes++;
        }
    }
    return numParentNodes;
}
-(int) fillNodeArcVarsFromChildrenOfNode:(MDDNode*)node {
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
                if (_nodes[i] == child) {
                    _arcValuesByNode[i][arcValue] = true;
                    foundChild = true;
                    _numArcsPerNode[i] = _numArcsPerNode[i] + 1;
                    break;
                }
            }
            if (!foundChild) {
                _nodes[numChildNodes] = child;
                _arcValuesByNode[numChildNodes] = calloc(domSize, sizeof(bool));
                _arcValuesByNode[numChildNodes] -= _minDomainsByLayer[layer];
                _arcValuesByNode[numChildNodes][arcValue] = true;
                _numArcsPerNode[numChildNodes] = 1;
                numChildNodes++;
            }
            remainingChildren--;
        }
    }
    return numChildNodes;
}
-(char*) computeForwardStateFromNumParents:(int)numParentNodes minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged {
    char* stateValues = [self computeStateFromParent:_nodes[0] arcValues:_arcValuesByNode[0] numArcs:_numArcsPerNode[0] minDom:minDom maxDom:maxDom isMerged:merged];
    for (int parentNodeIndex = 1; parentNodeIndex < numParentNodes; parentNodeIndex++) {
        char* otherStateValues = [self computeStateFromParent:_nodes[parentNodeIndex] arcValues:_arcValuesByNode[parentNodeIndex] numArcs:_numArcsPerNode[parentNodeIndex] minDom:minDom maxDom:maxDom isMerged:merged];
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
-(char*) computeReverseStateFromNumChildren:(int)numChildNodes minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged {
    char* stateValues = [self computeStateFromChild:_nodes[0] arcValues:_arcValuesByNode[0] numArcs:_numArcsPerNode[0] minDom:minDom maxDom:maxDom isMerged:merged];
    for (int childNodeIndex = 1; childNodeIndex < numChildNodes; childNodeIndex++) {
        char* otherStateValues = [self computeStateFromChild:_nodes[childNodeIndex] arcValues:_arcValuesByNode[childNodeIndex] numArcs:_numArcsPerNode[childNodeIndex] minDom:minDom maxDom:maxDom isMerged:merged];
        if (memcmp(stateValues, otherStateValues, _numReverseBytes) != 0) {
            [_spec mergeReverseStateProperties:stateValues with:otherStateValues];
            *merged = true;
        }
        free(otherStateValues);
    }
    return stateValues;
}
-(char*) computeStateFromChild:(MDDNode*)child arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom isMerged:(bool*)merged {
    return [_spec computeReverseStateFromProperties:[getReverseState(child) stateValues] combined:[getCombinedState(child) stateValues] assigningVariable:_layerToVariable[[child layer]-1] withValues:arcValues numArcs:numArcs minDom:minDom maxDom:maxDom merged:merged];
}
-(char*) updateStateFromChild:(MDDNode*)child arcValues:(bool*)arcValues numArcs:(int)numArcs minDom:(int)minDom maxDom:(int)maxDom properties:(bool*)properties oldState:(char*)oldState isMerged:(bool*)merged {
    return [_spec updateReverseStateFromReverse:[getReverseState(child) stateValues] combined:[getCombinedState(child) stateValues] assigningVariable:_layerToVariable[[child layer]-1] withValues:arcValues numArcs:numArcs minDom:minDom maxDom:maxDom properties:properties oldState:oldState merged:merged];
}
-(bool) stateExistsFor:(MDDNode*)node {
    return _objectiveVarsUsed ?
        [_spec stateExistsWithForward:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues] combined:[getCombinedState(node) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues] :
        [_spec stateExistsWithForward:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues] combined:[getCombinedState(node) stateValues]];
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
        if (!(_objectiveVarsUsed ?
              [_spec canChooseValue:arcValue forVariable:variableIndex fromParentForward:[getForwardState(parent) stateValues] combined:[getCombinedState(parent) stateValues] toChildReverse:reverseStateValues combined:combinedStateValues objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues] :
              [_spec canChooseValue:arcValue forVariable:variableIndex fromParentForward:[getForwardState(parent) stateValues] combined:[getCombinedState(parent) stateValues] toChildReverse:reverseStateValues combined:combinedStateValues])) {
            [self deleteArcWhileCheckingParent:parentArc parentLayer:layer-1];
            parentsChanged = true;
            numParents--;
            parentIndex--;
        } else if (_dualDirectional) {
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
            if (!(_objectiveVarsUsed ?
                  [_spec canChooseValue:childIndex forVariable:variableIndex fromParentForward:stateValues combined:combinedState toChildReverse:[getReverseState(child) stateValues] combined:[getCombinedState(child) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues] :
                  [_spec canChooseValue:childIndex forVariable:variableIndex fromParentForward:stateValues combined:combinedState toChildReverse:[getReverseState(child) stateValues] combined:[getCombinedState(child) stateValues]])) {
                [self deleteArcWhileCheckingChild:childArc childLayer:layer+1];
                childrenChanged = true;
            } else if (stateChanged) {
                if (_cacheForwardOnArcs) {
                    char* oldState = [childArc forwardState];
                    bool* arcValues = malloc(sizeof(bool));
                    arcValues[0] = true;
                    arcValues -= childIndex;
                    char* newState = [_spec computeForwardStateFromForward:stateValues combined:combinedState assigningVariable:variableIndex withValues:arcValues numArcs:1  minDom:childIndex maxDom:childIndex];
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
    if (childrenChanged && _dualDirectional) {
        [_reverseQueue enqueue:node];
    }
}
-(void) splitLayer:(int)layer forward:(bool)forward {
    [self emptySplittingQueues];
    
    int numNodesToSplit = max(1, min(_layerSize[layer]._val, _numNodesDefinedAsPercent ? (_layerSize[layer]._val / _numNodesSplitAtATime) : _numNodesSplitAtATime));
    
    for (int priority = _minConstraintPriority; priority <= _maxConstraintPriority; priority++) {
        [self fillSplittableNodesForLayer:layer atPriority:priority forward:forward];
        
        int numNodesSplit = 0;
        while (![_splittableNodes empty] && _layerSize[layer]._val < _relaxationSizes[layer]) {
            MDDNode* node = [_splittableNodes extractBest];
            if (forward) {
                [self enqueueChildrenOf:node];
            }
            
            if (forward) {
                [self forwardSplitNode:node layerInfo:_layerInfos[layer] priorityLevel:priority];
            } else {
                [self reverseSplitNode:node layerInfo:_layerInfos[layer] priorityLevel:priority];
            }
            numNodesSplit++;
            if (numNodesSplit == numNodesToSplit || [_splittableNodes empty]) {
                if ([_candidateSplits size] == 1) {
                    [[_candidateSplits extractBest] release];
                } else {
                    if (forward) {
                        [self forwardSplitCandidatesOnLayer:_layerInfos[layer]];
                    } else {
                        [self reverseSplitCandidatesOnLayer:_layerInfos[layer]];
                    }
                }
                numNodesSplit = 0;
            }
        }
    }
    
    if (forward) {
        [self updateFirstAndLastMergedLayersAfterSplitting:layer];
    }
}
-(void) updateFirstAndLastMergedLayersAfterSplitting:(int)layer {
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
        if ([[layer at:n] isMergedForward]) {
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
-(void) fillSplittableNodesForLayer:(int)layer atPriority:(int)priority forward:(bool)forward {
    ORTRIdArrayI* layerNodes = _layers[layer];
    for (int nodeIndex = 0; nodeIndex < _layerSize[layer]._val; nodeIndex++) {
        MDDNode* node = [layerNodes at:nodeIndex];
        if ([node candidateForSplittingForward:forward]) {
            NSNumber* key = [self keyForNode:node priority:priority forward:forward];
            [_splittableNodes addObject:node forKey:key];
            [key release];
        }
    }
    [_splittableNodes buildHeap];
}
-(void) forwardSplitNode:(MDDNode *)node layerInfo:(struct LayerInfo)layerInfo priorityLevel:(int)priority {
    [_forwardArcHashTable setPriority:priority];
    [_forwardArcHashTable setApproximate:(_splitPass == 1 && _approximateEquivalenceClasses)];
    if (_splitPass == 1 && _approximateEquivalenceClasses) {
        [_forwardArcHashTable setReverse:[getReverseState(node) stateValues]];
    }
    ORTRIdArrayI* parentArcs = [node parents];
    int numParents = [node numParents];
    //char* childReverse = [getReverseState(node) stateValues];
    //char* childCombined = [getCombinedState(node) stateValues];
    
    NSMutableArray* newCandidates = [[NSMutableArray alloc] init];
    
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
            
            if (![_forwardArcHashTable hasMatchingStateProperties:arcState forArc:parentArc arcList:&existingArcList]) {
                NSArray* candidate = [_forwardArcHashTable addArc:parentArc withState:arcState];
                [newCandidates addObject:candidate];
            } else {
                [existingArcList addObject:parentArc];
                if (!_cacheForwardOnArcs) {
                    free(arcState);
                }
            }
        }
    }
    int candNum = 0;
    for (NSArray* candidate in newCandidates) {
        NSNumber* key;
        if (_useDefaultArcRank) {
            //key = [NSNumber numberWithInt:(int)[candidate count]];
            MDDArc* firstArc = [candidate firstObject];
            MDDNode* parent = [firstArc parent];
            //key = [NSNumber numberWithInt:[firstArc parentArcIndex]];
            key = [NSNumber numberWithInt:[parent indexOnLayer] * (_maxDomainsByLayer[layerInfo.layerIndex-1]+1) - [firstArc arcValue]];
            //key = [NSNumber numberWithInt:(int)[parent numParents]];
        } else {
            if (candNum == 0) {
                key = [NSNumber numberWithInt:INT_MAX];
            }
            key = [NSNumber numberWithInt:[_spec candidatePriority:candidate]];
        }
        [_candidateSplits addObject:candidate forKey:key];
        candNum++;
        [key release];
    }
    [newCandidates release];
    [_forwardArcHashTable clear];
    if ([node numParents] == 0) {
        [self removeParentlessNodeFromMDD:node fromLayer:layerInfo.layerIndex];
    }
}
-(void) reverseSplitNode:(MDDNode *)node layerInfo:(struct LayerInfo)layerInfo priorityLevel:(int)priority {
    [_reverseArcHashTable clear];
    [_reverseArcHashTable setPriority:priority];
    [_reverseArcHashTable setApproximate:(_splitPass == 1 && _approximateEquivalenceClasses)];
    if (_splitPass == 1 && _approximateEquivalenceClasses) {
        [_reverseArcHashTable setForward:[getForwardState(node) stateValues]];
    }
    TRId* childArcs = [node children];
    int numChildren = [node numChildren];
    //char* parentForward = [getReverseState(node) stateValues];
    //char* parentCombined = [getCombinedState(node) stateValues];
    
    NSMutableArray* newCandidates = [[NSMutableArray alloc] init];
    
    for (int childIndex = _minDomainsByLayer[layerInfo.layerIndex]; numChildren; childIndex++) {
        MDDArc* childArc = childArcs[childIndex];
        if (childArc == nil) continue;
        numChildren--;
        MDDNode* child = [childArc child];
        char* arcState;
        if (_cacheReverseOnArcs) {
            arcState = nil;//[childArc reverseState];
        } else {
            bool* arcValues = malloc(sizeof(bool));
            arcValues[0] = true;
            arcValues -= childIndex;
            arcState = [_spec computeReverseStateFromReverse:[getForwardState(child) stateValues] combined:[getCombinedState(child) stateValues] assigningVariable:_layerToVariable[layerInfo.layerIndex] withValues:arcValues numArcs:1 minDom:childIndex maxDom:childIndex];
            arcValues += childIndex;
            free(arcValues);
        }
        NSMutableArray* existingArcList;
        
        if (![_reverseArcHashTable hasMatchingStateProperties:arcState forArc:childArc arcList:&existingArcList]) {
            NSArray* candidate = [_reverseArcHashTable addArc:childArc withState:arcState];
            [newCandidates addObject:candidate];
        } else {
            [existingArcList addObject:childArc];
            if (!_cacheForwardOnArcs) {
                free(arcState);
            }
        }
    }
    for (NSArray* candidate in newCandidates) {
        NSNumber* key;
        if (_useDefaultArcRank) {
            key = [NSNumber numberWithInt:(int)[candidate count]];
        } else {
            key = [NSNumber numberWithInt:[_spec candidatePriority:candidate]];
        }
        [_candidateSplits addObject:candidate forKey:key];
        [key release];
    }
    [newCandidates release];
    if ([node numChildren] == 0) {
        [self removeChildlessNodeFromMDD:node fromLayer:layerInfo.layerIndex];
    }
}
-(void) forwardSplitCandidatesOnLayer:(struct LayerInfo)layerInfo {
    while (![_candidateSplits empty] && _layerSize[layerInfo.layerIndex]._val < _relaxationSizes[layerInfo.layerIndex]) {
        NSArray* candidate = [_candidateSplits extractBest];
        MDDNode* newNode = [self createNodeWithEmptyPropertiesOnLayer:layerInfo.layerIndex];
        MDDNode* oldChild = [[candidate firstObject] child];
        char* reverse = [getReverseState(oldChild) stateValues];
        [_forwardQueue enqueue:oldChild];
        TRId* children = [oldChild children];
        bool merged = false;
        char* computedForwardProperties = [self computeForwardStateFromArcs:candidate isMerged:&merged layerInfo:layerInfo];
        [getForwardState(newNode) replaceUnusedStateWith:computedForwardProperties trail:_trail];
        [newNode setIsMergedForward:merged inCreation:true];
        [newNode setIsExactByApproximateEquivalence:true inCreation:true];
        if ([self checkChildrenOfNewNode:newNode withOldChildren:children layerInfo:layerInfo]) {
            for (MDDArc* arc in candidate) {
                [arc updateChildTo:newNode inPost:_inPost];
                if (_dualDirectional) {
                    [_reverseQueue enqueue: [arc parent]];
                }
            }
            if (_dualDirectional) {
                [newNode updateReverseState:reverse];
                [_reverseQueue enqueue:newNode];
            }
            [newNode updateRelaxedForward];
            [self updateCombinedStateFor:newNode];
        } else {
            [getForwardState(newNode) release];
            [newNode release];
            for (MDDArc* arc in candidate) {
                [self deleteArcWhileCheckingParent:arc parentLayer:layerInfo.layerIndex-1];
            }
        }
        if ([oldChild isParentless]) {
            [self removeParentlessNodeFromMDD:oldChild fromLayer:layerInfo.layerIndex];
        } else {
            [_forwardQueue enqueue:oldChild];
        }
        [candidate release];
    }
}
-(void) reverseSplitCandidatesOnLayer:(struct LayerInfo)layerInfo {
    /*while (![_candidateSplits empty] && _layerSize[layerInfo.layerIndex]._val < _relaxationSize) {
        NSArray* candidate = [_candidateSplits extractBest];
        MDDNode* oldParent = [(MDDArc*)[candidate firstObject] parent];
        char* forward = [getForwardState(oldParent) stateValues];
        MDDNode* newNode = [self createNodeWithProperties:forward onLayer:layerInfo.layerIndex];
        [_reverseQueue enqueue:oldParent];
        ORTRIdArrayI* parents = [oldParent parents];
        bool merged = false;
        char* computedReverseProperties = [self computeReverseStateFromArcs:candidate isMerged:&merged layerInfo:layerInfo];
        [newNode updateReverseState:computedReverseProperties];
        [newNode setIsMergedReverse:merged inCreation:true];
        [newNode setIsExactByApproximateEquivalence:[oldParent isExactByApproximateEquivalence] inCreation:true];
        if ([self checkParentsOfNewNode:newNode withOldParents:parents layerInfo:layerInfo]) {
            for (MDDArc* arc in candidate) {
                [arc updateChildTo:newNode inPost:_inPost];
            }
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
    }*/
}
-(NSNumber*) keyForNode:(MDDNode*)node priority:(int)priority forward:(bool)forward {
    if (_useDefaultNodeRank) {
        //return forward ? [NSNumber numberWithInt:[node numParents]] : [NSNumber numberWithInt:[node numChildren]];
        return forward ? [NSNumber numberWithInt:[node indexOnLayer]] : [NSNumber numberWithInt:[node indexOnLayer]];
    } else {
        return [NSNumber numberWithInt:[_spec nodePriority:[getForwardState(node) stateValues] reverse:[getReverseState(node) stateValues] combined:[getCombinedState(node) stateValues] node:node constraintPriority:priority]];
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
    if (_objectiveVarsUsed ?
        [_spec canChooseValue:arcValue forVariable:layerInfo.variableIndex fromParentForward:properties combined:[getCombinedState(node) stateValues] toChildReverse:childReverse combined:[getCombinedState(child) stateValues] objectiveMins:_fixpointMinValues objectiveMaxes:_fixpointMaxValues] :
        [_spec canChooseValue:arcValue forVariable:layerInfo.variableIndex fromParentForward:properties combined:[getCombinedState(node) stateValues] toChildReverse:childReverse combined:[getCombinedState(child) stateValues]]) {
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
    [self checkChildrenOfParentlessNode:node parentLayer:layer];
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
-(void) removeChildlessNodeFromMDD:(MDDNode*)node fromLayer:(int)layer {
    if (_layerSize[layer]._val == 1) { failNow(); }
    [self checkParentsOfChildlessNode:node parentLayer:layer-1];
    [self removeNode: node onLayer:layer];
}
-(void) checkParentsOfChildlessNode:(MDDNode*)node parentLayer:(int)layer {
    ORTRIdArrayI* parents = [node parents];
    while (![node isParentless]) {
        [self deleteArcWhileCheckingParent:[parents at: 0] parentLayer:layer];
    }
}
-(void) deleteArcWhileCheckingChild:(MDDArc*)arc childLayer:(int)layer {
    int arcValue = [arc arcValue];
    MDDNode* child = [arc child];
    [arc deleteArc:_inPost];
    //if ([child isParentless]) {
    //    [self removeParentlessNodeFromMDD:child fromLayer:[child layer]];
    //} else {
    //    [_forwardQueue enqueue:child];
    //}
    [_forwardDeletionQueue enqueue:child];
    assignTRInt(&_layerVariableCount[layer-1][arcValue], _layerVariableCount[layer-1][arcValue]._val-1, _trail);
}
-(void) deleteArcWhileCheckingParent:(MDDArc*)arc parentLayer:(int)layer {
    int arcValue = [arc arcValue];
    MDDNode* parent = [arc parent];
    [arc deleteArc:_inPost];
    //if ([parent isChildless]) {
    //    [self removeChildlessNodeFromMDD:parent fromLayer:[parent layer]];
    //} else {
    //    [_reverseQueue enqueue:parent];
    //}
    [_reverseDeletionQueue enqueue:parent];
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
    [_forwardDeletionQueue retract:node];
    [_reverseDeletionQueue retract:node];
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
                if (children[d] != nil && ![children[d] isMergedForward]) {
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
                if (children[d] != nil && [children[d] isMergedForward]) {
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


-(void) DEBUGcheckLayerVariableCountCorrectness {
    for (int l = 0; l < _numVariables; l++) {
        ORTRIdArrayI* layer = _layers[l];
        for (int v = _minDomainsByLayer[l]; v <= _maxDomainsByLayer[l]; v++) {
            int count = 0;
            for (int n = 0; n < _layerSize[l]._val; n++) {
                MDDNode* node = [layer at:n];
                if ([node children][v] != nil) {
                    count++;
                }
            }
            if (_layerVariableCount[l][v]._val != count) {
                @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Layer variable count is not correct."];
            }
        }
    }
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
-(void) DEBUGcheckNoParentlessNodes {
    for (int l = 1; l <= _numVariables; l++) {
        ORTRIdArrayI* layer = _layers[l];
        for (int n = 0; n < _layerSize[l]._val; n++) {
            MDDNode* node = [layer at:n];
            if ([node isParentless]) {
                @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Non-deleted parentless node found."];
            }
        }
    }
}
-(void) DEBUGcheckNoChildlessNodes {
    for (int l = 0; l < _numVariables; l++) {
        ORTRIdArrayI* layer = _layers[l];
        for (int n = 0; n < _layerSize[l]._val; n++) {
            MDDNode* node = [layer at:n];
            if ([node isChildless]) {
                @throw [[ORExecutionError alloc] initORExecutionError: "CPIRMDD: Non-deleted childless node found."];
            }
        }
    }
}

-(void) drawGraph {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/dotgraph.dot",
                                                  documentsDirectory];
    
    NSMutableString* content = [[NSMutableString alloc] initWithString:@"digraph G {\n"];
    for (int l = 1; l <= _numVariables; l++) {
        ORTRIdArrayI* layer = _layers[l];
        for (int n = 0; n < _layerSize[l]._val; n++) {
            MDDNode* node = [layer at:n];
            ORTRIdArrayI* parents = [node parents];
            for (int p = 0; p < [node numParents]; p++) {
                MDDArc* parentArc = [parents at:p];
                MDDNode* parent = [parentArc parent];
                [content appendFormat:@"    L%dN%d -> L%dN%d [label=\"%d\"]\n", l-1, [parent indexOnLayer], l, [node indexOnLayer], [parentArc arcValue]];
            }
        }
    }
    [content appendString:@"}"];
    [content writeToFile:fileName
                     atomically:NO
                           encoding:NSStringEncodingConversionAllowLossy
                                  error:nil];
}
@end
