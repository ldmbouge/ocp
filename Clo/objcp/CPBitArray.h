/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORTypes.h>

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
//-(ORBool)    getBit:(unsigned int) idx;

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
