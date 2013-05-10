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

int main_alldiff(int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORIntRange> ER = RANGE(mdl,-2*n,2*n);
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      id<ORIntVarArray> xp = [ORFactory intVarArray:mdl range: R domain: ER];
      id<ORIntVarArray> xn = [ORFactory intVarArray:mdl range: R domain: ER];
      
      for(ORInt i = 1; i <= n; i++) {
         [mdl add: [xp[i] eq: [x[i] plus: @(i)]]];
         [mdl add: [xn[i] eq: [x[i] sub: @(i)]]];
      }
      
      [mdl add: [ORFactory alldifferent: x annotation: DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xp annotation:DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xn annotation:DomainConsistency]];
          
      id<CPProgram> cp = [ORFactory createCPProgram: mdl];
      
      ORLong startTime = [ORRuntimeMonitor wctime];
      __block ORInt nbSol = 0;
          
      [cp solveAll:
       ^() {
          [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize: x[i]];}];
          @synchronized(cp) {
             nbSol++;
          }
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

int main_neq(int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      
      for(ORInt i = 1; i <= n; i++)
         for(ORInt j = i+1; j <= n; j++) {
            [mdl add: [x[i] neq: x[j]]];
            [mdl add: [[x[i] plus: @(i)] neq: [x[j] plus: @(j)]]];
            [mdl add: [[x[i] sub: @(i)] neq: [x[j] sub: @(j)]]];
         }
      
      id<ORVarLitterals> l = [ORFactory varLitterals: mdl var: x[1]];
      NSLog(@"literals: %@",l);
      id<CPProgram> cp = [ORFactory createCPLinearizedProgram: mdl];
      
      ORLong startTime = [ORRuntimeMonitor wctime];
      __block ORInt nbSol = 0;
      
      [cp solveAll:
       ^() {
          [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize: x[i]];}];
          @synchronized(cp) {
             nbSol++;
          }
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

int main(int argc, const char * argv[])
{
   return main_neq(argc,argv);
}
