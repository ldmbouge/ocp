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
   ORBounds           _xb;
   ORBounds           _sb;
   ORInt*           _tmap;     // mapping variables (x_i) to term identifier : i
   id<LSIntVarArray>  _vv;
}

-(id)init:(id<LSEngine>)engine
    coefs:(id<ORIntArray>)coefs
     vars:(id<LSIntVarArray>)x
     type:(LSLinearType)ty
 constant:(ORInt)c;     // sum(i in S) a_i x_i OP c
{
   self = [super init:engine];
   _coefs = coefs;
   _x = x;
   _t = ty;
   _posted = NO;
   return self;
}
-(void)dealloc
{
   _tmap += _xb.min;
   free(_tmap);
   _map += _sb.min;
   free(_map);
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
      ORInt ck = [_coefs at:k];
      if (ck > 0) {
         low += ck * xl;
         up  += ck * xu;
      } else {
         low += ck * xu;
         up  += ck * xl;
      }
   }
   _value = [LSFactory intVar:_engine domain:RANGE(_engine,low,up)];
   [_engine add:[LSFactory sum:_value is:_coefs times:_x]];
   switch(_t) {
      case LSTYEqual: {
         _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,max(abs(low - _c), abs(up- _c)))];
         [_engine add:[LSFactory inv:_violations equal:^ORInt{
            return abs(_value.value  - _c);
         } vars:@[_value]]];
      }break;
      case LSTYLEqual:
      case LSTYGEqual: {
         _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,max(abs(low - _c), abs(up - _c)))];
         [_engine add:[LSFactory inv:_violations equal:^ORInt{
            return max(0, _value.value - _c);
         } vars:@[_value]]];
      }break;
      case LSTYNEqual: {
         _violations = [LSFactory intVar:_engine domain:RANGE(_engine,0,1)];
         [_engine add:[LSFactory inv:_violations equal:^ORInt{
            return _value.value == _c;
         } vars:@[_value]]];
      }break;
   }
   _sat = [LSFactory intVar:_engine domain:RANGE(_engine,0,1)];
   [_engine add:[LSFactory inv:_sat equal:^ORInt{
      return _violations.value == 0;
   } vars:@[_violations]]];

   [self variables];  // now _src and _sb are both defined
   _xb = idRange(_x, (ORBounds){FDMAXINT,0});
   _tmap = malloc(sizeof(ORInt)*(_xb.max - _xb.min + 1));
   _tmap -= _xb.min;
   for(ORInt k=_x.low;k <= _x.up;k++)
      _tmap[getId(_x[k])] = k;
   _vv = [LSFactory intVarArray:_engine
                          range:RANGE(_engine,_sb.min,_sb.max)
                         domain:RANGE(_engine,FDMININT,FDMAXINT)];

   for(ORInt k=_src.range.low; k <= _src.range.up;k++) {
      id<LSIntVar> sk = _src[k];
      ORInt idx = getId(sk);
      id<LSIntVar> downG = [self downGSum:sk];
      id<LSIntVar> upG   = [self upGSum:sk];
      [_engine add:[LSFactory inv:_vv[idx] equal:^ORInt{
         ORInt fv = _value.value;
         if (fv >= 0)
            return min(fv,downG.value);
         else
            return min(-fv,upG.value);
      } vars:@[_value,downG,upG]]];
   }
}
-(id<LSIntVar>)downGSum:(id<LSIntVar>)sk
{
   id<LSIntVar> gv[_x.range.size];
   ORInt        gc[_x.range.size];
   id<LSIntVar>* gvPtr = gv;
   ORInt        nbt = 0;
   ORInt        gi = 0;
   for(ORInt t=_x.range.low; t <= _x.range.up;t++) {
      ORInt ct = [_coefs at:t];
      id<LSIntVar> xt = _x[t];
      if (ct > 0) {
         LSGradient gt = [xt decrease:sk];
         if (gt._gt == LSGCst)
            gi += gt._cg;
         else {
            gv[nbt] = gt._vg;
            gc[nbt] = ct;
            nbt++;
         }
      } else {
         LSGradient gt = [xt increase:sk];
         if (gt._gt == LSGCst)
            gi -= gt._cg;
         else {
            gv[nbt] = gt._vg;
            gc[nbt] = abs(ct);
            nbt++;
         }
      }
   }
   id<ORIntRange> R = RANGE(_engine,0,nbt-1);
   id<LSIntVarArray> gtv = [LSFactory intVarArray:_engine range:R with:^id<LSIntVar>(ORInt k) { return gvPtr[k];}];
   id<ORIntArray> gcoef  = [ORFactory intArray:_engine range:R values:gc];
   id<LSIntVar> downG = [LSFactory intVar:_engine domain:RANGE(_engine,FDMININT,FDMAXINT)];
   [_engine add:[LSFactory sum:downG is:gcoef times:gtv]];
   return downG;
}
-(id<LSIntVar>)upGSum:(id<LSIntVar>)sk
{
   id<LSIntVar> gv[[[_x range] size]];
   ORInt        gc[[[_x range] size]];
   id<LSIntVar>* gvPtr = gv;
   ORInt        nbt = 0;
   ORInt        gi = 0;
   for(ORInt t=_x.range.low; t <= _x.range.up;t++) {
      ORInt ct = [_coefs at:t];
      id<LSIntVar> xt = _x[t];
      if (ct > 0) {
         LSGradient gt = [xt increase:sk];
         if (gt._gt == LSGCst)
            gi += gt._cg;
         else {
            gv[nbt] = gt._vg;
            gc[nbt] = ct;
            nbt++;
         }
      } else {
         LSGradient gt = [xt decrease:sk];
         if (gt._gt == LSGCst)
            gi -= gt._cg;
         else {
            gv[nbt] = gt._vg;
            gc[nbt] = abs(ct);
            nbt++;
         }
      }
   }
   id<ORIntRange> R = RANGE(_engine,0,nbt-1);
   id<LSIntVarArray> gtv = [LSFactory intVarArray:_engine range:R with:^id<LSIntVar>(ORInt k) { return gvPtr[k];}];
   id<ORIntArray> gcoef  = [ORFactory intArray:_engine range:R values:gc];
   id<LSIntVar> upG = [LSFactory intVar:_engine domain:RANGE(_engine,FDMININT,FDMAXINT)];
   [_engine add:[LSFactory sum:upG is:gcoef times:gtv]];
   return upG;
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
   return _vv[getId(var)].value;
}
-(id<LSIntVar>)violations
{
   return _violations;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)x
{
   return _vv[getId(x)];
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max) {
      id<LSIntVar> viewForX = _map[xid];
      v = [(LSIntVar*)x lookahead:viewForX onAssign:v];
      x = viewForX;
   }
   ORInt tid = _tmap[getId(x)];
   ORInt cv = x.value;
   ORInt nv = v;
   if (cv == nv)
      return 0;
   else {
      ORInt eval  = _value.value;
      ORInt neval = eval + (nv - cv) * [_coefs at:tid];
      switch(_t) {
         case LSTYEqual: return abs(neval - _c) - abs(eval - _c);
         case LSTYLEqual:
         case LSTYGEqual: {
            ORInt nOut = neval - _c < 0 ? 0 : neval - _c;
            ORInt oOut = eval  - _c < 0 ? 0 : eval  - _c;
            return nOut - oOut;
         }
         case LSTYNEqual: return (neval == _c) - (eval == _c);
      }
   }
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt xid = getId(x);
   if (_map && _sb.min <= xid && xid <= _sb.max)
      x = _map[xid];
   ORInt txid = _tmap[getId(x)];
   ORInt yid = getId(y);
   if (_map && _sb.min <= yid && yid <= _sb.max)
      y = _map[yid];
   ORInt tyid = _tmap[getId(y)];
   if (x == y)
      return 0;
   else
   return 0;
}
@end
