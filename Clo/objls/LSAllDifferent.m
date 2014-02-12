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

@implementation LSAllDifferent {
   unsigned char* _present;  // boolean array (one boolean per var in _x)
   ORInt          _low;      // lowest variable identifier in _x
   ORInt          _up;       // highest variable identifier in _x
}
-(id)init:(id<LSEngine>)engine vars:(id<LSIntVarArray>)x
{
   self = [super init:engine];
   _x   = x;
   _posted = NO;
   _low = FDMAXINT;
   _up  = FDMININT;
   for(id<LSIntVar> v in _x) {
      _low = getId(v) < _low ? getId(v) : _low;
      _up  = getId(v) > _up  ? getId(v) : _up;
   }
   _present = malloc(sizeof(unsigned char)*(_up - _low + 1));
   _present -= _low;
   memset(_present,0,sizeof(unsigned char)*(_up - _low + 1));
   for(id<LSIntVar> v in _x)
      _present[getId(v)] = YES;
   return self;
}
static inline ORBool isPresent(LSAllDifferent* ad,id<LSIntVar> v)
{
   ORUInt vid = getId(v);
   if (ad->_low <= vid && vid <= ad->_up)
      return ad->_present[vid];
   return NO;
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
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];

   [_engine add:[LSFactory count:_engine vars:_x card:_c]];
   for (ORInt i=vals.low; i <= vals.up; ++i)
      [_engine add:[LSFactory inv:_vv[i] equal:^ { return max(0, [_c[i] value] - 1);} vars:@[_c[i]]]];
   [_engine add:[LSFactory sum: _sum over:_vv]];
}
-(ORBool)isTrue
{
   return _sum.value == 0;
}
-(ORInt)getViolations
{
   return _sum.value;
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   return _vv[var.value].value > 0;
}
-(id<LSIntVar>)violations
{
   return _sum;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   return nil;
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   if (x.value == v)
      return 0;
   else {
      const ORInt c1 = _c[x.value].value;
      const ORInt c2 = _c[v].value;
      return (c2 >= 1) - (c1 >= 2);
   }
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
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
