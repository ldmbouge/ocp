/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      const char* src = "/Users/ldm/work/langExp/benchdata/MKNAP";
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
      for(int k=0;k<n;k++) {
         int v;
         fscanf(dta,"%d ",&v);
         p[k] = v;
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
      id<CPIntVarArray> x = [CPFactory intVarArray: cp 
                                             range: N
                                            domain: (CPRange){0,1}];
      id<CPHeuristic> h = [CPFactory createIBS:cp];
      [cp solve: ^{
         [cp add:[CPFactory sum:[CPFactory pointwiseProduct:x by:p] eq:opt]];
         for(int i=0;i<m;i++) {
            [cp add:[CPFactory sum:[CPFactory pointwiseProduct:x by:r[i]] leq:b[i]]];
         }
      } using:^{
         [CPLabel heuristic:h];
         NSLog(@"Solution: %@",x);
         NSLog(@"Solver: %@",cp);
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
      }];
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

