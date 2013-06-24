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
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];

         ORInt n = 10;
         id<ORIntRange> A = RANGE(model,1,10); // 10 symbols in the alphabet
         id<ORIntRange> R = RANGE(model,0,n-1);
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain:A];

         ORTransition tf[] = {{1,1,2},{2,2,3},{3,2,4},{3,3,3},{4,1,5}};
         id<ORIntSet> final = [ORFactory intSet:model set:[NSSet setWithObjects:@5, nil]];
         id<ORAutomaton> a = [ORFactory automaton:model alphabet:A states:RANGE(model,1,5) transition:tf size:SIZETF(tf) initial:1 final:final];
         [model add:[ORFactory regular:x for:a]];
         
         id<CPProgram> cp = [args makeProgram:model];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:x];
         __block ORInt nbSol = 0;
         [cp solve:^{
            //[cp labelArrayFF:All2(cp, ORIntVar, i, D, j, D, [q at:i :j])];
            [cp labelHeuristic:h];
            nbSol++;
            @autoreleasepool {
               for(ORInt i=0;i <n;i++)
                  printf("%2d ",i);
               printf("\n");
               for(ORInt i=0;i <n;i++)
                  printf("%2d ",[cp intValue:x[i]]);
               printf("\n");
            }
         }];
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}
