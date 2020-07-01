/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngineI.h>
#import <objcp/CPMDDHashTables.h>

@implementation NodeTable
-(id) initNodeTable:(int)width numBytes:(int)numBytes {
    self = [super init];
    _width = width;
    _stateLists = malloc(_width * sizeof(MDDStateValues**));
    _numPerHash = calloc(_width, sizeof(int));
    _maxPerHash = calloc(_width, sizeof(int));
    _numBytes = numBytes;
    return self;
}
-(void) addArc:(MDDArc*)arc toState:(MDDStateValues*)state {
    @throw [[ORExecutionError alloc] initORExecutionError: "Method addArc not implemented for NodeTable."];
}
-(bool) hasMatchingStateProperties:(char*)state hashValue:(NSUInteger)hash node:(MDDNode**)existingNode {
    @throw [[ORExecutionError alloc] initORExecutionError: "Method hasMatchingStateProperties not implemented for NodeTable."];
}
@end

@implementation NodeHashTable
-(id) initNodeHashTable:(int)width numBytes:(int)numBytes {
    self = [super initNodeTable:width numBytes:numBytes];
    _statePropertiesLists = malloc(_width * sizeof(char**));
    return self;
}
-(bool) hasMatchingStateProperties:(char*)state hashValue:(NSUInteger)hash node:(MDDNode**)existingNode {
    _lastCheckedHash = hash;
    int numWithHash = _numPerHash[_lastCheckedHash];
    if (!numWithHash) return false;
    char** propertiesList = _statePropertiesLists[_lastCheckedHash];
    for (int i = 0; i < numWithHash; i++) {
        if (memcmp(state, propertiesList[i], _numBytes) == 0) {
            *existingNode = (MDDNode*)[_stateLists[_lastCheckedHash][i] node];
            return true;
        }
    }
    return false;
}
-(void) addArc:(MDDArc*)arc toState:(MDDStateValues*)state {
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
    for (int i = 0; i < _width; i++) {
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

@implementation NodeEquivalenceTable
-(id) initNodeEquivalenceTable:(int)width numBytes:(int)numBytes constraint:(int)constraint spec:(MDDStateSpecification*)spec {
    self = [super initNodeTable:width numBytes:numBytes];
    _constraint = constraint;
    _spec = spec;
    _arcsPerNewNode = malloc(_width * sizeof(NSMutableArray**));
    return self;
}
-(bool) hasMatchingStateProperties:(char*)state hashValue:(NSUInteger)hash node:(MDDNode**)existingNode {
    _lastCheckedHash = hash;
    int numWithHash = _numPerHash[_lastCheckedHash];
    if (!numWithHash) return false;
    MDDStateValues** stateList = _stateLists[_lastCheckedHash];
    for (int i = 0; i < numWithHash; i++) {
        if ([_spec state:state equivalentTo:[stateList[i] stateValues] forConstraint:_constraint]) {
            *existingNode = (MDDNode*)[_stateLists[_lastCheckedHash][i] node];
            return true;
        }
    }
    return false;
}
-(void) addArc:(MDDArc*)arc toState:(MDDStateValues*)state {
    int numStates = _numPerHash[_lastCheckedHash];
    if (numStates == 0) {
        _maxPerHash[_lastCheckedHash] = 2;
        _stateLists[_lastCheckedHash] = malloc(2 * sizeof(MDDStateValues*));
        _arcsPerNewNode[_lastCheckedHash] = malloc(2 * sizeof(NSMutableArray*));
    } else if (numStates == _maxPerHash[_lastCheckedHash]) {
        int newMax = _maxPerHash[_lastCheckedHash] * 2;
        _maxPerHash[_lastCheckedHash] = newMax;
        MDDStateValues** newList = malloc(newMax * sizeof(MDDStateValues*));
        NSMutableArray** newArcsPerNode = malloc(newMax * sizeof(NSMutableArray*));
        MDDStateValues** oldList = (MDDStateValues**)(_stateLists[_lastCheckedHash]);
        NSMutableArray** oldArcsPerNode = _arcsPerNewNode[_lastCheckedHash];
        for (int i = 0; i < numStates; i++) {
            newList[i] = oldList[i];
            newArcsPerNode[i] = oldArcsPerNode[i];
        }
        free(oldList);
        free(oldArcsPerNode);
        _stateLists[_lastCheckedHash] = (MDDStateValues* __strong *)newList;
        _arcsPerNewNode[_lastCheckedHash] = newArcsPerNode;
    }
    _stateLists[_lastCheckedHash][numStates] = state;
    _arcsPerNewNode[_lastCheckedHash][numStates] = [[NSMutableArray alloc] initWithObjects:arc, nil];
    _numPerHash[_lastCheckedHash] += 1;
    return;
}
-(void) addArc:(MDDArc*)arc forNode:(MDDNode*)node {
    int numWithHash = _numPerHash[_lastCheckedHash];
    MDDStateValues** stateList = _stateLists[_lastCheckedHash];
    for (int i = 0; i < numWithHash; i++) {
        if ([stateList[i] node] == node) {
            [_arcsPerNewNode[_lastCheckedHash][i] addObject:arc];
            return;
        }
    }
}
-(NSMutableArray*) arcsForNewState:(MDDStateValues*)state hashValue:(NSUInteger)hash {
    int numWithHash = _numPerHash[hash];
    MDDStateValues** stateList = _stateLists[hash];
    for (int i = 0; i < numWithHash; i++) {
        if (stateList[i] == state) {
            return _arcsPerNewNode[hash][i];
        }
    }
    return nil;
}
-(void) dealloc {
    for (int i = 0; i < _width; i++) {
        if (_maxPerHash[i] > 0) {
            free(_stateLists[i]);
            for (int j = 0; j < _numPerHash[i]; j++) {
                [_arcsPerNewNode[i][j] release];
            }
            free(_arcsPerNewNode[i]);
        }
    }
    free(_stateLists);
    free(_numPerHash);
    free(_maxPerHash);
    free(_arcsPerNewNode);
    [super dealloc];
}
@end

@implementation ArcHashTable
-(id) initArcHashTable:(int)width numBytes:(int)numBytes {
    self = [super init];
    _width = width;
    _arcLists = malloc(_width * sizeof(NSMutableArray**));
    _equivalenceArcs = malloc(_width * sizeof(MDDArc**));
    _numPerHash = calloc(_width, sizeof(int));
    _maxPerHash = calloc(_width, sizeof(int));
    _numBytes = numBytes;
    return self;
}
-(id) initArcHashTable:(int)width numBytes:(int)numBytes constraint:(int)constraint spec:(MDDStateSpecification *)spec {
    self = [self initArcHashTable:width numBytes:numBytes];
    _constraint = constraint;
    _spec = spec;
    return self;
}
-(void) setReverse:(char*)reverse { _reverse = reverse; }
-(void) setMatchingRule:(bool)matchByConstraint approximate:(bool)approximate {
    _matchByConstraint = matchByConstraint;
    _approximate = approximate;
}
-(bool) matches:(MDDArc*)a to:(MDDArc*)b {
    if (_approximate) {
        if (_matchByConstraint) {
            if ([_spec approximateEquivalenceUsedFor:_constraint]) {
                return [a equivalenceClassFor:_constraint] == [b equivalenceClassFor:_constraint];
            } else {
                @throw [[ORExecutionError alloc] initORExecutionError: "ArcHashTable: matches not implemented for apprximate equivalence by constraint with some specs not having their equivalence class defined."];
            }
        } else {
            for (int i = 0; i < [_spec numSpecs]; i++) {
                if ([_spec approximateEquivalenceUsedFor:i]) {
                    if ([a equivalenceClassFor:i] != [b equivalenceClassFor:i]) {
                        return false;
                    }
                } else {
                    @throw [[ORExecutionError alloc] initORExecutionError: "ArcHashTable: matches not implemented for apprximate equivalence by constraint with some specs not having their equivalence class defined."];
                }
            }
            return true;
        }
    } else {
        if (_matchByConstraint) {
            return [_spec state:[a forwardState] equivalentTo:[b forwardState] forConstraint:_constraint];
        } else {
            return memcmp([a forwardState], [b forwardState], _numBytes) == 0;
        }
    }
}
-(bool) hasMatchingStateProperties:(MDDArc*)arc hashValue:(NSUInteger)hash arcList:(NSMutableArray**)existingArcs {
    _lastCheckedHash = hash;
    int numWithHash = _numPerHash[_lastCheckedHash];
    if (!numWithHash) return false;
    MDDArc** propertiesList = _equivalenceArcs[_lastCheckedHash];
    for (int i = 0; i < numWithHash; i++) {
        if ([self matches:arc to:propertiesList[i]]) {
            *existingArcs = (NSMutableArray*)_arcLists[_lastCheckedHash][i];
            return true;
        }
    }
    return false;
}
-(NSMutableArray*) addArc:(MDDArc*)arc {
    int numStates = _numPerHash[_lastCheckedHash];
    if (numStates == 0) {
        _maxPerHash[_lastCheckedHash] = 2;
        _arcLists[_lastCheckedHash] = malloc(2 * sizeof(NSMutableArray*));
        _equivalenceArcs[_lastCheckedHash] = malloc(2 * sizeof(MDDArc*));
    } else if (numStates == _maxPerHash[_lastCheckedHash]) {
        int newMax = _maxPerHash[_lastCheckedHash] * 2;
        _maxPerHash[_lastCheckedHash] = newMax;
        NSMutableArray** newList = malloc(newMax * sizeof(NSMutableArray*));
        MDDArc** newProperties = malloc(newMax * sizeof(MDDArc*));
        NSMutableArray** oldList = (NSMutableArray**)(_arcLists[_lastCheckedHash]);
        MDDArc** oldProperties = _equivalenceArcs[_lastCheckedHash];
        for (int i = 0; i < numStates; i++) {
            newList[i] = oldList[i];
            newProperties[i] = oldProperties[i];
        }
        free(oldList);
        free(oldProperties);
        _arcLists[_lastCheckedHash] = (NSMutableArray**)newList;
        _equivalenceArcs[_lastCheckedHash] = newProperties;
    }
    NSMutableArray* newList = [[NSMutableArray alloc] initWithObjects:arc, nil];
    _arcLists[_lastCheckedHash][numStates] = newList;
    _equivalenceArcs[_lastCheckedHash][numStates] = arc;
    _numPerHash[_lastCheckedHash] += 1;
    return newList;
}
-(void) dealloc {
    for (int i = 0; i < _width; i++) {
        if (_maxPerHash[i] > 0) {
            for (int j = 0; j < _numPerHash[i]; j++) {
                [_arcLists[i][j] release];
            }
            free(_arcLists[i]);
            free(_equivalenceArcs[i]);
        }
    }
    free(_arcLists);
    free(_equivalenceArcs);
    free(_numPerHash);
    free(_maxPerHash);
    [super dealloc];
}
@end
