/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPEngine.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

int main (int argc, const char * argv[])
{
   int n = 13;
   CPRange R = (CPRange){0,n-1};
   long startTime = [CPRuntimeMonitor cputime];
   id<CPSolver> cp = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
   [CPFactory intArray:cp range: R with: ^CPInt(ORInt i) { return i; }]; 
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<ORIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
//   id<CPHeuristic> h2 = [CPFactory createDDeg:cp];
//   id<CPHeuristic> h2  = [CPFactory createWDeg:cp];
   id<CPHeuristic> h2 = [CPFactory createIBS:cp];
//   id<CPHeuristic> h2 = [CPFactory createFF:cp];
   [cp solveAll: 
    ^() {
       for(CPUInt i =0;i < n; i++) {
          for(CPUInt j=i+1;j< n;j++) {
             [cp add: [CPFactory notEqual:[x at:i]    to:[x at: j]]];
             [cp add: [CPFactory notEqual:[xp at: i]  to:[xp at: j]]];
             [cp add: [CPFactory notEqual:[xn at: i]  to:[xn at: j]]];
          }
       }       
       NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
       BOOL ok = [archive writeToFile:@"anInstance.CParchive" atomically:NO];
       NSLog(@"Writing ? %s",ok ? "OK" : "KO");
    }   
          using: 
    ^() {
       [CPLabel heuristic:h2];
       [nbSolutions incr];
    }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   long endTime = [CPRuntimeMonitor cputime];
   NSLog(@"Solution restored: %@",x);
   
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   NSLog(@"Total runtime: %ld\n",endTime - startTime);
   //[h release];
   [cp release];   
   [CPFactory shutdown];
   return 0;
}

