/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

#import "ORLagrangeRelax.h"
#import "ORLagrangianTransform.h"
#import <ORModeling/ORLinearize.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         
         id<ORModel> model = [ORFactory createModel];
         const char* fn = "market.dta";
         FILE* dta = fopen(fn,"r");
         int n,m,z;
         fscanf(dta, "%d %d %d",&m,&n,&z);
         NSLog(@"m: %i, n: %i", m, n);
         id<ORIntRange> V = RANGE(model,0,n-1);
         int** w = alloca(sizeof(int*)*m);
         for(int k=0;k<m;k++)
            w[k] = alloca(sizeof(int)*n);
         
         int* rhs = alloca(sizeof(int)*m);
         for(int i=0;i<m;i++) {
            for(int j=0;j<n;j++)
               fscanf(dta,"%d ",w[i]+j);
            fscanf(dta,"%d ",rhs+i);
         }
         
         for(int i=0;i<m;i++) {
            for(int j=0;j<n;j++)
               printf("%d ",w[i][j]);
            printf(" <= %d\n",rhs[i]);
         }
         ORInt rrhs = 0;
         ORInt alpha = 1;
         ORInt* wr = malloc(sizeof(ORInt)*n);
         for(ORInt v = 0; v < n;v++) wr[v] = 0;
         for(ORInt c = 0; c < m;++c) {
            for(ORInt v = 0; v < n;v++) {
               wr[v] = wr[v] + alpha * w[c][v];
               rrhs = rrhs + alpha * rhs[c];
               alpha = alpha * 5;
            }
         }
         ORInt* tw = malloc(sizeof(ORInt)*n);
         for (ORInt v=0; v < n; ++v) {
            tw[v] = 0;
            for(ORInt c =0;c < m;++c)
               tw[v] += w[c][v];
         }
         id<ORIntVarArray> x = All(model,ORIntVar, i, V, [ORFactory intVar:model domain:RANGE(model,0,1)]);
         for(int i=0;i<m;i++) {
            id<ORIntArray> coef = [ORFactory intArray:model range:V with:^ORInt(ORInt j) { return w[i][j];}];
            id<ORIntVar>   r = [ORFactory intVar:model domain:RANGE(model,rhs[i],rhs[i])];
            [model add:[ORFactory knapsack:x weight:coef capacity:r]];
         }
         
         //id<ORModel> lm = [ORFactory linearizeModel: model];
         ORLagrangianTransform* t = [[ORLagrangianTransform alloc] init];
         id<ORParameterizedModel> lagrangeModel = [t apply: model relaxing: [model constraints]];
         id<ORRunnable> lr = [[ORLagrangeRelax alloc] initWithModel: lagrangeModel];
         [lr run];

          /*
         id<CPProgram> cp  = [args makeProgram:model];
         //id<CPHeuristic> h = [args makeHeuristic:cp restricted:m];
         
         [cp solve: ^{
            [cp forall: V suchThat:^bool(ORInt i) { return ![cp bound:x[i]];}  orderedBy:^ORInt(ORInt i) { return -tw[i];} do:^(ORInt i) {
               [cp try:^{
                  [cp label:x[i] with:0];
               } or:^{
                  [cp label:x[i] with:1];
               }];
            }];
            NSLog(@"Solution: %@",x);
         }];
         id<ORSolution> best = [[cp solutionPool] best];
           */
         id<ORSolution> best = [lr bestSolution];
         
         for(int k=0;k < m;k++) {
            ORInt sum = 0;
            for(ORInt i=V.low;i <= V.up;++i)
               sum += w[k][i] * [best intValue:x[i]];
            NSLog(@"got: %d == %d",sum,rhs[k]);
            assert(sum == rhs[k]);
         }
         struct ORResult r;
         return r;
         //NSLog(@"Solver: %@",cp);
         //struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         //[cp release];
         [ORFactory shutdown];
         //return r;
      }];
   }
   return 0;
}
