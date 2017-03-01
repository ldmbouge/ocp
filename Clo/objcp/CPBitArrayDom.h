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
#import <CPUKernel/CPLEngine.h>
#import <objcp/CPData.h>

@protocol CPBitVarNotifier;
@class CPBitArrayIterator;

@interface CPBitArrayDom : NSObject {
@private
    id<ORTrail>     _trail;
    id<CPLEngine>    _engine;
    TRUInt*         _low;
    TRUInt*         _up;
    ORUInt    _wordLength;
    ORUInt    _bitLength;
    TRUInt          _freebits;
    TRUInt*         _min;
    TRUInt*         _max;
    TRUInt*         _levels;  //tracks at what level in the search that a bit was set
   
    NSMutableArray*        _remValues;
}
-(CPBitArrayDom*)       initWithLength: (int) len withEngine:(id<CPEngine>)engine withTrail:(id<ORTrail>) tr;
-(CPBitArrayDom*)       initWithBitPat: (int) len withLow: (ORUInt*) low andUp:(ORUInt*) up andEngine:(id<CPEngine>)engine andTrail:(id<ORTrail>)tr;

-(void)                 setEngine:(id<CPEngine>)engine;
-(ORUInt)         getLength;
-(ORUInt)         getWordLength;
-(ORUInt)               getSize;
-(ORInt)                domsize;
-(ORULong)              numPatterns;
-(void)                 updateFreeBitCount;
-(ORBounds)             bounds;
-(ORBool)               bound;
-(ORULong)               min;
-(ORULong)               max;
-(ORUInt*)        minArray;
-(ORUInt*)        sminArray;
-(ORUInt*)        maxArray;
-(ORUInt*)        smaxArray;
-(ORUInt*)        lowArray;
-(ORUInt*)        upArray;
-(ORBool)               getBit:(ORUInt) idx;
-(ORStatus)             setBit:(ORUInt) idx to:(ORBool) val for:(id<CPBitVarNotifier>)x;
-(ORBool)               isFree:(ORUInt) idx;
-(ORUInt)         lsFreeBit;
-(ORUInt)         msFreeBit;
-(ORUInt)         midFreeBit;
-(ORUInt)         randomFreeBit;
-(ORBool)               member:(ORUInt*) val;
-(ORULong)   getRank:(ORUInt*) val;
-(ORUInt*)        atRank:(ORULong) rnk;
-(ORUInt)         getMaxRank;
-(ORStatus)             remove:(ORUInt*)val;
-(ORUInt*)        pred:(ORUInt*) x;
-(ORStatus)             updateMin:(ORULong)newMin for: (id<CPBitVarNotifier>)x;
-(ORStatus)             updateMax:(ORULong)newMax for: (id<CPBitVarNotifier>)x;
-(ORStatus)             bind:(ORULong)val for:(id<CPBitVarNotifier>)x;
-(ORStatus)             bindToPat:(ORUInt*) pat for:(id<CPBitVarNotifier>)x;
-(TRUInt*)              getLow;
-(TRUInt*)              getUp;
-(void)                 getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow;
-(void)                 setLow: (ORUInt*) newLow for:(id<CPBitVarNotifier>)x;
-(void)                 setUp: (ORUInt*) newUp for:(id<CPBitVarNotifier>)x;
-(void)                 setUp: (ORUInt*) newUp andLow:(ORUInt*)newLow for:(id<CPBitVarNotifier>)x;
-(NSString*)            description;
-(void)                 enumerateWith:(void(^)(ORUInt*,ORInt))body;
-(void)                 restoreDomain:(CPBitArrayDom*)toRestore;
-(void)                 restoreValue:(ORInt)toRestore;
-(ORUInt)               getLevelForBit:(ORUInt)bit;

-(id) copyWithZone:(NSZone*) zone;
@end
