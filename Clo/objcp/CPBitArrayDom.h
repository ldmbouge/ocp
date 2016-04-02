/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPBitArrayDom.h>
#import <CPUKernel/CPEngine.h>
#import <CPUKernel/CPTypes.h>
#import <objcp/CPData.h>

@protocol CPBitVarNotifier;
@class CPBitArrayIterator;
@class CPLearningEngineI;

@interface CPBitArrayDom : NSObject {
@private
    id<ORTrail>     _trail;
    id<CPEngine>    _engine;
    TRUInt*         _low;
    TRUInt*         _up;
    unsigned int    _wordLength;
    unsigned int    _bitLength;
    TRUInt          _freebits;
    TRUInt*         _min;
    TRUInt*         _max;
    TRUInt*         _levels;  //tracks at what level in the search that a bit was set
   
    NSMutableArray*        _remValues;
}
-(CPBitArrayDom*)       initWithLength: (int) len withEngine:engine withTrail:(id<ORTrail>) tr;
-(CPBitArrayDom*)       initWithBitPat: (int) len withLow: (unsigned int*) low andUp:(unsigned int*) up withEngine:(id<CPEngine>)engine andTrail:(id<ORTrail>)tr;

-(void)                 setEngine:(id<CPEngine>)engine;
-(unsigned int)         getLength;
-(unsigned int)         getWordLength;
-(ORUInt)               getSize;
-(ORInt)                domsize;
-(ORULong)              numPatterns;
-(void)                 updateFreeBitCount;
-(ORBounds)             bounds;
-(ORBool)               bound;
-(ORULong)               min;
-(ORULong)               max;
-(unsigned int*)        minArray;
-(unsigned int*)        sminArray;
-(unsigned int*)        maxArray;
-(unsigned int*)        smaxArray;
-(unsigned int*)        lowArray;
-(unsigned int*)        upArray;
-(ORBool)               getBit:(unsigned int) idx;
-(ORStatus)             setBit:(unsigned int) idx to:(ORBool) val for:(id<CPBitVarNotifier>)x;
-(ORBool)               isFree:(unsigned int) idx;
-(unsigned int)         lsFreeBit;
-(unsigned int)         msFreeBit;
-(unsigned int)         midFreeBit;
-(unsigned int)         randomFreeBit;
-(ORBool)               member:(unsigned int*) val;
-(unsigned long long)   getRank:(unsigned int*) val;
-(unsigned int*)        atRank:(unsigned long long) rnk;
-(unsigned int)         getMaxRank;
-(ORStatus)             remove:(ORUInt)val;
-(unsigned int*)        pred:(unsigned int*) x;
-(ORStatus)             updateMin:(ORULong)newMin for: (id<CPBitVarNotifier>)x;
-(ORStatus)             updateMax:(ORULong)newMax for: (id<CPBitVarNotifier>)x;
-(ORStatus)             bind:(ORULong)val for:(id<CPBitVarNotifier>)x;
-(ORStatus)             bindToPat: (unsigned int*) pat for:(id<CPBitVarNotifier>)x;
-(TRUInt*)              getLow;
-(TRUInt*)              getUp;
-(void)                 getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow;
-(void)                 setLow: (unsigned int*) newLow for:(id<CPBitVarNotifier>)x;
-(void)                 setUp: (unsigned int*) newUp for:(id<CPBitVarNotifier>)x;
-(void)                 setUp: (unsigned int*) newUp andLow:(unsigned int*)newLow for:(id<CPBitVarNotifier>)x;
-(NSString*)            description;
-(void)                 enumerateWith:(void(^)(unsigned int*,ORInt))body;
-(void)                 restoreDomain:(CPBitArrayDom*)toRestore;
-(void)                 restoreValue:(ORInt)toRestore;
-(ORUInt)               getLevelForBit:(ORUInt)bit;

-(id) copyWithZone:(NSZone*) zone;
@end
