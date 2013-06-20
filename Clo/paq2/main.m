/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// Translation of the ESSENCE' model in the Minion Translator examples:
// http://www.cs.st-andrews.ac.uk/~andrea/examples/peacableArmyOfQueens/peaceableArmyOfQueens.eprime
// """
// Place 2 equally-sized armies of queens (white and black)
// on a chess board without attacking each other
// Maximise the size of the armies.
//
// 'occurrence' representation

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         ORInt n = [args size];
         id<ORIntRange> N  = RANGE(model,1,n);
         id<ORIntVarMatrix> board = [ORFactory intVarMatrix:model range:N :N domain:RANGE(model,0,2)];
         id<ORIntVar> nbQueens = [ORFactory intVar:model domain:RANGE(model,1,(n*n)/2)];
         
         [model add:[Sum2(model, i, N, j, N, [[board at:i :j] eq:@1]) eq: nbQueens]];
         [model add:[Sum2(model, i, N, j, N, [[board at:i :j] eq:@2]) eq: nbQueens]];
         [model maximize:nbQueens];
         id<CPProgram> cp = [args makeProgram:model];
         //id<CPHeuristic> h = [args makeHeuristic:cp restricted:nil];
         id<ORIntVarArray> x = All2(cp, ORIntVar, i, N, j, N, [board at:i :j]);
         __block ORInt nbSol = 0;
         [cp solve:^{
            for(ORInt i=1;i<=n;i++) {
               for(ORInt j=1;j<=n;j++) {
                  [cp add:[[[board at:i :j] eq:@1] guard:^{
                     for(ORInt k=1; k <= n;k++) {
                        if (k != i) [cp add:[[board at:k :j] lt:@2]];
                        if (k != j) [cp add:[[board at:i :k] lt:@2]];
                        if (i+k <=n && j+k <= n) [cp add:[[board at:i+k :j+k] lt:@2]];
                        if (i-k >0  && j-k > 0)  [cp add:[[board at:i-k :j-k] lt:@2]];
                        if (i+k <=0 && j-k > 0)  [cp add:[[board at:i+k :j-k] lt:@2]];
                        if (i-k > 0 && j+k <= n) [cp add:[[board at:i-k :j+k] lt:@2]];
                     }
                  }]];
                  [cp add:[[[board at:i :j] eq:@2] imply:
                              [ORFactory and:model over:N
                                    suchThat:nil
                                          of:^id<ORRelation>(ORInt k) {
                                             id<ORRelation> c = nil;
                                             if (k != i) c = [[[board at:k :j] neq:@1] and:c];
                                             if (k != j) c = [[[board at:i :k] neq:@1] and:c];
                                             if (i+k <=n && j+k <= n) c = [[[board at:i+k :j+k] neq:@1] and:c];
                                             if (i-k >0  && j-k > 0)  c = [[[board at:i-k :j-k] neq:@1] and:c];
                                             if (i+k <=0 && j-k > 0)  c = [[[board at:i+k :j-k] neq:@1] and:c];
                                             if (i-k > 0 && j+k <= n) c = [[[board at:i-k :j+k] neq:@1] and:c];
                                             return c;
                                          }]]];
               }
            }
            for(ORInt k=0;k <= n*n-1;k++) {
               if ([cp bound:x[k]]) continue;
               while (![cp bound:x[k]]) {
                  ORInt v = [cp max:x[k]];
                  [cp try:^{
                     [cp label:x[k] with:v];
                  } or:^{
                     [cp diff:x[k] with:v];
                  }];
               }
            }
            [cp label:nbQueens];
            //[cp labelHeuristic:h];
            nbSol++;
            @autoreleasepool {
               for(ORInt i=1;i <= n;i++) {
                  for(ORInt j=1;j <= n;j++) {
                     printf("%2d ",[cp intValue:[board at:i :j]]);
                  }
                  printf("\n");
               }
               printf("Number of queens: %d\n",[cp intValue:nbQueens]);
            }
         }];
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}