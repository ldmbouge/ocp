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
         
         id<ORIntRange> r1 = RANGE(model,1,2);
         id<ORIntRange> r2 = RANGE(model,0,10);
         id<ORIntVar> x = [ORFactory intVar:model value:5];
         id<ORIntVar> y = [ORFactory intVar:model domain:r1];
         id<ORIntVar> a = [ORFactory intVar:model domain:r2];
         id<ORIntVar> z = [ORFactory intVar:model domain:r2];
         id<ORIntVar> w = [ORFactory intVar:model domain:r1];
         id<ORIntVar> v = [ORFactory intVar:model domain:r2];
         
         id<ORIntVarArray> vars = [model intVars];
         
         id<ORExpr> cp  = [[x plus: y] gt: @(6)];
         id<ORIntVar> b0 = [ORFactory boolVar:model];
         id<ORIntVar> b1 = [ORFactory boolVar:model];
         [model add: [cp eq: b0]];
         [model add: [[cp neg] eq: b1]];
         
         id<ORGroup> g0 = [ORFactory group:model guard:b0];
         {
            [g0 add:[z eq: [x plus: y]]];               // z <- x + y
            [g0 add:[a eq: [z sub: @(2)]]];             // a <- z - 2
         
            id<ORExpr> c2  = [[a plus: w] leq: @(6)];
            id<ORIntVar> b00 = [ORFactory boolVar:model];
            id<ORIntVar> b01 = [ORFactory boolVar:model];
            [g0 add: [c2 eq: b00]];
            [g0 add:[b01 eq: [b00 neg]]];
            id<ORGroup> g00 = [ORFactory group:model guard:b00];
            {
               [g00 add:[v eq: [a plus: w]]];
            }
            [g0 add:g00];
            id<ORGroup> g01 = [ORFactory group:model guard:b01];
            {
               [g01 add:[v eq: [a mul: w]]];
            }
            [g0 add:g01];
         }
         [model add:g0];
         
         id<ORGroup> g1 = [ORFactory group:model guard:b1];
         {
            [g1 add:[a eq: [x sub: y]]];                // a <- x - y
            [g1 add:[z eq: [a plus: @(2)]]];            // z <- a + 2
            [g1 add:[w eq: @(2)]];                      // w <- 2
            [g1 add:[v eq: [a div:w]]];                 // v <- a div w
         }
         [model add:g1];
         
         
         __block BOOL found = false;
         id<CPProgram>   cps = [args makeProgram:model annotation:notes];
         [cps solveAll:^{
            [cps labelArray:vars];
            for(id<ORIntVar> v in vars)
               printf("%d ",[cps intValue:v]);
            printf("\n");
         }];
         NSLog(@"Solver status: %@\n",cps);
         struct ORResult res = REPORT(found, [[cps explorer] nbFailures], [[cps explorer] nbChoices], [[cps engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

