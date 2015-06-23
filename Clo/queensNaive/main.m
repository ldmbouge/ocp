/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      int n = 8;
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> R = RANGE(model,0,n-1);
      id<ORMutableInteger> nbSol = INTEGER(model,0);
      id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain: R];
      for(ORUInt i =0;i < n; i++) {
         for(ORUInt j=i+1;j< n;j++) {
            [model add: [x[i] neq: x[j]]];
            [model add: [x[i] neq: [x[j] plus: @(i-j)]]];
            [model add: [x[i] neq: [x[j] plus: @(j-i)]]];
         }
      }
      id<CPProgram> cp = [ORFactory createCPProgram: model];
      __unsafe_unretained id<CPProgram> cpw = cp; // necessary, otherwise we have a strong cycle and a leak.
      [cp onSolution:^{
         [nbSol incr:cpw];
         id s = [ORFactory intArray:cpw range:x.range with:^ORInt(ORInt k) {
            return [cpw intValue:x[k]];
         }];
         NSLog(@"Sol: %@",s);
      }];
      [cp solveAll: ^{
          [cp labelArray: x];
       }];
      printf("GOT %d solutions\n",[nbSol intValue:cp]);
      [ORFactory shutdown];
   }
   return 0;
}
