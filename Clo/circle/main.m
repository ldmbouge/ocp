/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
         id<ORRealVarArray> a = [ORFactory realVarArray:model range:RANGE(model,0,1) low:-1000.0 up:1000.0];
         id<ORRealVar> x = a[0];
         id<ORRealVar> y = a[1];
         [model add:[[[x square] plus:[y square]] eq:@1]];
         [model add:[[x square] eq:y]];
         
         id<CPProgram> cp = [args makeProgram:model];
         __block ORInt nbSol = 0;
         [cp solveAll:^{
            NSLog(@"Starting...");
            NSLog(@"X = %@",cp.gamma[x.getId]);
            NSLog(@"Y = %@",cp.gamma[y.getId]);
            NSLog(@"MODEL is: %@",cp.engine.model);
            id<ORSelect> select = [ORFactory select: cp
                                              range: a.range
                                           suchThat: ^ORBool(ORInt i)    { return ![cp bound:a[i]]; }
                                          orderedBy:^ORDouble(ORInt i) { return [cp domwidth:a[i]];} ];
            do {
               ORInt i = [select min];
               if (i == MAXINT)
                  break;               
               ORDouble mid = [cp doubleMin:a[i]] + ([cp doubleMax:a[i]] - [cp doubleMin:a[i]])/2.0;
               [cp try:^{
                  [cp realLthen:a[i] with:mid];
               } alt:^{
                  [cp realGthen:a[i] with:mid];
               }];
            } while (true);
            nbSol++;
         }];
         [[cp solutionPool] enumerateWith:^(id<ORSolution> sol) {
            printf("[x,y] = [");
            for(ORInt i = a.low; i <= a.up; i++)
               printf("%f%c",[sol doubleValue: a[i]],((i < a.up) ? ',' : ']'));
            printf("\n");
         }];
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return res;
      }];
   }
   return 0;
}

