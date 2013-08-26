/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORTrail.h"
#import "ORTrailI.h"
#import <ORFoundation/OREngine.h>
#import "ORError.h"
#import "ORData.h"
#import <assert.h>
#import "ORVisit.h"


@implementation ORTrailI
-(ORTrailI*) init
{
   self = [super init];
   _mxSeg = 32;
   _cSeg  = 0;
   _seg = malloc(sizeof(struct Segment*)*_mxSeg);
   _magic = -1;
   memset(_seg,0,sizeof(struct Segment*)*_mxSeg);
   _seg[0] = malloc(sizeof(struct Segment));
   _seg[0]->top = 0;
   return self;
}
-(void)dealloc
{
   NSLog(@"ORTrailI %p dealloc called...\n",self);
   for(ORInt k=0;k<_mxSeg;k++)
      if (_seg[k])
         free(_seg[k]);
   free(_seg);
   [super dealloc];
}
-(ORUInt)magic
{
   return _magic;
}
-(void)incMagic
{
   ++_magic;
}
-(void)resize
{
   if (_cSeg == _mxSeg - 1) {
      _seg = realloc(_seg, sizeof(struct Segment*)*_mxSeg*2);
      memset(_seg + _mxSeg,0,sizeof(struct Segment*)*_mxSeg);
      _mxSeg <<= 1;
   }
   if (_seg[++_cSeg] == 0)
      _seg[_cSeg] = malloc(sizeof(struct Segment));
   _seg[_cSeg]->top = 0;
}
-(void)trailInt:(ORInt*)ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGInt;
   s->intVal = *ptr;
   ++_seg[_cSeg]->top;
}
-(void)trailUnsigned:(ORUInt*)ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGUnsigned;
   s->uintVal = *ptr;
   ++_seg[_cSeg]->top;
}
-(void)trailId:(id*)ptr
{
   id obj = *ptr;
   [obj retain];
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGId;
   s->idVal = obj;
   ++_seg[_cSeg]->top;
}
-(void)trailIdNC:(id*)ptr
{
   id obj = *ptr;
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGIdNC;
   s->idVal = obj;
   ++_seg[_cSeg]->top;
}
-(void) trailLong:(ORLong*) ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGLong;
   s->longVal = *ptr;
   ++_seg[_cSeg]->top;
}
-(void) trailUnsignedLong:(ORULong*) ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGUnsignedLong;
   s->ulongVal = *ptr;
   ++_seg[_cSeg]->top;
}

-(void)trailFloat:(float*)ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGFloat;
   s->floatVal = *ptr;
   ++_seg[_cSeg]->top;
}
-(void)trailDouble:(double*)ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGDouble;
   s->doubleVal = *ptr;
   ++_seg[_cSeg]->top;
}
-(void) trailPointer:(void**) ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGPointer;
   s->ptrVal = *ptr;
   ++_seg[_cSeg]->top;
}

-(void)trailClosure:(void(^)(void))clo
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = 0;
   s->code = TAGClosure;
   s->cloVal = [clo copy];
   ++_seg[_cSeg]->top;
}
-(void) trailRelease:(id)obj
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = 0;
   s->code = TAGRelease;
   s->idVal = obj;
   ++_seg[_cSeg]->top;
}
-(void) trailFree:(void*)ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = 0;
   s->code = TAGFree;
   s->ptrVal = ptr;
   ++_seg[_cSeg]->top;
}

-(ORInt)trailSize
{
   return _cSeg * NBSLOT + _seg[_cSeg]->top;
}

-(void)backtrack:(ORInt)to
{
   ORInt segId = to / NBSLOT;
   ORInt inSeg = to % NBSLOT;
   ORInt cSeg  = _cSeg;
   while (segId <= cSeg) {
      struct Slot* target = _seg[cSeg]->tab + ((segId == cSeg) ? inSeg : 0);
      struct Slot* cs     = _seg[cSeg]->tab + _seg[cSeg]->top;
      while (cs != target) {
         switch ((--cs)->code) {
            case TAGShort:
               *((short*)cs->ptr) = cs->intVal;
               break;
            case TAGInt:
               *((int*)cs->ptr) = cs->intVal;
               break;
            case TAGUnsigned:
               *((unsigned*)cs->ptr) = cs->uintVal;
               break;
            case TAGLong:
               *((long long*)cs->ptr) = cs->longVal;
               break;
            case TAGUnsignedLong:
               *((unsigned long long*)cs->ptr) = cs->ulongVal;
               break;
            case TAGId: {
               if (*((id*)cs->ptr))
                  [(*((id*)cs->ptr)) release];
               *((id*)cs->ptr) = cs->idVal;
            }break;
            case TAGFloat:
               *((float*)cs->ptr) = cs->floatVal;
               break;
            case TAGDouble:
               *((double*)cs->ptr) = cs->doubleVal;
               break;
            case TAGPointer:
               *((void**)cs->ptr) = cs->ptrVal;
               break;
            case TAGClosure:
               cs->cloVal();
               [cs->cloVal release];
               break;
            case TAGRelease:
               [cs->idVal release];
               break;
            case TAGFree:
               free(cs->ptrVal);
               break;
            case TAGIdNC:
               *((id*)cs->ptr) = cs->idVal;
               break;
            default:
               break;
         }
      }
      _seg[cSeg]->top = (ORInt)(cs - _seg[cSeg]->tab);
      --cSeg;
   }
   _cSeg = segId;
   assert(_seg[_cSeg]->top == inSeg);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   // Only send the # of segments and the current magic
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_mxSeg];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_magic];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   // Allocate the right number of segments. Start with an empty trail in the clone.
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_mxSeg];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_magic];
   _seg = malloc(sizeof(struct Segment*)*_mxSeg);
   memset(_seg,0,sizeof(struct Segment*)*_mxSeg);
   _seg[0] = malloc(sizeof(struct Segment));
   _seg[0]->top = 0;
   _cSeg = 0;
   return self;
}
@end

@implementation ORTrailFunction

TRInt makeTRInt(ORTrailI* trail,int val)
{
   return (TRInt){val,[trail magic]-1};
}
FXInt makeFXInt(ORTrailI* trail)
{
   return (FXInt){0,[trail magic]-1};
}
TRUInt makeTRUInt(ORTrailI* trail,unsigned val)
{
   return (TRUInt) {val,[trail magic]-1};
}
TRLong makeTRLong(ORTrailI* trail,long long val)
{
   return (TRLong) {val,[trail magic]-1};
}
TRId  makeTRId(ORTrailI* trail,id val)
{
   return (TRId) {val};
}
TRIdNC  makeTRIdNC(ORTrailI* trail,id val)
{
   return (TRIdNC) {val};
}
TRDouble  makeTRDouble(ORTrailI* trail,double val)
{
   return (TRDouble){val,[trail magic]-1};
}

ORInt assignTRIntArray(TRIntArray a,int i,ORInt val)
{
   TRInt* ei = a._entries + i;
   if (ei->_mgc != [a._trail magic]) {
      trailIntFun((ORTrailI*)a._trail, & ei->_val);
      ei->_mgc = [a._trail magic];
   }
   return ei->_val = val;
}

void trailIntFun(ORTrailI* t,int* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGInt;
   s->intVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);
}
void trailFloatFun(ORTrailI* t,ORFloat* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGDouble;
   s->intVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);
}
void trailUIntFun(ORTrailI* t,unsigned* ptr)
{
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGUnsigned;
   s->uintVal = *ptr;
   ++(t->_seg[t->_cSeg]->top);
}
void trailIdNCFun(ORTrailI* t,id* ptr)
{
   id obj = *ptr;
   if (t->_seg[t->_cSeg]->top >= NBSLOT-1) [t resize];
   struct Slot* s = t->_seg[t->_cSeg]->tab + t->_seg[t->_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGIdNC;
   s->idVal = obj;
   ++(t->_seg[t->_cSeg]->top);
}

void assignTRInt(TRInt* v,int val,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      inline_trailIntFun(trail, &v->_val);
   }
   v->_val = val;
}

void  assignTRUInt(TRUInt* v,unsigned val,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      inline_trailUIntFun(trail, &v->_val);
   }
   v->_val = val;
}
void  assignTRLong(TRLong* v,long long val,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      [trail trailLong:&v->_val];
   }
   v->_val = val;
}
void  assignTRDouble(TRDouble* v,double val,ORTrailI* trail)
{
   if (v->_mgc != [trail magic]) {
      v->_mgc = [trail magic];
      [trail trailDouble:&v->_val];
   }
   v->_val = val;
}
void  assignTRId(TRId* v,id val,ORTrailI* trail)
{
   [trail trailId:&v->_val];
   [v->_val release];
   v->_val = [val retain];
}
void  assignTRIdNC(TRIdNC* v,id val,ORTrailI* trail)
{
   inline_trailIdNCFun(trail, &v->_val);
   v->_val = val;
}
ORInt getTRIntArray(TRIntArray a,int i)
{
   return a._entries[i]._val;
}
void  incrFXInt(FXInt* v,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;
   }
   v->_val++;
}
int getFXInt(FXInt* v,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;
   }
   return v->_val;
}
ORInt trailMagic(ORTrailI* trail)
{
   return trail->_magic;
}
@end

@implementation ORMemoryTrailI
-(id)init
{
   self = [super init];
   _mxs = 128;
   _csz = 0;
   _tab = malloc(sizeof(id)*_mxs);
   return self;
}
-(id)initWith:(ORMemoryTrailI*)mt
{
   self = [super init];
   _mxs = mt->_mxs;
   _csz = mt->_csz;
   _tab = malloc(sizeof(id)*_mxs);
   for(ORInt i=0;i<_csz;i++)
      _tab[i] = [mt->_tab[i] retain];
   return self;
}
-(void)dealloc
{
   while (_csz)
      [_tab[--_csz] release];
   free(_tab);
   [super dealloc];
}
-(id)copyWithZone:(NSZone *)zone
{
   return [[ORMemoryTrailI alloc] initWith:self];
}
-(void)resize
{
   _tab = realloc(_tab, _mxs * 2);
   _mxs = _mxs * 2;
}
-(id)track:(id)obj
{
   if (_csz >= _mxs)
      [self resize];
   _tab[_csz++] = [obj retain];
   return obj;
}
-(void)pop
{
   [_tab[--_csz] release];
}
-(ORInt) trailSize
{
   return _csz;
}
-(void)backtrack:(ORInt)to
{
   while (_csz > to)
      [_tab[--_csz] release];
}
-(void)clear
{
   while (_csz)
      [_tab[--_csz] release];
}
-(void)comply:(ORMemoryTrailI*)mt upTo:(ORInt)mh
{
//   while (_csz > mt->_csz)
//      [_tab[--_csz] release];
   assert(_csz <= mt->_csz);
   ORInt k = _csz;
   while (_csz < mh)
      _tab[_csz++] = [mt->_tab[k++] retain];
}
-(void)reload:(ORMemoryTrailI*)t
{
   const ORInt h = min(t->_csz,_csz);
   ORInt i;
   for(i = 0;i < h && _tab[i] == t->_tab[i];i++);
   while(_csz != i)
      [_tab[--_csz] release];
   while(_csz < t->_csz)
      _tab[_csz++] = [t->_tab[i++] retain];
}


-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"ORMemoryTrail(%d / %d)[",_csz,_mxs];
   for(ORInt i =0;i<_csz-1;i++)
      [buf appendFormat:@"%p,",_tab[i]];
   [buf appendFormat:@"%p]",_tab[_csz-1]];
   return buf;
}
@end

@implementation ORTrailIStack
-(ORTrailIStack*) initTrailStack: (ORTrailI*)tr memory:(ORMemoryTrailI*)mt
{
   self = [super init];
   _trail = [tr retain];
   _mt    = [mt retain];
   _sz  = 0;
   _mxs = 1024;
   _tab = malloc(sizeof(struct TRNode)*_mxs);
   memset(_tab,0,sizeof(struct TRNode)*_mxs);
   return self;
}
-(void)dealloc
{
   free(_tab);
   [_trail release];
   [_mt    release];
   [super dealloc];
}
-(void)pushNode:(ORInt)x
{
   if (_sz >= _mxs) {
      _tab = realloc(_tab,sizeof(struct TRNode)*_mxs*2);
      _mxs <<= 1;
   }
   _tab[_sz++] = (struct TRNode){x,[_trail trailSize],[_mt trailSize]};
}
-(void)popNode:(ORInt) x
{
   do {
      --_sz;
   } while(_sz>0 && (_tab[_sz]._x != x));
   const ORInt ofs  = _tab[_sz]._ofs;
   const ORInt mOfs = _tab[_sz]._mOfs;
   [_trail backtrack:ofs];
   [_mt    backtrack:mOfs];
}
-(void)popNode
{
   assert(_sz > 0);
   const ORInt mto = _tab[--_sz]._mOfs;
   const ORInt to  = _tab[_sz]._ofs;
   [_trail backtrack: to];
   [_mt    backtrack: mto];
}
-(void)reset
{
   _sz = 0;
}
-(ORBool)empty
{
   return _sz == 0;
}
-(ORInt)size
{
   return _sz;
}
@end

TRIntArray makeTRIntArray(ORTrailI* trail,int nb,int low)
{
   TRIntArray x = {trail,nb,low,NULL};
   x._entries = malloc(sizeof(TRInt)*nb);
   for(int i = 0; i < nb; i++)
      x._entries[i] = makeTRInt(trail,0);
   x._entries -= low;
   return x;
}
void freeTRIntArray(TRIntArray a)
{
   a._entries += a._low;
   free(a._entries);
}

@implementation ORTrailableIntI
{
   TRInt    _trint;
   ORTrailI* _trail;
}
-(ORTrailableIntI*) initORTrailableIntI: (ORTrailI*) trail value:(ORInt) value
{
   self = [super init];
   _trail = trail;
   _trint = makeTRInt(_trail,value);
   return self;
}
-(ORInt) value
{
   return _trint._val;
}
-(ORInt) setValue: (ORInt) value
{
   assignTRInt(&_trint,value,_trail);
   return value;
}
-(ORInt)  incr
{
   assignTRInt(&_trint,_trint._val+1,_trail);
   return _trint._val;
}
-(ORInt)  decr
{
   assignTRInt(&_trint,_trint._val-1,_trail);
   return _trint._val;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:32] autorelease];
   [buf appendFormat:@"TR<int>(%d)",_trint._val];
   return buf;
}
-(void)visit:(ORVisitor*)visitor
{
   [visitor visitTrailableInt:self];
}
@end

/**********************************************************************************************/
/*                          ORTRIntArray                                                      */
/**********************************************************************************************/


@implementation ORTRIntArrayI
-(ORTRIntArrayI*) initORTRIntArray: (id<ORSearchEngine>) engine range: (id<ORIntRange>) R
{
   self = [super init];
   _trail = (ORTrailI*)[engine trail];
   _low = [R low];
   _up = [R up];
   _nb = (_up - _low + 1);
   _array = malloc(_nb * sizeof(TRInt));
   _array -= _low;
   for(ORInt i = _low; i <= _up; i++)
      _array[i] = makeTRInt(_trail,0);
   return self;
}
-(void) dealloc
{
   _array += _low;
   free(_array);
   [super dealloc];
}

-(ORInt) at: (ORInt) value
{
   if (value < _low || value > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORTRIntArrayElement"];
   return _array[value]._val;
}

-(void) set: (ORInt) value at: (ORInt) idx
{
   if (idx < _low || idx > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORTRIntArrayElement"];
   inline_assignTRInt(_array + idx,value,_trail);
}

-(ORInt) low
{
   return _low;
}
-(ORInt) up
{
   return _up;
}
-(NSUInteger)count
{
   return _nb;
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendString:@"["];
   for(ORInt i=_low;i<=_up;i++) {
      [rv appendFormat:@"%d:%d",i,_array[i]._val];
      if (i < _up)
         [rv appendString:@","];
   }
   [rv appendString:@"]"];
   return rv;
}
- (void) encodeWithCoder: (NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   for(ORInt i=_low;i<=_up;i++) {
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_array[i]._val];
      [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_array[i]._mgc];
   }
}
-(id) initWithCoder: (NSCoder*) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
   _array =  malloc(sizeof(TRInt)*_nb);
   _array -= _low;
   for(ORInt i=_low;i<=_up;i++) {
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_array[i]._val];
      [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_array[i]._mgc];
   }
   return self;
}
@end

/*********************************************************************************/
/*             Multi-Dimensional Matrix of Trailable Int                         */
/*********************************************************************************/

@implementation ORTRIntMatrixI

-(ORTRIntMatrixI*) initORTRIntMatrix:(id<ORSearchEngine>) engine range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   self = [super init];
   _trail = (ORTrailI*)[engine trail];
   _arity = 3;
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _range[0] = r0;
   _range[1] = r1;
   _range[2] = r2;
   _low[0] = [r0 low];
   _low[1] = [r1 low];
   _low[2] = [r2 low];
   _up[0] = [r0 up];
   _up[1] = [r1 up];
   _up[2] = [r2 up];
   _size[0] = (_up[0] - _low[0] + 1);
   _size[1] = (_up[1] - _low[1] + 1);
   _size[2] = (_up[2] - _low[2] + 1);
   _nb = _size[0] * _size[1] * _size[2];
   _flat = malloc(sizeof(TRInt) * _nb);
   for (ORInt i=0 ; i < _nb; i++)
      _flat[i] = inline_makeTRInt(_trail,0);
   return self;
}

-(ORTRIntMatrixI*) initORTRIntMatrix:(id<ORSearchEngine>) engine range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   self = [super init];
   _trail = (ORTrailI*)[engine trail];
   _arity = 2;
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _range[0] = r0;
   _range[1] = r1;
   _low[0] = [r0 low];
   _low[1] = [r1 low];
   _up[0] = [r0 up];
   _up[1] = [r1 up];
   _size[0] = (_up[0] - _low[0] + 1);
   _size[1] = (_up[1] - _low[1] + 1);
   _nb = _size[0] * _size[1];
   _flat = malloc(sizeof(TRInt) * _nb);
   for (ORInt i=0 ; i < _nb; i++)
      _flat[i] = inline_makeTRInt(_trail,0);
   return self;
}

-(void) dealloc
{
   //   NSLog(@"CPIntVarMatrix dealloc called...\n");
   free(_range);
   free(_low);
   free(_up);
   free(_size);
   free(_flat);
   [super dealloc];
}
static inline ORInt indexMatrix(ORTRIntMatrixI* m,ORInt* i)
{
   for(ORInt k = 0; k < m->_arity; k++)
      if (i[k] < m->_low[k] || i[k] > m->_up[k])
         @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in ORTRIntMatrix"];
   ORInt idx = i[0] - m->_low[0];
   for(ORInt k = 1; k < m->_arity; k++)
      idx = idx * m->_size[k] + (i[k] - m->_low[k]);
   return idx;
}
-(id<ORIntRange>) range: (ORInt) i
{
   if (i < 0 || i >= _arity)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in ORTRIntMatrix"];
   return _range[i];
}
-(ORInt) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2
{
   if (_arity != 3)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORTRIntMatrix"];
   ORInt i[3] = {i0,i1,i2};
   return _flat[indexMatrix(self,i)]._val;
}
-(ORInt) at: (ORInt) i0 : (ORInt) i1
{
   if (_arity != 2)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORTRIntMatrix"];
   ORInt i[2] = {i0,i1};
   return _flat[indexMatrix(self,i)]._val;
}

-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2
{
   if (_arity != 3)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORTRIntMatrix"];
   ORInt i[3] = {i0,i1,i2};
   inline_assignTRInt(_flat + indexMatrix(self,i),value,_trail);
}
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1
{
   if (_arity != 2)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORTRIntMatrix"];
   ORInt i[3] = {i0,i1};
   inline_assignTRInt(_flat + indexMatrix(self,i),value,_trail);
}
-(ORInt) add:(ORInt) delta at: (ORInt) i0 : (ORInt) i1
{
   if (_arity != 2)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORTRIntMatrix"];
   ORInt i[2] = {i0,i1};
   TRInt* ptr = _flat + indexMatrix(self,i);
   inline_assignTRInt(ptr,ptr->_val + delta,_trail);
   return ptr->_val;
}
-(ORInt) add:(ORInt) delta at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2
{
   if (_arity != 3)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORTRIntMatrix"];
   ORInt i[3] = {i0,i1,i2};
   TRInt* ptr = _flat + indexMatrix(self,i);
   inline_assignTRInt(ptr,ptr->_val + delta,_trail);
   return ptr->_val;
}
-(NSUInteger) count
{
   return _nb;
}
-(void) descriptionAux: (ORInt*) i depth:(ORInt)d string: (NSMutableString*) rv
{
   if (d == _arity) {
      [rv appendString:@"<"];
      for(ORInt k = 0; k < _arity; k++)
         [rv appendFormat:@"%d,",_i[k]];
      [rv appendString:@"> ="];
      [rv appendFormat:@"%d \n",_flat[indexMatrix(self, i)]._val];
   }
   else {
      for(ORInt k = _low[d]; k <= _up[d]; k++) {
         i[d] = k;
         [self descriptionAux:i depth:d+1 string: rv];
      }
   }
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   ORInt* i = alloca(sizeof(ORInt)*_arity);
   [self descriptionAux: i depth:0 string: rv];
   return rv;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_arity];
   for(ORInt i = 0; i < _arity; i++) {
      [aCoder encodeObject:_range[i]];
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low[i]];
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up[i]];
   }
   for(ORInt i=0 ; i < _nb ;i++) {
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_flat[i]._val];
      [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_flat[i]._mgc];
   }
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_arity];
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _nb = 1;
   for(ORInt i = 0; i < _arity; i++) {
      _range[i] = [[aDecoder decodeObject] retain];
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low[i]];
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up[i]];
      _size[i] = (_up[i] - _low[i] + 1);
      _nb *= _size[i];
   }
   _flat = malloc(sizeof(TRInt) * _nb);
   for(ORInt i=0 ; i < _nb ;i++) {
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_flat[i]._val];
      [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_flat[i]._mgc];
   }
   return self;
}

@end


