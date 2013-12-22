/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFactory.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORModeling/ORModeling.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>

#import <ORProgram/ORProgramFactory.h>

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      const ORInt n = argc>= 2 ? atoi(argv[1]) : 5;  // 128 -> 494 fails
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
      id<ORIntVarArray> x = [ORFactory intVarArray: model range: R domain: R];
      //[model add: [Sum(model,i,R,[x[i] mul: @(i)]) eq: @(n) ]];
      for(ORInt i=0;i<n;i++)
         [model add: [Sum(model,j,R,[x[j] eq: @(i)]) eq: x[i] ]];
      
      id<CPProgram> cp = [ORFactory createCPProgram: model];
      
      [cp solveAll: ^{
         id* gamma = [cp gamma];
         id<CPIntVarArray> cx = gamma[x.getId];
         //NSLog(@"BASIC: %@",[[cp engine] model]);
         //[cp  labelArray: x];
         for(ORInt i=0;i<n;i++) {
            if ([cp bound:x[i]]) continue;
            [cp label:x[i]];
            NSLog(@"i = %d s = %@",i,cx);
         }
         
         
         printf("Succeeds \n");
         for(ORInt i = 0; i < n; i++)
            printf("%d ",[cp intValue:x[i]]);
         printf("\n");
      }
       ];
      NSLog(@"Solver status: %@\n",cp);
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

