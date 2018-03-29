/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

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

#define TESTTA 0
int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
          ORLong startTime = [ORRuntimeMonitor cputime];
          id<ORAnnotation> note = [ORFactory annotation];
         id<ORModel> model = [ORFactory createModel];
         int n = [args size];
         id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
         id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
         id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:i]; }];
         id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:-i]; }];
          [note vc: [model add: [ORFactory alldifferent: x]]];
          [note vc: [model add: [ORFactory alldifferent: xp]]];
          [note vc:[model add: [ORFactory alldifferent: xn]]];
         __block ORInt nbSol = 0;        
         //id<CPProgram> cp = [args makeProgram:model annotation: note];
         //id<CPProgram> cp = [ORFactory createCPSemanticProgram:model with:[ORSemDFSController proto]];
         id<CPProgram> cp = [ORFactory createCPSemanticProgram:model with:[ORSemBDSController proto]];

         //id<CPProgram> cp = [ORFactory createCPParProgram:model nb:6 with:[ORSemDFSController proto]];
         
         //id<CPHeuristic> h = [args makeHeuristic:cp restricted:x];
         
         [cp solveAll: ^{
            __block ORInt depth = 0;
            //[cp labelHeuristic:h];
            [cp forall:R suchThat:^ORBool(ORInt i) { return ![cp bound:x[i]];} orderedBy:^ORInt(ORInt i) { return [cp domsize:x[i]];} do:^(ORInt i) {
            //FORALL(i,R,![cp bound:x[i]],[cp domsize:x[i]], ^(ORInt i) {
#if TESTTA==1
               //NSLog(@"IN body of forall with i= %d",i);
               [cp tryall:R suchThat:^ORBool(ORInt v) { return [cp member:v in:x[i]];}
                       in:^(ORInt v) {
                          [cp label: x[i] with:v];
                          //NSLog(@"AFTER LABEL: %@",x);
                       } onFailure:^(ORInt v) {
                          [cp diff: x[i] with:v];
                          //NSLog(@"AFTER DIFF: %@",x);
                       }];
               depth++;
               //NSLog(@"After tryall: %@",[cp concretize:x]);
#else
               while (![cp bound:x[i]]) {
                  int v = [cp min:x[i]];
                  [cp try:^{
                     [cp label: x[i] with:v];
                  }   alt:^{
                     [cp diff: x[i] with:v];
                  }];
               }
#endif
            }];
            @synchronized(cp) {
               printf("Solution:%d  <%d,%d> [",nbSol,[cp nbChoices],[cp nbFailures]);
               for(ORInt k=0;k < n;k++) {
                  printf("%d%c",[cp intValue:x[k]],k<n-1 ? ',' : ']');
               }
               printf("\n");
               ++nbSol;
            }
            [[cp explorer] fail]; // to avoid saving solutions.
         }];
         ORLong endTime = [ORRuntimeMonitor cputime];
         NSLog(@"Quitting #SOL=%d",nbSol);
         NSLog(@"Solver: %@",cp);
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         NSLog(@"CPU Time: %lld\n",(int) endTime - startTime);
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
