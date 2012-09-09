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
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"

NSString* tab(int d);


#define TESTTA 1
int main (int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      int n = 11;
      id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n];
      id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
      id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:i]; }];
      id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:-i]; }];
      [model add: [ORFactory alldifferent: x]];
      [model add: [ORFactory alldifferent: xp]];
      [model add: [ORFactory alldifferent: xn]];
      id<ORInteger> nbSol = [ORFactory integer:model value:0];

      NSLog(@"Model: %@",model);
      //id<CPSemSolver> cp = [CPFactory createSemSolver:[ORSemDFSController class]];
      //id<CPSemSolver> cp = [CPFactory createSemSolver:[ORSemBDSController class]];
      id<CPParSolver> cp = [CPFactory createParSolver:2 withController:[ORSemDFSController class]];
      [cp addModel: model];
      [cp solveAll: ^{
         __block ORInt depth = 0;
         //[cp forall:R suchThat:^bool(ORInt i) { return ![x[i] bound];} orderedBy:^ORInt(ORInt i) { return [x[i] domsize];} do:^(ORInt i) {
         FORALL(i,R,![x[i] bound],[x[i] domsize], ^(ORInt i) {
#if TESTTA==1
            [cp tryall:R suchThat:^bool(ORInt v) { return [x[i] member:v];}
                    in:^(ORInt v) {
                       //NSLog(@"%@?x[%d] == %d   --> %@",tab(depth),i,v,[x[i] dereference]);
                       [cp label: x[i] with:v];
                       //NSLog(@"%@*x[%d] == %d   --> %@",tab(depth),i,v,[x[i] dereference]);
                    } onFailure:^(ORInt v) {
                       //NSLog(@"%@?x[%d] != %d   --> %@",tab(depth),i,v,[x[i] dereference]);
                       [cp diff: x[i] with:v];
                       //NSLog(@"%@*x[%d] != %d   --> %@",tab(depth),i,v,[x[i] dereference]);
                    }];
            depth++;
#else
            while (![x[i] bound]) {
               int v = [x[i] min];
               [cp try:^{
                  [cp label: x[i] with:v];
               } or:^{
                  [cp diff: x[i] with:v];
               }];
            }
#endif
         });

//           }];

/*         for(ORInt i = 0; i <= n; i++) {
            while (![x[i] bound]) {
               int v = [x[i] min];
               [cp try:^{
                  [cp label: x[i] with:v];
               } or:^{
                  [cp diff: x[i] with:v];
               }];
            }
         }*/
 /*
         @autoreleasepool {
            NSMutableString* buf = [NSMutableString stringWithCapacity:64];
            [buf appendFormat:@"x = (%p)[",[NSThread currentThread]];
            for(ORInt i = 0; i <= n; i++)
               [buf appendFormat:@"%d%c",[x[i] value],i < n ? ',' : ']' ];
            @synchronized(nbSol) {
               NSLog(@"SOL[%d] = %@",[nbSol value],buf);
            }
         }         
  */
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


NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}
