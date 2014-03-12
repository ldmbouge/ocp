/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSLinear.h"
#import <objls/LSFactory.h>
#import "LSEngineI.h"
#import "LSCount.h"
#import "LSIntVar.h"


@implementation LSLinear {
   ORBool _posted;
   id<LSIntVar> _value;        // sum(i in S) a_i * x_i
   id<LSIntVar> _sat;          // sat <=> sum(i in S) a_i * x_i OP 0
   id<LSIntVar> _violations;
   id<LSIntVarArray> _src;
   ORBool      _overViews;     // are there views involved?
   id<LSIntVar>*     _map;
   ORBounds           _sb;
}

-(id)init:(id<LSEngine>)engine
    coefs:(id<ORIntArray>)c
     vars:(id<LSIntVarArray>)x
     type:(LSLinearType)ty;     // sum(i in S) a_i x_i OP 0
{
   self = [super init:engine];
   _c = c;
   _x = x;
   _t = ty;
   _posted = NO;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void)post
{
   if (_posted) return;
   _posted = YES;
   ORInt low = 0,up = 0;
   for(ORInt k=_x.low;k <= _x.up;k++) {
      ORInt xl = [[_x[k] domain] low];
      ORInt xu = [[_x[k] domain] up];
      ORInt ck = [_c at:k];
      if (ck > 0) {
         low += ck * xl;
         up  += ck * xu;
      } else {
         low += ck * xu;
         up  += ck * xl;
      }
   }
   _value = [LSFactory intVar:_engine domain:RANGE(_engine,low,up)];
   [_engine add:[LSFactory sum:_value is:_c times:_x]];
   switch(_t) {
      case LSTYEqual: {
         _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,max(abs(low), abs(up)))];
         [_engine add:[LSFactory inv:_violations equal:^ORInt{
            return abs(_value.value);
         } vars:@[_value]]];
      }break;
      case LSTYLEqual:
      case LSTYGEqual: {
         _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,max(abs(low), abs(up)))];
         [_engine add:[LSFactory inv:_violations equal:^ORInt{
            return max(0, _value.value);
         } vars:@[_value]]];
      }break;
      case LSTYNEqual: {
         _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,1)];
         [_engine add:[LSFactory inv:_violations equal:^ORInt{
            return _value.value == 0;
         } vars:@[_value]]];
      }break;
   }
   _sat = [LSFactory intVar:_engine domain:RANGE(_engine,0,1)];
   [_engine add:[LSFactory inv:_sat equal:^ORInt{
      return _violations.value == 0;
   } vars:@[_violations]]];
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
-(ORBool)isTrue
{
   return _sat.value;
}
-(ORInt)getViolations
{
   return _violations.value;
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   return _violations.value;
}
-(id<LSIntVar>)violations
{
   return _violations;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   return _violations;
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
