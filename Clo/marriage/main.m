/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> mdl = [ORFactory createModel];
         enum Men   { Richard = 1,James = 2,John = 3,Hugh = 4,Greg = 5 };
         enum Women { Helen = 1,Tracy = 2, Linda = 3,Sally = 4,Wanda = 5 };
         id<ORIntRange> RMen   = RANGE(mdl,1,5);
         id<ORIntRange> RWomen = RANGE(mdl,1,5);
         ORInt  rankM[5][5] = {{5,1,2,4,3},
            {4,1,3,2,5},
            {5,3,2,4,1},
            {1,5,4,3,2},
            {4,3,2,1,5}};
         
         ORInt rankW[5][5] = {{1,2,4,3,5},
            {3,5,1,2,4},
            {5,4,2,1,3},
            {1,3,5,4,2},
            {4,2,3,5,1}};
         ORInt* rankMPtr = (ORInt*)rankM;
         ORInt* rankWPtr = (ORInt*)rankW;                     
         
         id<ORIntVarArray> husband = [ORFactory intVarArray: mdl range:RWomen domain: RMen];
         id<ORIntVarArray> wife    = [ORFactory intVarArray: mdl range:RMen domain: RWomen];
         id<ORIntArray>* rm = malloc(sizeof(id<ORIntArray>)*5);
         id<ORIntArray>* rw = malloc(sizeof(id<ORIntArray>)*5);
         for(ORInt m=RMen.low;m <= RMen.up;m++)
            rm[m] = [ORFactory intArray:mdl range:RWomen with:^ORInt(ORInt w) { return rankMPtr[(m-1) * 5 + w-1];}];
         for(ORInt w=RWomen.low;w <= RWomen.up;w++)
            rw[w] = [ORFactory intArray:mdl range:RMen with:^ORInt(ORInt m) { return rankWPtr[(w-1) * 5 + m-1];}];
         for(ORInt i=RMen.low;i <= RMen.up;i++)
            [mdl add: [[husband elt: wife[i]] eq: @(i)]];
         for(ORInt i=RWomen.low;i <= RWomen.up;i++)
            [mdl add: [[wife elt: husband[i]] eq: @(i)]];
         
         for(ORInt m=RMen.low;m <= RMen.up;m++) {
            for(ORInt w=RWomen.low;w <= RWomen.up;w++) {
               [mdl add: [[[rm[m] elt:wife[m]] gt: @([rm[m] at:w])] imply: [[rw[w] elt:husband[w]] lt: @([rw[w] at:m])]]];
               [mdl add: [[[rw[w] elt:husband[w]] gt: @([rw[w] at:m])] imply: [[rm[m] elt:wife[m]] lt: @([rm[m] at:w])]]];
            }
         }
         id<CPProgram> cp = [ORFactory createCPProgram:mdl];
         __block ORInt nbSolutions = 0;
         [cp solveAll:^{
            NSLog(@"Start...");
            [cp labelArray:husband orderedBy:^ORFloat(ORInt i) { return [cp domsize:husband[i]];}];
            [cp labelArray:wife orderedBy:^ORFloat(ORInt i) { return [cp domsize:wife[i]];}];
            nbSolutions++;
            NSLog(@"Solution: H:%@",[cp gamma][husband.getId]);
            NSLog(@"Solution: W:%@",[cp gamma][wife.getId]);
         }];
         NSLog(@"#solutions: %d",nbSolutions);
         NSLog(@"Solver: %@",cp);
         struct ORResult r = REPORT(nbSolutions, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}
