/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPConstraint.h>

#import "ORCmdLineArgs.h"

NSString* tab(int d);

#define TESTTA 1
int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         int n = [args size];
         id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
         id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
         id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:i]; }];
         id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:-i]; }];
         [model add: [ORFactory alldifferent: x]];
         [model add: [ORFactory alldifferent: xp]];
         [model add: [ORFactory alldifferent: xn]];
         id<ORInteger> nbSol = [ORFactory integer:model value:0];
         
         NSLog(@"Model: %@",model);
         id<CPProgram> cp = [args makeProgram:model];
         //id<CPProgram> cp = [ORFactory createCPSemanticProgram:model with:[ORSemDFSController class]];
         //id<CPProgram> cp = [CPFactory createCPSemanticProgram:model with:[ORSemBDSController class]];
         //id<CPProgram> cp = [ORFactory createCPParProgram:model nb:2 with:[ORSemDFSController class]];
         
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:x];
         
         [cp solveAll: ^{
            __block ORInt depth = 0;
            [cp labelHeuristic:h];
            //[cp forall:R suchThat:^bool(ORInt i) { return ![x[i] bound];} orderedBy:^ORInt(ORInt i) { return [x[i] domsize];} do:^(ORInt i) {
            FORALL(i,R,![x[i] bound],[x[i] domsize], ^(ORInt i) {
#if TESTTA==1
               [cp tryall:R suchThat:^bool(ORInt v) { return [x[i] member:v];}
                       in:^(ORInt v) {
                          [cp label: x[i] with:v];
                          //NSLog(@"AFTER LABEL: %@",x);
                       } onFailure:^(ORInt v) {
                          [cp diff: x[i] with:v];
                          //NSLog(@"AFTER DIFF: %@",x);
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
         NSLog(@"Solver: %@",cp);
         struct ORResult r = REPORT([nbSol value], [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
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
