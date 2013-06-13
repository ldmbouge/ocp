/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int test1(int argc, const char * argv[]);
int test2(int argc, const char * argv[]);

int main (int argc, const char * argv[])
{
   test1(argc,argv);
   test2(argc,argv);
   return 0;
}

int test1(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> model = [ORFactory createModel];
         id<ORIntVar> x = [ORFactory intVar:model domain:RANGE(model,-10,10)];
         id<ORIntVar> y = [ORFactory intVar:model domain:RANGE(model,1,3)];
         id<ORIntVar> z = [ORFactory intVar:model domain:RANGE(model,0,10)];
         [model add:[[x mod:y] eq:z]];
         __block int nbSol = 0;
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         [cp solveAll:^{
            [cp label:x];
            [cp label:y];
            [cp label:z];
            @autoreleasepool {
               NSLog(@"values: %@",@[@([cp intValue:x]),@([cp intValue:y]),@([cp intValue:z])]);
            }
            assert([cp intValue:x] % [cp intValue:y] == [cp intValue:z]);
            nbSol++;
         }];
         ORInt nbc = 0;
         for(ORInt i=-10;i<=10;i++) {
            for(ORInt j=1;j<=3;j++) {
               ORInt k = i % j;
               nbc += (k >= 0 && k <= 10);
            }
         }
         NSLog(@"#sol: %d - %d",nbSol,nbc);
         assert(nbSol == nbc);
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

int test2(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> model = [ORFactory createModel];
         id<ORIntVar> x = [ORFactory intVar:model domain:RANGE(model,-10,10)];
         ORInt y = 3;
         id<ORIntVar> z = [ORFactory intVar:model domain:RANGE(model,0,10)];
         [model add:[[x mod:@(y)] eq:z] annotation:DomainConsistency];
         __block int nbSol = 0;
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         [cp solveAll:^{
            NSLog(@"MODEL: %@",[[cp engine] model]);
            [cp label:x];
            //[cp label:z];
            @autoreleasepool {
               NSLog(@"values: %@",@[@([cp intValue:x]),@(y),@([cp intValue:z])]);
            }
            assert([cp intValue:x] % y == [cp intValue:z]);
            nbSol++;
         }];
         ORInt nbc = 0;
         for(ORInt i=-10;i<=10;i++) {
            ORInt j = 3;
            ORInt k = i % j;
            nbc += (k >= 0 && k <= 10);
         }
         NSLog(@"#sol: %d - %d",nbSol,nbc);
         assert(nbSol == nbc);
         NSLog(@"Solver: %@",cp);
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}
