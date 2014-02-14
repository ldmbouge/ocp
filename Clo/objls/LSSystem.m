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

@implementation LSSystem

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
   [_cstrs release];
   [super dealloc];
}
-(id<LSIntVarArray>)variables
{
   if (_src == nil) {
      ORInt n = (ORInt)[_cstrs count];
      id<LSIntVarArray> ava[n];
      ORInt i = 0;
      _lb = FDMAXINT;
      _ub = 0;
      for(id<LSConstraint> c in _cstrs) {
         ava[i] = [c variables];
         for(id<LSIntVar> x in ava[i]) {
            _lb = getId(x) < _lb ? getId(x) : _lb;
            _ub = getId(x) > _ub ? getId(x) : _ub;
         }
         i++;
      }
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
   [_engine add:[LSFactory inv:_sat equal:^ORInt{ return _viol.value ==  0;} vars:@[_viol]]];
   
   id<LSIntVarArray> as = [self variables];
   _vv = [LSFactory intVarArray:_engine range:as.range domain:RANGE(_engine,0,FDMAXINT)];
   for(ORInt k=as.low;k <= as.up;k++) {
      ORInt i=0;
      id<LSIntVarArray> cvk = [LSFactory intVarArray:_engine range:RANGE(_engine,0,_nb-1)];
      for(id<LSConstraint> c in _cstrs)
         cvk[i++] = [c varViolations:as[k]];
      [_engine add:[LSFactory sum:_vv[k] over:cvk]];
   }
   _vvIdMapped = isIdMapped(_vv);
}
-(ORBool)isTrue
{
   return _sat.value;
}
-(ORInt)getViolations
{
   return _viol.value;
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   if (_vvIdMapped)
      return _vv[getId(var)].value;
   else
      return findByName(_vv, getId(var)).value;
}
-(id<LSIntVar>)violations
{
   return _viol;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   if (_vvIdMapped)
      return _vv[getId(var)];
   else
      return findByName(_vv, getId(var));
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
