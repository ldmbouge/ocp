/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/CPMDDHashTables.h>

@implementation ArcHashTable
-(id) initArcHashTable:(int)width numBytes:(int)numBytes spec:(MDDStateSpecification *)spec singlePriority:(bool)singlePriority cachedOnArc:(bool)cachedOnArc forward:(bool)isForward {
    self = [super init];
    _width = width;
    _arcLists = malloc(_width * sizeof(NSMutableArray**));
    _equivalenceArcs = malloc(_width * sizeof(MDDArc**));
    _propertiesLists = malloc(_width * sizeof(char**));
    _numPerHash = calloc(_width, sizeof(int));
    _maxPerHash = calloc(_width, sizeof(int));
    _numBytes = numBytes;
    _spec = spec;
    _singlePriority = singlePriority;
    _cachedOnArc = cachedOnArc;
    _isForward = isForward;
    return self;
}
-(void) clear {
    for (int i = 0; i < _width; i++) {
        if (_numPerHash[i]) {
            for (int j = 0; j < _numPerHash[i]; j++) {
                [_arcLists[i][j] release];
                if (!_cachedOnArc) {
                    free(_propertiesLists[i][j]);
                }
            }
        }
        _numPerHash[i] = 0;
    }
}
-(void) setPriority:(int)priority {
    _priority = priority;
}
-(void) setApproximate:(bool)approximate {
    _approximate = approximate;
}
-(void) setReverse:(char*)reverse {
    _reverse = reverse;
}
-(void) setForward:(char*)forward {
    _forward = forward;
}
-(bool) matches:(MDDArc *)a withState:(char *)stateA to:(MDDArc *)b withState:(char *)stateB {
    if (_isForward) {
        if (_cachedOnArc) {
            return [_spec checkForwardEquivalence:a withForward:[a forwardState] reverse:_reverse to:b withForward:[b forwardState] reverse:_reverse approximate:_approximate priority:_priority];
        } else {
            return [_spec checkForwardEquivalence:a withForward:stateA reverse:_reverse to:b withForward:stateB reverse:_reverse approximate:_approximate priority:_priority];
        }
    } else {
        if (_cachedOnArc) {
            return false;
            //return [_spec checkReverseEquivalence:a withForward:_forward reverse:[a reverseState] to:b withForward:_forward reverse:[b reverseState] approximate:_approximate priority:_priority];
        } else {
            return [_spec checkReverseEquivalence:a withForward:_forward reverse:stateA to:b withForward:_forward reverse:stateB approximate:_approximate priority:_priority];
        }
    }
}
-(bool) hasMatchingStateProperties:(char*)state forArc:(MDDArc*)arc arcList:(NSMutableArray**)existingArcs {
    int hash = [self calculateHashFor:state arc:arc];
    
    if (hash > _width-2) {
        hash %= (_width-1);
    } else if (hash < 0) {
        hash += (_width-1);
    }
    _lastCheckedHash = hash;
    int numWithHash = _numPerHash[_lastCheckedHash];
    if (!numWithHash) return false;
    MDDArc** equivalenceArcs = _equivalenceArcs[_lastCheckedHash];
    char** propertiesList = _propertiesLists[_lastCheckedHash];
    for (int i = 0; i < numWithHash; i++) {
        if ([self matches:arc withState:state to:equivalenceArcs[i] withState:propertiesList[i]]) {
            *existingArcs = (NSMutableArray*)_arcLists[_lastCheckedHash][i];
            return true;
        }
    }
    return false;
}
-(int) calculateHashFor:(char*)state arc:(MDDArc*)arc {
    if (_cachedOnArc) {
        if (_approximate) {
            if (_singlePriority) {
                return [arc combinedEquivalenceClasses];
            } else {
                return 0;//[arc equivalenceClassFor:_priority];
            }
        } else {
            return [arc hashValue];
        }
    } else {
        if (_approximate) {
            return [_spec combinedEquivalenceClassFor:(_isForward ? state : _forward) reverse:(_isForward ? _reverse : state) priority:_priority];
        } else {
            if (_singlePriority) {
                return [_spec hashValueForState:state];
            } else {
                return [_spec hashValueForState:state priority:_priority];
            }
        }
    }
}
-(NSMutableArray*) addArc:(MDDArc*)arc withState:(char*)state {
    int numStates = _numPerHash[_lastCheckedHash];
    if (_maxPerHash[_lastCheckedHash] == 0) {
        _maxPerHash[_lastCheckedHash] = 2;
        _arcLists[_lastCheckedHash] = malloc(2 * sizeof(NSMutableArray*));
        _equivalenceArcs[_lastCheckedHash] = malloc(2 * sizeof(MDDArc*));
        _propertiesLists[_lastCheckedHash] = malloc(2 * sizeof(char*));
    } else if (numStates == _maxPerHash[_lastCheckedHash]) {
        int newMax = _maxPerHash[_lastCheckedHash] * 2;
        _maxPerHash[_lastCheckedHash] = newMax;
        NSMutableArray** newList = malloc(newMax * sizeof(NSMutableArray*));
        MDDArc** newArcs = malloc(newMax * sizeof(MDDArc*));
        char** newProperties = malloc(newMax * sizeof(char*));
        NSMutableArray** oldList = (NSMutableArray**)(_arcLists[_lastCheckedHash]);
        MDDArc** oldArcs = _equivalenceArcs[_lastCheckedHash];
        char** oldProperties = _propertiesLists[_lastCheckedHash];
        for (int i = 0; i < numStates; i++) {
            newList[i] = oldList[i];
            newArcs[i] = oldArcs[i];
            newProperties[i] = oldProperties[i];
        }
        free(oldList);
        free(oldArcs);
        free(oldProperties);
        _arcLists[_lastCheckedHash] = (NSMutableArray**)newList;
        _equivalenceArcs[_lastCheckedHash] = newArcs;
        _propertiesLists[_lastCheckedHash] = newProperties;
    }
    NSMutableArray* newList = [[NSMutableArray alloc] initWithObjects:arc, nil];
    _arcLists[_lastCheckedHash][numStates] = newList;
    _equivalenceArcs[_lastCheckedHash][numStates] = arc;
    _propertiesLists[_lastCheckedHash][numStates] = state;
    _numPerHash[_lastCheckedHash] += 1;
    return newList;
}
-(void) dealloc {
    for (int i = 0; i < _width; i++) {
        if (_maxPerHash[i] > 0) {
            for (int j = 0; j < _numPerHash[i]; j++) {
                [_arcLists[i][j] release];
                if (!_cachedOnArc) {
                    free(_propertiesLists[i][j]);
                }
            }
            free(_arcLists[i]);
            free(_equivalenceArcs[i]);
            free(_propertiesLists[i]);
        }
    }
    free(_arcLists);
    free(_equivalenceArcs);
    free(_numPerHash);
    free(_maxPerHash);
    free(_propertiesLists);
    [super dealloc];
}
@end
