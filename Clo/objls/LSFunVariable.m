/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSFunVariable.h"
#import "LSEngineI.h"
#import "LSIntVar.h"
#import "LSGlobalInvariants.h"
#import "LSCount.h"

@implementation LSFunVariable {
   id<LSEngine>   _engine;
   id<LSIntVar>      _var;  // could be a real variable or a view
   id<LSIntVarArray> _src;
   ORUInt          _srcId;
}
-(LSFunVariable*)init:(id<LSEngine>)engine with:(id<LSIntVar>)var
{
   self = [super init];
   _engine = engine;
   _var = var;
   return self;
}
-(void)post
{
}
-(id<LSIntVar>)evaluation
{
   return _var;
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   return [_var increase:x];
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   return [_var decrease:x];
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   if (getId(x) == _srcId) {
      return [_var  valueWhenVar:x equal:v] - getLSIntValue(_var);
   } else return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   if (getId(x) == _srcId)
      return getLSIntValue(y) - getLSIntValue(_var);
   else if (getId(y) == _srcId)
      return getLSIntValue(x) - getLSIntValue(_var);
   else
      return 0;
}
-(id<LSIntVarArray>)variables
{
   if (_src==nil) {
      if ([_var isKindOfClass:[LSCoreView class]]) {
         NSArray* av = [(LSCoreView*)_var sourceVars];
         assert([av count] == 1);
         _src = [LSFactory intVarArray:_engine range:RANGE(_engine,0,(ORInt)[av count]-1)];
         for(ORInt i=0;i<[av count];i++)
            _src[i] = av[i];
         _srcId = getId(av[0]);
      } else {
         _src = [LSFactory intVarArray:_engine range:RANGE(_engine,0,0)];
         _src[0] = _var;
         _srcId = getId(_var);
      }
   }
   return _src;
}
@end

@implementation LSFunOr {
   id<LSEngine>     _engine;
   id<LSIntVarArray>   _src;
   id<ORIdArray>     _terms;
   id<LSIntVar>        _dis;
   id<LSIntVar>       _eval;
   id<ORIdArray>    _ig,_dg;
}
-(LSFunOr*)init:(id<LSEngine>)engine withTerms:(id<ORIdArray>)terms
{
   self = [super init];
   _engine = engine;
   _terms = terms;
   return self;
}
-(void)post
{
   _dis = [LSFactory intVar:_engine domain:RANGE(_engine,0,_terms.range.size)];
   id<LSIntVarArray> vk = [LSFactory intVarArray:_engine range:_terms.range with:^id<LSIntVar>(ORInt k) {
      return [_terms[k] evaluation];
   }];
   [_engine add:[LSFactory sum:_dis over:vk]];
   _eval = [LSFactory intVarView:_engine domain:RANGE(_engine,0,1) fun:^ORInt{
      return getLSIntValue(_dis) > 0;
   } src:@[_dis]];
   id<LSIntVarArray> av = sortById([self variables]);
   _ig = [ORFactory idArray:_engine range:[av range]];
   for(ORInt i = av.range.low;i <= av.range.up;i++) {
      id<LSIntVar> x = av[i];
      id<LSGradient> g = [LSGradient cstGradient:0];
      for(id<LSFunction> tk in _terms)
         g = [LSGradient maxOf:g and:[tk increase:x]];
      assert([g isVar]);
      id<LSIntVar>   v = [g variable];
      id<LSIntVar> fgv = [LSFactory intVar:_engine domain:RANGE(_engine,0,1)];
      [_engine add:[LSFactory inv:fgv equal:^ORInt{
         return max(0,getLSIntValue(v) - getLSIntValue(_eval));
      } vars:@[v,_eval]]];
      _ig[i] = [LSGradient varGradient:fgv];
   }
   _dg = [ORFactory idArray:_engine range:[av range]];
   for(ORInt i = av.range.low;i <= av.range.up;i++) {
      id<LSIntVar> x = av[i];
      id<LSGradient> g = [LSGradient cstGradient:0];
      for(id<LSFunction> tk in _terms)
         g = [LSGradient maxOf:g and:[tk decrease:x]];
      assert([g isVar]);
      id<LSIntVar> v = [g variable];
      id<LSIntVar> fgv = [LSFactory intVar:_engine domain:RANGE(_engine,0,1)];
      [_engine add:[LSFactory inv:fgv equal:^ORInt{
         return getLSIntValue(v) * getLSIntValue(_eval);
      } vars:@[v,_eval]]];
      _dg[i] = [LSGradient varGradient:fgv];
   }
}
-(id<LSIntVar>)evaluation
{
   return _eval;
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   ORInt xr = findRankByName(_src, getId(x)); // [ldm] too slow. Have it O(1) with a map.
   return _ig[xr];
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   ORInt xr = findRankByName(_src, getId(x)); // [ldm] too slow. Have it O(1) with a map.
   return _dg[xr];
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt cnt = 0;
   for(id<LSFunction> tk in _terms) {
      ORInt vk = getLSIntValue([tk evaluation]);
      ORInt dk = [tk deltaWhenAssign:x to:v];
      if ((vk + dk) != 0) {
         ++cnt;
         break;
      }
   }
   ORInt cv = getLSIntValue(_eval);
   static ORInt delta[4] = {0,+1,-1,0};
   return delta[cv*2 + cnt];
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt cnt = 0;
   for(id<LSFunction> tk in _terms) {
      ORInt vk = getLSIntValue([tk evaluation]);
      ORInt dk = [tk deltaWhenSwap:x with:y];
      if ((vk + dk) != 0) {
         ++cnt;
         break;
      }
   }
   ORInt cv = getLSIntValue(_eval);
   static ORInt delta[4] = {0,+1,-1,0};
   return delta[cv*2 + cnt];

}
-(id<LSIntVarArray>)variables
{
   if (_src == nil) {
      NSMutableSet* av = [[NSMutableSet alloc] initWithCapacity:32];
      for(id<LSFunction> fk in _terms) {
         id<LSIntVarArray> vk = [fk variables];
         for(id<LSIntVar> vki in vk)
            [av addObject:vki];
      }
      ORInt k = 0;
      id<LSIntVarArray> na = [LSFactory intVarArray:_engine range:RANGE(_engine,0,(ORInt)[av count]-1)];
      for(id<LSIntVar> v in av)
         na[k++] = v;
      _src = na;
   }
   return _src;
}
@end

@implementation LSFunSum {
   id<LSEngine>     _engine;
   id<LSIntVarArray>   _src;
   id<ORIdArray>     _terms;
   id<ORIntArray>    _coefs;
   id<LSIntVar>        _sum;
   id<ORIdArray>    _ig,_dg;
}
-(LSFunSum*)init:(id<LSEngine>)engine withTerms:(id<ORIdArray>)terms coefs:(id<ORIntArray>)coefs;
{
   self = [super init];
   _engine = engine;
   _terms = terms;
   _coefs = coefs;
   return self;
}
-(void)post
{
   id<LSIntVarArray> vk = [LSFactory intVarArray:_engine range:_terms.range with:^id<LSIntVar>(ORInt k) {
      return [_terms[k] evaluation];
   }];
   ORInt lb = 0,ub = 0;
   for(ORInt i=vk.range.low;i <= vk.range.up;i++) {
      ORInt lk = [_terms[i] evaluation].domain.low;
      ORInt uk = [_terms[i] evaluation].domain.up;
      ORInt ck = [_coefs at:i];
      ORInt ubk = max(lk * ck,uk * ck);
      ORInt lbk = min(lk * ck,uk * ck);
      lb += lbk;
      ub += ubk;
   }
   _sum = [LSFactory intVar:_engine domain:RANGE(_engine,lb,ub)];
   [_engine add:[LSFactory sum:_sum is:_coefs times:vk]];
   id<LSIntVarArray> av = sortById([self variables]);
   _ig = [ORFactory idArray:_engine range:[av range]];
   for(ORInt i = av.range.low;i <= av.range.up;i++) {
      id<LSIntVar> x = av[i];
      id<LSGradient> g = [LSGradient cstGradient:0];
      ORInt k = _terms.range.low;
      for(id<LSFunction> tk in _terms) {
         id<LSGradient> gk = [tk increase:x];
         g = [LSGradient sumOf:g and:[gk scaleBy:[_coefs at:k]]];
         k++;
      }
      id<LSIntVar> gv  = [g intVar:_engine];
      _ig[i] = [LSGradient varGradient:gv];
   }
   _dg = [ORFactory idArray:_engine range:[av range]];
   for(ORInt i = av.range.low;i <= av.range.up;i++) {
      id<LSIntVar> x = av[i];
      id<LSGradient> g = [LSGradient cstGradient:0];
      ORInt k = _terms.range.low;
      for(id<LSFunction> tk in _terms) {
         id<LSGradient> gk = [tk decrease:x];
         g = [LSGradient sumOf:g and:[gk scaleBy:[_coefs at:k]]];
         k++;
      }
      id<LSIntVar>  gv = [g intVar:_engine];
      _dg[i] = [LSGradient varGradient:gv];
   }
}
-(id<LSIntVar>)evaluation
{
   return _sum;
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   ORInt xr = findRankByName(_src, getId(x)); // [ldm] too slow. Have it O(1) with a map.
   return _ig[xr];
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   ORInt xr = findRankByName(_src, getId(x)); // [ldm] too slow. Have it O(1) with a map.
   return _dg[xr];
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt ttl = 0;
   ORInt k = _terms.range.low;
   for(id<LSFunction> tk in _terms) {
      ORInt dk = [tk deltaWhenAssign:x to:v] * [_coefs at:k];
      ttl += dk;
      k++;
   }
   return ttl;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt ttl = 0;
   ORInt k = _terms.range.low;
   for(id<LSFunction> tk in _terms) {
      ORInt dk = [tk deltaWhenSwap:x with:y] * [_coefs at:k];
      ttl += dk;
      k++;
   }
   return ttl;
}
-(id<LSIntVarArray>)variables
{
   if (_src == nil) {
      NSMutableSet* av = [[NSMutableSet alloc] initWithCapacity:32];
      for(id<LSFunction> fk in _terms) {
         id<LSIntVarArray> vk = [fk variables];
         for(id<LSIntVar> vki in vk)
            [av addObject:vki];
      }
      ORInt k = 0;
      id<LSIntVarArray> na = [LSFactory intVarArray:_engine range:RANGE(_engine,0,(ORInt)[av count]-1)];
      for(id<LSIntVar> v in av)
         na[k++] = v;
      _src = na;
   }
   return _src;
}
@end