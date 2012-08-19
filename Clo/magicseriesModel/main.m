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
   const ORInt n = 8;  // 128 -> 494 fails
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: R domain: R];
   for(ORInt i=0;i<n;i++)
      [model add: [Sum(model,j,R,[x[j] eqi: i]) eq: x[i] ]];
   [model add: [Sum(model,i,R,[x[i] muli: i]) eqi: n ]];
   
   id<CPSolver> cp = [CPFactory createSolver];
   [cp addModel: model];
   [cp solveAll: ^{
      [CPLabel array: x];
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

