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
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORInt n = [args size];         
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORInteger> nbSolutions = [ORFactory integer: mdl value: 0];
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
         id<ORIntVarArray> xp = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:i]);
         id<ORIntVarArray> xn = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:-i]);
         [mdl add: [ORFactory alldifferent: x annotation: DomainConsistency]];
         [mdl add: [ORFactory alldifferent: xp annotation:DomainConsistency]];
         [mdl add: [ORFactory alldifferent: xn annotation:DomainConsistency]];
         
         id<CPProgram> cp = [ORFactory createCPProgram: mdl];
         [cp solveAll:
          ^() {
             [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [x[i] domsize];}];
             [nbSolutions incr];
          }
          ];
         printf("GOT %d solutions\n",[nbSolutions value]);
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult res = REPORT([nbSolutions value], [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

int main0(int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORInteger> nbSolutions = [ORFactory integer: mdl value: 0];
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      id<ORIntVarArray> xp = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:i]);
      id<ORIntVarArray> xn = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:-i]);
      [mdl add: [ORFactory alldifferent: x annotation: DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xp annotation:DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xn annotation:DomainConsistency]];
      
      id<CPProgram> cp = [ORFactory createCPProgram: mdl];
      [cp solveAll:
       ^() {
          [cp switchOnDepth:
            ^() { [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [x[i] domsize];}]; }
                         to:
            ^() {
                  //NSLog(@"I switched %@\n",x);
                   NSLog(@"I switched \n");
                  for(ORInt i = 1; i <= 8; i++)
                     printf("%d-%d ",x[i].min,x[i].max);
               printf("\n");
                  [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [x[i] domsize];}]; } limit: 4
           ];
          for(ORInt i = 1; i <= 8; i++)
             printf("%d ",x[i].value);
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

