/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
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
      id<ORInteger> nbSol = [ORFactory integer:model value:0];

      NSLog(@"Model: %@",model);
      id<CPParSolver> cp = [CPFactory createParSolver:2];
      [cp addModel: model];
      [cp solveAll: ^{
         for(ORInt i = 0; i <= n; i++) {
            id<ORIntVar> xi = [x[i] dereference];
            while (![xi bound]) {
               int v = [xi min];
               [cp try:^{
                  [cp label:xi with:v];
               } or:^{
                  [cp diff:xi with:v];
               }];
            }
         }
         printf("x = [");
         for(ORInt i = 0; i <= n; i++)
            printf("%d%c",[x[i] value],i < n ? ',' : ']');
         printf("\n");
         [nbSol incr];
      }];
      NSLog(@"Quitting #SOL=%d",[nbSol value]);
      [cp release];
      [CPFactory shutdown];
   }
   return 0;

   /*
    [cp solve: ^{
    [[cp explorer] applyController: [CPFactory bdsController:cp]
    in: ^ {
    [cp nestedSolveAll:^{
    for(ORInt i = 0; i <= n; i++) {
    id<ORIntVar> xi = [x[i] dereference];
    while (![xi bound]) {
    int v = [xi min];
    [cp try:^{
    //NSLog(@"?x[%d] == %d with x[%d] def %@",i,v,i,xi);
    [cp label:xi with:v];
    //NSLog(@"+x[%d] == %d with x[%d] def %@",i,v,i,xi);
    } or:^{
    //NSLog(@"?x[%d] != %d with x[%d] def %@",i,v,i,xi);
    [cp diff:xi with:v];
    //NSLog(@"-x[%d] != %d with x[%d] def %@",i,v,i,xi);
    }];
    }
    }
    printf("x = [");
    for(ORInt i = 0; i <= n; i++)
    printf("%d%c",[x[i] value],i < n ? ',' : ']');
    printf("\n");
    [nbSol incr];
    }];
    }];
    }];
    */
   
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

