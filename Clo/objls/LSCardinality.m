/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSCardinality.h"
#import <ORFoundation/ORSetI.h>
#import <objls/LSFactory.h>
#import "LSEngineI.h"
#import "LSGlobalInvariants.h"
#import "LSCount.h"
#import "LSIntVar.h"

@implementation LSCardinality {
   id<LSIntVarArray> _card; // actual cardinality of value k in _x
   id<LSIntVarArray> _vv;   // value violations
   id<LSIntVarArray> _xv;   // variable violations
   id<LSIntVar>     _sum;   // total violations
   ORBool        _posted;   // whether we have been posted already.

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

-(id)init:(id<LSEngine>)engine low:(id<ORIntArray>)lb vars:(id<LSIntVarArray>)x up:(id<ORIntArray>)ub
{
   self = [super init:engine];
   _lb = lb;
   _ub = ub;
   _x  = x;
   _card = _vv = _xv = nil;
   _sum = nil;
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
static inline ORBool isPresent(LSCardinality* ad,id<LSIntVar> v)
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
static inline ORInt max3(ORInt a,ORInt b,ORInt c)
{
   return max(max(a,b),c);
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
   ORInt slb = sumSet(_lb.range, ^ORInt(ORInt i) { return [_lb at:i];});
   ORInt sub = sumSet(_lb.range, ^ORInt(ORInt i) { return [_ub at:i];});
   if (slb > [_x count])
      @throw [[ORExecutionError alloc] initORExecutionError:"Sum of cardinality lower-bounds exceeds array size"];
   if (sub < [_x count])
      @throw [[ORExecutionError alloc] initORExecutionError:"Sum of cardinality upper-bounds does not reach array size"];
   id<ORIntRange> vals = RANGE(_engine,lb,ub);
   id<ORIntRange> cd   = RANGE(_engine,0,_x.range.size);
   _card = [LSFactory intVarArray:_engine range:vals with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _vv = [LSFactory intVarArray:_engine range:vals with:^id(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _xv = [LSFactory intVarArray:_engine range:_x.range with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:_engine domain:cd];
   }];
   _vvBase = (id*)[(id)_vv base];
   _cBase  = (id*)[(id)_card base];
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   [_engine add:[LSFactory count:_engine vars:_x card:_card]];
   for (ORInt i=vals.low; i <= vals.up; ++i) {
      ORInt lbi = [_lb at:i],ubi = [_ub at:i];
      [_engine add:[LSFactory inv:_vv[i] equal:^ { return max3(0,_card[i].value - ubi,lbi - _card[i].value);} vars:@[_card[i]]]];
   }
   [_engine add:[LSFactory sum: _sum over:_vv]];
   [_engine add:[LSFactory gelt:_engine x:_x card:_vv result:_xv]];
}
-(void)hardInit
{
   ORInt slb = sumSet(_lb.range, ^ORInt(ORInt i) { return [_lb at:i];});
   ORInt sub = sumSet(_lb.range, ^ORInt(ORInt i) { return [_ub at:i];});
   if (slb > 0)
      @throw [[ORExecutionError alloc] initORExecutionError:"Cardinality constraint cannot be hard if sum of lower bounds is > 0"];
   if (sub != [_x count])
      @throw [[ORExecutionError alloc] initORExecutionError:"Cardinality constraint cannot be hard if sum of upper bounds is not tight"];
   [_engine atomic:^{
      ORInt vals[sub];
      ORInt k = 0;
      for(ORInt i =_ub.range.low;i <= _ub.range.up;i++)
         for(ORInt j=0;j < [_ub at:i];j++)
            vals[k++] = i;
      id<ORIntRange> AV = [[ORIntRangeI alloc] initORIntRangeI: 0 up: sub-1];
      id<ORRandomPermutation> p = [ORFactory randomPermutation:AV];
      for(ORInt k = _x.range.low; k <= _x.range.up;k++) {
         ORInt theValue = vals[p.next];
         [_x[k] setValue:theValue];
      }
      [AV release];
      [p release];
   }];
}

-(ORBool)isTrue
{
   return getLSIntValue(_sum) == 0;
}
-(ORInt)getViolations
{
   return getLSIntValue(_sum);
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   ORInt xid = getId(var);
   if (_map && _src.range.low <= xid && xid <= _src.range.up) {
      var = _map[xid];
   }
   assert(_xv[var.value].value == [self varViolations:var].value);
   return getLSIntValue(_xv[getLSIntValue(var)]) > 0;
}
-(id<LSIntVar>)violations
{
   return _sum;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSCardinality: %p %@  cards = %@ viol = %@>",self,_x,_card,_vv];
   return buf;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   if (isPresent(self,var)) {
      ORInt xid = getId(var);
      if (_map && _sb.min <= xid && xid <= _sb.max)
         var = _map[xid];
      return _xv[_xOfs[getId(var)]];
   }
   else
      return 0;
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max) {
      id<LSIntVar> viewForX = _map[xid];
      v = [viewForX valueWhenVar:x equal:v];
      x = viewForX;
   }
   ORInt xv = getLSIntValue(x);
   if (xv == v)
      return 0;
   else {
      const ORInt c1 = getLSIntValue(_cBase[xv]);  // new(c1) will be c1 - 1
      const ORInt c2 = getLSIntValue(_cBase[v]);   // new(c2) will be c2 + 1
      ORInt violC2DecL = c2 <= [_lb at:v] - 1;
      ORInt violC2IncU = c2 >= [_ub at:v];
      ORInt violC1DecU = c1 >= [_ub at:v] + 1;
      ORInt violC1IncL = c1 <= [_lb at:v];
      ORInt vc1New = - violC1DecU + violC1IncL;
      ORInt vc2New = - violC2DecL + violC2IncU;
      return vc1New + vc2New;
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
   else if (xP)
      return [self deltaWhenAssign:x to:getLSIntValue(y)];
   else if (yP)
      return [self deltaWhenAssign:y to:getLSIntValue(x)];
   else
      return 0;
}
@end
