/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPBitDom.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@implementation CPBoundsDom

-(id<CPDom>)initBoundsDomFor:(CPBoundsDom*)dom
{
   self = [super init];
   _dc = DCBounds;
   _trail = dom->_trail;
   _min = dom->_min;
   _max = dom->_max;
   _sz  = dom->_sz;
   _imin = dom->_imin;
   _imax = dom->_imax;
   return self;
}

-(id<CPDom>)initBoundsDomFor:(id<ORTrail>)trail low:(ORInt)low up:(ORInt)up 
{
   self = [super init];
   _dc = DCBounds;
   _trail = trail;
   _min = makeTRInt(_trail,low);
   _max = makeTRInt(_trail,up);
   _sz  = makeTRInt(_trail,up - low + 1);  
   _imin = low;
   _imax = up;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPBoundsDom* copy = [[CPBoundsDom allocWithZone:zone] initBoundsDomFor:_trail 
                                                                      low:_imin 
                                                                       up:_imax];
   return copy;
}

- (void) dealloc
{
    [super dealloc];
}
-(ORInt) min
{
   return _min._val;
}
-(ORInt) max 
{
   return _max._val;
}
-(ORInt) imin
{
   return _imin;
}
-(ORInt) imax
{
   return _imax;
}

-(ORBounds) bounds
{
   return (ORBounds){_min._val,_max._val};
}
-(ORBool) bound
{
   return _sz._val == 1;
}
-(ORInt) domsize
{
   return _sz._val;
}
-(ORBool) get:(ORInt)v
{
   return _min._val <= v && v <= _max._val;
}
-(ORBool) member:(ORInt) v
{
   return _min._val <= v && v <= _max._val;
}
-(ORInt) findMin:(ORInt) from // smallest value larger or equal to from
{
   return from;
}
-(ORInt) findMax:(ORInt) from // largest value smaller or equal to from
{
   return from;
}
-(ORInt) countFrom:(ORInt) from to:(ORInt) to
{
   from = max(_min._val,from);
   to   = min(_max._val,to);
   return to - from + 1;
}

-(int(^)()) getMin
{
   return [^int() {
      return self->_min._val;
   } copy];
}

-(NSString*) description
{
   if (_min._val == _max._val)
      return [NSString stringWithFormat:@"%d",_min._val];
   else
      return [NSString stringWithFormat:@"(%d)[%d .. %d]",_sz._val,_min._val,_max._val];
}
-(ORStatus) updateMin:(ORInt) newMin for:(id<CPIntVarNotifier>) x
{
   if (newMin <= _min._val) return ORSuspend;
   if (newMin > _max._val)
      failNow();
   ORInt oldMin = _min._val;
   ORInt nbr = newMin - _min._val;
   ORInt nsz = _sz._val - nbr;
   assignTRInt(&_sz, nsz, _trail);
   assignTRInt(&_min, newMin, _trail);
   
   if ([x tracksLoseEvt:self]) {
      ORStatus ok = ORSuspend;
      for(ORInt k=oldMin;k< newMin && ok;k++)
         ok = [x loseValEvt:k sender:self];
      if (!ok) return ok;
   }
   return [x changeMinEvt:nsz sender:self];
}
-(ORStatus) updateMax:(ORInt) newMax for:(id<CPIntVarNotifier>) x
{
   if (newMax >= _max._val) return ORSuspend;
   if (newMax < _min._val)
      failNow();
   ORInt oldMax = _max._val;
   ORInt nbr = _max._val - newMax;
   ORInt nsz = _sz._val - nbr;
   assignTRInt(&_max, newMax, _trail);
   assignTRInt(&_sz, nsz, _trail);
   
   if ([x tracksLoseEvt:self]) {
      ORStatus ok = ORSuspend;
      for(ORInt k=newMax+1;k<= oldMax && ok;k++)
         ok = [x loseValEvt:k sender:self];
      if (!ok) return ok;
   }
   return [x changeMaxEvt:nsz sender:self];
}

-(ORStatus) updateMin:(ORInt)newMin andMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x
{
   if (newMin <= _min._val && newMax >= _max._val) return ORSuspend;
   newMin = max(newMin,_min._val);
   newMax = min(newMax,_max._val);
   if (newMin > _max._val || newMin > newMax || newMax < _min._val)
      failNow();
   ORInt oldMin = _min._val;
   ORInt oldMax = _max._val;
   ORInt nbr = newMin - _min._val + _max._val - newMax;  // number of values removed.
   ORInt nsz = _sz._val - nbr;
   assignTRInt(&_sz,nsz,_trail);
   assignTRInt(&_min, newMin, _trail);
   assignTRInt(&_max, newMax, _trail);
   if ([x tracksLoseEvt:self]) {
      ORStatus ok = ORSuspend;
      for(ORInt k=oldMin;k< newMin && ok;k++)
         ok = [x loseValEvt:k sender:self];
      for(ORInt k=newMax+1;k<= oldMax && ok;k++)
         ok = [x loseValEvt:k sender:self];
      if (!ok) return ok;
   }
   ORStatus ok = [x changeMinEvt:nsz sender:self];
   if (!ok) return ok;
   ok = [x changeMaxEvt:nsz sender:self];
   return ok;
}

-(ORStatus)  bind:(ORInt)  val for:(id<CPIntVarNotifier>) x
{
   if (val < _min._val || val > _max._val)
      failNow();
   if (_sz._val == 1 && val == _min._val) return ORSuccess;
   ORInt oldMin = _min._val;
   ORInt oldMax = _max._val;
   assignTRInt(&_min, val, _trail);
   assignTRInt(&_max, val, _trail);
   assignTRInt(&_sz, 1, _trail);
   
   if ([x tracksLoseEvt:self]) {
      ORStatus ok = ORSuspend;
      for(ORInt k=oldMin;k<=oldMax && ok;k++)
         if (k != val)
            ok = [x loseValEvt:k sender:self];
      if (!ok) return  ok;
   };
   return [x bindEvt:self];
}

-(ORStatus) remove:(ORInt) val for:(id<CPIntVarNotifier>) x
{
   if (val <= _min._val) return [self updateMin:val+1 for:x];
   if (val >= _max._val) return [self updateMax:val-1 for:x];
   @throw [[CPRemoveOnDenseDomainError alloc] initCPRemoveOnDenseDomainError];
}

-(void) restoreDomain:(id<CPDom>) toRestore
{
   _min._val = [toRestore min];
   _max._val = [toRestore max];
   _sz._val  = [toRestore domsize];
}
-(void) restoreValue:(ORInt) toRestore for:(id<CPIntVarNotifier>)x
{
    ORInt oldMin = _min._val;
    ORInt oldMax = _max._val;
    
    _min._val = toRestore;
    _max._val = toRestore;
    _sz._val  = 1;
    
    if ([x tracksLoseEvt:self]) {
        ORStatus ok = ORSuspend;
        for(ORInt k=oldMin;k<=oldMax && ok;k++)
            if (k != toRestore)
                ok = [x loseValEvt:k sender:self];
        if (!ok) return;
    };
    [x bindEvt:self];
}
-(void) enumerateWithBlock:(void(^)(ORInt))block
{
   for(ORInt k=_min._val;k <= _max._val;k++)
      block(k);
}

-(void) enumerateBackwardWithBlock:(void(^)(ORInt))block
{
   for(ORInt k=_max._val; k >= _min._val;k--)
      block(k);
}


- (void) encodeWithCoder:(NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_dc];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_min._val];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_max._val];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_sz._val];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_imin];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_imax];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_dc];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_min._val];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_max._val];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_sz._val];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_imin];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_imax];
   return self;
}
@end

// ========================================================================================
// Bit Dom Representation
// ========================================================================================

@implementation CPBitDom

-(CPBitDom*) initBitDomFor:(CPBitDom*) dom
{
   self = [super initBoundsDomFor:dom];
   _dc = DCBits;
   const ORInt sz = _imax - _imin + 1;
   const ORInt nb = (sz >> 5)  + ((sz & 0x1f)!=0);
   _bits  = malloc(sizeof(ORUInt)*nb);
   _magic = malloc(sizeof(ORInt)*nb);
   for(ORInt k=0;k<nb;k++) {
      _bits[k]  = 0xffffffff;
      _magic[k] = [_trail magic]-1;
   }
   const BOOL partialLast = sz & 0x1f;
   if (partialLast)
      _bits[nb-1]  &= ~(0xffffffff << (_imax - _imin + 1) % 32); // clear the unused high bits of the last partially filled word.
   _updateMin = (UBType)[self methodForSelector:@selector(updateMin:for:)];
   _updateMax = (UBType)[self methodForSelector:@selector(updateMax:for:)];
   return self;   
}
-(CPBitDom*) initBitDomFor:(id<ORTrail>) trail low:(ORInt) low up:(ORInt) up
{
   self = [super initBoundsDomFor:trail low:low up:up];
   _dc = DCBits;
   const ORInt sz = _imax - _imin + 1;
   const ORInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   _bits  = malloc(sizeof(ORUInt)*nb);
   _magic = malloc(sizeof(ORInt)*nb);
   for(ORInt k=0;k<nb;k++) {
      _bits[k]  = 0xffffffff;
      _magic[k] = [trail magic]-1;
   }
   const BOOL partialLast = sz & 0x1f;
   if (partialLast)
      _bits[nb-1]  &= ~(0xffffffff << (_imax - _imin + 1) % 32); // clear the unused high bits of the last partially filled word.
   _updateMin = (UBType)[self methodForSelector:@selector(updateMin:for:)];
   _updateMax = (UBType)[self methodForSelector:@selector(updateMax:for:)];
   return self;
}
- (id)copyWithZone:(NSZone *) zone
{
   CPBitDom* copy = [[CPBitDom alloc] initBitDomFor:self];
   const ORInt sz = _imax - _imin + 1;
   const ORInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   for(ORUInt k=0;k<nb;k++) {
      copy->_bits[k] = _bits[k];
      copy->_magic[k] = _magic[k];
   }
   return copy;
}

-(void)dealloc 
{
   //NSLog(@"free CPBitDom %p\n",self);
   free(_bits);
   free(_magic);
   [super dealloc];
}

static inline int countFrom(CPBitDom* dom,ORInt from,ORInt to)
{
   from -= dom->_imin;
   to    = to + 1 - dom->_imin;
   int fw = from >> 5;
   int tw = to >> 5;
   int fb = from & 0x1f;
   int tb = to & 0x1f;
   int nc = 0;
   if (fw == tw) {
      const unsigned int wm = (0xFFFFFFFF << fb) & ~(0xFFFFFFFF << tb);
      const unsigned int bits = dom->_bits[fw] & wm;
      nc = __builtin_popcount(bits);
   } else {
      unsigned int wm = (0xFFFFFFFF << fb);
      unsigned int bits;
      while (fw < tw) {
         bits = dom->_bits[fw] & wm;
         nc += __builtin_popcount(bits);
         fw += 1;
         wm = 0xFFFFFFFF;
      }
      wm = ~(0xFFFFFFFF << tb);
      bits = dom->_bits[fw] & wm;
      nc += __builtin_popcount(bits);
   }
   /*
   fw = from >> 5;
   tw = to >> 5;
   fb = from & 0x1f;
   tb = to & 0x1f;
   int cnt = 0;
   ORUInt mask = 0x1 << fb;
   while (fw != tw || fb != tb) {
      cnt += ((dom->_bits[fw] & mask)!=0);
      mask <<= 1;
      ++fb;
      if (mask==0) {
         ++fw;
         fb   = 0;
         mask = 0x1;
      }
   }
   assert(nc == cnt);
   return cnt;   */
   return nc;
}

inline static void resetBit(CPBitDom* dom,ORInt b) 
{
   b -= dom->_imin;
   const ORInt bw = b >> 5;
   const ORUInt magic = trailMagic(dom->_trail);
   if (dom->_magic[bw] != magic) {
      dom->_magic[bw] = magic;
      [dom->_trail trailUnsigned:(dom->_bits + bw)];
   }     
   dom->_bits[bw] &= ~(0x1 << (b & 0x1f));
}

static inline ORInt findMin(CPBitDom* dom,ORInt from)
{
   from -= dom->_imin;
   ORInt mw = from >> 5;
   ORInt mb = from & 0x1f;
   ORUInt mask = 0x1 << mb;
   while ((dom->_bits[mw] & mask) == 0) {
      mask <<= 1;
      ++mb;
      if (mask==0) {
         ++mw;
         mb   = 0;
         mask = 0x1;
      }
   }
   //assert((dom->_bits[mw] & mask) == mask);
   return dom->_imin + ((mw << 5) + mb);   
}

static inline ORInt findMax(CPBitDom* dom,ORInt from)
{
   from -= dom->_imin;
   int mw = from >> 5;
   int mb = from & 0x1f;
   ORUInt mask = 0x1 << mb;
   while ((dom->_bits[mw] & mask) == 0) {
      mask >>= 1;
      --mb;
      if (mask==0) {
         --mw;
         mb   = 31; 
         mask = 0x80000000;
      }
   }
   //assert((dom->_bits[mw] & mask) == mask);
   return dom->_imin + ((mw << 5) + mb);   
}

-(ORBool) get:(ORInt)b
{
   return GETBIT(b);
}
-(ORBool) member:(ORInt)b
{
   return b >= _min._val && b <= _max._val && GETBIT(b);
}

-(void)set:(ORInt)b at:(ORBool)v
{
   if (b >=_imin && b<=_imax) {
      b -= _imin;
      const ORInt bw = b >> 5;
      const ORUInt magic = trailMagic(_trail);
      if (_magic[bw] != magic) {
         _magic[bw] = magic;
         trailUIntFun(_trail,_bits+bw);
      }     
      if (v) 
         _bits[bw] |= (0x1 << (b & 0x1f));
      else
         _bits[bw] &= ~(0x1 << (b & 0x1f));
   }    
}
-(ORInt)setAllZeroFrom:(ORInt)from to:(ORInt)to
{
   assert(from >= _imin && from <= _imax);
   assert(to >= _imin && to <= _imax);
   const ORUInt magic = [_trail magic];
   from -= _imin;
   to    = to + 1 - _imin;
   ORInt fw = from >> 5;
   ORInt fb = from & 0x1f;
   ORInt tw = to >> 5;
   ORInt tb = to & 0x1f;
   ORInt nbin = 0;
   for(ORInt k=fw;k<tw;k++) {
      ORUInt bits = _bits[k];
      ORUInt mask = 0x1 << fb;
      ORUInt nmsk = ~mask;
      while(mask) {
         nbin += ((bits & mask) == mask);
         bits &= nmsk;
         mask <<= 1;
         nmsk = (nmsk << 1) | 1;
      }
      if (_magic[k] != magic) {
         _magic[k] = magic;
         [_trail trailUnsigned:_bits + k];
      }     
      _bits[k] = bits;
      fb = 0;
   }
   const ORUInt tomask = 0x1 << tb;
   ORUInt bits = _bits[tw];
   ORUInt mask = 0x1 << fb;
   ORUInt nmsk = ~mask;
   while(mask != tomask) {
      nbin += ((bits & mask) == mask);
      bits &= nmsk;
      mask <<= 1;
      nmsk = (nmsk << 1) | 1;
   }
   if (tb && _magic[tw] != magic) { // if to-bit is 0, we did not do anything on this word
      // and more importantly tw-1 was the _last_ word of the domain, so there is no magic[tw],
      // the last magic was magic[tw-1]
      _magic[tw] = magic;
      [_trail trailUnsigned:_bits + tw];
   }     
   _bits[tw] = bits;   
   return nbin;   
}

-(ORInt)countFrom:(ORInt)from to:(ORInt)to
{
   return countFrom(self,from,to);
}

-(ORInt)findMin:(ORInt)from
{
   return findMin(self,from);
}

-(ORInt)findMax:(ORInt)from
{
   return findMax(self,from);
}
-(ORInt)regret
{
   return [self findMin:_min._val+1] - _min._val;   
}
-(NSString*)description
{
   NSMutableString* s = [NSMutableString stringWithCapacity:80];
   if (_sz._val==1)
      [s appendFormat:@"%d",_min._val];
   else {
      [s appendFormat:@"(%d)[%d",_sz._val,_min._val];
      ORInt lastIn = _min._val;
      ORInt frstIn = _min._val;
      bool seq   = true;
      for(ORInt k=_min._val+1;k<=_max._val;k++) {
         if ([self get:k]) {
            if (!seq) {
               [s appendFormat:@",%d",k];
               frstIn = lastIn = k;
               seq = true;
            }
            lastIn = k;
         } else {
            if (seq) {
               if (frstIn != lastIn) {
                  if (frstIn + 1 == lastIn)
                     [s appendFormat:@",%d",lastIn];
                  else
                     [s appendFormat:@"..%d",lastIn];
               }
               seq = false;
            }
         }
      }
      if (seq) {
         if (frstIn != lastIn) {
            if (frstIn + 1 == lastIn)
               [s appendFormat:@",%d",lastIn];
            else
               [s appendFormat:@"..%d",lastIn];
         }
      }
      [s appendFormat:@"]"];
   }
   return s;
}
-(void) enumerateWithBlock:(void(^)(ORInt))block
{
   for(ORInt k =_min._val;k <= _max._val;k++) {
      if ([self get:k]) {
         block(k);
      }
   }
}
-(void) enumerateBackwardWithBlock:(void(^)(ORInt))block
{
   for(ORInt k=_max._val;k >= _min._val;k--) {
      if ([self get:k]) {
         block(k);
      }
   }
}


-(ORStatus) updateMin: (ORInt) newMin for: (id<CPIntVarNotifier>)x
{
   if (newMin <= _min._val) return ORSuspend;
   if (newMin > _max._val)
      failNow();
   ORInt oldMin = _min._val;
   int nbr = countFrom(self,_min._val,newMin-1);
   // need to send AC5 notifications still
   ORInt nsz = _sz._val - nbr;
   assignTRInt(&_sz, nsz, _trail);
   newMin = findMin(self,newMin);
   assignTRInt(&_min, newMin, _trail);

   if ([x tracksLoseEvt:self]) {
      ORStatus ok = ORSuspend;
      for(ORInt k=oldMin;k< newMin && ok;k++)
         if (GETBIT(k))
            ok = [x loseValEvt:k sender:self];
      if (!ok) return ok;
   }
   return [x changeMinEvt:nsz sender:self];
}

-(ORStatus)updateMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x
{
   if (newMax >= _max._val) return ORSuspend;
   if (newMax < _min._val)
      failNow();
   ORInt oldMax = _max._val;
   ORInt nbr = countFrom(self,newMax+1,_max._val);
   ORInt nsz = _sz._val - nbr;
   assignTRInt(&_sz, nsz, _trail);
   newMax = findMax(self,newMax);
   assignTRInt(&_max, newMax, _trail);

   if ([x tracksLoseEvt:self]) {
      ORStatus ok = ORSuspend;
      for(ORInt k=newMax+1;k<= oldMax && ok;k++)
         if (GETBIT(k))
            ok = [x loseValEvt:k sender:self];
      if (!ok) return ok;
   }
   return [x changeMaxEvt:nsz sender:self];
}

-(ORStatus) updateMin:(ORInt)newMin andMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x
{
   ORStatus ok = ORSuspend;
   if (newMin > _max._val || newMax < _min._val)
      failNow();
   if (newMin > _min._val) {
      ORInt oldMin = _min._val;
      int nbr = countFrom(self,_min._val,newMin-1);
      ORInt nsz = _sz._val - nbr;
      assignTRInt(&_sz, nsz, _trail);
      newMin = findMin(self,newMin);
      assignTRInt(&_min, newMin, _trail);
      
      if ([x tracksLoseEvt:self]) {
         for(ORInt k=oldMin;k< newMin && ok;k++)
            if (GETBIT(k))
               ok = [x loseValEvt:k sender:self];
         if (!ok) return ok;
      }
      ok = [x changeMinEvt:nsz sender:self];
      if (!ok) return ok;
   }
   if (newMax < _max._val)  {
      ORInt oldMax = _max._val;
      ORInt nbr = countFrom(self,newMax+1,_max._val);
      ORInt nsz = _sz._val - nbr;
      assignTRInt(&_sz, nsz, _trail);
      newMax = findMax(self,newMax);
      assignTRInt(&_max, newMax, _trail);
      
      if ([x tracksLoseEvt:self]) {
         ORStatus ok = ORSuspend;
         for(ORInt k=newMax+1;k<= oldMax && ok;k++)
            if (GETBIT(k))
               ok = [x loseValEvt:k sender:self];
         if (!ok) return ok;
      }
      ok = [x changeMaxEvt:nsz sender:self];
   }
   return ok;
}

-(ORStatus)bind:(ORInt)val for:(id<CPIntVarNotifier>)x
{
   if (val < _min._val || val > _max._val)
      failNow();
   if (_sz._val == 1 && val == _min._val)
      return ORSuccess;
   ORInt oldMin = _min._val;
   ORInt oldMax = _max._val;
   assignTRInt(&_min, val, _trail);
   assignTRInt(&_max, val, _trail);
   assignTRInt(&_sz, 1, _trail);
   
   if ([x tracksLoseEvt:self]) {
      ORStatus ok = ORSuspend;
      for(ORInt k=oldMin;k<=oldMax && ok;k++)
         if (GETBIT(k) && k != val)
            ok = [x loseValEvt:k sender:self];
      if (!ok) return ok;
   };
   
   return [x bindEvt:self];
}

-(ORStatus)remove:(ORInt)val for:(id<CPIntVarNotifier>)x
{
   if (val < _min._val || val > _max._val) return ORSuspend;
   if (_min._val == _max._val) failNow();
   if (val == _min._val) {
      ORInt oldMin = _min._val;
      inline_assignTRInt(&_sz, _sz._val - 1, _trail);
      ORInt newMin = findMin(self,_min._val + 1);
      inline_assignTRInt(&_min, newMin, _trail);
      ORStatus ok = [x loseValEvt:oldMin sender:self];
      if (!ok) return ok;
      return [x changeMinEvt:_sz._val sender:self];
   } 
   if (val == _max._val) {
      ORInt oldMax = _max._val;
      inline_assignTRInt(&_sz, _sz._val - 1, _trail);
      ORInt newMax = findMax(self,_max._val - 1);
      inline_assignTRInt(&_max, newMax, _trail);
      ORStatus ok = [x loseValEvt:oldMax sender:self];
      if (!ok) return ok;
      return [x changeMaxEvt:_sz._val sender:self];
   }
   if (GETBIT(val)) {
      resetBit(self,val);
      inline_assignTRInt(&_sz, _sz._val -  1, _trail);
      ORStatus ok = ORSuspend;
      if (_sz._val==1)
         ok = [x bindEvt:self];
      if (ok)
         return [x loseValEvt:val sender:self];
      else return ok;
   }
   else
      return ORSuspend;
}

-(void)restoreDomain:(CPBitDom*)toRestore
{
   _min._val = [toRestore min];
   _max._val = [toRestore max];
   _sz._val  = [toRestore domsize];
   const ORInt sz = _imax - _imin + 1;
   const ORInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   for(ORUInt k=0;k< nb ; k++) {
      _bits[k] = toRestore->_bits[k];
   }
}
-(void)restoreValue:(ORInt)toRestore for:(id<CPIntVarNotifier>)x
{
    ORInt oldMin = _min._val;
    ORInt oldMax = _max._val;
    
   _min._val = toRestore;
   _max._val = toRestore;
   _sz._val  = 1;
    
    if ([x tracksLoseEvt:self]) {
        ORStatus ok = ORSuspend;
        for(ORInt k=oldMin;k<=oldMax && ok;k++)
            if (GETBIT(k) && k != toRestore)
                ok = [x loseValEvt:k sender:self];
        if (!ok) return;
    };
    [x bindEvt:self];
}

-(void)translate:(ORInt)shift
{
   _imin = _imin + shift;
   _imax = _imax + shift;
   _min._val = _min._val + shift;
   _max._val = _max._val + shift;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_dc];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_min._val];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_max._val];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_sz._val];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_imin];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_imax];
   const ORInt sz = _imax - _imin + 1;
   const ORInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   for(ORInt k=0;k<nb;k++) {
      [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_bits[k]]; 
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_magic[k]]; 
   }
   [aCoder encodeObject:_trail];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_dc];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_min._val];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_max._val];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_sz._val];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_imin];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_imax];
   const ORInt sz = _imax - _imin + 1;
   const ORInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   
   _bits  = malloc(sizeof(ORUInt)*nb);
   _magic = malloc(sizeof(ORInt)*nb);

   for(ORInt k=0;k<nb;k++) {
      [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_bits[k]];  
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_magic[k]]; 
   }
   _trail = [aDecoder decodeObject] ;
   _updateMin = (UBType)[self methodForSelector:@selector(updateMin:for:)];
   _updateMax = (UBType)[self methodForSelector:@selector(updateMax:for:)];
   return self;
}
@end

CPBitDom* newDomain(CPBitDom* bd,ORInt a,ORInt b)
{
   if (a == 1 && b == 0) {
      CPBitDom* nDom = [[CPBitDom alloc] initBitDomFor:bd->_trail low:bd->_imin up: bd->_imax];
      for(ORInt v =bd->_imin;v <= bd->_imax;v++) {
         if (!memberCPDom(bd, v)) {
            [nDom set:v at:NO];
         }
      }
      return nDom;
      //return [bd copyWithZone:NULL];
   } else if (a==1) {
      CPBitDom* clone = [[CPBitDom alloc] initBitDomFor:bd->_trail low:bd->_imin up:bd->_imax];
      for(ORInt v =bd->_imin;v <= bd->_imax;v++) {
         if (!memberCPDom(bd, v)) {
            [clone set:v at:NO];
         }
      }
      //CPBitDom* clone = [bd copyWithZone:NULL];
      [clone translate: b];
      return clone;      
   } else if (a== -1 && b == 0) {
      CPBitDom* nDom = [[CPBitDom alloc] initBitDomFor:bd->_trail low:-bd->_imax up:-bd->_imin];
      for(ORInt v =bd->_imin;v <= bd->_imax;v++) {
         if (!memberCPDom(bd, v)) {
            [nDom set:-v at:NO];
         }
      }
      return nDom;
   } else if (a == -1) {
      CPBitDom* nDom = [[CPBitDom alloc] initBitDomFor:bd->_trail low:-bd->_imax + b up:-bd->_imin + b];
      for(ORInt v =bd->_imin;v <= bd->_imax;v++) {
         if (!memberCPDom(bd, v)) {
            [nDom set:-v+b at:NO];
         }
      }
      return nDom;
   } else {
      ORInt newLow = (a > 0 ? [bd min] : [bd max]) * a + b;
      ORInt newUp  = (a > 0 ? [bd max] : [bd min]) * a + b;
      CPBitDom* nDom = [[CPBitDom alloc] initBitDomFor:bd->_trail low:newLow up:newUp];
      [nDom setAllZeroFrom:newLow to:newUp];
      for(ORInt i = [bd min];i  <= [bd max];i++) {
         ORInt k = a * i + b;
         [nDom set:k at:YES];
      }
      return nDom;
   }
}

@implementation CPAffineDom
-(id)initAffineDom:(id<CPDom>)d scale:(ORInt)a shift:(ORInt)b
{
   self = [super init];
   _theDom = [d retain];
   _a = a;
   _b = b;
   return self;
}
-(void)dealloc
{
   [_theDom release];
   [super dealloc];
}
-(ORStatus) updateMin:(ORInt)newMin for:(id<CPIntVarNotifier>)x
{
   assert(FALSE);
   return ORSuspend;
}
-(ORStatus) updateMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x
{
   assert(FALSE);
   return ORSuspend;
}
-(ORStatus) bind:(ORInt)val  for:(id<CPIntVarNotifier>)x
{
   assert(FALSE);
   return ORSuspend;
}
-(ORStatus) remove:(ORInt)val  for:(id<CPIntVarNotifier>)x
{
   assert(FALSE);
   return ORSuspend;
}

-(ORInt) min
{
   if (_a > 0)
      return [_theDom min] * _a + _b;
   else
      return [_theDom max] * _a + _b;
}
-(ORInt) max
{
   if (_a > 0)
      return [_theDom max] * _a + _b;
   else
      return [_theDom min] * _a + _b;
}
-(ORInt) imin
{
   if (_a > 0)
      return [_theDom imin] * _a + _b;
   else
      return [_theDom imax] * _a + _b;
}
-(ORInt) imax
{
   if (_a > 0)
      return [_theDom imax] * _a + _b;
   else
      return [_theDom imin] * _a + _b;
}
-(ORBool) bound
{
   return [_theDom bound];
}
-(ORBounds) bounds
{
   ORBounds b = [_theDom bounds];
   if (_a > 0)
      return (ORBounds){b.min * _a + _b,b.max * _a + _b};
   else
      return (ORBounds){b.max * _a + _b,b.min * _a + _b};
}
-(ORInt) domsize
{
   return [_theDom domsize];
}
-(ORInt) countFrom:(ORInt)from to:(ORInt)to
{
   ORInt f2 = (from - _b) /  _a;
   ORInt t2 = (to  - _b) / _a;
   return [_theDom countFrom:f2 to:t2];
}
-(ORBool) get:(ORInt)b
{
   if ((b - _b)  % _a)
      return NO;
   else
      return [_theDom get:(b - _b)/_a];
}
-(ORBool) member:(ORInt)v
{
   if ((v - _b) % _a)
      return NO;
   else
      return [_theDom member:(v - _b)/_a];
}
-(ORInt)findMin:(ORInt)from
{
   ORInt r;
   if (_a > 0)
      r = [_theDom findMin:(from - _b)/_a];
   else
      r = [_theDom findMax:(from - _b)/_a];
   return r * _a + _b;
}
-(ORInt) findMax:(ORInt)from
{
   ORInt r;
   if (_a > 0)
      r = [_theDom findMax:(from - _b)/_a];
   else
      r = [_theDom findMin:(from - _b)/_a];   
   return r * _a + _b;
}
-(id) copyWithZone:(NSZone *)zone
{
   return [[CPAffineDom alloc] initAffineDom:_theDom scale:_a shift:_b];
}
-(void) restoreDomain:(id<CPDom>)toRestore
{
   assert(FALSE);
}
-(void) restoreValue:(ORInt)toRestore for:(id<CPIntVarNotifier>)x
{
   assert(FALSE);
}
-(void) enumerateWithBlock:(void(^)(ORInt))block
{
   if (_a > 0)
      [_theDom enumerateWithBlock:^(ORInt k) {
         block(k * _a + _b);
      }];
   else
      [_theDom enumerateBackwardWithBlock:^(ORInt k) {
         block(k * _a + _b);
      }];
}
-(void) enumerateBackwardWithBlock:(void(^)(ORInt))block
{
   if (_a > 0)
      [_theDom enumerateBackwardWithBlock:^(ORInt k) {
         block(k * _a + _b);
      }];
   else 
      [_theDom enumerateWithBlock:^(ORInt k) {
         block(k * _a + _b);
      }];
}

@end
