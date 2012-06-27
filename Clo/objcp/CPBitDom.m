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

#import "CPBitDom.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@implementation CPBoundsDom

-(id<CPDom>)initBoundsDomFor:(CPBoundsDom*)dom
{
   self = [super init];
   _trail = dom->_trail;
   _min = dom->_min;
   _max = dom->_max;
   _sz  = dom->_sz;
   _imin = dom->_imin;
   _imax = dom->_imax;
   return self;
}

-(id<CPDom>)initBoundsDomFor:(CPTrail*)trail low:(CPInt)low up:(CPInt)up 
{
   self = [super init];
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

- (void)dealloc
{
    [super dealloc];
}
-(CPInt)min
{
   return _min._val;
}
-(CPInt)max 
{
   return _max._val;
}
-(CPInt)imin
{
   return _imin;
}
-(CPInt)imax
{
   return _imax;
}

-(CPBounds)bounds
{
   return (CPBounds){_min._val,_max._val};
}
-(bool)bound
{
   return _sz._val == 1;
}
-(CPInt)domsize
{
   return _sz._val;
}
-(bool)get:(CPInt)v
{
   return _min._val <= v && v <= _max._val;
}
-(bool)member:(CPInt)v
{
   return _min._val <= v && v <= _max._val;
}
-(CPInt)findMin:(CPInt)from // smallest value larger or equal to from
{
   return from;
}
-(CPInt)findMax:(CPInt)from // largest value smaller or equal to from
{
   return from;
}
-(CPInt)countFrom:(CPInt)from to:(CPInt)to
{
   from = max(_min._val,from);
   to   = min(_max._val,to);
   return to - from + 1;
}

-(int(^)())getMin
{
   return [^int() {
      return self->_min._val;
   } copy];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"(%d)[%d .. %d]",_sz._val,
           _min._val,_max._val];
}
-(CPStatus)updateMin:(CPInt)newMin for:(id<CPIntVarNotifier>)x
{
   if (newMin <= _min._val) return CPSuspend;
   if (newMin > _max._val)  return CPFailure;
   CPInt nbr = newMin - _min._val;
   CPInt nsz = _sz._val - nbr;
   assignTRInt(&_sz, nsz, _trail);
   assignTRInt(&_min, newMin, _trail);
   [x changeMinEvt:nsz];
   return CPSuspend;
}
-(CPStatus)updateMax:(CPInt)newMax for:(id<CPIntVarNotifier>)x
{
   if (newMax >= _max._val) return CPSuspend;
   if (newMax < _min._val) return CPFailure;
   CPInt nbr = _max._val - newMax;
   CPInt nsz = _sz._val - nbr;
   assignTRInt(&_max, newMax, _trail);
   assignTRInt(&_sz, nsz, _trail);
   [x changeMaxEvt:nsz];
   return CPSuspend;   
}
-(CPStatus)bind:(CPInt)val for:(id<CPIntVarNotifier>)x
{
   if (val < _min._val || val > _max._val) return CPFailure;
   if (_sz._val == 1 && val == _min._val) return CPSuccess;
   
   assignTRInt(&_min, val, _trail);
   assignTRInt(&_max, val, _trail);
   assignTRInt(&_sz, 1, _trail);
   [x bindEvt];
   return CPSuspend;   
}

-(CPStatus)remove:(CPInt)val for:(id<CPIntVarNotifier>)x
{
    @throw [[CPRemoveOnDenseDomainError alloc] initCPRemoveOnDenseDomainError];     
    return CPSuspend;
}

-(void)restoreDomain:(id<CPDom>)toRestore
{
   _min._val = [toRestore min];
   _max._val = [toRestore max];
   _sz._val  = [toRestore domsize];
}
-(void)restoreValue:(CPInt)toRestore
{
   _min._val = toRestore;
   _max._val = toRestore;
   _sz._val  = 1;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_min._val];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_max._val];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_sz._val];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_imin];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_imax];

}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_min._val];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_max._val];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_sz._val];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_imin];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_imax];
   return self;
}
@end

@implementation CPBitDom

-(CPBitDom*)initBitDomFor:(CPBitDom*)dom
{
   self = [super initBoundsDomFor:dom];
   const CPInt sz = _imax - _imin + 1;
   const CPInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   _bits  = malloc(sizeof(CPUInt)*nb);
   _magic = malloc(sizeof(CPInt)*nb);
   for(CPInt k=0;k<nb;k++) {
      _bits[k]  = 0xffffffff;
      _magic[k] = [_trail magic]-1;
   }
   return self;   
}
-(CPBitDom*) initBitDomFor:(CPTrail*)trail low:(CPInt)low up:(CPInt)up
{
   self = [super initBoundsDomFor:trail low:low up:up];
   const CPInt sz = _imax - _imin + 1;
   const CPInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   _bits  = malloc(sizeof(CPUInt)*nb);
   _magic = malloc(sizeof(CPInt)*nb);
   for(CPInt k=0;k<nb;k++) {
      _bits[k]  = 0xffffffff;
      _magic[k] = [trail magic]-1;
   }
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPBitDom* copy = [[CPBitDom alloc] initBitDomFor:self];
   const CPInt sz = _imax - _imin + 1;
   const CPInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   for(CPUInt k=0;k<nb;k++) {
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

static inline int countFrom(CPBitDom* dom,CPInt from,CPInt to)
{
   from -= dom->_imin;
   int fw = from >> 5;
   int fb = from & 0x1f;
   to    = to + 1 - dom->_imin;
   int tw = to >> 5;
   int tb = to & 0x1f;
   int cnt = 0;
   CPUInt mask = 0x1 << fb;
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
   return cnt;   
}

inline static void resetBit(CPBitDom* dom,CPInt b) 
{
   b -= dom->_imin;
   const CPInt bw = b >> 5;
   const CPUInt magic = dom->_trail->_magic;
   if (dom->_magic[bw] != magic) {
      dom->_magic[bw] = magic;
      [dom->_trail trailUnsigned:(dom->_bits + bw)];
   }     
   dom->_bits[bw] &= ~(0x1 << (b & 0x1f));
}

static inline CPInt findMin(CPBitDom* dom,CPInt from)
{
   from -= dom->_imin;
   CPInt mw = from >> 5;
   CPInt mb = from & 0x1f;
   CPUInt mask = 0x1 << mb;
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

static inline CPInt findMax(CPBitDom* dom,CPInt from)
{
   from -= dom->_imin;
   int mw = from >> 5;
   int mb = from & 0x1f;
   CPUInt mask = 0x1 << mb;
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

-(bool) get:(CPInt)b
{
   return GETBIT(b);
}
-(bool) member:(CPInt)b
{
   return b >= _min._val && b <= _max._val && GETBIT(b);
}

-(void)set:(CPInt)b at:(bool)v
{
   if (b >=_imin && b<=_imax) {
      b -= _imin;
      const CPInt bw = b >> 5;
      const CPUInt magic = _trail->_magic;
      if (_magic[bw] != magic) {
         _magic[bw] = magic;
         [_trail trailUnsigned:(_bits + bw)];
      }     
      if (v) 
         _bits[bw] |= (0x1 << (b & 0x1f));
      else
         _bits[bw] &= ~(0x1 << (b & 0x1f));
   }    
}
-(CPInt)setAllZeroFrom:(CPInt)from to:(CPInt)to
{
   assert(from >= _imin && from <= _imax);
   assert(to >= _imin && to <= _imax);
   const CPUInt magic = [_trail magic];
   from -= _imin;
   to    = to + 1 - _imin;
   CPInt fw = from >> 5;
   CPInt fb = from & 0x1f;
   CPInt tw = to >> 5;
   CPInt tb = to & 0x1f;
   CPInt nbin = 0;
   for(CPInt k=fw;k<tw;k++) {
      CPUInt bits = _bits[k];
      CPUInt mask = 0x1 << fb;
      CPUInt nmsk = ~mask;
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
   const CPUInt tomask = 0x1 << tb;
   CPUInt bits = _bits[tw];
   CPUInt mask = 0x1 << fb;
   CPUInt nmsk = ~mask;
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

-(CPInt)countFrom:(CPInt)from to:(CPInt)to
{
   return countFrom(self,from,to);
}

-(CPInt)findMin:(CPInt)from
{
   return findMin(self,from);
}

-(CPInt)findMax:(CPInt)from
{
   return findMax(self,from);
}
-(CPInt)regret
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
      CPInt lastIn = _min._val;
      CPInt frstIn = _min._val;
      bool seq   = true;
      for(CPInt k=_min._val+1;k<=_max._val;k++) {
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

-(CPStatus) updateMin: (CPInt) newMin for: (id<CPIntVarNotifier>)x
{
    if (newMin <= _min._val) return CPSuspend;
    if (newMin > _max._val)  return CPFailure;
    int nbr = countFrom(self,_min._val,newMin-1);
   if ([x tracksLoseEvt]) {
      for(CPInt k=_min._val;k< newMin;k++) 
         if (GETBIT(k)) 
            [x loseValEvt:k];         
   }
    // need to send AC5 notifications still
    CPInt nsz = _sz._val - nbr;
    assignTRInt(&_sz, nsz, _trail);
    newMin = findMin(self,newMin);
    assignTRInt(&_min, newMin, _trail);
    [x changeMinEvt:nsz];
    return CPSuspend;   
}

-(CPStatus)updateMax:(CPInt)newMax for:(id<CPIntVarNotifier>)x
{
    if (newMax >= _max._val) return CPSuspend;
    if (newMax < _min._val) return CPFailure;
    CPInt nbr = countFrom(self,newMax+1,_max._val);
   if ([x tracksLoseEvt]) {
      for(CPInt k=newMax+1;k<= _max._val;k++) 
         if (GETBIT(k)) 
            [x loseValEvt:k];         
   }
    CPInt nsz = _sz._val - nbr;
    assignTRInt(&_sz, nsz, _trail);
    newMax = findMax(self,newMax);
    assignTRInt(&_max, newMax, _trail);
    [x changeMaxEvt:nsz];
    return CPSuspend;      
}

-(CPStatus)bind:(CPInt)val for:(id<CPIntVarNotifier>)x
{
    if (val < _min._val || val > _max._val) return CPFailure;
    if (_sz._val == 1 && val == _min._val) return CPSuccess;
    if ([x tracksLoseEvt]) {
        for(CPInt k=_min._val;k<=_max._val;k++) 
            if (GETBIT(k) && k != val) 
                [x loseValEvt:k];         
    };
    assignTRInt(&_min, val, _trail);
    assignTRInt(&_max, val, _trail);
    assignTRInt(&_sz, 1, _trail);
    [x bindEvt];
    return CPSuspend;      
}

-(CPStatus)remove:(CPInt)val for:(id<CPIntVarNotifier>)x
{
   if (val < _min._val || val > _max._val) return CPSuspend;
   if (val == _min._val) return [self updateMin:val+1 for:x];
   if (val == _max._val) return [self updateMax:val-1 for:x];   
   if (GETBIT(val)) {
       resetBit(self,val);
       assignTRInt(&_sz, _sz._val -  1, _trail);
       [x loseValEvt:val];
       return CPSuspend;
   } 
   else
      return CPSuspend;   
}

-(void)restoreDomain:(CPBitDom*)toRestore
{
   _min._val = [toRestore min];
   _max._val = [toRestore max];
   _sz._val  = [toRestore domsize];
   const CPInt sz = _imax - _imin + 1;
   const CPInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   for(CPUInt k=0;k< nb ; k++) {
      _bits[k] = toRestore->_bits[k];
   }
}
-(void)restoreValue:(CPInt)toRestore
{
   _min._val = toRestore;
   _max._val = toRestore;
   _sz._val  = 1;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_min._val];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_max._val];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_sz._val];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_imin];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_imax];
   const CPInt sz = _imax - _imin + 1;
   const CPInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   for(CPInt k=0;k<nb;k++) {
      [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_bits[k]]; 
      [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_magic[k]]; 
   }
   [aCoder encodeObject:_trail];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_min._val];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_max._val];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_sz._val];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_imin];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_imax];
   const CPInt sz = _imax - _imin + 1;
   const CPInt nb = (sz >> 5) + ((sz & 0x1f)!=0);
   
   _bits  = malloc(sizeof(CPUInt)*nb);
   _magic = malloc(sizeof(CPInt)*nb);

   for(CPInt k=0;k<nb;k++) {
      [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_bits[k]];  
      [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_magic[k]]; 
   }
   _trail = [aDecoder decodeObject] ;
   return self;
}
@end
