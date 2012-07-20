/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

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
      sprintf(buf,"%s/%s",src,afn[3]);
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
      
      CPRange N = (CPRange){0,n-1};
      id<CP> cp = [CPFactory createSolver];
      id<CPIntVarArray> x = ALL(CPIntVar, i, N, [CPFactory intVar:cp bounds:RANGE(0,1)]);
      id<CPIntVar> obj = [CPFactory intVar:cp domain:RANGE(0,sp)];
      id<CPHeuristic> h = [CPFactory createIBS:cp restricted:x];
      [cp maximize:obj
         subjectTo: ^{
            [cp add: [SUM(i, N, [x[i] muli:p[i]]) eq:obj]];
            for(int i=0;i<m;i++) {
               id<CPIntArray> w = [CPFactory intArray:cp range:N with:^ORInt(ORInt j) {return r[i][j];}];
               id<CPIntVar>   c = [CPFactory intVar:cp domain:RANGE(0,b[i])];
               [cp add:[CPFactory knapsack:x weight:w capacity:c]];
            }
      }  using:^{
         [CPLabel heuristic:h];
         NSLog(@"Solution: %@ -> obj = %@",x,obj);
      }];

      CPInt tot = 0;
      for(int k=0;k<n;k++)
         tot += p[k] * [[x at: k] min];
      assert(tot == opt);
      NSLog(@"objective: %d == %d",tot,opt);
      for(int i=0;i<m;i++) {
         CPInt lhs = 0;
         for(int j=0;j<n;j++)
            lhs += r[i][j] * [[x at:j] min];
         assert(lhs <= b[i]);
         NSLog(@"C[%d] %d <= %d",i,lhs,b[i]);
      }

      NSLog(@"Solver: %@",cp);      
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

