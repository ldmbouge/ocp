/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPTypes.h>

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

@interface CPTrail : NSObject<NSCoding> {
   @package
   struct Slot {
      void* ptr;
      union {
         CPInt         intVal;          // 4-bytes
         CPUInt       uintVal;          // 4-bytes
         CPLong       longVal;          // 8-bytes
         CPULong     ulongVal;          // 8-bytes
         float       floatVal;          // 4-bytes
         double     doubleVal;          // 8-bytes
         id             idVal;          // 4-bytes OR 8-bytes depending 32/64 compilation mode
         void (^cloVal)(void);         
      };
      CPInt code;
   };
   struct Segment {
      struct Slot tab[NBSLOT];
      CPInt  top;
   };
   struct Segment** _seg; // array of segments
   CPInt _cSeg;       // current segment
   CPInt _mxSeg;      // maximum # of segments
   @package
   CPUInt _magic;     // magic is always 32-bit wide
}
-(CPTrail*) init;
-(void) dealloc;
-(CPUInt) magic;
-(CPUInt) trailSize;
-(void)resize;
-(void) incMagic;
-(void) trailInt:(CPInt*) ptr;
-(void) trailUnsigned:(CPUInt*) ptr;
-(void) trailLong:(CPLong*) ptr;
-(void) trailUnsignedLong:(CPULong*) ptr;
-(void) trailId:(id*) ptr;
-(void) trailFloat:(float*) ptr;
-(void) trailDouble:(double*) ptr;
-(void) trailClosure:(void(^) (void) ) clo;
-(void) trailRelease:(id)obj;
-(void) backtrack:(CPInt) to;
@end

@interface CPTrailStack : NSObject {
   CPTrail*  _trail;
   struct TRNode {
      CPInt   _x;
      CPInt _ofs;
   };
   struct TRNode*  _tab;
   CPInt        _sz;
   CPInt       _mxs;
}
-(CPTrailStack*) initTrailStack: (CPTrail*) tr;
-(void) dealloc;
-(void) pushNode:(CPInt) x;
-(void) popNode:(CPInt) x;
-(void) popNode;
-(void) reset;
-(bool) empty;
-(CPInt)size;
@end

typedef struct {
   int    _val;   // TRInt should be a 32-bit wide trailable signed integer
   CPUInt _mgc;
} TRInt;

typedef struct {
   unsigned  _val;   // TRUInt should be a 32-bit wide trailable unsigned integer
   CPUInt _mgc;
} TRUInt;

typedef struct {
   long long _val;   // TRLong should be a 64-bit wide trailable signed integer
   CPUInt _mgc;
} TRLong;

typedef struct {
   double    _val;
   CPUInt _mgc;
} TRDouble;

typedef struct {
   id        _val;
   CPUInt _mgc;
} TRId;

typedef struct {
    CPTrail* _trail;
    int      _nb;
    int      _low;
    TRInt*   _entries;
} TRIntArray;


typedef struct {
   int       _val;
   CPUInt _mgc;
} FXInt;

static inline void trailIntFun(CPTrail* t,int* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGInt;
   s->intVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);   
}

static inline void trailUIntFun(CPTrail* t,unsigned* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGUnsigned;
   s->uintVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);   
}

TRInt makeTRInt(CPTrail* trail,int val);
TRUInt makeTRUInt(CPTrail* trail,unsigned val);
TRLong makeTRLong(CPTrail* trail,long long val);
TRDouble  makeTRDouble(CPTrail* trail,double val);
TRId  makeTRId(CPTrail* trail,id val);
TRIntArray makeTRIntArray(CPTrail* trail,int nb,int low);
void  freeTRIntArray(TRIntArray a);
FXInt makeFXInt(CPTrail* trail);

static inline void  assignTRInt(TRInt* v,int val,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailIntFun(trail, &v->_val);
   }
   v->_val = val;      
}
static inline void  assignTRUInt(TRUInt* v,unsigned val,CPTrail* trail) 
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailUIntFun(trail, &v->_val);
   }
   v->_val = val;         
}
static inline void  assignTRLong(TRLong* v,long long val,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      [trail trailLong:&v->_val];
   }
   v->_val = val;      
}
static inline void  assignTRDouble(TRDouble* v,double val,CPTrail* trail)
{
   if (v->_mgc != [trail magic]) {
      v->_mgc = [trail magic];
      [trail trailDouble:&v->_val];
   }
   v->_val = val;
}
static inline void  assignTRId(TRId* v,id val,CPTrail* trail)
{
   if (v->_mgc != [trail magic]) {
      v->_mgc = [trail magic];
      [trail trailId:&v->_val];
   }
   [v->_val release];
   v->_val = [val retain];         
}
static inline CPInt assignTRIntArray(TRIntArray a,int i,CPInt val)
{
   TRInt* ei = a._entries + i;
   if (ei->_mgc != a._trail->_magic) {
      trailIntFun(a._trail, & ei->_val);
      ei->_mgc = a._trail->_magic;
   }
   return ei->_val = val;
}
static inline CPInt getTRIntArray(TRIntArray a,int i)
{
   return a._entries[i]._val;
}
static inline void  incrFXInt(FXInt* v,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;      
   }
   v->_val++;
}
static inline int   getFXInt(FXInt* v,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;      
   }   
   return v->_val;
}
