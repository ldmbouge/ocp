/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORCrFactory.h"
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPlabel.h"

#import "objcp/CPArray.h"
#import "objcp/CPDataI.h"


/*
int main (int argc, const char * argv[])
{
   CPRange R = (CPRange){1,3};
   CPRange D = (CPRange){1,3};
   id<CP> cp = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
   id<CPIntMatrix> cost = [CPFactory intMatrix:cp range: R : R];
   id<CPIntVar> assignmentCost = [CPFactory intVar:cp domain: (CPRange){0,36}];
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
   id<CP> cp = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
   id<CPIntMatrix> cost = [CPFactory intMatrix:cp range: R : R];
   id<CPIntVar> assignmentCost = [CPFactory intVar:cp domain: (CPRange){0,100}];
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
void printCircuit(id<CPIntVarArray> x)
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
   FILE* dta = fopen("/Users/pvh/NICTA/Project/objectivecp/data/rbg040a.tw","r");
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
   id<CP> cp = [CPFactory createSolver];
   id<CPIntMatrix> cost = [CPFactory intMatrix:cp range: Cities : Cities];
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
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range: Cities domain: Cities];
   id<CPIntVar> assignmentCost = [CPFactory intVar:cp domain: (CPRange){0,10000}];
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
       [cp restart:
         ^{
            [cp limitSolutions: [nbSolutions value] in:
            ^{
//               NSLog(@"x=%@",x);
             [CPLabel array: x];
             printf("Cost: %d \n",[assignmentCost min]);
//             printCircuit(x);
            }
           ];
         }
         onRestart:
            ^{
               printf("I am restarting ... %d \n",[nbRestarts value]); [nbRestarts incr];
               [nbSolutions incr];
               id<CPSolution> solution = [cp solution];
               [cp add: [CPFactory lEqualc: assignmentCost to: [solution intValue: assignmentCost] - 1]];
               for(CPInt i = 0; i < nbCities; i++)
                  [mark set: 0 at: i];
               
               CPInt start = (int) [distr next];
               for(CPInt i = 0; i < 19; i++) {
                  [mark set: 1 at: start];
                  start = [solution intValue: [x at: start]];
               }
               for(CPInt i = 0; i < nbCities; i++) {
                  if ([mark at: i] == 0)
                     [cp add: [CPFactory equalc: [x at: i] to: [solution intValue: [x at: i]]]];
               }
            }
            isDone: ^bool() { return [nbRestarts value] >= 35; }
        ];
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

