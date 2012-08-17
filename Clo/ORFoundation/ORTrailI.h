/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>
#import "ORData.h"
#import "ORTrail.h"
#import "ORSet.h"

#define NBSLOT 8192

#define TAGShort        0x1
#define TAGInt          0x2
#define TAGUnsigned     0x3
#define TAGId           0x4
#define TAGFloat        0x5
#define TAGDouble       0x6
#define TAGLong         0x7
#define TAGUnsignedLong 0x8
#define TAGClosure      0x9
#define TAGRelease      0xA
#define TAGFree         0xB
#define TAGIdNC         0xC

@interface ORTrailI : NSObject<NSCoding,ORTrail>
{
   @public
   struct Slot {
      void* ptr;
      union {
         ORInt         intVal;          // 4-bytes
         ORUInt       uintVal;          // 4-bytes
         ORLong       longVal;          // 8-bytes
         ORULong     ulongVal;          // 8-bytes
         float       floatVal;          // 4-bytes
         double     doubleVal;          // 8-bytes
         id             idVal;          // 4-bytes OR 8-bytes depending 32/64 compilation mode
         void*         ptrVal;          // 4 or 8 (pointer)
         void (^cloVal)(void);
      };
      ORInt code;
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
-(ORUInt) trailSize;
-(void) resize;
-(void) incMagic;
-(void) trailInt:(ORInt*) ptr;
-(void) trailUnsigned:(ORUInt*) ptr;
-(void) trailLong:(ORLong*) ptr;
-(void) trailUnsignedLong:(ORULong*) ptr;
-(void) trailId:(id*) ptr;
-(void) trailIdNC:(id*) ptr;
-(void) trailFloat:(float*) ptr;
-(void) trailDouble:(double*) ptr;
-(void) trailClosure:(void(^) (void) ) clo;
-(void) trailRelease:(id)obj;
-(void) trailFree:(void*)ptr;
-(void) backtrack:(ORInt) to;
@end

@interface ORTrailIStack : NSObject {
   ORTrailI*  _trail;
   struct TRNode {
      ORInt   _x;
      ORInt _ofs;
   };
   struct TRNode*  _tab;
   ORInt        _sz;
   ORInt       _mxs;
}
-(ORTrailIStack*) initTrailStack: (ORTrailI*) tr;
-(void) dealloc;
-(void) pushNode:(ORInt) x;
-(void) popNode:(ORInt) x;
-(void) popNode;
-(void) reset;
-(bool) empty;
-(ORInt)size;
@end


@interface ORTrailableIntI : NSObject<ORTrailableInt>
-(ORTrailableIntI*) initORTrailableIntI: (ORTrailI*) trail value:(ORInt) value;
-(ORInt) value;
-(void)  setValue: (ORInt) value;
-(void)  incr;
-(void)  decr;
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
static inline TRDouble  inline_makeTRDouble(ORTrailI* trail,double val)
{
   return (TRDouble){val,[trail magic]-1};
}

static inline ORInt inline_assignTRIntArray(TRIntArray a,int i,ORInt val)
{
   TRInt* ei = a._entries + i;
   if (ei->_mgc != [a._trail magic]) {
      trailIntFun(a._trail, & ei->_val);
      ei->_mgc = [a._trail magic];
   }
   return ei->_val = val;
}

static inline void inline_trailIntFun(ORTrailI* t,int* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGInt;
   s->intVal = *ptr;
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
   id obj = *ptr;
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGIdNC;
   s->idVal = obj;
   ++(t->_seg[t->_cSeg]->top);
}

static inline void inline_assignTRInt(TRInt* v,int val,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailIntFun(trail, &v->_val);
   }
   v->_val = val;
}

static inline void  inline_assignTRUInt(TRUInt* v,unsigned val,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailUIntFun(trail, &v->_val);
   }
   v->_val = val;
}
static inline void  inline_assignTRLong(TRLong* v,long long val,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      [trail trailLong:&v->_val];
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
static inline void  inline_assignTRId(TRId* v,id val,ORTrailI* trail)
{
   [trail trailId:&v->_val];
   [v->_val release];
   v->_val = [val retain];
}
static inline void  inline_assignTRIdNC(TRIdNC* v,id val,ORTrailI* trail)
{
   trailIdNCFun(trail, &v->_val);
   v->_val = val;
}
static inline ORInt inline_getTRIntArray(TRIntArray a,int i)
{
   return a._entries[i]._val;
}
static inline void  inline_incrFXInt(FXInt* v,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
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
@end

@interface ORTRIntArrayI : NSObject<ORTRIntArray,NSCoding> {
   @package
   id<ORSolver> _solver;
   ORTrailI*    _trail;
   TRInt*       _array;
   ORInt        _low;
   ORInt        _up;
   ORInt        _nb;
}
-(ORTRIntArrayI*) initORTRIntArray: (id<ORSolver>) cp range: (id<ORIntRange>) R;
-(void) dealloc;
-(ORInt) at: (ORInt) value;
-(void) set: (ORInt) value at: (ORInt) idx;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORSolver>) solver;
-(ORInt) virtualOffset;
- (void) encodeWithCoder:(NSCoder *) aCoder;
- (id) initWithCoder:(NSCoder *) aDecoder;
@end



@interface ORTRIntMatrixI : NSObject<ORTRIntMatrix,NSCoding> {
@private
   id<ORSolver>    _solver;
   ORTrailI*       _trail;
   TRInt*          _flat;
   ORInt           _arity;
   id<ORIntRange>* _range;
   ORInt*          _low;
   ORInt*          _up;
   ORInt*          _size;
   ORInt*          _i;
   ORInt           _nb;
}
-(ORTRIntMatrixI*) initORTRIntMatrix: (id<ORSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
-(ORTRIntMatrixI*) initORTRIntMatrix: (id<ORSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
-(void) dealloc;
-(ORInt) at: (ORInt) i0 : (ORInt) i1;
-(ORInt) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1;
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(ORInt) add:(ORInt) delta at: (ORInt) i0 : (ORInt) i1;
-(ORInt) add:(ORInt) delta at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger) count;
-(id<ORSolver>) solver;
-(id<OREngine>) engine;
-(ORInt) virtualOffset;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
@end

