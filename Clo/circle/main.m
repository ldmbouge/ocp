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
         id<ORFloatVarArray> a = [ORFactory floatVarArray:model range:RANGE(model,0,1) low:-1000.0 up:1000.0];
         id<ORFloatVar> x = a[0];
         id<ORFloatVar> y = a[1];
         [model add:[[[x square] plus:[y square]] eq:@1]];
         [model add:[[x square] eq:y]];
         
         id<CPProgram> cp = [args makeProgram:model];
         __block ORInt nbSol = 0;
         [cp solve:^{
            NSLog(@"Starting...");
            NSLog(@"X = %@",[cp gamma][x.getId]);
            NSLog(@"Y = %@",[cp gamma][x.getId]);
            //[cp labelArrayFF:x];
            //[cp labelArrayFF:l];
            
         }];
         id<ORCPSolution> sol = [[cp solutionPool] best];
         printf("x = [");
         for(ORInt i = x.low; i <= x.up; i++)
            printf("%f%c",[sol floatValue: x[i]],((i < x.up) ? ',' : ']'));
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

