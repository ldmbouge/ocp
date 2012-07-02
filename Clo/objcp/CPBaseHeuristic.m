/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBaseHeuristic.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"

@implementation CPBaseHeuristic
-(void)initHeuristic:(NSMutableArray*)array
{
   __block CPUInt nbViews = 0;
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      nbViews += ([obj isKindOfClass:[CPIntShiftView class]] || [obj isKindOfClass:[CPIntView class]]);
   }];
   CPUInt l = [array count] - nbViews;
   __block CPUInt k = 0;
   id<CPIntVar>* t = alloca(sizeof(id<CPIntVar>)*l);
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      if (!([obj isKindOfClass:[CPIntShiftView class]] || [obj isKindOfClass:[CPIntView class]]))
         t[k++] = obj;
   }];
   [self initHeuristic:t length:l];   
}
-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)len
{
   
}
@end
