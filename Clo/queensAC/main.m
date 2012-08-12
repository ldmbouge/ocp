/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"
#import "objcp/CPHeuristic.h"

//345 choices
//254 fail
//5027 propagations
// First solution
// 22 choices 20 fail 277 propagations

int main (int argc, const char * argv[])
{
   ORInt n = 8;
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,1,n);
   id<ORInteger> nbSolutions = [ORFactory integer: cp value: 0];
   [CPFactory intArray:cp range:R with: ^CPInt(ORInt i) { return i; }];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range: R domain: R];
   id<ORIntVarArray> xp = ALL(ORIntVar,i,R,[CPFactory intVar:x[i] shift:i]);
   id<ORIntVarArray> xn = ALL(ORIntVar,i,R,[CPFactory intVar:x[i] shift:-i]);
   [cp add: [CPFactory alldifferent: x consistency: DomainConsistency]];
   [cp add: [CPFactory alldifferent: xp consistency:DomainConsistency]];
   [cp add: [CPFactory alldifferent: xn consistency:DomainConsistency]];

   [cp solveAll:
     ^() {
       [CPLabel array: x orderedBy: ^CPInt(ORInt i) { return [x[i] domsize];}];
       [nbSolutions incr];
    }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   NSLog(@"SOLUTION IS: %@",x);
   [cp release];
   [CPFactory shutdown];
   return 0;
}

