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
#import <objcp/CPError.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> mdl = [ORFactory createModel];
         int n = [args size];
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORIntRange> D = RANGE(mdl,0,1);
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range:R domain:D];
         id<CPProgram> cp =  [args makeProgram:mdl annotation:notes];
         __block ORInt nbSolutions = 0;
         [cp solve: ^{
            [cp labelArray:x];
            nbSolutions++;
         }];
         NSLog(@"#solutions: %d",nbSolutions);
         NSLog(@"Solver: %@",cp);
         struct ORResult res = REPORT(nbSolutions, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
//         struct ORResult res;
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

