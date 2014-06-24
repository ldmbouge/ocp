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


// ==================================================================================

@implementation LSNEqualc {
   id<LSIntVarArray> _src;
   id<LSIntVar>     _viol;
}
-(id)init:(id<LSEngine>)engine x:(id<LSIntVar>)x neq:(ORInt)c;  // x != c
{
   self = [super init:engine];
   _x = x;
   _c = c;
   _src = nil;
   return self;
}
-(void)post
{
   id<LSEngine> engine = (id)_engine;
   // viol = 1 - min(1,abs(x - c))
   // viol = (x == c)
   _viol = [LSFactory intVarView:engine var:_x eq:_c];   
//   _viol = [LSFactory intVar:engine domain:RANGE(engine,0,1)];
//   [engine add:[LSFactory inv:_viol equal:^ORInt{
//      return getLSIntValue(_x) == _c;
//   } vars:@[_x]]];
}
-(id<LSIntVarArray>)variables
{
   if (!_src) {
      _src = [LSFactory intVarArray:(id)_engine range:RANGE((id)_engine,0,0)];
      _src[0] = _x;
   }
   return _src;
}
-(ORBool)isTrue
{
   return getLSIntValue(_x) != _c;
}
-(ORInt)getViolations
{
   return getLSIntValue(_x) == _c;
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   if (getId(var) == getId(_x))
      return getLSIntValue(_viol);
   else return 0;
}
-(id<LSIntVar>)violations
{
   return _viol;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   if (getId(var) == getId(_x))
      return _viol;
   else return nil;
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   if (getId(x) == getId(_x)) {
      return (getLSIntValue(_x) != _c) - (v != _c);
   } else return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt xid = getId(_x);
   if (xid == getId(x))
      return [self deltaWhenAssign:x to:getLSIntValue(y)];
   else if (xid == getId(y))
      return [self deltaWhenAssign:y to:getLSIntValue(x)];
   else return 0;
}
@end

@implementation LSOr {
   id<LSIntVarArray> _src;
   id<LSIntVar>      _viol;
   id<LSIntVarArray> _vx;
}
-(id)init:(id<LSEngine>)engine boolean:(id<LSIntVar>)b equal:(id<LSIntVar>)x or:(id<LSIntVar>)y
{
   self = [super init:engine];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
static inline ORInt flipper(ORInt b) { return b * 2 - 1;}

-(void)post
{
   id<LSEngine> engine = (id)_engine;
   _viol = [LSFactory intVar:engine domain:RANGE(engine, 0, 1)];
   [engine add:[LSFactory inv:_viol equal:^ORInt{
      return abs(getLSIntValue(_b) - (getLSIntValue(_x) || getLSIntValue(_y)));
   } vars:@[_b,_x,_y]]];
   _vx = [LSFactory intVarArray:engine range:RANGE(engine,0,2) domain:RANGE(engine,0,1)];
   [_engine add:[LSFactory inv:_vx[0] equal:^ORInt{
      return flipper(getLSIntValue(_viol)==0) * (getLSIntValue(_b) == 1);
   } vars:@[_b,_viol]]];
   [_engine add:[LSFactory inv:_vx[1] equal:^ORInt{
      return flipper(getLSIntValue(_viol)==0) * (getLSIntValue(_x) == 1);
   } vars:@[_x,_viol]]];
   [_engine add:[LSFactory inv:_vx[2] equal:^ORInt{
      return flipper(getLSIntValue(_viol)==0) * (getLSIntValue(_y) == 1);
   } vars:@[_x,_viol]]];
}
-(id<LSIntVarArray>)variables
{
   if (!_src) {
      _src = [LSFactory intVarArray:(id)_engine range:RANGE((id)_engine,0,2)];
      _src[0] = _b;
      _src[1] = _x;
      _src[2] = _y;
   }
   return _src;
}
-(ORBool)isTrue
{
   return getLSIntValue(_viol) == 0;
}
-(ORInt)getViolations
{
   return getLSIntValue(_viol);
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   if (getId(var) == getId(_b))
      return getLSIntValue(_vx[0]);
   else if (getId(var) == getId(_x))
      return getLSIntValue(_vx[1]);
   else if (getId(var) == getId(_y))
      return getLSIntValue(_vx[2]);
   else return 0;
}
-(id<LSIntVar>)violations
{
   return _viol;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   if (getId(var) == getId(_b))
      return _vx[0];
   else if (getId(var) == getId(_x))
      return _vx[1];
   else if (getId(var) == getId(_y))
      return _vx[2];
   else return 0;
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid  = getId(x);
   ORInt orig = getLSIntValue(_b) == (getLSIntValue(_x) || getLSIntValue(_y));
   if (xid == getId(_b))
      return (v == getLSIntValue(_x) || getLSIntValue(_y)) - orig;
   else if (xid == getId(_x))
      return (getLSIntValue(_b) == v || getLSIntValue(_y)) - orig;
   else if (xid == getId(_y))
      return (getLSIntValue(_b) == v || getLSIntValue(_x)) - orig;
   else return 0;
}
inline static ORInt presentIn(ORInt key,ORInt* t,ORInt sz)
{
   while(sz--)
      if (t[sz] == key)
         return YES;
   return NO;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt xid = getId(x),yid = getId(y);
   ORInt cid[3] = {getId(_x),getId(_y),getId(_b)};
   ORInt xIn =presentIn(xid,cid,3),yIn = presentIn(yid,cid,3);
   if (xIn && yIn) {
      ORInt orig = getLSIntValue(_b) == (getLSIntValue(_x) || getLSIntValue(_y));
      if (xid == cid[0]) {
         if (yid == cid[1]) {
            // b is the non-mentioned var
            return 0; // no effect (|| commutes)
         } else {
            assert(yid == cid[2]);
            // _y is is non-mentioned var  (swap(_x,_b))
            ORInt nb = getLSIntValue(_x),nx = getLSIntValue(_b);
            ORInt new = nb == nx || getLSIntValue(_y);
            return new - orig;
         }
      } else if (xid == cid[1]) {
         if (yid == cid[0]) {
            // b is the non-mentioned var
            return 0; // no effect (|| commutes)
         } else {
            assert(yid == cid[2]);
            // _x is the non-mentioned var --> swap(_y,_b)
            ORInt nb = getLSIntValue(_y),ny = getLSIntValue(_b);
            ORInt new = nb == getLSIntValue(_x) || ny;
            return new - orig;
         }
      } else {
         assert(xid == cid[2]);
         if (yid == cid[0]) {
            // _y is the non mentioned var --> swap(b,x)
            ORInt nb = getLSIntValue(_x),nx = getLSIntValue(_b);
            ORInt new = nb == nx || getLSIntValue(_y);
            return new - orig;
         } else {
            assert(yid == cid[1]);
            // _x is the non-mentioned var --> swap(b,y)
            ORInt nb = getLSIntValue(_y),ny = getLSIntValue(_b);
            ORInt new = nb == getLSIntValue(_x) || ny;
            return new - orig;
         }
      }
   } else if (xIn)
      return [self deltaWhenAssign:x to:getLSIntValue(y)];
   else if (yIn)
      return [self deltaWhenAssign:y to:getLSIntValue(x)];
   else return 0;
}
@end
