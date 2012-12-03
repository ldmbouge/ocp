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
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
      ORInt k = 3;
      ORInt n = 9;
      
      id<ORIntRange> R = RANGE(model,1,k*n);
      id<ORIntRange> N = RANGE(model,1,n);
      id<ORIntRange> K = RANGE(model,1,k);
      id<ORIntVarArray>  x = [ORFactory intVarArray:model range:R domain:N];
      id<ORIntVarMatrix> p = [ORFactory intVarMatrix:model range:K :N domain:R];
      id<ORIntArray> occ = [ORFactory intArray:model range:N with:^ORInt(ORInt i) { return k;}];
      
      [model add:[ORFactory cardinality:x low:occ up:occ]];
      for(ORInt i=1;i<=k;i++)
         for(ORInt j=1;j<=n;j++)
            [model add:[[x elt:[p at:i :j]] eqi:j]];  // onDomain
      
      for(ORInt i=1;i<=k-1;i++)
         for(ORInt j=1;j<=n;j++)
            [model add:[[p at:i :j] lt:[p at:i+1 :j]]]; // onDomain

      for(ORInt i=1;i<=k-1;i++)
         for(ORInt j=1;j<=n;j++)
            [model add:[[x elt:[[p at:i :j] plusi:1+j]] eqi:j]]; // onDomain
      [model add: [x[1] leq: x[k*n]]];
      
      __block ORInt nbSol = 0;
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solveAll:^{
         [cp labelArray:All2(model, ORIntVar, i, K, j, N, [p at:i :j])];
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
   return 0;
}
