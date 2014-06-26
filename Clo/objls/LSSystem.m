/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSSystem.h"
#import <objls/LSIntVar.h>
#import "LSEngineI.h"
#import "LSCount.h"

typedef struct LSConstraintList {
   id<LSConstraint>* _t;
   ORInt*            _nb;
   ORInt             _n;
} LSConstraintList;

@implementation LSSystem {
   id* _vvBase;
   ORInt* _srcOfs;
   LSConstraintList* _cstrOnVars;
}

-(id)init:(id<LSEngine>)engine with:(NSArray*)ca
{
   self = [super init:engine];
   _cstrs = [ca retain];
   _posted = NO;
   _src = NULL;
   return self;
}
-(void)dealloc
{
   _flatSrc += _lb;
   free(_flatSrc);
   _srcOfs += _lb;
   free(_srcOfs);
   [_cstrs release];
   for(ORInt k=_lb;k <= _ub;++k)
      free(_cstrOnVars[k]._t);
   _cstrOnVars += _lb;
   free(_cstrOnVars);
   [super dealloc];
}
-(id<LSIntVarArray>)variables
{
   if (_src == nil) {
      ORInt n = (ORInt)[_cstrs count];
      id<LSIntVarArray> ava[n];
      ORInt i = 0;
      ORBounds idb = (ORBounds){FDMAXINT,0};
      for(id<LSConstraint> c in _cstrs) {
         ava[i] = [c variables];
//         NSLog(@"ava[i] = %@",ava[i]);
         idb = idRange(ava[i],idb);
         i++;
      }
      _lb = idb.min;
      _ub = idb.max;
      ORInt sz = _ub - _lb + 1;
//      NSLog(@"size: %d",sz);
      id<LSIntVar>* iSrc = malloc(sizeof(id)*sz);
      memset(iSrc,0,sizeof(id)*sz);
      iSrc -= _lb;
      _flatSrc = iSrc;
      for(i=0;i < n;i++)
         for(id<LSIntVar> x in ava[i])
            iSrc[getId(x)] = x;
      ORInt anb = 0;
      for(i=_lb;i <= _ub;i++)
         anb += iSrc[i] != nil;
      _src = [LSFactory intVarArray:_engine range:RANGE(_engine,0,anb-1)];
      ORInt k = 0;
      for(i=_lb;i <= _ub;i++)
         if (iSrc[i] != nil)
            _src[k++] = iSrc[i];
      _cstrOnVars = malloc(sizeof(LSConstraintList)*sz);
      memset(_cstrOnVars,0,sizeof(LSConstraintList)*sz);
      _cstrOnVars -= _lb;
      for(ORInt k=_lb;k <= _ub;++k) {
         _cstrOnVars[k]._t = malloc(sizeof(id<LSConstraint>)*n);
         _cstrOnVars[k]._nb = malloc(sizeof(ORInt)*n);
         _cstrOnVars[k]._n = 0;
      }
      for(id<LSIntVar> x in _src) {
         LSConstraintList* lx =_cstrOnVars + getId(x);
         for(ORInt i = 0;i < n;i++)
            if (containsVar(ava[i], getId(x))) {
               lx->_nb[lx->_n] = i;
               lx->_t[lx->_n++] = _cstrs[i];
            }
      }
      _srcOfs = malloc(sizeof(ORInt)*sz);
      for(ORInt i=0;i< sz;++i)
         _srcOfs[i] = - 1;
      _srcOfs -= _lb;
      ORInt r = 0;
      for(id<LSIntVar> x in _src)
         _srcOfs[getId(x)] = r++;
   }
   return _src;
}
-(void)post
{
   if (_posted) return;
   _posted = YES;
   _nb = (ORInt) [_cstrs count];
   _viol = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   _sat  = [LSFactory intVar:_engine domain:RANGE(_engine,0,1)];
   _av = [LSFactory intVarArray:_engine range:RANGE(_engine,0,_nb-1) with:^id<LSIntVar>(ORInt i) {
      return [_cstrs[i] violations];
   }];
   [_engine add:[LSFactory sum: _viol over:_av]];
   [_engine add:[LSFactory inv:_sat equal:^ORInt{ return getLSIntValue(_viol) ==  0;} vars:@[_viol]]];
   
   id<LSIntVarArray> src = [self variables];
//   NSLog(@"source range in system = %@",src.range);
//   NSLog(@"source in system = %@",src);
   _vv = [LSFactory intVarArray:_engine range:src.range domain:RANGE(_engine,0,FDMAXINT)];
   for(ORInt k=src.low;k <= src.up;k++) {
      ORInt i=0;
      ORInt cvkSz = 0;
      for(id<LSConstraint> c in _cstrs) {
         id vv = [c varViolations:src[k]];
         cvkSz +=  (vv != nil);
      }
      id<LSIntVarArray> cvk = [LSFactory intVarArray:_engine range:RANGE(_engine,0,cvkSz-1)];
      
      for(id<LSConstraint> c in _cstrs) {
         id vv = [c varViolations:src[k]];
         if (vv != nil)
            cvk[i++] = vv;
      }
      [_engine add:[LSFactory sum:_vv[k] over:cvk]];
   }
   _vvBase = (id*)[(id)_vv base];
}
-(ORBool)isTrue
{
   return getLSIntValue(_sat);
}
-(ORInt)getViolations
{
   return getLSIntValue(_viol);
}
-(ORInt)getTrueViolations
{
   ORInt v = 0;
   for(id<LSConstraint> c in _cstrs) {
      v += [c getTrueViolations];
   }
   return v;
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
//   ORInt r = findRankByName(_src, getId(var));
   ORInt r = _srcOfs[getId(var)];
   return getLSIntValue(_vvBase[r]);
}
-(id<LSIntVar>)violations
{
   return _viol;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   ORInt r = findRankByName(_src, getId(var));
   return _vvBase[r];
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   if (x.value == v)
      return 0;
   ORInt xid = getId(x);
   if (_lb <= xid && xid <= _ub && _srcOfs[xid] >= 0) {
      ORInt ttl = 0;
      for(ORInt k = 0;k < _cstrOnVars[xid]._n;k++) {
         id<LSConstraint> c = _cstrOnVars[xid]._t[k];
         ttl += [c deltaWhenAssign:x to:v];
      }
      return ttl;
   }
   else
      return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt xv = getLSIntValue(x),yv = getLSIntValue(y);
   if (xv==yv)
      return 0;
   ORInt xid = getId(x),yid = getId(y);
   ORBool hasX = _lb <= xid && xid <= _ub && _srcOfs[xid] >= 0;
   ORBool hasY = _lb <= yid && yid <= _ub && _srcOfs[yid] >= 0;
   if (hasX ^ hasY) {
      if (hasX)
         return [self deltaWhenAssign:x to:yv];
      else return [self deltaWhenAssign:y to:xv];
   } else if (!hasX || !hasY) {
      return 0;
   } else {
      // We have x and y showing up somewhere in the system. Pick the constraints of x and y
      // and scan them, sending deltaWhenXXX messages as appropriate (whether x alone, y alone or both together)
      ORInt ttl = 0;
      ORInt nx = _cstrOnVars[xid]._n,ny = _cstrOnVars[yid]._n;
      id<LSConstraint> *cx = _cstrOnVars[xid]._t,*cy = _cstrOnVars[yid]._t;
      ORInt            *lx = _cstrOnVars[xid]._nb,*ly = _cstrOnVars[yid]._nb;
      ORInt i=0,j=0;
      while (i < nx && j < ny) {
         if (lx[i] == ly[j]) {
            assert(cx[i] == cy[j]);
            ttl += [cx[i] deltaWhenSwap:x with:y];
            ++i;
            ++j;
         } else if (lx[i] < ly[j])
            ttl += [cx[i++] deltaWhenAssign:x to:yv];
         else
            ttl += [cy[j++] deltaWhenAssign:y to:xv];
      }
      while(i < nx)
         ttl += [cx[i++] deltaWhenAssign:x to:yv];
      while(j < ny)
         ttl += [cy[j++] deltaWhenAssign:y to:xv];
      return ttl;
   }
}
@end

@implementation LSLRSystem {
   id* _vvBase;
   ORInt* _srcOfs;
   LSConstraintList* _cstrOnVars;
   ORInt _step;
}

-(id)init:(id<LSEngine>)engine with:(NSArray*)ca
{
   self = [super init:engine];
   _cstrs = [ca retain];
   _posted = NO;
   _src = NULL;
   _step = 1;
   return self;
}
-(void)dealloc
{
   _flatSrc += _lb;
   free(_flatSrc);
   _srcOfs += _lb;
   free(_srcOfs);
   [_cstrs release];
   for(ORInt k=_lb;k <= _ub;++k)
      free(_cstrOnVars[k]._t);
   _cstrOnVars += _lb;
   free(_cstrOnVars);
   [super dealloc];
}
-(id<LSIntVarArray>)variables
{
   if (_src == nil) {
      ORInt n = (ORInt)[_cstrs count];
      id<LSIntVarArray> ava[n];
      ORInt i = 0;
      ORBounds idb = (ORBounds){FDMAXINT,0};
      for(id<LSConstraint> c in _cstrs) {
         ava[i] = [c variables];
//         NSLog(@"ava[i] = %@",ava[i]);
         idb = idRange(ava[i],idb);
         i++;
      }
      _lb = idb.min;
      _ub = idb.max;
      ORInt sz = _ub - _lb + 1;
//      NSLog(@"size: %d",sz);
      id<LSIntVar>* iSrc = malloc(sizeof(id)*sz);
      memset(iSrc,0,sizeof(id)*sz);
      iSrc -= _lb;
      _flatSrc = iSrc;
      for(i=0;i < n;i++)
         for(id<LSIntVar> x in ava[i])
            iSrc[getId(x)] = x;
      ORInt anb = 0;
      for(i=_lb;i <= _ub;i++)
         anb += iSrc[i] != nil;
      _src = [LSFactory intVarArray:_engine range:RANGE(_engine,0,anb-1)];
      ORInt k = 0;
      for(i=_lb;i <= _ub;i++)
         if (iSrc[i] != nil)
            _src[k++] = iSrc[i];
      _cstrOnVars = malloc(sizeof(LSConstraintList)*sz);
      memset(_cstrOnVars,0,sizeof(LSConstraintList)*sz);
      _cstrOnVars -= _lb;
      for(ORInt k=_lb;k <= _ub;++k) {
         _cstrOnVars[k]._t = malloc(sizeof(id<LSConstraint>)*n);
         _cstrOnVars[k]._nb = malloc(sizeof(ORInt)*n);
         _cstrOnVars[k]._n = 0;
      }
      for(id<LSIntVar> x in _src) {
         for(ORInt i = 0;i < n;i++)
            if (containsVar(ava[i], getId(x))) {
               LSConstraintList* lx =_cstrOnVars + getId(x);
               lx->_nb[lx->_n] = i;
               lx->_t[lx->_n++] = _cstrs[i];
            }
      }
      _srcOfs = malloc(sizeof(ORInt)*sz);
      for(ORInt i=0;i< sz;++i)
         _srcOfs[i] = - 1;
      _srcOfs -= _lb;
      ORInt r = 0;
      for(id<LSIntVar> x in _src)
         _srcOfs[getId(x)] = r++;
   }
   return _src;
}
-(void)post
{
   if (_posted) return;
   _posted = YES;
   _nb = (ORInt) [_cstrs count];
   _viol = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   _wviol = [LSFactory intVar:_engine domain:RANGE(_engine,0,FDMAXINT)];
   _sat  = [LSFactory intVar:_engine domain:RANGE(_engine,0,1)];
   _lambda = [LSFactory intVarArray:_engine range:RANGE(_engine,0,_nb-1) domain: RANGE(_engine,0,FDMAXINT)];
   for(ORInt i = 0; i < _nb; i++)
      [_lambda[i] setValue: 1];
   
   // constraint violations; must multiply by the lamdba; probably an intermediary array
   
   _av = [LSFactory intVarArray:_engine range:RANGE(_engine,0,_nb-1) with:^id<LSIntVar>(ORInt i) {
      return [_cstrs[i] violations];
   }];
   _wav = [LSFactory intVarArray:_engine range:RANGE(_engine,0,_nb-1) domain: RANGE(_engine,0,FDMAXINT)];
   for(ORInt i = 0; i < _nb; i++)
      [_engine add: [LSFactory inv: _wav[i] equal: ^{ return [_lambda[i] value] * [_av[i] value];} vars:@[_lambda[i],_av[i]]]];
   
   [_engine add:[LSFactory sum: _viol over:_av]];
   [_engine add:[LSFactory sum: _wviol over:_wav]];
   [_engine add:[LSFactory inv:_sat equal:^ORInt{ return getLSIntValue(_viol) ==  0;} vars:@[_viol]]];
   
   // variable violations; must be multipled as well
   
   id<LSIntVarArray> src = [self variables];
//   NSLog(@"source range in system = %@",src.range);
//   NSLog(@"source in system = %@",src);
   _vv = [LSFactory intVarArray:_engine range:src.range domain:RANGE(_engine,0,FDMAXINT)];
   _wvv = [LSFactory intVarArray:_engine range:src.range domain:RANGE(_engine,0,FDMAXINT)];
   for(ORInt k=src.low;k <= src.up;k++) {
      ORInt i=0;
      ORInt cvkSz = 0;
      for(id<LSConstraint> c in _cstrs) {
         id vv = [c varViolations:src[k]];
         cvkSz +=  (vv != nil);
      }
      id<LSIntVarArray> cvk = [LSFactory intVarArray:_engine range:RANGE(_engine,0,cvkSz-1)];
      
      for(id<LSConstraint> c in _cstrs) {
         id vv = [c varViolations:src[k]];
         if (vv != nil)
            cvk[i++] = vv;
      }
      [_engine add:[LSFactory sum:_vv[k] over:cvk]];
      id<LSIntVarArray> lcvk = [LSFactory intVarArray:_engine range:RANGE(_engine,0,cvkSz-1) domain: RANGE(_engine,0,FDMAXINT)];
      for(ORInt i = 0; i < cvkSz; i++)
         [_engine add: [LSFactory inv: lcvk[i] equal: ^{ return [_lambda[i] value] * [cvk[i] value];} vars:@[_lambda[i],cvk[i]]]];
      [_engine add:[LSFactory sum:_wvv[k] over:lcvk]];
   }
   _vvBase = (id*)[(id)_vv base];
}
-(ORBool)isTrue
{
   return getLSIntValue(_sat);
}
-(ORInt)getViolations
{
   return getLSIntValue(_wviol);
}
-(ORInt)getWeightedViolations
{
   return getLSIntValue(_wviol);
}
-(ORInt)getUnweightedViolations
{
   return getLSIntValue(_viol);
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSLRSystem: %p",self];
   ORInt i = 0;
   for(id<LSConstraint> c in _cstrs) {
      [buf appendFormat:@"\tW=%d \tC=%@\n",_lambda[i].value,c];
      i++;
   }
   [buf appendString:@">"];
   return buf;
}

-(ORInt)getVarUnweightedViolations:(id<LSIntVar>)var
{
   ORInt r = _srcOfs[getId(var)];
   return getLSIntValue(_vvBase[r]);
}
// [pvh] can speed up these by using a base array
-(ORInt)getVarWeightedViolations:(id<LSIntVar>)var
{
   ORInt r = _srcOfs[getId(var)];
   return [_wvv[r] value];
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   ORInt r = _srcOfs[getId(var)];
   return [_wvv[r] value];
}

-(id<LSIntVar>)violations
{
   return _wviol;
}
-(id<LSIntVar>)weightedViolations
{
   return _wviol;
}
-(id<LSIntVar>)unweightedViolations
{
   return _viol;
}

-(id<LSIntVar>)varUnweightedViolations:(id<LSIntVar>)var
{
   ORInt r = findRankByName(_src, getId(var));
   return _vvBase[r];
}
-(id<LSIntVar>)varWeightedViolations:(id<LSIntVar>)var
{
   ORInt r = findRankByName(_src, getId(var));
   return _wvv[r];
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   ORInt r = findRankByName(_src, getId(var));
   return _wvv[r];
}

-(ORInt) unweightedDeltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   if (x.value == v)
      return 0;
   ORInt xid = getId(x);
   if (_lb <= xid && xid <= _ub && _srcOfs[xid] >= 0) {
      ORInt ttl = 0;
      for(ORInt k = 0;k < _cstrOnVars[xid]._n;k++) {
         id<LSConstraint> c = _cstrOnVars[xid]._t[k];
         ttl += [c deltaWhenAssign:x to:v];
      }
      return ttl;
   }
   else
      return 0;
}
-(ORInt) weightedDeltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   if (x.value == v)
      return 0;
   ORInt xid = getId(x);
   if (_lb <= xid && xid <= _ub && _srcOfs[xid] >= 0) {
      ORInt ttl = 0;
      for(ORInt k = 0;k < _cstrOnVars[xid]._n;k++) {
         id<LSConstraint> c = _cstrOnVars[xid]._t[k];
         ORInt idx = _cstrOnVars[xid]._nb[k];
         ttl += [_lambda[idx] value] * [c deltaWhenAssign:x to:v];
      }
      return ttl;
   }
   else
      return 0;
}

-(ORInt) deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   return [self weightedDeltaWhenAssign: x to: v];
}

-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt xv = getLSIntValue(x),yv = getLSIntValue(y);
   if (xv==yv)
      return 0;
   ORInt xid = getId(x),yid = getId(y);
   ORBool hasX = _lb <= xid && xid <= _ub && _srcOfs[xid] >= 0;
   ORBool hasY = _lb <= yid && yid <= _ub && _srcOfs[yid] >= 0;
   if (hasX ^ hasY) {
      if (hasX)
         return [self deltaWhenAssign:x to:yv];
      else return [self deltaWhenAssign:y to:xv];
   } else if (!hasX || !hasY) {
      return 0;
   } else {
      // We have x and y showing up somewhere in the system. Pick the constraints of x and y
      // and scan them, sending deltaWhenXXX messages as appropriate (whether x alone, y alone or both together)
      id<LSIntVar>* lambda = (id<LSIntVar>*)[(id)_lambda base];
      ORInt ttl = 0;
      ORInt nx = _cstrOnVars[xid]._n,ny = _cstrOnVars[yid]._n;
      id<LSConstraint> *cx = _cstrOnVars[xid]._t,*cy = _cstrOnVars[yid]._t;
      ORInt            *lx = _cstrOnVars[xid]._nb,*ly = _cstrOnVars[yid]._nb;
      ORInt i=0,j=0;
      while (i < nx && j < ny) {
         if (lx[i] == ly[j]) {
            assert(cx[i] == cy[j]);
            ttl += getLSIntValue(lambda[lx[i]]) * [cx[i] deltaWhenSwap:x with:y];
            ++i;
            ++j;
         } else if (lx[i] < ly[j]) {
            ttl += getLSIntValue(lambda[lx[i]]) * [cx[i] deltaWhenAssign:x to:yv];
            ++i;
         } else {
            ttl += getLSIntValue(lambda[ly[j]]) * [cy[j] deltaWhenAssign:y to:xv];
            ++j;
         }
      }
      while(i < nx) {
         ttl += getLSIntValue(lambda[lx[i]]) * [cx[i] deltaWhenAssign:x to:yv];
         ++i;
      }
      while(j < ny) {
         ttl += getLSIntValue(lambda[ly[j]]) * [cy[j] deltaWhenAssign:y to:xv];
         ++j;
      }
      return ttl;
   }
}

-(void) updateMultipliers
{
   for(ORInt i = 0; i < _nb; i++)
      [_lambda[i] setValue: [_lambda[i] value] + [_av[i] value]];
   [_engine propagate];
   
   
//   for(ORInt i = 0; i < _nb; i++) {
//      printf("%d ",[_lambda[i] value]);
//   }
//   printf("\n");
   
}

-(void) resetMultipliers
{
   for(ORInt i = 0; i < _nb; i++) {
      [_lambda[i] setValue: 1];
   }
   [_engine propagate];
}

@end

