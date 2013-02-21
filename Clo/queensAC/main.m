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

//345 choices
//254 fail
//5027 propagations
// First solution
// 22 choices 20 fail 277 propagations

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORInteger> nbSolutions = [ORFactory integer: mdl value: 0];
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      id<ORIntVarArray> xp = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:i]);
      id<ORIntVarArray> xn = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:-i]);
      [mdl add: [ORFactory alldifferent: x annotation: DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xp annotation:DomainConsistency]];
      [mdl add: [ORFactory alldifferent: xn annotation:DomainConsistency]];
      
      id<CPProgram> cp = [ORFactory createCPProgram: mdl];
      [cp solveAll:
       ^() {
          [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [x[i] domsize];}];
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

