/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
