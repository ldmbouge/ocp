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
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

void labelFF(id<CP> m,id<CPIntVarArray> x)
{
   CPRange R = {[x low],[x up]};
   [m forrange: R
    filteredBy: ^bool(int i) { return ![[x at:i] bound];}
     orderedBy: ^int(int i)  { return [[x at:i] domsize];}
            do: ^(int i)     { [CPLabel var: [x at:i]]; }
    ];
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      int n = 14;
      CPRange R = (CPRange){1,n};
      CPRange D = (CPRange){0,n-1};
      CPRange SD = (CPRange){1,n-1};
      id<CP> cp = [CPFactory createSolver];      
      id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
      id<CPIntVarArray> sx = [CPFactory intVarArray: cp range:R domain: D];         
      id<CPIntVarArray> dx = [CPFactory intVarArray: cp range:SD domain: SD];         
      //id<CPHeuristic> h = [CPFactory createWDeg:cp];
      //id<CPHeuristic> h = [CPFactory createFF:cp];
      [cp solveAll: ^{
         [cp add:[CPFactory alldifferent:sx consistency:DomainConsistency]];
         for(CPUInt i=SD.low;i<=SD.up;i++) {
            [cp add:[CPFactory expr:[CPFactory expr:[dx at:i]
                                              equal:[CPFactory exprAbs:[CPFactory expr:[sx at:i+1] sub:[sx at:i]]]]
                        consistency: DomainConsistency]];
         }
         [cp add:[CPFactory alldifferent:dx consistency:DomainConsistency]];
         [cp add:[CPFactory less:[sx at:1] to:[sx at:2]]];
         [cp add:[CPFactory less:[dx at:n-1] to:[dx at:1]]];
         
         NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
         BOOL ok = [archive writeToFile:@"ais.CParchive" atomically:NO];
         NSLog(@"Writing ? %s",ok ? "OK" : "KO");
         
      } using:^{
         NSLog(@"Start...");
         labelFF(cp,sx);
         //[CPLabel heuristic:h];
         //[CPLabel array:sx];
         [nbSolutions incr];
         //NSLog(@"Solution: %@",sx);
      }];
      NSLog(@"#solutions: %@",nbSolutions);
      NSLog(@"Solver: %@",cp);
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

