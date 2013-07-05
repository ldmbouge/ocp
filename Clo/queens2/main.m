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
   int n = 7;
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
	 id<CPIntVarArray> cx = [cp gamma][[x getId]];
	 [cp label:x[1] with:2];
	 NSLog(@"cx= %@",cx);
	 [cp label:x[2] with:6];
	 [cp forall:R suchThat:^bool(ORInt i) { return ![cp bound:x[i]];}
  	 orderedBy: ^ORInt(ORInt i) { return [cp domsize:x[i]];}
		 do: ^void(ORInt i) {
		 [cp label:x[i]];
	       }];
	 //[cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return i;/*[cp domsize:x[i]]*/;}];
	 //[cp labelArrayFF: x];
	  printf("S[%d] = [",[nbSolutions intValue:cp]);
	  for(ORInt k=1;k <= n;k++) {
	    printf("%d%c",[cp intValue:x[k]],k<n ? ',' : ']');
	  }
	  printf("\n");
	  //[cp labelHeuristic:h];
          [nbSolutions incr:cp];
       }];
     printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
     
     NSLog(@"Solver status: %@\n",cp);
     NSLog(@"Quitting");
     [cp release];
     [ORFactory shutdown];
  }
   return 0;
}

