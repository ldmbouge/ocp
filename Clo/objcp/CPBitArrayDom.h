/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPTrail.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPTypes.h>
#import <objcp/CPData.h>


@protocol CPBitVarNotifier;
@class CPBitArrayIterator;

@interface CPBitArrayDom : NSObject {
@private
    CPTrail*        _trail;
    TRUInt*         _low;
    TRUInt*         _up;
    unsigned int    _wordLength;
    unsigned int    _bitLength;
    TRInt            _freebits;
    TRUInt*         _min;
    TRUInt*         _max;
}
-(CPBitArrayDom*)       initWithLength: (int) len withTrail:(CPTrail*) tr;
-(CPBitArrayDom*)       initWithBitPat: (int) len withLow: (unsigned int*) low andUp:(unsigned int*) up andTrail:(CPTrail*)tr;

-(unsigned int)         getLength;
-(unsigned int)         getWordLength;
-(CPUInt)           getSize;
-(int)                  domsize;
-(void)                 updateFreeBitCount;
-(bool)                 bound;
-(uint64)               min;
-(uint64)               max;
-(unsigned int*)        minArray;
-(unsigned int*)        maxArray;
-(bool)                 getBit:(unsigned int) idx;
-(CPStatus)             setBit:(unsigned int) idx to:(bool) val;
-(bool)                 isFree:(unsigned int) idx;
-(bool)                 member:(unsigned int*) val;
-(unsigned long long)   getRank:(unsigned int*) val;
-(unsigned int*)        atRank:(unsigned long long) rnk;
-(unsigned int)         getMaxRank;
-(unsigned int*)        pred:(unsigned int*) x;
-(CPStatus)             updateMin:(uint64)newMin for: (id<CPBitVarNotifier>)x;
-(CPStatus)             updateMax:(uint64)newMax for: (id<CPBitVarNotifier>)x;
-(CPStatus)             bind:(uint64)val for:(id<CPBitVarNotifier>)x;
-(CPStatus)             bindToPat: (unsigned int*) pat for:(id<CPBitVarNotifier>)x;
-(TRUInt*)              getLow;
-(TRUInt*)              getUp;
-(void)                 setLow: (unsigned int*) newLow for:(id<CPBitVarNotifier>)x;
-(void)                 setUp: (unsigned int*) newUp for:(id<CPBitVarNotifier>)x;
-(NSString*)            description;
-(void)                 enumerateWith:(void(^)(unsigned int*,CPInt))body;
@end
