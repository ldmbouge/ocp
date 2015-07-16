/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
         id<ORIntRange> Slabs = RANGE(mdl,1,nbSize);
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
         ORInt maxLoss = 0;
         for(ORInt c = 0; c <= maxCapacities; c++) {
            ORInt m = MAXINT;
            for(ORInt i = Caps.low; i <= Caps.up; i++)
               if ([cap at: i] >= c && [cap at: i] - c < m)
                  m = [cap at: i] - c;
            [loss set: m at: c];
            maxLoss = m > maxLoss ? m : maxLoss;
         }
         id<ORIntVar> obj = [ORFactory intVar: mdl domain: RANGE(mdl,0,nbSize*maxCapacities)];
         id<ORIntVarArray> slab = [ORFactory intVarArray: mdl range: SetOrders domain: Slabs];
         id<ORIntVarArray> load = [ORFactory intVarArray: mdl range: Slabs domain: Capacities];
         id<ORIntVarMatrix> x = [ORFactory intVarMatrix:mdl range:SetOrders :Slabs domain:RANGE(mdl,0,1)];
         id<ORIntVarMatrix> l = [ORFactory intVarMatrix:mdl range:Slabs :Capacities domain:RANGE(mdl,0,1)];

         id<ORIntVarMatrix> cs = [ORFactory intVarMatrix:mdl range:Colors :Slabs domain:RANGE(mdl,0,1)];
         
         // binarization of slab variables
         [SetOrders enumerateWithBlock:^(ORInt o) {
            [mdl add:[Sum(mdl, i, Slabs, [[x at:o :i] mul:@(i)]) eq:slab[o]]];
            [mdl add:[Sum(mdl,i,Slabs,[x at:o :i]) eq:@(1)]];
         }];
         // linearization of packing constraint
         [Slabs enumerateWithBlock:^(ORInt s) {
            [mdl add:[Sum(mdl, o, SetOrders, [[x at:o :s] mul:weight[o]]) eq:load[s]]];
         }];
         // binarization of load variables
         [Slabs enumerateWithBlock:^(ORInt s) {
            [mdl add:[Sum(mdl,i,Capacities,[[l at:s :i] mul:@(i)]) eq:load[s]]];
            //[mdl add:[Sum(mdl,i,Capacities, [l at:s :i]) eq:@(1)]];
            [mdl add:[ORFactory sumbool:mdl array:All(mdl, ORIntVar, i, Capacities, [l at:s :i]) eqi:1]];
         }];
         // objective function with linearization of element
         [mdl add:[obj eq:Sum2(mdl, s, Slabs, c, Capacities, [[l at:s :c] mul:@([loss at:c])] )]];
         // Disjunction on order.
         
         [SetOrders enumerateWithBlock:^(ORInt o) {
            [Slabs enumerateWithBlock:^(ORInt s) {
               [mdl add:[[x at:o :s] leq:[cs at:[color at:o] :s]]];
            }];
         }];
         
         [Colors enumerateWithBlock:^(ORInt c) {
            [Slabs enumerateWithBlock:^(ORInt s) {
               [mdl add:[[cs at:c :s] leq: Sum(mdl, o, coloredOrder[c], [x at:o :s]) ]];
               [mdl add:[[[cs at:c :s] mul:@(1000)] geq: Sum(mdl, o, coloredOrder[c], [x at:o :s]) ]];
            }];
         }];
         [Slabs enumerateWithBlock:^(ORInt s) {
            [mdl add: [Sum(mdl, c, Colors, [cs at:c :s]) leq:@2]];
         }];
         

          
         [mdl minimize: obj];
         
         id<MIPProgram> cp = [ORFactory createMIPProgram:mdl];
         [cp solve];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}
