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
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORIntRange> D = RANGE(mdl,0,n-1);
         id<ORIntRange> SD = RANGE(mdl,1,n-1);

         id<ORInteger> nbSolutions = [ORFactory integer: mdl value:0];
         id<ORIntVarArray> sx = [ORFactory intVarArray: mdl range:R domain: D];
         id<ORIntVarArray> dx = [ORFactory intVarArray: mdl range:SD domain: SD];

         [mdl add:[ORFactory alldifferent:sx annotation:DomainConsistency]];
         for(ORUInt i=SD.low;i<=SD.up;i++) {
            [mdl add:[dx[i] eq:[[sx[i+1] sub:sx[i]] abs]] annotation: DomainConsistency];
         }
         [mdl add:[ORFactory alldifferent:dx annotation:DomainConsistency]];
         [mdl add:[sx[1]   leq:sx[2]]];
         [mdl add:[dx[n-1] leq:dx[1]]];

         id<CPProgram> cp =  [args makeProgram:mdl];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:sx];

         [cp solve: ^{
            [cp labelHeuristic:h];
            [cp labelArray:sx orderedBy:^ORFloat(ORInt i) {
               return [[sx at:i] domsize];
            }];
            [nbSolutions incr];
            id<ORIntArray> a = [ORFactory intArray:cp range: R  with:^ORInt(ORInt i) {
               return [sx[i] value];
            }];
            NSLog(@"Solution: %@",a);
         }];
         NSLog(@"#solutions: %@",nbSolutions);
         NSLog(@"Solver: %@",cp);
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

