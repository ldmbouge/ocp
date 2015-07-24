/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         int n = [args size];
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> R = RANGE(model,0,n-1);
         id<ORMutableInteger> nbSol = INTEGER(model,0);
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain: R];
         for(ORUInt i =0;i < n; i++) {
            for(ORUInt j=i+1;j< n;j++) {
               [model add: [x[i] neq: x[j]]];
               [model add: [x[i] neq: [x[j] plus: @(i-j)]]];
               [model add: [x[i] neq: [x[j] plus: @(j-i)]]];
            }
         }
         id<CPProgram> cp = [ORFactory createCPProgram: model];
         [cp clearOnSolution]; // other solvers do not save solutions. We shouldn't either.
         [cp solveAll: ^{
            [cp labelArrayFF: x];
            [nbSol incr:cp];
         }];
         printf("GOT %d solutions\n",[nbSol intValue:cp]);
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT([nbSol intValue:cp], [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return r;
      }];      
   }
   return 0;
}
