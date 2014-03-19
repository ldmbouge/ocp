/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
         idb = idRange(ava[i],idb);
         i++;
      }
      _lb = idb.min;
      _ub = idb.max;
      ORInt sz = _ub - _lb + 1;
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
         _cstrOnVars[k]._n = 0;
      }
      for(id<LSIntVar> x in _src) {
         for(ORInt i = 0;i < n;i++)
            if (containsVar(ava[i], getId(x))) {
               LSConstraintList* lx =_cstrOnVars + getId(x);
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
   _vv = [LSFactory intVarArray:_engine range:src.range domain:RANGE(_engine,0,FDMAXINT)];
   for(ORInt k=src.low;k <= src.up;k++) {
      ORInt i=0;
      id<LSIntVarArray> cvk = [LSFactory intVarArray:_engine range:RANGE(_engine,0,_nb-1)];
      for(id<LSConstraint> c in _cstrs)
         cvk[i++] = [c varViolations:src[k]];
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
   ORInt xid = getId(x);
   if (_lb <= xid && xid <= _ub && _srcOfs[xid] >= 0) {
      ORInt ttl = 0;
      for(ORInt k = 0;k < _cstrOnVars[xid]._n;k++) {
         id<LSConstraint> c = _cstrOnVars[xid]._t[k];
         ttl += [c deltaWhenAssign:x to:v];
      }
      return ttl;
   } else
      return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   return 0;
}
@end
