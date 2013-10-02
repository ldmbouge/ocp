//
//  main.m
//  WarehouseLocation
//
//  Created by Nikolaj on 9/26/13.
//  Copyright (c) 2013 Nikolaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      const ORInt cf = 30; // fixed maintenance cost
      const ORInt nw = 5; // number warehouses
      const ORInt ns = 10; // number stores
      
      ORInt cap[nw] = {1, 4, 2, 1, 3};
      ORInt supc[ns][nw] = {
         {20, 24, 11, 25, 30},
         {28, 27, 82, 83, 74},
         {74, 97, 71, 96, 70},
         {2, 55, 73, 69, 61},
         {46, 96, 59, 83, 4},
         {42, 22, 29, 67, 59},
         {1, 5, 73, 59, 56},
         {10, 73, 13, 43, 96},
         {93, 35, 63, 85, 46},
         {47, 65, 55, 71, 95}
      };
      
      id<ORIntArray> capacity = [ORFactory intArray:mdl range:RANGE(mdl, 1, nw) values:cap];
      id<ORIntVarMatrix> supCost = [ORFactory intVarMatrix:mdl range:RANGE(mdl, 1, ns) :RANGE(mdl, 1, nw) domain:RANGE(mdl, 1, 1000)];
      id<ORIntVarArray> warehouseof = [ORFactory intVarArray:mdl range:RANGE(mdl, 1, ns) domain:RANGE(mdl, 1, nw)];
      id<ORIntVarArray> warehouseused = [ORFactory intVarArray:mdl range:RANGE(mdl, 1, nw) domain:RANGE(mdl, 0, 1)];
      
      id<ORIntVar> totalcost = [ORFactory intVar:mdl domain:RANGE(mdl, 0, 1000)];
      
      for (int s = 1; s <= ns; s++) {
         for (int w = 1; w <= nw; w++) {
            [mdl add:[[supCost at:s :w] eq:@(supc[s-1][w-1])]];
         }
      }
      
      for (int w = 1; w <= nw; w++) {
         [mdl add:[Sum(mdl, s, RANGE(mdl, 1, ns), [warehouseof[s] eq:@(w)]) leq:@([capacity at:w])]];
      }
      
      // this loop is what causes the invalid behavior
      for (ORInt w = 1; w <= nw; w++) {
         [mdl add:[warehouseused[w] eq: [Sum(mdl, s, RANGE(mdl, 1, ns), [[warehouseof at:s] eq:@(w)]) neq:@(0)]]];
      }
      
      // if you replace the above loop with the one commented out below, it works as expected
      //        for (int s = 1; s <= ns; s++) {
      //            [mdl add:[[warehouseused elt:warehouseof[s]] eq:@(1)]];
      //        }
      
      [mdl add:[totalcost eq:[Sum(mdl, w, RANGE(mdl, 1, nw), [warehouseused[w] mul:@(cf)]) plus:Sum(mdl, s, RANGE(mdl, 1, ns), [supCost at:s elt:warehouseof[s]])]]];
      
      [mdl minimize:totalcost];
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      [cp solve:
       ^() {
          [cp label:totalcost];
          [cp labelArray:warehouseof];
          [cp labelArray:warehouseused];
          
          printf("Total cost: %d \n", [cp intValue:totalcost]);
          for (int s = 1; s <= ns; s++) {
             printf("%d ", [cp intValue:warehouseof[s]]);
          }
          printf("\n");
          for (int s = 1; s <= ns; s++) {
             printf("%d ", [cp intValue:[supCost at: s :[cp intValue:warehouseof[s]]]]);
          }
          
          printf("\n");
          for (int w = 1; w <= nw; w++) {
             printf("%d ", [cp intValue:warehouseused[w]]);
          }
          printf("\n");
       }
       ];
      
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}
