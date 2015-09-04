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
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      id<ORIntVarArray> xp = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:i]);
      id<ORIntVarArray> xn = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:-i]);
      id<ORAnnotation> note = [ORFactory annotation];
      [note bc:[mdl add: [ORFactory alldifferent: x]]];
      [note bc:[mdl add: [ORFactory alldifferent: xp]]];
      [note bc:[mdl add: [ORFactory alldifferent: xn]]];
      id<CPProgram> cp = [ORFactory createCPParProgram:mdl nb:1 annotation:note with:[ORSemDFSController class]];
      __block ORInt nbSol = 0;
      [cp solveAll:
       ^() {
          [cp switchOnDepth: ^{ [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return [cp domsize: x[i]];}]; }
                         to: ^{
                            NSLog(@"I switched \n");
                            for(ORInt i = 1; i <= 8; i++)
                               printf("%d-%d ",[cp min:x[i]],[cp max:x[i]]);
                            printf("\n");
                            [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return [cp domsize: x[i]];}];
                         }
                      limit: 4
           ];
          for(ORInt i = 1; i <= 8; i++)
             printf("%d ",[cp intValue: x[i]]);
          printf("\n");
          nbSol++;
          [nbSolutions incr: cp];
       }
       ];
      printf("GOT %d solutions\n",nbSol);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [ORFactory shutdown];
   }
   return 0;
}

