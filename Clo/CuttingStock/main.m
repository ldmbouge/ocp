/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORConcretizer.h>
#import <objcp/CPFactory.h>
#import "../ORModeling/ORLinearize.h"
#import "../ORModeling/ORFlatten.h"
#import "ORRunnable.h"
#import "ORParallelRunnable.h"

int main (int argc, const char * argv[])
{
    id<ORModel> master = [ORFactory createModel];

    NSInteger boardWidth = 110;
    id<ORIntRange> shelves = [ORFactory intRange: master low: 0 up: 4];
    ORInt shelfValues[] = {20, 45, 50, 55, 75};
    id<ORIntArray> shelf = [ORFactory intArray: master range: shelves values: shelfValues];
    ORInt demandValues[] = {48, 35, 24, 10, 8};
    id<ORIntArray> demand = [ORFactory intArray: master range: shelves values: demandValues];
    id<ORIntArray> columns = [ORFactory intArray: master range: shelves range: shelves with:^ORInt(ORInt i, ORInt j) {
        if(i == j) return (ORInt)floor(boardWidth / [shelf at: i]);
        return 0.0;
    }];
    
    id<ORIntVarArray> cut = [ORFactory intVarArray: master range: shelves domain: RANGE(master, 0, [demand max])];
    /*
    id<ORIntVar> objSum = [ORFactory sum: master over: shelves suchThat: nil of:^id<ORExpr>(ORInt i) {
        return [cut at: i];
    }];
    
    [master minimize: objSum];
    
    model CuttingStock {
        var{int} cut[columns.range()](0..demand.max());
    objective: Minimize(sum(i in cut.range()) cut[i]);
        forall(i in shelves)
    post: Satisfy((sum(j in cut.range()) columns[j, i] * cut[j]) >= demand[i]);
    }
    
    model Knapsack {
        var{int} use[shelves](0..board_width);
        var{int} cost[shelves](-100..100);
    objective: Minimize(1 - sum(i in shelves) cost[i] * use[i]);
    post: Satisfy((sum(i in shelves) shelf[i] * use[i]) <= board_width);
    }

    
    id<ORModel> model = [ORFactory createModel];
    ORInt n = 6;
    id<ORIntRange> R = RANGE(model,1,n);
    
    id<ORUniformDistribution> distr = [CPFactory uniformDistribution: model range: RANGE(model, 1, 20)];
    id<ORIntArray> cost =[ORFactory intArray: model range: R range: R with: ^ORInt (ORInt i, ORInt j) { return [distr next]; }];
    
    //id<ORInteger> nbSolutions = [ORFactory integer: model value: 0];
    
    id<ORIntVarArray> tasks  = [ORFactory intVarArray: model range: R domain: R];
    id<ORIntVar> assignCost = [ORFactory intVar: model domain: RANGE(model, n, n * 20)];
    
    [model minimize: assignCost];
    [model add: [ORFactory alldifferent: tasks]];
    [model add: [assignCost eq: Sum(model, i, R, [cost elt: [tasks[i] plusi:(i-1)*n -  1]])]];
    
    id<ORModel> lm = [ORFactory linearizeModel: model];
    id<ORRunnable> r0 = [[CPRunnableI alloc] initWithModel: model];
    id<ORRunnable> r1 = [[CPRunnableI alloc] initWithModel: lm];
    id<ORRunnableBinaryTransform> parTran = [[ORParallelRunnableTransform alloc] init];
    id<ORRunnable> pr = [parTran apply: r0 and: r1];
    [pr run];
    
    for(id<ORIntVar> v in [lm variables])
        NSLog(@"var(%@): %i-%i", [v description], [v min], [v max]);
    NSLog(@"SOL: %@", assignCost);
    [ORFactory shutdown];
    */
    return 0;
}

