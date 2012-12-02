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
   ORInt n = 20;
   id<ORIntRange> R = RANGE(model,1,n);
   
   id<ORUniformDistribution> distr = [CPFactory uniformDistribution: model range: RANGE(model, 1, 20)];
   id<ORIntArray> cost =[ORFactory intArray: model range: R range: R with: ^ORInt (ORInt i, ORInt j) { return [distr next]; }];
   
   //id<ORInteger> nbSolutions = [ORFactory integer: model value: 0];
   
   id<ORIntVarArray> tasks  = [ORFactory intVarArray: model range: R domain: R];
   id<ORIntVar> assignCost = [ORFactory intVar: model domain: RANGE(model, 20, 20 * n)];
   
   [model minimize: assignCost];
   [model add: [ORFactory alldifferent: tasks]];
   [model add: [assignCost eq: Sum(model, i, R, [cost elt: [tasks[i] plusi:(i-1)*n -  1]])]];
    
    id<ORModelTransformation> linearizer = [[ORLinearize alloc] initORLinearize];
    ORBatchModel* lm = [[ORBatchModel alloc] init: model];
    [linearizer apply: model into: lm];
    
    id<CPProgram> cp = [ORFactory createCPProgram: model];
    id<CPHeuristic> h = [ORFactory createFF: cp];
   [cp solve:
    ^() {
       [cp labelHeuristic: h];
    }];
   NSLog(@"solution: %@", [tasks description]);
   
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

