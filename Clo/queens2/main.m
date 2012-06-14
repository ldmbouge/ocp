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
#import "objcp/CPHeuristic.h"
#import "objcp/CPWDeg.h"

CPInt labelFF3(CP* m,id<CPIntVarArray> x,CPInt from,CPInt to)
{
   CPIntegerI* nbSolutions = [[[CPIntegerI alloc] initCPIntegerI: 0] autorelease];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return [[x at:i] domsize];}];
      [nbSolutions incr];
   }
    ];
   printf("NbSolutions: %d \n",[nbSolutions value]);   
   return [nbSolutions value];
}

int main (int argc, const char * argv[])
{
   int n = 8;
   CPRange R = (CPRange){1,n};
   id<CP> cp = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
   [CPFactory intArray:cp range: R with: ^CPInt(CPInt i) { return i; }]; 
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<CPIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
   [cp solveAll: 
    ^() {
       [cp add: [CPFactory alldifferent: x consistency:ValueConsistency]];
       [cp add: [CPFactory alldifferent: xp consistency:ValueConsistency]];
       [cp add: [CPFactory alldifferent: xn consistency:ValueConsistency]];
    }   
          using: 
    ^() {
       [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return [[x at:i] domsize];}];
       printf("sol [%d]: %s THREAD: %p\n",[nbSolutions value],[[x description] cStringUsingEncoding:NSASCIIStringEncoding],[NSThread currentThread]);
       [nbSolutions incr];
    }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   
   
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   //[h release];
   [cp release];   
   [CPFactory shutdown];
   return 0;
}

