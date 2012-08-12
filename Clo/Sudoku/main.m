/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

void show(id<ORIntVarMatrix> m) 
{
    id<ORIntRange> R = [m range: 0];
    id<ORIntRange> C = [m range: 1];
    for(ORInt i = [R low] ; i <= [R up]; i++) {
        for(ORInt j = C.low ; j <= C.up; j++) 
            printf("%d  ",[[m at: i : j] min]);
        printf("\n");   
    }
    printf("\n");
}

int main (int argc, const char * argv[])
{
   FILE* f = fopen("sudokuFile3.txt","r");
   int nb;
   int r, c, v;
   fscanf(f,"%d \n",&nb);
   printf("number of entries %d \n",nb);
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,1,9);
   id<ORIntVarMatrix> x =  [CPFactory intVarMatrix: cp range: R : R domain: R];
   id<ORIntVarArray> a = [CPFactory intVarArray: cp range: R : R with: ^id<ORIntVar>(ORInt i,ORInt j) { return [x at: i : j]; }];
   for(ORInt i = 0; i < nb; i++) {
      fscanf(f,"%d%d%d",&r,&c,&v);
      [cp label: [x at: r : c] with:v];
   }
   for(ORInt i = 1; i <= 9; i++)
      [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: R with: ^id<ORIntVar>(ORInt j) { return [x at: i : j]; }]]];
   for(ORInt j = 1; j <= 9; j++)
      [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: R with: ^id<ORIntVar>(ORInt i) { return [x at: i : j]; }]]];
   for(ORInt i = 0; i <= 2; i++)
      for(ORInt j = 0; j <= 2; j++)
         [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp
                                                            range: RANGE(cp,i*3+1,i*3+3)
                                                                 : RANGE(cp,j*3+1,j*3+3)
                                                             with: ^id<ORIntVar>(ORInt r,ORInt c) { return [x at: r : c]; }]]];
    [cp solve:
     ^() {
         [CPLabel array: a orderedBy: ^ORInt(ORInt i) { return [[a at:i] domsize];}];
         show(x);
     }
     ];
    
    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
    [cp release];
   [CPFactory shutdown];
    return 0;
}

