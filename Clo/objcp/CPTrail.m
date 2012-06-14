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

#import "CPTrail.h"
#import <assert.h>

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

@implementation CPTrail
-(CPTrail*) init
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
   NSLog(@"CPTrail %p dealloc called...\n",self);
   for(CPInt k=0;k<_mxSeg;k++)
      if (_seg[k])
         free(_seg[k]);
   free(_seg);
   [super dealloc];
}
-(CPUInt)magic
{
   return _magic;
}
-(void)incMagic
{
   ++_magic;
}
-(void)resize 
{
   if (_cSeg == _mxSeg) {
      _seg = realloc(_seg, sizeof(struct Segment*)*_mxSeg*2);
      memset(_seg + _mxSeg,0,sizeof(struct Segment*)*_mxSeg);
      _mxSeg <<= 1;
   }
   if (_seg[++_cSeg] == 0) 
      _seg[_cSeg] = malloc(sizeof(struct Segment));   
   _seg[_cSeg]->top = 0;
}
-(void)trailInt:(CPInt*)ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];
   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGInt;
   s->intVal = *ptr;
   ++_seg[_cSeg]->top;
}
-(void)trailUnsigned:(CPUInt*)ptr
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

-(void) trailLong:(CPLong*) ptr
{
   if (_seg[_cSeg]->top >= NBSLOT-1) [self resize];   struct Slot* s = _seg[_cSeg]->tab + _seg[_cSeg]->top;
   s->ptr = ptr;
   s->code = TAGLong;
   s->longVal = *ptr;
   ++_seg[_cSeg]->top;   
}
-(void) trailUnsignedLong:(CPULong*) ptr
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

-(CPUInt)trailSize
{
   return _cSeg * NBSLOT + _seg[_cSeg]->top;
}

-(void)backtrack:(CPInt)to
{
   CPInt segId = to / NBSLOT;
   CPInt inSeg = to % NBSLOT;
   CPInt cSeg  = _cSeg;
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
               [*((id*)cs->ptr) release];
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
               [cs->idVal release];
               break;
            default:
               break;
         }                  
      }
      _seg[cSeg]->top = (CPInt)(cs - _seg[cSeg]->tab);
      --cSeg;
   }
   _cSeg = segId;
   assert(_seg[_cSeg]->top == inSeg);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   // Only send the # of segments and the current magic
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_mxSeg];
   [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_magic];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   // Allocate the right number of segments. Start with an empty trail in the clone.
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_mxSeg];
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_magic];
   _seg = malloc(sizeof(struct Segment*)*_mxSeg);
   memset(_seg,0,sizeof(struct Segment*)*_mxSeg);
   _seg[0] = malloc(sizeof(struct Segment));
   _seg[0]->top = 0;
   _cSeg = 0;
   return self;
}
@end

TRInt makeTRInt(CPTrail* trail,int val)
{
   TRInt x = {val,[trail magic]-1};
   return x;
}

void  assignTRInt(TRInt* v,int val,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailIntFun(trail, &v->_val);
      //[trail trailInt:&v->_val];
   }
   v->_val = val;      
}

FXInt makeFXInt(CPTrail* trail)
{
   FXInt x = {0,[trail magic]-1};
   return x;
}
void  incrFXInt(FXInt* v,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;      
   }
   v->_val++;
}
int getFXInt(FXInt* v,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      v->_val = 0;      
   }   
   return v->_val;
}


TRUInt makeTRUInt(CPTrail* trail,unsigned val)
{
   TRUInt x = {val,[trail magic]-1};
   return x;   
}
void  assignTRUInt(TRUInt* v,unsigned val,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      trailUIntFun(trail, &v->_val);
   }
   v->_val = val;         
}


TRLong makeTRLong(CPTrail* trail,long long val)
{
   TRLong x = {val,[trail magic]-1};
   return x;
}

void  assignTRLong(TRLong* v,long long val,CPTrail* trail)
{
   CPInt cmgc = trail->_magic;
   if (v->_mgc != cmgc) {
      v->_mgc = cmgc;
      [trail trailLong:&v->_val];
   }
   v->_val = val;      
}

TRId  makeTRId(CPTrail* trail,id val)
{
  TRId x = {val,[trail magic]-1};
  return x;   
}
void  assignTRId(TRId* v,id val,CPTrail* trail)
{
  if (v->_mgc != [trail magic]) {
    v->_mgc = [trail magic];
    [trail trailId:&v->_val];
  }
  [v->_val release];
  v->_val = [val retain];         
}

TRDouble  makeTRDouble(CPTrail* trail,double val)
{
   TRDouble x = {val,[trail magic]-1};
   return x;
}
void  assignTRDouble(TRDouble* v,double val,CPTrail* trail)
{
   if (v->_mgc != [trail magic]) {
      v->_mgc = [trail magic];
      [trail trailDouble:&v->_val];
   }
   v->_val = val;
}


@implementation CPTrailStack 
-(CPTrailStack*) initTrailStack: (CPTrail*)tr
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
-(void)pushNode:(CPInt)x
{
   if (_sz >= _mxs) {
      _tab = realloc(_tab,sizeof(struct TRNode)*_mxs*2);
      _mxs <<= 1;
   }
   _tab[_sz++] = (struct TRNode){x,[_trail trailSize]};
}
-(CPInt)popOffset:(CPInt)x
{
   do {
      --_sz;
   } while(_sz>0 && (_tab[_sz]._x != x));
   return _tab[_sz]._ofs;
}
-(void)popNode:(CPInt) x
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
-(CPInt)size
{
   return _sz;
}
@end

TRIntArray makeTRIntArray(CPTrail* trail,int nb,int low)
{
    TRIntArray x = {trail,nb,low,NULL};
    x._entries = malloc(sizeof(TRInt)*nb);
    for(int i = 0; i < nb; i++)
        x._entries[i] = makeTRInt(trail,0); 
    x._entries -= low;
    return x;
}
void assignTRIntArray(TRIntArray a,int i,int val)
{
    assignTRInt(a._entries + i,val,a._trail);
}
int getTRIntArray(TRIntArray a,int i)
{
    return a._entries[i]._val;
}
void freeTRIntArray(TRIntArray a)
{
    a._entries += a._low;
    free(a._entries);
}


