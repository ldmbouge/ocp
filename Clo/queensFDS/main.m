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
//         ORInt n = [args size];
         ORInt n = 8;
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
         id<ORAnnotation> note = [ORFactory annotation];
         [note dc:[mdl add: [ORFactory alldifferent: x]]];
         [note vc:[mdl add: [ORFactory alldifferent: All(mdl, ORExpr, i, R, [x[i] plus:@(i)])]]];
         [note vc:[mdl add: [ORFactory alldifferent: All(mdl, ORExpr, i, R, [x[i]  sub:@(i)])]]];
         id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl annotation:note with:[ORSemDFSController proto]];
         id<CPHeuristic> h = [cp createFDS];
         [cp clearOnSolution];     // do not save the solutions (the other solvers do not).
         __block ORInt nbSol = 0;
         [cp solveAll:
          ^() {
             [cp splitArray:x];
//             id<CPIntVarArray> cx = [cp concretize:x];
//             while (![cp allBound:x]) {
//                ORDouble ld = FDMAXINT;
//                ORInt bi = R.low - 1;
//                for(ORInt i=R.low;i <= R.up;i++) {
//                   if ([cp bound:x[i]]) continue;
//                   ORDouble ds =[h varOrdering:cx[i]];
//                   ld = ld < ds ? ld : ds;
//                   if (ld == ds) bi = i;
//                }
//                ORInt lb = [cp min:x[bi]], ub = [cp max:x[bi]];
//                ORInt mp = lb + (ub - lb)/2;
//                [cp try: ^ {
//                   [cp lthen:x[bi] with:mp+1];
//                }
//                    alt: ^{
//                   [cp gthen:x[bi] with:mp];
//                }];
//             }
             
             //[cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return [cp domsize: x[i]];}];
             printf("sol %d [",nbSol);
             for(ORInt i=1;i<= n;i++)
                printf("%d%c",[cp intValue:x[i]],i<n ? ',' : ' ');
             printf("]\n");
             
             @synchronized(cp) { // synchronized so that it works correctly even when asking parallel tree search
                nbSol++;
             }
          }];
         printf("GOT %d solutions\n",nbSol);
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}