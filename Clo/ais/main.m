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
      [args measure:^struct ORResult() {
         id<ORModel> mdl = [ORFactory createModel];
         int n = [args size];
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORIntRange> D = RANGE(mdl,0,n-1);
         id<ORIntRange> SD = RANGE(mdl,1,n-1);

         id<ORIntVarArray> sx = [ORFactory intVarArray: mdl range:R domain: D];
         id<ORIntVarArray> dx = [ORFactory intVarArray: mdl range:SD domain: SD];

         [notes dc:[mdl add:[ORFactory alldifferent:sx]]];
         for(ORUInt i=SD.low;i<=SD.up;i++) {
            [notes dc:[mdl add:[dx[i] eq:[[sx[i] sub:sx[i+1]] abs]]]];
         }
         [notes dc:[mdl add:[ORFactory alldifferent:dx]]];

         [mdl add:[sx[1] leq:sx[n]]];
         [mdl add:[dx[1] leq:dx[2]]];

         id<CPProgram> cp =  [args makeProgram:mdl annotation:notes];
         __block ORInt nbSolutions = 0;
         [cp clearOnSolution]; // other solvers are not saving the solutions. So we shouldn't either.
         [cp solveAll: ^{
            while(true) {
               /**
                * Manual implementation of 'mindom' heuristic to have a deterministic 
                * tie break and be as close as possible to other solvers
                * sd is the size of the smallest domain so-far
                * sdi is the index of the first variable  in 'sx' with the smallest domain.
                */
               ORInt sd  = FDMAXINT;
               ORInt sdi = -1;
               for(ORInt i=1;i<=n;i++) {
                  if ([cp bound:sx[i]]) continue;
                  ORInt dsz = [cp domsize:sx[i]];
                  if (dsz < sd) {
                     sd = dsz;
                     sdi = i;
                  }
               }
               if (sdi == -1) break;
               [cp tryall:D suchThat:^ORBool(ORInt v) { return [cp member:v in:sx[sdi]];}
                       do:^(ORInt v) {
                          [cp label:sx[sdi] with:v];
                       }];
            }
            nbSolutions++;
         }];
         NSLog(@"#solutions: %d",nbSolutions);
         NSLog(@"Solver: %@",cp);
         struct ORResult res = REPORT(nbSolutions, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         return res;
      }];
   }
   return 0;
}
