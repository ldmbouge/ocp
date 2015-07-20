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

@implementation LSFunConstant {
   id<LSEngine>   _engine;
   ORInt               _c;
   id<LSIntVarArray> _src;
   id<LSIntVar>     _fake;
}
-(id)init:(id<LSEngine>)engine with:(ORInt)c
{
   self = [super init];
   _engine = engine;
   _c = c;
   return self;
}
-(void)post
{
   _fake = [LSFactory intVar:_engine domain:RANGE(_engine,_c,_c)];
}
-(id<LSIntVar>)evaluation
{
   return _fake;
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   return [LSGradient cstGradient:0];
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   return [LSGradient cstGradient:0];
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   return 0;
}
-(id<LSIntVarArray>)variables
{
   if (_src==nil)
      _src = [LSFactory intVarArray:_engine range:RANGE(_engine,0,-1)];
   return _src;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSFunCst %p : %d>",self,_c];
   return buf;
}
@end

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
      return [_var valueWhenVar:x equal:getLSIntValue(y)] - getLSIntValue(_var);
   else if (getId(y) == _srcId)
      return [_var valueWhenVar:y equal:getLSIntValue(x)] - getLSIntValue(_var);
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
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSFunVar %p : %@>",self,_var];
   return buf;
}
@end

@implementation LSFunOr {
   id<LSEngine>     _engine;
   id<LSIntVarArray>   _src;
   id<ORIdArray>     _terms;
   id<LSIntVar>        _dis;
   id<LSIntVar>       _eval;
   id<ORIdArray>    _ig,_dg;
   ORBounds             _sb;
   ORInt*              _map;
   id<LSGradient>     _zero;
   ORInt**            _tmap;
   ORInt*             _tmsz;
}
-(LSFunOr*)init:(id<LSEngine>)engine withTerms:(id<ORIdArray>)terms
{
   self = [super init];
   _engine = engine;
   _terms = terms;
   return self;
}
-(void)dealloc
{
   [_zero release];
   _map += _sb.min;
   free(_map);
   [super dealloc];
}
-(void)post
{
   @autoreleasepool {
      _zero = [[LSGradient cstGradient:0] retain];
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
         _ig[i] = [[LSGradient varGradient:fgv] retain];
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
         _dg[i] = [[LSGradient varGradient:fgv] retain];
      }
   }
}
-(id<LSIntVar>)evaluation
{
   return _eval;
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   ORInt xid = getId(x);
   if (xid < _sb.min || xid > _sb.max || _map[xid] == -1)
      return _zero;
   else
      return _ig[_map[xid]];
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   ORInt xid = getId(x);
   if (xid < _sb.min || xid > _sb.max || _map[xid] == -1)
      return _zero;
   else
      return _dg[_map[xid]];
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   ORInt xid = getId(x);
   ORBool nox = xid < _sb.min || xid > _sb.max || _map[xid] == -1;
   if (nox) return 0;
   ORInt td = 0;
   ORInt* tx = _tmap[xid],nx = _tmsz[xid];
   for(ORInt i=0;i<nx;i++)
      td += [_terms[tx[i]] deltaWhenAssign:x to:v];
   ORInt status = (getLSIntValue(_dis) + td) > 0;
   ORInt cv = getLSIntValue(_eval);
   return status - cv;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt xid = getId(x),yid = getId(y);
   ORBool nox = xid < _sb.min || xid > _sb.max || _map[xid] == -1;
   ORBool noy = yid < _sb.min || yid > _sb.max || _map[yid] == -1;
   if (nox && noy)
      return 0;
   else if (nox)
      return [self deltaWhenAssign:y to:getLSIntValue(x)];
   else if (noy)
      return [self deltaWhenAssign:x to:getLSIntValue(y)];
   ORInt cnt = 0;
   for(id<LSFunction> tk in _terms) {
      ORInt vk = getLSIntValue([tk evaluation]);
      ORInt dk = [tk deltaWhenSwap:x with:y];
      if ((vk + dk) != 0) {
         cnt = 1;
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
      _sb = idRange(_src,(ORBounds){FDMAXINT,0});
      _map = malloc(sizeof(ORInt)*(_sb.max - _sb.min + 1));
      ORInt sz = _sb.max - _sb.min + 1;
      for(k = 0; k < sz;k++)
         _map[k] = -1;
      _map -= _sb.min;
      ORInt ofs = 0;
      for(k = _src.range.low;k <= _src.range.up;k++)
         _map[getId(_src[k])] = ofs++;
      [av release];
      
      NSMutableDictionary* termsOfVar = [[NSMutableDictionary alloc] initWithCapacity:[_src count]];
      for(ORInt i = _src.range.low;i <= _src.range.up;i++)
         termsOfVar[@(getId(_src[i]))] = [[NSMutableArray alloc] initWithCapacity:8];
      ORInt tk = 0;
      for(id<LSFunction> fk in _terms) {
         for(id<LSIntVar> vki in [fk variables])
            [termsOfVar[@(getId(vki))] addObject:@(tk)];
         tk += 1;
      }

      _tmap = calloc(sz,sizeof(ORInt*));   // array indexed by varId. Each entry is array of terms IDS mentionning the var.
      _tmsz = calloc(sz,sizeof(ORInt));    // how many in each entry of _map.
      _tmap -= _sb.min;
      _tmsz -= _sb.min;
      for(NSNumber* key in termsOfVar) {
         NSArray* terms = termsOfVar[key];
         _tmsz[key.intValue] = (ORInt) [terms count];
         ORInt* tab = _tmap[key.intValue] = malloc(sizeof(ORInt)*[terms count]);
         ORInt j = 0;
         for(NSNumber* t in terms)
            tab[j++] = t.intValue;
      }
      [termsOfVar release];
   }
   return _src;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSFunOr %p : %@>",self,_terms];
   return buf;
}
@end

@implementation LSFunSum {
   id<LSEngine>     _engine;
   id<LSIntVarArray>   _src;
   id<ORIdArray>     _terms;
   id<ORIntArray>    _coefs;
   id<LSIntVar>        _sum;
   id<ORIdArray>    _ig,_dg;
   ORBounds             _sb;
   ORInt**             _map;
   ORInt*              _msz;
}
-(LSFunSum*)init:(id<LSEngine>)engine withTerms:(id<ORIdArray>)terms coefs:(id<ORIntArray>)coefs;
{
   self = [super init];
   _engine = engine;
   _terms = terms;
   _coefs = coefs;
   return self;
}
-(void)dealloc
{
   _map += _sb.min;
   _msz += _sb.min;
   free(_msz);
   for(ORInt i = 0; i < _sb.max - _sb.min + 1;i++)
      free(_map[i]);
   free(_map);
   [super dealloc];
}
-(void)post
{
   @autoreleasepool {
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
      id<LSIntVarArray> av = [self variables];
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
         _ig[i] = [[LSGradient varGradient:gv] retain];
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
         _dg[i] = [[LSGradient varGradient:gv] retain];
      }
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
   ORInt xid = getId(x),yid = getId(y);
   ORInt xval = getLSIntValue(x),yval = getLSIntValue(y);
   ORBool nox = xid < _sb.min || xid > _sb.max || _map[xid] == NULL;
   ORBool noy = yid < _sb.min || yid > _sb.max || _map[yid] == NULL;
   if (nox && noy) return 0;
   else if (nox)
      return [self deltaWhenAssign:y to:xval];
   else if (noy)
      return [self deltaWhenAssign:x to:yval];
   //Both are present in the sum.
   ORInt* coefs = (ORInt*)[(id)_coefs base];
   ORInt *tx = _map[xid], *ty = _map[yid];
   ORInt nx = _msz[xid],ny = _msz[yid];
   ORInt i=0,j=0;
   while (i < nx && j < ny) {
      if (tx[i] < ty[j]) {
         id<LSFunction> term = _terms[tx[i]];
         ttl += [term deltaWhenAssign:x to:yval] * coefs[tx[i]];
         i++;
      } else if (ty[j] < tx[i]) {
         id<LSFunction> term = _terms[ty[j]];
         ttl += [term deltaWhenAssign:y to:xval] * coefs[ty[j]];
         j++;
      } else {
         id<LSFunction> term = _terms[tx[i]];
         ttl += [term deltaWhenSwap:x with:y] * coefs[tx[i]];
         i++;
         j++;
      }
   }
   while (i < nx) {
      ttl += [_terms[tx[i]] deltaWhenAssign:x to:yval]  * coefs[tx[i]];
      ++i;
   }
   while (j < ny) {
      ttl += [_terms[ty[j]] deltaWhenAssign:y to:xval] * coefs[ty[j]];
      ++j;
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
      NSMutableDictionary* termsOfVar = [[NSMutableDictionary alloc] initWithCapacity:[_src count]];
      for(ORInt i = _src.range.low;i <= _src.range.up;i++)
         termsOfVar[@(getId(_src[i]))] = [[NSMutableArray alloc] initWithCapacity:8];
      ORInt tk = 0;
      for(id<LSFunction> fk in _terms) {
         for(id<LSIntVar> vki in [fk variables])
            [termsOfVar[@(getId(vki))] addObject:@(tk)];
         tk += 1;
      }
      _sb = idRange(_src, (ORBounds){FDMAXINT,0});
      ORInt sz = _sb.max - _sb.min + 1;
      _map = calloc(sz,sizeof(ORInt*));   // array indexed by varId. Each entry is array of terms IDS mentionning the var.
      _msz = calloc(sz,sizeof(ORInt));    // how many in each entry of _map.
      _map -= _sb.min;
      _msz -= _sb.min;
      for(NSNumber* key in termsOfVar) {
         NSArray* terms = termsOfVar[key];
         _msz[key.intValue] = (ORInt) [terms count];
         ORInt* tab = _map[key.intValue] = malloc(sizeof(ORInt)*[terms count]);
         ORInt j = 0;
         for(NSNumber* t in terms)
            tab[j++] = t.intValue;
      }
      [av release];
      [termsOfVar release];
   }
   return _src;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSFunSum %p : %@ coefs:%@>",self,_terms,_coefs];
   return buf;
}
@end
