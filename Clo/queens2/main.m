/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>

int main (int argc, const char * argv[])
{
   int n = 8;
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      id<ORAnnotation> notes = [ORFactory annotation];
      id<ORIntRange> R = RANGE(model,0,n-1);
      
      id<ORMutableInteger> nbSolutions = [ORFactory mutable: model value:0];
      id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain: R];
      id<ORIntVarArray> xp = [ORFactory intVarArray:model range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:x[i] shift:i]; }];
      id<ORIntVarArray> xn = [ORFactory intVarArray:model range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:x[i] shift:-i]; }];
      [notes dc:[model add: [ORFactory alldifferent: x ]]];
      [notes dc:[model add: [ORFactory alldifferent: xp ]]];
      [notes dc:[model add: [ORFactory alldifferent: xn ]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram: model annotation:notes];
      //id<CPHeuristic> h = [cp createFF];
      [cp solve:  // solveAll:
       ^() {
          [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return [cp domsize:x[i]];}];
          printf("S[%d] = [",[nbSolutions intValue:cp]);
          for(ORInt k=0;k < n;k++) {
             printf("%d%c",[cp intValue:x[k]],k<n-1 ? ',' : ']');
          }
          printf("\n");
          //[cp labelHeuristic:h];
          [nbSolutions incr:cp];
       }];
      printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
      
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
   }
   return 0;
}

