/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORTrail.h"
#import "ORTrailI.h"
#import <assert.h>

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
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
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

-(ORUInt)trailSize
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
                  CFRelease(*((id*)cs->ptr));// release];
               *((id*)cs->ptr) = cs->idVal;
            }break;
            case TAGFloat:
               *((float*)cs->ptr) = cs->floatVal;
               break;
            case TAGDouble:
               *((double*)cs->ptr) = cs->doubleVal;
               break;
            case TAGClosure:
               cs->cloVal();
               [cs->cloVal release];
               break;
            case TAGRelease:
               CFRelease(cs->idVal);
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
      trailIntFun(a._trail, & ei->_val);
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
      trailIntFun(trail, &v->_val);
   }
   v->_val = val;
}

void  assignTRUInt(TRUInt* v,unsigned val,ORTrailI* trail)
{
   ORInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailUIntFun(trail, &v->_val);
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
   trailIdNCFun(trail, &v->_val);
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

@implementation ORTrailIStack
-(ORTrailIStack*) initTrailStack: (ORTrailI*)tr
{
   self = [super init];
   _trail = [tr retain];
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
   [super dealloc];
}
-(void)pushNode:(ORInt)x
{
   if (_sz >= _mxs) {
      _tab = realloc(_tab,sizeof(struct TRNode)*_mxs*2);
      _mxs <<= 1;
   }
   _tab[_sz++] = (struct TRNode){x,[_trail trailSize]};
}
-(ORInt)popOffset:(ORInt)x
{
   do {
      --_sz;
   } while(_sz>0 && (_tab[_sz]._x != x));
   return _tab[_sz]._ofs;
}
-(void)popNode:(ORInt) x
{
   [_trail backtrack:[self popOffset:x]];
}
-(void)popNode
{
   assert(_sz > 0);
   [_trail backtrack: _tab[--_sz]._ofs];
}

-(void)reset
{
   _sz = 0;
}
-(bool)empty
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
-(void)  setValue: (ORInt) value
{
   assignTRInt(&_trint,value,_trail);
}
-(void)  incr
{
   assignTRInt(&_trint,_trint._val+1,_trail);
}
-(void)  decr
{
   assignTRInt(&_trint,_trint._val-1,_trail);
}
@end
