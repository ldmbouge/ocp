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

#import <ORProgram/ORLagrangeRelax.h>
#import <ORProgram/ORLagrangianTransform.h>
#import <ORModeling/ORLinearize.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         int n = 20;
         int m = 4;
         double p = 0.6;
         const int MAX_DMD = 99;
         int** w = alloca(sizeof(int*)*m);
         for(int k=0;k<m;k++)
            w[k] = alloca(sizeof(int)*n);
         printf("(retailers) x (prod. demand)\n");
         for(int i=0;i<m;i++) {
            for(int j=0;j<n;j++) {
               w[i][j] = (arc4random() % MAX_DMD) + 1;
               printf("%i ", w[i][j]);
            }
            printf("\n");
         }
         printf("\n");
         
         int d[m];
         printf("\n ideal split: \n");
         for(int i=0;i<m;i++) {
            int sum = 0;
            for(int j=0;j<n;j++) sum += w[i][j];
            d[i] = (int)(sum * p);
            printf("%i ", d[i]);
         }
         printf("\n\n");
         
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> V = RANGE(model, 0, n-1);
         id<ORIntRange> M = RANGE(model, 0, m);
         id<ORIntRange> D = RANGE(model, 0, MAX_DMD-m);
         id<ORIntVarArray> x = All(model,ORIntVar, i, V, [ORFactory intVar:model domain:RANGE(model,0,1)]);
         id<ORIntVarArray> alpha = All(model, ORIntVar, i, M, [ORFactory intVar:model domain: D]);
         id<ORIntVarArray> beta = All(model, ORIntVar, i, M, [ORFactory intVar:model domain: D]);
         id<ORIntVarArray> s = All(model, ORIntVar, i, M, [ORFactory intVar:model domain: RANGE(model, 0, 2*MAX_DMD)]);

         for(int i=0;i<m;i++) {
            id<ORIntArray> coef = [ORFactory intArray:model range:V with:^ORInt(ORInt j) { return w[i][j];}];
            id<ORIntVar>   r = [ORFactory intVar:model domain:RANGE(model,0,2*MAX_DMD)];
            [model add: [r eq: [[@(d[i]) plus: [alpha at: i]] sub: [beta at: i]]]];
            [model add: [[s at: i] eq: [[alpha at: i] plus: [beta at: i]]]];
            [model add:[ORFactory knapsack:x weight:coef capacity:r]];
         }
         [model minimize: Sum(model, i, M, [s at: i])];
         
         //id<ORModel> lm = [ORFactory linearizeModel: model];
         //ORLagrangianTransform* t = [[ORLagrangianTransform alloc] init];
         //id<ORParameterizedModel> lagrangeModel = [t apply: model relaxing: [model constraints]];
         //id<ORRunnable> lr = [[ORLagrangeRelax alloc] initWithModel: lagrangeModel];
         //[lr run];
         id<CPProgram> cp = [ORFactory createCPProgram: model];
         id<CPHeuristic> h = [cp createABS];
         [cp solve:^{
            [cp labelHeuristic: h];
         }];
         
         //id<ORSolution> best = [lr bestSolution];
         
         id<ORSolution> best = [[cp solutionPool] best];
         for(int k=0;k < m;k++) {
            ORInt sum = 0;
            for(ORInt i=V.low;i <= V.up;++i)
               sum += w[k][i] * [best intValue:x[i]];
            printf("%i\n", sum);
            //NSLog(@"got: %d == %d",sum,rhs[k]);
            //assert(sum == rhs[k]);
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
