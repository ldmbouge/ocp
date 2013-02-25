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
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[])
{
   mallocWatch();   
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
      ORInt k    = argc >= 2 ? atoi(argv[1]) : 2;
      ORInt n    = argc >= 3 ? atoi(argv[2]) : 8;
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
            [model add:[[x elt:[p at:i :j]] eqi:j] annotation:DomainConsistency];  // onDomain
      
      for(ORInt i=1;i<=k-1;i++)
         for(ORInt j=1;j<=n;j++)
            [model add:[[p at:i :j] lt:[p at:i+1 :j]] annotation:DomainConsistency]; // onDomain

      for(ORInt i=1;i<=k-1;i++)
         for(ORInt j=1;j<=n;j++)
            [model add:[[x elt:[[p at:i :j] plusi:1+j]] eqi:j] annotation:DomainConsistency]; // onDomain
      [model add: [x[1] leq: x[k*n]]];
      
      __block ORInt nbSol = 0;
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      //NSLog(@"Model %@",model);
//      id<CPHeuristic> h = [ORFactory createFF:cp];
      [cp solveAll:^{
         //NSLog(@"concrete: %@",[[cp engine] model]);
         id<ORIntVarArray> tb = All2(model, ORIntVar, i, K, j, N, [p at:i :j]);
         //[cp labelHeuristic:h];
         //[cp labelArray:tb];
         [cp forall:[tb range] suchThat:^bool(ORInt i) { return ![tb[i] bound];} orderedBy:^ORInt(ORInt i) {
            return [tb[i] domsize];
         } do:^(ORInt i) {
            [cp tryall:[tb[i] domain] suchThat:^bool(ORInt j) {
               return [tb[i] member:j];
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
               [buf appendFormat:@"%d%c",[x[i] value],(i < k *n) ? ',' : ']'];
            NSLog(@"Sol: %@",buf);
         }
         nbSol++;
       }];
            
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"#sol: %d",nbSol);
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   NSLog(@"malloc: %@",mallocReport());
   return 0;
}
