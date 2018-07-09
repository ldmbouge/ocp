/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORTrail.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORTrailable.h>

//#include "rationalUtilities.h"

@protocol ORSearchEngine;

#define NBSLOT 8192

#define TAGShort        0x1
#define TAGInt          0x2
#define TAGUnsigned     0x3
#define TAGId           0x4
#define TAGFloat        0x5
#define TAGDouble       0x6
#define TAGLong         0x7
#define TAGUnsignedLong 0x8
#define TAGPointer      0x9
#define TAGClosure      0xA
#define TAGRelease      0xB
#define TAGFree         0xC
#define TAGIdNC         0xD
#define TAGLDouble      0xF
#define TAGRational     0x10

@interface ORTrailI : NSObject<ORTrail>
{
   @public
   struct Slot {
      void*               ptr;
      unsigned short     code;
      union {
         ORInt         intVal;          // 4-bytes
         ORUInt       uintVal;          // 4-bytes
         ORLong       longVal;          // 8-bytes
         ORULong     ulongVal;          // 8-bytes
         float       floatVal;          // 4-bytes
         ORRational  rationalVal;
         double     doubleVal;          // 8-bytes
         long double    ldVal;          // 10-byte
         void*         ptrVal;          // 4 or 8 (pointer)
      };
   };
   struct Segment {
      struct Slot tab[NBSLOT];
      ORInt  top;
   };
   struct Segment** _seg; // array of segments
   ORInt _cSeg;       // current segment
   ORInt _mxSeg;      // maximum # of segments
   ORUInt _magic;     // magic is always 32-bit wide
}
-(ORTrailI*) init;
-(void) dealloc;
-(ORUInt) magic;
-(ORInt) trailSize;
-(void) resize;
-(void) incMagic;
-(void) trailInt:(ORInt*) ptr;
-(void) trailUnsigned:(ORUInt*) ptr;
-(void) trailLong:(ORLong*) ptr;
-(void) trailUnsignedLong:(ORULong*) ptr;
-(void) trailId:(id*) ptr;
-(void) trailIdNC:(id*) ptr;
-(void) trailFloat:(float*) ptr;
-(void) trailRational:(ORRational *)ptr;
-(void) trailDouble:(double*) ptr;
-(void) trailLDouble:(long double*)ptr;
-(void) trailPointer:(void**) ptr;
-(void) trailClosure:(void(^) (void) ) clo;
-(void) trailRelease:(id)obj;
-(void) trailFree:(void*)ptr;
-(void) backtrack:(ORInt) to;
@end

@class ORCommandList;
@interface ORMemoryTrailI : NSObject<ORMemoryTrail,NSCopying> 
-(id)init;
-(id)copyWithZone:(NSZone *)zone;
-(void)dealloc;
-(id)track:(id)obj;
-(void)pop;
-(ORInt)trailSize;
-(void)clear;
-(void)comply:(id<ORMemoryTrail>)mt upTo:(ORCommandList*)cl;
-(void)comply:(ORMemoryTrailI*)mt from:(ORInt)fh to:(ORInt)th;
-(void)reload:(id<ORMemoryTrail>)t;
@end

@interface ORTrailIStack : NSObject {
   @package
   ORTrailI*        _trail;
   ORMemoryTrailI*     _mt;
   struct TRNode {
      ORInt    _x;
      ORInt  _ofs;
      ORInt _mOfs;
   };
   struct TRNode*     _tab;
   ORInt               _sz;
   ORInt              _mxs;
}
-(ORTrailIStack*) initTrailStack: (ORTrailI*) tr memory:(ORMemoryTrailI*)mt;
-(void) dealloc;
-(void) pushNode:(ORInt) x;
-(void) popNode:(ORInt) x;
-(void) popNode;
-(void) reset;
-(ORBool) empty;
-(ORInt)size;
@end

inline static void trailPop(ORTrailIStack* s)
{
   const ORInt ofs = s->_tab[--s->_sz]._ofs;
   const ORInt mof = s->_tab[s->_sz]._mOfs;
   [s->_trail backtrack: ofs];
   [s->_mt backtrack:mof];
}

@interface ORTrailableIntI : ORObject<ORTrailableInt>
-(ORTrailableIntI*) initORTrailableIntI: (id<ORTrail>) trail value:(ORInt) value;
-(ORInt) value;
-(ORInt) setValue: (ORInt) value;
-(ORInt)  incr;
-(ORInt)  decr;
@end

@implementation ORTrailI (InlineTrailFunction)
static inline TRInt inline_makeTRInt(ORTrailI* trail,int val)
{
   return (TRInt){val,[trail magic]-1};
}
static inline FXInt inline_makeFXInt(ORTrailI* trail)
{
   return (FXInt){0,[trail magic]-1};
}
static inline TRUInt inline_makeTRUInt(ORTrailI* trail,unsigned val)
{
   return (TRUInt) {val,[trail magic]-1};
}
static inline TRLong inline_makeTRLong(ORTrailI* trail,long long val)
{
   return (TRLong) {val,[trail magic]-1};
}
static inline TRId  inline_makeTRId(ORTrailI* trail,id val)
{
   return (TRId) {val};
}
static inline TRIdNC  inline_makeTRIdNC(ORTrailI* trail,id val)
{
   return (TRIdNC) {val};
}
static inline TRFloat inline_makeTRFloat(ORTrailI* trail,float val)
{
   return (TRFloat){val,[trail magic]-1};
}
static inline TRDouble  inline_makeTRDouble(ORTrailI* trail,double val)
{
   return (TRDouble){val,[trail magic]-1};
}
static inline TRLDouble  inline_makeTRLDouble(ORTrailI* trail,long double val)
{
   return (TRLDouble){val,[trail magic]-1};
}
static inline TRRational inline_makeTRRational(ORTrailI* trail, ORRational val)
{
    return (TRRational){val, [trail magic]-1};
}

static inline ORInt inline_assignTRIntArray(TRIntArray a,int i,ORInt val,id<ORTrail> trail)
{
   TRInt* ei = a._entries + i;
   if (ei->_mgc != [trail magic]) {
      trailIntFun(trail, & ei->_val);
      ei->_mgc = [trail magic];
   }
   return ei->_val = val;
}

static inline ORDouble inline_assignTRDoubleArray(TRDoubleArray a,int i,ORDouble val,id<ORTrail> trail)
{
   TRDouble* ei = a._entries + i;
   if (ei->_mgc != [trail magic]) {
      trailDoubleFun(trail, & ei->_val);
      ei->_mgc = [trail magic];
   }
   return ei->_val = val;
}

static inline void inline_trailIntFun(ORTrailI* t,int* ptr)
{
   struct Segment* seg = t->_seg[t->_cSeg];
   if (seg->top >= NBSLOT-1) {
      [t resize];
      seg = t->_seg[t->_cSeg];
   }
   struct Slot* s = seg->tab + seg->top++;
   s->ptr = ptr;
   s->code = TAGInt;
   s->intVal = *ptr;
}

static inline void inline_trailLongFun(ORTrailI* t,long long* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGLong;
   s->longVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);
}

static inline void inline_trailPointerFun(ORTrailI* t,void** ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGPointer;
   s->ptrVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);
}

static inline void inline_trailUIntFun(ORTrailI* t,unsigned* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGUnsigned;
   s->uintVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);
}
static inline void inline_trailIdNCFun(ORTrailI* t,id* ptr)
{
   struct Segment* seg = t->_seg[t->_cSeg];
   if (seg->top >= NBSLOT-1) {
      [t resize];
      seg = t->_seg[t->_cSeg];
   }
   struct Slot* s = seg->tab + seg->top++;
   s->ptr = ptr;
   s->code = TAGIdNC;
   s->ptrVal = (__bridge void*) *ptr;
}
static inline void inline_assignTRInt(TRInt* v,int val,id<ORTrail> trail)
{
   ORInt cmgc = ((ORTrailI*)trail)->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      inline_trailIntFun((ORTrailI*)trail, &v->_val);
   }
   v->_val = val;
}

static inline void  inline_assignTRUInt(TRUInt* v,unsigned val,id<ORTrail> trail)
{
   ORInt cmgc = ((ORTrailI*)trail)->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      inline_trailUIntFun((ORTrailI*)trail, &v->_val);
   }
   v->_val = val;
}
static inline void  inline_assignTRLong(TRLong* v,long long val,id<ORTrail> trail)
{
   ORInt cmgc = ((ORTrailI*)trail)->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      inline_trailLongFun((ORTrailI*)trail,&v->_val);
      //[trail trailLong:&v->_val];
   }
   v->_val = val;
}
static inline void  inline_assignTRDouble(TRDouble* v,double val,ORTrailI* trail)
{
   if (v->_mgc != [trail magic]) {
      v->_mgc = [trail magic];
      [trail trailDouble:&v->_val];
   }
   v->_val = val;
}
static inline void  inline_assignTRId(TRId* v,id val,id<ORTrail> trail)
{
   [trail trailId:v];
#if __has_feature(objc_arc)
   *v = val;
#else
   [*v release];
   *v = [val retain];
#endif
}
static inline void  inline_assignTRIdNC(TRIdNC* v,id val,id<ORTrail> trail)
{
   inline_trailIdNCFun((ORTrailI*)trail, v);
   *v = val;
}
static inline ORInt inline_getTRIntArray(TRIntArray a,int i)
{
   return a._entries[i]._val;
}
static inline void  inline_incrFXInt(FXInt* v,id<ORTrail> trail)
{
   ORInt cmgc = ((ORTrailI*)trail)->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;
   }
   v->_val++;
}
static inline int inline_getFXInt(FXInt* v,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;
   }
   return v->_val;
}
static inline ORInt inline_trailMagic(ORTrailI* trail)
{
   return trail->_magic;
}


#define MAKETRPointer(T,V) \
typedef struct { \
   V*      _val; \
   ORUInt _mgc; \
} T; \
static inline T inline_make##T(id<ORTrail> trail,V* val) \
{ \
   return (T) { val, [trail magic]-1}; \
} \
static inline void inline_assign##T(T* v,V* val,id<ORTrail> trail) \
{ \
   ORInt cmgc = ((ORTrailI*)trail)->_magic; \
   if (v->_mgc != cmgc) { \
      v->_mgc = cmgc; \
      inline_trailPointerFun((ORTrailI*)trail, (void**)&v->_val); \
   } \
   v->_val = val; \
} \
static inline V* get##T(T* v) { return v->_val;}


@end

@interface ORTRIntArrayI : NSObject<ORTRIntArray> {
   @package
   ORTrailI*    _trail;
   TRInt*       _array;
   ORInt        _low;
   ORInt        _up;
   ORInt        _nb;
}
-(ORTRIntArrayI*) initORTRIntArray: (id<ORSearchEngine>) cp range: (id<ORIntRange>) R;
-(void) dealloc;
-(ORInt) at: (ORInt) value;
-(void) set: (ORInt) value at: (ORInt) idx;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger) count;
-(NSString*) description;
- (void) encodeWithCoder:(NSCoder *) aCoder;
- (id) initWithCoder:(NSCoder *) aDecoder;
@end

@interface ORTRIntMatrixI : NSObject<ORTRIntMatrix> 
-(ORTRIntMatrixI*) initORTRIntMatrix: (id<ORSearchEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
-(ORTRIntMatrixI*) initORTRIntMatrix: (id<ORSearchEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
-(void) dealloc;
-(ORInt) at: (ORInt) i0 : (ORInt) i1;
-(ORInt) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1;
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(ORInt) add:(ORInt) delta at: (ORInt) i0 : (ORInt) i1;
-(ORInt) add:(ORInt) delta at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger) count;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
@end

