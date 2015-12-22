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
      [args measure:^struct ORResult() {
         ORInt n = [args size];
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
         id<ORIntVarArray> x = [ORFactory intVarArray: model range: R domain: R];
         for(ORInt i=0;i<n;i++)
            [model add: [Sum(model,j,R,[x[j] eq: @(i)]) eq: x[i] ]];
         
         id<CPProgram> cp = [ORFactory createCPProgram: model];
         
         [cp solveAll: ^{
            [cp  labelArray: x];
            for(ORInt i = 0; i < n; i++)
               printf("%d ",[cp intValue:x[i]]);
            printf("\n");
         }];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return res;
      }];
   }
   return 0;
}

