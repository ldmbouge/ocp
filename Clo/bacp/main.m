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
         id<ORIntRange> Courses = RANGE(model,0,nbCourses-1);
         id<ORIntRange> Periods = RANGE(model,1,nbPeriods);
         ORInt prerequisites[] = {7,1,8,2,8,6,10,5,11,5,11,6,12,7,13,8,13,11,14,
            3,16,9,17,10,17,11,18,10,18,11,19,8,19,11,20,9,21,10,23,17,23,18,24,13,24,
            19,26,13,26,23,30,9,32,9,33,27,34,17,35,9,35,17,35,18,37,20,37,30,37,35,38,
            33,39,35,41,9,41,17,41,18,43,20,44,16,45,38,46,37,47,42,48,34,48,35,49,30,49,
            32,50,43,51,33,53,47,54,50,55,43,55,38,56,51,57,39,57,34,58,28,59,55,61,48,
            61,55,62,31,63,48,65,59};
         const ORInt minCard = 5;
         const ORInt maxCard = 6;
         id<ORIntArray> credits = [ORFactory intArray:model
                                                array:@[@1,@3,@1,@2,@4,@4,@1,@5,@3,@4,@4,@1,@4,@1,@1,@4,@4,@4,@4,@4,@3,
                                   @3,@4,@4,@1,@3,@3,@3,@3,@3,@4,@4,@3,@4,@4,@3,@4,@3,@3,@3,@4,@2,
                                   @4,@3,@3,@4,@2,@4,@4,@4,@3,@3,@2,@4,@4,@3,@3,@3,@2,@2,@3,@4,@3,
                                   @3,@2,@2]];
         ORInt totCredit = 0;
         for(ORInt k=0;k < nbCourses;k++) totCredit += [credits at:k];
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:Courses domain:Periods];
         id<ORIntVarArray> l = [ORFactory intVarArray:model range:Periods domain:RANGE(model,0,totCredit)];
         [model minimize:[ORFactory max:model over:Periods suchThat:nil of:^id<ORExpr>(ORInt i) {return l[i];}]];
         //[model add:[[ORFactory max:model over:Periods suchThat:nil of:^id<ORExpr>(ORInt i) {return l[i];}] eq:@17]];
         [model add:[ORFactory packing:model item:x itemSize:credits load:l]];
         for(ORInt i=0;i<nbPre;i++)
            [model add:[x[prerequisites[i*2]] lt:x[prerequisites[i*2+1]]]];
         [model add:[ORFactory cardinality:x
                                       low:[ORFactory intArray:model range:Periods with:^ORInt(ORInt p) { return minCard;}]
                                        up:[ORFactory intArray:model range:Periods with:^ORInt(ORInt p) { return maxCard;}]
                                annotation:DomainConsistency]];
        
         id<CPProgram> cp = [args makeProgram:model];
         __block ORInt nbSol = 0;
         [cp solve:^{
            [cp labelArrayFF:x];
            [cp labelArrayFF:l];
            /*
            [cp forall:Courses suchThat:^bool(ORInt i) { return ![cp bound:x[i]];}
             orderedBy:^ORInt(ORInt i) { return [cp domsize:x[i]];}
                   and:^ORInt(ORInt i) { return - [credits at:i];}
                    do:^(ORInt i) {
                       [cp tryall:Periods suchThat:^bool(ORInt p) { return [cp member:p in:x[i]];}
                               in:^(ORInt i) {
                                  <#code#>
                               } onFailure:<#^(ORInt)onFailure#>]
                    }];
            */
            printf("x = [");
            for(ORInt i = x.low; i <= x.up; i++)
               printf("%d%c",[cp intValue: x[i]],((i < x.up) ? ',' : ']'));
            printf("\nl = [");
            for(ORInt i = l.low; i <= l.up; i++)
               printf("%d%c",[cp intValue: l[i]],((i < l.up) ? ',' : ']'));
            printf("\tObjective: %d\n",[[[[cp engine] objective] value] value]);
         }];
         id<ORCPSolution> sol = [[cp solutionPool] best];
         printf("x = [");
         for(ORInt i = x.low; i <= x.up; i++)
            printf("%d%c",[sol intValue: x[i]],((i < x.up) ? ',' : ']'));
         printf("\tObjective: %d\n",[[sol objectiveValue] value]);
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}
