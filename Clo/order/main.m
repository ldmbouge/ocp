/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         ORLong startTime = [ORRuntimeMonitor cputime];
         id<ORModel> model = [ORFactory createModel];
         ORInt n = [args size];
         id<ORIntRange> D = RANGE(model,0,n);
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:D domain:D];
         for(ORInt k=0;k <= n-1;k++)
            [model add:[x[k] lt:x[k+1]]];
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         [cp solve:^{
            NSLog(@"About to search...");
             @autoreleasepool {
                id<ORIntArray> xv = [ORFactory intArray:cp range:x.range with:^ORInt(ORInt i) {
                   return [cp intValue:x[i]];
                }];
                NSLog(@"solution: %@",xv);
            }
         }];
         ORLong endTime = [ORRuntimeMonitor cputime];
         NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}

