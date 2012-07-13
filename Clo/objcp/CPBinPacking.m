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
   NSLog(@"BinPacking post called ...");
   if (_posted)
      return CPSkip;
   
   _posted = true;
   CPRange BR = [_binSize range];
   CPRange IR = [_item range];
   id<CP> cp = [_item cp];
   for(CPInt b = BR.low; b <= BR.up; b++)
      [cp add: [SUM(i,IR,mult([_itemSize at: i],[_item[i] eqi: b])) leq: _binSize[b]]];
   CPInt s = 0;
   for(CPInt i = IR.low; i <= IR.up; i++)
      s += [_itemSize at: i];
   [cp add: [SUM(b,BR,_binSize[b]) eqi: s]];

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

   CPInt              _p;
   CPInt              _alphaprime;
   CPInt              _betaprime;
   
}

-(void) initInstanceVariables
{
   _idempotent = YES;
   _priority = HIGHEST_PRIO-1;
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
   NSLog(@"BinPacking dealloc called ...");
   if (_posted) {
      free(_var);
      free(_size);
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
   NSLog(@"BinPacking post called ...");
   if (_posted)
      return CPSkip;
   
   _posted = true;
   _low = [_item range].low;
   _up = [_item range].up;
   _nbVar = _up - _low + 1;
   _var = (CPIntVarI**) malloc(sizeof(CPIntVarI*) * _nbVar);
   _size = (CPInt*) malloc(sizeof(CPInt*) * _nbVar);
   _candidate = (CPIntVarI**) malloc(sizeof(CPIntVarI*) * _nbVar);
   _candidateSize = (CPInt*) malloc(sizeof(CPInt*) * _nbVar);
   for(CPInt i = _low; i <= _up; i++) {
      _var[i-_low] = (CPIntVarI*) _item[i];
      _size[i-_low] = [_itemSize at: i];
   }
   _load = (CPIntVarI*) _binSize;
   
   [self prune];
   return CPSuspend;
}

-(void) prune
{
   CPInt nbCandidates = 0;
   for(CPInt i = 0; i < _nbVar; i++) {
      
   }
}
-(BOOL) noSum: (CPInt) alpha beta: (CPInt) beta 
{
   return false;
}
@end

