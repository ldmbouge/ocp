/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <ORFoundation/ORFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         int n = [args size];
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORIntRange> D = RANGE(mdl,-n+1,n-1);
         
         id<ORIntVarArray> costas = [ORFactory intVarArray: mdl range:R domain: R];
         id<ORIntVarMatrix>  diff = [ORFactory intVarMatrix:mdl range:R : R domain:D];
         [mdl add:[ORFactory alldifferent:costas]];
         for(ORUInt i=R.low;i<=R.up;i++) {
            for(ORUInt j=R.low;j<=R.up;j++) {
               if (i < j)
                  [mdl add:[[diff at:i :j] eq: [[costas at:j] sub:[costas at:j-i]]]];
               else [mdl add:[[diff at:i :j] eq: @0]];
            }
         }
         for(ORInt i=1;i<=n-1;i++) {
            id<ORIntVarArray> slice = All(mdl,ORIntVar, j, RANGE(mdl,i+1,n), [diff at:i :j]);
            [mdl add:[ORFactory alldifferent:slice]];
         }
         //[mdl add:[[costas at:1] leq:[costas at:n]]];
         for(ORUInt i=R.low;i<=R.up;i++) {
            for(ORUInt j=i+1;j<=R.up;j++) {
               [mdl add:[[diff at:i :j] neq:@0]];
            }
         }
         for (ORInt k=3; k<=n; k++) {
            for (ORInt l=k+1; l<=n; l++) {
               [mdl add:[[[diff at:k-2 :l-1] plus: [diff at:k :l]] eq:
                         [[diff at:k-1 :l-1] plus: [diff at:k-1 :l]]]];
            }
         }
         
         //         NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
         //         BOOL ok = [archive writeToFile:@"fdmul.CParchive" atomically:NO];
         //         NSLog(@"Writing ? %s",ok ? "OK" : "KO");
         //id<ORMutableInteger> nbSol = [ORFactory mutable:mdl value:0];
         __block ORInt nbSol = 0;
         id<CPProgram> cp = [args makeProgram:mdl];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:costas];
         [cp solveAll: ^{
            NSLog(@"Searching...");
//            [cp labelHeuristic:h];
            for(ORInt  i=1;i <=n;i++) {
               //if ([cp bound:costas[i]]) continue;
               while (![cp bound:costas[i]]) {
                  ORInt val = [cp max:costas[i]];
                  [cp try:^{
                     [cp label:costas[i] with:val];
                  } or:^{
                     [cp diff:costas[i] with:val];
                  }];
               }
            }            
            @autoreleasepool {
               //               id<ORIntArray> s = [ORFactory intArray:cp range:[costas range] with:^ORInt(ORInt i) {
               //                  return [cp intValue:costas[i]];
               //               }];
               //               NSLog(@"Solution: %@",s);
               @synchronized(cp) {
                  nbSol++;
               }
            }
         }];
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}

