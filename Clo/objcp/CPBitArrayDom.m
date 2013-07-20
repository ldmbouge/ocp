/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBitArrayDom.h"
#import "CPError.h"
#import "CPBitVar.h"
#import "CPBitVarI.h"
#import "CPBitMacros.h"
#import "CPIntVarI.h"

#define BITFREE(idx)     ((_low[WORDIDX(idx)]._val ^ _up[WORDIDX(idx)]._val) & ONEAT(idx))
#define SETBITTRUE(idx)   (assignTRUInt(&_low[WORDIDX(idx)],_low[WORDIDX(idx)]._val | ONEAT(idx),_trail))
#define SETBITFALSE(idx)  (assignTRUInt(&_up[WORDIDX(idx)],_up[WORDIDX(idx)]._val & ZEROAT(idx),_trail))

@implementation CPBitArrayDom

-(CPBitArrayDom*)      initWithLength: (int) len withTrail:(id<ORTrail>) tr
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
   
   for(int i=0;i<_wordLength;i++){
      _low[i] = makeTRUInt(tr, 0);
      _up[i]  = makeTRUInt(tr, CP_UMASK);
      _min[i] = makeTRUInt(tr, 0);
      _max[i] = makeTRUInt(tr, CP_UMASK);      
   }
   return self;
}

-(CPBitArrayDom*)initWithBitPat:(int)len withLow:(unsigned int *)low andUp:(unsigned int *)up andTrail:(id<ORTrail>) tr
{
    self = [super init];
    _trail = tr;
    _bitLength = len;
    _wordLength = (_bitLength / BITSPERWORD) + ((_bitLength % BITSPERWORD != 0) ? 1: 0);
    _low = malloc(sizeof(TRUInt)*_wordLength);
    _up = malloc(sizeof(TRUInt)*_wordLength);
    _min = malloc(sizeof(TRUInt)*_wordLength);
    _max = malloc(sizeof(TRUInt)*_wordLength);
    
    for(int i=0;i<_wordLength;i++){
        _low[i] = makeTRUInt(tr, low[i]);
        _up[i]  = makeTRUInt(tr, up[i]);
        _min[i] = makeTRUInt(tr, low[i]);
        _max[i] = makeTRUInt(tr, up[i]);        
    }
    unsigned int boundBits = 0;
    unsigned int freeBits = 0;
    for (int i=0; i<_wordLength; i++) {
        boundBits = (_low[i]._val ^ _up[i]._val);
        freeBits += __builtin_popcount(boundBits);
    }
   
   //Shouldn't
    _freebits = makeTRUInt(tr, freeBits);
    return self;
}

-(NSString*)    description
{
   NSMutableString* string = [[[NSMutableString alloc] init] autorelease];
   for(int i=0; i< _wordLength;i++){
      unsigned int boundLow = (~ _up[i]._val) & (~_low[i]._val);
      unsigned int boundUp = _up[i]._val & _low[i]._val;
      unsigned int err = ~_up[i]._val & _low[i]._val;
      unsigned int mask = CP_DESC_MASK;
      if (i<_wordLength-1)
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
      else{
         int remainingbits = (_bitLength%32 == 0) ? 32 : _bitLength%32;            
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
      }
   }
   return string;
}
-(ORInt) domsize
{
   [self updateFreeBitCount];
   return _freebits._val;
   //return pow(2.0, _freebits._val);
   //return 1 << _freebits._val;
}
-(ORBool) bound
{
   [self updateFreeBitCount];
    return _freebits._val==0;
}

-(uint64)   min
{
    uint64 minimum;
    
    minimum = _min[0]._val;
    if(_wordLength > 1){
        minimum <<= 32;
        minimum += _min[1]._val;
    }
    return minimum;
}

-(unsigned int*) minArray
{
    unsigned int* min = malloc(sizeof(unsigned int)*_wordLength);
    for(int i=0;i<_wordLength;i++)
        min[i] = _min[i]._val;
    return min;     
}


-(unsigned int*) lowArray
{
   unsigned int* low = malloc(sizeof(unsigned int)*_wordLength);
   for(int i=0;i<_wordLength;i++)
      low[i] = _low[i]._val;
   return low;
}
-(unsigned int*) upArray
{
   unsigned int* up = malloc(sizeof(unsigned int)*_wordLength);
   for(int i=0;i<_wordLength;i++)
      up[i] = _up[i]._val;
   return up;
}



-(uint64)   max
{
    uint64 maximum;
    
    maximum = _max[0]._val;
    if(_wordLength > 1){
        maximum <<= 32;
        maximum += _max[1]._val;
    }
    return maximum;
}

-(unsigned int*) maxArray
{
    unsigned int* max = malloc(sizeof(unsigned int)*_wordLength);
    for(int i=0;i<_wordLength;i++)
        max[i] = _max[i]._val;
    return max;     
}

-(unsigned int) getLength
{
    return _bitLength;
}

-(unsigned int) getWordLength
{
    return _wordLength;
}

-(ORBool) getBit:(unsigned int) idx
{
   if (BITFREE(idx)) 
      @throw [[ORExecutionError alloc] initORExecutionError: "Trying to 'get' unbound bit in CPBitArrayDom"];
   return _low[WORDIDX(idx)]._val  & ONEAT(idx);
}

-(ORStatus) setBit:(unsigned int) idx to:(ORBool) val for:(id<CPBitVarNotifier>)x
{
   if (BITFREE(idx)) {
      if (val)
         SETBITTRUE(idx);
      else SETBITFALSE(idx);
   } else {
      bool theBit = _low[WORDIDX(idx)]._val  & ONEAT(idx);
      if (theBit ^ val)
         failNow();
   }
   [self updateFreeBitCount];
   [x bitFixedEvt:_freebits._val sender:self];
   return ORSuspend;
}
-(ORBool) isFree:(unsigned int)idx
{
   return BITFREE(idx);
}
-(unsigned int) lsFreeBit
{
   int j;
   [self updateFreeBitCount];
   //Assumes length is a multiple of 32 bits
   //Should work otherwise if extraneous bits are
   //all the same value in up and low (e.g. 0)
   
   for(int i=_wordLength-1; i>=0; i--){
//      NSLog(@"%d is first free bit in %x\n",i*32+__builtin_ffs((_low[i]._val^_up[i]._val))-1, (_low[i]._val^_up[i]._val));
      if ((j=__builtin_ffs(_low[i]._val^_up[i]._val))!=0) {
         return (i*32)+j-1;
      }
   }
   return -1;
}

-(unsigned int) randomFreeBit
{
   [self updateFreeBitCount];
   int r = random() % _freebits._val;
   unsigned int foundFreeBits =0;
   unsigned int boundBits;
   unsigned int bitMask;
   
   for(int i=_wordLength; i>=0;i--)
   {
      boundBits = (_low[i]._val ^ _up[i]._val);
      bitMask = 1;
      for(int j=31;j>=0;j--)
      {
         if (boundBits & bitMask)
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

-(void) updateFreeBitCount
{
   unsigned int freeBits = 0;
   for (int i=0; i<_wordLength; i++) {
      unsigned int boundBits = (_low[i]._val ^ _up[i]._val);
      freeBits += __builtin_popcount(boundBits);
   }
//   NSLog(@"Bit pattern:%@",[self description]);
//   NSLog(@"%d free bits\n", freeBits);
   assignTRUInt(&(_freebits), freeBits, _trail);
}
-(ORBool) member:(unsigned int*) val
{
   for(int i=0; i<_wordLength;i++){
      if ((val[i] & ~_up[i]._val)!=0)
         return false;
      if ((~val[i] & _low[i]._val)!=0)
         return false;
   }
   return true;
}

-(unsigned long long) getRank: (unsigned int*) val
{
   // [ldm] Algorithm runs in THETA(k) where k is the number of free bits in domain.
   if(_freebits._val > 64)
      @throw[[ORExecutionError alloc] initORExecutionError:"Cannot get rank of a binary array with > 64 bits free.\n"];  
   unsigned long long rank = 0;
   unsigned long long rankIndex = 0;   
   for (int index=_wordLength-1;index >= 0;index--) {
      unsigned int unbound = _low[index]._val ^ _up[index]._val; // picks up free bits in word (as a set)
      unsigned int cur  = val[index];                            // bit pattern to analyze
      while (unbound && cur) {                                   // as long as we have free bits and bits @ 1 in val_i
         int bOfs = __builtin_ffs(unbound);                      // pick up offset of LSB among free bits
         unbound >>= bOfs;                                       // skips all fixed bits and the first free bit
         rank |= (cur>>(bOfs-1) & 0x1) << rankIndex++;           // set bit @ 1 in rank if bit is @ 1 in pattern
         cur >>= bOfs;                                           // skip bits in pattern.
      }
   }
   return rank;
}

-(unsigned int*) atRank: (unsigned long long) rank
{
   // [ldm] Algorithm still has O(|B|) rather than O(k). Must improve and use __builtin_ffs.
   if(_wordLength>2)
      @throw[[ORExecutionError alloc] initORExecutionError:"CPBitArrayDom::atRank does not support bit arrays with length > 64 bits.\n"];    
   unsigned int* bits = malloc(sizeof(unsigned int) * _wordLength);
   memset(bits,0,sizeof(unsigned int)*_wordLength);
   ORInt k = _freebits._val;
   unsigned int idx = 0;
   unsigned long long rc = rank;
   while(k) {
      unsigned int isFree = BITFREE(idx); // has a 1 at the proper bit position if free(b_idx)
      if (isFree) {
         bits[WORDIDX(idx)] |= (rc & 0x1) ? isFree : 0;     
         rc >>= 1;
         k -= (isFree!=0);   
      }
      ++idx;
   }
   return bits;
}

-(unsigned int) getMaxRank
{
   return (1 << _freebits._val)-1;
}

-(ORUInt) getSize
{
   return (1 << _freebits._val)-1;
}

-(unsigned int*) pred:(unsigned int*)x
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
    
    uint64 x64bit = x[0];
    if (_wordLength>1) {
        x64bit <<= 32;
        x64bit += x[1];
    }
    
    unsigned int* outarray = malloc (sizeof(unsigned int)*_wordLength);
    
    unsigned int* lowa = alloca(sizeof(unsigned int)*_wordLength);
    unsigned int* upa = alloca(sizeof(unsigned int)*_wordLength);    
    
    for (int i = 0; i<_wordLength ; i++){
        lowa[i] = _low[i]._val;
        upa[i] = _up[i]._val;
    }
    
    uint64 low = lowa[0];
    if (_wordLength>1) {
        low <<= 32;
        low += lowa[1];
    }
    
    uint64 up = upa[0];
    if (_wordLength>1) {
        up <<= 32;
        up += upa[1];
    }
    
    uint64 m = 1, sm=1;
    while (*x & ~m){
        m = (m<<1) |1;
        sm <<= 1;
    }
    
    uint64 mup = up & m;
    uint64 out = low & m;
    uint64 pm = m;
    
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
    outarray[0] = out >> 32;
    outarray[1] = (out << 32) >> 32;
    return outarray;
}

#define INTERPRETATION(t) ((((unsigned long long)(t)[0]._val)<<BITSPERWORD) | (t)[1]._val)

-(ORStatus)updateMin:(uint64)newMin for:(id<CPBitVarNotifier>)x
{
   uint64 oldMin = INTERPRETATION(_low);
   uint64 oldMax = INTERPRETATION(_up);
   int oldDS = _freebits._val;
   int msbIndex = BITSPERWORD - 1;
   while (msbIndex) {
      uint64 curMin = INTERPRETATION(_low);
      uint64 curMax = INTERPRETATION(_up);
      if ((curMax < newMin) || (curMin > oldMax))
         failNow();
      uint64 freeBits = curMin ^ curMax;
      if ((0x1 << msbIndex) & freeBits) {
         if (curMax - (0x1 << msbIndex) < newMin) {
            curMin = curMin | (0x1 << msbIndex);
            assignTRUInt(_low+0,curMin>>BITSPERWORD,_trail);
            assignTRUInt(_low+1,curMin & CP_BITMASK,_trail);
            assignTRUInt(&_freebits,_freebits._val - 1,_trail);
            [x bitFixedEvt:oldDS sender:self];
         } else if (curMin + (0x1 << msbIndex) > curMax) {
            curMax = curMax & ~(0x1 << msbIndex);
            assignTRUInt(_up+0,curMax>>BITSPERWORD,_trail);
            assignTRUInt(_up+1,curMax & CP_BITMASK,_trail);
            assignTRUInt(&_freebits,_freebits._val - 1,_trail);
            [x bitFixedEvt:oldDS sender:self];
         } else break;
      }
      msbIndex--;
   }
   uint64 finalMin = INTERPRETATION(_low);
   uint64 finalMax = INTERPRETATION(_up);
   if (finalMin > oldMin)
      [x changeMinEvt:oldDS sender:self];
   if (finalMax < oldMax)
      [x changeMaxEvt:oldDS sender:self];
   return ORSuspend;
}

-(ORStatus)updateMax:(uint64)newMax for:(id<CPBitVarNotifier>)x
{
    uint64 originalMax = _max[0]._val;
    uint64 min = _min[0]._val;
    if(_wordLength>1){
        originalMax <<= 32;
        originalMax += _max[1]._val;
        min <<=32;
        min += _min[1]._val;
    }
    
   uint64 newMax64 = newMax;
    
    if(newMax64 >= originalMax)
        return ORSuspend;
   unsigned int* ptrMax = (unsigned int*)&newMax;

    assignTRUInt(&_max[0], ptrMax[0], _trail);
    if(_wordLength > 1)
        assignTRUInt(&_max[1], ptrMax[1], _trail);
    
    if(newMax64 < min)
        failNow();
    
    if (![self member:ptrMax]){
        unsigned int* pred = [self pred:ptrMax];
        assignTRUInt(&_max[0], pred[0], _trail);
        if(_wordLength > 1)
            assignTRUInt(&_max[1], pred[1], _trail);
        free(pred);
    }
    newMax64 = _max[0]._val;
    if(_wordLength > 1){
        newMax64 <<= 32;
        newMax64 += _max[1]._val;
    }
    uint64 newUp = 1;
    uint64 mask = 1;
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
    uint64 low = _low[0]._val;
    uint64 up = _up[0]._val;
    
    if(_wordLength > 1){
        low <<= 32;
        up <<=32;
        low += _low[1]._val;
        up += _up[1]._val;
    }
    
    uint64 inc = ~newUp & up;
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
    uint64 atLeast = low;
    newMax64 = _max[0]._val;
    if(_wordLength > 1){
        newMax64 <<= 32;
        newMax64 += _max[1]._val;
    }    
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
    
    if(up < newMax64){
        if (_wordLength == 1)
           assignTRUInt(&_max[0],(ORUInt) up, _trail);
        else{
            assignTRUInt(&_max[0], up>>32, _trail);
            assignTRUInt(&_max[1], (up << 32)>>32, _trail);
        }
    }
    else{
        if (_wordLength == 1)
           assignTRUInt(&_max[0], (ORUInt)newMax64, _trail); 
        else{
            assignTRUInt(&_max[0], newMax64>>32, _trail);
            assignTRUInt(&_max[1], (newMax64 << 32)>>32, _trail);
        }
    }
    if (newMax64 < originalMax)
        [x changeMaxEvt:pow(2,_freebits._val) sender:self];

    newMax64 = _max[0]._val;
    if(_wordLength > 1){
        newMax64 <<= 32;
        newMax64 += _max[1]._val;
    }
   if (min > newMax64)
      failNow();
   return ORSuspend;
}

-(ORStatus)bind:(uint64)val for:(id<CPBitVarNotifier>)x
{
    if ((val < [self min]) || (val > [self max]))
       failNow();
    if ((_freebits._val == 0) && (val == [self min])) return ORSuccess;
    //Deal with arrays < 64 bits long
    assignTRUInt(&_min[0], val>>32, _trail);
    assignTRUInt(&_max[0], val>>32, _trail);
    assignTRUInt(&_min[1], val & CP_BITMASK, _trail);
    assignTRUInt(&_max[1], val & CP_BITMASK, _trail);
    assignTRUInt(&_freebits, 0, _trail);
   [self updateFreeBitCount];
    [x bindEvt];
    return ORSuspend;   
}

-(ORStatus) bindToPat:(unsigned int*) pat for:(id<CPBitVarNotifier>)x
{
   uint64  val = (((unsigned long long)pat[0]) << BITSPERWORD) | pat[1];
   if(_wordLength > 1){
      val <<= 32;
      val+= pat[1];
   }
   if (val < [self min] || val > [self max]) 
      failNow();
   if (_freebits._val == 0 && val == [self min]) 
      return ORSuccess;

   assignTRUInt(&_min[0], pat[0], _trail);
   assignTRUInt(&_max[0], pat[0], _trail);
   assignTRUInt(&_min[1], pat[1], _trail);
   assignTRUInt(&_max[1], pat[1], _trail);
   assignTRUInt(&_freebits, 0, _trail);
   [x bindEvt];
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

-(void)        getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow
{
   *currUp = _up;
   *currLow = _low;
}


-(void) setLow: (unsigned int*) newLow for:(id<CPBitVarNotifier>)x
{
   bool lmod =  false;
   for(int i=0;i<_wordLength;i++){
    lmod |= _low[i]._val != newLow[i];
    assignTRUInt(&_low[i], newLow[i], _trail);
   }
    [self updateFreeBitCount];
    if (lmod)
       [x bitFixedEvt:_freebits._val sender:self];
}

-(void) setUp: (unsigned int*) newUp  for:(id<CPBitVarNotifier>)x
{
    bool umod = false;

   for(int i=0;i<_wordLength;i++){
    umod |= _up[i]._val != newUp[i];
    assignTRUInt(&_up[i], newUp[i], _trail);
   }
    [self updateFreeBitCount];
    if (umod)
       [x bitFixedEvt:_freebits._val sender:self];
}
-(void) setUp: (unsigned int*) newUp andLow:(unsigned int*)newLow for:(id<CPBitVarNotifier>)x
{
   bool umod = false;
   bool lmod = false;
   
   for(int i=0;i<_wordLength;i++){
      umod |= _up[i]._val != newUp[i];
      assignTRUInt(&_up[i], newUp[i], _trail);
      lmod |= _low[i]._val != newLow[i];
      assignTRUInt(&_low[i], newLow[i], _trail);

   }
   [self updateFreeBitCount];
   if (umod || lmod)
      [x bitFixedEvt:_freebits._val sender:self];
   
}

-(void)enumerateWith:(void(^)(unsigned int*,ORInt))body
{
   ORUInt sz = [self getSize];
   unsigned int* bits = alloca(sizeof(unsigned int)*_wordLength);
   for(ORUInt rank=0;rank < sz;rank++) {
      memset(bits,0,sizeof(unsigned int)*_wordLength);
      ORInt k = _freebits._val;
      unsigned int idx = 0;
      ORUInt rc = rank;
      while(k) {
         unsigned int isFree = BITFREE(idx); // has a 1 at the proper bit position if free(b_idx)
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

@end

