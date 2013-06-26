/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         
         const ORInt nbCourses = 66;
         const ORInt nbPeriods = 12;
         const ORInt nbPre = 65;
         id<ORIntRange> Courses = RANGE(model,1,nbCourses);
         id<ORIntRange> Periods = RANGE(model,1,nbPeriods);
         id<ORIntRange> Prerequisites = RANGE(model,1,nbPre);
         ORInt credits[nbCourses] = {1,3,1,2,4,4,1,5,3,4,4,1,4,1,1,4,4,4,4,4,3,
            3,4,4,1,3,3,3,3,3,4,4,3,4,4,3,4,3,3,3,4,2,
            4,3,3,4,2,4,4,4,3,3,2,4,4,3,3,3,2,2,3,4,3,
            3,2,2};                  
         ORInt prerequisites[2*nbPre] = {7,1,8,2,8,6,10,5,11,5,11,6,12,7,13,8,13,11,14,
            3,16,9,17,10,17,11,18,10,18,11,19,8,19,11,20,9,21,10,23,17,23,18,24,13,24,
            19,26,13,26,23,30,9,32,9,33,27,34,17,35,9,35,17,35,18,37,20,37,30,37,35,38,
            33,39,35,41,9,41,17,41,18,43,20,44,16,45,38,46,37,47,42,48,34,48,35,49,30,49,
            32,50,43,51,33,53,47,54,50,55,43,55,38,56,51,57,39,57,34,58,28,59,55,61,48,
            61,55,62,31,63,48,65,59};
         const ORInt minCard = 5;
         const ORInt maxCard = 6;
         
         ORInt totCredit = 0;
         for(ORInt k=0;k < nbCourses;k++) totCredit += credits[k];
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:Courses domain:Periods];
         id<ORIntVarArray> l = [ORFactory intVarArray:model range:Periods domain:RANGE(model,0,totCredit)];
         [model minimize:[ORFactory max:model over:Periods suchThat:nil of:^id<ORExpr>(ORInt i) {return l[i];}]];
         /*
         subject to{
            cp.post(multiknapsack(x,credits,l));
            forall(i in Prerequisites)
            cp.post(x[prerequisites[i*2-1]]<x[prerequisites[i*2]]);
            cp.post(cardinality(all(p in Periods)(minCard),x,all(p in Periods)(maxCard)),onDomains);
         }*/
         
         id<CPProgram> cp = [args makeProgram:model];
         __block ORInt nbSol = 0;
         [cp solveAll:^{
            [cp labelArrayFF:x];
            @autoreleasepool {
               [[x range:0] enumerateWithBlock:^(ORInt i) {
                  printf("|");
                  [[x range:1] enumerateWithBlock:^(ORInt j) {
                     printf("%c",[cp intValue:[x at:i :j]] == 0 ? ' ' : '#');
                  }];
                  printf("|\n");
               }];
            }
         }];
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}
