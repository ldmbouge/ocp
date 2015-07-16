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

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> mdl = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntRange> D = RANGE(mdl,1,9);
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range:D domain:D];
         [mdl add:[[[[[x[1] plus: [[x[2] mul:@13] div:x[3]]] plus: x[4]] plus:
                    [[[x[5] mul:@(12)] sub:x[6]] sub:@(11)]] plus:
                    [[x[7] mul:[x[8] div: x[9]]] sub:@10]] eq:@(66)]];
         [mdl add:[ORFactory alldifferent:x]];
         id<ORMutableInteger> nbSolutions = [ORFactory mutable:mdl value:0];
         
         NSLog(@"MODEL = %@\n",mdl);
         id<CPProgram> cp =  [args makeProgram:mdl annotation:notes];
         __block ORInt nbs = 0;
         [cp solveAll:^{
            [cp labelArray:x];
            id<ORIntArray> s = [ORFactory intArray:cp range:D with:^ORInt(ORInt i) {
               return [cp intValue:x[i]];
            }];
            ORInt v = [s at:1] + ([s at:2]*13)/ [s at:3] + [s at:4] +[s at:5]*12 - [s at:6] - 11 + [s at:7] * ([s at:8] / [s at:9]) - 10;
            assert(v== 66);
            [nbSolutions incr:cp];
            nbs++;
         }];
         NSLog(@"#solutions: %d - %d",[cp intValue:nbSolutions],nbs);
         NSLog(@"Solver: %@",cp);
         struct ORResult res = REPORT(nbs, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
        [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}
