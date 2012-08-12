/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "objcp/CP.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPController.h"
#import "objcp/ORTracer.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"

int main (int argc, const char * argv[])
{
   int n = 12;
   id<CPSolver> cp = [CPFactory createSemSolver];
   id<ORIntRange> R = RANGE(cp,1,n);
   id<CPInteger> nbSolutions = [CPFactory integer: cp value: 0];
   id<ORIntVarArray> x  = [CPFactory intVarArray:cp range:R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:cp range:R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<ORIntVarArray> xn = [CPFactory intVarArray:cp range:R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
   [cp solveParAll:4
       subjectTo: 
            ^() {
                [cp add: [CPFactory alldifferent: x]];
                [cp add: [CPFactory alldifferent: xp]];
                [cp add: [CPFactory alldifferent: xn]];
            }   
             using: 
           ^void(id<CPSolver> cp) {
               id<ORIntVarArray> y = [cp virtual:x]; 
               [CPLabel array: y orderedBy: ^ORInt(ORInt i) { return [[y at:i] domsize];}];              
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

