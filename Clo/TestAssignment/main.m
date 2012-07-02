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

#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPlabel.h"
#import "objcp/CPCrFactory.h"
#import "objcp/CPArray.h"

int main (int argc, const char * argv[])
{
    CPRange R = (CPRange){1,3};
    CPRange D = (CPRange){1,3};
    id<CP> cp = [CPFactory createSolver];
    id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
    id<CPIntMatrix> cost = [CPFactory intMatrix:cp range: R : R];
    [cost set: 10 at: 1 : 1];
    [cost set: 15 at: 1 : 2];
    [cost set: 11 at: 1 : 3];
    [cost set: 8  at: 2 : 1];
    [cost set: 17 at: 2 : 2];
    [cost set: 7  at: 2 : 3];
    [cost set: 14 at: 3 : 1];
    [cost set: 21 at: 3 : 2];
    [cost set: 16 at: 3 : 3];
    
    for(CPInt i = 1; i <= 3; i++) {
        for(CPInt j = 1; j <= 3; j++)
            printf("%2d ",[cost at: i : j ]);
        printf("\n");
    }
    
    [cp solve: 
     ^() {
 //        [cp diff: [x at: 2] with: 2];
         [cp add: [CPFactory assignment: x matrix: cost]];
     }
           using:
     ^() {        
         [CPLabel array: x];
         for(CPInt i = 1; i <= 3; i++)
             printf("%d ",[[x at: i] min]);
         printf("\n");
     }
     ];
    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
    [cp release];
    [CPFactory shutdown];
    return 0;
}



