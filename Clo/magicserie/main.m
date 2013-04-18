/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      const ORInt n = 5;  // 128 -> 494 fails
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,0,n-1);
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      for(ORInt i=0;i<n;i++)
         [mdl add: [Sum(mdl,j,R,[x[j] eq: @(i)]) eq: x[i] ]];
      [mdl add: [Sum(mdl,i,R,[x[i] mul: @(i)]) eq: @(n) ]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      [cp solve: ^{
         NSLog(@"x = %@",x);
         //NSLog(@"model: %@",[[cp engine] model]);
         for(ORInt i=0;i<n;i++) {
            while (![x[i] bound]) {
               ORInt v = [x[i] min];
               [cp try:^{
                  //NSLog(@"try    x[%d] == %d  -- %@ -- %@",i,v,x[i],x);
                  [cp label:x[i] with:v];
                  //NSLog(@"tryok  x[%d] == %d  -- %@ -- %@",i,v,x[i],x);
               } or:^{
                  //NSLog(@"diff   x[%d] == %d  -- %@ -- %@",i,v,x[i],x);
                  [cp diff:x[i] with:v];
                  //NSLog(@"diffok x[%d] == %d  -- %@ -- %@",i,v,x[i],x);
               }];
            }
         }
         //[CPLabel array: x];
         printf("Succeeds \n");
         for(ORInt i = 0; i < n; i++)
            printf("%d ",[x[i] value]);
         printf("\n");
      }
       ];
      NSLog(@"Solver status: %@\n",cp);
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}
