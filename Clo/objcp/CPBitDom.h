/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTrail.h>
#import <objcp/CPDom.h>

@class CPEngineI;

enum CPDomClass {
   DCBounds = 0,
   DCBits = 1,
   DCLRanges = 2
};

@interface CPBoundsDom : NSObject<CPDom,NSCoding,NSCopying> {
@package
   enum CPDomClass    _dc;
   ORTrail*        _trail;
   TRInt             _min;
   TRInt             _max;
   TRInt              _sz;
   CPInt            _imin;
   CPInt            _imax;
}
-(CPBoundsDom*)initBoundsDomFor:(CPBoundsDom*)dom;
-(CPBoundsDom*)initBoundsDomFor:(ORTrail*)trail low:(ORInt)low up:(ORInt)up;
-(ORStatus)updateMin:(ORInt)newMin for:(id<CPIntVarNotifier>)x;
-(ORStatus)updateMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x;
-(ORStatus)bind:(ORInt)val for:(id<CPIntVarNotifier>)x;
-(ORStatus)remove:(ORInt)val for:(id<CPIntVarNotifier>)x;
-(ORInt)min;
-(ORInt)max;
-(ORInt)imin;
-(ORInt)imax;
-(CPBounds)bounds;
-(bool)bound;
-(ORInt)domsize;
-(bool)member:(ORInt)v;
-(ORInt)findMin:(ORInt)from;
-(ORInt)findMax:(ORInt)from;
-(int(^)())getMin;
-(NSString*)description;
-(id)copyWithZone:(NSZone *)zone;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(ORInt)toRestore;
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
-(CPBitDom*)initBitDomFor:(ORTrail*)trail low:(ORInt)low up:(ORInt)up;
-(void)dealloc;
-(bool)get:(ORInt)b;
-(bool)member:(ORInt)b;
-(void)set:(ORInt)b at:(bool)v;
-(ORInt)setAllZeroFrom:(ORInt)from to:(ORInt)to;
-(ORInt)countFrom:(ORInt)from to:(ORInt)to;
-(ORInt)findMin:(ORInt)from;
-(ORInt)findMax:(ORInt)from;
-(ORInt)regret;
-(NSString*)description;
-(ORStatus)updateMin:(ORInt)newMin for:(id<CPIntVarNotifier>)x;
-(ORStatus)updateMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x;
-(ORStatus)bind:(ORInt)val for:(id<CPIntVarNotifier>)x;
-(ORStatus)remove:(ORInt)val for:(id<CPIntVarNotifier>)x;
-(id)copyWithZone:(NSZone *)zone;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(ORInt)toRestore;
-(void)translate:(ORInt)shift;
@end

static const CPUInt __bitmasks[32] = {
      0x00000001,0x00000002,0x00000004,0x00000008,
      0x00000010,0x00000020,0x00000040,0x00000080,
      0x00000100,0x00000200,0x00000400,0x00000800,
      0x00001000,0x00002000,0x00004000,0x00008000,
      0x00010000,0x00020000,0x00040000,0x00080000,
      0x00100000,0x00200000,0x00400000,0x00800000,
      0x01000000,0x02000000,0x04000000,0x08000000,
      0x10000000,0x20000000,0x40000000,0x80000000};

#define GETBIT(b) ((_bits[((b) - _imin)>>5] & (0x1 << (((b)-_imin) & 0x1f)))!=0)
#define GETBITPTR(x,b) ((((CPBitDom*)x)->_bits[((b) - ((CPBitDom*)x)->_imin)>>5] & (0x1 << (((b)-((CPBitDom*)x)->_imin) & 0x1f)))!=0)

static inline CPInt domMember(CPBoundsDom* x,CPInt value)
{
   switch(x->_dc) {
      case DCBounds:
         return x->_min._val <= value && value <= x->_max._val;
      case DCBits: {
         if (x->_min._val <= value && value <= x->_max._val) {
            const CPInt ofs = value - x->_imin;
            return (((CPBitDom*)x)->_bits[ofs>>5] & (0x1 << (ofs & 0x1f))) != 0;
         } else return 0;         
      }
      default: return 0;
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
   const CPUInt ofs = v - d->_imin;
   //return (d->_bits[ofs>>5] & __bitmasks[ofs & 0x1f]);
   return (d->_bits[ofs>>5] & (0x1 << (ofs & 0x1f)));
}
static inline void setCPDom(CPBitDom* d,CPInt b,BOOL v)
{
   return [d set:b at:v];
}
static inline CPInt sizeCPDom(CPBitDom* d)
{
   return d->_sz._val;
}
