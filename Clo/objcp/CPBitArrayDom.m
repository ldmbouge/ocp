/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPLEngine.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPError.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitMacros.h>
#import <objcp/CPIntVarI.h>
#import "CPBitVarI.h"

#define BITFREE(idx)     ((_low[WORDIDX(idx)]._val ^ _up[WORDIDX(idx)]._val) & ONEAT(idx) & _up[WORDIDX(idx)]._val)
#define SETBITTRUE(idx)   (assignTRUInt(&_low[WORDIDX(idx)],_low[WORDIDX(idx)]._val | ONEAT(idx),_trail))
#define SETBITFALSE(idx)  (assignTRUInt(&_up[WORDIDX(idx)],_up[WORDIDX(idx)]._val & ZEROAT(idx),_trail))

@implementation CPBitArrayDom

-(CPBitArrayDom*)      initWithLength: (int) len withEngine:(id<CPEngine>)engine withTrail:(id<ORTrail>) tr
{
   self = [super init];
   _trail = tr;
   _bitLength = len;
   _freebits = makeTRUInt(tr, len);
   _wordLength = (_bitLength / BITSPERWORD) + ((_bitLength % BITSPERWORD != 0) ? 1: 0);
   _low = malloc(sizeof(TRUInt)*_wordLength);
   _up = malloc(sizeof(TRUInt)*_wordLength);
   _min = malloc(sizeof(TRUInt)*_wordLength);
   _max = malloc(sizeof(TRUInt)*_wordLength);
   _levels = malloc(sizeof(TRUInt)*len);
   
   for(int i=0;i<_wordLength;i++){
      _low[i] = makeTRUInt(tr, 0);
      _up[i]  = makeTRUInt(tr, CP_UMASK);
      _min[i] = makeTRUInt(tr, 0);
      _max[i] = makeTRUInt(tr, CP_UMASK);
   }
   for (int i=0; i<len; i++) {
      _levels[i] = makeTRUInt(tr, -1);
   }
   
   _remValues = [[NSMutableArray alloc] init];
   return self;
}

-(CPBitArrayDom*)initWithBitPat:(int)len withLow:(ORUInt *)low andUp:(ORUInt *)up andEngine:(id<CPEngine>)engine andTrail:(id<ORTrail>) tr
{
    self = [super init];
    _trail = tr;
    _bitLength = len;
    _wordLength = (_bitLength / BITSPERWORD) + ((_bitLength % BITSPERWORD != 0) ? 1: 0);
    _low = malloc(sizeof(TRUInt)*_wordLength);
    _up = malloc(sizeof(TRUInt)*_wordLength);
    _min = malloc(sizeof(TRUInt)*_wordLength);
    _max = malloc(sizeof(TRUInt)*_wordLength);
    _levels = malloc(sizeof(TRUInt)*len);

   //Mask out unused bits - bits are bound to zero
   ORUInt remainingbits = (_bitLength%32 == 0) ? 32 : _bitLength%32;
   ORUInt mask = CP_UMASK;
   mask >>= 32 - remainingbits;
   up[0] &= mask;
   low[0] &= mask;

    for(int i=0;i<_wordLength;i++){
        _low[_wordLength - 1 - i] = makeTRUInt(tr, low[i]);
        _up[_wordLength - 1 - i]  = makeTRUInt(tr, up[i]);
        _min[_wordLength - 1 - i] = makeTRUInt(tr, low[i]);
        _max[_wordLength - 1 - i] = makeTRUInt(tr, up[i]);
    }
   for (int i=0; i<len; i++) {
      _levels[i] = makeTRUInt(tr, -1);
   }
    ORUInt boundBits = 0;
    ORUInt freeBits = 0;
    for (int i=0; i<_wordLength; i++) {
        boundBits = (_low[i]._val ^ _up[i]._val);
        freeBits += __builtin_popcount(boundBits);
    }
   
    _freebits = makeTRUInt(tr, freeBits);

   _remValues = [[NSMutableArray alloc] init];

   return self;
}

-(void) setEngine:(id<CPEngine>)engine
{
   _engine = (id)engine;
}

-(NSString*)    description
{
   NSMutableString* string = [[[NSMutableString alloc] init] autorelease];
   
   [string appendString:[NSString stringWithFormat:@"%p : ",(void*)self]];
   
   int remainingbits = (_bitLength%32 == 0) ? 32 : _bitLength%32;
   ORUInt boundLow = (~ _up[_wordLength-1]._val) & (~_low[_wordLength-1]._val);
   ORUInt boundUp = _up[_wordLength-1]._val & _low[_wordLength-1]._val;
   ORUInt err = ~_up[_wordLength-1]._val & _low[_wordLength-1]._val;
   ORUInt mask = CP_DESC_MASK;

   mask >>= 32 - remainingbits;

   for (int j=0; j<remainingbits; j++){
      if ((mask & boundLow) !=0)
         [string appendString: @"0"];
      else if ((mask & boundUp) !=0)
         [string appendString: @"1"];
      else if ((mask & err) != 0)
         [string appendString: @"X"];
      else
         [string appendString: @"?"];
      mask >>= 1;
   }

   if(_wordLength > 1){
      for(int i=_wordLength-2; i>=0;i--){
      boundLow = (~ _up[i]._val) & (~_low[i]._val);
      boundUp = _up[i]._val & _low[i]._val;
      err = ~_up[i]._val & _low[i]._val;
      mask = CP_DESC_MASK;

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
   }
   return string;
}

-(ORInt) domsize
{
   return _freebits._val;

}
-(ORULong) numPatterns
{
   ORULong dSize = 0x0000000000000001;
   dSize <<= _freebits._val;
   return dSize;
   
}
-(ORBool) bound
{
    return _freebits._val==0;
}
-(ORBounds) bounds
{
   ORBounds b = {(ORInt)[self min],(ORInt)[self max]};
   return b;
}
-(ORStatus) remove:(ORUInt*)val
{
   [_remValues addObject:[NSValue valueWithPointer:val]];
   return ORSuccess;
}

-(ORULong)   min
{
    ORULong minimum = _min[0]._val;
    if(_wordLength > 1)
        minimum = minimum | ((ORULong)_min[1]._val << BITSPERWORD);
    return minimum;
}

-(ORUInt*) minArray
{
    ORUInt* min = malloc(sizeof(ORUInt)*_wordLength);
    for(int i=0;i<_wordLength;i++)
        min[i] = _low[i]._val;
    return min;     
}
-(ORUInt*) sminArray
{
   ORUInt* min = malloc(sizeof(ORUInt)*_wordLength);
   for(int i=0;i<_wordLength;i++)
      min[i] = _low[i]._val;
   ORUInt signMask = 1 << ((_bitLength-1) % BITSPERWORD);
   ORUInt signIsSet = (~(_up[_wordLength-1]._val ^ _low[_wordLength-1]._val)) & signMask;
   if (!signIsSet)
      min[_wordLength-1] |= signMask;
   return min;
}

-(ORUInt*) lowArray
{
   ORUInt* low = malloc(sizeof(ORUInt)*_wordLength);
   for(int i=0;i<_wordLength;i++)
      low[i] = _low[i]._val;
   return low;
}
-(ORUInt*) upArray
{
   ORUInt* up = malloc(sizeof(ORUInt)*_wordLength);
   for(int i=0;i<_wordLength;i++)
      up[i] = _up[i]._val;
   return up;
}

-(ORULong)   max
{
    ORULong maximum = _max[0]._val;
    if(_wordLength > 1)
        maximum = maximum | ((ORULong)_max[1]._val << BITSPERWORD);
    return maximum;
}

-(ORUInt*) maxArray
{
    ORUInt* max = malloc(sizeof(ORUInt)*_wordLength);
    for(int i=0;i<_wordLength;i++)
        max[i] = _up[i]._val;
    return max;     
}

-(ORUInt*) smaxArray
{
   ORUInt* max = malloc(sizeof(ORUInt)*_wordLength);
   for(int i=0;i<_wordLength;i++)
      max[i] = _up[i]._val;
   ORUInt signMask = 1 << ((_bitLength-1) % BITSPERWORD);
   ORUInt signIsSet = (~(_up[_wordLength-1]._val ^ _low[_wordLength-1]._val)) & signMask;
   if (!signIsSet)
      max[_wordLength-1] &= ~signMask;
   return max;
}

-(ORUInt) getLength
{
    return _bitLength;
}

-(ORUInt) getWordLength
{
    return _wordLength;
}

-(ORBool) getBit:(ORUInt) idx
{
   if (BITFREE(idx)) 
      @throw [[ORExecutionError alloc] initORExecutionError: "Trying to 'get' unbound bit in CPBitArrayDom"];
   if (_low[WORDIDX(idx)]._val  & ONEAT(idx))
      return true;
   else
      return false;
}

-(ORStatus) setBit:(ORUInt)idx to:(ORBool) val for:(id<CPBitVarNotifier>)x
{
   if (BITFREE(idx)) {
      if (val){
         SETBITTRUE(idx);
      }
      else {
         SETBITFALSE(idx);
      }
   } else {
      bool theBit = _low[WORDIDX(idx)]._val  & ONEAT(idx);
      if (theBit ^ val)
         failNow();
      else{
         return ORSuspend;
      }
   }

   [self updateFreeBitCount];
   if([_engine conformsToProtocol:@protocol(CPLEngine)]){
      ORUInt level = [(id<CPLEngine>)_engine getLevel];
      assignTRUInt(&(_levels[idx]),level, _trail);
//      NSLog(@"Setting %@[%d] to %i at Level %u",self, idx,val,level);
   }
   [x bitFixedEvt:_freebits._val sender:self];
   //Added _freebits._val when I included bitFixedAtEvt here, not sure it is needed
   [x bitFixedAtEvt:_freebits._val at:idx sender:self];
   return ORSuspend;
}
-(ORBool) isFree:(ORUInt)idx
{
   //NSLog(@"ONEAT for index %d is %x",idx, ONEAT(idx));
   //NSLog(@"BITFREE for index %d is %x",idx, BITFREE(idx));
   return (BITFREE(idx) != 0);
}
-(ORUInt) lsFreeBit
{
   int j;
   //[self updateFreeBitCount];
   //Assumes length is a multiple of 32 bits
   //Should work otherwise if extraneous bits are
   //all the same value in up and low (e.g. 0)
   
   for(int i=0; i<_wordLength; i++){
//      NSLog(@"%d is first free bit in %x\n",i*32+__builtin_ffs((_low[i]._val^_up[i]._val))-1, (_low[i]._val^_up[i]._val));
      if ((j=__builtin_ffs(_low[i]._val^_up[i]._val))!=0) {
         return (i*BITSPERWORD)+j-1;
      }
   }
   return -1;
}
-(ORUInt) msFreeBit
{
   ORUInt freeBits;
   int j;
   //[self updateFreeBitCount];
   //Assumes length is a multiple of 32 bits
   //Should work otherwise if extraneous bits are
   //all the same value in up and low (e.g. 0)
   ORInt wordLengthInBits = _wordLength * BITSPERWORD;
   
   for(int i=_wordLength-1; i>=0; i--){
      //NSLog(@"%d leading zeroes in %x\n",__builtin_clz((_low[i]._val^_up[i]._val)), (_low[i]._val^_up[i]._val));
      freeBits =_low[i]._val^_up[i]._val;
      if (freeBits==0) {
         continue;
      }
      else if (freeBits == 0xFFFFFFFF) {
         int msfb = wordLengthInBits-((i*32)+1);
         return msfb;
      }
      else if (freeBits & 0x80000000) {
//         j=__builtin_clz(~freeBits);
//         int msfb = wordLengthInBits-((i*32)+1);
//         return msfb;
         return (((i+1)*BITSPERWORD)-1);
      }
      else{
         j=__builtin_clz(freeBits);
         //int msfb = (wordLengthInBits)-((i*32)+j+1);
         int msfb = BITSPERWORD-j-1+(i*BITSPERWORD);
         return msfb;
      }
   }
   return -1;
}

-(ORUInt) randomFreeBit
{
   //[self updateFreeBitCount];
#if defined(__linux__)
   int r = random() % _freebits._val;
#else
   int r = arc4random() % _freebits._val;
#endif
   
   ORUInt foundFreeBits =0;
   ORUInt unboundBits;
   ORUInt bitMask;
   
   for(int i=0; i<_wordLength;i++)
   {
      unboundBits = (_low[i]._val ^ _up[i]._val);
      bitMask = 0x00000001;
      for(int j=31;j>=0;j--)
      {
         if (unboundBits & bitMask)
         {
            foundFreeBits++;
            if (foundFreeBits >= r)
               return (i*32+(31-j));
         }
         bitMask <<= 1;
      }
   }
   return -1;
}
-(ORUInt) midFreeBit
{
   ORUInt n;
   ORUInt oldn;
   ORUInt c = 0;
   
   ORUInt numConsecutiveUnboundBits = 0;
   ORUInt lsBitPos = 0;
   
   for (int i=0; i<_wordLength; i++) {
      n =  (_low[i]._val ^ _up[i]._val);
      while (n != 0){
         oldn = n;
         n &= n >> 1;
         c += 1;
      }
      if (c > numConsecutiveUnboundBits) {
         numConsecutiveUnboundBits = c;
         lsBitPos = __builtin_ffs(oldn) - 1;
      }
   }
   return lsBitPos+(numConsecutiveUnboundBits/2);
}

-(void) updateFreeBitCount
{
   ORUInt freeBits = 0;
   for (int i=0; i<_wordLength; i++) {
      ORUInt boundBits = (_low[i]._val ^ _up[i]._val);
      freeBits += __builtin_popcount(boundBits);
   }
   assignTRUInt(&(_freebits), freeBits, _trail);
}
-(ORBool) member:(ORUInt*) val
{
   bool isMember = true;
   bool wasRemoved = false;
   for(int i=0; i<_wordLength;i++){
      if ((val[i] & ~_up[i]._val)!=0)
         isMember = false;;
      if ((~val[i] & _low[i]._val)!=0)
         isMember = false;
   }
   for(int i=0;i<[_remValues count];i++)
   {
      wasRemoved = true;
      for (int j=0; j<_wordLength; j++) {
         if (((ORUInt*)[[_remValues objectAtIndex:i] pointerValue])[j] != val[j]) {
            wasRemoved = false;
            break;
         }
      }
      if (wasRemoved)
         return false;
   }
   return isMember;
}

-(ORULong) getRank: (ORUInt*) val
{
   // [ldm] Algorithm runs in THETA(k) where k is the number of free bits in domain.
   if(_freebits._val > 64)
      @throw[[ORExecutionError alloc] initORExecutionError:"Cannot get rank of a binary array with > 64 bits free.\n"];  
   ORULong rank = 0;
   ORULong rankIndex = 0;   
   for (int index=_wordLength-1;index >= 0;index--) {
      ORUInt unbound = _low[index]._val ^ _up[index]._val; // picks up free bits in word (as a set)
      ORUInt cur  = val[index];                            // bit pattern to analyze
      while (unbound && cur) {                                   // as long as we have free bits and bits @ 1 in val_i
         int bOfs = __builtin_ffs(unbound);                      // pick up offset of LSB among free bits
         unbound >>= bOfs;                                       // skips all fixed bits and the first free bit
         rank |= (cur>>(bOfs-1) & 0x1) << rankIndex++;           // set bit @ 1 in rank if bit is @ 1 in pattern
         cur >>= bOfs;                                           // skip bits in pattern.
      }
   }
   return rank;
}

-(ORUInt*) atRank: (ORULong) rank
{
   // [ldm] Algorithm still has O(|B|) rather than O(k). Must improve and use __builtin_ffs.
   if(_wordLength>2)
      @throw[[ORExecutionError alloc] initORExecutionError:"CPBitArrayDom::atRank does not support bit arrays with length > 64 bits.\n"];    
   ORUInt* bits = malloc(sizeof(ORUInt) * _wordLength);
   memset(bits,0,sizeof(ORUInt)*_wordLength);
   ORInt k = _freebits._val;
   ORUInt idx = 0;
   ORULong rc = rank;
   while(k) {
      ORUInt isFree = BITFREE(idx); // has a 1 at the proper bit position if free(b_idx)
      if (isFree) {
         bits[WORDIDX(idx)] |= (rc & 0x1) ? isFree : 0;     
         rc >>= 1;
         k -= (isFree!=0);   
      }
      ++idx;
   }
   return bits;
}

-(ORUInt) getMaxRank
{
   return (1 << _freebits._val)-1;
}

-(ORUInt) getSize
{
   return (1 << _freebits._val)-1;
}

-(ORUInt*) pred:(ORUInt*)x
{
   /*
    * Idea is simple:
    * 1. get a mask that covers the used bits of x (up to MSB(x)).
    * 2. The fixed bits at 1 are copied into the output (in one instruction)
    * 3. Then the bits of up are copied in the output if and only if the
    *    corresponding bit in (x-1) is at 1. If the bit installed in the output
    *    at a position is lower than the bit in (x-1), we have reduced the
    *    ouput (compared to x) and from now on the remaining bits of up can
    *    all be copied in one shot. If we increased the output bit (again
    *    compared to x), then we know that the MSB(output) should be reset to
    *    0 and all the remaining bits of up should be copied. If the input and
    *    output bits are the same, move to the left one bit toward the LSB and
    *    repeat.
    *
    *    This procedure works whether x is in the domain or not.
    *    The successor can be done in the same way.
    *    cost: O(#bits).
    */
   
   if(_wordLength>2)
      @throw[[ORExecutionError alloc] initORExecutionError:"CPBitArrayDomIterator does not support bit arrays with length > 64 bits.\n"];
   
   ORULong x64bit = x[0] | (_wordLength > 1 ? ((ORULong)x[1] << 32) : 0);
   
   ORUInt* outarray = malloc (sizeof(ORUInt)*_wordLength);
   
   ORUInt* lowa = alloca(sizeof(ORUInt)*_wordLength);
   ORUInt* upa = alloca(sizeof(ORUInt)*_wordLength);
   
   for (int i = 0; i<_wordLength ; i++){
      lowa[i] = _low[i]._val;
      upa[i] = _up[i]._val;
   }
   
   ORULong low = lowa[0] | (_wordLength > 1 ? ((ORULong)lowa[1] << 32) : 0);
   ORULong up = upa[0] | (_wordLength > 1 ? ((ORULong)upa[1] << 32) : 0);
   if (x64bit <= low) {
      for (int i = 0; i<_wordLength ; i++)
         outarray[i] = lowa[i];
      return outarray;
   }
   x64bit -= 1;
   ORULong m = 1, sm=1;
   while (x64bit & ~m){
      m = (m<<1) |1;
      sm <<= 1;
   }
   ORULong mup = up & m;
   ORULong out = low & m;
   ORULong pm = m;
   
   while(sm){
      bool isOne = (x64bit & sm) == sm;
      out   |= isOne ? mup & sm : 0;
      bool decrease = (out & sm) < (x64bit & sm);
      if (decrease){
         out |= (up & pm);
         outarray[0] = out >> 32;
         outarray[1] = (out << 32) >> 32;
         return outarray;
      }
      bool increase = (out & sm) > (x64bit & sm);
      if (increase) {
         // Move up again to drop the Least significant bit that is currently
         // at one in the output but still free.
         sm <<= 1;
         pm = (pm << 1) | 1;
         while(sm) {
            bool isBitFree = (low & sm) != (up & sm);
            bool isBitSet  = (out & sm);
            if (isBitSet && isBitFree) {
               out &= ~sm;
               out |= (up & (pm>>1));
               outarray[0] = out >> 32;
               outarray[1] = (out << 32) >> 32;
               return outarray;
            }
            sm <<= 1;
            pm = (pm << 1) | 1;
         }
      }
      sm >>= 1;
      pm >>= 1;
   }
   outarray[0] = ((ORUInt*)&out)[0];
   outarray[1] = ((ORUInt*)&out)[1];
   return outarray;
}

#define INTERPRETATION(t) ((((ORULong)(t)[1]._val)<<BITSPERWORD) | (t)[0]._val)

-(ORStatus)updateMin:(ORULong)newMin for:(id<CPBitVarNotifier>)x
{
   ORULong oldMin = INTERPRETATION(_low);
   ORULong oldMax = INTERPRETATION(_up);
   int oldDS = _freebits._val;
   int msbIndex = BITSPERWORD - 1;
   while (msbIndex) {
      ORULong curMin = INTERPRETATION(_low);
      ORULong curMax = INTERPRETATION(_up);
      if ((curMax < newMin) || (curMin > oldMax))
         failNow();
      ORULong freeBits = curMin ^ curMax;
      if ((0x1 << msbIndex) & freeBits) {
         if (curMax - (0x1 << msbIndex) < newMin) {
            curMin = curMin | (0x1 << msbIndex);
            ORUInt* pc = (ORUInt*)&curMin;
            assignTRUInt(_low+0,pc[0],_trail);
            assignTRUInt(_low+1,pc[1],_trail);
            assignTRUInt(&_freebits,_freebits._val - 1,_trail);
            [x bitFixedEvt:oldDS sender:self];
         } else if (curMin + (0x1 << msbIndex) > curMax) {
            curMax = curMax & ~(0x1 << msbIndex);
            ORUInt* pc = (ORUInt*)&curMax;
            assignTRUInt(_up+0,pc[0],_trail);
            assignTRUInt(_up+1,pc[1],_trail);
            assignTRUInt(&_freebits,_freebits._val - 1,_trail);
            [x bitFixedEvt:oldDS sender:self];
         } else break;
      }
      msbIndex--;
   }
   [self updateFreeBitCount];

   ORULong finalMin = INTERPRETATION(_low);
   ORULong finalMax = INTERPRETATION(_up);
   if (finalMin > oldMin)
      [x changeMinEvt:oldDS sender:self];
   if (finalMax < oldMax)
      [x changeMaxEvt:oldDS sender:self];
   return ORSuspend;
}

#define TOULONG(v)  ((v)[0]._val | (_wordLength > 1 ? ((ORULong)(v)[1]._val << 32) : 0))


-(ORStatus)updateMax:(ORULong)newMax for:(id<CPBitVarNotifier>)x
{
   ORULong originalMax = TOULONG(_max);
   ORULong min = TOULONG(_min);
   ORULong newMax64 = newMax;
    if(newMax64 >= originalMax)
        return ORSuspend;
   ORUInt* ptrMax = (ORUInt*)&newMax;

    assignTRUInt(&_max[0], ptrMax[0], _trail);
    if(_wordLength > 1)
        assignTRUInt(&_max[1], ptrMax[1], _trail);
    
    if(newMax64 < min)
        failNow();
    
    if (![self member:ptrMax]){
        ORUInt* pred = [self pred:ptrMax];
        assignTRUInt(&_max[0], pred[0], _trail);
        if(_wordLength > 1)
            assignTRUInt(&_max[1], pred[1], _trail);
        free(pred);
    }
    newMax64 = TOULONG(_max);
    ORULong newUp = 1;
    ORULong mask = 1;
    int bit = 0;
    
    while(newMax64) {
        newMax64 >>= 1;
        newUp = (newUp << 1) | 0x1;
        mask <<= 1;
        ++bit;            // bit goes up with mask (counting the bits).
    }
    newUp >>= 1;         // This should not have any bits set in the high 32
    mask >>= 1;
    --bit;              // keep bit in synch with mask.
    // ======================================================================
    // newUp is a mask with all the low signicant bits at 1, e.g.,
    // MSB               LSB 
    // 000000000000000100011: value 35
    // 000000000000000111111: newUp mask
    // 000000000000000100000: mask          (MSB of _max set to 1)
    // ======================================================================
    // This loops counts the number of bits in the "high" part of up that 
    // will be reset to 0.
    // inc is the masked high part of _up. Bring it down to 0 and count the 1 bits
    // 111111111111111000000: INC          (negated newUp)
    // Since _max is guaranteed to be >= _min, I can't have bits in _low that are set to 1
    // and the corresponding bit in the target part of up be 0. The bits can be reset all
    // at once. The loop is merely meant to count the number of zapped bits. 
    ORULong low = TOULONG(_low);
    ORULong up = TOULONG(_up);
   
    ORULong inc = ~newUp & up;
    int bith = 0;
    while(inc) {
        if (inc & 0x1) 
            [self  setBit:bith to: false for:x];          // Indicate that this specific bit was reset to 0.
        inc >>= 1;
        ++bith;
    }
    // ======================================================================
    // Next phase, force some bits in the up part masked by newUp to 0 if we can
    // be sure that this specific bit can never be set to 1.   
    ORULong atLeast = low;
    newMax64 = TOULONG(_max);
    mask = 0x8000000000000000;
    bit = [self getLength] - 1;
    while(atLeast <= min && mask) {
        const bool isFreeBit = [self isFree:bit];
        if (isFreeBit) {
            if (atLeast + mask > newMax64) { 	
               [self setBit:bit to:false for:x];
            } else {
                if (atLeast + mask <= min) {
                   [self setBit:bit to:true for:x];
                    atLeast += mask;
                } else break;
            }
        }
        mask >>= 1;
        --bit;
    }
    ORULong finalUp = TOULONG(_up);
    ORULong  finalMax = TOULONG(_max);
    if(finalUp < finalMax){
       ORUInt* pc = (ORUInt*)&finalUp;
       assignTRUInt(&_max[0],pc[0], _trail);
       if (_wordLength == 1)
          assignTRUInt(&_max[1], pc[1], _trail);
       finalMax = finalUp;
    }
    if (newMax64 < originalMax)
        [x changeMaxEvt:pow(2,_freebits._val) sender:self];

   newMax64 = TOULONG(_max);
   if (min > newMax64)
      failNow();
   return ORSuspend;
}

-(ORStatus)bind:(ORULong)val for:(id<CPBitVarNotifier>)x
{
   // [LDM]. This is buggy  Some bits might already be set in low/up and *incompatible* with the
   // mass setting done here. In this case it should *FAIL*.
   if ((val < [self min]) || (val > [self max]))
      failNow();
   if ((_freebits._val == 0) && (val == [self min])) return ORSuccess;
   ORUInt* pc = (ORUInt*)&val;
   //Deal with arrays < 64 bits long
   assignTRUInt(&_min[1], pc[1], _trail);
   assignTRUInt(&_max[1], pc[1], _trail);
   assignTRUInt(&_low[1], pc[1], _trail);
   assignTRUInt(&_up[1], pc[1], _trail);
   assignTRUInt(&_min[0], pc[0], _trail);
   assignTRUInt(&_max[0], pc[0], _trail);
   assignTRUInt(&_low[0], pc[0], _trail);
   assignTRUInt(&_up[0], pc[0], _trail);
   assignTRUInt(&_freebits, 0, _trail);
   [x bindEvt:1 sender:self];
   return ORSuspend;
}

-(ORStatus) bindToPat:(ORUInt*) pat for:(id<CPBitVarNotifier>)x
{
   ORULong  val = (((ORULong)pat[1]) << BITSPERWORD) | pat[0];
   if (val < [self min] || val > [self max])
      failNow();
   if (_freebits._val == 0 && val == [self min]) 
      return ORSuccess;

   assignTRUInt(&_min[0], pat[0], _trail);
   assignTRUInt(&_max[0], pat[0], _trail);
   assignTRUInt(&_min[1], pat[1], _trail);
   assignTRUInt(&_max[1], pat[1], _trail);
   
   [self updateMin:val for:x];
   [self updateMax:val for:x];

   assignTRUInt(&_freebits, 0, _trail);
   [x bindEvt:1 sender:self];
   [self updateFreeBitCount];
   return ORSuspend;   
}


- (void)dealloc
{
    free(_low);
    free(_up);
    [super dealloc];
}

-(TRUInt*) getLow 
{
    return _low;
}

-(TRUInt*) getUp 
{
    return _up;
}

-(void) getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow
{
   *currUp = _up;
   *currLow = _low;
}


-(void) setLow: (ORUInt*) newLow for:(id<CPBitVarNotifier>)x
{
   bool lmod =  false;
   ORUInt* isChanged = alloca(sizeof(ORUInt)*_wordLength);

   for(int i=0;i<_wordLength;i++){
      isChanged[i] |= (_low[i]._val & ~newLow[i]);
      lmod |= _low[i]._val != newLow[i];
      assignTRUInt(&_low[i], newLow[i], _trail);
   }
    [self updateFreeBitCount];
   if (lmod){
       [x bitFixedEvt:_freebits._val sender:self];

      //Update Min for bitvector
      ORULong lowInterpretation = TOULONG(_low);
      ORULong currentMin = TOULONG(_min);
      if(lowInterpretation > currentMin){
         ORUInt* pc = (ORUInt*)&lowInterpretation;
         assignTRUInt(&_min[0], pc[0], _trail);
         if (_wordLength>1)
            assignTRUInt(&_min[1], pc[1], _trail);
         [x changeMinEvt:[self domsize] sender:self];
      }

      for (int i=0; i<_wordLength; i++) {
         for (int j=0; j<BITSPERWORD; j++) {
            if (isChanged[i] & 0x00000001) {
               if([_engine conformsToProtocol:@protocol(CPLEngine)])
                  assignTRUInt(&_levels[(i*BITSPERWORD)+j], [(id<CPLEngine>)_engine getLevel], _trail);
               [x bitFixedAtEvt:(i*BITSPERWORD)+j sender:self];
            }
            isChanged[i] >>= 1;
         }
      }
   }
}

-(void) setUp: (ORUInt*) newUp  for:(id<CPBitVarNotifier>)x
{
   bool umod = false;
   ORUInt* isChanged = alloca(sizeof(ORUInt)*_wordLength);
   
   for(int i=0;i<_wordLength;i++){
      isChanged[i]  = (_up[i]._val & ~newUp[i]);
      umod |= _up[i]._val != newUp[i];
      assignTRUInt(&_up[i], newUp[i], _trail);
   }
   [self updateFreeBitCount];
   
   if (umod){
      [x bitFixedEvt:_freebits._val sender:self];
      //Update Max for bitvector
      ORULong upInterpretation = TOULONG(_up);
      ORULong currentMax = TOULONG(_max);
      if(upInterpretation < currentMax){
         ORUInt* pc = (ORUInt*)&upInterpretation;
         assignTRUInt(&_max[0], pc[0], _trail);
         if (_wordLength>1)
            assignTRUInt(&_max[1], pc[1], _trail);
         [x changeMaxEvt:[self domsize] sender:self];
      }
      //record level new bits were set at
      for (int i=0; i<_wordLength; i++) {
         for (int j=0; j<BITSPERWORD; j++) {
            if (isChanged[i] & 0x00000001) {
               [x bitFixedAtEvt:_freebits._val at:(i*BITSPERWORD)+j sender:self];
               assignTRUInt(&_levels[i*BITSPERWORD+j],[(id<CPLEngine>)_engine getLevel],_trail);
            }
            isChanged[i] >>= 1;
         }
      }
   }
}

-(void) setUp: (ORUInt*) newUp andLow:(ORUInt*)newLow for:(id<CPBitVarNotifier>)x
{
   ORUInt umod = false;
   ORUInt lmod = false;
   ORUInt* isChanged = alloca(sizeof(ORUInt)*_wordLength);
   for(int i=0;i<_wordLength;i++){
      isChanged[i]  = (_up[i]._val ^ newUp[i]);
      isChanged[i] |= (_low[i]._val ^ newLow[i]);
      umod |= _up[i]._val != newUp[i];
      assignTRUInt(&_up[i], newUp[i], _trail);
      lmod |= _low[i]._val != newLow[i];
      assignTRUInt(&_low[i], newLow[i], _trail);
   }
   [self updateFreeBitCount];
   if (umod || lmod){
      [x bitFixedEvt:_freebits._val sender:self];
      ORULong upInterpretation = TOULONG(_up);
      ORULong lowInterpretation = TOULONG(_low);
      ORULong currentMax = TOULONG(_max);
      ORULong currentMin = TOULONG(_min);
      if(upInterpretation < currentMax){
         ORUInt* pc = (ORUInt*)&upInterpretation;
         assignTRUInt(&_max[0], pc[0], _trail);
         if (_wordLength>1)
            assignTRUInt(&_max[1], pc[1], _trail);
         [x changeMaxEvt:[self domsize] sender:self];         // This currently assumes that min/max are 32-bit wide. Some APIs are ORLong, so not consistent
      }
      if(lowInterpretation > currentMin){
         ORUInt* pc = (ORUInt*)&lowInterpretation;
         assignTRUInt(&_min[0], pc[0], _trail);
         if (_wordLength>1)
            assignTRUInt(&_min[1], pc[1], _trail);
         [x changeMinEvt:[self domsize] sender:self];         // ditto, see above.
      }

      for (int i=0; i<_wordLength; i++) {
         for (int j=0; j<BITSPERWORD; j++) {
            if (isChanged[i] & 0x00000001) {
               [x bitFixedAtEvt:_freebits._val at:(i*BITSPERWORD)+j sender:self];
               if([_engine conformsToProtocol:@protocol(CPLEngine)])
                  assignTRUInt(&_levels[(i*BITSPERWORD)+j], [(CPLearningEngineI*)_engine getLevel], _trail);
            }
            isChanged[i] >>= 1;
         }
      }
   }
}

-(void)enumerateWith:(void(^)(ORUInt*,ORInt))body
{
   ORUInt sz = [self getSize];
   ORUInt* bits = alloca(sizeof(ORUInt)*_wordLength);
   for(ORUInt rank=0;rank < sz;rank++) {
      memset(bits,0,sizeof(ORUInt)*_wordLength);
      ORInt k = _freebits._val;
      ORUInt idx = 0;
      ORUInt rc = rank;
      while(k) {
         ORUInt isFree = BITFREE(idx); // has a 1 at the proper bit position if free(b_idx)
         if (isFree) {
            bits[WORDIDX(idx)] |= (rc & 0x1) ? isFree : 0;     
            rc >>= 1;
            k -= (isFree!=0);   
         }
         ++idx;
      }
      body(bits,rank);
   }
}


-(void)restoreDomain:(CPBitArrayDom*)toRestore
{
//   [self setLow:[toRestore lowArray]];
//   [self setUp:[toRestore upArray]];
   //update min/max????
}
-(void)restoreValue:(ORInt)toRestore
{
//   _min._val = toRestore;
//   _max._val = toRestore;
//   _sz._val  = 1;
}
-(ORUInt) getLevelForBit:(ORUInt)bit{
   return _levels[bit]._val;
}

-(id) copyWithZone:(NSZone*) zone{
   CPBitArrayDom* copy = [[CPBitArrayDom alloc] initWithBitPat:_bitLength withLow:&_low->_val andUp:&_up->_val andEngine:_engine andTrail:_trail];
   [copy setEngine:_engine];
   return copy;
}
@end

