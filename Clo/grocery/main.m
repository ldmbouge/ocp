/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

void splitUpFF(id<CPProgram> cp,id<ORIntVarArray> vars);

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORLong startTime = [ORRuntimeMonitor wctime];
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> R = RANGE(model,1,4);
         ORInt t = 711;
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain:RANGE(model,0,t)];
         [model add:[Sum(model, i, R, x[i]) eq:@(t)]];
         [model add:[Prod(model,i, R, x[i]) eq:@(t * 100 * 100 * 100)]];
         [model add:[x[1] lt:x[2]]];
         [model add:[x[2] lt:x[3]]];
         [model add:[x[3] lt:x[4]]];
         
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         __block ORInt nbSol = 0;
         [cp solveAll:^{
            splitUpFF(cp, x);
            @autoreleasepool {
               [x enumerateWith:^(id<ORIntVar> xi, int i) {
                  NSLog(@"Sol: x[%d] = %d",i,[cp intValue:xi]);
               }];
               nbSol++;
            }
         }];
         ORLong endTime = [ORRuntimeMonitor wctime];
         NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}

void splitUpFF(id<CPProgram> cp,id<ORIntVarArray> vars)
{
   id<ORIntRange> V = [vars range];
   bool found;
   do {
      found = NO;
      id<ORSelect> sel = [ORFactory select:cp range:V
                                  suchThat:^bool(ORInt i)    { return ![cp bound:vars[i]];}
                                 orderedBy:^ORFloat(ORInt i) { return [cp domsize:vars[i]];}];
      ORInt si = [sel min];
      if (si != MAXINT) {
         found = YES;
         ORInt mid = ([cp min:vars[si]] + [cp max:vars[si]]) / 2;
         [cp try:^{
            [cp gthen:vars[si] with:mid];
         } alt:^{
            [cp lthen:vars[si] with:mid+1];
         }];
      }
   } while(found);
}
