/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORFoundation.h"
#import "objcp/CPSolver.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPController.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      int n = 7;
      id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n];
      id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
      id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:i]; }];
      id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:-i]; }];
      [model add: [ORFactory alldifferent: x]];
      [model add: [ORFactory alldifferent: xp]];
      [model add: [ORFactory alldifferent: xn]];

      NSLog(@"Model: %@",model);
      id<CPSolver> cp = [CPFactory createSemSolver];
      [cp addModel: model];
      
      [cp solveAll: ^{
         for(ORInt i = 0; i <= n; i++)
            [CPLabel var: x[i]];
         printf("x = [");
         for(ORInt i = 0; i <= n; i++)
            printf("%d%c",[x[i] value],i < n ? ',' : ']');
         printf("\n");
      }];
      NSLog(@"Quitting");
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
   
/*
   
   int n = 12;
   id<CPSolver> cp = [CPFactory createSemSolver];
   id<ORIntRange> R = RANGE(cp,1,n);
   id<ORInteger> nbSolutions = [CPFactory integer: cp value: 0];
   id<ORIntVarArray> x  = [CPFactory intVarArray:cp range:R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:cp range:R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:i]; }];
   id<ORIntVarArray> xn = [CPFactory intVarArray:cp range:R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
   [cp solveParAll:4
       subjectTo: 
            ^() {
                [cp add: [CPFactory alldifferent: x]];
                [cp add: [CPFactory alldifferent: xp]];
                [cp add: [CPFactory alldifferent: xn]];
            }   
             using: 
           ^void(id<CPSolver> cp) {
               id<ORIntVarArray> y = [cp virtual:x]; 
               [CPLabel array: y orderedBy: ^ORInt(ORInt i) { return [[y at:i] domsize];}];              
                @synchronized(nbSolutions) {
                   [nbSolutions incr];  
                }
            }        
   ];
   NSLog(@"GOT %d solutions\n",[nbSolutions value]);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;
 */
}

