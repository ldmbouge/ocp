/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         ORInt n = [args size];
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
         id<ORAnnotation> note = [ORFactory annotation];
         [note dc:[mdl add: [ORFactory alldifferent: x]]];
         [note vc:[mdl add: [ORFactory alldifferent: All(mdl, ORExpr, i, R, [x[i] plus:@(i)])]]];
         [note vc:[mdl add: [ORFactory alldifferent: All(mdl, ORExpr, i, R, [x[i]  sub:@(i)])]]];
         //id<CPProgram> cp = [args makeProgram:mdl annotation:note];
         id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemDFSController proto]];
         [cp clearOnSolution];     // do not save the solutions (the other solvers do not).
         __block ORInt nbSol = 0;
         [cp solveAll: ^ {
             
             id<ORPost> pItf = [[CPINCModel alloc] init:cp];
             [cp nestedSolveAll:^{
                [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return [cp domsize: x[i]];}];
                @synchronized(cp) { // synchronized so that it works correctly even when asking parallel tree search
                   nbSol++;
                }
             } onSolution: nil
                         onExit: nil
                        control:[[ORDFSController alloc] initTheController:[cp tracer] engine:[cp engine] posting:pItf]];

          }];
         printf("GOT %d solutions\n",nbSol);
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}