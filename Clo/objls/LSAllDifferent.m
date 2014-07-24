/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSAllDifferent.h"
#import <objls/LSFactory.h>
#import "LSEngineI.h"
#import "LSGlobalInvariants.h"
#import "LSCount.h"
#import "LSIntVar.h"
#import <ORFoundation/ORSetI.h>

@implementation LSAllDifferent {
   unsigned char* _present;  // boolean array (one boolean per var in _x)
   ORInt              _low;  // lowest variable identifier in _x
   ORInt               _up;  // highest variable identifier in _x
   ORInt*            _xOfs;  // Offset of variable j in array x. i.e., x[_xOfs[j]].getId() == j
   ORBool       _overViews;
   id<LSIntVarArray>  _src;
   ORBounds            _sb;
   id<LSIntVar>*      _map;
   id* _vvBase;
   id*  _cBase;
}
-(id)init:(id<LSEngine>)engine vars:(id<LSIntVarArray>)x
{
   self = [super init:engine];
   _x   = x;
   _src = nil;
   _posted = NO;
   ORBounds b = idRange(_x, (ORBounds){FDMAXINT,0});
   _low = b.min;
   _up  = b.max;
   _present = malloc(sizeof(unsigned char)*(_up - _low + 1));
   memset(_present,0,sizeof(unsigned char)*(_up - _low + 1));
   _present -= _low;
   _xOfs = malloc(sizeof(ORInt)*(_up - _low + 1));
   _xOfs -= _low;
   ORInt k = x.range.low;
   for(id<LSIntVar> v in _x) {
      _present[getId(v)] = YES;
      _xOfs[getId(v)] = k++;
   }
   return self;
}
-(void)dealloc
{
   _present += _low;
   _xOfs    += _low;
   free(_present);
   free(_xOfs);
   _map += _sb.max;
   free(_map);
   [super dealloc];
}
static inline ORBool isPresent(LSAllDifferent* ad,id<LSIntVar> v)
{
   ORUInt vid = getId(v);
   if (ad->_low <= vid && vid <= ad->_up)
      return ad->_present[vid];
   return NO;
}
-(id<LSIntVarArray>) variables
{
   if (_src) return _src;
   _overViews = NO;
   for(id<LSIntVar> xk in _x)
      _overViews |= [xk isKindOfClass:[LSCoreView class]];
   if (_overViews) {
      ORInt sz = (ORInt)[_x count];
      NSArray* asv[sz];
      collectSources(_x, asv);
      ORBool multi = NO;
      _src = sourceVariables(_engine, asv,sz,&multi);     // _src is now packed with the source variables
      _map = makeVar2ViewMap(_src, _x, asv, sz, &_sb); // create a map source -> view
      return _src;
   }
   else {
      _sb = idRange(_x,(ORBounds){FDMAXINT,0});
      return _src = _x;
   }
}
-(void)hardInit
{
   id<ORIntRange> valRange = _c.range;
   [_engine atomic:^{
      ORInt sub = valRange.size;
      ORInt vals[sub];
      ORInt k = 0;
      ORBool fixed[sub];
      memset(fixed,0,sizeof(ORBool)*sub);
      for(id<LSIntVar> aVar in _x) {
         if ([[aVar domain] size] == 1)
            fixed[getLSIntValue(aVar) - valRange.low] |= true;
      }
      for(ORInt i =valRange.low;i <= valRange.up;i++) {
         if (!fixed[i - valRange.low])
            vals[k++] = i;
      }
      ORInt nbUsable = k;
      id<ORIntRange> AV = [[ORIntRangeI alloc] initORIntRangeI: 0 up: nbUsable-1];
      id<ORRandomPermutation> p = [ORFactory randomPermutation:AV];
      for(ORInt k = _x.range.low; k <= _x.range.up;k++) {
         id<ORIntRange> xkd = [_x[k] domain];
         if (xkd.size == 1)
            assert(getLSIntValue(_x[k]) == xkd.low);
         else {
            ORInt theValue = vals[p.next];
            [_x[k] setValue:theValue];
         }
      }
      [AV release];
      [p release];
   }];
}

-(void)post
{
   if (_posted) return;
   _posted = YES;
   ORInt lb=FDMAXINT,ub=FDMININT;
   for(id<LSIntVar> xk in _x) {
      ORInt lk = [xk domain].low;
      ORInt uk = [xk domain].up;
      lb = lk < lb ? lk : lb;
      ub = uk > ub ? uk : ub;
   }
   id<ORIntRange> vals = RANGE(_engine,lb,ub);
   id<ORIntRange> cd   = RANGE(_engine,0,_x.range.size);
   _c = [LSFactory intVarArray:_engine range:vals with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _vv = [LSFactory intVarArray:_engine range:vals with:^id(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
 //  id<LSIntVarArray> xe = [LSFactory intVarArray:_engine range:_x.range with:^id<LSIntVar>(ORInt i) {
 //     return [LSFactory intVar:_engine domain:cd];
 //  }];
   _xv = [LSFactory intVarArray:_engine range:_x.range with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _vvBase = (id*)[(id)_vv base];
   _cBase  = (id*)[(id)_c base];
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory count:_engine vars:_x card:_c]];
   for (ORInt i=vals.low; i <= vals.up; ++i)
      [_engine add:[LSFactory inv:_vv[i] equal:^ { return max(0, [_c[i] value] - 1);} vars:@[_c[i]]]];
   [_engine add:[LSFactory sum: _sum over:_vv]];
//   [_engine add:[LSFactory element:_x of:_vv is:xe]];
//   for (ORInt i=_x.range.low; i <= _x.range.up; ++i)
//      [_engine add:[LSFactory inv:_xv[i] equal:^ { return ([xe[i] value] >0);} vars:@[xe[i]]]];
   [_engine add:[LSFactory gelt:_engine x:_x card:_vv result:_xv]];
}
-(ORBool)isTrue
{
   return getLSIntValue(_sum) == 0;
}
-(ORInt)getViolations
{
   return getLSIntValue(_sum);
}
-(ORInt)getVarViolations:(id<LSIntVar>)x
{
   ORInt xid = getId(x);
   if (_map && _src.range.low <= xid && xid <= _src.range.up) {
      x = _map[xid];
   }
   assert(_vv[x.value].value == [self varViolations:x].value);
   return getLSIntValue(_vvBase[x.value]) > 0;
}
-(id<LSIntVar>)violations
{
   return _sum;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)x
{
   if (isPresent(self,x)) {
      ORInt xid = getId(x);
      if (_map && _sb.min <= xid && xid <= _sb.max)
         x = _map[xid];
      return _xv[_xOfs[getId(x)]];
   }
   else
      return 0;
}

-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max) {
      id<LSIntVar> viewForX = _map[xid];
      v = [(LSIntVar*)x lookahead:viewForX onAssign:v];
      x = viewForX;
   }
   ORInt xv = x.value;
   if (xv == v)
      return 0;
   else {
      const ORInt c1 = getLSIntValue(_cBase[xv]);
      const ORInt c2 = getLSIntValue(_cBase[v]);
      return (c2 >= 1) - (c1 >= 2);
   }
}
// [pvh] no views in here which is strange. Also could delegate to deltaAssign which would be simpler.
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max)
      x = _map[xid];
   ORInt yid = getId(y);
   if (_map && _sb.min <= yid && yid <= _sb.max)
      y = _map[yid];

   ORBool xP = isPresent(self,x);
   ORBool yP = isPresent(self,y);
   if (xP && yP)
      return 0;
   else if (xP==0 && yP==0)
      return 0;
   else {
      if (yP) {
         id<LSIntVar> t = x;
         x = y;
         y = t;
      }
      ORInt xv = x.value;
      ORInt yv = y.value;
      if (xv == yv)
         return 0;
      else {
         const ORInt c1 = _c[xv].value;
         const ORInt c2 = _c[yv].value;
         return (c2 >= 1) - (c1 >= 2);
      }
   }
}
@end


@implementation LSPacking {
   unsigned char* _present;  // boolean array (one boolean per var in _x)
   ORInt              _low;  // lowest variable identifier in _x
   ORInt               _up;  // highest variable identifier in _x
   ORInt*            _xOfs;  // Offset of variable j in array x. i.e., x[_xOfs[j]].getId() == j
   ORBool       _overViews;
   id<LSIntVarArray>  _src;
   ORBounds            _sb;
   id<LSIntVar>*      _map;
   id* _vvBase;
   id*  _cBase;
}
-(id)init: (id<LSIntVarArray>)x weight:(id<ORIntArray>)weight cap:(id<ORIntArray>)cap
{
   id<LSEngine> engine = [x[x.range.low] engine];
   self = [super init:engine];
   _x   = x;
   _weight = weight;
   _cap = cap;
   _src = nil;
   _posted = NO;
   ORBounds b = idRange(_x, (ORBounds){FDMAXINT,0});
   _low = b.min;
   _up  = b.max;
   _present = malloc(sizeof(unsigned char)*(_up - _low + 1));
   memset(_present,0,sizeof(unsigned char)*(_up - _low + 1));
   _present -= _low;
   _xOfs = malloc(sizeof(ORInt)*(_up - _low + 1));
   _xOfs -= _low;
   ORInt k = x.range.low;
   for(id<LSIntVar> v in _x) {
      _present[getId(v)] = YES;
      _xOfs[getId(v)] = k++;
   }
   return self;
}
-(void)dealloc
{
   _present += _low;
   _xOfs    += _low;
   free(_present);
   free(_xOfs);
   _map += _sb.max;
   free(_map);
   [super dealloc];
}
static inline ORBool isPresentPacking(LSPacking* ad,id<LSIntVar> v)
{
   ORUInt vid = getId(v);
   if (ad->_low <= vid && vid <= ad->_up)
      return ad->_present[vid];
   return NO;
}
-(id<LSIntVarArray>) variables
{
   if (_src) return _src;
   _overViews = NO;
   for(id<LSIntVar> xk in _x)
      _overViews |= [xk isKindOfClass:[LSCoreView class]];
   if (_overViews) {
      ORInt sz = (ORInt)[_x count];
      NSArray* asv[sz];
      collectSources(_x, asv);
      ORBool multi = NO;
      _src = sourceVariables(_engine, asv,sz,&multi);     // _src is now packed with the source variables
      _map = makeVar2ViewMap(_src, _x, asv, sz, &_sb); // create a map source -> view
      return _src;
   }
   else {
      _sb = idRange(_x,(ORBounds){FDMAXINT,0});
      return _src = _x;
   }
}

-(void)post
{
   if (_posted) return;
   _posted = YES;
   ORInt lb=FDMAXINT,ub=FDMININT;
   for(id<LSIntVar> xk in _x) {
      ORInt lk = [xk domain].low;
      ORInt uk = [xk domain].up;
      lb = lk < lb ? lk : lb;
      ub = uk > ub ? uk : ub;
   }
   id<ORIntRange> vals = RANGE(_engine,lb,ub);
   id<ORIntRange> cd   = RANGE(_engine,0,_x.range.size);
   _c = [LSFactory intVarArray:_engine range:vals with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _satDegree = [LSFactory intVarArray:_engine range:vals with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _vv = [LSFactory intVarArray:_engine range:vals with:^id(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _xv = [LSFactory intVarArray:_engine range:_x.range with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _vvBase = (id*)[(id)_vv base];
   _cBase  = (id*)[(id)_c base];
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory count: _x weight: _weight count:_c]];
   for (ORInt i=vals.low; i <= vals.up; ++i)
      [_engine add:[LSFactory inv:_satDegree[i] equal: ^{ return [_c[i] value] - [_cap at: i];} vars:@[_c[i]]]];
   for (ORInt i=vals.low; i <= vals.up; ++i)
      [_engine add:[LSFactory inv:_vv[i] equal: ^{ return max(0,[_satDegree[i] value]); } vars:@[_satDegree[i]]]];
   [_engine add:[LSFactory sum: _sum over:_vv]];
   [_engine add:[LSFactory element:_x of:_vv is: _xv]];
}
-(ORBool)isTrue
{
   return getLSIntValue(_sum) == 0;
}
-(ORInt)getViolations
{
   return getLSIntValue(_sum);
}
-(ORInt)getVarViolations:(id<LSIntVar>)x
{
   ORInt xid = getId(x);
   if (_map && _src.range.low <= xid && xid <= _src.range.up) {
      x = _map[xid];
   }
//   assert(_vv[x.value].value == [self varViolations:x].value);
   return getLSIntValue(_vvBase[x.value]);
}
-(id<LSIntVar>)violations
{
   return _sum;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)x
{
   if (isPresentPacking(self,x)) {
      ORInt xid = getId(x);
      if (_map && _sb.min <= xid && xid <= _sb.max)
         x = _map[xid];
      return _xv[_xOfs[getId(x)]];
   }
   else
      return 0;
}

-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max) {
      id<LSIntVar> viewForX = _map[xid];
      v = [(LSIntVar*)x lookahead:viewForX onAssign:v];
      x = viewForX;
   }
   ORInt xv = x.value;
   if (xv == v)
      return 0;
   else {
      const ORInt w = [_weight at: _xOfs[xid]];
      const ORInt newSatxv = [_satDegree[xv] value] - w;
      const ORInt newSatv = [_satDegree[v] value] + w;
      return (max(0,newSatxv) - [_vv[xv] value]) + (max(0,newSatv) - [_vv[v] value]);
   }
}
// [pvh] no views in here which is strange. Also could delegate to deltaAssign which would be simpler.
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   abort();
}
@end


@implementation LSMeetAtmost {
   ORInt               _low;   // lowest variable identifier in _x, _y
   ORInt               _up;    // highest variable identifier in _x, _y
   ORInt*              _xOfs;  // Offset of variable j in array _x and _y;
   ORInt*              _left;  // variable is in _x
   id<LSIntVarArray>   _src;
   unsigned char*      _present;  // boolean array
}
-(id) init: (id<LSIntVarArray>)x and:(id<LSIntVarArray>)y atmost:(ORInt) cap
{
   id<LSEngine> engine = [x[x.range.low] engine];
   self = [super init:engine];
   _x = x;
   _y = y;
   _cap = cap;
   _src = nil;
   _posted = NO;
   ORBounds b = idRange(_x, (ORBounds){FDMAXINT,0});
   _low = b.min;
   _up  = b.max;
   b = idRange(_y, (ORBounds){FDMAXINT,0});
   _low = min(b.min,_low);
   _up = max(b.max,_up);
   
   _present = malloc(sizeof(unsigned char)*(_up - _low + 1));
   memset(_present,0,sizeof(unsigned char)*(_up - _low + 1));
   _present -= _low;
   
   _xOfs = malloc(sizeof(ORInt)*(_up - _low + 1));
   _xOfs -= _low;
   
   _left = malloc(sizeof(ORInt)*(_up - _low + 1));
   _left -= _low;
   
   ORInt k = x.range.low;
   for(id<LSIntVar> v in _x) {
      _present[getId(v)] = YES;
      _xOfs[getId(v)] = k++;
      _left[getId(v)] = YES;
   }
   k = x.range.low;
   for(id<LSIntVar> v in _y) {
      _present[getId(v)] = YES;
      _xOfs[getId(v)] = k++;
      _left[getId(v)] = NO;
   }
   return self;
}
-(void)dealloc
{
   _present += _low;
   _xOfs    += _low;
   free(_present);
   free(_xOfs);
   [super dealloc];
}
static inline ORBool isPresentMeetAtmost(LSMeetAtmost* ad,id<LSIntVar> v)
{
   ORUInt vid = getId(v);
   if (ad->_low <= vid && vid <= ad->_up)
      return ad->_present[vid];
   return NO;
}
-(id<LSIntVarArray>) variables
{
   if (_src)
      return _src;
   ORInt s = _x.range.up - _x.range.low + 1;
   _src = [LSFactory intVarArray:_engine range:RANGE(_engine,1,2*s)];
   ORInt i=1;
   for(id<LSIntVar> xk in _x)
      _src[i++] = [xk retain];
   for(id<LSIntVar> yk in _y)
      _src[i++] = [yk retain];
//   NSLog(@"x.range.size: %d",_x.range.size);
//   NSLog(@"i: %d",i);
//   NSLog(@"_src (meet) = %@",_src);
//   NSLog(@"_src.range = %@",_src.range);
   return _src;
//   return _x;
}

-(void)post
{
   if (_posted)
      return;
   _posted = YES;
   ORInt low = _x.range.low;
   ORInt up = _x.range.up;
   id<ORIntRange> cd   = RANGE(_engine,0,1);
   _equal = [LSFactory intVarArray:_engine range: _x.range with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   for (ORInt i=low; i <= up; ++i)
      [_engine add:[LSFactory inv:_equal[i] equal: ^{ return [_x[i] value] ==[_y[i] value];} vars:@[_x[i],_y[i]]]];
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
//   NSLog(@"equal: %@",_equal);
   [_engine add:[LSFactory sum: _sum over:_equal]];
   _satDegree = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory inv:_satDegree equal: ^{ return [_sum value] - _cap; } vars:@[_sum]]];
   _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory inv:_violations equal: ^{ return max(0,[_satDegree value]); } vars:@[_satDegree]]];
//   ORInt s = _x.range.up - _x.range.low + 1;
   _varv = [LSFactory intVarArray:_engine range: _x.range with: ^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain: RANGE(_engine,0,FDMAXINT)];
   }];
   for(ORInt k = low; k <= up; k++) {
      ORInt o = _xOfs[getId(_x[k])];
      [_engine add: [LSFactory inv: _varv[o] equal: ^{ return ([_violations value] > 0) && ([_x[k] value] == [_y[k] value]); } vars:@[_violations,_x[k],_y[k]]]];
   }
//   for(ORInt k = low; k <= up; k++) {
//      ORInt o = _xOfs[getId(_y[k])];
//      [_engine add: [LSFactory inv: _varv[o+s] equal: ^{ return ([_violations value] > 0) && ([_x[k] value] == [_y[k] value]); } vars:@[_violations,_x[k],_y[k]]]];
//   }
 }
-(ORBool)isTrue
{
   return getLSIntValue(_violations) == 0;
}
-(ORInt)getViolations
{
   return getLSIntValue(_violations);
}
-(ORInt)getVarViolations:(id<LSIntVar>)v
{
   ORInt vid = getId(v);
   // [pvh] should ideally include present but will not be necessary when the new implementation comes
   if (vid < _low || vid > _up)
      return 0;
   ORInt o = _xOfs[vid];
//   ORInt l = _left[vid];
//   if (l)
     return getLSIntValue(_varv[o]);
//   else
//     return getLSIntValue(_varv[o+_x.range.size]);
}
-(id<LSIntVar>)violations
{
   return _violations;
}
-(id<LSIntVar>) varViolations:(id<LSIntVar>)v
{
   if (isPresentMeetAtmost(self,v)) {
      ORInt vid = getId(v);
      ORInt o = _xOfs[vid];
//      ORInt l = _left[vid];
//      if (l) {
//         NSLog(@"_varv[o]: %@",_varv[o]);
         return _varv[o];
//      }
//      else {
//         //NSLog(@"_varv[o+...]: %@",_varv[o+_x.range.size]);
//         return _varv[o+_x.range.size];
//      }
   }
   else
      return 0;
}

-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   ORInt o = _xOfs[xid];
   ORInt l = _left[xid];
   ORInt xv = x.value;
   if (xv == v)
      return 0;
   else {
      ORInt newv;
      ORInt oldv = [_x[o] value] == [_y[o] value];
      if (l)
         newv = (v == [_y[o] value]);
      else
         newv = (v == [_x[o] value]);
      const ORInt nsat = [_satDegree value] + newv - oldv;
      return (max(0,nsat) - [_violations value]);
   }
}
// [pvh] no views in here which is strange. Also could delegate to deltaAssign which would be simpler.
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   abort();
}
@end


@implementation LSPackingOne {
   unsigned char* _present;  // boolean array (one boolean per var in _x)
   ORInt              _low;  // lowest variable identifier in _x
   ORInt               _up;  // highest variable identifier in _x
   ORInt*            _xOfs;  // Offset of variable j in array x. i.e., x[_xOfs[j]].getId() == j
   ORBool       _overViews;
   id<LSIntVarArray>  _src;
   ORBounds            _sb;
   id<LSIntVar>*      _map;
   id* _vvBase;
   id*  _cBase;
}
-(id)init: (id<LSIntVarArray>)x weight:(id<ORIntArray>)weight bin: (ORInt) bin cap:(ORInt)cap
{
   id<LSEngine> engine = [x[x.range.low] engine];
   self = [super init:engine];
   _x   = x;
   _weight = weight;
   _bin= bin;
   _cap = cap;
   _src = nil;
   _posted = NO;
   ORBounds b = idRange(_x, (ORBounds){FDMAXINT,0});
   _low = b.min;
   _up  = b.max;
   _present = malloc(sizeof(unsigned char)*(_up - _low + 1));
   memset(_present,0,sizeof(unsigned char)*(_up - _low + 1));
   _present -= _low;
   _xOfs = malloc(sizeof(ORInt)*(_up - _low + 1));
   _xOfs -= _low;
   ORInt k = x.range.low;
   for(id<LSIntVar> v in _x) {
      _present[getId(v)] = YES;
      _xOfs[getId(v)] = k++;
   }
   return self;
}
-(void)dealloc
{
   _present += _low;
   _xOfs    += _low;
   free(_present);
   free(_xOfs);
   _map += _sb.max;
   free(_map);
   [super dealloc];
}
static inline ORBool isPresentPackingOne(LSPackingOne* ad,id<LSIntVar> v)
{
   ORUInt vid = getId(v);
   if (ad->_low <= vid && vid <= ad->_up)
      return ad->_present[vid];
   return NO;
}
-(id<LSIntVarArray>) variables
{
   if (_src) return _src;
   _overViews = NO;
   for(id<LSIntVar> xk in _x)
      _overViews |= [xk isKindOfClass:[LSCoreView class]];
   if (_overViews) {
      ORInt sz = (ORInt)[_x count];
      NSArray* asv[sz];
      collectSources(_x, asv);
      ORBool multi = NO;
      _src = sourceVariables(_engine, asv,sz,&multi);     // _src is now packed with the source variables
      _map = makeVar2ViewMap(_src, _x, asv, sz, &_sb); // create a map source -> view
      return _src;
   }
   else {
      _sb = idRange(_x,(ORBounds){FDMAXINT,0});
      return _src = _x;
   }
}

-(void)post
{
   if (_posted) return;
   _posted = YES;
   ORInt lb=FDMAXINT,ub=FDMININT;
   for(id<LSIntVar> xk in _x) {
      ORInt lk = [xk domain].low;
      ORInt uk = [xk domain].up;
      lb = lk < lb ? lk : lb;
      ub = uk > ub ? uk : ub;
   }
   _wx = [LSFactory intVarArray:_engine range: _x.range with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain: RANGE(_engine,0,FDMAXINT)];
   }];
   for (ORInt i= _x.range.low; i <= _x.range.up; ++i)
      [_engine add:[LSFactory inv:_wx[i] equal: ^{ return [_weight at: i] * ([_x[i] value] == _bin);} vars:@[_x[i]]]];
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory sum: _sum over:_wx]];
   _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory inv:_violations equal: ^{ return max(0,[_sum value] - _cap); } vars:@[_sum]]];
   _vv = [LSFactory intVarArray:_engine range: _x.range with:^id(ORInt i) {
      return [LSFactory intVar:_engine domain: RANGE(_engine,0,FDMAXINT)];
   }];
   for (ORInt i=_x.range.low; i <= _x.range.up; ++i)
//      [_engine add:[LSFactory inv:_vv[i] equal: ^{ return min([_violations value],[_wx[i] value]); } vars:@[_violations,_wx[i]]]];
      [_engine add:[LSFactory inv:_vv[i] equal: ^{ return [_violations value] *([_wx[i] value] > 0); } vars:@[_violations,_wx[i]]]];
}
-(ORBool)isTrue
{
   return getLSIntValue(_violations) == 0;
}
-(ORInt)getViolations
{
   return getLSIntValue(_violations);
}
-(ORInt)getVarViolations:(id<LSIntVar>)x
{
   ORInt xid = getId(x);
   if (_map && _src.range.low <= xid && xid <= _src.range.up) {
      x = _map[xid];
   }
   //   assert(_vv[x.value].value == [self varViolations:x].value);
   return getLSIntValue(_vvBase[x.value]);
}
-(id<LSIntVar>)violations
{
   return _violations;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)x
{
   if (isPresentPackingOne(self,x)) {
      ORInt xid = getId(x);
      if (_map && _sb.min <= xid && xid <= _sb.max)
         x = _map[xid];
      return _vv[_xOfs[getId(x)]];
   }
   else
      return 0;
}

-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max) {
      id<LSIntVar> viewForX = _map[xid];
      v = [(LSIntVar*)x lookahead:viewForX onAssign:v];
      x = viewForX;
   }
   ORInt xv = x.value;
   const ORInt w = [_weight at: _xOfs[xid]];
   if (xv == v)
      return 0;
   else if (v == _bin)
      return  max(0,[_sum value] + w - _cap) - [_violations value];
   else if (xv == _bin)
      return max(0,[_sum value] - w - _cap) - [_violations value];
   else
      return 0;
}
// [pvh] no views in here which is strange. Also could delegate to deltaAssign which would be simpler.
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   abort();
}
@end

/*
 
 Pack one:
 
 <x,w,b,cap>
 
 wx[i] <- w[i] * (x[i] == b)
 s <- sum(wx)
 violations <- max(0,s - b)
 
 vv[i] = (min(violations,wx[i])
 
 assign(x,v)
   if ([x value] == v)
      return 0;
   else if (v == b) 
      return max(0,s + w[i] - b) - violations;
   else if ([x value] == b)
      return max(0,s - w[i] - b) - violations;
   else 
      return 0;
 
 */


@implementation LSMeetAtmostSat {
   ORInt               _low;   // lowest variable identifier in _x, _y
   ORInt               _up;    // highest variable identifier in _x, _y
   ORInt*              _xOfs;  // Offset of variable j in array _x and _y;
   ORInt*              _left;  // variable is in _x
   id<LSIntVarArray>   _src;
   unsigned char*      _present;  // boolean array
}
-(id) init: (id<LSIntVarArray>)x and:(id<LSIntVarArray>)y atmost:(ORInt) cap
{
   id<LSEngine> engine = [x[x.range.low] engine];
   self = [super init:engine];
   _x = x;
   _y = y;
   _cap = cap;
   _src = nil;
   _posted = NO;
   ORBounds b = idRange(_x, (ORBounds){FDMAXINT,0});
   _low = b.min;
   _up  = b.max;
   b = idRange(_y, (ORBounds){FDMAXINT,0});
   _low = min(b.min,_low);
   _up = max(b.max,_up);
   
   _present = malloc(sizeof(unsigned char)*(_up - _low + 1));
   memset(_present,0,sizeof(unsigned char)*(_up - _low + 1));
   _present -= _low;
   
   _xOfs = malloc(sizeof(ORInt)*(_up - _low + 1));
   _xOfs -= _low;
   
   _left = malloc(sizeof(ORInt)*(_up - _low + 1));
   _left -= _low;
   
   ORInt k = x.range.low;
   for(id<LSIntVar> v in _x) {
      _present[getId(v)] = YES;
      _xOfs[getId(v)] = k++;
      _left[getId(v)] = YES;
   }
   k = x.range.low;
   for(id<LSIntVar> v in _y) {
      _present[getId(v)] = YES;
      _xOfs[getId(v)] = k++;
      _left[getId(v)] = NO;
   }
   return self;
}
-(void)dealloc
{
   _present += _low;
   _xOfs    += _low;
   free(_present);
   free(_xOfs);
   [super dealloc];
}
static inline ORBool isPresentMeetAtmostSat(LSMeetAtmostSat* ad,id<LSIntVar> v)
{
   ORUInt vid = getId(v);
   if (ad->_low <= vid && vid <= ad->_up)
      return ad->_present[vid];
   return NO;
}
-(id<LSIntVarArray>) variables
{
   if (_src)
      return _src;
   ORInt s = _x.range.up - _x.range.low + 1;
   _src = [LSFactory intVarArray:_engine range:RANGE(_engine,1,2*s)];
   ORInt i=1;
   for(id<LSIntVar> xk in _x)
      _src[i++] = [xk retain];
   for(id<LSIntVar> yk in _y)
      _src[i++] = [yk retain];
   //   NSLog(@"x.range.size: %d",_x.range.size);
   //   NSLog(@"i: %d",i);
   //   NSLog(@"_src (meet) = %@",_src);
   //   NSLog(@"_src.range = %@",_src.range);
   return _src;
   //   return _x;
}

-(void)post
{
   if (_posted)
      return;
   _posted = YES;
   ORInt low = _x.range.low;
   ORInt up = _x.range.up;
   id<ORIntRange> cd   = RANGE(_engine,0,1);
   _equal = [LSFactory intVarArray:_engine range: _x.range with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   for (ORInt i=low; i <= up; ++i)
      [_engine add:[LSFactory inv:_equal[i] equal: ^{ return [_x[i] value] ==[_y[i] value];} vars:@[_x[i],_y[i]]]];
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   //   NSLog(@"equal: %@",_equal);
   [_engine add:[LSFactory sum: _sum over:_equal]];
   _satDegree = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory inv:_satDegree equal: ^{ return [_sum value] - _cap; } vars:@[_sum]]];
//   _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
//   [_engine add:[LSFactory inv:_violations equal: ^{ return max(0,[_satDegree value]); } vars:@[_satDegree]]];
   //   ORInt s = _x.range.up - _x.range.low + 1;
   _varv = [LSFactory intVarArray:_engine range: _x.range with: ^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain: RANGE(_engine,0,FDMAXINT)];
   }];
   for(ORInt k = low; k <= up; k++) {
      ORInt o = _xOfs[getId(_x[k])];
      [_engine add: [LSFactory inv: _varv[o] equal: ^{ return ([_x[k] value] == [_y[k] value]); } vars:@[_x[k],_y[k]]]];
   }
   //   for(ORInt k = low; k <= up; k++) {
   //      ORInt o = _xOfs[getId(_y[k])];
   //      [_engine add: [LSFactory inv: _varv[o+s] equal: ^{ return ([_violations value] > 0) && ([_x[k] value] == [_y[k] value]); } vars:@[_violations,_x[k],_y[k]]]];
   //   }
}
-(ORBool)isTrue
{
   return getLSIntValue(_satDegree) <= 0;
}
-(ORInt)getViolations
{
   return getLSIntValue(_satDegree);
}
-(ORInt)getVarViolations:(id<LSIntVar>)v
{
   ORInt vid = getId(v);
   // [pvh] should ideally include present but will not be necessary when the new implementation comes
   if (vid < _low || vid > _up)
      return 0;
   ORInt o = _xOfs[vid];
   //   ORInt l = _left[vid];
   //   if (l)
   return getLSIntValue(_varv[o]);
   //   else
   //     return getLSIntValue(_varv[o+_x.range.size]);
}
-(id<LSIntVar>)violations
{
   return _satDegree;
}
-(id<LSIntVar>) varViolations:(id<LSIntVar>)v
{
   if (isPresentMeetAtmostSat(self,v)) {
      ORInt vid = getId(v);
      ORInt o = _xOfs[vid];
      //      ORInt l = _left[vid];
      //      if (l) {
      //         NSLog(@"_varv[o]: %@",_varv[o]);
      return _varv[o];
      //      }
      //      else {
      //         //NSLog(@"_varv[o+...]: %@",_varv[o+_x.range.size]);
      //         return _varv[o+_x.range.size];
      //      }
   }
   else
      return 0;
}

-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   ORInt o = _xOfs[xid];
   ORInt l = _left[xid];
   ORInt xv = x.value;
   if (xv == v)
      return 0;
   else {
      ORInt newv;
      ORInt oldv = [_x[o] value] == [_y[o] value];
      if (l)
         newv = (v == [_y[o] value]);
      else
         newv = (v == [_x[o] value]);
      const ORInt nsat = [_satDegree value] + newv - oldv;
      return (nsat - [_satDegree value]);
   }
}
// [pvh] no views in here which is strange. Also could delegate to deltaAssign which would be simpler.
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   abort();
}
@end


@implementation LSPackingOneSat {
   unsigned char* _present;  // boolean array (one boolean per var in _x)
   ORInt              _low;  // lowest variable identifier in _x
   ORInt               _up;  // highest variable identifier in _x
   ORInt*            _xOfs;  // Offset of variable j in array x. i.e., x[_xOfs[j]].getId() == j
   ORBool       _overViews;
   id<LSIntVarArray>  _src;
   ORBounds            _sb;
   id<LSIntVar>*      _map;
   id* _vvBase;
   id*  _cBase;
}
-(id)init: (id<LSIntVarArray>)x weight:(id<ORIntArray>)weight bin: (ORInt) bin cap:(ORInt)cap
{
   id<LSEngine> engine = [x[x.range.low] engine];
   self = [super init:engine];
   _x   = x;
   _weight = weight;
   _bin= bin;
   _cap = cap;
   _src = nil;
   _posted = NO;
   ORBounds b = idRange(_x, (ORBounds){FDMAXINT,0});
   _low = b.min;
   _up  = b.max;
   _present = malloc(sizeof(unsigned char)*(_up - _low + 1));
   memset(_present,0,sizeof(unsigned char)*(_up - _low + 1));
   _present -= _low;
   _xOfs = malloc(sizeof(ORInt)*(_up - _low + 1));
   _xOfs -= _low;
   ORInt k = x.range.low;
   for(id<LSIntVar> v in _x) {
      _present[getId(v)] = YES;
      _xOfs[getId(v)] = k++;
   }
   return self;
}
-(void)dealloc
{
   _present += _low;
   _xOfs    += _low;
   free(_present);
   free(_xOfs);
   _map += _sb.max;
   free(_map);
   [super dealloc];
}
static inline ORBool isPresentPackingOneSat(LSPackingOneSat* ad,id<LSIntVar> v)
{
   ORUInt vid = getId(v);
   if (ad->_low <= vid && vid <= ad->_up)
      return ad->_present[vid];
   return NO;
}
-(id<LSIntVarArray>) variables
{
   if (_src) return _src;
   _overViews = NO;
   for(id<LSIntVar> xk in _x)
      _overViews |= [xk isKindOfClass:[LSCoreView class]];
   if (_overViews) {
      ORInt sz = (ORInt)[_x count];
      NSArray* asv[sz];
      collectSources(_x, asv);
      ORBool multi = NO;
      _src = sourceVariables(_engine, asv,sz,&multi);     // _src is now packed with the source variables
      _map = makeVar2ViewMap(_src, _x, asv, sz, &_sb); // create a map source -> view
      return _src;
   }
   else {
      _sb = idRange(_x,(ORBounds){FDMAXINT,0});
      return _src = _x;
   }
}

-(void)post
{
   if (_posted) return;
   _posted = YES;
   ORInt lb=FDMAXINT,ub=FDMININT;
   for(id<LSIntVar> xk in _x) {
      ORInt lk = [xk domain].low;
      ORInt uk = [xk domain].up;
      lb = lk < lb ? lk : lb;
      ub = uk > ub ? uk : ub;
   }
   _wx = [LSFactory intVarArray:_engine range: _x.range with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain: RANGE(_engine,0,FDMAXINT)];
   }];
   for (ORInt i= _x.range.low; i <= _x.range.up; ++i)
      [_engine add:[LSFactory inv:_wx[i] equal: ^{ return [_weight at: i] * ([_x[i] value] == _bin);} vars:@[_x[i]]]];
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory sum: _sum over:_wx]];
   _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory inv:_violations equal: ^{ return [_sum value] - _cap; } vars:@[_sum]]];
   _vv = [LSFactory intVarArray:_engine range: _x.range with:^id(ORInt i) {
      return [LSFactory intVar:_engine domain: RANGE(_engine,0,FDMAXINT)];
   }];
   for (ORInt i=_x.range.low; i <= _x.range.up; ++i)
      //      [_engine add:[LSFactory inv:_vv[i] equal: ^{ return min([_violations value],[_wx[i] value]); } vars:@[_violations,_wx[i]]]];
      [_engine add:[LSFactory inv:_vv[i] equal: ^{ return [_wx[i] value]; } vars:@[_violations,_wx[i]]]];
}
-(ORBool)isTrue
{
   return getLSIntValue(_violations) <= 0;
}
-(ORInt)getViolations
{
   return getLSIntValue(_violations);
}
-(ORInt)getVarViolations:(id<LSIntVar>)x
{
   ORInt xid = getId(x);
   if (_map && _src.range.low <= xid && xid <= _src.range.up) {
      x = _map[xid];
   }
   //   assert(_vv[x.value].value == [self varViolations:x].value);
   return getLSIntValue(_vvBase[x.value]);
}
-(id<LSIntVar>)violations
{
   return _violations;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)x
{
   if (isPresentPackingOneSat(self,x)) {
      ORInt xid = getId(x);
      if (_map && _sb.min <= xid && xid <= _sb.max)
         x = _map[xid];
      return _vv[_xOfs[getId(x)]];
   }
   else
      return 0;
}

-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max) {
      id<LSIntVar> viewForX = _map[xid];
      v = [(LSIntVar*)x lookahead:viewForX onAssign:v];
      x = viewForX;
   }
   ORInt xv = x.value;
   const ORInt w = [_weight at: _xOfs[xid]];
   if (xv == v)
      return 0;
   else if (v == _bin)
      return  [_sum value] + w - _cap - [_violations value];
   else if (xv == _bin)
      return [_sum value] - w - _cap - [_violations value];
   else
      return 0;
}
// [pvh] no views in here which is strange. Also could delegate to deltaAssign which would be simpler.
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   abort();
}
@end


