/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
      ORInt n = argc >= 2 ? atoi(argv[1]) : 26;
      id<ORIntRange> V = RANGE(model,0,n-1);
      id<ORIntRange> F = RANGE(model,0,2*n-1);
      id<ORIntRange> D = RANGE(model,1,2*n);
      id<ORIntVarArray> x = [ORFactory intVarArray:model range:V domain:D];
      id<ORIntVarArray> y = [ORFactory intVarArray:model range:V domain:D];
      for(ORInt i=0;i<= n-2;i++) {
         [model add:[x[i] lt:x[i+1]]];
         [model add:[y[i] lt:y[i+1]]];
      }
      [model add:[x[0] lt:y[0]]];
      id<ORIntVarArray> xy = [ORFactory intVarArray:model range:F with:^id<ORIntVar>(ORInt i) {
         if (i <= n-1)
            return x[i];
         else return y[i-n];
      }];
      id<ORIntVarArray> sx = [ORFactory intVarArray:model range:V domain:RANGE(model,1,4*n*n)];
      id<ORIntVarArray> sy = [ORFactory intVarArray:model range:V domain:RANGE(model,1,4*n*n)];
      for(ORInt i=0;i<=n-1;i++) {
         [model add:[sx[i] eq:[x[i] mul:x[i]]] annotation:DomainConsistency];
         [model add:[sy[i] eq:[y[i] mul:y[i]]] annotation:DomainConsistency];
      }
      [model add:[ORFactory alldifferent:xy annotation:DomainConsistency]];
      [model add:[[Sum(model, i, V, x[i])  sub:Sum(model, j, V, y[j])] eqi:0]];
      [model add:[[Sum(model, i, V, sx[i]) sub:Sum(model, j, V, sy[j])] eqi:0]];
      [model add:[Sum(model,i,V,x[i])  eqi:2 * n * (2 * n + 1) / 4 ]];
      [model add:[Sum(model,i,V,y[i])  eqi:2 * n * (2 * n + 1) / 4 ]];

      [model add:[Sum(model,i,V,sx[i])  eqi:2 * n * (2 * n + 1)*(4*n+1) / 12 ]];
      [model add:[Sum(model,i,V,sx[i])  eqi:2 * n * (2 * n + 1)*(4*n+1) / 12 ]];
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^{
         NSLog(@"Concrete model;%@",[[cp engine] model]);
         [cp labelArray:xy orderedBy:^ORFloat(ORInt i) { return [xy[i] domsize];}];
         id<ORIntArray> solX = [ORFactory intArray:model range:[x range] with:^ORInt(ORInt i) { return [x[i] value];}];
         id<ORIntArray> solY = [ORFactory intArray:model range:[x range] with:^ORInt(ORInt i) { return [y[i] value];}];
         NSLog(@"Sol: %@ -- %@",solX,solY);
      }];
      
      ORLong endTime = [ORRuntimeMonitor wctime];      
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

