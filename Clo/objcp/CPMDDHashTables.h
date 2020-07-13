/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPMDDNode.h>

@interface NodeTable : NSObject {
    int* _numPerHash;
    int* _maxPerHash;
    int _width;
    NSUInteger _lastCheckedHash;
    int _numBytes;
    MDDStateValues* __strong **_stateLists;
}
-(id) initNodeTable:(int)width numBytes:(int)numBytes;
-(bool) hasMatchingStateProperties:(char*)state hashValue:(NSUInteger)hash node:(MDDNode**)existingNode;
-(void) addArc:(MDDArc*)arc toState:(MDDStateValues*)state;
@end

@interface NodeHashTable : NodeTable {
    char** *_statePropertiesLists;
}
-(id) initNodeHashTable:(int)width numBytes:(int)numBytes;
@end

@interface NodeEquivalenceTable : NodeTable {
    int _constraint;
    MDDStateSpecification* _spec;
    NSMutableArray* __strong **_arcsPerNewNode;
}
-(id) initNodeEquivalenceTable:(int)width numBytes:(int)numBytes constraint:(int)constraint spec:(MDDStateSpecification*)spec;
-(void) addArc:(MDDArc*)arc forNode:(MDDNode*)node;
-(NSMutableArray*) arcsForNewState:(MDDStateValues*)state hashValue:(NSUInteger)hash;
@end

@interface ArcHashTable : NSObject {
    MDDArc* __strong **_equivalenceArcs;
    char*** _propertiesLists;
    int* _numPerHash;
    int* _maxPerHash;
    int _width;
    NSUInteger _lastCheckedHash;
    int _numBytes;
    int _constraint;
    MDDStateSpecification* _spec;
    bool _matchByConstraint;
    bool _approximate;
    char* _reverse;
    bool _cachedOnArc;
}
@property NSMutableArray* __strong **arcLists;
-(id) initArcHashTable:(int)width numBytes:(int)numBytes;
-(id) initArcHashTable:(int)width numBytes:(int)numBytes constraint:(int)constraint spec:(MDDStateSpecification*)spec;
-(void) setReverse:(char*)reverse;
-(void) setMatchingRule:(bool)matchByConstraint approximate:(bool)approximate cachedOnArc:(bool)cachedOnArc;
-(bool) matches:(MDDArc*)a withState:(char*)stateA to:(MDDArc*)b withState:(char*)stateB;
-(bool) hasMatchingStateProperties:(char*)state forArc:(MDDArc*)arc hashValue:(NSUInteger)hash arcList:(NSMutableArray**)existingArcs;
-(NSMutableArray*) addArc:(MDDArc*)arc withState:(char*)state;
@end
