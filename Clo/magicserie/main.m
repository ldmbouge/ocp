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
   const CPInt n = 128;  // 128 -> 494 fails
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,0,n-1);
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: R];
   [cp solve: ^{
      for(CPInt i=0;i<n;i++)
         [cp add: [SUM(j,R,[x[j] eqi: i]) eq: x[i] ]];
      [cp add: [SUM(i,R,[x[i] muli: i]) eqi: n ]];
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


/*

int main (int argc, const char * argv[])
{
   const CPInt n = 128;  // 128 -> 494 fails
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,0,n-1);
   id<ORIntSet> RS = [ORFactory intSet: cp];
   [R iterate: ^(ORInt e) { [RS insert: e]; } ];
   NSLog(@"%@",RS);
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: R];
   [cp solve: ^{
      for(CPInt i=0;i<n;i++)
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