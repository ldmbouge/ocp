/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPElement.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPEngineI.h"
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

-(id) initCPElementBC: (id) x indexCstArray:(id<ORIntArray>) c equal:(id)y
{
   self = [super initCPActiveConstraint: [[x solver] engine]];
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
   else
      return d1;
}
-(ORStatus) post
{
   if (bound(_x)) {
       return [_y bind:[_x min]];
   } else if (bound(_y)) {
      CPInt cLow = [_c low];
      CPInt cUp  = [_c up];
      CPInt yv   = [_y min];
      CPBounds xb = bounds(_x);
      ORStatus ok = ORSuspend;
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
      qsort(_tab, _sz,sizeof(CPEltRecord),(int(*)(const void*,const void*)) &compareCPEltRecords);
      CPBounds yb = bounds(_y);
      ORStatus ok = ORSuspend;
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
-(void) propagate
{
   if (bound(_x)) {
      [_y bind:[_c at:[_x min]]];
   } else {
      CPInt k = _from._val;
      while (k < _sz && !memberDom(_x, _tab[k]._idx))
         ++k;
      if (k < _sz) {
         [_y updateMin:_tab[k]._val];
         assignTRInt(&_from, k, _trail);
      }
      else
         failNow();
      k = _to._val;
      while(k >= 0 && !memberDom(_x,_tab[k]._idx))
         --k;
      if (k >= 0) {
         [_y updateMax:_tab[k]._val];
         assignTRInt(&_to, k, _trail);
      }
      else
         failNow();
      CPBounds yb = bounds(_y);
      k = _from._val;
      while (k < _sz && _tab[k]._val < yb.min) 
         removeDom(_x, _tab[k++]._idx);
      assignTRInt(&_from, k, _trail);
      k = _to._val;
      while (k >= 0 && _tab[k]._val > yb.max)
         removeDom(_x,_tab[k--]._idx);
      assignTRInt(&_to,k,_trail);
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
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"CPElementCstBC: <%02d %@ [ %@ ] == %@ >",_name,_c,_x,_y];
   return buf;
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
-(id) initCPElementBC: (id) x indexVarArray:(id<ORIntVarArray>)z equal:(id)y
{
   self = [super initCPActiveConstraint: [((id<CPSolver>)[x solver]) engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   [_x whenChangePropagate:self];
   [_y whenChangeBoundsPropagate:self];
   CPBounds xb = bounds(_x);
   for(CPInt k=xb.min; k <= xb.max;k++)
      if (memberDom(_x, k))
         [(CPIntVarI*)[_z at:k] whenChangeBoundsPropagate:self];
   return ORSuspend;
}
-(void) propagate
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
   [_y updateMin:minZ andMax:maxZ]; // D(y) <- D(y) INTER [minZ,maxZ]
   CPBounds yb = bounds(_y);
   for(int k=bx.min; k <= bx.max;k++) {
      if (memberDom(_x, k)) {
         CPIntVarI* zk = (CPIntVarI*) [_z at: k];
         CPBounds zkb = bounds(zk);
         if (zkb.min > yb.max || zkb.max < yb.min)  // D(z[k]) INTER D(y) = EMPTY -> k NOTIN D(x)
            removeDom(_x, k);
      }
   }
   bx = bounds(_x);
   if (bound(_x)) { 
      CPIntVarI* zk = (CPIntVarI*)[_z at:bx.min];
      [zk updateMin:yb.min andMax:yb.max];  //x==c -> D(y) == D(z_c)
   }
}
-(NSSet*)allVars
{
   CPULong sz = [_z count] + 2;
   id<ORIntVar>* t = alloca(sizeof(id<ORIntVar>)*sz);
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
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"CPElementVarBC: <%02d %@ [ %@ ] == %@ >",_name,_z,_x,_y];
   return buf;
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
