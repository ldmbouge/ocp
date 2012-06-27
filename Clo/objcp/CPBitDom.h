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
#import "CPDom.h"
#import "CPTrail.h"
#import "objc/runtime.h"

@class CPSolverI;

@interface CPBoundsDom : NSObject<CPDom,NSCoding,NSCopying> {
@package
   CPTrail* _trail;
   TRInt      _min;
   TRInt      _max;
   TRInt       _sz;
   CPInt       _imin;
   CPInt       _imax;
}
-(CPBoundsDom*)initBoundsDomFor:(CPBoundsDom*)dom;
-(CPBoundsDom*)initBoundsDomFor:(CPTrail*)trail low:(CPInt)low up:(CPInt)up;
-(CPStatus)updateMin:(CPInt)newMin for:(id<CPIntVarNotifier>)x;
-(CPStatus)updateMax:(CPInt)newMax for:(id<CPIntVarNotifier>)x;
-(CPStatus)bind:(CPInt)val for:(id<CPIntVarNotifier>)x;
-(CPStatus)remove:(CPInt)val for:(id<CPIntVarNotifier>)x;
-(CPInt)min;
-(CPInt)max;
-(CPInt)imin;
-(CPInt)imax;
-(CPBounds)bounds;
-(bool)bound;
-(CPInt)domsize;
-(bool)member:(CPInt)v;
-(CPInt)findMin:(CPInt)from;
-(CPInt)findMax:(CPInt)from;
-(int(^)())getMin;
-(NSString*)description;
-(id)copyWithZone:(NSZone *)zone;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(CPInt)toRestore;
@end

static inline CPBounds domBounds(CPBoundsDom* dom)
{
   return (CPBounds){dom->_min._val,dom->_max._val};
}

@interface CPBitDom : CPBoundsDom {
@package
   unsigned*    _bits;
   CPInt*      _magic;
   UBType  _updateMin;
   UBType  _updateMax;   
}
//-(CPBitDom*)initBitDomFor:(CPTrail*)trail low:(CPInt)low up:(CPInt)up;
-(CPBitDom*)initBitDomFor:(CPTrail*)trail low:(CPInt)low up:(CPInt)up;
-(void)dealloc;
-(bool)get:(CPInt)b;
-(bool)member:(CPInt)b;
-(void)set:(CPInt)b at:(bool)v;
-(CPInt)setAllZeroFrom:(CPInt)from to:(CPInt)to;
-(CPInt)countFrom:(CPInt)from to:(CPInt)to;
-(CPInt)findMin:(CPInt)from;
-(CPInt)findMax:(CPInt)from;
-(CPInt)regret;
-(NSString*)description;
-(CPStatus)updateMin:(CPInt)newMin for:(id<CPIntVarNotifier>)x;
-(CPStatus)updateMax:(CPInt)newMax for:(id<CPIntVarNotifier>)x;
-(CPStatus)bind:(CPInt)val for:(id<CPIntVarNotifier>)x;
-(CPStatus)remove:(CPInt)val for:(id<CPIntVarNotifier>)x;
-(id)copyWithZone:(NSZone *)zone;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(CPInt)toRestore;
-(void)translate:(CPInt)shift;
@end

static const CPUInt __bitmasks[32] = {1,2,4,8,16,32,64,128,256,512,1024,2048,0x1000,0x2000,0x4000,0x8000,
   0x10000,0x20000,0x40000,0x80000,0x100000,0x200000,0x400000,0x8000000,0x1000000,0x2000000,
   0x4000000,0x8000000,0x10000000,0x20000000,0x40000000,0x80000000};

#define GETBIT(b) ((_bits[((b) - _imin)>>5] & (0x1 << (((b)-_imin) & 0x1f)))!=0)
#define GETBITPTR(x,b) ((((CPBitDom*)x)->_bits[((b) - ((CPBitDom*)x)->_imin)>>5] & (0x1 << (((b)-((CPBitDom*)x)->_imin) & 0x1f)))!=0)

static inline CPInt domMember(CPBoundsDom* x,CPInt value)
{
   static id ibnd = nil;
   if (ibnd==nil) {
      ibnd = objc_getClass("CPBoundsDom");
   }
   id cx = object_getClass(x);
   if (cx == ibnd) {
      return x->_min._val <= value && value <= x->_max._val;
   } else {
      const CPInt ofs = value - x->_imin;
      return x->_min._val <= value && value <= x->_max._val && (((CPBitDom*)x)->_bits[ofs>>5] & __bitmasks[ofs & 0x1f]);
   }
}

CPBitDom* newDomain(CPBitDom* bd,CPInt a,CPInt b);
static inline CPInt memberCPDom(CPBitDom* d,CPInt v) 
{
   return domMember(d, v);
}
static inline CPInt minCPDom(CPBitDom* d)
{
   return d->_min._val;
}
static inline CPInt maxCPDom(CPBitDom* d)
{
   return d->_max._val;
}
static inline CPInt getCPDom(CPBitDom* d,CPInt v)
{
   const CPInt ofs = v - d->_imin;
   return (d->_bits[ofs>>5] & __bitmasks[ofs & 0x1f]);
}
static inline void setCPDom(CPBitDom* d,CPInt b,BOOL v)
{
   return [d set:b at:v];
}
static inline CPInt sizeCPDom(CPBitDom* d)
{
   return d->_sz._val;
}
