/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBaseHeuristic.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"

@implementation CPBaseHeuristic
-(void)initHeuristic:(NSMutableArray*)array
{
   __block CPUInt nbViews = 0;
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      nbViews += ([obj isKindOfClass:[CPIntShiftView class]] || [obj isKindOfClass:[CPIntView class]]);
   }];
   CPULong l = [array count] - nbViews;
   id<CPSolver> cp = [[array objectAtIndex:0] cp];
   id<CPVarArray> direct = [CPFactory varArray:cp range: RANGE(cp,0,(ORInt)l-1)];
   __block CPUInt k = 0;
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      if (!([obj isKindOfClass:[CPIntShiftView class]] || [obj isKindOfClass:[CPIntView class]]))
         [direct set:obj at:k++];
   }];
   [self initInternal:direct];   
}
-(void)initInternal:(id<CPVarArray>)t 
{
   
}
@end
