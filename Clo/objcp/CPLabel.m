/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPData.h"
#import "CPLabel.h"
#import "CPSelector.h"
#import "CPEngineI.h"
#import "ORExplorer.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"

@implementation CPLabel

+(void) var: (id<ORIntVar>) mx
{
   id<CPSolver> cp = (id<CPSolver>) [mx solver];
   CPIntVarI* x = (CPIntVarI*) [mx dereference];
   while (!bound(x)) {
      ORInt m = minDom(x);
      [cp try: ^() {
         [cp label:x with:m];
      }
           or: ^() {
              [cp diff:x with:m];
           }];
   }
}

+(void) array: (id<ORIntVarArray>) x
{
    ORInt low = [x low];
    ORInt up = [x up];
    for(ORInt i = low; i <= up; i++) 
        [CPLabel var: x[i]];
}

+(void) array: (id<ORIntVarArray>) x orderedBy: (ORInt2Int) orderedBy
{
    CPSolverI* cp = (CPSolverI*) [x solver];
    CPSelect* select = [cp selectInRange: RANGE(cp,[x low],[x up])
                              suchThat: ^bool(ORInt i) { return [[x at: i] bound]; }
                               orderedBy: orderedBy];
    do {
        ORInt i = [select min];
        if (i == MAXINT) {
            return;
        }
 //      printf("(%d)",[[x at: i] getId]);
        [CPLabel var: [x at: i]];
    } while (true);    
}


+(void) heuristic:(id<CPHeuristic>)h
{
   id<ORIntVarArray> av = [h allIntVars];
//   NSLog(@"Heuristic on: <%lu> %@",[av count],av);
   CPSolverI* cp = (CPSolverI*) [av solver];
   CPSelect* select = [cp selectInRange: RANGE(cp,[av low],[av up])
                                suchThat: ^bool(ORInt i)      { return [[av at: i] bound]; }
                               orderedBy: ^ORInt(ORInt i) { return [h varOrdering:av[i]]; }];
   do {      
      ORInt i = [select max];
      if (i == MAXINT)
         return;
      id<ORIntVar> x = [av at: i];
      CPSelectMax* valSelect = [[CPSelectMax alloc] initSelectMax:cp
                                                            range:RANGE(cp,[x min],[x max])
                                                         suchThat:^bool(ORInt v)  { return [x member:v];}
                                                        orderedBy:^ORInt(ORInt v) { return [h valOrdering:v forVar:x];}];
      do {
         ORInt curVal = [valSelect choose];
         if (curVal == MAXINT)
            break;
         [cp try:^{
            [cp label:x with:curVal];
         } or:^{
            [cp diff:x with:curVal];
         }];
      } while(![x bound]);       
   } while (true);
}

+(ORInt) maxBound: (id<ORIntVarArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   ORInt M = -MAXINT;
   for(ORInt i = low; i <= up; i++)
      if ([x[i] bound] && [x[i] value] > M)
         M = [x[i] value];
   return M;
}
@end;
