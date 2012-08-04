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
      id<CPSolver> cp = [CPFactory createSolver];
      const char* fn = "market.dta";
      FILE* dta = fopen(fn,"r");
      int n,m,z;
      fscanf(dta, "%d %d %d",&m,&n,&z);
      id<ORIntRange> V = RANGE(cp,0,n-1);
      int** w = alloca(sizeof(int*)*m);
      for(int k=0;k<m;k++)
         w[k] = alloca(sizeof(int)*n);
      
      int* rhs = alloca(sizeof(int)*m);
      for(int i=0;i<m;i++) {
         for(int j=0;j<n;j++)
            fscanf(dta,"%d ",w[i]+j);
         fscanf(dta,"%d ",rhs+i);
      }
      
      for(int i=0;i<m;i++) {
         for(int j=0;j<n;j++)
            printf("%d ",w[i][j]);
         printf(" <= %d\n",rhs[i]);
      }
      CPInt rrhs = 0;
      CPInt alpha = 1;
      CPInt* wr = malloc(sizeof(CPInt)*n);
      for(CPInt v = 0; v < n;v++) wr[v] = 0;
      for(CPInt c = 0; c < m;++c) {
         for(CPInt v = 0; v < n;v++) {
            wr[v] = wr[v] + alpha * w[c][v];
            rrhs = rrhs + alpha * rhs[c];
            alpha = alpha * 5;
         }
      }
      CPInt* tw = malloc(sizeof(CPInt)*n);
      for (CPInt v=0; v < n; ++v) {
         tw[v] = 0;
         for(CPInt c =0;c < m;++c)
            tw[v] += w[c][v];
      }
      
      
      
      id<CPIntVarArray> x = ALL(CPIntVar, i, V, [CPFactory intVar:cp domain:RANGE(cp,0,1)]);
      [cp solve: ^{
         for(int i=0;i<m;i++) {
            id<CPIntArray> coef = [CPFactory intArray:cp range:V with:^ORInt(ORInt j) { return w[i][j];}];
            id<CPIntVar>   r = [CPFactory intVar:cp domain:RANGE(cp,rhs[i],rhs[i])];
            [cp add:[CPFactory knapsack:x weight:coef capacity:r]];
         }
      }  using:^{
         [ORControl forall: V suchThat:^bool(ORInt i) { return ![x[i] bound];}  orderedBy:^ORInt(ORInt i) {
            return -tw[i];
         } do:^(ORInt i) {
            [cp try:^{
               //printf("BR:%d==%d\n",i+1,0);
               [cp label:x[i] with:0];
               /*
               for(CPInt k=V.low;k<=V.up;k++)
                  if ([x[k] bound])
                     printf("%d ",[x[k] value]);
                  else printf("? ");
               printf("\n");
               */
            } or:^{
               //printf("BR:%d==%d\n",i+1,1);
               [cp label:x[i] with:1];
               /*
               for(CPInt k=V.low;k<=V.up;k++)
                  if ([x[k] bound])
                     printf("%d ",[x[k] value]);
                  else printf("? ");
               printf("\n");
               */
            }];
         }];
         NSLog(@"Solution: %@",x);
      }];
      
      for(int k=0;k < m;k++) {
         CPInt sum = 0;
         for(CPInt i=V.low;i <= V.up;++i)
            sum += w[k][i] * [x[i] value];
         NSLog(@"got: %d == %d",sum,rhs[k]);
         assert(sum == rhs[k]);
      }
      NSLog(@"Solver: %@",cp);
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}