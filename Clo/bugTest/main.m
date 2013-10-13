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
      const ORInt no = 9; // number of orders
      const ORInt nst = 3; // number of slab types
      
      
      ORInt osz[no] = {2, 3, 1, 1, 1, 1, 1, 2, 1};
      ORInt szs[nst] = {1, 3, 4};
      
      id<ORIntArray> sizes = [ORFactory intArray:mdl range:RANGE(mdl, 1, nst) values:szs];
      id<ORIntArray> sizeOfOrder = [ORFactory intArray:mdl range:RANGE(mdl, 1, no) values:osz];
      id<ORIntVarArray> slabOfOrder = [ORFactory intVarArray:mdl range:RANGE(mdl, 1, 9) domain:RANGE(mdl, 1, 3)];
      id<ORIntVarArray> isCounted = [ORFactory intVarArray:mdl range:RANGE(mdl, 1, 9) domain:RANGE(mdl, 0, 1)];
      
      int lowerbound = 0;
      for (int o = 0; o < 9; o++) {
         lowerbound += osz[o];
      }
      id<ORIntVar> totcap = [ORFactory intVar:mdl domain:RANGE(mdl, 1, 1000)];
      
      id<ORIntVarMatrix> overlap = [ORFactory intVarMatrix:mdl range:RANGE(mdl, 1, no) :RANGE(mdl, 1, no) domain:RANGE(mdl, 0, 1)];
      
      for (int o = 1; o <= 9; o++) {
         [mdl add:[[sizes elt: slabOfOrder[o]] geq:@([sizeOfOrder at:o])]]; // this seems to work
         //            [[sizes elt: slabOfOrder[o]] gt:@(sizeOfOrder[o])]; // this doesn't work. why?
      }
      
      for (int o = 1; o <= 9; o++)
          [mdl add:[[overlap at:o :o] eq:@(1)]];
      
      for (int o = 1; o <= no; o++) {
         for (int i = 1; i <= no; i++) {
            [mdl add:[[overlap at:o :i] eq:   [overlap at:i :o]]];
            [mdl add:[[overlap at:o :i] imply:[slabOfOrder[o] eq:slabOfOrder[i]] ] ];
            [mdl add:[[overlap at:o :i] imply:[Sum(mdl,j,RANGE(mdl,1, no),[[overlap at:o :j] mul:@([sizeOfOrder at:j])])
                                                     leq:[sizes elt: slabOfOrder[o]]]]
                      ];
            
//            [mdl add:[[overlap at:o :i] imply:[[
//                                                [overlap at:i :o] and: [slabOfOrder[o] eq:slabOfOrder[i]]
//                                               ]
//                                               and: [Sum(mdl,j,RANGE(mdl,1, no),[[overlap at:o :j] mul:@([sizeOfOrder at:j])])
//                                                     leq:[sizes elt: slabOfOrder[o]]]]
//                      ]];
         }
      }
      
      [mdl add:[[isCounted at:1] eq:@(0)]];
      for (int r = 2; r <= no; r++) {
         [mdl add:[[isCounted at:r] eq:[Sum(mdl, c, RANGE(mdl, 1, r-1), [overlap at:r :c]) gt:@(0)]]]; // this is not counting right (for example for 5)
//         [mdl add:[[isCounted at:r] eq:[Sum(mdl, c, RANGE(mdl, 1, r-1), [overlap at:r :c]) neq:@(0)]]]; // this gives different result than above, still not counting right though
      }
      
      [mdl add:[totcap eq: Sum(mdl, o, RANGE(mdl, 1, 9), [[sizes elt: slabOfOrder[o]] mul:[isCounted[o] neg]])]];
      //        [mdl add:[totcap eq: Sum(mdl, o, RANGE(mdl, 1, 9), [[sizes elt: slabOfOrder[o]] mul:[[isCounted at:o] eq:@(0)]])]]; // this crashes
      [mdl minimize:totcap];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id* gamma = [cp gamma];
      [cp solve:
       ^() {
          //[cp label:totcap];
          [cp labelArray:slabOfOrder];
          [cp labelArray:isCounted];
          for (int r = 1; r <= no; r++) {
             for (int c = 1; c <= no; c++) {
                [cp label: [overlap at:r :c]];
             }
          }
          NSLog(@"SOO: %@",[cp gamma][slabOfOrder.getId]);
          printf("Total cap: %d \n", [cp intValue:totcap]);
          printf("   ");
          for (int c = 1; c <= no; c++) {
             printf("%d ", c);
          }
          printf("\n");
          for (int r = 1; r <= no; r++) {
             printf("%d: ", r);
             for (int c = 1; c <= no; c++) {
                printf("%d ", [cp intValue:[overlap at:r :c]]);
             }
             printf("\n");
          }
          
          for (int o = 1; o <= no; o++) {
             printf("%d: %d %d %d\n", o, [sizes at:[cp intValue:slabOfOrder[o]]], [cp intValue:isCounted[o]],![cp intValue:isCounted[o]]);
          }
          
       }
       ];
      
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}
