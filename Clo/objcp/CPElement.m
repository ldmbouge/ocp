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

#import "CPElement.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"

typedef struct CPEltRecordTag {
   CPInt _idx;
   CPInt _val;
} CPEltRecord;

@implementation CPElementCstBC {
   CPEltRecord* _tab;
   CPInt        _sz;
   TRInt        _from;
   TRInt        _to;
}

-(id) initCPElementBC: (id) x indexCstArray:(id<CPIntArray>) c equal:(id)y
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _y = y;
   _c = c;
   _tab = NULL;
   _sz  = 0;
   return self;
}
-(void) dealloc
{
   free(_tab);
   [super dealloc];
}
int compareCPEltRecords(const CPEltRecord* r1,const CPEltRecord* r2)
{
   CPInt d1 = r1->_val - r2->_val;
   if (d1==0)
      return r1->_idx - r2->_idx;
   else return d1;
}
-(CPStatus) post
{
   if (bound(_x)) {
       return [_y bind:[_x min]];
   } else if (bound(_y)) {
      CPInt cLow = [_c low];
      CPInt cUp  = [_c up];
      CPInt yv   = [_y min];
      CPBounds xb = bounds(_x);
      CPStatus ok = CPSuspend;
      for(CPInt k=xb.min;k <= xb.max && ok;k++)
         if (k < cLow || k > cUp || [_c at:k] != yv)
            ok = removeDom(_x, k);
      return ok;
   } else {
      CPInt cLow = [_c low];
      CPInt cUp  = [_c up];
      _sz = cUp - cLow + 1;
      _tab = malloc(sizeof(CPEltRecord)*_sz);
      for(CPInt k=cLow;k <= cUp;k++) 
         _tab[k - cLow] = (CPEltRecord){k,[_c at:k]};
      qsort(_tab, sizeof(CPEltRecord), _sz,(int(*)(const void*,const void*)) &compareCPEltRecords);
      CPBounds yb = bounds(_y);
      CPStatus ok = CPSuspend;
      _from = makeTRInt(_trail, -1);
      _to   = makeTRInt(_trail, -1);
      for(CPInt k=0;k < _sz && ok;k++) {
         if (_tab[k]._val < yb.min || _tab[k]._val > yb.max)
            ok = removeDom(_x, _tab[k]._idx);
         else {
            if (_from._val == -1)
               assignTRInt(&_from, k, _trail);
            assignTRInt(&_to, k, _trail);
         }
      }
      if (ok) {
         if (bound(_x))
            return [_y bind:[_x min]];
         else {
            [_y whenChangeBoundsPropagate:self];
            [_x whenChangePropagate:self];
         }
      }
      return ok;
   }
}
-(CPStatus) propagate
{
   if (bound(_x)) {
      return [_y bind:[_c at:[_x min]]];
   } else {
      CPInt k = _from._val;
      CPStatus ok = CPSuspend;
      while (k < _sz && !memberDom(_x, _tab[k]._idx))
         ++k;
      if (k < _sz) {
         ok = [_y updateMin:_tab[k]._val];
         assignTRInt(&_from, k, _trail);
      }
      else return CPFailure;
      k = _to._val;
      while(k >= 0 && !memberDom(_x,_tab[k]._idx))
         --k;
      if (k >= 0) {
         ok = [_y updateMax:_tab[k]._val];
         assignTRInt(&_to, k, _trail);
      }
      else return CPFailure;
      CPBounds yb = bounds(_y);
      k = _from._val;
      while (k < _sz && ok && _tab[k]._val < yb.min) 
         ok = removeDom(_x, _tab[k++]._idx);
      if (ok) assignTRInt(&_from, k, _trail);
      k = _to._val;
      while (k >= 0 && ok && _tab[k]._val > yb.max)
         ok = removeDom(_x,_tab[k--]._idx);
      if (ok) assignTRInt(&_to,k,_trail);
      return ok;
   }   
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];   
}
-(CPUInt)nbUVars
{
   return !bound(_x) && !bound(_y);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _c = [aDecoder decodeObject];
   _tab = NULL;
   _sz  = 0;
   return self;
}
@end

@implementation CPElementVarBC
-(id) initCPElementBC: (id) x indexVarArray:(id<CPIntVarArray>)z equal:(id)y
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(CPStatus) post
{
   CPStatus ok = [self propagate];
   if (!ok) return ok;
   [_x whenChangePropagate:self];
   [_y whenChangeBoundsPropagate:self];
   CPBounds xb = bounds(_x);
   for(CPInt k=xb.min; k <= xb.max;k++)
      if (memberDom(_x, k))
         [(CPIntVarI*)[_z at:k] whenChangeBoundsPropagate:self];
   return ok;
}
-(CPStatus)propagate
{
   CPBounds bx = bounds(_x);
   CPInt minZ = MAXINT,maxZ = MININT; // [minZ,maxZ] = UNION(k in D(x)) D(z[k])
   for(int k=bx.min; k <= bx.max;k++) {
      if (memberDom(_x, k)) {
         CPBounds zk = bounds((CPIntVarI*)[_z at:k]);
         minZ = minZ < zk.min ? minZ : zk.min;
         maxZ = maxZ > zk.max ? maxZ : zk.max;
      }
   }
   if ([_y updateMin:minZ andMax:maxZ] == CPFailure) // D(y) <- D(y) INTER [minZ,maxZ]
      return  CPFailure;
   CPBounds yb = bounds(_y);
   for(int k=bx.min; k <= bx.max;k++) {
      if (memberDom(_x, k)) {
         CPIntVarI* zk = (CPIntVarI*) [_z at: k];
         CPBounds zkb = bounds(zk);
         if (zkb.min > yb.max || zkb.max < yb.min)  // D(z[k]) INTER D(y) = EMPTY -> k NOTIN D(x)
            if (removeDom(_x, k) == CPFailure)
               return CPFailure;
      }
   }
   bx = bounds(_x);
   if (bound(_x)) { 
      CPIntVarI* zk = (CPIntVarI*)[_z at:bx.min];
      if ([zk updateMin:yb.min andMax:yb.max] == CPFailure)  //x==c -> D(y) == D(z_c)
         return CPFailure;
   }
   return CPSuspend;
}
-(NSSet*)allVars
{
   CPUInt sz = [_z count] + 2;
   id<CPIntVar>* t = alloca(sizeof(id<CPIntVar>)*sz);
   CPInt i = 0;
   for(CPInt k=[_z low];k<=[_z up];k++)
      t[i++] = [_z at: k];
   t[i++] = _x;
   t[i++] = _y;
   return [[NSSet alloc] initWithObjects:t count:sz];
}
-(CPUInt)nbUVars
{
   CPInt nbuv = 0;
   for(CPInt k=[_z low];k<=[_z up];k++)
      nbuv += !bound((CPIntVarI*)[_z at: k]);
   nbuv += !bound(_x) + !bound(_y);
   return nbuv;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end
