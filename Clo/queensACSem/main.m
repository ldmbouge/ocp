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
      id<CPSemSolver> cp = [CPFactory createSemSolver:[ORSemBDSController class]];
      //id<CPParSolver> cp = [CPFactory createParSolver:4 withController:[ORSemDFSController class]];
      [cp addModel: model];
      [cp solveAll: ^{
         for(ORInt i = 0; i <= n; i++) {
            id<ORIntVar> xi = [x[i] dereference];
            while (![xi bound]) {
               int v = [xi min];
               [cp try:^{
                  [cp label: xi with:v];
               } or:^{
                  [cp diff: xi with:v];
               }];
            }
         }
         @autoreleasepool {
            NSMutableString* buf = [NSMutableString stringWithCapacity:64];
            [buf appendFormat:@"x = (%p)[",[NSThread currentThread]];
            for(ORInt i = 0; i <= n; i++)
               [buf appendFormat:@"%d%c",[x[i] value],i < n ? ',' : ']' ];
            @synchronized(nbSol) {
               NSLog(@"SOL[%d] = %@",[nbSol value],buf);
            }
         }
         @synchronized(nbSol) {
            [nbSol incr];
         }
      }];
      NSLog(@"Quitting #SOL=%d",[nbSol value]);
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

