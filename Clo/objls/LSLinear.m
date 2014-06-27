/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSLinear.h"
#import <objls/LSFactory.h>
#import "LSEngineI.h"
#import "LSCount.h"
#import "LSIntVar.h"

typedef struct LSTermDesc {
   ORInt            _ofs;
   id<LSIntVar> _termVar;
} LSTermDesc;

typedef struct LSOccurrence {
   ORInt       _n;  // number of terms
   LSTermDesc* _t;  // pointer to array of terms
} LSOccurrence;

@implementation LSLinear {
   ORBool _posted;
   id<LSIntVar> _value;        // sum(i in S) a_i * x_i
   id<LSIntVar> _sat;          // sat <=> sum(i in S) a_i * x_i OP 0
   id<LSIntVar> _violations;
   id<LSIntVarArray> _src;
   ORBool      _overViews;     // are there views involved?
   ORBounds           _xb;
   ORBounds           _sb;
   ORInt*           _tmap;     // mapping variables (x_i) to term identifier : i
   id<LSIntVarArray>  _vv;
   ORInt*  _srcOfs;
   LSOccurrence*  _occ;  // array of occurrences for source variables
   ORInt        _nbOcc;  // how many occurrence  entries (same as _src.size)
   LSTermDesc*     _at;  // flat array of all terms (for sub-allocation inside _occ).
   ORInt*         _cBase;
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
   _c = c;
   _t = ty;
   _posted = NO;
   _cBase  = (ORInt*)[(id)_coefs base];
   return self;
}
-(void)dealloc
{
   _tmap += _xb.min;
   _srcOfs += _sb.min;
   free(_srcOfs);
   free(_tmap);
   free(_occ);
   free(_at);
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
      }
      else {
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
   ORBool present[_sb.max - _sb.min + 1];
   memset(present,0,sizeof(ORBool)*(_sb.max - _sb.min + 1));
   ORBool* pp = present;
   for(id<LSIntVar> y in _src)
      present[getId(y) - _sb.min] = YES;
   // present tells us in O(1) whether a specific source variable exist (and therefore what kind of violation
   // variable must be created.
   
   
   _xb = idRange(_x, (ORBounds){FDMAXINT,0});
   _tmap = malloc(sizeof(ORInt)*(_xb.max - _xb.min + 1));
   _tmap -= _xb.min;
   for(ORInt k=_x.low;k <= _x.up;k++)
      _tmap[getId(_x[k])] = k;
   id<ORIntRange> wide = RANGE(_engine,FDMININT,FDMAXINT);
   _vv = [LSFactory intVarArray:_engine range:RANGE(_engine,_sb.min,_sb.max) with:^id<LSIntVar>(ORInt k) {
      if (pp[k - _sb.min])
         return [LSFactory intVar:_engine domain:wide];
      else
         return [LSFactory intVar:_engine domain:RANGE(_engine,0,0)];
   }];
   for(ORInt k=_src.range.low; k <= _src.range.up;k++) {
      id<LSIntVar> sk = _src[k];
      ORInt idx = getId(sk);
      id<LSIntVar> downG = [self downGSum:sk];
      id<LSIntVar> upG   = [self upGSum:sk];
      [_engine add:[LSFactory inv:_vv[idx] equal:^ORInt{
         ORInt fv = _value.value - _c;
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
         id<LSGradient> gt = [xt decrease:sk];
         if (gt.isConstant)
            gi += gt.constant;
         else {
            gv[nbt] = gt.variable;
            gc[nbt] = ct;
            nbt++;
         }
         [gt release];
      } else {
         id<LSGradient> gt = [xt increase:sk];
         if (gt.isConstant)
            gi -= gt.constant;
         else {
            gv[nbt] = gt.variable;
            gc[nbt] = abs(ct);
            nbt++;
         }
         [gt release];
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
         id<LSGradient> gt = [xt increase:sk];
         if (gt.isConstant)
            gi += gt.constant;
         else {
            gv[nbt] = gt.variable;
            gc[nbt] = ct;
            nbt++;
         }
         [gt release];
      }
      else {
         id<LSGradient> gt = [xt decrease:sk];
         if (gt.isConstant)
            gi -= gt.constant;
         else {
            gv[nbt] = gt.variable;
            gc[nbt] = abs(ct);
            nbt++;
         }
         [gt release];
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
      ORBool multi = NO;
      _src = sourceVariables(_engine, asv,sz,&multi);  // _src is now packed with the source variables. _src uses 0-based indexing
      ORInt ttlSz = 0;
      for(ORInt i=0;i<sz;i++)
         ttlSz += [asv[i] count];
      _at = malloc(sizeof(LSTermDesc)*ttlSz);
      _nbOcc =_src.range.size;
      _occ = malloc(sizeof(LSOccurrence)*_nbOcc);
      LSTermDesc* ptr = _at;
      for(ORInt i=0;i<_nbOcc;i++) {
         _occ[i]._n = 0;
         _occ[i]._t = ptr;
         for(ORInt j=_x.range.low; j <= _x.range.up;j++) {
            if ([asv[j - _x.range.low] containsObject:_src[i]]) {
               _occ[i]._t[_occ[i]._n]._termVar = _x[j];
               _occ[i]._t[_occ[i]._n]._ofs     = j;
               _occ[i]._n++;
            }
         }
         ptr += _occ[i]._n;
      }
   }
   else {
      _src = _x;
      ORInt sz = _nbOcc = _src.range.size;
      _at = malloc(sizeof(LSTermDesc)*sz);
      _occ = malloc(sizeof(LSOccurrence)*_nbOcc);
      LSTermDesc* ptr = _at;
      for(ORInt i=0;i<_nbOcc;i++) {
         _occ[i]._n = 1;
         _occ[i]._t = ptr++;
         _occ[i]._t[0]._termVar = _src[i];
         _occ[i]._t[0]._ofs     = i;
      }
   }
   _sb = idRange(_src,(ORBounds){FDMAXINT,0});
   ORInt sz =_sb.max - _sb.min + 1;
   _srcOfs = malloc(sizeof(ORInt)*sz);
   for(ORInt i=0;i< sz;++i)
      _srcOfs[i] = -1;
   _srcOfs -= _sb.min;
   ORInt r = 0;
   for(id<LSIntVar> x in _src)
      _srcOfs[getId(x)] = r++;   
   return _src;
}
-(ORBool)isTrue
{
   return _sat.value;
}
-(ORInt)getViolations
{
   return _violations.value;
}
-(ORInt)getVarViolations:(id<LSIntVar>)x
{
   ORInt xid = getId(x);
   if (_sb.min <= xid && xid <= _sb.max)
      return _vv[getId(x)].value;
   else
      return 0;
}
-(id<LSIntVar>)violations
{
   return _violations;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)x
{
   ORInt xid = getId(x);
   if (_sb.min <= xid && xid <= _sb.max)
      return _vv[getId(x)];
   else return nil;
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   ORBool hasX = _sb.min <= xid && xid <= _sb.max && _srcOfs[xid] >= 0;
   if (!hasX)
      return 0;     // that means variable x does not even appear in the constraint.
   const ORInt nbt = _occ[_srcOfs[xid]]._n;
   LSTermDesc* t = _occ[_srcOfs[xid]]._t;
   ORInt oldEval = getLSIntValue(_value);
   ORInt newEval = oldEval;
   for(ORInt k=0;k < nbt;k++) {
      id<LSIntVar> varTermk = t[k]._termVar;
      ORInt        termOfs  = t[k]._ofs;
      //ORInt    newTermValue = [(LSIntVar*)x lookahead:varTermk onAssign:v];
      ORInt    newTermValue = varTermk == x ? v : [varTermk valueWhenVar:x equal:v];
      ORInt    oldTermValue = getLSIntValue(varTermk);//varTermk.value;
      if (newTermValue == oldTermValue) continue;
      newEval += (newTermValue - oldTermValue) * _cBase[termOfs];
   }
   switch(_t) {
      case LSTYEqual: return abs(newEval - _c) - abs(oldEval - _c);
      case LSTYLEqual:
      case LSTYGEqual: {
         ORInt nOut = newEval - _c < 0 ? 0 : newEval - _c;
         ORInt oOut = oldEval - _c < 0 ? 0 : oldEval  - _c;
         return nOut - oOut;
      }
      case LSTYNEqual: return (newEval == _c) - (oldEval == _c);
   }
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt xid = getId(x),yid = getId(y);
   ORInt xv  = getLSIntValue(x),yv = getLSIntValue(y);
   if (xid == yid)
      return 0;
   ORBool hasX = _sb.min <= xid && xid <= _sb.max && _srcOfs[xid] >= 0;
   ORBool hasY = _sb.min <= yid && yid <= _sb.max && _srcOfs[yid] >= 0;
   if (hasX ^ hasY) {
      if (hasX)
         return [self deltaWhenAssign:x to:yv];
      else return [self deltaWhenAssign:y to:xv];
   } else if (!hasX || !hasY)
      return 0;
   else {
      // Both x and y appear in the equation. That's a real swap. Find the
      // terms where x occurs and the terms with y occurs.
      // Reevaluate those affected terms and accumulate delta
      // Since this is a linear equation, we can't have a term mentioning both x and y.
      ORInt nbx = _occ[_srcOfs[xid]]._n,nby = _occ[_srcOfs[yid]]._n;
      LSTermDesc *tx = _occ[_srcOfs[xid]]._t,*ty = _occ[_srcOfs[yid]]._t;
      ORInt oldEval = _value.value;
      ORInt newEval = oldEval;
      ORInt i = 0,j =0;
      while (i < nbx) {
         id<LSIntVar> vari   = tx[i]._termVar;
         ORInt        termi  = tx[i]._ofs;
         i++;
         ORInt    newTermValue = [(LSIntVar*)x lookahead:vari onAssign:yv];
         ORInt    oldTermValue = vari.value;
         if (newTermValue == oldTermValue) continue;
         newEval += (newTermValue - oldTermValue) * [_coefs at:termi];
      }
      while (j < nby) {
         id<LSIntVar> varj   = ty[j]._termVar;
         ORInt        termj  = ty[j]._ofs;
         j++;
         ORInt    newTermValue = [(LSIntVar*)y lookahead:varj onAssign:xv];
         ORInt    oldTermValue = varj.value;
         if (newTermValue == oldTermValue) continue;
         newEval += (newTermValue - oldTermValue) * [_coefs at:termj];
      }
      switch(_t) {
         case LSTYEqual: return abs(newEval - _c) - abs(oldEval - _c);
         case LSTYLEqual:
         case LSTYGEqual: {
            ORInt nOut = newEval - _c < 0 ? 0 : newEval - _c;
            ORInt oOut = oldEval - _c < 0 ? 0 : oldEval  - _c;
            return nOut - oOut;
         }
         case LSTYNEqual: return (newEval == _c) - (oldEval == _c);
      }
   }
}
@end
