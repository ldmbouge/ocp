/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPSolver.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

int main (int argc, const char * argv[])
{
   int n = 10;
   CPRange R = (CPRange){0,n-1};
   long startTime = [CPRuntimeMonitor cputime];
   id<CP> cp = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
   [CPFactory intArray:cp range: R with: ^CPInt(CPInt i) { return i; }]; 
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<CPIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
//   id<CPHeuristic> h2 = [CPFactory createDDeg:cp];
//   id<CPHeuristic> h2  = [CPFactory createWDeg:cp];
   id<CPHeuristic> h2 = [CPFactory createIBS:cp];
//   id<CPHeuristic> h2 = [CPFactory createFF:cp];
   [cp solve: //All: 
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

