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
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPCrFactory.h"
#import "objcp/CPLabel.h"
#import "objcp/CPHeuristic.h"

//345 choices
//254 fail
//5027 propagations

int main (int argc, const char * argv[])
{
    CPInt n = 8;
    CPRange R = (CPRange){1,n};
    CPRange D = (CPRange){1,2};
    CPRange DV = (CPRange){1,3};
    id<CP> cp = [CPFactory createSolver];
    id<CPIntArray> lb = [CPFactory intArray:cp range:D with: ^CPInt(CPInt i) { return 4; }]; 
    id<CPIntArray> ub = [CPFactory intArray:cp range:D with: ^CPInt(CPInt i) { return 4; }]; 
    id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: DV];
    [cp solve: 
     ^() {
         [cp add: [CPFactory cardinality: x low: lb up: ub consistency:DomainConsistency]];
     }   
        using: 
     ^() {
         printf("lb: %s\n",[[lb description] cStringUsingEncoding:NSASCIIStringEncoding]);
         printf("x: %s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);
//         [CPLabel array: x];
     }
     ];
    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
    [cp release];
    [CPFactory shutdown];
    return 0;
}
