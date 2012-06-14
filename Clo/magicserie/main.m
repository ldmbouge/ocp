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
#import "objcp/CPFactory.h"
#import "CPValueConstraint.h"
#import "CPEquationBC.h"
#import "CPLabel.h"


int main (int argc, const char * argv[])
{
   const CPInt n = 20;  // 128 -> 494 fails
   id<CP> cp = [CPFactory createSolver]; 
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range:(CPRange){0,n-1} domain: (CPRange){0,n-1}];
   id<CPIntVarMatrix> b = [CPFactory intVarMatrix:cp rows:(CPRange){0,n-1} columns: (CPRange){0,n-1} domain: (CPRange){0,1}];
   [cp solve: 
    ^() {
        for(CPInt i=0;i<n;i++) {
            for(CPInt j=0;j<n;j++) 
                [cp add: [CPFactory reify: [b atRow:i col:j] with: [x at:j] eq: i]];
            id<CPIntVar> nxi = [CPFactory intVar:[x at:i] scale: -1 shift:0];
            id<CPIntVarArray> rowi = [CPFactory intVarArray: cp range: (CPRange){0,n} with: ^id<CPIntVar>(CPInt j) { if (j == n) return nxi; else return [b atRow: i col: j]; }];
            [cp add:[CPFactory sum: rowi eq: 0]];
        }
     }   
    using: 
    ^() {
        [CPLabel array: x];
        printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);      
     }
    ];
   NSLog(@"Solver status: %@\n",cp);
   [cp release];
   [CPFactory shutdown];
   return 0;
}


