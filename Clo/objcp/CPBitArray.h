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

@interface CPBitArray : NSObject<NSCopying> {
@private
    union raw_bits {
        unsigned int    usValue;
        int             sValue;
        int*            ptr;
        unsigned int*   usPtr;
    };
    
    union raw_bits      _data;
    unsigned int        _length;
    unsigned int        _wLength;
    bool                _signed;
    bool                _overflow;
}

-(CPBitArray*)      initWithValue: (int) val;
-(CPBitArray*)      initWithUnsignedValue: (unsigned int) val;
-(CPBitArray*)      initWithBitArray: (CPBitArray*) array;
-(CPBitArray*)      initWithArray: (int*) array andLength:(unsigned int) len;
-(CPBitArray*)      initWithUnsignedArray: (unsigned int*) array andLength:(unsigned int) len;

-(id)               copyWithZone:(NSZone *)zone; //Copy Constructor-ish

-(CPBitArray*)      bitwiseAND:(CPBitArray*) rhs;
-(CPBitArray*)      bitwiseOR:(CPBitArray*) rhs;
-(CPBitArray*)      bitwiseXOR:(CPBitArray*) rhs;
-(CPBitArray*)      bitwiseShiftR:(unsigned int) places;
-(CPBitArray*)      bitwiseShiftL:(unsigned int) places;
-(CPBitArray*)      bitwiseNOT;

-(void)    flip:(unsigned int) idx;
-(void)    set:(unsigned int) idx;
-(void)    clear:(unsigned int) idx;
-(void)    flip;
-(void)    set;
-(void)    clear;
//-(bool)    getBit:(unsigned int) idx;

-(int)             getData;
-(unsigned int)    getUSData;
-(int*)            getPtr;
-(unsigned int*)   getUSPtr;
-(unsigned int)    getLength;
-(bool)            isSigned;
-(bool)            getOverflow;

-(NSString*) description;
-(NSString*) intToBinString:(int) integer;
-(NSString*) usIntToBinString:(unsigned int) integer;
-(NSMutableString*) intArrayToBinString:(int*) integer;
-(NSMutableString*) usIntArrayToBinString:(unsigned int*) integer;

@end
