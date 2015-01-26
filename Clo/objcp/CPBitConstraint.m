/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBitConstraint.h"
#import "CPUKernel/CPEngineI.h"
#import "CPBitMacros.h"

#define ISTRUE(up, low) ((up) & (low))
#define ISFALSE(up, low) ((~up) & (~low))

NSString* bitvar2NSString(unsigned int* low, unsigned int* up, int wordLength)
{
   NSMutableString* string = [[NSMutableString alloc] init];
   for(int i=wordLength-1; i>=0;i--){
      unsigned int boundLow = ~low[i] & ~ up[i];
      unsigned int boundUp = up[i] & low[i];
      unsigned int err = ~up[i] & low[i];
      unsigned int mask = CP_DESC_MASK;
      for (int j=0; j<32; j++){
         if ((mask & boundLow) != 0)
            [string appendString: @"0"];
         else if ((mask & boundUp) != 0)
            [string appendString: @"1"];
         else if ((mask & err) != 0)
            [string appendString: @"X"];
         else
            [string appendString: @"?"];
         mask >>= 1;
      }
   }
   return string;
}

ORUInt numSetBits(TRUInt* low, TRUInt* up, int wordLength)
{
   ORUInt setBits = 0;
   for(int i=0; i< wordLength;i++){
      unsigned int boundLow = ~low[i]._val & ~ up[i]._val;
      unsigned int boundUp = up[i]._val & low[i]._val;
      setBits += __builtin_popcount(boundLow || boundUp);
   }
   return setBits;
}

ORUInt numSetBitsORUInt(ORUInt* low, ORUInt* up, int wordLength)
{
   ORUInt setBits = 0;
   for(int i=0; i< wordLength;i++){
      unsigned int boundLow = ~low[i] & ~ up[i];
      unsigned int boundUp = up[i] & low[i];
      setBits += __builtin_popcount(boundLow || boundUp);
   }
   return setBits;
}

//ORStatus checkBVSAC(id<CPBitVar> x, CPEngineI* engine, id<CPCommonProgram> cp)
//{
//   for (int i=0; i<[x bitLength]; i++) {
//      <#statements#>
//   }
//   return ORSuccess;
//}

@implementation CPFactory (BitConstraint)
//Bit Vector Constraints
+(id<CPConstraint>) bitEqual:(CPBitVarI*)x to:(CPBitVarI*)y
{
    id<CPConstraint> o = [[CPBitEqual alloc] initCPBitEqual:x and:y];
    [[x engine] trackMutable:o];
    return o;
}

+(id<CPConstraint>) bitAND:(CPBitVarI*)x and:(CPBitVarI*)y equals:(CPBitVarI*)z
{
    id<CPConstraint> o = [[CPBitAND alloc] initCPBitAND:x and:y equals:z];
    [[x engine] trackMutable:o];
    return o;
}

+(id<CPConstraint>) bitOR:(CPBitVarI*)x or:(CPBitVarI*) y equals:(CPBitVarI*)z
{
    id<CPConstraint> o = [[CPBitOR alloc] initCPBitOR:x or:y equals:z];
    [[x engine] trackMutable:o];
    return o;
}
+(id<CPConstraint>) bitXOR:(CPBitVarI*)x xor:(CPBitVarI*)y equals:(CPBitVarI*) z
{
    id<CPConstraint> o = [[CPBitXOR alloc] initCPBitXOR:x xor:y equals:z];
    [[x engine] trackMutable:o];
    return o;
    
}
+(id<CPConstraint>) bitNOT:(CPBitVarI*)x equals:(CPBitVarI*) y
{
    id<CPConstraint> o = [[CPBitNOT alloc] initCPBitNOT:x equals:y];
    [[x engine] trackMutable:o];
    return o;
    
}

+(id<CPConstraint>) bitShiftL:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
    id<CPConstraint> o = [[CPBitShiftL alloc] initCPBitShiftL:x shiftLBy:p equals:y];
    [[x engine] trackMutable:o];
    return o;    
}

+(id<CPConstraint>) bitShiftR:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPConstraint> o = [[CPBitShiftR alloc] initCPBitShiftR:x shiftRBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPConstraint>) bitRotateL:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPConstraint> o = [[CPBitRotateL alloc] initCPBitRotateL:x rotateLBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
   
}

+(id<CPConstraint>) bitADD:(id<CPBitVar>)x plus:(id<CPBitVar>) y withCarryIn:(id<CPBitVar>) cin equals:(id<CPBitVar>) z withCarryOut:(id<CPBitVar>) cout
{
   id<CPConstraint> o = [[CPBitADD alloc] initCPBitAdd:(CPBitVarI*)x
                                                  plus:(CPBitVarI*)y
                                                equals:(CPBitVarI*)z
                                           withCarryIn:(CPBitVarI*)cin
                                           andCarryOut:(CPBitVarI*)cout];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPConstraint>) bitIF:(id<CPBitVar>)w equalsOneIf:(id<CPBitVar>)x equals:(id<CPBitVar>)y andZeroIfXEquals:(id<CPBitVar>) z
{
   id<CPConstraint> o = [[CPBitIF alloc] initCPBitIF:(CPBitVarI*)w
                                         equalsOneIf:(CPBitVarI*)x
                                              equals:(CPBitVarI*)y
                                    andZeroIfXEquals:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitCount:(id<CPBitVar>)x count:(id<CPIntVar>)p
{
   id<CPConstraint> o = [[CPBitCount alloc] initCPBitCount:(CPBitVarI*)x count:(CPIntVarI*)p];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitZeroExtend:(id<CPBitVar>)x extendTo:(id<CPBitVar>)y
{
   id<CPConstraint> o = [[CPBitZeroExtend alloc] initCPBitZeroExtend:(CPBitVarI*)x extendTo:(CPBitVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitConcat:(id<CPBitVar>)x concat:(id<CPBitVar>)y eq:(id<CPBitVar>)z
{
   id<CPConstraint> o = [[CPBitConcat alloc] initCPBitConcat:(CPBitVarI*)x concat:(CPBitVarI*)y eq:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitExtract:(id<CPBitVar>)x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<CPBitVar>)y
{
   id<CPConstraint> o = [[CPBitExtract alloc] initCPBitExtract:(CPBitVarI*)x from:lsb to:msb eq:(CPBitVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitLogicalEqual:(id<CPBitVar>)x EQ:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPConstraint> o = [[CPBitLogicalEqual alloc] initCPBitLogicalEqual:(CPBitVarI*)x EQ:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
   
}
+(id<CPConstraint>) bitLT:(id<CPBitVar>)x LT:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPConstraint> o = [[CPBitLT alloc] initCPBitLT:(CPBitVarI*)x LT:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
   
}
+(id<CPConstraint>) bitLE:(id<CPBitVar>)x LE:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPConstraint> o = [[CPBitLE alloc] initCPBitLE:(CPBitVarI*)x LE:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitITE:(id<CPBitVar>)i then:(id<CPBitVar>)t else:(id<CPBitVar>)e result:(id<CPBitVar>)r
{
   id<CPConstraint> o = [[CPBitITE alloc] initCPBitITE:(CPBitVarI*)i then:(CPBitVarI*)t else:(CPBitVarI*)e result:(CPBitVarI*)r];
   [[i engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitLogicalAnd:(id<CPBitVarArray>)x eval:(CPBitVarI*)r
{
   id<CPConstraint> o = [[CPBitLogicalAnd alloc] initCPBitLogicalAnd:x eval:r];
   [[x[0] engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitLogicalOr:(id<CPBitVarArray>)x eval:(CPBitVarI*)r
{
   id<CPConstraint> o = [[CPBitLogicalOr alloc] initCPBitLogicalOr:x eval:r];
   [[x[0] engine] trackMutable:o];
   return o;
}
@end

@implementation CPBitEqual

-(id) initCPBitEqual:(CPBitVarI*) x and:(CPBitVarI*) y
{
    self = [super initCPCoreConstraint: [x engine]];
    _x = x;
    _y = y;
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
//<<<<<<< HEAD
//
////   [self propagate];
//   return ORSuspend;
//=======
//   }
   [self propagate];
//>>>>>>> master
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Equal Constraint propagated.");
#endif
   
    unsigned int wordLength = [_x getWordLength];
    
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
    unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
    unsigned int  upXORlow;
        
    for(int i=0;i<wordLength;i++){
        up[i] = xUp[i]._val & yUp[i]._val;
        low[i] = xLow[i]._val | yLow[i]._val;
        upXORlow = up[i] ^ low[i];
        if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
            failNow();
        }
    }
   
   id<CPEngine> engine = [_x engine];
//   id<CPCommonProgram> cp = [engine ];

   int idx = 0;
   ORUInt freebits;
   for (int i=0; i<wordLength; i++) {
      if ((freebits = up[i] & ~low[i])) {
         for (int j=0; j<BITSPERWORD; j++) {
            
         }
      }
   }
   
   [_x setUp:up andLow:low];
   [_y setUp:up andLow:low];
   
//    [_x setLow: low];
//    [_y setLow: low];
//    [_x setUp: up];
//    [_y setUp: up];
}
@end

@implementation CPBitNOT

-(id) initCPBitNOT: (CPBitVarI*) x equals:(CPBitVarI*) y
{
    self = [super initCPCoreConstraint:[x engine]];
    _x = x;
    _y = y;
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
    [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];

//<<<<<<< HEAD
////   [self propagate];
//   return ORSuspend;
//=======
//        [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
//        [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
//    }
   [self propagate];
//>>>>>>> master
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit NOT Constraint propagated.");
#endif
   
    unsigned int wordLength = [_x getWordLength];
    
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];

    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow = alloca(sizeof(unsigned int)*wordLength);
    unsigned int  upXORlow;

    bool    inconsistencyFound = false;
#ifdef BIT_DEBUG
   NSLog(@"     ~(X =%@)",_x);
   NSLog(@"  =    Y =%@",_y);
#endif

    for(int i=0;i<wordLength;i++){
        //x_k=0 => y_k=1
        newYLow[i] = ~xUp[i]._val | yLow[i]._val;
        
        //x_k=1 => y_k=0
        newYUp[i] = ~xLow[i]._val & yUp[i]._val;
        
        //y_k=0 => x_k=1
        newXLow[i] = ~yUp[i]._val | xLow[i]._val;
        
        //y_k=1 => x_k=0
        newXUp[i] = ~yLow[i]._val & xUp[i]._val;
       
       if(i==wordLength-1){
          uint32 bitmask = CP_UMASK >> (32 - ([_x bitLength] % 32));
          newXUp[i] &= bitmask;
          newXLow[i] &= bitmask;
          newYUp[i] &= bitmask;
          newYLow[i] &= bitmask;
       }
        
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= ((upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]));

        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
       
        if (inconsistencyFound)
            failNow();

    }
    
   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];
   
//    [_x setLow: newXLow];
//    [_y setLow: newYLow];
//    [_x setUp: newXUp];
//    [_y setUp: newYUp];
#ifdef BIT_DEBUG
   NSLog(@"     ~(X =%@)",_x);
   NSLog(@"  =    Y =%@",_y);
   NSLog(@"**********************************");
#endif
}
@end

@implementation CPBitAND
-(id) initCPBitAND:(CPBitVarI*)x and:(CPBitVarI*)y equals:(CPBitVarI*)z{
    self = [super initCPCoreConstraint:[x engine]];
    _x = x;
    _y = y;
    _z = z;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];

//<<<<<<< HEAD
////   [self propagate];
//   return ORSuspend;
//=======
////      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
////      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
////      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
//   }
   [self propagate];
//>>>>>>> master
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit AND Constraint propagated.");
#endif
   
    unsigned int wordLength = [_x getWordLength];
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];

    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int upXORlow;

    bool    inconsistencyFound = false;
#ifdef BIT_DEBUG
   NSLog(@"       X =%@",_x);
   NSLog(@"  AND  Y =%@",_y);
   NSLog(@"   =   Z =%@",_z);
#endif
    
    for(int i=0;i<wordLength;i++){
        
        // x_k=1 & y_k=1 => z_k=1
        newZLow[i] = (xLow[i]._val & yLow[i]._val) | zLow[i]._val;
        
        //z_k=1 => x_k=1
        //z_k=1 => y_k=1
        newXLow[i] = xLow[i]._val | zLow[i]._val;
        newYLow[i] = yLow[i]._val | zLow[i]._val;
        
        //z_k=0 & y_k=1 =>x_k=0
        newXUp[i] = (~(~zUp[i]._val & yLow[i]._val)) & xUp[i]._val;

        //z_k=0 & x_k=1 =>y_k=0
        newYUp[i] = (~(~zUp[i]._val & xLow[i]._val)) & yUp[i]._val;
        
        //x_k=0 | y_k=0 =>z_k=0
        newZUp[i] = (xUp[i]._val & yUp[i]._val) & zUp[i]._val; 
        
//        up[i] = ~((~xUp[i]) & (~yUp[i])) | (~zUp[i]);
//        low[i] = (xLow[i] & yLow[i]) | zLow[i];
//        newZUp[i] = low[i] | zLow[i];
//        newZLow[i] = ~((~up[i]) | (~zLow[i]));
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        upXORlow = newZUp[i] ^ newZLow[i];
        inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
        if (inconsistencyFound)
            failNow();
    }

   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];
   [_z setUp:newZUp andLow:newZLow];
   
//    [_x setLow:newXLow];
//    [_x setUp:newXUp];
//    [_y setLow:newYLow];
//    [_y setUp:newYUp];
//    [_z setLow:newZLow];
//    [_z setUp:newZUp];
#ifdef BIT_DEBUG
   NSLog(@"       X =%@",_x);
   NSLog(@"  AND  Y =%@",_y);
   NSLog(@"   =   Z =%@",_z);
   NSLog(@"**********************************");
#endif
}
@end

@implementation CPBitOR
-(id) initCPBitOR:(CPBitVarI*)x or:(CPBitVarI*)y equals:(CPBitVarI*)z{
    self = [super initCPCoreConstraint:[x engine]];
    _x = x;
    _y = y;
    _z = z;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];

//<<<<<<< HEAD
////   [self propagate];
//   return ORSuspend;
//=======
////      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
//   }
   [self propagate];
//>>>>>>> master
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit OR Constraint propagated.");
#endif
    unsigned int wordLength = [_x getWordLength];
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];

    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;

#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"  OR  Y =%@",_y);
   NSLog(@"   =  Z =%@",_z);
#endif
    for(int i=0;i<wordLength;i++){
        
        // x_k=1 | y_k=1 => z_k=1
        newZLow[i] = xLow[i]._val | yLow[i]._val | zLow[i]._val;
        
        //z_k=0 => x_k=0
        //z_k=0 => y_k=0
        newXUp[i] = zUp[i]._val & xUp[i]._val;
        newYUp[i] = zUp[i]._val & yUp[i]._val;
        
        //z_k=1 & y_k=0 =>x_k=1
        newXLow[i] =  (~yUp[i]._val & zLow[i]._val) | xLow[i]._val;
        
        //z_k=1 & x_k=0 =>y_k=1
        newYLow[i] =  (~xUp[i]._val & zLow[i]._val) | yLow[i]._val;
        
        //x_k=0 & y_k=0 =>z_k=0
        newZUp[i] = (xUp[i]._val | yUp[i]._val) & zUp[i]._val; 
        
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        upXORlow = newZUp[i] ^ newZLow[i];
        inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
        if (inconsistencyFound)
           failNow();
    }

   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];
   [_z setUp:newZUp andLow:newZLow];

//    [_x setLow:newXLow];
//    [_x setUp:newXUp];
//    [_y setLow:newYLow];
//    [_y setUp:newYUp];
//    [_z setLow:newZLow];
//    [_z setUp:newZUp];
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"  OR  Y =%@",_y);
   NSLog(@"   =  Z =%@",_z);
   NSLog(@"**********************************");
#endif
}
@end

@implementation CPBitXOR
-(id) initCPBitXOR:(CPBitVarI*)x xor:(CPBitVarI*)y equals:(CPBitVarI*)z{
    self = [super initCPCoreConstraint:[x engine]];
    _x = x;
    _y = y;
    _z = z;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];

//<<<<<<< HEAD
////   [self propagate];
//   return ORSuspend;
//=======
////      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
//   }
   [self propagate];
//>>>>>>> master
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit XOR Constraint propagated.");
#endif

    unsigned int wordLength = [_x getWordLength];
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];

    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;
   
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@" XOR  Y =%@",_y);
   NSLog(@"   =  Z=%@\n\n",_z);
#endif
    
    for(int i=0;i<wordLength;i++){

        
        // x_k=0 & y_k=0 => z_k=0
        // x_k=1 & y_k=1 => z_k=0
//        newZUp[i] = ~((~xUp[i]._val & ~yUp[i]._val) | (xLow[i]._val & yLow[i]._val) | ~zUp[i]._val);
        newZUp[i] = (xUp[i]._val | yUp[i]._val) & ~(xLow[i]._val & yLow[i]._val) & zUp[i]._val;
        
        //x_k=0 & y_k=1 => z_k=1
        //x_k=1 & y_k=0 => z_k=1
        newZLow[i] = (~xUp[i]._val & yLow[i]._val) | (xLow[i]._val & ~yUp[i]._val) | zLow[i]._val;
        
        //z_k=0 & y_k=0 => x_k=0
        //z_k=1 & y_k=1 => x_k=0
        newXUp[i] = (zUp[i]._val | yUp[i]._val) & ~(yLow[i]._val & zLow[i]._val) & xUp[i]._val;
        
        //z_k=0 & y_k=1 => x_k=1
        //z_k=1 & y_k=0 => x_k=1
        newXLow[i] = (~zUp[i]._val & yLow[i]._val) | (zLow[i]._val & ~yUp[i]._val) | xLow[i]._val;
        
        //z_k=0 & x_k=0 => y_k=0
        //z_k=1 & x_k=1 => y_k=0
        newYUp[i] = (zUp[i]._val | xUp[i]._val) & ~(xLow[i]._val & zLow[i]._val) & yUp[i]._val;
        
        //z_k=0 & x_k=1 => y_k=1
        //z_k=1 & x_k=0 => y_k=1
        newYLow[i] =  (~zUp[i]._val & xLow[i]._val) | (zLow[i]._val & ~xUp[i]._val) | yLow[i]._val;
        
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        upXORlow = newZUp[i] ^ newZLow[i];
        inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
        if (inconsistencyFound)
            failNow();
    }
   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];
   [_z setUp:newZUp andLow:newZLow];
   
//    [_x setLow:newXLow];
//    [_x setUp:newXUp];
//    [_y setLow:newYLow];
//    [_y setUp:newYUp];
//    [_z setLow:newZLow];
//    [_z setUp:newZUp];
   
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@" XOR  Y =%@",_y);
   NSLog(@"   =  Z=%@",_z);
   NSLog(@"**********************************");
#endif
}
@end

@implementation CPBitIF
-(id) initCPBitIF: (CPBitVarI*) w equalsOneIf:(CPBitVarI*) x equals: (CPBitVarI*) y andZeroIfXEquals: (CPBitVarI*) z {
    self = [super initCPCoreConstraint:[x engine]];
    _w = w;
    _x = x;
    _y = y;
    _z = z;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
   [self propagate];
//<<<<<<< HEAD
//   if (![_w bound])
//      [_w whenChangePropagate: self];
//   if (![_x bound])
//      [_x whenChangePropagate: self];
//   if (![_y bound])
//      [_y whenChangePropagate: self];
//   if (![_z bound])
//      [_z whenChangePropagate: self];
//////   if (![_x bound] || ![_y bound]) {
////   if (![_x bound] || ![_y bound] || ![_z bound] || ![_w bound]) {\
////      //_w added by GAJ on 11/29/12
////      [_w whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////   }
////   [self propagate];
//   return ORSuspend;
//=======
////   if (![_x bound] || ![_y bound]) {
   if (![_x bound] || ![_y bound] || ![_z bound] || ![_w bound]) {
      //_w added by GAJ on 11/29/12
      [_w whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   }
   [self propagate];
//>>>>>>> master
}
-(void) propagate
{    
    unsigned int wordLength = [_x getWordLength];
    
    TRUInt* wLow = [_w getLow];
    TRUInt* wUp = [_w getUp];
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    TRUInt* zLow = [_z getLow];
    TRUInt* zUp = [_z getUp];
    
    unsigned int* newWUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newWLow = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    
    unsigned int fixed;
    unsigned int opposite;
    unsigned int trueInWY;
    unsigned int trueInWZ;
    unsigned int falseInWY;
    unsigned int falseInWZ;

    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;
    
    for(int i=0;i<wordLength;i++){
        
        newWUp[i] = (~xLow[i]._val | yUp[i]._val) & (xUp[i]._val | zUp[i]._val) & (yUp[i]._val | zUp[i]._val) & wUp[i]._val;
        newWLow[i] = (~xLow[i]._val | yLow[i]._val) | (xUp[i]._val | zLow[i]._val) | (yLow[i]._val & zLow[i]._val) | wLow[i]._val;
        
        fixed = ~(yLow[i]._val ^ yUp[i]._val) & ~(zLow[i]._val & zUp[i]._val);
        opposite = fixed & (yLow[i]._val ^ zLow[i]._val);
        
        trueInWY = yLow[i]._val & opposite & wLow[i]._val;
        trueInWZ = zLow[i]._val & opposite & wLow[i]._val;
        falseInWY = ~yUp[i]._val & opposite & ~wUp[i]._val;
        falseInWZ = ~zUp[i]._val & opposite & ~wUp[i]._val;
        
        newXLow[i] =  xLow[i]._val | trueInWY | falseInWY;
        newXUp[i] = xUp[i]._val & ~trueInWZ & ~falseInWZ;

        newYLow[i] =  (~xLow[i]._val | wLow[i]._val) | yLow[i]._val;
        newYUp[i] = (~xLow[i]._val | wUp[i]._val) & yUp[i]._val;
        
        newZLow[i] = (xUp[i]._val | wLow[i]._val) | xLow[i]._val;
        newZUp[i] = (xUp[i]._val | wUp[i]._val) & zUp[i]._val; 
        
        upXORlow = newWUp[i] ^ newWLow[i];
        inconsistencyFound |= (upXORlow&(~newWUp[i]))&(upXORlow & newWLow[i]);
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        upXORlow = newZUp[i] ^ newZLow[i];
        inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
        if (inconsistencyFound)
            failNow();
    }
    [_w setLow:newWLow];
    [_w setUp:newWUp];
    [_x setLow:newXLow];
    [_x setUp:newXUp];
    [_y setLow:newYLow];
    [_y setUp:newYUp];
    [_z setLow:newZLow];
    [_z setUp:newZUp];
}
@end
 
@implementation CPBitShiftL
-(id) initCPBitShiftL:(CPBitVarI*)x shiftLBy:(int)places equals:(CPBitVarI*)y{
    self = [super initCPCoreConstraint:[x engine]];
    _x = x;
    _y = y;
    _places = places;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
//<<<<<<< HEAD
//
////   [self propagate];
//   return ORSuspend;
//=======
////      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
////      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
//   }
   [self propagate];
//>>>>>>> master
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Left Constraint propagated.");
#endif
   unsigned int wordLength = [_x getWordLength];
    
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;

   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];

   
    unsigned int* newXUp = alloca((sizeof(unsigned int))*(wordLength+1));
    unsigned int* newXLow  = alloca((sizeof(unsigned int))*(wordLength+1));
    unsigned int* newYUp = alloca((sizeof(unsigned int))*(wordLength+1));
    unsigned int* newYLow  = alloca((sizeof(unsigned int))*(wordLength+1));
    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;

   for(int i=0;i<wordLength;i++){
      if ((i+_places/32) < wordLength) {
         newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)<<(_places%32))));
         newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)<<(_places%32)));
//         NSLog(@"i=%i",i+_places/32);
         if((i+_places/32+1) < wordLength) {
            newYUp[i] &= ~(ISFALSE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)>>(32-(_places%32)));
            newYLow[i] |= ISTRUE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)>>(32-(_places%32));
//            NSLog(@"i=%i",i+_places/32+1);
         }
         else{
            newYUp[i] &= ~(UP_MASK >> (32-(_places%32)));
            newYLow[i] &= ~(UP_MASK >> (32-(_places%32)));
         }
      }
      else{
         newYUp[i] = 0;
         newYLow[i] = 0;
      }
      
      if ((i-(int)_places/32) >= 0) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)>>(_places%32))));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)>>(_places%32)));
//         NSLog(@"i=%i",i-_places/32);
         if((i-(int)_places/32-1) >= 0) {
            newXUp[i] &= ~(ISFALSE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)<<(32-(_places%32)));
            newXLow[i] |= ISTRUE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)<<(32-(_places%32));
//            NSLog(@"i=%i",i-(int)_places/32-1);
         }
      }
      else{
         newXUp[i] = xUp[i]._val;
         newXLow[i] = xLow[i]._val;
      }

      upXORlow = newXUp[i] ^ newXLow[i];
      inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
      if (inconsistencyFound){
//         NSLog(@"Inconsistency found in Shift L Bit constraint X Variable.");
         failNow();
      }

      upXORlow = newYUp[i] ^ newYLow[i];
      inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
      if (inconsistencyFound){
//         NSLog(@"Inconsistency found in Shift L Bit constraint Y Variable.");
         failNow();
      }

   }
   
   if (inconsistencyFound){
//      NSLog(@"Inconsistency found in Shift L Bit constraint.");
      failNow();
   }

   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];

//    [_x setLow:newXLow];
//    [_x setUp:newXUp];
//    [_y setLow:newYLow];
//    [_y setUp:newYUp];
}
@end

@implementation CPBitShiftR
-(id) initCPBitShiftR:(CPBitVarI*)x shiftRBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
//   return ORSuspend;
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Right Constraint propagated.");
#endif
   unsigned int wordLength = [_x getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   
   unsigned int* newXUp = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newXLow  = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newYUp = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newYLow  = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int upXORlow;
   
   bool    inconsistencyFound = false;
   
   for(int i=0;i<wordLength;i++){
      if ((i+_places/32) < wordLength) {
         newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)>>(_places%32))));
         newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)>>(_places%32)));
         //         NSLog(@"i=%i",i+_places/32);
         if((i+_places/32+1) < wordLength) {
            newYUp[i] &= ~(ISFALSE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)<<(32-(_places%32)));
            newYLow[i] |= ISTRUE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)<<(32-(_places%32));
            //            NSLog(@"i=%i",i+_places/32+1);
         }
         else{
            newYUp[i] &= ~(UP_MASK << (32-(_places%32)));
            newYLow[i] &= ~(UP_MASK << (32-(_places%32)));
         }
      }
      else{
         newYUp[i] = 0;
         newYLow[i] = 0;
      }
      
      if ((i-(int)_places/32) >= 0) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)<<(_places%32))));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)<<(_places%32)));
         //         NSLog(@"i=%i",i-_places/32);
         if((i-(int)_places/32-1) >= 0) {
            newXUp[i] &= ~(ISFALSE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)>>(32-(_places%32)));
            newXLow[i] |= ISTRUE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)>>(32-(_places%32));
            //            NSLog(@"i=%i",i-(int)_places/32-1);
         }
      }
      else{
         newXUp[i] = xUp[i]._val;
         newXLow[i] = xLow[i]._val;
      }
      
      upXORlow = newXUp[i] ^ newXLow[i];
      inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
//      if (inconsistencyFound){
//         //         NSLog(@"Inconsistency found in Shift L Bit constraint X Variable.");
//         failNow();
//      }
      
      upXORlow = newYUp[i] ^ newYLow[i];
      inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
//      if (inconsistencyFound){
//         //         NSLog(@"Inconsistency found in Shift L Bit constraint Y Variable.");
//         failNow();
//      }
      
   }
   
   if (inconsistencyFound){
      //      NSLog(@"Inconsistency found in Shift L Bit constraint.");
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];
   
   //    [_x setLow:newXLow];
   //    [_x setUp:newXUp];
   //    [_y setLow:newYLow];
   //    [_y setUp:newYUp];
}
@end

@implementation CPBitRotateL
-(id) initCPBitRotateL:(CPBitVarI*)x rotateLBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
}

-(void) post
{
   [self propagate];
//<<<<<<< HEAD
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];

//   [self propagate];
//=======
//>>>>>>> master
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"********************************************************");
   NSLog(@"Bit Rotate Left Constraint propagated.");
#endif
   unsigned int wordLength = [_x getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];

   
   unsigned int* newXUp = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newXLow  = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newYUp = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newYLow  = alloca((sizeof(unsigned int))*wordLength);
   unsigned int upXORlow;
   
   bool    inconsistencyFound = false;
   
#ifdef BIT_DEBUG
   NSLog(@"         X =%@",_x);
   NSLog(@" ROTL %d  Y =%@",_places,_y);
#endif

   for(int i=0;i<wordLength;i++){
      newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val) | (ISFALSE(xUp[(i+(_places/32))%wordLength]._val, xLow[(i+(_places/32))%wordLength]._val) << _places%32)
                                                      | (ISFALSE(xUp[(i+(_places/32)+1)%wordLength]._val, xLow[(i+(_places/32)+1)%wordLength]._val) >> (32-(_places%32))));
      
      newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)   | (ISTRUE(xUp[(i+(_places/32))%wordLength]._val, xLow[(i+(_places/32))%wordLength]._val) << _places%32)
                                                      | (ISTRUE(xUp[(i+(_places/32)+1)%wordLength]._val, xLow[(i+(_places/32)+1)%wordLength]._val) >> (32-(_places%32)));
      
      newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val) | (ISFALSE(yUp[(i-(_places/32))%wordLength]._val, yLow[(i-(_places/32))%wordLength]._val) >> _places%32)
                                                      | (ISFALSE(yUp[(i-(_places/32)-1)%wordLength]._val, yLow[(i-(_places/32)-1)%wordLength]._val) << (32-(_places%32))));
      
      newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)   | (ISTRUE(yUp[(i-(_places/32))%wordLength]._val, yLow[(i-(_places/32))%wordLength]._val) >> _places%32)
                                                      | (ISTRUE(yUp[(i-(_places/32)-1)%wordLength]._val, yLow[(i-(_places/32)-1)%wordLength]._val) << (32-(_places%32)));
     
      upXORlow = newYUp[i] ^ newYLow[i];
      inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
//      if (inconsistencyFound)
//         NSLog(@"Inconsistency found in Rotate L Bit constraint in the y variable at index %d.",i);
      
      upXORlow = newXUp[i] ^ newXLow[i];
      inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
//      if (inconsistencyFound)
//         NSLog(@"Inconsistency found in Rotate L Bit constraint in the x variable at index %d.",i);
      
   }
   
   if (inconsistencyFound){
//      NSLog(@"Inconsistency found in Rotate L Bit constraint.");
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];
   
//   [_x setLow:newXLow];
//   [_x setUp:newXUp];
//   [_y setLow:newYLow];
//   [_y setUp:newYUp];

#ifdef BIT_DEBUG
   NSLog(@"         X =%@",_x);
   NSLog(@" ROTL %d  Y =%@",_places,_y);
   NSLog(@"********************************************************");
#endif
}
@end

@implementation CPBitADD
-(id) initCPBitAdd:(id<CPBitVar>)x plus:(id<CPBitVar>)y equals:(id<CPBitVar>)z withCarryIn:(id<CPBitVar>)cin andCarryOut:(id<CPBitVar>)cout
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = (CPBitVarI*)x;
   _y = (CPBitVarI*)y;
   _z = (CPBitVarI*)z;
   _cin = (CPBitVarI*)cin;
   _cout = (CPBitVarI*)cout;
   return self;
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
//   NSLog(@"Bit Sum Constraint Posted");
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
//<<<<<<< HEAD
////   [self propagate];
//   return ORSuspend;
//=======
////      [_cin whenChangePropagate: self];
////      [_cout whenChangePropagate: self];
//      
////      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
////      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
////      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
////      [_cin whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
////      [_cout whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
//   }
//   [self propagate];
//>>>>>>> master
}
-(void) propagate
{//   NSLog(@"Bit Sum Constraint Propagated");
   
    unsigned int wordLength = [_x getWordLength];
    bool change = true;

//   TRUInt* xLow = [_x getLow];
//   TRUInt* xUp = [_x getUp];
//   TRUInt* yLow = [_y getLow];
//   TRUInt* yUp = [_y getUp];
//   TRUInt* zLow = [_z getLow];
//   TRUInt* zUp = [_z getUp];
//   TRUInt* cinLow = [_cin getLow];
//   TRUInt* cinUp = [_cin getUp];
//   TRUInt* coutLow = [_cout getLow];
//   TRUInt* coutUp = [_cout getUp];

   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   TRUInt* cinLow;
   TRUInt* cinUp;
   TRUInt* coutLow;
   TRUInt* coutUp;

   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   [_cin getUp:&cinUp andLow:&cinLow];
   [_cout getUp:&coutUp andLow:&coutLow];
   
#ifdef BIT_CONSISTENT_CHECK
   ORUInt xSetBitsBefore = numSetBits(xLow, xUp, wordLength);
   ORUInt ySetBitsBefore = numSetBits(yLow, yUp, wordLength);
   ORUInt zSetBitsBefore = numSetBits(zLow, zUp, wordLength);
   ORUInt cinSetBitsBefore = numSetBits(cinLow, cinUp, wordLength);
   ORUInt coutSetBitsBefore = numSetBits(coutLow, coutUp, wordLength);
#endif

    unsigned int* prevXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevCinUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevCinLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevCoutUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* prevCoutLow  = alloca(sizeof(unsigned int)*wordLength);
    
    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newCinUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newCinLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newCoutUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newCoutLow  = alloca(sizeof(unsigned int)*wordLength);

   unsigned int* shiftedCinUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* shiftedCinLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* shiftedCoutUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* shiftedCoutLow  = alloca(sizeof(unsigned int)*wordLength);

    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;

    for(int i = 0; i<wordLength;i++){
        prevXUp[i] = newXUp[i] = xUp[i]._val;
        prevXLow[i] = newXLow[i] = xLow[i]._val;
        prevYUp[i] = newYUp[i] = yUp[i]._val;
        prevYLow[i] = newYLow[i] = yLow[i]._val;
        prevZUp[i] = newZUp[i] = zUp[i]._val;
        prevZLow[i] = newZLow[i] = zLow[i]._val;
        
//       newXUp[i] = xUp[i]._val;
//       newXLow[i] = xLow[i]._val;
//       newYUp[i] = yUp[i]._val;
//       newYLow[i] = yLow[i]._val;
//       newZUp[i] = zUp[i]._val;
//       newZLow[i] = zLow[i]._val;

        prevCinUp[i] = newCinUp[i] = cinUp[i]._val;
        prevCinLow[i] = newCinLow[i] = cinLow[i]._val;
        prevCoutUp[i] = newCoutUp[i] = coutUp[i]._val;
        prevCoutLow[i] = newCoutLow[i] = coutLow[i]._val;
       
//       newCinUp[i] = cinUp[i]._val;
//       newCinLow[i] = cinLow[i]._val;
//       newCoutUp[i] = coutUp[i]._val;
//       newCoutLow[i] = coutLow[i]._val;

    }
#ifdef BIT_DEBUG
       NSLog(@"********************************************************");
       NSLog(@"propagating sum constraint");
       NSLog(@" Cin  =%@",_cin);
       NSLog(@" X    =%@",_x);
       NSLog(@"+Y    =%@",_y);
       NSLog(@"_______________________________________________________");
       NSLog(@" Z    =%@",_z);
       NSLog(@" Cout =%@\n\n",_cout);
   NSLog(@"\n\n");
#endif
//   NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
//   NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
//   NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
//   NSLog(@"_______________________________________________________");
//   NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
//   NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));


   while (change) {
//       NSLog(@"propagating sum constraint");
//       NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
//       NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
//       NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
//       NSLog(@"_______________________________________________________");
//       NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
//       NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));

       change = false;
//      NSLog(@"top of iteration for sum constraint");
//             NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
//             NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
//             NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
//             NSLog(@"_______________________________________________________");
//             NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
//             NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));

       for(int i=0;i<wordLength;i++){
//          NSLog(@"\ttop of shift iteration for sum constraint");
//          NSLog(@"\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
//          NSLog(@"\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
//          NSLog(@"\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
//          NSLog(@"\t_______________________________________________________");
//          NSLog(@"\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
//          NSLog(@"\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
          
          // Pasted shift constraint code to directly compute new CIN from the new COUT
//          for(int j=0;j<wordLength;j++){
             if (i < wordLength) {
                shiftedCinUp[i] = ~(ISFALSE(prevCinUp[i],prevCinLow[i])|((ISFALSE(prevCoutUp[i], prevCoutLow[i])<<1)));
                shiftedCinLow[i] = ISTRUE(prevCinUp[i],prevCinLow[i])|(ISTRUE(prevCoutUp[i], prevCoutLow[i])<<1);
                //         NSLog(@"i=%i",i+1/32);
                if((i+1) < wordLength) {
                   shiftedCinUp[i] &= ~(ISFALSE(prevCoutUp[i+1], prevCoutLow[i+1])>>31);
                   shiftedCinLow[i] |= ISTRUE(prevCoutUp[i+1], prevCoutLow[i+1])>>31;
                   //            NSLog(@"i=%i",i+1/32+1);
                }
                else{
                   shiftedCinUp[i] &= ~(UP_MASK >> 31);
                   shiftedCinLow[i] &= ~(UP_MASK >> 31);
                }
             }
             else{
                shiftedCinUp[i] = 0;
                shiftedCinLow[i] = 0;
             }
             
             if (i >= 0) {
                shiftedCoutUp[i] = ~(ISFALSE(prevCoutUp[i],prevCoutLow[i])|(ISFALSE(prevCinUp[i], prevCinLow[i])>>1));
                shiftedCoutLow[i] = ISTRUE(prevCoutUp[i],prevCoutLow[i])|(ISTRUE(prevCinUp[i], prevCinLow[i])>>1);
                //         NSLog(@"i=%i",i-1/32);
                if((i-1) >= 0) {
                   shiftedCoutUp[i] &= ~(ISFALSE(prevCinUp[i-1],prevCinLow[i-1])<<31);
                   shiftedCoutLow[i] |= ISTRUE(prevCinUp[i-1],prevCinLow[i-1])<<31;
                   //            NSLog(@"i=%i",i-(int)_places/32-1);
                }
             }
             else{
                shiftedCoutUp[i] = prevCoutUp[i];
                shiftedCoutLow[i] = prevCoutLow[i];
             }
             change |= shiftedCinUp[i] ^ prevCinUp[i];
             change |= shiftedCinLow[i] ^ prevCinLow[i];
             change |= shiftedCoutUp[i] ^ prevCoutUp[i];
             change |= shiftedCoutLow[i] ^ prevCoutLow[i];

             //testing for internal consistency
             upXORlow = shiftedCinUp[i] ^ shiftedCinLow[i];
             inconsistencyFound |= (upXORlow&(~shiftedCinUp[i]))&(upXORlow & shiftedCinLow[i]);
#ifdef BIT_DEBUG
             if (inconsistencyFound){
                NSLog(@"Inconsistency in Bitwise sum constraint in (shifted) Carry In.\n");

                          NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
                          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
                          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
                          NSLog(@"_______________________________________________________");
                          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
                          NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
                
                          NSLog(@" Cin  =%@",bitvar2NSString(shiftedCinLow,shiftedCinUp, wordLength));
                          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
                          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
                          NSLog(@"_______________________________________________________");
                          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
                          NSLog(@" Cout =%@\n\n",bitvar2NSString(shiftedCoutLow, shiftedCoutUp, wordLength));
                failNow();
          }
#endif
             prevCoutLow[i] = shiftedCoutLow[i];
             prevCoutUp[i] = shiftedCoutUp[i];
             prevCinLow[i] = shiftedCinLow[i];
             prevCinUp[i] = shiftedCinUp[i];
             

//          NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
//          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
//          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
//          NSLog(@"_______________________________________________________");
//          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
//          NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
          
             //commented out on 2/11/13 by GAJ (vars are checked below)
//          //Chgeck consistency of new domain for Cin variable.
//             inconsistencyFound |= ((prevXLow[i] & ~prevXUp[i]) |
//                                    (prevXLow[i] & prevYLow[i] & ~prevCoutUp[i]) |
//                                    (prevXLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                    (~prevXUp[i] & ~prevYUp[i] & prevCoutLow[i]) |
//                                    (~prevXUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                    (prevYLow[i] & ~prevYUp[i]) |
//                                    (prevYLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                    (~prevYUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                    (prevZLow[i] & ~prevZUp[i]) |
//                                    (prevCoutLow[i] & ~prevCoutUp[i]));
          
//          }

          
          // End of pasted code
          
//          if(![_x bound]){
           newXUp[i] = prevXUp[i] &
             ~((~prevCinLow[i] & ~prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i]) |
               (~prevCinLow[i] & ~prevCinUp[i] & prevYLow[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
               (~prevCinLow[i] & ~prevYLow[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (~prevCinLow[i] & prevYLow[i] & prevYUp[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (prevCinLow[i] & prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
               (prevCinLow[i] & prevCinUp[i] & ~prevYLow[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (prevCinLow[i] & prevCinUp[i] & prevYLow[i] & prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]));
             
           newXLow[i] = prevXLow[i] |
             ((~prevCinLow[i] & ~prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
              (~prevCinLow[i] & ~prevCinUp[i] & prevYLow[i] & prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
              (~prevCinLow[i] & ~prevCinUp[i] & prevYUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
              (prevCinLow[i] & prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
              (prevCinLow[i] & prevCinUp[i] & prevYLow[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & prevCoutUp[i]) |
              (prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
              (prevCinUp[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & prevCoutLow[i] & prevCoutUp[i]));


//          }
          
//          if(![_y bound]){
           newYUp[i] = prevYUp[i] &
             ~((~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i]) |
               (~prevCinLow[i] & ~prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
               (~prevCinLow[i] & ~prevXLow[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (~prevCinLow[i] & prevXLow[i] & prevXUp[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
               (prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]));

           newYLow[i] = prevYLow[i] |
             ((~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
              (~prevCinLow[i] & ~prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
              (~prevCinLow[i] & ~prevCinUp[i] & prevXUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
              (prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
              (prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevZLow[i] & prevZUp[i] & prevCoutUp[i]) |
              (prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
              (prevCinUp[i] & prevXUp[i] & prevZLow[i] & prevZUp[i] & prevCoutLow[i] & prevCoutUp[i]));


//          }

          
//          if(![_z bound]){
           newZUp[i] = prevZUp[i] &
             ~((~prevCoutLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
               (prevCoutLow[i] & prevCoutUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXUp[i] & prevYUp[i]) |
               (prevCoutLow[i] & prevCoutUp[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevYUp[i]) |
               (prevCoutLow[i] & prevCoutUp[i] & prevCinUp[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
               (prevCoutUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]) |
               (prevCoutUp[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevYLow[i] & prevYUp[i]) |
               (prevCoutUp[i] & prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]));
             
             
             newZLow[i] = prevZLow[i] |
             ((~prevCoutLow[i] & ~prevCoutUp[i] & ~prevCinLow[i] & ~prevXLow[i] & prevYLow[i] & prevYUp[i]) |
              (~prevCoutLow[i] & ~prevCoutUp[i] & ~prevCinLow[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i]) |
              (~prevCoutLow[i] & ~prevCoutUp[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevYLow[i]) |
              (~prevCoutLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevYLow[i] & prevYUp[i]) |
              (~prevCoutLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
              (~prevCoutLow[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
              (prevCoutUp[i] & prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]));

             //Check consistency of new domain for Z variable
             inconsistencyFound |=((prevCoutLow[i] & ~prevCoutUp[i]) |
                                   (prevCoutLow[i] & ~prevCinUp[i] & ~prevXUp[i]) |
                                   (prevCoutLow[i] & ~prevCinUp[i] & ~prevYUp[i]) |
                                   (prevCoutLow[i] & ~prevXUp[i] & ~prevYUp[i]) |
                                   (~prevCoutUp[i] & prevCinLow[i] & prevXLow[i]) |
                                   (~prevCoutUp[i] & prevCinLow[i] & prevYLow[i]) |
                                   (~prevCoutUp[i] & prevXLow[i] & prevYLow[i]) | 
                                   (prevCinLow[i] & ~prevCinUp[i]) | 
                                   (prevXLow[i] & ~prevXUp[i]) | 
                                   (prevYLow[i] & ~prevYUp[i]));
             
//          }
        
//          if(![_cin bound]){
           newCinUp[i] = prevCinUp[i] &
             ~((~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i]) |
               (~prevXLow[i] & ~prevXUp[i] & prevYLow[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
               (~prevXLow[i] & ~prevYLow[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (~prevXLow[i] & prevYLow[i] & prevYUp[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (prevXLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
               (prevXLow[i] & prevXUp[i] & ~prevYLow[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
               (prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]));

                                                                                                                                                                               
           newCinLow[i] = prevCinLow[i] |
             ((~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
              (~prevXLow[i] & ~prevXUp[i] & prevYLow[i] & prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
              (~prevXLow[i] & ~prevXUp[i] & prevYUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
              (prevXLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
              (prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & prevCoutUp[i]) |
              (prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
              (prevXUp[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & prevCoutLow[i] & prevCoutUp[i]));
             
             //Chgeck consistency of new domain for Cin variable.
             //AB'+ACH'+AF'H'+B'CE+B'D'G+B'EG+CD'+CF'H'+D'EG+EF'+GH'
             inconsistencyFound |= ((prevXLow[i] & ~prevXUp[i]) |
                                    (prevXLow[i] & prevYLow[i] & ~prevCoutUp[i]) |
                                    (prevXLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
                                    (~prevXUp[i] & ~prevYUp[i] & prevCoutLow[i]) |
                                    (~prevXUp[i] & prevZLow[i] & prevCoutLow[i]) |
                                    (prevYLow[i] & ~prevYUp[i]) |
                                    (prevYLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
                                    (~prevYUp[i] & prevZLow[i] & prevCoutLow[i]) |
                                    (prevZLow[i] & ~prevZUp[i]) |
                                    (prevCoutLow[i] & ~prevCoutUp[i]));
             

             

//          }
          
//          if(![_cout bound]){
           newCoutUp[i] = prevCoutUp[i] &
             ~((~prevZLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i]) |
               (~prevZLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevYLow[i] & ~prevYUp[i]) |
               (~prevZLow[i] & ~prevCinLow[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
               (prevZLow[i] & prevZUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & prevYUp[i]) |
               (prevZLow[i] & prevZUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXUp[i] & ~prevYLow[i]) |
               (prevZLow[i] & prevZUp[i] & ~prevCinLow[i] & ~prevXLow[i] & ~prevXUp[i] & prevYUp[i]) |
               (prevZLow[i] & prevZUp[i] & ~prevCinLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
               (prevZLow[i] & prevZUp[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i]) |
               (prevZLow[i] & prevZUp[i] & prevCinUp[i] & ~prevXLow[i] & ~prevYLow[i] & ~prevYUp[i]) |
               (prevZUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevYUp[i]) |
               (prevZUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
               (prevZUp[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]));
             
             newCoutLow[i] = prevCoutLow[i] |
             ((~prevZLow[i] & ~prevZUp[i] & ~prevCinLow[i] & prevXLow[i] & prevXUp[i] & prevYUp[i]) |
              (~prevZLow[i] & ~prevZUp[i] & ~prevCinLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]) |
              (~prevZLow[i] & ~prevZUp[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & prevYUp[i]) |
              (~prevZLow[i] & ~prevZUp[i] & prevCinLow[i] & prevCinUp[i] & prevXUp[i] & ~prevYLow[i]) |
              (~prevZLow[i] & ~prevZUp[i] & prevCinUp[i] & ~prevXLow[i] & prevYLow[i] & prevYUp[i]) |
              (~prevZLow[i] & ~prevZUp[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i]) |
              (~prevZLow[i] & ~prevCinLow[i] & prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]) |
              (~prevZLow[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & prevYLow[i] & prevYUp[i]) |
              (~prevZLow[i] & prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i]) |
              (prevZUp[i] & prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevYUp[i]) |
              (prevZUp[i] & prevCinLow[i] & prevCinUp[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]) |
              (prevZUp[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]));
             
//         }
          
          //Check consistency of new domain for X variable
          inconsistencyFound |= ((prevCinLow[i] & ~prevCinUp[i]) |
                                (prevCinLow[i] & prevYLow[i] & ~prevCoutUp[i]) |
                                (prevCinLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
                                (~prevCinUp[i] & ~prevYUp[i] & prevCoutLow[i]) |
                                (~prevCinUp[i] & prevZLow[i] & prevCoutLow[i]) |
                                (prevYLow[i] & ~prevYUp[i]) |
                                (prevYLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
                                (~prevYUp[i] & prevZLow[i] & prevCoutLow[i]) |
                                (prevZLow[i] & ~prevZUp[i]) |
                                (prevCoutLow[i] & ~prevCoutUp[i]));
#ifdef BIT_DEBUG
          if (inconsistencyFound){
             NSLog(@"Logical inconsistency in Bitwise sum constraint variable x.\n");
             NSLog(@"In the %d th word: %x\n\n",i,inconsistencyFound);
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
             failNow();
          }
//#endif
          
          //testing for internal consistency
          upXORlow = newXUp[i] ^ newXLow[i];
          inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
//#ifdef BIT_DEBUG
          if (inconsistencyFound){
             NSLog(@"Inconsistency in Bitwise sum constraint variable x.\n");
             NSLog(@"In the %d th word: %x\n\n",i,inconsistencyFound);
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
             failNow();
          }
#endif
          //Check consistency of new domain for Y variable
          inconsistencyFound |= ((prevCinLow[i] & ~prevCinUp[i]) |
                                 (prevCinLow[i] & prevXLow[i] & ~prevCoutUp[i]) |
                                 (prevCinLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
                                 (~prevCinUp[i] & ~prevXUp[i] & prevCoutLow[i]) |
                                 (~prevCinUp[i] & prevZLow[i] & prevCoutLow[i]) |
                                 (prevXLow[i] & ~prevXUp[i]) |
                                 (prevXLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
                                 (~prevXUp[i] & prevZLow[i] & prevCoutLow[i]) |
                                 (prevZLow[i] & ~prevZUp[i]) |
                                 (prevCoutLow[i] & ~prevCoutUp[i]));
          
          
#ifdef BIT_DEBUG
          if (inconsistencyFound){
             NSLog(@"Inconsistency in Bitwise sum constraint variable y. [unstable sum constraint]\n");
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
             failNow();
          }
//#endif
          
          
          //testing for internal consistency
          upXORlow = newYUp[i] ^ newYLow[i];
          inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
//#ifdef BIT_DEBUG
          if (inconsistencyFound){
             NSLog(@"Inconsistency in Bitwise sum constraint variable y. [unstable bitvar]\n");
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
             failNow();
          }
#endif
          
          
#ifdef BIT_DEBUG
          if (inconsistencyFound){
             NSLog(@"Inconsistency in Bitwise sum constraint variable z [impossible bit pattern for variable].\n");
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
             failNow();
          }
//#endif
          
          //testing for internal consistency
          upXORlow = newZUp[i] ^ newZLow[i];
          inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
//#ifdef BIT_DEBUG
          if (inconsistencyFound){
             NSLog(@"Inconsistency in Bitwise sum constraint variable z.\n");
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
             failNow();
          }
          
          if (inconsistencyFound){
             NSLog(@"Inconsistency in Bitwise sum constraint in Carry In logical inconsistency.\n");
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
             failNow();
          }
//#endif
          
          
          //testing for internal consistency
          upXORlow = newCinUp[i] ^ newCinLow[i];
          inconsistencyFound |= (upXORlow&(~newCinUp[i]))&(upXORlow & newCinLow[i]);
//#ifdef BIT_DEBUG
          if (inconsistencyFound){
             NSLog(@"Inconsistency in Bitwise sum constraint in Carry In.\n");
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
             failNow();
          }
#endif

          //Check consistency of new domain for Cout variable
          inconsistencyFound |= ((prevZLow[i] & ~prevZUp[i]) |
                                 (prevZLow[i] & prevCinLow[i] & prevXLow[i] & ~prevYUp[i]) |
                                 (prevZLow[i] & prevCinLow[i] & ~prevXUp[i] & prevYLow[i]) |
                                 (prevZLow[i] & ~prevCinUp[i] & prevXLow[i] & prevYLow[i]) |
                                 (prevZLow[i] & ~prevCinUp[i] & ~prevXUp[i] & ~prevYUp[i]) |
                                 (~prevZUp[i] & prevCinLow[i] & prevXLow[i] & prevYLow[i]) |
                                 (~prevZUp[i] & prevCinLow[i] & ~prevXUp[i] & ~prevYUp[i]) |
                                 (~prevZUp[i] & ~prevCinUp[i] & prevXLow[i] & ~prevYUp[i]) |
                                 (~prevZUp[i] & ~prevCinUp[i] & ~prevXUp[i] & prevYLow[i]) |
                                 (prevCinLow[i] & ~prevCinUp[i]) |
                                 (prevXLow[i] & ~prevXUp[i]) |
                                 (prevYLow[i] & ~prevYUp[i]));
          
          
          //testing for internal consistency
          upXORlow = newCoutUp[i] ^ newCoutLow[i];
          inconsistencyFound |= (upXORlow&(~newCoutUp[i]))&(upXORlow & newCoutLow[i]);
          
          if (inconsistencyFound){
#ifdef BIT_DEBUG
             NSLog(@"Inconsistency in Bitwise sum constraint in carry out.\n");
             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
#endif
             failNow();
          }

//          //Check consistency of new domain for Z variable
//          inconsistencyFound |= (ISFALSE(newXUp[i], newXLow[i]) & ISFALSE(newCinUp[i], newCinLow[i]) & ISTRUE(newCoutUp[i], newCoutLow[i])) |
//          (ISTRUE(newYUp[i], newYLow[i]) & ISTRUE(newCinUp[i], newCinLow[i]) & ISFALSE(newCoutUp[i], newCoutLow[i])) |
//          (ISTRUE(newXUp[i], newXLow[i]) & ISTRUE(newCinUp[i], newCinLow[i]) & ISFALSE(newCoutUp[i], newCoutLow[i])) |
//          (ISFALSE(newXUp[i], newXLow[i]) & ISFALSE(newYUp[i], newYLow[i]) & ISTRUE(newCoutUp[i], newCoutLow[i])) |
//          (ISTRUE(newXUp[i], newXLow[i]) & ISTRUE(newYUp[i], newYLow[i]) & ISFALSE(newCoutUp[i], newCoutLow[i])) |
//          (ISFALSE(newYUp[i], newYLow[i]) & ISFALSE(newCinUp[i], newCinLow[i]) & ISTRUE(newCoutUp[i], newCoutLow[i]));
//          
//          if (inconsistencyFound){
//             NSLog(@"Inconsistency in Bitwise sum constraint variable z [impossible bit pattern for variable].\n");
//             failNow();
//          }
//          
//          //testing for internal consistency
//          upXORlow = newZUp[i] ^ newZLow[i];
//          inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
//          if (inconsistencyFound){
//             NSLog(@"Inconsistency in Bitwise sum constraint variable z.\n");
//             failNow();
//          }

                    
            change |= newXUp[i] ^ prevXUp[i];
            change |= newXLow[i] ^ prevXLow[i];
            change |= newYUp[i] ^ prevYUp[i];
            change |= newYLow[i] ^ prevYLow[i];
            change |= newZUp[i] ^ prevZUp[i];
            change |= newZLow[i] ^ prevZLow[i];
            change |= newCinUp[i] ^ prevCinUp[i];
            change |= newCinLow[i] ^ prevCinLow[i];
            change |= newCoutUp[i] ^ prevCoutUp[i];
            change |= newCoutLow[i] ^ prevCoutLow[i];
          
//            if(change)
//               NSLog(@"At least one variable has changed in propagation of Sum constraint");
//          
          
//          NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
//          NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
//          NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
//          NSLog(@"_____________________________________________________________________________________________________________________________________________________");
//          NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
//          NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
          
          
          
            prevXUp[i] = newXUp[i];
            prevXLow[i] = newXLow[i];
            prevYUp[i] = newYUp[i];
            prevYLow[i] = newYLow[i];
            prevZUp[i] = newZUp[i];
            prevZLow[i] = newZLow[i];
            prevCinUp[i] = newCinUp[i];
            prevCinLow[i] = newCinLow[i];
            prevCoutUp[i] = newCoutUp[i];
            prevCoutLow[i] = newCoutLow[i];
        }
    }
   
   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];
   [_z setUp:newZUp andLow:newZLow];
   [_cin setUp:newCinUp andLow:newCinLow];
   [_cout setUp:newCoutUp andLow:newCoutLow];

//   [_x setLow:newXLow];
//   [_x setUp:newXUp];
//   [_y setLow:newYLow];
//   [_y setUp:newYUp];
//   [_z setLow:newZLow];
//   [_z setUp:newZUp];
//   [_cin setLow:newCinLow];
//   [_cin setUp:newCinUp];
//   [_cout setLow:newCoutLow];
//   [_cout setUp:newCoutUp];
   
#ifdef BIT_CONSISTENT_CHECK
   ORUInt xSetBitsAfter = numSetBitsORUInt(newXLow, newXUp, wordLength);
   ORUInt ySetBitsAfter = numSetBitsORUInt(newYLow, newYUp, wordLength);
   ORUInt zSetBitsAfter = numSetBitsORUInt(newZLow, newZUp, wordLength);
   ORUInt cinSetBitsAfter = numSetBitsORUInt(newCinLow, newCinUp, wordLength);
   ORUInt coutSetBitsAfter = numSetBitsORUInt(newCoutLow, newCoutUp, wordLength);
   
   NSAssert(xSetBitsBefore <= xSetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
   NSAssert(ySetBitsBefore <= ySetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
   NSAssert(zSetBitsBefore <= zSetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
   NSAssert(cinSetBitsBefore <= cinSetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
   NSAssert(coutSetBitsBefore <= coutSetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
#endif
   
#ifdef BIT_DEBUG
   NSLog(@"Done propagating sum constraint");
   NSLog(@" Cin  =%@",_cin);
   NSLog(@" X    =%@",_x);
   NSLog(@"+Y    =%@",_y);
   NSLog(@"_______________________________________________________");
   NSLog(@" Z    =%@",_z);
   NSLog(@" Cout =%@\n\n",_cout);
   NSLog(@"********************************************************\n");
#endif
}
@end

@implementation CPBitCount

-(id) initCPBitCount:(CPBitVarI*) x count:(CPIntVarI*) p
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _p = p;
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_p bound])
      [_p whenChangePropagate: self];
//   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Count Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   ORInt pLow;
   ORInt pUp;
   
   [_x getUp:&xUp andLow:&xLow];
   pLow = [_p min];
   pUp = [_p max];
   
   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
   unsigned int  upXORlow;
   bool    inconsistencyFound = false;
   
//   unsigned int* setUp = alloca(sizeof(unsigned int)*wordLength);
//   unsigned int* freeBits = alloca(sizeof(unsigned int)*wordLength);
   
   ORInt xPopcount = 0;
   ORInt xFreebits = 0;
   
   for(int i=0;i<wordLength;i++){
      up[i] = xUp[i]._val;
      low[i] = xLow[i]._val;
      xPopcount += __builtin_popcount(low[i]);
      xFreebits += __builtin_popcount(up[i] ^ low[i]);
   }
   //Consistency Check
   if((pLow > (xFreebits + xPopcount)) || (pUp < xPopcount))
      failNow();
   
   //Shrink domain of _p if possible
   if(pUp > (xPopcount+xFreebits))
      pUp = xPopcount+xFreebits;
   if(pLow < xPopcount)
      pLow =  xPopcount;
   

   //set or clear unbound bits in _x if possible
   //   If
   if ((xFreebits + xPopcount) == pLow) {
      if (![_p bound])
         [_p bind:pLow];
      for (int i=0; i<wordLength; i++)
         low[i] = up[i];
   }else if(xPopcount == pUp){
      if(![_p bound])
         [_p bind:pUp];
      for (int i=0; i<wordLength; i++)
         up[i] = low[i];
   }else{
      [_p updateMin:pLow andMax:pUp];
   }
   
   //domain consistency check on _x
   for (int i=0; i<wordLength; i++) {
      upXORlow = up[i] ^ low[i];
      inconsistencyFound |= (upXORlow&(~up[i]))&(upXORlow & low[i]);
   }
   if (inconsistencyFound)
      failNow();
   
   //set _x and _p to new values
   [_x setUp:up andLow:low];
}
@end

@implementation CPBitZeroExtend

-(id) initCPBitZeroExtend:(CPBitVarI*) x extendTo:(CPBitVarI *)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
//   unsigned int xWordLength = [_x getWordLength];
//   unsigned int yWordLength = [_y getWordLength];
//   unsigned int wordDiff = yWordLength - xWordLength;
//   
//   TRUInt* yLow;
//   TRUInt* yUp;
//   [_y getUp:&yUp andLow:&yLow];
//   unsigned int* up = alloca(sizeof(unsigned int)*xWordLength);
//   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
//   unsigned int  upXORlow;
//
//   for (int i=0; i<wordDiff; i++) {
//      up[i] = 0;
//      low[i] = 0;
//   }
//   
//   for(int i=wordDiff;i<yWordLength;i++){
//      up[i] = yUp[i]._val;
//      low[i] = yLow[i]._val;
//      upXORlow = up[i] ^ low[i];
//      if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
//         failNow();
//      }
//   }
//   
//   [_y setUp:up andLow:low];
   
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
//   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit ZeroExtend Constraint propagated.");
#endif
   //Check to see that upper (zero) bits are not set to 1
   unsigned int xWordLength = [_x getWordLength];
   unsigned int yWordLength = [_y getWordLength];
//   unsigned int wordDiff = yWordLength - xWordLength;
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   unsigned int* up = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int  upXORlow;
   
   for (int i=0; i<yWordLength; i++) {
      up[i] = 0;
      low[i] = 0;
   }
   
   for(int i=0;i<xWordLength;i++){
      up[i] = xUp[i]._val & yUp[i]._val;
      low[i] = xLow[i]._val | yLow[i]._val;
      upXORlow = up[i] ^ low[i];
      if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
         failNow();
      }
   }
   
   [_x setUp:up andLow:low];
   [_y setUp:up andLow:low];
   
}
@end

@implementation CPBitExtract

-(id) initCPBitExtract:(CPBitVarI*) x from:(ORUInt)lsb to:(ORUInt)msb eq:(CPBitVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _lsb = lsb;
   _msb = msb;
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
//   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Extract Constraint propagated.");
#endif
   
   unsigned int xWordLength = [_x getWordLength];
   unsigned int yWordLength = [_y getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
//   NSLog(@"*******************************************");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   
   unsigned int* up = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
//   unsigned int* xUpForY = alloca(sizeof(unsigned int)*yWordLength);
//   unsigned int* xLowForY =  alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* newXUp = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* yLowForX = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* yUpForX = alloca(sizeof(unsigned int)*yWordLength);
   
   unsigned int  upXORlow;
   bool    inconsistencyFound = false;

   for (int i = 0; i < yWordLength; i++) {
      low[i] = yLowForX[i] = yLow[i]._val;
      up[i] = yUpForX[i] = yUp[i]._val;
      
   }
   yUpForX[yWordLength-1] |= CP_UMASK << [_y bitLength];
   yLowForX[yWordLength-1] &= ~(CP_UMASK << [_y bitLength]);
   
//   NSLog(@"yForX = %@\n",bitvar2NSString(yLowForX, yUpForX, yWordLength));

   for(int i=0;i<xWordLength;i++){
      if ((i+_lsb/32) < xWordLength) {
         
         up[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_lsb/32]._val, xLow[i+_lsb/32]._val)>>(_lsb%32))));
         low[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_lsb/32]._val, xLow[i+_lsb/32]._val)>>(_lsb%32)));
         //         NSLog(@"i=%i",i+_places/32);
         if((i+_lsb/32+1) < xWordLength) {
            up[i] &= ~(ISFALSE(xUp[i+_lsb/32+1]._val, xLow[i+_lsb/32+1]._val)<<(32-(_lsb%32)));
            low[i] |= ISTRUE(xUp[i+_lsb/32+1]._val, xLow[i+_lsb/32+1]._val)<<(32-(_lsb%32));
            //            NSLog(@"i=%i",i+_places/32+1);
         }
         if (i==(yWordLength-1)) {
            up[i] &= UP_MASK >> (32 - ([_y bitLength]%32));
            low[i] &= UP_MASK >> (32 - ([_y bitLength]%32));
         }
      }
//      else{
//         up[i] = 0;
//         low[i] = 0;
//      }
      
      if ((i-(int)_lsb/32) >= 0) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUpForX[i-_lsb/32], yLow[i-_lsb/32]._val)<<(_lsb%32))));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUpForX[i-_lsb/32], yLow[i-_lsb/32]._val)<<(_lsb%32)));
         //         NSLog(@"i=%i",i-_places/32);
         if((i-(int)_lsb/32-1) >= 0) {
            newXUp[i] &= ~(ISFALSE(yUpForX[(i-(int)_lsb/32-1)],yLowForX[(i-(int)_lsb/32-1)])>>(32-(_lsb%32)));
            newXLow[i] |= ISTRUE(yUpForX[(i-(int)_lsb/32-1)],yLowForX[(i-(int)_lsb/32-1)])>>(32-(_lsb%32));
            //            NSLog(@"i=%i",i-(int)_places/32-1);
         }
      }
      else{
         newXUp[i] = xUp[i]._val;
         newXLow[i] = xLow[i]._val;
      }
      
   }
   
   //clear unused upper bits
//   ORUInt mask = CP_UMASK << (_msb-_lsb)%32;
//   newXUp[xWordLength-1] |= mask;
//   newXLow[xWordLength-1] &= ~mask;

   //check domain consistency
   for(int i=0;i<xWordLength;i++){
      upXORlow = newXUp[i] ^ newXLow[i];
      inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
      if (inconsistencyFound){
         NSLog(@"Inconsistency found in Bit Extract constraint X Variable.");
         NSLog(@"x=%@\n",bitvar2NSString(newXLow, newXUp, xWordLength));
         failNow();
      }
      
      upXORlow = up[i] ^ low[i];
      inconsistencyFound |= (upXORlow&(~up[i]))&(upXORlow & low[i]);
      if (inconsistencyFound){
         NSLog(@"Inconsistency found in Bit Extract constraint Y Variable.");
         NSLog(@"y=%@\n",bitvar2NSString(low, up, yWordLength));
         failNow();
      }
      
   }
   
   if (inconsistencyFound){
      NSLog(@"Inconsistency found in Bit Extract constraint.");
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:up andLow:low];
}
@end

@implementation CPBitConcat
-(id) initCPBitConcat:(CPBitVarI*) x concat:(CPBitVarI *)y eq:(CPBitVarI *)z
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   unsigned int xWordLength = [_x getWordLength];
   unsigned int yWordLength = [_y getWordLength];
   unsigned int zWordLength = [_z getWordLength];
   
   if (zWordLength < (xWordLength + yWordLength)-1) {
      failNow();
   }

   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
//   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Concat Constraint propagated.");
#endif
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int xWordLength = [_x getWordLength];
   unsigned int yWordLength = [_y getWordLength];
   unsigned int zWordLength = [_z getWordLength];
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* newYLow = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* zUpForX = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* zLowForX = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* zUpForY = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* zLowForY = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* newZLow = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int  upXORlow;
   
   for(int i=0;i<zWordLength;i++){
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
   }
   
   for(int i=0;i<yWordLength;i++){
      zUpForY[i] = zUp[i]._val;
      zLowForY[i] = zLow[i]._val;
   }
   uint32 mask = CP_UMASK;
   mask >>= 32 - ([_y bitLength]%32);
   zUpForY[yWordLength-1] &= mask;
   zLowForY[yWordLength-1] &= mask;
   
   int xWordShift = ([_y bitLength]/32);

   int xBitShift = ([_y bitLength]%32);
   for(int i=0;i<xWordLength;i++){
      zUpForX[i] = zUp[i+xWordShift]._val>>xBitShift;
      zLowForX[i] = zLow[i+xWordShift]._val>>xBitShift;
      if (xBitShift!=0 && ((i+1) < xWordLength)) {
         zUpForX[i] &= zUp[i+xWordShift+1]._val << (32 - xBitShift);
         zLowForX[i] |= zLow[i+xWordShift+1]._val << (32 - xBitShift);
      }
   }
   mask = CP_UMASK;
   mask >>= 32 - [_x bitLength]%32;
   zUpForX[xWordLength-1] &= mask;
   zLowForX[xWordLength-1] &= mask;
   
   for(int i=0;i<xWordLength;i++){
      newXUp[i] = xUp[i]._val & zUpForX[i];
      newXLow[i] = xLow[i]._val | zLowForX[i];
      upXORlow = newXUp[i] ^ newXLow[i];
      if(((upXORlow & (~newXUp[i])) & (upXORlow & newXLow[i])) != 0){
         failNow();
      }
   }



   for(int i=0;i<yWordLength;i++){
      newYUp[i] = yUp[i]._val & zUpForY[i];
      newYLow[i] = yLow[i]._val | zLowForY[i];
      upXORlow = newXUp[i] ^ newXLow[i];
      if(((upXORlow & (~newYUp[i])) & (upXORlow & newYLow[i])) != 0){
         failNow();
      }
   }
   mask = CP_UMASK;
   mask >>= 32 - xBitShift;
   for(int i=0;i<yWordLength;i++){
      newZUp[i] &= (yUp[i]._val & mask) | ~mask;
      newZLow[i] |= (yLow[i]._val & mask);
   }
   
   mask = CP_UMASK;
   mask = (CP_UMASK >> (32 - [_x bitLength])) << xBitShift;
//   newZUp[yWordLength-1] &= mask;
//   newZLow[yWordLength-1] &= mask;
   
//fix for bv not on 32 bit boundary
   for(int i=0;i<xWordLength;i++){
      newZUp[i+xWordShift] &= ((xUp[i]._val<<xBitShift) & mask) | ~mask;//>>xBitShift;
      newZLow[i+xWordShift] |= (xLow[i]._val<<xBitShift) & mask;//>>xBitShift;
      if (xBitShift!=0 && ((i+1) < xWordLength)) {
         newZUp[i+xWordShift] &= newXUp[i+1] << (32 - xBitShift);
         newZLow[i+xWordShift] |= newXLow[i+1] << (32 - xBitShift);
      }
   }

   NSLog(@"%@\n",bitvar2NSString(newZLow, newZUp, zWordLength));
   for(int i=0;i<zWordLength;i++){
      upXORlow = newZUp[i] ^ newZLow[i];
      if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0){
         failNow();
      }
   }
   
   [_x setUp:newXUp andLow:newXLow];
   [_y setUp:newYUp andLow:newYLow];
   [_z setUp:newZUp andLow:newZLow];
}
@end

@implementation CPBitLT
-(id) initCPBitLT:(CPBitVarI *)x LT:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
//   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit < Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   unsigned int zWordLength = [_z getWordLength];
   unsigned int zBitLength = [_z bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int* zero = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* one = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp;
   unsigned int* newZLow;
//   unsigned int  upXORlow;
   
   
   for (int i = 0; i<[_z getWordLength]; i++) {
      zero[i] = one[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   
   ORUInt mask = CP_UMASK;
   mask >>= zBitLength % BITSPERWORD;
   one[zWordLength] &=mask;
   
   ORBool zFixed = false;
   for(int i = wordLength - 1; i >= 0; i--){
      
      ORUInt setBitsInX = ~(xUp[i]._val ^ xLow[i]._val);
      ORUInt setBitsInY = ~(yUp[i]._val ^ yLow[i]._val);
      
      ORUInt setUpInX = setBitsInX & xLow[i]._val;
      ORUInt setUpInY = setBitsInY & yLow[i]._val;
      
      
      if (__builtin_clz(setUpInX) < __builtin_clz(yUp[i]._val)) {
         newZUp = newZLow = one;
         zFixed = true;
         break;
      }
      
      if (__builtin_clz(setUpInY) < __builtin_clz(xUp[i]._val)) {
         newZUp = newZLow = zero;
         zFixed = true;
         break;
      }
      
   }
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"   <  Y =%@",_y);
   NSLog(@"   =  Z =%@\n\n",_z);
#endif
   if(zFixed)
      [_z setUp:newZUp andLow:newZLow];
}
@end

@implementation CPBitLE
-(id) initCPBitLE:(CPBitVarI *)x LE:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
//   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit <= Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   unsigned int zWordLength = [_z getWordLength];
   unsigned int zBitLength = [_z bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int* zero = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* one = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp;
   unsigned int* newZLow;
   //   unsigned int  upXORlow;
   
   
   for (int i = 0; i<[_z getWordLength]; i++) {
      zero[i] = one[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   
   ORUInt mask = CP_UMASK;
   mask >>= zBitLength % BITSPERWORD;
   one[zWordLength] &=mask;
   
   ORBool xyFixed = true;
   ORBool xyEqual = true;
   ORBool zFixed = false;
   
   
   for (int i=0; i<wordLength; i++) {
      if (!((xUp[i]._val == xLow[i]._val) && (yUp[i]._val == yLow[i]._val))){
         xyFixed = false;
      }
      if(!((xUp[i]._val == yUp[i]._val)&& (xLow[i]._val == yLow[i]._val)))
         xyEqual = false;
   }
   if (xyFixed && xyEqual) {
      [_z setUp:one andLow:one];
      return;
   }
   for(int i = wordLength - 1; i >= 0; i--){
      
      ORUInt setBitsInX = ~(xUp[i]._val ^ xLow[i]._val);
      ORUInt setBitsInY = ~(yUp[i]._val ^ yLow[i]._val);
      
      ORUInt setUpInX = setBitsInX & xLow[i]._val;
      ORUInt setUpInY = setBitsInY & yLow[i]._val;
      
      
      if (__builtin_clz(setUpInX) < __builtin_clz(yUp[i]._val)) {
         newZUp = newZLow = one;
         zFixed = true;
         break;
      }
      
      if (__builtin_clz(setUpInY) < __builtin_clz(xUp[i]._val)) {
         newZUp = newZLow = zero;
         zFixed = true;
         break;
      }
      
   }
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"   <  Y =%@",_y);
   NSLog(@"   =  Z =%@\n\n",_z);
#endif
   if(zFixed)
      [_z setUp:newZUp andLow:newZLow];
}
@end

@implementation CPBitITE
-(id) initCPBitITE:(CPBitVarI *)i then:(CPBitVarI *)t else:(CPBitVarI *)e result:(CPBitVarI*)r{
   self = [super initCPCoreConstraint:[i engine]];
   _i = i;
   _t = t;
   _e = e;
   _r = r;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_i bound])
      [_i whenChangePropagate: self];
   if (![_t bound])
      [_t whenChangePropagate: self];
   if (![_e bound])
      [_e whenChangePropagate: self];
   if (![_r bound])
      [_r whenChangePropagate: self];
//   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit If-Then-Else Constraint propagated.");
#endif
   
   unsigned int wordLength = [_t getWordLength];
   
   TRUInt* iLow;
   TRUInt* iUp;
   TRUInt* tLow;
   TRUInt* tUp;
   TRUInt* eLow;
   TRUInt* eUp;
   TRUInt* rLow;
   TRUInt* rUp;
   
   [_i getUp:&iUp andLow:&iLow];
   [_t getUp:&tUp andLow:&tLow];
   [_e getUp:&eUp andLow:&eLow];
   [_r getUp:&rUp andLow:&rLow];
   
   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
   unsigned int  upXORlow;
   
//   ORUInt tXORe = 0;
   
   unsigned int setbits = 0;
   for (int i=0; i<wordLength; i++) {
      setbits += __builtin_popcount(iLow[i]._val);
   }
   
   if (setbits > 0) {
      for(int i=0;i<wordLength;i++){
         up[i] = tUp[i]._val & rUp[i]._val;
         low[i] = tLow[i]._val | rLow[i]._val;
         upXORlow = up[i] ^ low[i];
         if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0)
            failNow();
      }
      
      [_t setUp:up andLow:low];
      [_r setUp:up andLow:low];
      return;
   }
   else if ([_i bound]) {
      for(int i=0;i<wordLength;i++){
         up[i] = eUp[i]._val & rUp[i]._val;
         low[i] = eLow[i]._val | rLow[i]._val;
         upXORlow = up[i] ^ low[i];
         if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
            failNow();
         }
      }
      
      [_e setUp:up andLow:low];
      [_r setUp:up andLow:low];
      return;
   }
   
//   if ([_i bound] && [_r bound]) {
//      
//      setbits = 0;
//      for (int i=0; i<wordLength; i++)
//         setbits += __builtin_popcount(iLow[i]._val);
//      if (setbits==0)
//         failNow();
//      
//   }
   //if then and else are the same (if condition is irrelevant)
//   if ([_t bound] && [_e bound]) {
//      
//   }
   
   //if _r is bound
   if ([_r bound]) {
      ORUInt rNEQt = 0;
      ORUInt rNEQe = 0;
      for (int i=0; i<wordLength; i++) {
         rNEQt |= (tLow[i]._val & ~rUp[i]._val);// ^ xLow[i]._val;
         rNEQt |= (~tUp[i]._val & rLow[i]._val);// ^ ~xUp[i]._val;
         rNEQe |= (eLow[i]._val & ~rUp[i]._val);// ^ xLow[i]._val;
         rNEQe |= (~eUp[i]._val & rLow[i]._val);// ^ ~xUp[i]._val;
      }
   // if (_r == _t) && (_r != _e) && (_i is bound)
      if (!rNEQt && rNEQe) {
         for (int i=0; i<wordLength; i++)
            setbits += __builtin_popcount(iLow[i]._val);
         //    if countbits in i is zero
         //       fail
         if ([_i bound] && setbits==0)
            failNow();
         ORUInt trueVector[wordLength];
         for (int i=1; i<wordLength; i++) {
            trueVector[i] = 0;
         }
         trueVector[0] = 1;
         [_i setUp:trueVector andLow:trueVector];
      }
   // else if (_r == _e) && (_r != _t)
      else if (!rNEQe) {
         for (int i=0; i<wordLength; i++)
            setbits += __builtin_popcount(iLow[i]._val);
         //    if countbits in i is > zero
         //       fail
         if (setbits>0)
            failNow();
         ORUInt zeroVector[wordLength];
         if(![_i bound]){
            for (int i=0; i<wordLength; i++) {
               zeroVector[i] = 0;
            }
            [_i setUp:zeroVector andLow:zeroVector];
         }
      }
   }
   
//   if ([_t bound] && [_e bound]) {
//      for(int i=0;i<wordLength;i++)
//         tXORe |= tLow[i]._val ^ eLow[i]._val;
//      if (tXORe == 0) {
//         for(int i=0;i<wordLength;i++){
//            up[i] = eUp[i]._val;
//            low[i] = eLow[i]._val;
//            upXORlow = up[i] ^ low[i];
//            if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
//               failNow();
//            }
//         }
//         
//         [_r setUp:up andLow:low];
//      }
//   }

   return;
}
@end

@implementation CPBitLogicalEqual
-(id) initCPBitLogicalEqual:(CPBitVarI *)x EQ:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
//   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit BitLogicalEqual Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   unsigned int zWordLength = [_z getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   unsigned int one[zWordLength];
   unsigned int zero[zWordLength];
   for (int i=1; i<zWordLength; i++) {
      one[i] = zero[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   zero[0] = 0x00000000;
   
   unsigned int* newZUp = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* newZLow = alloca(sizeof(unsigned int)*zWordLength);

   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
   unsigned int  upXORlow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int different = 0;
   unsigned int makesame = 0;
   for (int i=0; i<wordLength; i++) {
      different |= (xLow[i]._val & ~yUp[i]._val);// ^ xLow[i]._val;
      different |= (~xUp[i]._val & yLow[i]._val);// ^ ~xUp[i]._val;
   }
   
   for (int i=0; i<[_z getWordLength]; i++) {
      makesame |= zLow[i]._val;
   }
   
   if(makesame){
      for(int i=0;i<wordLength;i++){
         up[i] = xUp[i]._val & yUp[i]._val;
         low[i] = xLow[i]._val | yLow[i]._val;
         upXORlow = up[i] ^ low[i];
         if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
            failNow();
         }
      }
      
      [_x setUp:up andLow:low];
      [_y setUp:up andLow:low];
   }

   if (different) {
      for (int i=0; i<zWordLength; i++) {
         newZUp[i] = zUp[i]._val & zero[i];
         newZLow[i] = zLow[i]._val | zero[i];
         upXORlow = newZUp[i] ^ newZLow[i];
         if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0)
            failNow();
      }
      [_z setUp:newZUp andLow:newZLow];
   }
   else if ([_x bound] && [_y bound]){
      //LSB should be 1
      newZUp[0] = zUp[0]._val & one[0];
      newZLow[0] = zLow[0]._val | one[0];
      upXORlow = newZUp[0] ^ newZLow[0];
      if(((upXORlow & (~newZUp[0])) & (upXORlow & newZLow[0])) != 0)
         failNow();

      //check the rest of the words in the bitvector if present
      for (int i=1; i<zWordLength; i++) {
         newZUp[i] = zUp[i]._val & zero[i];
         newZLow[i] = zLow[i]._val | zero[i];
         upXORlow = newZUp[i] ^ newZLow[i];
         if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0)
            failNow();
      }
      [_z setUp:newZUp andLow:newZLow];
   }
   return;
}
@end

@implementation CPBitLogicalAnd

-(id) initCPBitLogicalAnd:(id<CPBitVarArray>) x eval:(CPBitVarI *)r
{
   self = [super initCPCoreConstraint: [x[0] engine]];
   _x = x;
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   for (int i=[_x low]; i<=[_x up]; i++) {
      if (![_x[i] bound])
         [(CPBitVarI*)_x[i] whenChangePropagate: self];
   }
   if (![_r bound]) {
      [_r whenChangePropagate: self];
   }
//   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Logical AND Constraint propagated.");
#endif
   //TODO: If r is bound, should we check if only one bit in all of the x[i]
   //are free and need to be set up or low?
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* rLow;
   TRUInt* rUp;
   unsigned int* rup = alloca(sizeof(unsigned int)* [_r getWordLength]);
   unsigned int* rlow = alloca(sizeof(unsigned int)* [_r getWordLength]);

   [_r getUp:&rUp andLow:&rLow];
   
   ORUInt fullbv;
   ORUInt unboundExists = false;

   for (int i=[_x low]; i<=[_x up]; i++) {
      [(CPBitVarI*)_x[i] getUp:&xUp andLow:&xLow];

      if (![_x[i] bound])
         unboundExists = true;

      fullbv = 0;
      for (int j=0; j<[(CPBitVarI*)_x[j] getWordLength]; j++)
         fullbv |= xUp[j]._val;
      
      if (!fullbv) {
         for (int k=0; k<[_r getWordLength]; k++)
            rup[k] = rlow[k] = 0;
            [_r setUp:rup andLow:rlow];
            return;
         }
      }
   if (!unboundExists) {
      for (int k=1; k<[_r getWordLength]; k++)
         rup[k] = rlow[k] = 0;
      rup[0] = rlow[0] = 1;
      [_r setUp:rup andLow:rlow];
      return;
   }
   return;
}
@end

@implementation CPBitLogicalOr

-(id) initCPBitLogicalOr:(id<CPBitVarArray>) x eval:(CPBitVarI *)r
{
   self = [super initCPCoreConstraint: [x[0] engine]];
   _x = x;
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   for (int i=[_x low]; i<=[_x up]; i++) {
      if (![_x[i] bound])
         [(CPBitVarI*)_x[i] whenChangePropagate: self];
   }
   if (![_r bound]) {
      [_r whenChangePropagate: self];
   }
//   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Logical OR Constraint propagated.");
#endif
   //TODO: If r is bound, should we check if only one bit in all of the x[i]
   //are free and need to be set up or low?

   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* rLow;
   TRUInt* rUp;
   unsigned int* rup = alloca(sizeof(unsigned int)* [_r getWordLength]);
   unsigned int* rlow = alloca(sizeof(unsigned int)* [_r getWordLength]);
   
   [_r getUp:&rUp andLow:&rLow];
   
   ORUInt fullbv;
   ORUInt unboundExists = false;
   
   for (int i=[_x low]; i<=[_x up]; i++) {
      [(CPBitVarI*)_x[i] getUp:&xUp andLow:&xLow];
      
      if (![_x[i] bound])
         unboundExists = true;
      
      fullbv = 0;
      for (int j=0; j<[(CPBitVarI*)_x[j] getWordLength]; j++)
         fullbv |= xLow[j]._val;
      
      if (fullbv) {
         for (int k=0; k<[_r getWordLength]; k++)
            rup[k] = rlow[k] = 0x00000001;
         [_r setUp:rup andLow:rlow];
         return;
      }
   }
   if (!unboundExists) {
      for (int k=0; k<[_r getWordLength]; k++)
         rup[k] = rlow[k] = 0;
         [_r setUp:rup andLow:rlow];
         return;
   }
   return;
}
@end
