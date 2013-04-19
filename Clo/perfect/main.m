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
                  [model add: [[[[[x[i] plus:@(side[i])] leq:x[j]]  or:
                                 [[x[j] plus:@(side[j])] leq:x[i]]] or:
                                 [[y[i] plus:@(side[i])] leq:y[j]]] or:
                                 [[y[j] plus:@(side[j])] leq:y[i]]]];
               }
            }];
         }];
         [sidel enumerateWithBlock:^(ORInt k) {
            [model add:[Sum(model, i, square, [[[x[i] leq:@(k)] and:[x[i] geq:@(k - side[i] + 1)]] mul:@(side[i])]) eq:@(s)]];
            [model add:[Sum(model, i, square, [[[y[i] leq:@(k)] and:[y[i] geq:@(k - side[i] + 1)]] mul:@(side[i])]) eq:@(s)]];
         }
         ];
         //NSLog(@"model: %@",model);
         id<CPProgram> cp  = [args makeProgram:model];
         //id<CPHeuristic> h = [args makeHeuristic:cp restricted:m];
         [cp solveAll:^{
            id<ORBasicModel> bm = [[cp engine] model];
            NSLog(@"start(x)  %ld %ld %ld",[[bm variables] count],[[bm objects] count],[[bm constraints] count]);
            [sidel enumerateWithBlock:^(ORInt p) {
               [square enumerateWithBlock:^(ORInt i) {
                  [cp try:^{
                     [cp label:x[i] with:p];
                  } or:^{
                     [cp diff:x[i] with:p];
                  }];
               }];
            }];
            [sidel enumerateWithBlock:^(ORInt p) {
               [square enumerateWithBlock:^(ORInt i) {
                  [cp try:^{
                     [cp label:y[i] with:p];
                  } or:^{
                     [cp diff:y[i] with:p];
                  }];
               }];
            }];
            id<ORIntArray> xs = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) { return [x[i] value];}];
            id<ORIntArray> ys = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) { return [y[i] value];}];
            NSLog(@"x = %@",xs);
            NSLog(@"y = %@",ys);

         }];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}

