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
#import "objcp/CP.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPController.h"
#import "objcp/CPTracer.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"

int main (int argc, const char * argv[])
{
   int n = 12;
   CPRange R = (CPRange){1,n};
   id<CP> cp = [CPFactory createSemSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value: 0];
   id<CPIntVarArray> x  = [CPFactory intVarArray:cp range:R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:cp range:R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<CPIntVarArray> xn = [CPFactory intVarArray:cp range:R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
   [cp solveParAll:4
       subjectTo: 
            ^() {
                [cp add: [CPFactory alldifferent: x]];
                [cp add: [CPFactory alldifferent: xp]];
                [cp add: [CPFactory alldifferent: xn]];
            }   
             using: 
           ^void(id<CP> cp) {
               id<CPIntVarArray> y = [cp virtual:x]; 
               [CPLabel array: y orderedBy: ^CPInt(CPInt i) { return [[y at:i] domsize];}];              
                @synchronized(nbSolutions) {
                   [nbSolutions incr];  
                }
            }        
   ];
   NSLog(@"GOT %d solutions\n",[nbSolutions value]);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;
}

