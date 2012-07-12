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
   id<CPIntVarArray>  _x;
   id<CPIntArray>     _itemSize;
   id<CPIntArray>     _binSize;
   BOOL               _posted;
}

-(void) initInstanceVariables
{
   _idempotent = YES;
   _priority = HIGHEST_PRIO-1;
   _posted = false;
}

-(CPBinPackingI*) initCPBinPackingI: (id<CPIntVarArray>) x itemSize: (id<CPIntArray>) itemSize binSize: (id<CPIntArray>) binSize;
{
   self = [super initCPActiveConstraint: [[x cp] solver]];
   _x = x;
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
   [aCoder encodeObject:_x];

}

-(id) initWithCoder:(NSCoder*) aDecoder
{
   self = [super initWithCoder:aDecoder];
   [self initInstanceVariables];
   _x = [aDecoder decodeObject];
   return self;
}


-(CPStatus) post
{
   NSLog(@"BinPacking post called ...");
   if (_posted)
      return CPSuspend;
   _posted = true;
   return CPSuspend;
}

@end
