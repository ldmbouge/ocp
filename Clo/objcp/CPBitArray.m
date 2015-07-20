/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBitMacros.h"
#import "CPBitArray.h"

#define CP_SPACING 4
#define UMASK 0xFFFFFFFF
#define lmask 0x00000000

unsigned int getLengthInWords(CPBitArray* array) 
{
   return (unsigned int) 1 + (([array getLength] - 1) / BITSPERWORD);
} 

@implementation CPBitArray

-(id)initWithValue:(int) val
{
   self = [super init];
   if (self) {
      _length = BITSPERWORD;
      _signed = true;
      _overflow = false;
      _wLength = 1;
      _data.sValue = val;
   }
   
   return self;
}

-(id)initWithUnsignedValue:(unsigned int) val
{
   self = [super init];
   if (self) {
      _length = BITSPERWORD;
      _signed = false;
      _overflow = false;
      _wLength = 1;
      _data.usValue = val;
   }
   
   return self;
}

-(id)initWithArray: (int*) array andLength: (unsigned int) len
{
   self = [super init];
   if (self) {
      _length = len;
      _signed = true;
      _overflow = false;
      _wLength = 1;
      
      if(len <=BITSPERWORD)
         _data.sValue = *array;
      else{  
         _wLength = getLengthInWords(self);
         _data.ptr = (int*) malloc (_wLength* sizeof(int));
         
         for(int i=0;i<_wLength; i++)
            _data.ptr[i] = array[i];
      }
   }
   return self;
}

-(id)initWithUnsignedArray: (unsigned int*) array andLength: (unsigned int) len
{
   self = [super init];
   if (self) {
      _length = len;
      _signed = false;
      _overflow = false;
      _wLength = 1;
      
      if(len <=BITSPERWORD)
         _data.usValue = *array;
      else{  
         _wLength = getLengthInWords(self);
         _data.usPtr = (unsigned int*) malloc (_wLength* sizeof(unsigned int));
         
         for(int i=0;i<_wLength; i++)
            _data.usPtr[i] = array[i];
      }
   }
   return self;
}

- (CPBitArray*)initWithBitArray: (CPBitArray*) array 
{
   self = [super init];
   if (self) {
      _length = [array getLength];
      _signed = [array isSigned];
      _overflow = [array getOverflow];
      _wLength = getLengthInWords(self);
      if (_length <=BITSPERWORD) {
         if (_signed)
            _data.sValue = [array getData];
         else
            _data.usValue = [array getUSData];
      }
      else {
         if (_signed) {
            _data.ptr = (int*) malloc (_wLength * sizeof(int));
            int* bvPtr = [array getPtr];
            for (int i=0; i<_wLength; i++) 
               _data.ptr[i] = bvPtr[i];
         }
         else{
            _data.usPtr = (unsigned int*) malloc(_wLength * sizeof(unsigned int));
            unsigned int* bvUSPtr = [array getUSPtr];
            for (int i=0; i<_wLength; i++) 
               _data.usPtr[i] = bvUSPtr[i];
         }
      }
   }
   
   return self;
}


- (void)dealloc
{
   if (_length > BITSPERWORD) 
      free(_data.ptr);
   [super dealloc];
}

-(id) copyWithZone:(NSZone *)zone
{
   CPBitArray *newBitArray = [[CPBitArray allocWithZone:zone] initWithBitArray:self];
   return newBitArray;
}

-(CPBitArray*) bitwiseAND:(CPBitArray *)rhs
{
   
   //Must check that both BitArrays are the same length
   NSAssert((_length == [rhs getLength]), @"*ERROR* - Tried to bitwise AND two CPBitArrays of different lengths\n");
   int             i;
   unsigned int    ui;
   
   if (_length <=BITSPERWORD)
      if (_signed) {
         i = [rhs getData] & _data.sValue;
         return [[CPBitArray alloc] initWithValue:i];
      }
      else {
         ui = [rhs getUSData] & _data.usValue;
         return [[CPBitArray alloc] initWithUnsignedValue:ui];
      }
      else {
         if (_signed) {
            int newIntArray[getLengthInWords(self)];
            for (int i=0; i<_wLength; i++) 
               newIntArray[i] = _data.ptr[i] & [rhs getPtr][i];
            return [[CPBitArray alloc] initWithArray:newIntArray andLength: _length];
         }
         else{
            unsigned int newUIArray[getLengthInWords(self)];
            for (int i=0; i<_wLength; i++) 
               newUIArray[i] = _data.usPtr[i] & [rhs getUSPtr][i];
            return [[CPBitArray alloc] initWithUnsignedArray: newUIArray andLength: _length];
         }
      }
}

-(CPBitArray*) bitwiseOR:(CPBitArray *)rhs
{   
   //Must check that both BitArrays are the same length
   NSAssert((_length == [rhs getLength]), @"*ERROR* - Tried to bitwise OR two CPBitArrays of different lengths\n");
   int             i;
   unsigned int    ui;
   
   if (_length <=BITSPERWORD)
      if (_signed) {
         i = [rhs getData] | _data.sValue;
         return [[CPBitArray alloc] initWithValue:i];
      }
      else {
         ui = [rhs getUSData] | _data.usValue;
         return [[CPBitArray alloc] initWithUnsignedValue:ui];
      }
      else {
         if (_signed) {
            int newIntArray[getLengthInWords(self)];
            for (int i=0; i<_wLength; i++) 
               newIntArray[i] = _data.ptr[i] | [rhs getPtr][i];
            return [[CPBitArray alloc] initWithArray:newIntArray andLength: _length];
         }
         else{
            unsigned int newUIArray[getLengthInWords(self)];
            for (int i=0; i<_wLength; i++) 
               newUIArray[i] = _data.usPtr[i] | [rhs getUSPtr][i];
            return [[CPBitArray alloc] initWithUnsignedArray: newUIArray andLength: _length];
         }
      }
}

-(CPBitArray*) bitwiseXOR:(CPBitArray *)rhs
{  
   //Must check that both BitArrays are the same length
   NSAssert((_length == [rhs getLength]), @"*ERROR* - Tried to bitwise AND two CPBitArrays of different lengths\n");
   int             i;
   unsigned int    ui;
   
   if (_length <=BITSPERWORD)
      if (_signed) {
         i = [rhs getData] ^ _data.sValue;
         return [[CPBitArray alloc] initWithValue:i];
      }
      else {
         ui = [rhs getUSData] ^ _data.usValue;
         return [[CPBitArray alloc] initWithUnsignedValue:ui];
      }
      else {
         if (_signed) {
            int newIntArray[getLengthInWords(self)];
            for (int i=0; i<_wLength; i++) 
               newIntArray[i] = _data.ptr[i] ^ [rhs getPtr][i];
            return [[CPBitArray alloc] initWithArray:newIntArray andLength: _length];
         }
         else{
            unsigned int newUIArray[getLengthInWords(self)];
            for (int i=0; i<_wLength; i++) 
               newUIArray[i] = _data.usPtr[i] ^ [rhs getUSPtr][i];
            return [[CPBitArray alloc] initWithUnsignedArray: newUIArray andLength: _length];
         }
      }
}


-(CPBitArray*) bitwiseShiftR:(unsigned int) places
{
   int             i;
   unsigned int    ui;
   
   if (_length <=BITSPERWORD) {
      if (_signed) {
         i = _data.sValue >> places;
         return [[CPBitArray alloc] initWithValue:i];
      }
      else {
         ui = _data.usValue >> places;
         return [[CPBitArray alloc] initWithUnsignedValue:ui];
      }
   }
   //TODO: Add code to deal with bit vectors with length > BITSPERWORD
   return nil;
   
}

-(CPBitArray*) bitwiseShiftL:(unsigned int)places
{
   int             i;
   unsigned int    ui;
   
   if (_length <=BITSPERWORD)
      if (_signed) {
         i = _data.sValue << places;
         return [[CPBitArray alloc] initWithValue:i];
      }
      else {
         ui = _data.usValue << places;
         return [[CPBitArray alloc] initWithUnsignedValue:ui];
      }
      else{
         int mask = 0xFFFFFFFF;
         mask >>=BITSPERWORD-places;
         if (_signed) {
            int newBitArray[_wLength];
            for (unsigned int i=0; i<_wLength-1; i++) {
               newBitArray[i] = _data.ptr[i] << places;
               newBitArray[i+1] = _data.ptr[i+1];
               newBitArray[i+1] >>= BITSPERWORD-places;
               newBitArray[i+1] &= mask;
               newBitArray[i] |= newBitArray[i+1];
            }
            newBitArray[_wLength-1] = _data.ptr[_wLength-1];
            newBitArray[_wLength-1] <<= places;
            return [[CPBitArray alloc] initWithArray:newBitArray andLength: _length];
         }
         else{
            unsigned int newUSBitArray[_wLength];
            for (unsigned int i=0; i<_wLength-1; i++) {
               newUSBitArray[i] = _data.usPtr[i] << places;
               newUSBitArray[i+1] = _data.usPtr[i+1];
               newUSBitArray[i+1] >>= BITSPERWORD-places;
               newUSBitArray[i+1] &= mask;
               newUSBitArray[i] |= newUSBitArray[i+1];
            }
            newUSBitArray[_wLength-1] = _data.usPtr[_wLength-1];
            newUSBitArray[_wLength-1] <<= places;
            return [[CPBitArray alloc] initWithUnsignedArray: newUSBitArray andLength: _length];
            
         }
      }
}

-(CPBitArray*) bitwiseNOT
{
   int             i;
   unsigned int    ui;
   
   if (_length <=BITSPERWORD)
      if (_signed) {
         i = ~_data.sValue;
         return [[CPBitArray alloc] initWithValue:i];
      }
      else {
         ui = ~_data.usValue;
         return [[CPBitArray alloc] initWithUnsignedValue:ui ];
      }
      else {
         if (_signed) {
            int newIntArray[_wLength];
            for (int i=0; i<_wLength; i++) 
               newIntArray[i] = ~ _data.ptr[i];
            return [[CPBitArray alloc] initWithArray: newIntArray andLength:_length ];
         }
         else{
            unsigned int newUIArray[_wLength];
            for (int i=0; i<_wLength; i++) 
               newUIArray[i] = ~ _data.usPtr[i];
            return [[CPBitArray alloc] initWithUnsignedArray: newUIArray andLength:_length];
         }    
      }
}

-(void) flip:(unsigned int)idx
{
   
   if (_length <=BITSPERWORD) {
      _data.usValue ^= 1<<idx;
   }else{
      for (int i=0; i<_wLength; i++) 
         _data.ptr[idx/BITSPERWORD] ^= 1<<(idx % BITSPERWORD);
   }
}

-(void) set:(unsigned int)idx
{
   if (_length <=BITSPERWORD) {
      _data.usValue |= 1<<idx;
   }else{
      for (int i=0; i<_wLength; i++) 
         _data.ptr[idx/BITSPERWORD] |= 1<<(idx % BITSPERWORD);
   }    
}

-(void) clear:(unsigned int)idx
{
   if (_length <=BITSPERWORD) {
      _data.usValue &= ~(1 << idx);
   }else{
      for (int i=0; i<_wLength; i++) 
         _data.ptr[idx/BITSPERWORD] &= ~(1 << (idx % BITSPERWORD));
   }
}

-(void) flip
{
   if (_length <=BITSPERWORD) {
      _data.sValue ^= CP_UMASK;
   }else{
      if (_signed) {
         for (int i=0; i<_wLength; i++) 
            _data.ptr[i] ^= UMASK;
      }
      else{
         for (int i=0; i<_wLength; i++) 
            _data.usPtr[i] ^= UMASK;
      }
   }
}

-(void) set
{
   if (_length <=BITSPERWORD){
         _data.sValue = CP_UMASK;
   } else {
      if (_signed) {
         for (int i=0; i<_wLength; i++) 
            _data.ptr[i] = UMASK;
      }
      else{
         for (int i=0; i<_wLength; i++) 
            _data.usPtr[i] = UMASK;
      }
      
   }
}

-(void) clear
{
   if (_length <=BITSPERWORD){
      _data.sValue = 0;
   } else {
      if (_signed) {
         for (int i=0; i<_wLength; i++) 
            _data.ptr[i] = lmask;
      }
      else{
         for (int i=0; i<_wLength; i++) 
            _data.usPtr[i] = lmask;
      }
      
   }
}

-(int)             getData   { return _data.sValue;}
-(unsigned int)    getUSData { return _data.usValue;}
-(unsigned int)    getLength { return _length;}
-(unsigned int*)   getUSPtr  { return _data.usPtr;}
-(int*)            getPtr    { return _data.ptr;}
-(ORBool)            isSigned  { return _signed;}
-(ORBool)          getOverflow { return _overflow;}

-(NSString*) description
{
   //TODO: fix this to only print the number of bits in the vector!!
   NSString*       string;
   
   if(_length <= BITSPERWORD)
      if (_signed)
         string = [self intToBinString:_data.sValue];
      else
         string = [self usIntToBinString: _data.usValue];
      else{
         string = [NSString alloc];
         if (_signed){
            for (int i=0; i<_wLength; i++)
               string = [self intArrayToBinString: _data.ptr];
         }
         else{
            for (int i=0; i<_wLength; i++)
               string = [self usIntArrayToBinString: _data.usPtr];
         }
      }
   return string;
}
-(NSString*) intArrayToBinString: (int*) integer
{
   NSMutableString* string = [[NSMutableString alloc] init];
   
   for(int i = 0; i<_wLength;i++)
      [string appendString: [self intToBinString:_data.ptr[i]]];
   return string;
}  

-(NSString*) usIntArrayToBinString: (unsigned int*) integer
{
   NSMutableString* string = [[NSMutableString alloc] init];
   
   for(int i = 0; i<_wLength;i++)
      [string appendString: [self usIntToBinString:_data.usPtr[i]]];
   return string;
   
}
-(NSString*) intToBinString:(int) integer
{
   NSMutableString*       string = [[NSMutableString alloc] init];
   unsigned int    binaryDigit = 0;
   
   NSAssert(_signed, @"CPBitArray ERROR -- Trying to print unsigned integer as signed data");
   
   while( binaryDigit < BITSPERWORD )
   {
      binaryDigit++;
      [string insertString:( integer & 1) ? @"1" : @"0"  atIndex:0];
      
      if( binaryDigit % CP_SPACING == 0 && binaryDigit != BITSPERWORD )
         [string insertString:@" " atIndex:0];
      integer = integer >> 1;
   }
   return string;
}

-(NSString*) usIntToBinString:(unsigned int) integer
{
   NSMutableString*       string = [[NSMutableString alloc] init];
   unsigned int    binaryDigit = 0;
   
   NSAssert(!_signed, @"CPBitArray ERROR -- Trying to print signed integer as unsigned data");
   
   while( binaryDigit < BITSPERWORD )
   {
      binaryDigit++;
      [string insertString:( integer & 1) ? @"1" : @"0" atIndex:0];
      
      if( binaryDigit % CP_SPACING == 0 && binaryDigit != BITSPERWORD )
         [string insertString:@" " atIndex:0];
      integer = integer >> 1;
   }
   return string;
}
@end
