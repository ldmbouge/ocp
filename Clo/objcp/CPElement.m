/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPElement.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"

typedef struct CPEltRecordTag {
   ORInt _idx;
   ORInt _val;
} CPEltRecord;

@implementation CPElementCstBC {
   CPEltRecord* _tab;
   ORInt        _sz;
   TRInt        _from;
   TRInt        _to;
}

-(id) initCPElementBC: (id) x indexCstArray:(id<ORIntArray>) c equal:(id)y
{
   self = [super initCPActiveConstraint: [x engine]];
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
   ORInt d1 = r1->_val - r2->_val;
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
      ORInt cLow = [_c low];
      ORInt cUp  = [_c up];
      ORInt yv   = [_y min];
      ORBounds xb = bounds(_x);
      ORStatus ok = ORSuspend;
      for(ORInt k=xb.min;k <= xb.max && ok;k++)
         if (k < cLow || k > cUp || [_c at:k] != yv)
            ok = removeDom(_x, k);
      return ok;
   } else {
      ORInt cLow = [_c low];
      ORInt cUp  = [_c up];
      _sz = cUp - cLow + 1;
      _tab = malloc(sizeof(CPEltRecord)*_sz);
      for(ORInt k=cLow;k <= cUp;k++) 
         _tab[k - cLow] = (CPEltRecord){k,[_c at:k]};
      qsort(_tab, _sz,sizeof(CPEltRecord),(int(*)(const void*,const void*)) &compareCPEltRecords);
      ORBounds yb = bounds(_y);
      ORStatus ok = ORSuspend;
      _from = makeTRInt(_trail, -1);
      _to   = makeTRInt(_trail, -1);
      for(ORInt k=0;k < _sz && ok;k++) {
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
      ORInt k = _from._val;
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
      ORBounds yb = bounds(_y);
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
-(ORUInt)nbUVars
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
-(id) initCPElementBC: (id) x indexVarArray:(id<CPIntVarArray>)z equal:(id)y   // y == z[x]
{
   self = [super initCPActiveConstraint: [x engine]];
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
   ORBounds xb = bounds(_x);
   for(ORInt k=xb.min; k <= xb.max;k++)
      if (memberDom(_x, k))
         [(CPIntVarI*)[_z at:k] whenChangeBoundsPropagate:self];
   return ORSuspend;
}
-(void) propagate
{
   ORBounds bx = bounds(_x);
   id<ORIntRange> zr = [_z range];
   [_x updateMin:[zr low] andMax:[zr up]];
   ORInt minZ = MAXINT,maxZ = MININT; // [minZ,maxZ] = UNION(k in D(x)) D(z[k])
   for(int k=bx.min; k <= bx.max;k++) {
      if (memberDom(_x, k)) {
         ORBounds zk = bounds((CPIntVarI*)[_z at:k]);
         minZ = minZ < zk.min ? minZ : zk.min;
         maxZ = maxZ > zk.max ? maxZ : zk.max;
      }
   }
   [_y updateMin:minZ andMax:maxZ]; // D(y) <- D(y) INTER [minZ,maxZ]
   ORBounds yb = bounds(_y);
   for(int k=bx.min; k <= bx.max;k++) {
      if (memberDom(_x, k)) {
         CPIntVarI* zk = (CPIntVarI*) [_z at: k];
         ORBounds zkb = bounds(zk);
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
   ORULong sz = [_z count] + 2;
   id<CPIntVar>* t = alloca(sizeof(id<ORIntVar>)*sz);
   ORInt i = 0;
   for(ORInt k=[_z low];k<=[_z up];k++)
      t[i++] = [_z at: k];
   t[i++] = _x;
   t[i++] = _y;
   return [[NSSet alloc] initWithObjects:t count:sz];
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for(ORInt k=[_z low];k<=[_z up];k++)
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

@implementation CPElementVarAC
-(id)initCPElementAC: (id) x indexVarArray:(id<CPIntVarArray>)y equal:(id)z   // z AC== y[x]
{
   self = [super initCPActiveConstraint: [x engine]];
   _x = x;
   _array = y;
   _z = z;
   _s = _c = nil;
   _inter = nil;
   _iva = nil;
   _minCI = _maxCI = _nbCI = 0;
   _minA = _nbVal = 0;
   return self;   
}
-(void)dealloc
{
   for(ORInt k=0;k<_nbCI;k++)
      [_inter[k] release];
   free(_inter);
   [_iva release];
   [_s release];
   [_c release];
   [super dealloc];   
}
-(ORStatus)post
{
   ORBounds xb = bounds(_x);
   ORInt la = max([_array low],xb.min);
   ORInt ua = min([_array up],xb.max);
   ORInt minA = MAXINT,maxA = MININT;
   [_x updateMin:la andMax:ua];
   for(ORInt k=la;k <= ua;k++) {
      if (memberDom(_x, k)) {
         minA = min(minA,[_array[k] min]);
         maxA = max(maxA,[_array[k] max]);
      }
   }
   [_z updateMin:minA andMax:maxA];
   _minA   = minA;
   _nbVal  = maxA - minA + 1;          // range of reachable array *values*.
   _nbCI   = [_x max] - [_x min] + 1;  // range of *index* variable
   _minCI  = [_x min];
   _maxCI  = [_x max];
   _s      = [ORFactory trailableIntArray:[_x engine] range:RANGE([_x engine],0,_nbVal-1) value:0];
   _c      = [ORFactory trailableIntArray:[_x engine] range:RANGE([_x engine],0,_nbCI) value:0];
   _inter  = malloc(sizeof(CPBitDom*)*_nbCI);
   /*
   _s      = cnew<CotTrail<int> >(_nbVal,getAllocator());
   _ci     = cnew<CotTrail<int> >(_nbCI,getAllocator());
   _inter  = cnew<CotCPDomainI*>(_nbCI,getAllocator());
   memset(_s,0,sizeof(CotTrail<int>)*_nbVal);
   memset(_ci,0,sizeof(CotTrail<int>)*_nbCI);
   _s     -= minY;
   _ci    -= _minCI;
   _inter -= _minCI;
   for(int k = _minCI;k<=_maxCI;k++) {
      if (_x->member(k)) {
         int interMin = yr[k]->getMin() < _z->getMin() ? yr[k]->getMin() : _z->getMin();
         int interMax = yr[k]->getMax() > _z->getMax() ? yr[k]->getMax() : _z->getMax();
         _inter[k] = new (getAllocator()) CotCPDomainI(getAllocator(),_fdm->getTrail(),interMin,interMax);
         _inter[k]->setAllZero(interMin,interMax);
      } else _inter[k] = 0;
   }
   
   _iva = new (getAllocator()) CotCPDomainI(getAllocator(),_fdm->getTrail(),lx,ux);
   for(int k=lx;k<=ux;k++) {
      if (_x->member(k)) {
         for(int i=yr[k]->getMin();i<=yr[k]->getMax();i++) {
            if (yr[k]->member(i)) {
               _s[i].assign(_s[i]+1,*_fdm);
            }
         }
      } else _iva->set(k,false);
   }
   for(int k=minY;ok && k<=maxY;k++) {
      if (_s[k] == 0 && _z->member(k))
         ok = _z->removeValue(k);
   }
   if (!ok) return ok;
   for(int k=_x->getMin();ok && k<= _x->getMax();k++) {
      if (_x->member(k)) {
         COMETASSERT(_ci[k] == 0);
         COMETASSERT(_inter[k]->countBetween(_inter[k]->getMin(),_inter[k]->getMax()) == _ci[k]);
         CotCPIntVarI* yk = yr[k]->getVar();
         for(int i=yk->getMin();i<= yk->getMax();i++) {
            if (yk->member(i) && _z->member(i)) {
               _ci[k].assign(_ci[k]+1,*_fdm);
               _inter[k]->set(i,true);
            }
            COMETASSERT(_inter[k]->countBetween(_inter[k]->getMin(),_inter[k]->getMax()) == _ci[k]);
         }
         COMETASSERT(_inter[k]->countBetween(_inter[k]->getMin(),_inter[k]->getMax()) == _ci[k]);
         if (_ci[k] == 0)
            ok = _x->removeValue(k);
      }
   }
   if (!ok) return ok;
   if (!_x->isBound()) _x->addAC5(this);
   if (!_z->isBound()) _z->addAC5(this);
   for(int k=_x->getMin();ok && k<= _x->getMax();k++)
      if (_x->member(k) && !yr[k]->isBound())
         yr[k]->getVar()->addAC5Index(this,k);
   return ok;
    */
}
-(NSSet*)allVars
{
   ORULong sz = [_array count] + 2;
   id<CPIntVar>* t = alloca(sizeof(id<ORIntVar>)*sz);
   ORInt i = 0;
   for(ORInt k=[_array low];k<=[_array up];k++)
      t[i++] = [_array at: k];
   t[i++] = _x;
   t[i++] = _z;
   return [[NSSet alloc] initWithObjects:t count:sz];   
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for(ORInt k=[_array low];k<=[_array up];k++)
      nbuv += !bound((CPIntVarI*)[_array at: k]);
   nbuv += !bound(_x) + !bound(_z);
   return nbuv;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"CPElementVarAC: <%02d %@ [ %@ ] == %@ >",_name,_array,_x,_z];
   return buf;
}
@end

