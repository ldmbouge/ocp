/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

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



