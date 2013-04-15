/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPBitArrayDom.h>
#import <CPUKernel/CPTypes.h>
#import <objcp/CPData.h>


@protocol CPBitVarNotifier;
@class CPBitArrayIterator;

@interface CPBitArrayDom : NSObject {
@private
    id<ORTrail>        _trail;
    TRUInt*         _low;
    TRUInt*         _up;
    unsigned int    _wordLength;
    unsigned int    _bitLength;
    TRUInt            _freebits;
    TRUInt*         _min;
    TRUInt*         _max;
}
-(CPBitArrayDom*)       initWithLength: (int) len withTrail:(id<ORTrail>) tr;
-(CPBitArrayDom*)       initWithBitPat: (int) len withLow: (unsigned int*) low andUp:(unsigned int*) up andTrail:(id<ORTrail>)tr;

-(unsigned int)         getLength;
-(unsigned int)         getWordLength;
-(ORUInt)               getSize;
-(ORULong)              domsize;
-(void)                 updateFreeBitCount;
-(ORBool)                 bound;
-(uint64)               min;
-(uint64)               max;
-(unsigned int*)        minArray;
-(unsigned int*)        maxArray;
-(unsigned int*)        lowArray;
-(unsigned int*)        upArray;
-(ORBool)                 getBit:(unsigned int) idx;
-(ORStatus)             setBit:(unsigned int) idx to:(ORBool) val for:(id<CPBitVarNotifier>)x;
-(ORBool)                 isFree:(unsigned int) idx;
-(unsigned int)         lsFreeBit;
-(unsigned int)         randomFreeBit;
-(ORBool)                 member:(unsigned int*) val;
-(unsigned long long)   getRank:(unsigned int*) val;
-(unsigned int*)        atRank:(unsigned long long) rnk;
-(unsigned int)         getMaxRank;
-(unsigned int*)        pred:(unsigned int*) x;
-(ORStatus)             updateMin:(uint64)newMin for: (id<CPBitVarNotifier>)x;
-(ORStatus)             updateMax:(uint64)newMax for: (id<CPBitVarNotifier>)x;
-(ORStatus)             bind:(uint64)val for:(id<CPBitVarNotifier>)x;
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

@end
