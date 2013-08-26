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
#import "objcp/CPSolver.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"
#import "objcp/CPHeuristic.h"
#import "objcp/CPWDeg.h"

ORInt labelFF3(id<CPSolver> m,id<ORIntVarArray> x,ORInt from,ORInt to)
{
   id<ORInteger> nbSolutions = [ORFactory integer:m value:0];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^ORFloat(ORInt i) { return [[x at:i] domsize];}];
      [nbSolutions incr];
   }
    ];
   printf("NbSolutions: %d \n",[nbSolutions value]);   
   return [nbSolutions value];
}

int main (int argc, const char * argv[])
{
   int n = 8;
   @autoreleasepool {
     id<ORModel> model = [ORFactory createModel];
     
     id<ORIntRange> R = RANGE(model,1,n);
     
     id<ORMutableInteger> nbSolutions = [ORFactory mutable: model value:0];
     id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain: R];
     id<ORIntVarArray> xp = [ORFactory intVarArray:model range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:x[i] shift:i]; }];
     id<ORIntVarArray> xn = [ORFactory intVarArray:model range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:x[i] shift:-i]; }];
     [model add: [ORFactory alldifferent: x annotation:ValueConsistency]];
     [model add: [ORFactory alldifferent: xp annotation:ValueConsistency]];
     [model add: [ORFactory alldifferent: xn annotation:ValueConsistency]];

     id<CPProgram> cp = [ORFactory createCPProgram: model];
     id<CPHeuristic> h = [cp createFF];
     [cp solveAll:
       ^() {
          [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize:x[i]];}];
         [cp labelHeuristic:h];
       //printf("sol [%d]: %s THREAD: %p\n",[nbSolutions value],[[x description] cStringUsingEncoding:NSASCIIStringEncoding],[NSThread currentThread]);
          [nbSolutions incr:cp];
       }
       ];
     printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
     
     NSLog(@"Solver status: %@\n",cp);
     NSLog(@"Quitting");
     [cp release];
     [ORFactory shutdown];
  }
   return 0;
}

