/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBaseHeuristic.h"
#import <objcp/CPVar.h>

@implementation CPBaseHeuristic
-(void)initHeuristic:(NSMutableArray*)array
{
   __block ORUInt nbViews = 0;
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      nbViews += ([obj varClass] == CPVCShift || [obj varClass] == CPVCAffine);
   }];
   ORULong l = [array count] - nbViews;
   id<ORASolver> cp = [[array objectAtIndex:0] solver];
   id<ORVarArray> direct = (id<ORVarArray>)[ORFactory idArray:cp range:RANGE(cp,0,(ORInt)l-1) ];
   __block ORUInt k = 0;
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      if (!([obj varClass] == CPVCShift || [obj varClass] == CPVCAffine))
         [direct set:obj at:k++];
   }];
   [self initInternal:direct];   
}
-(void)initInternal:(id<ORVarArray>)t
{
   
}
@end
