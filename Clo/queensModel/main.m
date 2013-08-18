/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORScheduler.h>

int main (int argc, const char * argv[])
{
   ORInt n = 8;
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];      
      id<ORIntRange> R = RANGE(model,1,n);
      id<ORMutableInteger> nbSolutions = [ORFactory mutable: model value: 0];
      
      id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
      id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) {
         return [ORFactory intVar:model var:x[i] shift:i];
      }];
      id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) {
         return [ORFactory intVar:model var:x[i] shift:-i];
      }];
      
      [model add: [ORFactory alldifferent: x]];
      [model add: [ORFactory alldifferent: xp]];
      [model add: [ORFactory alldifferent: xn]];
      
      [model add: [ORFactory disjunctive: x[1] duration: 1 start: x[2] duration: 1]];
      
      id<CPProgram> cp = [ORFactory createCPProgram: model];
      [cp solve:
       ^() {
          [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize:x[i]]; }];
          for(int i = 1; i <= n; i++)
             printf("%d ",[cp intValue:x[i]]);
          printf("\n");
          [nbSolutions incr:cp];
       }
       ];
      NSLog(@"GOT %d solutions\n",[nbSolutions intValue:cp]);
      NSLog(@"Solver status: %@\n",cp);
      [ORFactory shutdown];
   }
   return 0;
}

