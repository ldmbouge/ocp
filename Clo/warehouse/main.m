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
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
#import <ORProgram/ORConcretizer.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      ORInt fixed = 30;
      ORInt maxCost = 100;
      id<ORIntRange> Stores     = RANGE(mdl,0,9);
      id<ORIntRange> Warehouses = RANGE(mdl,0,4);
      ORInt* cap = (ORInt[]){1,4,2,1,3};
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

    
      id<ORInteger> nbSolutions = [ORFactory integer: mdl value:0];
      
      id<ORIntVarArray> cost = [ORFactory intVarArray: mdl range:Stores domain: RANGE(mdl,0,maxCost)];
      id<ORIntVarArray> supp = [ORFactory intVarArray: mdl range:Stores domain: Warehouses];
      id<ORIntVarArray> open = [ORFactory intVarArray: mdl range:Warehouses domain: RANGE(mdl,0,1)];
      id<ORIntVar>      obj  = [ORFactory intVar:mdl domain:RANGE(mdl,0,maxCost*sizeof(cap))];
      
      [mdl add: [obj eq: [Sum(mdl,s, Stores, cost[s]) plus: Sum(mdl,w, Warehouses, [open[w] muli:fixed]) ]]];
      for(ORUInt i=Warehouses.low;i <= Warehouses.up;i++) {
         [mdl add: [Sum(mdl,s, Stores, [supp[s] eqi:i]) leqi:cap[i]]];
      }
      for(ORUInt i=Stores.low;i <= Stores.up; i++) {
         id<ORIntArray> row = [ORFactory intArray:mdl range:Warehouses with:^ORInt(ORInt j) { return conn[i*5+j];}];
         [mdl add: [[open elt:supp[i]] eqi:YES]];
         [mdl add: [cost[i] eq:[row elt:supp[i]]]];
      }
      [mdl minimize: obj];
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      [cp solve: ^{
         NSLog(@"Start...");
         [cp labelArray:cost orderedBy:^ORFloat(ORInt i) { return [cost[i] domsize];}];
         [cp labelArray:supp orderedBy:^ORFloat(ORInt i) { return [supp[i] domsize];}];
         [cp labelArray:open orderedBy:^ORFloat(ORInt i) { return [open[i] domsize];}];
         [nbSolutions incr];
         NSLog(@"Solution: %@  -- cost: %@",open,obj);
      }];
      NSLog(@"#solutions: %@",nbSolutions);
      NSLog(@"Solver: %@",cp);
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

