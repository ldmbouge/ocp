/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


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
   _priority = HIGHEST_PRIO-1;
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
   if (!_posted) {
      _posted = true;
      CPRange BR = [_binSize range];
      CPRange IR = [_item range];
      id<CP> cp = [_item cp];
      for(CPInt i = BR.low; i <= BR.up; i++) {
         printf("binSize[%d] = %d \n",i,[_binSize[i] max]);
         for(CPInt j = IR.low; j <= IR.up; j++)
            printf("%d ",[_itemSize at: j]);
         printf("\n");
         NSLog(@"%@",_item);
         [cp add: SUM(j,IR,[[_item[j] eqi: i] muli: [_itemSize at: j]]) leq: _binSize[i]];
      }
   }
   return CPSkip;
}

@end
