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
#import <objcp/CPFactory.h>

#import "ORCmdLineArgs.h"

void printCircuit(id<ORIntVarArray> x)
{
   int curr = 0;
   printf("1");
   do {
      curr = [[x at: curr] min];
      printf("->%d",curr);
   } while (curr != 0);
   printf("\n");
}

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         FILE* dta = fopen("rbg040a.tw","r");
         ORInt nbCities;
         ORInt tmp;
         fscanf(dta, "%d",&nbCities);
         printf("NbCities: %d \n",nbCities);
         for(ORInt i = 0; i < nbCities; i++) {
            fscanf(dta, "%d",&tmp);
            fscanf(dta, "%d",&tmp);
            fscanf(dta, "%d",&tmp);
         }
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> Cities = RANGE(mdl,0,nbCities-1);
         
         id<ORIntMatrix> cost = [ORFactory intMatrix:mdl range: Cities : Cities];
         for(ORInt i = 0; i < nbCities; i++) {
            for(ORInt j = 0; j < nbCities; j++) {
               fscanf(dta, "%d",&tmp);
               [cost set: tmp at: i : j ];
            }
         }
         for(ORInt i = 0; i < nbCities; i++) {
            for(ORInt j = 0; j < nbCities; j++)
               printf("%2d ",[cost at: i : j ]);
            printf("\n");
         }
         [ORStreamManager setRandomized];
         id<ORUniformDistribution> distr = [ORFactory uniformDistribution: mdl range: Cities];
         
         id<ORMutableInteger> nbRestarts = [ORFactory mutable: mdl value:0];
         id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value:1];
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: Cities domain: Cities];
         id<ORIntVar> assignmentCost = [ORFactory intVar:mdl domain: RANGE(mdl,0,10000)];
         
         for(ORInt i = 0; i < nbCities; i++)
            [mdl add: [x[i] neq: @(i)]];
         [mdl add: [ORFactory alldifferent: x]];
         [mdl add: [ORFactory circuit: x]];
         [mdl add: [ORFactory assignment: x matrix: cost cost:assignmentCost]];
         
         [mdl minimize: assignmentCost ];
         
         id<CPProgram> cp = [ORFactory createCPProgram:mdl];
         //id<ORTRIntArray> mark = [ORFactory TRIntArray:[cp engine] range: Cities];
         
         [cp solve: ^{
            [cp limitCondition: ^bool() { return [nbRestarts intValue:cp] >= 100; } in:
             ^{
                [cp repeat:
                 ^{
                    [cp limitFailures: 100 in:
                     ^{
                        [cp labelArrayFF: x];
                        [cp label:assignmentCost with:[cp min:assignmentCost]];
                        printf("Cost: %d \n",[cp intValue:assignmentCost]);
                     }
                     ];
                 }
                  onRepeat:
                 ^{
                    printf("I am restarting ... %d \n",[nbRestarts intValue:cp]); [nbRestarts incr:cp];
                    [nbSolutions incr:cp];
                    id<ORSolution> solution = [[cp solutionPool] best];
                    //for(ORInt i = 0; i < nbCities; i++)
                    //[mark set: 0 at: i];
                    NSMutableSet* all = [[NSMutableSet alloc] initWithCapacity:nbCities];
                    for(ORInt i = 0; i < nbCities; i++) [all addObject:@(i)];
                    
                    ORInt start = (int) [distr next];
                    for(ORInt i = 0; i < 19; i++) {
                       //[mark set: 1 at: start];
                       [all removeObject:@(start)];
                       start = [solution intValue: [x at: start]];
                    }
                    [all enumerateObjectsUsingBlock:^(NSNumber* i, BOOL *stop) {
                       [cp label: x[i.intValue] with: [solution intValue: x[i.intValue]]];
                    }];
                 }
                 ];
             }
             ];
         }
          ];
         id<ORSolution> solution = [[cp solutionPool] best];
         ORInt start = (int) [distr next];
         for(ORInt i = 0; i < 10; i++) {
            printf("%d->",start);
            start = [solution intValue: [x at: start]];
         }
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult r = REPORT([solution intValue:assignmentCost], [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         return r;
      }];
   }
   return 0;
}


