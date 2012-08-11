/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFoundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPlabel.h"
#import "objcp/CPController.h"
#import "objcp/CPLimit.h"

#import "objcp/CPArray.h"



/*
int main (int argc, const char * argv[])
{
   CPRange R = (CPRange){1,3};
   CPRange D = (CPRange){1,3};
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
   id<ORIntMatrix> cost = [CPFactory intMatrix:cp range: R : R];
   id<ORIntVar> assignmentCost = [CPFactory intVar:cp domain: (CPRange){0,36}];
   [cost set: 10 at: 1 : 1];
   [cost set: 15 at: 1 : 2];
   [cost set: 11 at: 1 : 3];
   [cost set: 8  at: 2 : 1];
   [cost set: 17 at: 2 : 2];
   [cost set: 7  at: 2 : 3];
   [cost set: 14 at: 3 : 1];
   [cost set: 21 at: 3 : 2];
   [cost set: 16 at: 3 : 3];
   
   for(CPInt i = 1; i <= 3; i++) {
      for(CPInt j = 1; j <= 3; j++)
         printf("%2d ",[cost at: i : j ]);
      printf("\n");
   }
   
   [cp solveAll: 
    ^() {
       //        [cp diff: [x at: 2] with: 2];
       [cp add: [CPFactory alldifferent: x]];
       [cp add: [CPFactory assignment: x matrix: cost cost:assignmentCost]];
    }
          using:
    ^() {        
       [CPLabel array: x];
       for(CPInt i = 1; i <= 3; i++)
          printf("%d ",[[x at: i] min]);
       printf("\n");
       CPInt acost = 0;
       for(CPInt i = 1; i <= 3; i++)
          acost += [cost at: i : [[x at: i] min]];
       printf("Cost: %d \n",acost);
       printf("Cost: %d \n",[assignmentCost min]);
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;
}
*/

/*
int main (int argc, const char * argv[])
{
   CPRange R = (CPRange){1,3};
   CPRange D = (CPRange){1,3};
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
   id<ORIntMatrix> cost = [CPFactory intMatrix:cp range: R : R];
   id<ORIntVar> assignmentCost = [CPFactory intVar:cp domain: (CPRange){0,100}];
   [cost set: 10 at: 1 : 1];
   [cost set: 15 at: 1 : 2];
   [cost set: 11 at: 1 : 3];
   [cost set: 8  at: 2 : 1];
   [cost set: 17 at: 2 : 2];
   [cost set: 7  at: 2 : 3];
   [cost set: 14 at: 3 : 1];
   [cost set: 21 at: 3 : 2];
   [cost set: 16 at: 3 : 3];
   
   for(CPInt i = 1; i <= 3; i++) {
      for(CPInt j = 1; j <= 3; j++)
         printf("%2d ",[cost at: i : j ]);
      printf("\n");
   }
   
   [cp minimize: assignmentCost subjectTo:
    ^ {
       //        [cp diff: [x at: 2] with: 2];
       [cp add: [CPFactory alldifferent: x]];
       [cp add: [CPFactory assignment: x matrix: cost cost:assignmentCost]];
    }
          using:
    ^{        
       [CPLabel array: x];
       for(CPInt i = 1; i <= 3; i++)
          printf("%d ",[[x at: i] min]);
       printf("\n");
       CPInt acost = 0;
       for(CPInt i = 1; i <= 3; i++)
          acost += [cost at: i : [[x at: i] min]];
       printf("Cost: %d \n",acost);
       printf("Cost: %d \n",[assignmentCost min]);
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;
}
*/
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
   FILE* dta = fopen("rbg040a.tw","r");
   CPInt nbCities;
   CPInt tmp;
   fscanf(dta, "%d",&nbCities);
   printf("NbCities: %d \n",nbCities);
   for(CPInt i = 0; i < nbCities; i++) {
      fscanf(dta, "%d",&tmp);
      fscanf(dta, "%d",&tmp);
      fscanf(dta, "%d",&tmp);
   }
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> Cities = RANGE(cp,0,nbCities-1);

   id<ORIntMatrix> cost = [CPFactory intMatrix:cp range: Cities : Cities];
   for(CPInt i = 0; i < nbCities; i++) {
      for(CPInt j = 0; j < nbCities; j++) {
         fscanf(dta, "%d",&tmp);
         [cost set: tmp at: i : j ];
      }
   }
   for(CPInt i = 0; i < nbCities; i++) {
      for(CPInt j = 0; j < nbCities; j++) 
         printf("%2d ",[cost at: i : j ]);
      printf("\n");
   }
   id<CPUniformDistribution> distr = [CPFactory uniformDistribution: cp range: Cities];
      
   id<CPInteger> nbRestarts = [CPFactory integer: cp value:0];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value:1];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range: Cities domain: Cities];
   id<ORIntVar> assignmentCost = [CPFactory intVar:cp bounds: RANGE(cp,0,10000)];
   id<CPTRIntArray> mark = [CPFactory TRIntArray:cp range: Cities];
   
   for(CPInt i = 0; i < nbCities; i++)
      [cp add: [CPFactory notEqualc: x[i] to: i]];
   [cp add: [CPFactory alldifferent: x]];
   [cp add: [CPFactory circuit: x]];
   [cp add: [CPFactory assignment: x matrix: cost cost:assignmentCost]];

   [cp minimize: assignmentCost ];
   [cp solve: ^{
       [cp limitCondition: ^bool() { return [nbRestarts value] >= 30; } in:
        ^{
           [cp repeat:
            ^{
               [cp limitFailures: 100 in:
                ^{
                  [CPLabel array: x];
                   printf("Cost: %d \n",[assignmentCost min]);
                }
                ];
            }
            onRepeat:
               ^{
                  printf("I am restarting ... %d \n",[nbRestarts value]); [nbRestarts incr];
                  [nbSolutions incr];
                  id<ORSolution> solution = [cp solution];
                  for(CPInt i = 0; i < nbCities; i++)
                     [mark set: 0 at: i];
                  
                  CPInt start = (int) [distr next];
                  for(CPInt i = 0; i < 19; i++) {
                     [mark set: 1 at: start];
                     start = [solution intValue: [x at: start]];
                  }
                  for(CPInt i = 0; i < nbCities; i++) {
                     if ([mark at: i] == 0)
                        [cp label: [x at: i] with: [solution intValue: [x at: i]]];
                  }
               }
            ];
        }
        ];
    }
    ];
   id<ORSolution> solution = [cp solution];
   CPInt start = (int) [distr next];
   for(CPInt i = 0; i < 10; i++) {
      printf("%d->",start);
      start = [solution intValue: [x at: start]];
   }
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];

   return 0;
}


/*
int main (int argc, const char * argv[])
{
   FILE* dta = fopen("/Users/ldm/work/langExp/benchdata/ATSPTW/rbg040a.tw","r");
   CPInt nbCities;
   CPInt tmp;
   fscanf(dta, "%d",&nbCities);
   printf("NbCities: %d \n",nbCities);
   for(CPInt i = 0; i < nbCities; i++) {
      fscanf(dta, "%d",&tmp);
      fscanf(dta, "%d",&tmp);
      fscanf(dta, "%d",&tmp);
   }
   CPRange Cities = (CPRange){0,nbCities-1};
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntMatrix> cost = [CPFactory intMatrix:cp range: Cities : Cities];
   for(CPInt i = 0; i < nbCities; i++) {
      for(CPInt j = 0; j < nbCities; j++) {
         fscanf(dta, "%d",&tmp);
         [cost set: tmp at: i : j ];
      }
   }
   for(CPInt i = 0; i < nbCities; i++) {
      for(CPInt j = 0; j < nbCities; j++)
         printf("%2d ",[cost at: i : j ]);
      printf("\n");
   }
   id<CPUniformDistribution> distr = [CPFactory uniformDistribution: cp range: Cities];
   
   id<CPInteger> nbRestarts = [CPFactory integer: cp value:0];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value:1];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range: Cities domain: Cities];
   id<ORIntVar> assignmentCost = [CPFactory intVar:cp domain: (CPRange){0,10000}];
   id<CPTRIntArray> mark = [CPFactory TRIntArray:cp range: Cities];
   [cp minimize: assignmentCost subjectTo:
    ^{
       for(CPInt i = 0; i < nbCities; i++)
          [cp add: [CPFactory notEqualc: [x at: i] to: i]];
       [cp add: [CPFactory alldifferent: x]];
       [cp add: [CPFactory circuit: x]];
       [cp add: [CPFactory assignment: x matrix: cost cost:assignmentCost]];
    }
          using:
    ^{
       [cp lthen: assignmentCost with: 166];
//         [CPLabel array: x];
         printf("Cost: %d \n",[assignmentCost min]);
//         [cp add: assignmentCost leqi: 163];
//         printf("Cost: %d \n",[assignmentCost min]);
                   //             printCircuit(x);
    }
    ];
                
   id<CPSolution> solution = [cp solution];
   CPInt start = (int) [distr next];
   for(CPInt i = 0; i < 10; i++) {
      printf("%d->",start);
      start = [solution intValue: [x at: start]];
   }
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   
   return 0;
}
*/
