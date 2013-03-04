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

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = argc >= 2 ? atoi(argv[1]) : 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl, 0, n-1);
      long startTime = [ORRuntimeMonitor cputime];
      id<ORInteger> nbSolutions = [ORFactory integer: mdl value:0];
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range:R domain: R];
      id<ORIntVarArray> xp = [ORFactory intVarArray:mdl range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:mdl var:[x at: i] shift:i]; }];
      id<ORIntVarArray> xn = [ORFactory intVarArray:mdl range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:mdl var:[x at: i] shift:-i]; }];
      
      for(ORUInt i =0;i < n; i++) {
         for(ORUInt j=i+1;j< n;j++) {
            [mdl add: [ORFactory notEqual:mdl  var:[x at:i]    to:[x at: j]]];
            [mdl add: [ORFactory notEqual:mdl  var:[xp at: i]  to:[xp at: j]]];
            [mdl add: [ORFactory notEqual:mdl  var:[xn at: i]  to:[xn at: j]]];
         }
      }
      NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:mdl];
      BOOL ok = [archive writeToFile:@"anInstance.CParchive" atomically:NO];
      NSLog(@"Writing ? %s",ok ? "OK" : "KO");
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<CPHeuristic> h2 = [cp createIBS];
      //   id<CPHeuristic> h2 = [CPFactory createDDeg:cp];
      //   id<CPHeuristic> h2  = [CPFactory createWDeg:cp];
      //   id<CPHeuristic> h2 = [CPFactory createFF:cp];
      [cp solveAll:
       ^() {
          [cp labelHeuristic:h2];
          [nbSolutions incr];
       }
       ];
      printf("GOT %d solutions\n",[nbSolutions value]);
      long endTime = [ORRuntimeMonitor cputime];
      NSLog(@"Solution restored: %@",x);
      
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      NSLog(@"Total runtime: %ld\n",endTime - startTime);
      [cp release];   
      [ORFactory shutdown];
   }
   return 0;
}

