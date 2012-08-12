/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <objcp/CPConstraint.h>
#import "objcp/CPEngine.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"
#import "objcp/CPHeuristic.h"
#import "objcp/CPWDeg.h"

ORInt labelFF3(id<CPSolver> m,id<ORIntVarArray> x,ORInt from,ORInt to)
{
   id<ORInteger> nbSolutions = [ORFactory integer:m value:0];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^CPInt(ORInt i) { return [[x at:i] domsize];}];
      [nbSolutions incr];
   }
    ];
   printf("NbSolutions: %d \n",[nbSolutions value]);   
   return [nbSolutions value];
}

int main (int argc, const char * argv[])
{
   int n = 8;
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,1,n);
 
   id<ORInteger> nbSolutions = [ORFactory integer: cp value:0];
   [CPFactory intArray:cp range: R with: ^CPInt(ORInt i) { return i; }]; 
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: x[i] shift:i]; }];
   id<ORIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: x[i] shift:-i]; }];
   id<CPHeuristic> h = [CPFactory createFF:cp];
   [cp add: [CPFactory alldifferent: cp over: x consistency:ValueConsistency]];
   [cp add: [CPFactory alldifferent: cp over: xp consistency:ValueConsistency]];
   [cp add: [CPFactory alldifferent: cp over: xn consistency:ValueConsistency]];
   [cp solveAll:
   ^() {
       //[CPLabel array: x orderedBy: ^CPInt(ORInt i) { return [[x at:i] domsize];}];
       [CPLabel heuristic:h];
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

