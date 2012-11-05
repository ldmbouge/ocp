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
#import <ORProgram/ORConcretizer.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      const char* src = "MKNAP";
      const char* afn[6] = {"mknap1-0.txt",
         "mknap1-2.txt",
         "mknap1-3.txt",
         "mknap1-4.txt",
         "mknap1-5.txt",
         "mknap1-6.txt"};
      char buf[512];
      sprintf(buf,"%s/%s",src,afn[4]);
      FILE* dta = fopen(buf,"r");
      int n,m,opt;
      fscanf(dta, "%d %d %d",&n,&m,&opt);
      int** r = alloca(sizeof(int*)*m);
      for(int k=0;k<m;k++)
         r[k] = alloca(sizeof(int)*n);
      int* b = alloca(sizeof(int)*m);
      int* p = alloca(sizeof(int)*n);
      int  sp = 0;
      for(int k=0;k<n;k++) {
         int v;
         fscanf(dta,"%d ",&v);
         p[k] = v;
         sp += v;
      }
      for(int i=0;i<m;i++)
         for(int j=0;j<n;j++)
            fscanf(dta,"%d ",r[i]+j);
      for(int i=0;i<m;i++)
         fscanf(dta,"%d ",b+i);
      
      for(int i=0;i<n;i++)
         printf("%d ",p[i]);
      printf("\n");
      for(int i=0;i<m;i++) {
         for(int j=0;j<n;j++)
            printf("%d ",r[i][j]);
         printf(" <= %d\n",b[i]);
      }
      
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> N = RANGE(mdl,0,n-1);
      
      id<ORIntVarArray> x = All(mdl,ORIntVar, i, N, [ORFactory intVar:mdl domain:RANGE(mdl,0,1)]);
      id<ORIntVar> obj = [ORFactory intVar:mdl domain:RANGE(mdl,0,sp)];
      [mdl add: [Sum(mdl,i, N, [x[i] muli:p[i]]) eq: obj]];
      for(int i=0;i<m;i++) {
         id<ORIntArray> w = [ORFactory intArray:mdl range:N with:^ORInt(ORInt j) {return r[i][j];}];
         id<ORIntVar>   c = [ORFactory intVar:mdl domain:RANGE(mdl,0,b[i])];
         [mdl add:[ORFactory knapsack:x weight:w capacity:c]];
      }
      [mdl maximize: obj];

      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<CPHeuristic> h = [ORFactory createIBS:cp restricted:x];
      [cp solve: ^{
         [cp labelHeuristic:h];
         NSLog(@"Solution: %@ -> obj = %@",x,obj);
      }];

      ORInt tot = 0;
      for(int k=0;k<n;k++)
         tot += p[k] * [[x at: k] min];
      assert(tot == opt);
      NSLog(@"objective: %d == %d",tot,opt);
      for(int i=0;i<m;i++) {
         ORInt lhs = 0;
         for(int j=0;j<n;j++)
            lhs += r[i][j] * [[x at:j] min];
         assert(lhs <= b[i]);
         NSLog(@"C[%d] %d <= %d",i,lhs,b[i]);
      }

      NSLog(@"Solver: %@",cp);      
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

