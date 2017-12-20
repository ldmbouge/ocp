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
         
         id<ORFloatVar> x = [ORFactory floatVar:model];
         id<ORFloatVar> y = [ORFactory floatVar:model];
         
         id<ORFloatVarArray> vars = [model floatVars];
         
         [model add:[x leq: y]];
         
         id<ORGroup> g0 = [ORFactory group3B:model];
         {
            [g0 add:[m eq: x]];
         }
         
         [model add:g0];
         
         
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
