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

@implementation LSAllDifferent
-(id)init:(id<LSEngine>)engine vars:(id<LSIntVarArray>)x
{
   self = [super init:engine];
   _x   = x;
   _posted = NO;
   return self;
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
   return _vv[var.value].value;
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
   return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   return 0;
}
@end
