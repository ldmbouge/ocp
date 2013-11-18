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


int main (int argc, const char * argv[])
{
    int m = 50; // knapsacks
    int n = 120; // items
    int MAX_WGHT = 10;
    int MAX_PRFT = 15;
    int CAP_LOW = 100;
    int CAP_RNG = 500;
    unsigned int seed = 147;
    srand(seed);
    
    // Weight
    int** w = alloca(sizeof(int*)*m);
    for(int k=0;k<m;k++) w[k] = alloca(sizeof(int)*n);
    printf("weights\n");
    for(int i=0;i<m;i++) {
        for(int j=0;j<n;j++) {
            w[i][j] = (rand() % MAX_WGHT) + 1;
            printf("%i ", w[i][j]);
        }
        printf("\n");
    }
    printf("\n\n");

    // cost
    int** p = alloca(sizeof(int*)*m);
    for(int k=0;k<m;k++) p[k] = alloca(sizeof(int)*n);
    printf("profits\n");
    for(int i=0;i<m;i++) {
        for(int j=0;j<n;j++) {
            p[i][j] = (rand() % MAX_PRFT) + 1;
            printf("%i ", p[i][j]);
        }
        printf("\n");
    }
    printf("\n\n");

    // Capacity
    int* c = alloca(sizeof(int)*m);
    printf("cap\n");
    for(int i=0;i<m;i++) {
        c[i] = (rand() % CAP_RNG) + CAP_LOW;
        printf("%i ", c[i]);
    }
    printf("\n");
     
    id<ORModel> model = [ORFactory createModel];
    id<ORIntRange> M = RANGE(model, 0, m-1);
    id<ORIntRange> N = RANGE(model, 0, n-1);
    id<ORIntRange> B = RANGE(model, 0, 1);
    id<ORIntVarMatrix> x = [ORFactory intVarMatrix: model range: M : N domain: B];
    [model minimize: Sum2(model, i, M, j, N, [[x at: i : j] mul: @(p[i][j])])];
    NSMutableArray* knapsacks = [[NSMutableArray alloc] initWithCapacity: m];
    NSMutableArray* limits = [[NSMutableArray alloc] initWithCapacity: n];
    for(int i=0;i<m;i++) {
        id<ORIntArray> coef = [ORFactory intArray:model range: N with:^ORInt(ORInt j) { return w[i][j];}];
        id<ORIntVarArray> xi = [ORFactory intVarArray: model range: N with:^id<ORIntVar>(ORInt j) { return [x at: i : j]; }];
        id<ORIntVar>   cap = [ORFactory intVar:model domain:RANGE(model,0,c[i])];
        id<ORConstraint> knapsack = [ORFactory knapsack: xi weight:coef capacity:cap];
        [knapsacks addObject: knapsack];
        [model add: knapsack];
    }
    for(int j = 0; j < n; j++) {
        id<ORConstraint> c = [Sum(model, i, M, [x at: i: j]) eq: @(1)];
        [limits addObject: [model add: c]];
    }
    
    
    /*
    id<CPProgram> cp = [ORFactory createCPProgram: model];
    id<CPHeuristic> h = [cp createFF: [model intVars]];
    [cp solve:^{
        [cp labelHeuristic: h];
    }];
    
    id<ORSolution> best = [[cp solutionPool] best];
    */
     
    id<ORModel> lmodel = [ORFactory linearizeModel: model];
    ORLagrangianTransform* t = [[ORLagrangianTransform alloc] init];
    id<ORParameterizedModel> lagrangeModel = [t apply: lmodel relaxing: limits];
    id<ORRunnable> lr = [[ORLagrangeRelax alloc] initWithModel: lagrangeModel];
    [lr run];
    id<ORSolution> best = [(ORLagrangeRelax*)lr bestSolution];
    
    NSLog(@"BEST: %@", best);
    return 0;
}
