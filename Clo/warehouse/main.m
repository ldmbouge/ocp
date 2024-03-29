/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> mdl = [ORFactory createModel];
         
         ORInt fixed = 30;
         ORInt maxCost = 100;
          id<ORIntRange> Stores     = RANGE(mdl,0,9);
          id<ORIntRange> Warehouses = RANGE(mdl,0,4);
          id<ORIntArray> cap = [ORFactory intArray:mdl array: @[@1,@4,@2,@1,@3]];
         
          ORInt connection[10][5] = {{ 20, 24, 11, 25, 30 },
            { 28, 27, 82, 83, 74 },
            { 74, 97, 71, 96, 70 },
            {  2, 55, 73, 69, 61 },
            { 46, 96, 59, 83,  4 },
            { 42, 22, 29, 67, 59 },
            {  1,  5, 73, 59, 56 },
            { 10, 73, 13, 43, 96 },
            { 93, 35, 63, 85, 46 },
            { 47, 65, 55, 71, 95 }};
         ORInt* conn = (ORInt*)connection;
         
         
         id<ORIntVarArray> cost = [ORFactory intVarArray: mdl range:Stores domain: RANGE(mdl,0,maxCost)];
         id<ORIntVarArray> supp = [ORFactory intVarArray: mdl range:Stores domain: Warehouses];
         id<ORIntVarArray> open = [ORFactory intVarArray: mdl range:Warehouses domain: RANGE(mdl,0,1)];
         id<ORIntVar>      obj  = [ORFactory intVar:mdl domain:RANGE(mdl,0,maxCost*sizeof(cap))];
         
         [mdl add: [obj eq: [Sum(mdl,s, Stores, cost[s]) plus: Sum(mdl,w, Warehouses, [open[w] mul:@(fixed)]) ]]];
         for(ORUInt i=Warehouses.low;i <= Warehouses.up;i++) {
            [mdl add: [Sum(mdl,s, Stores, [supp[s] eq:@(i)]) leq:cap[i]]];
         }
         for(ORUInt i=Stores.low;i <= Stores.up; i++) {
            id<ORIntArray> row = [ORFactory intArray:mdl range:Warehouses with:^ORInt(ORInt j) {
                return conn[i*[Warehouses size]+j];}];
            [mdl add: [[open elt:supp[i]] eq:@1]];
            [mdl add: [cost[i] eq:[row elt:supp[i]]]];
         }
         //[mdl minimize: [Sum(mdl,s, Stores, cost[s]) plus: Sum(mdl,w, Warehouses, [open[w] mul:@(fixed)])]];
         [mdl minimizeVar:obj];
         
         id<CPProgram> cp = [ORFactory createCPProgram:mdl];
         __block ORInt nbSol = 0;
         
         [cp solve: ^{
            NSLog(@"Start...");
            [cp labelArray:cost orderedBy:^ORDouble(ORInt i) { return [cp domsize:cost[i]];}];
            [cp labelArray:supp orderedBy:^ORDouble(ORInt i) { return [cp domsize:supp[i]];}];
            [cp labelArray:open orderedBy:^ORDouble(ORInt i) { return [cp domsize:open[i]];}];
            nbSol++;
            @autoreleasepool {
               id<ORIntArray> ops = [ORFactory intArray:cp range:open.range with:^ORInt(ORInt k) {
                  return [cp intValue:open[k]];
               }];
                id<ORIntArray> sps = [ORFactory intArray:cp range:supp.range with:^ORInt(ORInt k) {
                    return [cp intValue:supp[k]];
                }];
                id<ORIntArray> cps = [ORFactory intArray:cp range:cost.range with:^ORInt(ORInt k) {
                    return [cp intValue:cost[k]];
                }];
               NSLog(@"Solution: %@  -- %@ -- %@ -- open: %d",ops,sps,cps,[cp intValue:obj]);
            }
         }];
         NSLog(@"#solutions: %d",nbSol);
         NSLog(@"Solver: %@",cp);
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return res;
      }];
   }
   return 0;
}

