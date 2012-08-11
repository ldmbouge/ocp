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
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPBinPackingI
{
   id<ORIntVarArray>  _item;
   id<ORIntArray>     _itemSize;
   id<ORIntVarArray>  _binSize;
   BOOL               _posted;
}

-(void) initInstanceVariables
{
   _idempotent = YES;
   _priority = HIGHEST_PRIO;
   _posted = false;
}

-(CPBinPackingI*) initCPBinPackingI: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntVarArray>) binSize;
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

-(ORStatus) post
{
//   NSLog(@"BinPacking post called ...");
   if (_posted)
      return ORSkip;
   
   _posted = true;
   id<ORIntRange> BR = [_binSize range];
   id<ORIntRange> IR = [_item range];
   id<CP> cp = [_item tracker];
   
   ORInt brlow = [BR low];
   ORInt brup = [BR up];
   for(CPInt b = brlow; b <= brup; b++)
      [cp add: [SUM(i,IR,mult([_itemSize at: i],[_item[i] eqi: b])) eq: _binSize[b]] consistency:RangeConsistency];
   CPInt s = 0;
   ORInt irlow = [IR low];
   ORInt irup = [IR up];
   for(CPInt i = irlow; i <= irup; i++)
      s += [_itemSize at: i];
   [cp add: [SUM(b,BR,_binSize[b]) eqi: s]];
   for(CPInt b = brlow; b <= brup; b++)
      [cp add: [CPFactory packOne: _item itemSize: _itemSize bin: b binSize: _binSize[b]]];
   return ORSkip;
}

@end

@implementation CPOneBinPackingI
{
   id<ORIntVarArray>  _item;
   id<ORIntArray>     _itemSize;
   CPInt              _bin;
   id<ORIntVar>       _binSize;
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
   BOOL               _changed;
   
}

-(void) initInstanceVariables
{
   _idempotent = YES;
   _priority = HIGHEST_PRIO-2;
   _posted = false;
}

-(CPOneBinPackingI*) initCPOneBinPackingI: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize;
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
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_bin];
   [aCoder encodeObject:_binSize];
}

-(id) initWithCoder:(NSCoder*) aDecoder
{
   self = [super initWithCoder:aDecoder];
   [self initInstanceVariables];
   _item = [aDecoder decodeObject];
   _itemSize = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_bin];
   _binSize = [aDecoder decodeObject];
   return self;
}


-(ORStatus) post
{
//   NSLog(@"BinPacking post called ...");
   if (_posted)
      return ORSkip;
   
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

   return ORSuspend;
}

-(void) propagate
{
   do {
      _changed = false;
      [self prune];
   } while (_changed);
}

static BOOL noSumAlphaBeta(CPOneBinPackingI* cstr,CPInt alpha,CPInt beta,CPInt* alphaPrime,CPInt* betaPrime)
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
   *alphaPrime = sumA + sumC;
   *betaPrime = sumB;
   //   printf("SumA: %d \n",sumA);
   //   printf("SumB: %d \n",sumB);
   //   printf("SumC: %d \n",sumC);
   //   printf("SumA + SumC: %d \n",sumA + sumC);
   return sumA < alpha;
}

static BOOL noSum(CPOneBinPackingI* cstr,CPInt alpha,CPInt beta)
{
   CPInt alphaPrime;
   CPInt betaPrime;
   return noSumAlphaBeta(cstr,alpha,beta,&alphaPrime,&betaPrime);
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
   CPInt alphaPrime;
   CPInt betaPrime;

   if (noSumForCandidates(self,alpha,beta,&alphaPrime,&betaPrime))
      failNow();
   if (noSumForCandidates(self,alpha,alpha,&alphaPrime,&betaPrime))
      [_load updateMin: _p + betaPrime];
   if (noSumForCandidates(self,beta,beta,&alphaPrime,&betaPrime))
      [_load updateMax: _p + alphaPrime];
   
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

static BOOL noSumForCandidates(CPOneBinPackingI* cstr,CPInt alpha,CPInt beta,CPInt* alphaPrime,CPInt* betaPrime)
{
   cstr->_nbX = cstr->_nbCandidates;
   cstr->_maxLoad = 0;
   for(CPInt i = 0; i < cstr->_nbX; i++) {
      cstr->_s[i] = cstr->_candidateSize[i];
      cstr->_maxLoad += cstr->_s[i];
   }
   return noSumAlphaBeta(cstr,alpha,beta,alphaPrime,betaPrime);
}
@end

