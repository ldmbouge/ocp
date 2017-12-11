/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
         
         id<ORFloatVar> x = [ORFactory floatVar:model low:5.f up:10.f];
         id<ORFloatVar> y = [ORFactory floatVar:model low:4.f up:11.f];
         id<ORFloatVar> m = [ORFactory floatVar:model low:0.f up:20.f];
         
         
         [model add:[x leq: m]];
         [model add:[y leq: m]];
         
         id<ORGroup> g0 = [ORFactory group:model];
         {
            [g0 add:[m eq: x]];
//           don't work [g0 add:[m eq: [x plus:@(2.f)]]];
         }
         
         id<ORGroup> g1 = [ORFactory group:model];
         {
            [g1 add:[m eq: y]];
         }
         [model add:[ORFactory cdisj:model clauses:@[g0,g1]]];
         
         id<ORFloatVarArray> vars = [model floatVars];
         __block BOOL found = false;
         id<CPProgram>   cps = [args makeProgram:model];
         __block int nbSol = 0;
         [cps solve:^{
            [args launchHeuristic:cps restricted:vars];
            for(id<ORFloatVar> v in vars)
               printf("%16.16e ",[cps floatValue:v]);
            printf("\n");
            nbSol++;
         }];
         NSLog(@"#sol = %d",nbSol);
         NSLog(@"Solver status: %@\n",cps);
         struct ORResult res = REPORT(found, [[cps explorer] nbFailures], [[cps explorer] nbChoices], [[cps engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}



