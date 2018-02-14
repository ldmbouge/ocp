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
         
         id<ORFloatVar> x = [ORFactory floatVar:model low:2.f up:4.f name:@"x"];
         id<ORFloatVar> y = [ORFactory floatVar:model low:-12.f up:1.f name:@"res"];
         
         id<ORFloatVarArray> vars = [model floatVars];
         
//         [model add:[x leq: y]];
         id<ORGroup> g0 = [ORFactory group3B:model];
         {
            [g0 add:[y eq: [[x mul:x] sub:[x mul:x]]]];
         }
         
         [model add:g0];
         
         
         __block BOOL found = false;
         id<CPProgram>   cps = [args makeProgram:model annotation:notes];
         __block int nbSol = 0;
         [cps solve:^{
            [args launchHeuristic:cps restricted:vars];
            NSLog(@"Domaines finaux");
            for(id<ORFloatVar> v in vars)
               NSLog(@"%@ bound : (%s) %@\n ",v,[cps bound:v]?"YES":"NO",[cps concretize:v]);
//            printf("\n");
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
