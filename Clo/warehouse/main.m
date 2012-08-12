/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORFactory.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<CPSolver> cp = [CPFactory createSolver];
      CPInt fixed = 30;
      CPInt maxCost = 100;
      id<ORIntRange> Stores     = RANGE(cp,0,9);
      id<ORIntRange> Warehouses = RANGE(cp,0,4);
      CPInt* cap = (CPInt[]){1,4,2,1,3};
      CPInt connection[10][5] = {{ 20, 24, 11, 25, 30 },
                                 { 28, 27, 82, 83, 74 },
                                 { 74, 97, 71, 96, 70 },
                                 {  2, 55, 73, 69, 61 },
                                 { 46, 96, 59, 83,  4 },
                                 { 42, 22, 29, 67, 59 },
                                 {  1,  5, 73, 59, 56 },
                                 { 10, 73, 13, 43, 96 },
                                 { 93, 35, 63, 85, 46 },
                                 { 47, 65, 55, 71, 95 }};
      CPInt* conn = (CPInt*)connection;

    
      id<ORInteger> nbSolutions = [ORFactory integer: cp value:0];
      
      id<ORIntVarArray> cost = [CPFactory intVarArray: cp range:Stores domain: RANGE(cp,0,maxCost)];
      id<ORIntVarArray> supp = [CPFactory intVarArray: cp range:Stores domain: Warehouses];
      id<ORIntVarArray> open = [CPFactory intVarArray: cp range:Warehouses domain: RANGE(cp,0,1)];
      id<ORIntVar>      obj  = [CPFactory intVar:cp bounds:RANGE(cp,0,maxCost*sizeof(cap))];
      
      [cp add: [obj eq: [SUM(s, Stores, cost[s]) plus: SUM(w, Warehouses, [open[w] muli:fixed]) ]]];
      for(CPUInt i=Warehouses.low;i <= Warehouses.up;i++) {
         [cp add: [SUM(s, Stores, [supp[s] eqi:i]) leqi:cap[i]]];
      }
      for(CPUInt i=Stores.low;i <= Stores.up; i++) {
         id<ORIntArray> row = [CPFactory intArray:cp range:Warehouses with:^ORInt(ORInt j) { return conn[i*5+j];}];
         [cp add: [[open elt:supp[i]] eqi:YES]];
         [cp add: [cost[i] eq:[row elt:supp[i]]]];
      }
      [cp minimize: obj];
      [cp solve: ^{
         NSLog(@"Start...");
         [CPLabel array:cost orderedBy:^ORInt(ORInt i) { return [cost[i] domsize];}];
         [CPLabel array:supp orderedBy:^ORInt(ORInt i) { return [supp[i] domsize];}];
         [CPLabel array:open orderedBy:^ORInt(ORInt i) { return [open[i] domsize];}];
         [nbSolutions incr];
         NSLog(@"Solution: %@  -- cost: %@",open,obj);
      }];
      NSLog(@"#solutions: %@",nbSolutions);
      NSLog(@"Solver: %@",cp);
      [cp release];
      [CPFactory shutdown];      
   }
   return 0;
}

