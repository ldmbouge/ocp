/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSBasic.h"
#import "LSIntVar.h"
#import "LSCount.h"

@implementation LSLEqual {
   id<LSIntVarArray> _src;
   id<LSIntVar>     _viol;
   id<LSIntVar>       _vx;
   id<LSIntVar>       _vy;
}
-(id)init:(id<LSEngine>)engine x:(id<LSIntVar>)x leq:(id<LSIntVar>)y plus:(ORInt)c;  // x ≤ y + c
{
   self = [super init:engine];
   _x = x;
   _y = y;
   _c = c;
   _src = nil;
   return self;
}
-(void)post
{
   id<LSEngine> engine = (id)_engine;
   _viol = [LSFactory intVar:engine domain:RANGE(engine,0,_x.domain.up - _y.domain.low - _c)];
   [engine add:[LSFactory inv:_viol equal:^ORInt{
      return max(0,getLSIntValue(_x) - getLSIntValue(_y) - _c);
   } vars:@[_x,_y]]];
   _vx = [LSFactory intVar:engine domain:RANGE(engine,0,_x.domain.up - _y.domain.low - _c)];
   _vy = [LSFactory intVar:engine domain:RANGE(engine,0,_x.domain.up - _y.domain.low - _c)];
   [engine add:[LSFactory inv:_vx equal:^ORInt{
      return getLSIntValue(_viol) + max(0, - (getLSIntValue(_x) - _x.domain.low));
   } vars:@[_viol,_x]]];
   [engine add:[LSFactory inv:_vy equal:^ORInt{
      return getLSIntValue(_viol) + max(0, - (0 + _y.domain.up - getLSIntValue(_y)));
   } vars:@[_viol,_y]]];
}
-(id<LSIntVarArray>)variables
{
   if (!_src) {
      _src = [LSFactory intVarArray:(id)_engine range:RANGE((id)_engine,0,1)];
      _src[0] = _x;
      _src[1] = _y;
   }
   return _src;
}
-(ORBool)isTrue
{
   return getLSIntValue(_x) <= getLSIntValue(_y) + _c;
}
-(ORInt)getViolations
{
   return max(0,getLSIntValue(_x) - getLSIntValue(_y) - _c);
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   if (getId(var) == getId(_x))
      return getLSIntValue(_vx);
   else if (getId(var) == getId(_y))
      return getLSIntValue(_vy);
   else return 0;
}
-(id<LSIntVar>)violations
{
   return _viol;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   if (getId(var) == getId(_x))
      return _vx;
   else if (getId(var) == getId(_y))
      return _vy;
   else return nil;
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt cv = getLSIntValue(_viol) == 0;
   if (getId(x) == getId(_x))
      return (max(0,v - getLSIntValue(_y) - _c) == 0) - cv;
   else if (getId(x) == getId(_y))
      return (max(0,getLSIntValue(_x) - v - _c) == 0) - cv;
   else return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt vid[2] = { getId(_x),getId(_y) };
   ORInt xid = getId(x),yid = getId(y);
   ORBool xIn = (xid == vid[0] || xid == vid[1]);
   ORBool yIn = (yid == vid[0] || yid == vid[1]);
   if (xIn && yIn) {
      ORInt xv = getLSIntValue(x),yv = getLSIntValue(y);
      ORInt cv = xv <= yv + _c;
      ORInt nv = yv <= xv + _c;
      return nv - cv;
   } else if (xIn) {
      return [self deltaWhenAssign:x to:getLSIntValue(y)];
   } else if (yIn) {
      return [self deltaWhenAssign:y to:getLSIntValue(x)];
   } else return 0;
}
@end
