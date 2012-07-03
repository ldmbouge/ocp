/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
   id<CPIntVarMatrix> b = [CPFactory intVarMatrix:cp range:(CPRange){0,n-1} : (CPRange){0,n-1} domain: (CPRange){0,1}];
   [cp solve: 
    ^() {
        for(CPInt i=0;i<n;i++) {
            for(CPInt j=0;j<n;j++) 
                [cp add: [CPFactory reify: [b at:i :j] with: [x at:j] eq: i]];
            id<CPIntVar> nxi = [CPFactory intVar:[x at:i] scale: -1 shift:0];
            id<CPIntVarArray> rowi = [CPFactory intVarArray: cp range: (CPRange){0,n} with: ^id<CPIntVar>(CPInt j) { if (j == n) return nxi; else return [b at: i : j]; }];
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


