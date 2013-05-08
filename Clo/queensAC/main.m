/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
#import <ORProgram/ORProgramFactory.h>

#import "ORCmdLineArgs.h"
//345 choices
//254 fail
//5027 propagations
// First solution
// 22 choices 20 fail 277 propagations

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORMutableInteger> nbSolutions = [ORFactory integer: mdl value: 0];
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      id<ORIntVarArray> xp = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:i]);
      id<ORIntVarArray> xn = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:-i]);
      [mdl add: [ORFactory alldifferent: x annotation: DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xp annotation:DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xn annotation:DomainConsistency]];
      ORLong startTime = [ORRuntimeMonitor wctime];
      //id<CPProgram> cp = [ORFactory createCPProgram: mdl];
      id<CPProgram> cp = [ORFactory createCPMultiStartProgram: mdl nb: 2];
      //id<CPProgram> cp = [ORFactory createCPParProgram:mdl nb:2 with:[ORSemDFSController class]];
      __block ORInt nbSol = 0;
      [cp solveAll:
       ^() {
          [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize: x[i]];}];
//          [cp labelArray: x];
          [nbSolutions incr: cp];
           @synchronized(cp) {
             nbSol++;
          }
          NSLog(@"Nb Solutions in thread %d is %d",[NSThread threadID],[nbSolutions value: cp]);
//          NSLog(@"Solutions: %@",x);
       }
       ];
      printf("GOT %d solutions\n",nbSol);
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];

   }
   return 0;
}


int main2(int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORMutableInteger> nbSolutions = [ORFactory integer: mdl value: 0];
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      id<ORIntVarArray> xp = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:i]);
      id<ORIntVarArray> xn = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:-i]);
      [mdl add: [ORFactory alldifferent: x annotation: DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xp annotation:DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xn annotation:DomainConsistency]];
//      id<CPProgram> cp = [ORFactory createCPProgram: mdl];
      id<CPProgram> cp = [ORFactory createCPParProgram:mdl nb:1 with:[ORSemDFSController class]];
      [cp solveAll:
       ^() {
          [cp switchOnDepth:
           ^() { [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize: x[i]];}]; }
                         to:
            ^() {
                  //NSLog(@"I switched %@\n",x);
                   NSLog(@"I switched \n");
                  for(ORInt i = 1; i <= 8; i++)
                     printf("%d-%d ",x[i].min,x[i].max);
               printf("\n");
               [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize: x[i]];}]; } limit: 4
           ];
          for(ORInt i = 1; i <= 8; i++)
             printf("%d ",[cp intValue: x[i]]);
          printf("\n");
          [nbSolutions incr];
       }
       ];
      printf("GOT %d solutions\n",[nbSolutions value]);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

