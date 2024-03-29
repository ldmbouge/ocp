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
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> model = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory annotation];
          ORInt k    = 2;//[args nArg];
          ORInt n    = 7;//[args size];
         NSLog(@"Params: k=%d n=%d",k,n);
         
         id<ORIntRange> R = RANGE(model,1,k*n);
         id<ORIntRange> N = RANGE(model,1,n);
         id<ORIntRange> K = RANGE(model,1,k);
         id<ORIntVarArray>  x = [ORFactory intVarArray:model range:R domain:N];
         id<ORIntVarMatrix> p = [ORFactory intVarMatrix:model range:K :N domain:R];
         id<ORIntArray> occ = [ORFactory intArray:model range:N with:^ORInt(ORInt i) { return k;}];
         
         [model add:[ORFactory cardinality:x low:occ up:occ]];
         for(ORInt i=1;i<=k;i++)
            for(ORInt j=1;j<=n;j++)
               [notes dc:[model add:[[x elt:[p at:i :j]] eq:@(j)]]];  // onDomain
         
         for(ORInt i=1;i<=k-1;i++)
            for(ORInt j=1;j<=n;j++)
               [notes dc:[model add:[[p at:i :j] lt:[p at:i+1 :j]]]]; // onDomain
         
         for(ORInt i=1;i<=k-1;i++)
             for(ORInt j=1;j<=n;j++) {
                 NSLog(@"p - %i %i", [[p at:i :j] min] + j + 1, [[p at:i :j] max] + j + 1);
                 NSLog(@"x rng: %i %i", [[x range] low], [[x range] up]);
                 [notes dc:[model add:[[x elt:[[p at:i :j] plus:@(1+j)]] eq:@(j)]]]; // onDomain
             }
         [model add: [x[1] leq: x[k*n]]];
         
         __block ORInt nbSol = 0;
         id<CPProgram> cp = [args makeProgram:model annotation:notes];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:nil];
         //NSLog(@"Model %@",model);
         //      id<CPHeuristic> h = [ORFactory createFF:cp];
         [cp solveAll:^{
            //NSLog(@"concrete: %@",[[cp engine] model]);
            id<ORIntVarArray> tb = All2(model, ORIntVar, i, K, j, N, [p at:i :j]);
            [cp labelHeuristic:h];
            //[cp labelArray:tb];
            [cp forall:[tb range] suchThat:^ORBool(ORInt i) { return ![cp bound:tb[i]];} orderedBy:^ORInt(ORInt i) {
               return [cp domsize:tb[i]];
            } do:^(ORInt i) {
               [cp tryall:[tb[i] domain] suchThat:^ORBool(ORInt j) {
                  return [cp member:j in:tb[i]];
               } in:^(ORInt j) {
                  //NSLog(@" ? tb[%d] == %d",i,j);
                  [cp label:tb[i] with:j];
                  //NSLog(@" ! tb[%d] == %d",i,j);
               } onFailure:^(ORInt j) {
                  //NSLog(@" ? tb[%d] != %d",i,j);
                  [cp diff:tb[i] with:j];
                  //NSLog(@" ! tb[%d] != %d",i,j);
               }];
            }];
            @autoreleasepool {
               NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
               [buf appendString:@"["];
               for(ORInt i=1;i<=k*n;i++)
                  [buf appendFormat:@"%d%c",[cp intValue:x[i]],(i < k *n) ? ',' : ']'];
               NSLog(@"Sol: %@",buf);
            }
            nbSol++;
            [[cp explorer] fail];
         }];         
         NSLog(@"#sol: %d",nbSol);
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return res;
      }];
   }
   return 0;
}
