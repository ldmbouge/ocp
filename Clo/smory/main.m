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
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntRange> Digit = RANGE(model,0,9);
         id<ORIntVar> S = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> E = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> N = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> D = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> M = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> O = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> R = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> Y = [ORFactory intVar:model domain:Digit];
         id<ORIntVarArray> x = (id)[ORFactory idArray:model array:@[S,E,N,D,M,O,R,Y]];
         [model add:[ORFactory alldifferent:x]];
         [model add:[M neq:@0]];
         [model add:[S neq:@0]];
         id<ORIntArray>    c1 = [ORFactory intArray:model array:@[@1000,@100,@10,@1]];
         id<ORIntArray>    c2 = [ORFactory intArray:model array:@[@10000,@1000,@100,@10,@1]];
         id<ORIntVarArray> e1 = (id)[ORFactory idArray:model array:@[S,E,N,D]];
         id<ORIntVarArray> e2 = (id)[ORFactory idArray:model array:@[M,O,R,E]];
         id<ORIntVarArray> e3 = (id)[ORFactory idArray:model array:@[M,O,N,E,Y]];
         [model add:[[Sum(model, i, RANGE(model,0,3),[e1[i] mul:@([c1 at:i])]) plus:
                      Sum(model, i, RANGE(model,0,3),[e2[i] mul:@([c1 at:i])])] eq:
                      Sum(model, i, RANGE(model,0,4),[e3[i] mul:@([c2 at:i])])]
          ];
         
         id<CPProgram> cp = [args makeProgram:model annotation:notes];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:x];
         __block BOOL found = NO;
         [cp solveAll:^{
            NSLog(@"concrete: %@",[[cp engine] model]);
            [cp labelHeuristic:h];
            [cp labelArray:x orderedBy:^ORFloat(ORInt i) { return [cp domsize:x[i]];}];
            id<ORIntArray> sx = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) { return [cp intValue:x[i]];}];
            NSLog(@"Sol: %@",sx);
            found = YES;
         }];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(found, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

