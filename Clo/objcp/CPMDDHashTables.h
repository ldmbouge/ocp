/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

@interface ArcHashTable : NSObject {
    id __strong **_equivalenceArcs;
    char*** _propertiesLists;
    int* _numPerHash;
    int* _maxPerHash;
    int _width;
    NSUInteger _lastCheckedHash;
    int _numBytes;
    int _priority;
    id _spec;
    bool _approximate;
    bool _cachedOnArc;
    bool _singlePriority;
    
    char* _reverse;
    char* _forward;
    bool _isForward;
}
@property NSMutableArray* __strong **arcLists;
-(id) initArcHashTable:(int)width numBytes:(int)numBytes spec:(id)spec singlePriority:(bool)singlePriority cachedOnArc:(bool)cachedOnArc forward:(bool)isForward;
-(void) clear;
-(void) setPriority:(int)priority;
-(void) setApproximate:(bool)approximate;
-(bool) matches:(id)a withState:(char*)stateA to:(id)b withState:(char*)stateB;
-(bool) hasMatchingStateProperties:(char*)state forArc:(id)arc arcList:(NSMutableArray**)existingArcs;
-(int) calculateHashFor:(char*)state arc:(id)arc;
-(NSMutableArray*) addArc:(id)arc withState:(char*)state;
-(void) setForward:(char*)reverse;
-(void) setReverse:(char*)reverse;
@end
