/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFoundation/ORExpr.h"
#import "CPBinPacking.h"
#import "CPBasicConstraint.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPBinPackingI
{
   id<CPIntVarArray>  _item;
   id<CPIntArray>     _itemSize;
   id<CPIntVarArray>  _binSize;
   BOOL               _posted;
}

-(void) initInstanceVariables
{
   _idempotent = YES;
   _priority = HIGHEST_PRIO;
   _posted = false;
}

-(CPBinPackingI*) initCPBinPackingI: (id<CPIntVarArray>) item itemSize: (id<CPIntArray>) itemSize binSize: (id<CPIntVarArray>) binSize;
{
   self = [super initCPActiveConstraint: [[item cp] solver]];
   _item = item;
   _itemSize = itemSize;
   _binSize = binSize;
   [self initInstanceVariables];
   return self;
}
-(void) dealloc
{
   NSLog(@"BinPacking dealloc called ...");
   if (_posted) {
   }
   [super dealloc];
}

-(void) encodeWithCoder:(NSCoder*) aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_item];
   [aCoder encodeObject:_itemSize];
   [aCoder encodeObject:_binSize];
}

-(id) initWithCoder:(NSCoder*) aDecoder
{
   self = [super initWithCoder:aDecoder];
   [self initInstanceVariables];
   _item = [aDecoder decodeObject];
   _itemSize = [aDecoder decodeObject];
   _binSize = [aDecoder decodeObject];
   return self;
}

-(CPStatus) post
{
//   NSLog(@"BinPacking post called ...");
   if (_posted)
      return CPSkip;
   
   _posted = true;
   CPRange BR = [_binSize range];
   CPRange IR = [_item range];
   id<CP> cp = [_item cp];
   
   for(CPInt b = BR.low; b <= BR.up; b++)
      [cp add: [SUM(i,IR,mult([_itemSize at: i],[_item[i] eqi: b])) eq: _binSize[b]]];
   CPInt s = 0;
   for(CPInt i = IR.low; i <= IR.up; i++)
      s += [_itemSize at: i];
   [cp add: [SUM(b,BR,_binSize[b]) eqi: s]];
   for(CPInt b = BR.low; b <= BR.up; b++)
     [cp add: [CPFactory packOne: _item itemSize: _itemSize bin: b binSize: _binSize[b]]];
   return CPSkip;
}

@end

@implementation CPOneBinPackingI
{
   id<CPIntVarArray>  _item;
   id<CPIntArray>     _itemSize;
   CPInt              _bin;
   id<CPIntVar>       _binSize;
   BOOL               _posted;
   
   CPInt              _low;
   CPInt              _up;
   
   CPIntVarI**        _var;
   CPInt              _nbVar;
   CPInt*             _size;
   CPIntVarI*         _load;
   
   int                _nbCandidates;
   CPIntVarI**        _candidate;
   CPInt*             _candidateSize;
   
   int                _nbX;
   CPInt*             _s;

   CPInt              _maxLoad;
   CPInt              _p;
   CPInt              _alphaprime;
   CPInt              _betaprime;
   BOOL               _changed;
   
}

-(void) initInstanceVariables
{
   _idempotent = YES;
   _priority = HIGHEST_PRIO-2;
   _posted = false;
}

-(CPOneBinPackingI*) initCPOneBinPackingI: (id<CPIntVarArray>) item itemSize: (id<CPIntArray>) itemSize bin: (CPInt) b binSize: (id<CPIntVar>) binSize;
{
   self = [super initCPActiveConstraint: [[item cp] solver]];
   _item = item;
   _itemSize = itemSize;
   _bin = b;
   _binSize = binSize;
   [self initInstanceVariables];
   return self;
}
-(void) dealloc
{
//   NSLog(@"BinPacking dealloc called ...");
   if (_posted) {
      free(_var);
      free(_size);
      free(_s);
      free(_candidate);
      free(_candidateSize);
   }
   [super dealloc];
}

-(void) encodeWithCoder:(NSCoder*) aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_item];
   [aCoder encodeObject:_itemSize];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_bin];
   [aCoder encodeObject:_binSize];
}

-(id) initWithCoder:(NSCoder*) aDecoder
{
   self = [super initWithCoder:aDecoder];
   [self initInstanceVariables];
   _item = [aDecoder decodeObject];
   _itemSize = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_bin];
   _binSize = [aDecoder decodeObject];
   return self;
}


-(CPStatus) post
{
//   NSLog(@"BinPacking post called ...");
   if (_posted)
      return CPSkip;
   
   _posted = true;
   _low = [_item range].low;
   _up = [_item range].up;
   _nbVar = _up - _low + 1;
   _var = (CPIntVarI**) malloc(sizeof(CPIntVarI*) * _nbVar);
   _size = (CPInt*) malloc(sizeof(CPInt*) * _nbVar);
   _s = (CPInt*) malloc(sizeof(CPInt*) * _nbVar);
   _candidate = (CPIntVarI**) malloc(sizeof(CPIntVarI*) * _nbVar);
   _candidateSize = (CPInt*) malloc(sizeof(CPInt*) * _nbVar);
   for(CPInt i = _low; i <= _up; i++) {
      _var[i-_low] = (CPIntVarI*) _item[i];
      _size[i-_low] = [_itemSize at: i];
   }
   _load = (CPIntVarI*) _binSize;
   [self propagate];
   
   for(CPInt i = 0; i < _nbVar; i++)
      if (![_var[i] bound])
         [_var[i] whenChangePropagate: self];
   [_load whenChangeBoundsPropagate: self];

   return CPSuspend;
}

-(void) propagate
{
   do {
      _changed = false;
      [self prune];
   } while (_changed);
}

static BOOL noSum(CPOneBinPackingI* cstr,CPInt alpha,CPInt beta)
{
   if (alpha <= 0 || beta >= cstr->_maxLoad)
      return false;
   CPInt sumA = 0;
   CPInt sumB = 0;
   CPInt sumC = 0;
   CPInt k = -1;
   CPInt kp = cstr->_nbX - 1;
   while (sumC + cstr->_s[kp] < alpha) {
      sumC += cstr->_s[kp];
      kp--;
   }
   sumB = cstr->_s[kp];
   while (sumA < alpha && sumB <= beta) {
      k++;
      sumA += cstr->_s[k];
      if (sumA < alpha) {
         kp++;
         sumB += cstr->_s[kp];
         sumC -= cstr->_s[kp];
         while (sumA + sumC >= alpha) {
            kp++;
            sumC -= cstr->_s[kp];
            sumB += cstr->_s[kp];
            sumB -= cstr->_s[kp - k - 1];
         }
      }
   }
   cstr->_alphaprime = sumA + sumC;
   cstr->_betaprime = sumB;
   //   printf("SumA: %d \n",sumA);
   //   printf("SumB: %d \n",sumB);
   //   printf("SumC: %d \n",sumC);
   //   printf("SumA + SumC: %d \n",sumA + sumC);
   return sumA < alpha;
}

static void noSumForCandidatesWithout(CPOneBinPackingI* cstr,CPInt alpha,CPInt beta,CPInt item)
{
   cstr->_nbX = 0;
   for(CPInt i = 0; i < cstr->_nbCandidates; i++)
      if (i != item) {
         cstr->_s[cstr->_nbX++] = cstr->_candidateSize[i];
         cstr->_maxLoad += cstr->_s[i];
      }
   if (noSum(cstr,alpha,beta)) {
      cstr->_changed = true;
      [cstr->_candidate[item] bind: cstr->_bin];
   }
}

static void noSumForCandidatesWith(CPOneBinPackingI* cstr,CPInt alpha,CPInt beta,CPInt item)
{
   cstr->_nbX = 0;
   for(CPInt i = 0; i < cstr->_nbCandidates; i++)
      if (i != item) {
         cstr->_s[cstr->_nbX++] = cstr->_candidateSize[i];
         cstr->_maxLoad += cstr->_s[i];
      }

   if (noSum(cstr,alpha - cstr->_candidateSize[item],beta - cstr->_candidateSize[item])) {
      cstr->_changed = true;
      [cstr->_candidate[item] remove: cstr->_bin];
   }
}


-(void) prune
{
   _nbCandidates = 0;
   _p = 0;
   _maxLoad = 0;
   for(CPInt i = 0; i < _nbVar; i++) 
      if (memberDom(_var[i],_bin)) {
         if (bound(_var[i]))
            _p += _size[i];
         else {
            _candidate[_nbCandidates] = _var[i];
            _candidateSize[_nbCandidates] = _size[i];
            _maxLoad += _size[i];
            _nbCandidates++;
         }
      }
   [_load updateMin: _p];
   [_load updateMax: _maxLoad + _p];
   CPInt alpha = minDom(_load) - _p;
   CPInt beta = maxDom(_load) - _p;
   if (noSumForCandidates(self,alpha,beta))
      failNow();
   
   if (noSumForCandidates(self,alpha,alpha))
      [_load updateMin: _p + _betaprime];
   if (noSumForCandidates(self,beta,beta))
      [_load updateMax: _p + _alphaprime];
   
   alpha = minDom(_load) - _p;
   beta = maxDom(_load) - _p;
   CPInt lastSize = MAXINT;
   for(CPInt i = 0; i < _nbCandidates && !_changed; i++) {
      if (_candidateSize[i] != lastSize)
         noSumForCandidatesWithout(self,alpha,beta,i);
      lastSize = _candidateSize[i];
   }
   lastSize = MAXINT;
   for(CPInt i = 0; i < _nbCandidates && !_changed; i++) {
      if (_candidateSize[i] != lastSize)
         noSumForCandidatesWith(self,alpha,beta,i);
      lastSize = _candidateSize[i];
   }

}

static BOOL noSumForCandidates(CPOneBinPackingI* cstr,CPInt alpha,CPInt beta)
{
   cstr->_nbX = cstr->_nbCandidates;
   cstr->_maxLoad = 0;
   for(CPInt i = 0; i < cstr->_nbX; i++) {
      cstr->_s[i] = cstr->_candidateSize[i];
      cstr->_maxLoad += cstr->_s[i];
   }
   return noSum(cstr,alpha,beta);
   
}
-(BOOL) noSumForCandidates: (CPInt) alpha beta: (CPInt) beta
{
   _nbX = _nbCandidates;
   _maxLoad = 0;
   for(CPInt i = 0; i < _nbX; i++) {
      _s[i] = _candidateSize[i];
      _maxLoad += _s[i];
   }
   return noSum(self,alpha,beta);
}

-(void) noSumForCandidates: (CPInt) alpha beta: (CPInt) beta without: (CPInt) item
{
   _nbX = 0;
   for(CPInt i = 0; i < _nbCandidates; i++)
      if (i != item) {
         _s[_nbX++] = _candidateSize[i];
         _maxLoad += _s[i];
      }
   if (noSum(self,alpha,beta)) {
      _changed = true;
      [_candidate[item] bind: _bin];
   }
}

-(void) noSumForCandidates: (CPInt) alpha beta: (CPInt) beta with: (CPInt) item
{
   _nbX = 0;
   for(CPInt i = 0; i < _nbCandidates; i++)
      if (i != item) {
         _s[_nbX++] = _candidateSize[i];
         _maxLoad += _s[i];
      }
   assert(_nbX == _nbCandidates - 1);
   if (noSum(self,alpha - _candidateSize[item],beta - _candidateSize[item])) {
      _changed = true;
      [_candidate[item] remove: _bin];
   }
}


-(BOOL) noSum: (CPInt) alpha beta: (CPInt) beta
{
   if (alpha <= 0 || beta >= _maxLoad)
      return false;
   CPInt sumA = 0;
   CPInt sumB = 0;
   CPInt sumC = 0;
   CPInt k = -1;
   CPInt kp = _nbX - 1;
   while (sumC + _s[kp] < alpha) {
      sumC += _s[kp];
      kp--;
   }
   sumB = _s[kp];
   while (sumA < alpha && sumB <= beta) {
      k++;
      sumA += _s[k];
      if (sumA < alpha) {
         kp++;
         sumB += _s[kp];
         sumC -= _s[kp];
         while (sumA + sumC >= alpha) {
            kp++;
            sumC -= _s[kp];
            sumB += _s[kp];
            sumB -= _s[kp - k - 1];
         }
      }
   }
   _alphaprime = sumA + sumC;
   _betaprime = sumB;
//   printf("SumA: %d \n",sumA);
//   printf("SumB: %d \n",sumB);
//   printf("SumC: %d \n",sumC);
//   printf("SumA + SumC: %d \n",sumA + sumC);
   return sumA < alpha;
}
@end

