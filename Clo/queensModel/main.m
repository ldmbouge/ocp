/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import "ORConcretizer.h"
#import <ORModeling/ORModelTransformation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
#import "../ORProgram/ORConcretizer.h"
#import "objcp/CPSolver.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"


// PVH Need to release the CPProgram

int main (int argc, const char * argv[])
{
   ORInt n = 8;
   id<ORModel> model = [ORFactory createModel];
   
   id<ORIntRange> R = RANGE(model,1,n);
   id<ORInteger> nbSolutions = [ORFactory integer: model value: 0];
   
   id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
   id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:i]; }];
   id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:-i]; }];
   
   [model add: [ORFactory alldifferent: x]];
   [model add: [ORFactory alldifferent: xp]];
   [model add: [ORFactory alldifferent: xn]];
   
   id<CPProgram> cp = [ORFactory createCPProgram: model];
   [cp solveAll:
    ^() {
       [cp labelArray: x];
       for(int i = 1; i <= n; i++)
          printf("%d ",[x[i] value]);
       printf("\n");
//       [CPLabel array: x orderedBy: ^ORFloat(ORInt i) { return [x[i] domsize];}];
       [nbSolutions incr];
    }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   NSLog(@"SOLUTION IS: %@",x);

//    id<ORModelTransformation> linearizer = [ORFactory createLinearizer];
//    id<ORModel> linearModel = [linearizer apply: model];
//    NSLog(@"-----------------------------------------------------------------------");
//    NSLog([linearModel description]);
    
    //id<CPSolver> cp = [ORFactory createCPProgram: linearModel];
    //id<CPHeuristic> heur = [CPFactory createFF: cp];
    //[cp solveAll: ^() {
    //    [CPLabel heuristic: heur];
    //}];
    
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

