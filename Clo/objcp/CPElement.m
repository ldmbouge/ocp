/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPElement.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "CPBitVarI.h"

#if defined(__linux__)
#define WORD_BIT 32
#endif

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

-(id) initCPElementBC: (CPIntVar*) x indexCstArray:(id<ORIntArray>) c equal:(CPIntVar*)y
{
   self = [super initCPCoreConstraint: [x engine]];
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
-(void) post
{
   if (bound(_x)) {
      [_y bind:[_c at:[_x min]]];
   }
   else if (bound(_y)) {
      ORInt cLow = [_c low];
      ORInt cUp  = [_c up];
      ORInt yv   = [_y min];
      ORBounds xb = bounds(_x);
      for(ORInt k=xb.min;k <= xb.max;k++)
         if (k < cLow || k > cUp || [_c at:k] != yv)
            removeDom(_x, k);
   }
   else {
      ORInt cLow = [_c low];
      ORInt cUp  = [_c up];
      _sz = cUp - cLow + 1;
      _tab = malloc(sizeof(CPEltRecord)*_sz);
      for(ORInt k=cLow;k <= cUp;k++) 
         _tab[k - cLow] = (CPEltRecord){k,[_c at:k]};
      qsort(_tab, _sz,sizeof(CPEltRecord),(int(*)(const void*,const void*)) &compareCPEltRecords);
      ORBounds yb = bounds(_y);
      _from = makeTRInt(_trail, -1);
      _to   = makeTRInt(_trail, -1);
      for(ORInt k=0;k < _sz;k++) {
         if (_tab[k]._val < yb.min || _tab[k]._val > yb.max)
            removeDom(_x, _tab[k]._idx);
         else {
            if (_from._val == -1)
               assignTRInt(&_from, k, _trail);
            assignTRInt(&_to, k, _trail);
         }
      }
      if (bound(_x))
         [_y bind:[_x min]];
      else {
         [_y whenChangeBoundsPropagate:self];
         [_x whenChangePropagate:self];
      }
   }
}
-(void) propagate
{
//   NSLog(@"element x: %@",[_x description]);
//   NSLog(@"element y: %@",[_y description]);
//   NSLog(@"element c: %@",[_c description]);
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
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
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

@end

struct EltACPair {
   ORInt _value;
   ORInt _idx;
   TRInt _support;
};

@implementation CPElementCstAC {
   struct EltACPair* _values;
   ORInt             _endOfList;
   ORInt*            _list;
   ORInt             _xLow;
   ORInt             _xUp;
   ORInt             _nbValues;
}
-(id) initCPElementAC: (CPIntVar*) x indexCstArray:(id<ORIntArray>) c equal:(CPIntVar*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(void) dealloc
{
   _list += _xLow;
   free(_list);
   free(_values);
   [super dealloc];
}
int compareInt32(const ORInt* i1,const ORInt* i2) { return *i1 - *i2;}

-(ORInt)valueIndex:(ORInt)v
{
   ORInt low = 0,up = _nbValues - 1;
   while (low <= up) {
      ORInt mid = (low + up)/2;
      if (_values[mid]._value == v)
         return mid;
      else if (_values[mid]._value > v)
         up = mid - 1;
      else low = mid + 1;
   }
   return _endOfList;
}

-(void) post
{
   ORInt cLow = [_c low];
   ORInt cUp  = [_c up];
   [_x updateMin:cLow andMax:cUp];
   ORBounds xb = bounds(_x);
   _xLow = xb.min;
   _xUp  = xb.max;
   ORInt xsz = xb.max - xb.min + 1;
   ORInt minC = MAXINT;
   ORInt maxC = MININT;
   for(ORInt k=xb.min; k <= xb.max;k++) {
      if (memberDom(_x, k)) {
         ORInt ck = [_c at:k];
         minC = minC < ck ? minC : ck;
         maxC = maxC > ck ? maxC : ck;
      }
   }
   _endOfList = xb.min - 1;   // endOfList marker is min(D) - 1
   _list = malloc(sizeof(ORInt)*xsz);
   _list -= _xLow;
   ORInt* sorted = malloc(sizeof(ORInt)*xsz);
   ORInt nbs = 0;
   for(ORInt k=xb.min; k <= xb.max;k++)
      if (memberDom(_x, k))
         sorted[nbs++] = [_c at:k];
   qsort(sorted, nbs,sizeof(ORInt), (int(*)(const void*,const void*))&compareInt32);
   // note that sorted may contain duplicates (which are now consecutive after the sort)
   _values = malloc(sizeof(struct EltACPair)*xsz);
   _nbValues = 0;
   ORInt lastValue = sorted[0] - 1;
   for(ORInt k =0 ; k < nbs ; k++) {
      if (sorted[k] != lastValue) {
         _values[_nbValues]._value = sorted[k];
         _values[_nbValues]._idx   = _endOfList; // next index in list supporting this value (initially empty)
         _values[_nbValues]._support = makeTRInt(_trail, 1);
         _nbValues++;
      } else  // duplicates cause an increase in the number of supports (# duplicates == # supports)
         assignTRInt(&_values[_nbValues - 1]._support,_values[_nbValues - 1]._support._val + 1,_trail);
      lastValue = sorted[k];
   }
   [_y updateMin:minC andMax:maxC];                   // update the bounds of the output variable first.
   ORBounds yb = bounds(_y);
   ORInt sortedIdx = 0;
   assert(yb.min == sorted[0]);
   assert(yb.max == sorted[nbs-1]);
   for(ORInt i=yb.min;i <= yb.max;i++) {              // scan the output variable to eliminate unsupported values
      while (sorted[sortedIdx] < i) sortedIdx++;
      if (sorted[sortedIdx] > i)
         removeDom(_y,i);
      while (sorted[sortedIdx] == i && sortedIdx < nbs) sortedIdx++;
   }
   free(sorted);
  
   for(ORInt k=_xLow;k <= _xUp;k++) {                 // scan the index variable
      if (memberDom(_x, k)) {                         // for each valid index value (k)
         ORInt listIdx = [self valueIndex:[_c at:k]]; // find start of list of supports for value ck
         _list[k] = _values[listIdx]._idx;            // Add k to the list of indices supporting ck
         _values[listIdx]._idx  = k;                  // update the head-of-list
      }
   }
   for(ORInt k=0;k < _nbValues;k++) {                 // scan all the values appearing in array c (in range)
      if (!memberDom(_y,_values[k]._value)) {         // if the value is not in the domain of result var.
         ORInt ptr = _values[k]._idx;                 // get the list of supporting indices.
         while (ptr != _endOfList) {                  // loop over all
            removeDom(_x, ptr);                       // remove each from the index variable.
            ptr = _list[ptr];                         // go to the next one.
         }
      }
   }
   if (!bound(_y)) {
      [_y whenLoseValue:self do:^(ORInt v) {
         ORInt listIdx = [self valueIndex:v];         // get the index of the value in the value DS.
         ORInt ptr = _values[listIdx]._idx;           // get the list of supporting indices.
         while (ptr != _endOfList) {                  // loop over all
            removeDom(_x, ptr);                       // remove each from the index variable.
            ptr = _list[ptr];                         // go to the next one.
         }
      }];
   }
   if (!bound(_x)) {
      [_x whenLoseValue:self do:^(ORInt v) {
         ORInt listIdx = [self valueIndex:[_c at:v]]; // get the index of the value in the value DS.
         assignTRInt(&_values[listIdx]._support, _values[listIdx]._support._val - 1, _trail);
         if (_values[listIdx]._support._val == 0)
            removeDom(_y, _values[listIdx]._value);
      }];
   }
}

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"CPElementCstAC: <%02d %@ [ %@ ] == %@ >",_name,_c,_x,_y];
   return buf;
}
@end

@implementation CPElementVarBC
-(id) initCPElementBC: (CPIntVar*) x indexVarArray:(id<CPIntVarArray>)z equal:(CPIntVar*)y   // y == z[x]
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(void) post
{
   [_x whenChangePropagate:self];
   [_y whenChangeBoundsPropagate:self];
   ORBounds xb = bounds(_x);
   for(ORInt k=xb.min; k <= xb.max;k++)
      if (memberDom(_x, k))
         [(CPIntVar*)[_z at:k] whenChangeBoundsPropagate:self];
   [self propagate];
}
-(void) propagate
{
   ORBounds bx = bounds(_x);
   id<ORIntRange> zr = [_z range];
   [_x updateMin:[zr low] andMax:[zr up]];
   
   // [minZ,maxZ] = UNION(k in D(x)) D(z[k])
   ORInt minZ = MAXINT,maxZ = MININT;
   for(int k=bx.min; k <= bx.max;k++) {
      if (memberDom(_x, k)) {
         ORBounds zk = bounds((CPIntVar*)[_z at:k]);
         minZ = minZ < zk.min ? minZ : zk.min;
         maxZ = maxZ > zk.max ? maxZ : zk.max;
      }
   }
   [_y updateMin:minZ andMax:maxZ]; // D(y) <- D(y) INTER [minZ,maxZ]
   ORBounds yb = bounds(_y);
   for(int k=bx.min; k <= bx.max;k++) {
      if (memberDom(_x, k)) {
         CPIntVar* zk = (CPIntVar*) [_z at: k];
         ORBounds zkb = bounds(zk);
         if (zkb.min > yb.max || zkb.max < yb.min)  // D(z[k]) INTER D(y) = EMPTY -> k NOTIN D(x)
            removeDom(_x, k);
      }
   }
   if (bound(_x)) {
      bx = bounds(_x);
      CPIntVar* zk = (CPIntVar*)[_z at:bx.min];
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
   return [[[NSSet alloc] initWithObjects:t count:sz] autorelease];
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for(ORInt k=[_z low];k<=[_z up];k++)
      nbuv += !bound((CPIntVar*)[_z at: k]);
   nbuv += !bound(_x) + !bound(_y);
   return nbuv;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"CPElementVarBC: <%02d %@ [ %@ ] == %@ >",_name,_z,_x,_y];
   return buf;
}
@end

@implementation CPElementVarAC
-(id)initCPElementAC: (CPIntVar*) x indexVarArray:(id<CPIntVarArray>)y equal:(CPIntVar*)z   // z AC== y[x]
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _array = y;
   _z = z;
   _s = _c = NULL;
   _inter = NULL;
   _iva = NULL;
   _minCI = _maxCI = _nbCI = 0;
   _minA = _nbVal = 0;
   return self;   
}
-(void)dealloc
{
   _inter += _minCI;
   for(ORInt k=0;k<_nbCI;k++)
      [_inter[k] release];
   free(_inter);
   [_iva release];
   [super dealloc];
}
-(void) post
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
   _s      = [ORFactory trailableIntArray:[_x engine] range:RANGE([_x engine],minA,maxA) value:0];
   _c      = [ORFactory trailableIntArray:[_x engine] range:RANGE([_x engine],_minCI,_maxCI) value:0];
   _inter  = malloc(sizeof(CPBitDom*)*_nbCI);
   _inter  -= _minCI;
   
   for(ORInt k = _minCI;k<=_maxCI;k++) {
      if (memberDom(_x, k)) {
         ORInt interMin = min([_array[k] min],[_z min]);
         ORInt interMax = max([_array[k] max],[_z max]);
         _inter[k] = [[CPBitDom alloc] initBitDomFor:[[_x engine] trail] low:interMin up:interMax];
         [_inter[k] setAllZeroFrom:interMin to:interMax];
      } else _inter[k] = nil;
   }
   _iva = [[CPBitDom alloc] initBitDomFor:[[_x engine] trail] low:la up:ua];
   for(ORInt k=la;k<=ua;k++) {
      if (memberDom(_x, k)) {
         for(ORInt i=[_array[k] min]; i <= [_array[k] max];i++)
            if (memberDom((CPIntVar*)_array[k], i))
               [_s[i] setValue:[_s[i] value] + 1];
      } else
         [_iva set:k at:false];
   }
   for(ORInt k=minA; k <= maxA;k++) {
      if ([_s[k] value] == 0 && memberDom(_z, k)) 
         [_z remove:k];
   }
   for(int k=[_x min]; k<= [_x max];k++) {
      if (memberDom(_x, k)) {
         assert([_c[k] value] == 0);
         assert([_inter[k] countFrom:[_inter[k] min] to:[_inter[k] max]] == [_c[k] value]);
         CPIntVar* ak = (CPIntVar*) _array[k];
         for(int i=[ak min];i<= [ak max];i++) {
            if (memberDom(ak, i) &&  memberDom(_z,i)) {
               [_c[k] setValue:[_c[k] value] + 1];
               [_inter[k] set:i at:YES];
            }
            assert([_inter[k] countFrom:[_inter[k] min] to:[_inter[k] max]] == [_c[k] value]);
         }
         assert([_inter[k] countFrom:[_inter[k] min] to:[_inter[k] max]] == [_c[k] value]);
         if ([_c[k] value] == 0)
            [_x remove:k];
      }
   }
   if (!bound(_x))
      [_x whenLoseValue:self do:^(ORInt val) {
         if ([_iva get:val]) {
            [_iva set:val at:NO];
            [_c[val] setValue:0];
            [_inter[val] setAllZeroFrom:[_inter[val] min] to:[_inter[val] max]];
            CPIntVar* av = (CPIntVar*)_array[val];
            ORBounds avb = bounds(av);
            for(ORInt k=avb.min;k <= avb.max;k++) {
               if (memberDom(av, k)) {
                  ORInt support = [_s[k] decr];
                  if (support == 0)
                     removeDom(_z, k);
               }
            }
            if (bound(_x))
               [self doACEqual:[_x min]];
         }
      }];
   
   if (!bound(_z))
      [_z whenLoseValue:self do:^(ORInt val) {
         ORBounds xb = bounds(_x);
         for(ORInt k=xb.min;k <= xb.max;k++) {
            if (!memberDom(_x, k)) continue;
            if ([_inter[k] get:val]) {
               [_inter[k] set:val at:NO];
               ORInt card = [_c[k] decr];
               if (card == 0)
                  [_x remove:k];
            }
            assert([_inter[k] countFrom:[_inter[k] min] to:[_inter[k] max]] == [_c[k] value]);
         }
      }];
   for(int k=minDom(_x);k <= maxDom(_x);k++) {
      CPIntVar* ak = (CPIntVar*)_array[k];
      if (memberDom(_x, k) && !bound(ak)) {
         [ak whenLoseValue:self do:^(ORInt val) {
            if ([_iva get:k]) {
               ORInt support = [_s[val] decr];
               if ([_inter[k] get:val]) {
                  ORInt card = [_c[k] decr];
                  [_inter[k] set:val at:NO];
                  assert([_inter[k] countFrom: minCPDom(_inter[k]) to: maxCPDom(_inter[k])] == [_c[k] value]);
                  assert([_c[k] value] >= 0);
                  if (card == 0)
                     removeDom(_x,k);
               }
               if (support == 0)
                  removeDom(_z,val);
            }
            if (bound(_x)) {
               if (minDom(_x) == k)
                  removeDom(_z,val);
            }
         }];
      }
   }
}

-(void)doACEqual:(ORInt)xv
{
   if (bound(_z)) {
      [_array[xv] bind:[_z min]];
   } else if ([_array[xv] bound]) {
      [_z bind:[_array[xv] min]];
   } else {
      CPIntVar* av = (CPIntVar*)_array[xv];
      [av  updateMin:[_z min] andMax:[_z max]];
      [_z updateMin:[av min] andMax:[av max]];
      ORBounds zb = bounds(_z);
      for(ORInt k=zb.min;k <= zb.max;k++) {
         if (!memberDom(_z, k))
            removeDom(av, k);
         if (!memberDom(av, k))
            removeDom(_z, k);
      }
   }
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
   return [[[NSSet alloc] initWithObjects:t count:sz] autorelease];
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for(ORInt k=[_array low];k<=[_array up];k++)
      nbuv += !bound((CPIntVar*)[_array at: k]);
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



@implementation CPElementBitVarBC
-(id) initCPElementBC: (CPBitVarI*) x indexVarArray:(id<ORIdArray>)z equal:(CPBitVarI*)y   // y == z[x]
{
   self = [super initCPCoreConstraint: (id<ORSearchEngine>)[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(void) post
{
   NSLog(@"BC constraint posted.\n");
}
-(void) propagate
{
   
}
-(NSSet*)allVars
{
   ORULong sz = [_z count] + 2;
   id<ORIdArray>* t = alloca(sizeof(id<ORBitVar>)*sz);
   ORInt i = 0;
   for(ORInt k=[_z low];k<=[_z up];k++)
      t[i++] = [_z at: k];
   t[i++] = (id)_x;
   t[i++] = (id)_y;
   return [[[NSSet alloc] initWithObjects:t count:sz] autorelease];
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for(ORInt k=[_z low];k<=[_z up];k++)
      nbuv += !([(CPBitVarI*)[_z at: k] bound]);
   nbuv += [_x bound] + [_y bound];
   return nbuv;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"CPElementVarBC: <%02d %@ [ %@ ] == %@ >",_name,_z,_x,_y];
   return buf;
}
@end

@implementation CPElementBitVarAC
-(id) initCPElementAC: (CPBitVarI*) x indexVarArray:(id<ORIdArray>)z equal:(CPBitVarI*)y   // y == z[x]
{
   self = [super initCPCoreConstraint: (id<ORSearchEngine>)[x engine]];
   _x = x;
   _y = y;
   _z = z;
   //_xold = NULL;
   _cI = [ORFactory trailableInt:(id<ORSearchEngine>)[_x engine] value:0];
   _la = makeTRInt(_trail, 0);
   _ua = makeTRInt(_trail, 0);
   _I = NULL;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(void) post
{
   unsigned int xwl = [_x getWordLength];
   assert(xwl==1);
   
   id<CPEngine> engine = [_x engine];
   
   //    ORBounds xb = [_x bounds];
   CPBitArrayDom* xdom = [_x domain];
   CPBitArrayDom* ydom = [_y domain];
   
   //    ORUInt la = max([_z low],xb.min);
   TRUInt* xUp;
   TRUInt* xLow;
   [xdom getUp:&xUp andLow:&xLow];
   ORUInt la = max([_z low],xLow[0]._val);
   ORUInt ua = min([_z up],xUp[0]._val);
   //    ORUInt ua = min([_z up],xb.max);
   
   unsigned int *temp;
   unsigned long long rank;
   if (![_x member:&la]) {
      temp = [xdom pred:&la];
      rank = [xdom getRank:&temp[1]];
      temp = [xdom atRank:rank+1];
      //        la = temp[0]+xb.min;
      la = temp[0]+xLow[0]._val;
   }
   if (![_x member:&ua]) {
      temp = [xdom pred:&ua];
      ua = temp[1];
   }
   if (la>ua || la>[_z up])
      failNow();
   
   assignTRInt(&_la, la, _trail);
   assignTRInt(&_ua, ua, _trail);
   _I = [ORFactory trailableIntArray:engine range:RANGE([_x engine],la,ua) value:0];
   _svx0 = makeTRIntArray(_trail, xwl*WORD_BIT-1, 0);
   _svx1 = makeTRIntArray(_trail, xwl*WORD_BIT-1, 0);
   _svy0 = makeTRIntArray(_trail, [_y getWordLength]*WORD_BIT-1, 0);
   _svy1 = makeTRIntArray(_trail, [_y getWordLength]*WORD_BIT-1, 0);
   
   CPBitVarI* elmt;
   unsigned int elmtfixed, yfixed, bothfixed, yeldif, notcomp;
   
   for(ORUInt k=_la._val;k <= _ua._val;k++) {
      if ([_x member:&k]) {
         // check if z[k]=y is valid assignment
         elmt = (CPBitVarI*)[_z at:k];
         TRUInt* zUp;
         TRUInt* zLow;
         [elmt getUp:&zUp andLow:&zLow];
         elmtfixed = ~(zLow[0]._val^zUp[0]._val);
         TRUInt* yUp;
         TRUInt* yLow;
         [_y getUp:&yUp andLow:&yLow];
         yfixed = ~(yLow[0]._val^yUp[0]._val);
         bothfixed = yfixed & elmtfixed;
         yeldif = yLow[0]._val^zLow[0]._val;
         notcomp = bothfixed & yeldif;
         if (notcomp)
            continue;
         for (int b=0; b < _svx0._nb; b++) {
            if ([xdom isFree:b]) {
               bool isOne = (k) & (1<<(b));
               assignTRIntArray(_svx0, b, _svx0._entries[b]._val + !isOne, _trail);
               assignTRIntArray(_svx1, b, _svx1._entries[b]._val + isOne, _trail);
            }
         }
         for (int b=0; b < _svy0._nb; b++) {
            if ([ydom isFree:b]) {
               if (![[elmt domain] isFree:b]) {
                  bool isOne = [[elmt domain] getBit:b];
                  assignTRIntArray(_svy0, b, _svy0._entries[b]._val + !isOne, _trail);
                  assignTRIntArray(_svy1, b, _svy1._entries[b]._val + isOne, _trail);
               }
               else {
                  assignTRIntArray(_svy0, b, _svy0._entries[b]._val + 1, _trail);
                  assignTRIntArray(_svy1, b, _svy1._entries[b]._val + 1, _trail);
               }
            }
         }
         [_I[k] setValue:1];
         [_cI incr];
         //            [_cI setValue:[_cI value]+1];
      }
   }
   
   if ([_cI value]==1) {
      for(ORInt k=_la._val;k <= _ua._val;k++) {
         if ([_I[k] value]) {
            [self doACEqual:k];
            break;
         }
      }
   }
   else if (![_cI value])
      failNow();
   
   for (int b=0   ;b < _svx0._nb;b++) {
      if ([xdom isFree:b]) {
         if (!_svx0._entries[b]._val) { // support for 0 for free bit b is 0
            [xdom setBit:b to:TRUE for:_x];
         }
         else if (!_svx1._entries[b]._val) { // support for 1 for free bit b is 0
            [xdom setBit:b to:FALSE for:_x];
         }
      }
   }
   for (int b=0;b < _svy0._nb;b++) {
      if ([ydom isFree:b]) {
         if (!_svy0._entries[b]._val) {
            [ydom setBit:b to:TRUE for:_y];
         }
         else if (!_svy1._entries[b]._val) {
            [ydom setBit:b to:FALSE for:_y];
         }
      }
   }
   
   la = max(_la._val, xLow[0]._val);
   assignTRInt(&_la, la, _trail);
   ua = min(_ua._val, xUp[0]._val);
   assignTRInt(&_ua, ua, _trail);

   [_x getUp:&xUp andLow:&xLow];
   ORUInt xWordLength = [_x getWordLength];
   ORUInt* newXLow = alloca(sizeof(ORUInt)*xWordLength);
   ORUInt* newXUp = alloca(sizeof(ORUInt)*xWordLength);
   for(int i=0;i<xWordLength;i++) {
      newXLow[i] = xLow[i]._val;
      newXUp[i] = xUp[i]._val;
   }
   _xold2 = [[CPBitArrayDom alloc] initWithBitPat:WORD_BIT withLow:newXLow andUp:newXUp andEngine:engine andTrail:[engine trail]];
   if (![_x bound])
      [_x whenChangePropagate:self];
   if (![_y bound])
      [_y whenChangePropagate:self];
   for(ORInt k=_la._val;k <= _ua._val;k++) {
      if (_I[k] && ![_z[k] bound])
         [_z[k] whenChangePropagate:self];
   }   
}
-(void) propagate
{
   
   if ([_cI value]==1) {
      for(ORInt k=_la._val;k <= _ua._val;k++) {
         if ([_I[k] value]) {
            [self doACEqual:k];
            break;
         }
      }
      return;
   }
   else if ([_cI value]<=0)
      failNow();
   CPBitVarI* elmt = NULL;
   unsigned int elmtfixed, yfixed, bothfixed, yeldif, notcomp;
   bool inXDom;
   
   TRUInt* eUp;
   TRUInt* eLow;
   ULRep yrep = getULVarRep(_y);
   TRUInt* yUp = yrep._up;
   TRUInt* yLow = yrep._low;
   //[_y getUp:&yUp andLow:&yLow];
   // plenty of room for optimization here
   for(ORUInt k=_la._val;k <= _ua._val;k++) {
      if ([_I[k] value]) {
         elmt = (CPBitVarI*)[_z at:k];
         [elmt getUp:&eUp andLow:&eLow];
         elmtfixed = ~(eLow[0]._val^eUp[0]._val);
         yfixed = ~(yLow[0]._val^yUp[0]._val);
         bothfixed = yfixed&elmtfixed;
         yeldif = yLow[0]._val^eLow[0]._val;
         notcomp = bothfixed&yeldif;
         inXDom = [_x member:&k];
         if (!inXDom||notcomp) {
            [_I[k] setValue:0];
            [_cI setValue:[_cI value]-1];
            if ([_cI value]==1) {
               for(ORInt k= _la._val;k <= _ua._val;k++) {
                  if ([_I[k] value]) {
                     [self doACEqual:k];
                     break;
                  }
               }
               return;
            }
            for (int b=0;b < _svy0._nb;b++) {
               if (!DomBitFree(elmt->_dom, b)) {
                  bool bit = DomBitGet(elmt->_dom, b);
                  if (bit) {
                     if (_svy1._entries[b]._val)
                        assignTRIntArray(_svy1, b, _svy1._entries[b]._val - 1, _trail);
                  }
                  else  {
                     if (_svy0._entries[b]._val)
                        assignTRIntArray(_svy0, b, _svy0._entries[b]._val - 1, _trail);
                  }
               }
               else {
                  if (_svy1._entries[b]._val)
                     assignTRIntArray(_svy1, b, _svy1._entries[b]._val - 1, _trail);
                  if (_svy0._entries[b]._val)
                     assignTRIntArray(_svy0, b, _svy0._entries[b]._val - 1, _trail);
               }
            }
            // update svx0, svx1
            for (int b=0;b < _svx0._nb;b++) {
               if (DomBitFree(_xold2, b)) {
                  bool isOne = (k)&(1<<(b));
                  if (_svx0._entries[b]._val)
                     assignTRIntArray(_svx0, b, _svx0._entries[b]._val - !isOne, _trail);
                  if (_svx1._entries[b]._val)
                     assignTRIntArray(_svx1, b, _svx1._entries[b]._val - isOne, _trail);
               }
            }
            
         }
      }
   }
   
   for (int b=0;b < _svx0._nb;b++) {
      if ([[_x domain] isFree:b]) {
         if (!_svx0._entries[b]._val) { // support for 0 for free bit b is 0
            [[_x domain] setBit:b to:TRUE for:_x];
         }
         else if (!_svx1._entries[b]._val) { // support for 1 for free bit b is 0
            [[_x domain] setBit:b to:FALSE for:_x];
         }
      }
   }
   for (int b=0;b < _svy0._nb;b++) {
      if ([[_y domain] isFree:b]) {
         if (!_svy0._entries[b]._val) {
            [[_y domain] setBit:b to:TRUE for:_y];
         }
         else if (!_svy1._entries[b]._val) {
            [[_y domain] setBit:b to:FALSE for:_y];
         }
      }
   }
   
   // update bounds
   TRUInt* xUp;
   TRUInt* xLow;
   [_x getUp:&xUp andLow:&xLow];
   ORInt la = max(_la._val, xLow[0]._val);
   assignTRInt(&_la, la, _trail);
   ORInt ua = min(_ua._val, xUp[0]._val);
   assignTRInt(&_ua, ua, _trail);
   ORUInt wordLength = [_x getWordLength];
   ORUInt* newXLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   for(int i=0;i<wordLength;i++){
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
   }
   [_xold2 setUp:newXUp andLow:newXLow for:NULL];
}

-(void)doACEqual:(ORUInt)k
{
   CPBitVarI* elmt = _z[k];
   TRUInt* eUp;
   TRUInt* eLow;
   [elmt getUp:&eUp andLow:&eLow];
   TRUInt* yUp;
   TRUInt* yLow;
   [_y getUp:&yUp andLow:&yLow];
   unsigned int elmtfixed, yfixed, bothfixed, yeldif, notcomp;
   elmtfixed = ~(eLow[0]._val^eUp[0]._val);
   yfixed = ~(yLow[0]._val^yUp[0]._val);
   bothfixed = yfixed&elmtfixed;
   yeldif = yLow[0]._val^eLow[0]._val;
   notcomp = bothfixed&yeldif;
   if (notcomp)
      failNow();
   unsigned int* finalidx = alloca(sizeof(unsigned int));
   finalidx[0] = k;
   [_x setUp:finalidx andLow:finalidx]; // bind still doesn't work
   //    [_x bind:finalidx];
   assignTRInt(&_la, k, _trail);
   assignTRInt(&_ua, k, _trail);
   ORUInt wordLength = [_y getWordLength];
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newEUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newELow = alloca(sizeof(ORUInt)*wordLength);
   
   for(int i=0;i<wordLength;i++){
      newYUp[i]=yUp[i]._val;
      newYLow[i] = yLow[i]._val;
      newEUp[i]= eUp[i]._val;
      newELow[i] = eLow[i]._val;
   }
   
   if ([_y bound]) {
      [elmt setUp:newYUp andLow:newYLow];
   }
   else if ([elmt bound]) {
      [_y setUp:newEUp andLow:newELow];
   }
   else {
      // this doesn't really work!
      //        [elmt setUp:[[_y domain] upArray] andLow:[[_y domain] lowArray]];
      //        [_y setUp:[[elmt domain] upArray] andLow:[[elmt domain] lowArray]];
      //        for (unsigned int b=0;b<=WORD_BIT-1;b++) {
      //            if ([[_y domain] isFree:b]&&![[elmt domain] isFree:b])
      //                [[_y domain] setBit:b to:[[elmt domain] getBit:b] for:_y];
      //            else if ([[elmt domain] isFree:b]&&![[_y domain] isFree:b])
      //                [[elmt domain] setBit:b to:[[_y domain] getBit:b] for:elmt];
      //        }
      unsigned int* up = alloca(sizeof(unsigned int));
      unsigned int* low = alloca(sizeof(unsigned int));
      up[0]  = yUp[0]._val  & eUp[0]._val;
      low[0] = yLow[0]._val | eLow[0]._val;
      [_y setUp:up andLow:low];
      [elmt setUp:up andLow:low];
   }
}

-(NSSet*)allVars
{
   ORULong sz = [_z count] + 2;
   id<ORIdArray>* t = alloca(sizeof(id<ORBitVar>)*sz);
   ORInt i = 0;
   for(ORInt k=[_z low];k<=[_z up];k++)
      t[i++] = [_z at: k];
   t[i++] = (id)_x;
   t[i++] = (id)_y;
   return [[[NSSet alloc] initWithObjects:t count:sz] autorelease];
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for(ORInt k=[_z low];k<=[_z up];k++)
      nbuv += !([(CPBitVarI*)[_z at: k] bound]);
   nbuv += [_x bound] + [_y bound];
   return nbuv;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"CPElementVarBC: <%02d %@ [ %@ ] == %@ >",_name,_z,_x,_y];
   return buf;
}
@end

