/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>
#import <objcp/CPError.h>
#include <malloc/malloc.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> mdl = [ORFactory createModel];
         int n = [args size];
         id<ORAnnotation> notes = [ORFactory note];
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORIntRange> D = RANGE(mdl,0,n-1);
         id<ORIntRange> SD = RANGE(mdl,1,n-1);

         id<ORIntVarArray> sx = [ORFactory intVarArray: mdl range:R domain: D];
         id<ORIntVarArray> dx = [ORFactory intVarArray: mdl range:SD domain: SD];

         [notes dc:[mdl add:[ORFactory alldifferent:sx]]];
         for(ORUInt i=SD.low;i<=SD.up;i++) {
            //[mdl add:[dx[i] eq:[[sx[i] sub:sx[i+1]] abs]] annotation: DomainConsistency];
            [mdl add:[dx[i] eq:[[sx[i] sub:sx[i+1]] abs]]];
         }
         [notes dc:[mdl add:[ORFactory alldifferent:dx]]];
//         [mdl add:[sx[1]   leq:sx[2]]];
//         [mdl add:[dx[n-1] leq:dx[1]]];

         [mdl add:[sx[1] leq:sx[n]]];
         [mdl add:[dx[1] leq:dx[2]]];

         id<CPProgram> cp =  [args makeProgram:mdl annotation:notes];
//         id<CPHeuristic> h = [args makeHeuristic:cp restricted:sx];
         __block ORInt nbSolutions = 0;
         [cp solveAll: ^{
//            [cp labelHeuristic:h];
//            [cp labelArrayFF:sx];
//            [cp labelArray:sx orderedBy:^ORFloat(ORInt i) {
//               return [cp domsize:sx[i]];
//            }];
            while(true) {
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
               [cp tryall:D suchThat:^bool(ORInt v) { return [cp member:v in:sx[sdi]];}
                       in:^(ORInt v) {
                          [cp label:sx[sdi] with:v];
                       }];
            }
            nbSolutions++;
//            id<ORIntArray> a = [ORFactory intArray:cp range: R  with:^ORInt(ORInt i) {
//               return [cp intValue:sx[i]];
//            }];
//            NSLog(@"Solution: %@",a);
         }];
         NSLog(@"#solutions: %d",nbSolutions);
         NSLog(@"Solver: %@",cp);
         struct ORResult res = REPORT(nbSolutions, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

