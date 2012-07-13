/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>

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

@interface ORTrail : NSObject<NSCoding> {
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
-(ORTrail*) init;
-(void) dealloc;
-(ORUInt) magic;
-(ORUInt) trailSize;
-(void)resize;
-(void) incMagic;
-(void) trailInt:(ORInt*) ptr;
-(void) trailUnsigned:(ORUInt*) ptr;
-(void) trailLong:(ORLong*) ptr;
-(void) trailUnsignedLong:(ORULong*) ptr;
-(void) trailId:(id*) ptr;
-(void) trailFloat:(float*) ptr;
-(void) trailDouble:(double*) ptr;
-(void) trailClosure:(void(^) (void) ) clo;
-(void) trailRelease:(id)obj;
-(void) trailFree:(void*)ptr;
-(void) backtrack:(ORInt) to;
@end

@interface ORTrailStack : NSObject {
   ORTrail*  _trail;
   struct TRNode {
      ORInt   _x;
      ORInt _ofs;
   };
   struct TRNode*  _tab;
   ORInt        _sz;
   ORInt       _mxs;
}
-(ORTrailStack*) initTrailStack: (ORTrail*) tr;
-(void) dealloc;
-(void) pushNode:(ORInt) x;
-(void) popNode:(ORInt) x;
-(void) popNode;
-(void) reset;
-(bool) empty;
-(ORInt)size;
@end

typedef struct {
   int    _val;   // TRInt should be a 32-bit wide trailable signed integer
   ORUInt _mgc;
} TRInt;

typedef struct {
   unsigned  _val;   // TRUInt should be a 32-bit wide trailable unsigned integer
   ORUInt _mgc;
} TRUInt;

typedef struct {
   long long _val;   // TRLong should be a 64-bit wide trailable signed integer
   ORUInt _mgc;
} TRLong;

typedef struct {
   double    _val;
   ORUInt _mgc;
} TRDouble;

typedef struct {
   id        _val;
} TRId;

typedef struct {
    ORTrail* _trail;
    int      _nb;
    int      _low;
    TRInt*   _entries;
} TRIntArray;


typedef struct {
   int       _val;
   ORUInt _mgc;
} FXInt;

@implementation ORTrail (Funs)
static inline void trailIntFun(ORTrail* t,int* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGInt;
   s->intVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);   
}

static inline void trailUIntFun(ORTrail* t,unsigned* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGUnsigned;
   s->uintVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);   
}

TRInt makeTRInt(ORTrail* trail,int val);
TRUInt makeTRUInt(ORTrail* trail,unsigned val);
TRLong makeTRLong(ORTrail* trail,long long val);
TRDouble  makeTRDouble(ORTrail* trail,double val);
TRId  makeTRId(ORTrail* trail,id val);
TRIntArray makeTRIntArray(ORTrail* trail,int nb,int low);
void  freeTRIntArray(TRIntArray a);
FXInt makeFXInt(ORTrail* trail);

static inline void  assignTRInt(TRInt* v,int val,ORTrail* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailIntFun(trail, &v->_val);
   }
   v->_val = val;      
}
static inline void  assignTRUInt(TRUInt* v,unsigned val,ORTrail* trail) 
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailUIntFun(trail, &v->_val);
   }
   v->_val = val;         
}
static inline void  assignTRLong(TRLong* v,long long val,ORTrail* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      [trail trailLong:&v->_val];
   }
   v->_val = val;      
}
static inline void  assignTRDouble(TRDouble* v,double val,ORTrail* trail)
{
   if (v->_mgc != [trail magic]) {
      v->_mgc = [trail magic];
      [trail trailDouble:&v->_val];
   }
   v->_val = val;
}
static inline void  assignTRId(TRId* v,id val,ORTrail* trail)
{
   [trail trailId:&v->_val];
   [v->_val release];
   v->_val = [val retain];
}
static inline ORInt assignTRIntArray(TRIntArray a,int i,ORInt val)
{
   TRInt* ei = a._entries + i;
   if (ei->_mgc != a._trail->_magic) {
      trailIntFun(a._trail, & ei->_val);
      ei->_mgc = a._trail->_magic;
   }
   return ei->_val = val;
}
static inline ORInt getTRIntArray(TRIntArray a,int i)
{
   return a._entries[i]._val;
}
static inline void  incrFXInt(FXInt* v,ORTrail* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;      
   }
   v->_val++;
}
static inline int   getFXInt(FXInt* v,ORTrail* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;      
   }   
   return v->_val;
}
static inline ORInt trailMagic(ORTrail* trail) {
   return trail->_magic;
}
@end
