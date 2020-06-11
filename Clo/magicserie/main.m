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
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> R = RANGE(mdl,0,n-1);
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
         for(ORInt i=0;i<n;i++)
            [mdl add: [Sum(mdl,j,R,[x[j] eq: @(i)]) eq: x[i] ]];
         [mdl add: [Sum(mdl,i,R,[x[i] mul: @(i)]) eq: @(n) ]];
         [mdl add: [Sum(mdl,i,R,[x[i] mul:@(i-1)]) eq: @0]];
         id<CPProgram> cp = [ORFactory createCPProgram:mdl];
         [cp solve: ^{
            NSLog(@"start...");
            ORLong st0 = [ORRuntimeMonitor cputime];
            for(ORInt i=0;i<n;i++) {
               while (![cp bound:x[i]]) {
                  ORInt v = [cp max:x[i]];
                  [cp try:^{
                     [cp label:x[i] with:v];
                  } alt:^{
                     [cp diff:x[i] with:v];
                  }];
               }
            }
            ORLong st1 = [ORRuntimeMonitor cputime];
            printf("Succeeds(%lld) \n",st1 - st0);
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
