/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> model = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory note];
         ORInt n = [args size];
         id<ORIntRange> V = RANGE(model,0,n-1);
         id<ORIntRange> F = RANGE(model,0,2*n-1);
         id<ORIntRange> D = RANGE(model,1,2*n);
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:V domain:D];
         id<ORIntVarArray> y = [ORFactory intVarArray:model range:V domain:D];
         for(ORInt i=0;i<= n-2;i++) {
            [model add:[x[i] lt:x[i+1]]];
            [model add:[y[i] lt:y[i+1]]];
         }
         [model add:[x[0] lt:y[0]]];
         id<ORIntVarArray> xy = [ORFactory intVarArray:model range:F with:^id<ORIntVar>(ORInt i) {
            if (i <= n-1)
               return x[i];
            else return y[i-n];
         }];
         id<ORIntVarArray> sx = [ORFactory intVarArray:model range:V domain:RANGE(model,1,4*n*n)];
         id<ORIntVarArray> sy = [ORFactory intVarArray:model range:V domain:RANGE(model,1,4*n*n)];
         for(ORInt i=0;i<=n-1;i++) {
            [notes dc:[model add:[sx[i] eq:[x[i] mul:x[i]]]]];
            [notes dc:[model add:[sy[i] eq:[y[i] mul:y[i]]]]];
         }
         [notes dc:[model add:[ORFactory alldifferent:xy]]];
         [model add:[[Sum(model, i, V, x[i])  sub:Sum(model, j, V, y[j])] eq:@0]];
         [model add:[[Sum(model, i, V, sx[i]) sub:Sum(model, j, V, sy[j])] eq:@0]];
         [model add:[Sum(model,i,V,x[i])  eq:@(2 * n * (2 * n + 1) / 4) ]];
         [model add:[Sum(model,i,V,y[i])  eq:@(2 * n * (2 * n + 1) / 4) ]];
         
         [model add:[Sum(model,i,V,sx[i])  eq:@(2 * n * (2 * n + 1)*(4*n+1) / 12) ]];
         [model add:[Sum(model,i,V,sx[i])  eq:@(2 * n * (2 * n + 1)*(4*n+1) / 12) ]];

         id<CPProgram> cp  = [args makeProgram:model annotation:notes];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:xy];
         __block ORInt nbSol = 0;
         [cp solve:^{
            //NSLog(@"Concrete model;%@",[[cp engine] model]);
            [cp labelHeuristic:h];
            //[cp labelArray:xy orderedBy:^ORFloat(ORInt i) { return [xy[i] domsize];}];
            id<ORIntArray> solX = [ORFactory intArray:model range:[x range] with:^ORInt(ORInt i) { return [cp intValue:x[i]];}];
            id<ORIntArray> solY = [ORFactory intArray:model range:[x range] with:^ORInt(ORInt i) { return [cp intValue:y[i]];}];
            NSLog(@"Sol: %@ -- %@",solX,solY);
            nbSol++;
         }];         
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}

