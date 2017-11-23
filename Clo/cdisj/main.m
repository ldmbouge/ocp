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
         id<ORAnnotation> notes = [ORFactory annotation];
         
         id<ORIntVar> x = [ORFactory intVar:model domain:RANGE(model,5,10)];
         id<ORIntVar> y = [ORFactory intVar:model domain:RANGE(model,4,11)];
         id<ORIntVar> m = [ORFactory intVar:model domain:RANGE(model,0,20)];
         
         id<ORIntVarArray> vars = [model intVars];
//         
//         id<ORConstraint> c = [x leq: m];
//         id<ORConstraint> c2 = [y leq: m];
//         [model add:[x leq: m]];
//         [model add:[y leq: m]];
//
         id<ORGroup> g0 = [ORFactory group:model];
         {
            [g0 add:[m eq: x]];
         }
         
         id<ORGroup> g1 = [ORFactory group:model];
         {
            [g1 add:[m eq: y]];
         }
         [model add:[ORFactory cdisj:model clauses:@[g0,g1]]];
         
         
         __block BOOL found = false;
         id<CPProgram>   cps = [args makeProgram:model annotation:notes];
         __block int nbSol = 0;
         [cps solveAll:^{
            //[cps label:y with:10];
            //[cps gthen:y with:9];
            [cps label:x];
            [cps label:y];
            [cps label:m];
            for(id<ORIntVar> v in vars)
               printf("%d ",[cps intValue:v]);
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


