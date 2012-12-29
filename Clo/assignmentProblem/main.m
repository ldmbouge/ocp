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

int main (int argc, const char * argv[])
{
    id<ORModel> model = [ORFactory createModel];
    ORInt n = 3;
    id<ORIntRange> R = RANGE(model,1,n);
    
    id<ORUniformDistribution> distr = [CPFactory uniformDistribution: model range: RANGE(model, 1, 20)];
    id<ORIntArray> cost =[ORFactory intArray: model range: R range: R with: ^ORInt (ORInt i, ORInt j) { return [distr next]; }];
    
    //id<ORInteger> nbSolutions = [ORFactory integer: model value: 0];
    
    id<ORIntVarArray> tasks  = [ORFactory intVarArray: model range: R domain: R];
    id<ORIntVar> assignCost = [ORFactory intVar: model domain: RANGE(model, n, n * 20)];
    
    [model minimize: assignCost];
    //[model add: [tasks[1] eqi:2]];
    //[model add: [tasks[2] eqi:1]];
    //[model add: [tasks[3] eqi:3]];
   
    [model add: [ORFactory alldifferent: tasks]];
    [model add: [assignCost eq: Sum(model, i, R, [cost elt: [tasks[i] plusi:(i-1)*n -  1]])]];
    
    NSLog(@"ORIG: %@",model);
    id<ORModelTransformation> linearizer = [[ORLinearize alloc] initORLinearize];
    id<ORModel> lin = [ORFactory createModel];
    ORBatchModel* lm = [[ORBatchModel alloc] init: lin];
    [linearizer apply: model into: lm];
    NSLog(@"FLAT: %@",lin);
   
    id<CPProgram> cp = [ORFactory createCPProgram: lin];
    id<CPHeuristic> h = [ORFactory createFF: cp];
    [cp solve:
     ^() {
        NSLog(@"here...");
        [cp labelArray:tasks];
        [cp labelHeuristic: h];
        NSLog(@"better sol --------> %d",[assignCost value]);
     }];

    for(id<ORIntVar> v in [[lm model] variables])
        NSLog(@"var(%@): %i-%i", [v description], [[v domain] low], [[v domain] up]);
    NSLog(@"SOL: %@", assignCost);
   [ORFactory shutdown];
   
    //id<CPSolver> cp = [ORFactory createCPProgram: model];
    //[cp solve:
    //^() {
    //    [CPLabel array: x orderedBy: ^ORFloat(ORInt i) { return [x[i] domsize];}];
    //    [nbSolutions incr];
    // }
    // ];
    //printf("GOT %d solutions\n",[nbSolutions value]);
    //NSLog(@"Solver status: %@\n",cp);
    // NSLog(@"Quitting");
    //NSLog(@"SOLUTION IS: %@",x);
    // PVH
    //   [cp release];
    // put on the ORFactory
    //   [CPFactory shutdown];
    NSLog(@"Done");
    return 0;
}

