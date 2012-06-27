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
   unsigned*   _bits;
   CPInt* _magic;
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
@end

#define GETBIT(b) ((_bits[((b) - _imin)>>5] & (0x1 << (((b)-_imin) & 0x1f)))!=0)
#define GETBITPTR(x,b) ((((CPBitDom*)x)->_bits[((b) - ((CPBitDom*)x)->_imin)>>5] & (0x1 << (((b)-((CPBitDom*)x)->_imin) & 0x1f)))!=0)

static inline BOOL domMember(CPBoundsDom* x,CPInt value)
{
   static id ibnd = nil;
   if (ibnd==nil) {
      ibnd = objc_getClass("CPBoundsDom");
   }
   id cx = object_getClass(x);
   if (cx == ibnd) {
      return ((CPBoundsDom*)x)->_min._val <= value && value <= ((CPBoundsDom*)x)->_max._val;
   } else {
      return ((CPBoundsDom*)x)->_min._val <= value && value <= ((CPBoundsDom*)x)->_max._val && GETBITPTR(x,value);
   }
}

typedef struct CPDomainTag {
   CPBitDom*    _dom;
   CPInt      _scale;
   CPInt      _shift;
} CPDomain;

static inline CPDomain newDomain(CPBitDom* bd,CPInt a,CPInt b)
{
   return (CPDomain){[bd copyWithZone:NULL],a,b};
}
static inline void freeDomain(CPDomain* d)
{
   [d->_dom release];
}
static inline BOOL memberCPDom(CPDomain* d,CPInt v) 
{
   CPInt vp;
   if (d->_scale == 1)
      vp = v - d->_shift;
   else if (d->_scale == -1) 
      vp = d->_shift - v;
   else {
      CPInt r = (v - d->_shift) % d->_scale;
      if (r != 0) return NO;
      vp = (v - d->_shift) / d->_scale;
   } 
   return domMember(d->_dom, vp);
}
static inline CPInt minCPDom(CPDomain* d)
{
   if (d->_scale > 0) 
      return d->_dom->_min._val * d->_scale + d->_shift;
   else return d->_dom->_max._val * d->_scale + d->_shift;
}
static inline CPInt maxCPDom(CPDomain* d)
{
   if (d->_scale > 0) 
      return d->_dom->_max._val * d->_scale + d->_shift;
   else return d->_dom->_min._val * d->_scale + d->_shift;
}
static inline BOOL getCPDom(CPDomain* d,CPInt v)
{
   CPInt vp;
   if (d->_scale == 1)
      vp = v - d->_shift;
   else if (d->_scale == -1) 
      vp = d->_shift - v;
   else {   
      CPInt r = (v - d->_shift) % d->_scale;
      if (r != 0) return NO;      
      vp = (v - d->_shift) / d->_scale;
   } 
   return GETBITPTR(d->_dom,vp);
}
static inline void setCPDom(CPDomain* d,CPInt b,BOOL v)
{
   CPInt nb = (b - d->_shift) / d->_scale;
   return [d->_dom set:nb at:v];
}
static inline CPInt sizeCPDom(CPDomain* d)
{
   return d->_dom->_sz._val;
}
