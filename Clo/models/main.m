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

         ORInt n = 6;
         id<ORIntRange> R = RANGE(model,1,n);
         id<ORUniformDistribution> distr = [ORFactory uniformDistribution: model range: RANGE(model, 1, 20)];
         id<ORIntArray> cost =[ORFactory intArray: model range: R range: R with: ^ORInt (ORInt i, ORInt j) { return [distr next]; }];
         id<ORIntVarArray> tasks = [ORFactory intVarArray: model range: R domain: R];
         id<ORIntVar> assignCost = [ORFactory intVar: model domain: RANGE(model, n, n * 20)];
         
         [model minimize: assignCost];
         [model add: [ORFactory alldifferent: tasks]];
         [model add: [assignCost eq: Sum(model, i, R, [cost elt: [tasks[i] plusi:(i-1)*n -  1]])]];
         
         id<ORModel> m0 = [model copy];
         id<ORModel> cm = [m0 flatten];
         NSLog(@"Initial: %@",model);
         id<CPProgram> cp1 = [ORFactory createCPProgram:model];

         NSLog(@"clone  : %@",cm);

         
         id<CPProgram> cp2 = [ORFactory concretizeCP:cm];
         [cp2 solve:^{
            [cp2 labelArray:tasks];
            id<ORIntArray> ts = [ORFactory intArray:cp2 range:tasks.range with:^ORInt(ORInt i) {
               return [cp2 intValue:tasks[i]];
            }];
            NSLog(@"SOL:%@   \tobjective: %d",ts,[cp2 intValue:assignCost]);
         }];
         
         struct ORResult res = REPORT(1, [[cp1 explorer] nbFailures], [[cp1 explorer] nbChoices], [[cp1 engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

