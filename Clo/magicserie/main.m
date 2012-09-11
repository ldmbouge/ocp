/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "objcp/CPFactory.h"
#import "CPValueConstraint.h"
#import "CPEquationBC.h"
#import "CPLabel.h"


int main (int argc, const char * argv[])
{
   const ORInt n = 4;  // 128 -> 494 fails
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,0,n-1);
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range: R domain: R];
   for(ORInt i=0;i<n;i++)
     [cp add: [SUM(j,R,[x[j] eqi: i]) eq: x[i] ]];
   [cp add: [SUM(i,R,[x[i] muli: i]) eqi: n ]];

   [cp solveAll: ^{
      NSLog(@"x = %@",x);
      for(ORInt i=1;i<n;i++) {
         while (![x[i] bound]) {
            ORInt v = [x[i] min];
            [cp try:^{
               NSLog(@"try    x[%d] == %d  -- %@",i,v,x[i]);
               [cp label:x[i] with:v];
               NSLog(@"tryok  x[%d] == %d  -- %@",i,v,x[i]);
            } or:^{
               NSLog(@"diff   x[%d] == %d  -- %@",i,v,x[i]);
               [cp diff:x[i] with:v];
               NSLog(@"diffok x[%d] == %d  -- %@",i,v,x[i]);
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
   [CPFactory shutdown];
   return 0;
}


/*

int main (int argc, const char * argv[])
{
   const ORInt n = 128;  // 128 -> 494 fails
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,0,n-1);
   id<ORIntSet> RS = [ORFactory intSet: cp];
   [R iterate: ^(ORInt e) { [RS insert: e]; } ];
   NSLog(@"%@",RS);
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range: R domain: R];
   [cp solve: ^{
      for(ORInt i=0;i<n;i++)
         [cp add: [SUM(j,RS,[x[j] eqi: i]) eq: x[i] ]];
      [cp add: [SUM(i,RS,[x[i] muli: i]) eqi: n ]];
   }
       using: ^{
          [CPLabel array: x];
          for(ORInt i = 0; i < n; i++)
             printf("%d ",[x[i] value]);
          printf("\n");
       }
    ];
   NSLog(@"Solver status: %@\n",cp);
   [cp release];
   [CPFactory shutdown];
   return 0;
}


*/