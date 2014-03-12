/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSAllDifferent.h"
#import <objls/LSFactory.h>
#import "LSEngineI.h"
#import "LSCount.h"
#import "LSIntVar.h"

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
   _low = FDMAXINT;
   _up  = 0;
   for(id<LSIntVar> v in _x) {
      _low = getId(v) < _low ? getId(v) : _low;
      _up  = getId(v) > _up  ? getId(v) : _up;
   }
   _present = malloc(sizeof(unsigned char)*(_up - _low + 1));
   _present -= _low;
   memset(_present,0,sizeof(unsigned char)*(_up - _low + 1));
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
-(id<LSIntVarArray>)variables
{
   if (_src) return _src;
   _overViews = NO;
   for(id<LSIntVar> xk in _x)
      _overViews |= [xk isKindOfClass:[LSIntVarView class]];
   if (_overViews) {
      ORInt sz = (ORInt)[_x count];
      NSArray* asv[sz];
      collectSources(_x, asv);
      _src = sourceVariables(_engine, asv,sz);     // _src is now packed with the source variables
      _map = makeVar2ViewMap(_src, _x, asv, sz, &_sb); // create a map source -> view
      return _src;
   } else {
      _sb = idRange(_x,(ORBounds){FDMAXINT,0});
      return _src = _x;
   }
}

-(void)post
{
   ORInt lb=FDMAXINT,ub=FDMININT;
   for(id<LSIntVar> xk in _x) {
      ORInt lk = [xk domain].low;
      ORInt uk = [xk domain].up;
      lb = lk < lb ? lk : lb;
      ub = uk > ub ? uk : ub;
   }
   id<ORIntRange> vals = RANGE(_engine,lb,ub);
   id<ORIntRange> cd   = RANGE(_engine,0,_x.range.size);
   if (_posted) return;
   _c = [LSFactory intVarArray:_engine range:vals with:^id<LSIntVar>(ORInt i) {
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
   [_engine add:[LSFactory count:_engine vars:_x card:_c]];
   for (ORInt i=vals.low; i <= vals.up; ++i)
      [_engine add:[LSFactory inv:_vv[i] equal:^ { return max(0, [_c[i] value] - 1);} vars:@[_c[i]]]];
   [_engine add:[LSFactory sum: _sum over:_vv]];
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
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max)
      x = _map[xid];
   return _xv[_xOfs[getId(x)]];
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
