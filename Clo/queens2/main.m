/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
#import <ORProgram/ORProgramFactory.h>

int main (int argc, const char * argv[])
{
   int n = 8;
   @autoreleasepool {
     id<ORModel> model = [ORFactory createModel];
     
     id<ORIntRange> R = RANGE(model,1,n);
     
     id<ORInteger> nbSolutions = [ORFactory integer: model value:0];
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
         [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [x[i] domsize];}];
         [cp labelHeuristic:h];
       //printf("sol [%d]: %s THREAD: %p\n",[nbSolutions value],[[x description] cStringUsingEncoding:NSASCIIStringEncoding],[NSThread currentThread]);
         [nbSolutions incr];
       }
       ];
     printf("GOT %d solutions\n",[nbSolutions value]);
     
     
     NSLog(@"Solver status: %@\n",cp);
     NSLog(@"Quitting");
     [cp release];
     [ORFactory shutdown];
  }
   return 0;
}

