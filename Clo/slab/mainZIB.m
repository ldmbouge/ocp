/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORProgram/ORProgram.h>
#import <ORProgram/ORProgramFactory.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> mdl = [ORFactory createModel];
         FILE* dta = fopen("slab.dat","r");
         ORInt nbCap;
         fscanf(dta,"%d",&nbCap);
         nbCap++;
         id<ORIntRange> Caps = RANGE(mdl,1,nbCap);
         id<ORIntArray> cap = [ORFactory intArray: mdl range:Caps value: 0];
         for(ORInt i = 2; i <= nbCap; i++) {
            ORInt c;
            fscanf(dta,"%d",&c);
            [cap set: c at: i];
         }
         ORInt nbColors;
         ORInt nbOrders;
         fscanf(dta,"%d",&nbColors);
         NSLog(@"Nb Colors: %d",nbColors);
         fscanf(dta,"%d",&nbOrders);
         id<ORIntRange> Colors = RANGE(mdl,1,nbColors);
         id<ORIntRange> Orders = RANGE(mdl,1,nbOrders);
         id<ORIntArray> color = [ORFactory intArray: mdl range:Orders value: 0];
         id<ORIntArray> weight = [ORFactory intArray: mdl range:Orders value: 0];
         for(ORInt o = 1; o <= nbOrders; o++) {
            ORInt w;
            ORInt c;
            fscanf(dta,"%d",&w);
            fscanf(dta,"%d",&c);
            [weight set: w at: o];
            [color set: c at: o];
         }
         
         ORInt nbSize = 111;
         id<ORIntRange> SetOrders = RANGE(mdl,1,nbSize);
//         id<ORIntRange> Slabs = RANGE(mdl,1,nbSize);
         id<ORIntSetArray> coloredOrder = [ORFactory intSetArray: mdl range: Colors];
         for(int o = 1; o <= nbSize; o++)
            coloredOrder[[color at: o]] = [ORFactory intSet: mdl];
         for(int o = 1; o <= nbSize; o++)
            [coloredOrder[[color at: o]] insert: o];
         ORInt maxCapacities = 0;
         for(int c = 1; c <= nbCap; c++)
            if ([cap at: c] > maxCapacities)
               maxCapacities = [cap at: c];
         
         id<ORIntRange> Capacities = RANGE(mdl,0,maxCapacities);
         id<ORIntArray> loss = [ORFactory intArray: mdl range: Capacities value: 0];
         for(ORInt c = 0; c <= maxCapacities; c++) {
            ORInt m = MAXINT;
            for(ORInt i = Caps.low; i <= Caps.up; i++)
               if ([cap at: i] >= c && [cap at: i] - c < m)
                  m = [cap at: i] - c;
            [loss set: m at: c];
         }
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range:SetOrders domain:RANGE(mdl,0,1)];
         id<ORIntVar>      w = [ORFactory intVar:mdl domain:RANGE(mdl,0,maxCapacities)];

         [mdl add:[Sum(mdl,i, SetOrders, [x[i] mul:weight[i]]) eq:w]];
         [mdl add:[Sum(mdl,c,Colors,Or(mdl,o,coloredOrder[c],x[o])) leq: @2]];
         [mdl add:[Sum(mdl,i, SetOrders, x[i]) geq:@1]];
         
         id<CPProgram> cp  = [args makeProgram:mdl annotation:nil];
         [cp solveAll: ^{
            [cp labelArray:x];
         }];
         NSLog(@"Solver status: %@\n",cp);
         id<ORSolutionPool> pool = [cp solutionPool];
         id<ORModel> mip = [ORFactory createModel];
         id<ORIntVarArray> slab = [ORFactory intVarArray:mip range:RANGE(mip,0,(int)pool.count - 1) domain:RANGE(mdl,0,1)];
         [SetOrders enumerateWithBlock:^(ORInt o) {
            [mip add:[Sum(mip, s, slab.range, [slab[s] mul:@([pool[s] intValue:x[o]])]) eq:@1]];
         }];
         [mip minimize:Sum(mip,s,slab.range,[slab[s] mul: @([loss at:[pool[s] intValue:w]])])];
         
         id<MIPProgram> mps = [ORFactory createMIPProgram:mip];
//         id<ORIntArray> lc = [ORFactory intArray:mps range:slab.range with:^ORInt(ORInt c) {
//            return [loss at:[pool[c] intValue:w]];
//         }];
//         [mps solve:^{
//            [mps forall:slab.range orderedBy:^ORInt(ORInt c) { return -[lc at:c];}
//                     do:^(ORInt c) {
//               [mps label:slab[c]];
//            }];
//            //[mps labelArrayFF:slab];
//            NSLog(@"Solution: %@",[[mps objective] value]);
//         }];
         [mps solve];
         id<ORSolution> bs = [[mps solutionPool] best];
         id<ORIntSet> cc = [ORFactory collect:mps range:slab.range suchThat:^bool(ORInt c) {
            return [bs intValue:slab[c]] == 1;
         } of:^ORInt(ORInt c) {
            return c;
         }];
         NSLog(@"Chosen configs: %@",cc);
         
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}
