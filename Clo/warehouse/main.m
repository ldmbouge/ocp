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
      CPInt fixed = 30;
      CPInt maxCost = 100;
      CPRange Stores     = RANGE(0,9);
      CPRange Warehouses = RANGE(0,4);
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

      id<CP> cp = [CPFactory createSolver];
      id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
      
      id<CPIntVarArray> cost = [CPFactory intVarArray: cp range:Stores domain: RANGE(0,maxCost)];
      id<CPIntVarArray> supp = [CPFactory intVarArray: cp range:Stores domain: Warehouses];
      id<CPIntVarArray> open = [CPFactory intVarArray: cp range:Warehouses domain: RANGE(0,1)];
      id<CPIntVar>      obj  = [CPFactory intVar:cp domain:RANGE(0,maxCost*sizeof(cap))];
      
      [cp minimize:obj
         subjectTo:^{

            [cp add: obj equal: [SUM(s, Stores, cost[s]) add: SUM(w, Warehouses, [open[w] muli:fixed]) ]];
            for(CPUInt i=Warehouses.low;i <= Warehouses.up;i++) {
               [cp add: SUM(s, Stores, [supp[s] equal:[CPFactory integer:cp value:i]]) leq: [CPFactory integer:cp value:cap[i]]];
            }
            for(CPUInt i=Stores.low;i <= Stores.up; i++) {
               id<CPIntArray> row = [CPFactory intArray:cp range:Warehouses with:^ORInt(ORInt j) { return conn[i*5+j];}];
               [cp add: [open elt:supp[i]] equal:[CPFactory integer:cp value:YES]];
               [cp add: cost[i] equal:[row elt:supp[i]]];
            }

/*
            NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
            BOOL ok = [archive writeToFile:@"ais.CParchive" atomically:NO];
            NSLog(@"Writing ? %s",ok ? "OK" : "KO");            
 */
         } using:^{
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

