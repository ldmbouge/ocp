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
         id<ORModel> model = [ORFactory createModel];
         ORInt   s    = 112;
         id<ORIntRange> sidel = RANGE(model,1,s);
         id<ORIntRange> square = RANGE(model,0,20);
         ORInt* side = (ORInt[]){50,42,37,35,33,29,27,25,24,19,18,17,16,15,11,9,8,7,6,4,2};
         
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:square domain:sidel];
         id<ORIntVarArray> y = [ORFactory intVarArray:model range:square domain:sidel];
         [square enumerateWithBlock:^(ORInt i) {
            [model add:[x[i] leq:@(s - side[i] + 1)]];
            [model add:[y[i] leq:@(s - side[i] + 1)]];
         }];
         [square enumerateWithBlock:^(ORInt i) {
            [square enumerateWithBlock:^(ORInt j) {
               if (i < j) {
                  [model add: [[[[[x[i] plus:@(side[i])] leq:x[j]]  lor:
                                 [[x[j] plus:@(side[j])] leq:x[i]]] lor:
                                [[y[i] plus:@(side[i])] leq:y[j]]] lor:
                               [[y[j] plus:@(side[j])] leq:y[i]]]];
               }
            }];
         }];
         [sidel enumerateWithBlock:^(ORInt k) {
            [model add:[Sum(model, i, square, [[[x[i] leq:@(k)] land:[x[i] geq:@(k - side[i] + 1)]] mul:@(side[i])]) eq:@(s)]];
            [model add:[Sum(model, i, square, [[[y[i] leq:@(k)] land:[y[i] geq:@(k - side[i] + 1)]] mul:@(side[i])]) eq:@(s)]];
         }
          ];
         id<CPProgram> cp  = [args makeProgram:model];
         [cp solveAll:^{
            [sidel enumerateWithBlock:^(ORInt p) {
               [square enumerateWithBlock:^(ORInt i) {
                  [cp try:^{
                     [cp label:x[i] with:p];
                  } alt:^{
                     [cp diff:x[i] with:p];
                  }];
               }];
            }];
            [sidel enumerateWithBlock:^(ORInt p) {
               [square enumerateWithBlock:^(ORInt i) {
                  [cp try:^{
                     [cp label:y[i] with:p];
                  } alt:^{
                     [cp diff:y[i] with:p];
                  }];
               }];
            }];
            id<ORIntArray> xs = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) { return [cp intValue:x[i]];}];
            id<ORIntArray> ys = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) { return [cp intValue:y[i]];}];
            NSLog(@"x = %@",xs);
            NSLog(@"y = %@",ys);
            
         }];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}


