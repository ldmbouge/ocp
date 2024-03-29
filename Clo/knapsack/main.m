/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         const char* src = "MKNAP";
         const char* afn[6] = {"mknap1-0.txt",
            "mknap1-2.txt",
            "mknap1-3.txt",
            "mknap1-4.txt",
            "mknap1-5.txt",
            "mknap1-6.txt"};
         char buf[512];
         sprintf(buf,"%s/%s",src,afn[[args size]]);
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
         
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> N = RANGE(mdl,0,n-1);
         
         id<ORIntVarArray> x = All(mdl,ORIntVar, i, N, [ORFactory intVar:mdl domain:RANGE(mdl,0,1)]);
         [mdl add:[Sum(mdl, i, N, [x[i] mul:@(p[i])]) eq:@(opt)]];
         for(int i=0;i<m;i++) {
            [mdl add:[Sum(mdl,j,N,[x[j] mul:@(r[i][j])]) leq:@(b[i])]];
            /*
             id<ORIntArray> w = [CPFactory intArray:mdl range:N with:^ORInt(ORInt j) {return r[i][j];}];
             id<ORIntVar>   c = [CPFactory intVar:mdl domain:RANGE(mdl,0,b[i])];
             [mdl add:[CPFactory knapsack:x weight:w capacity:c]];
             */
         }
         
         id<CPProgram> cp  = [args makeProgram:mdl];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:nil];
         
         [cp solve: ^{
            [cp labelHeuristic:h restricted:x];
            NSLog(@"Solution: %@",x);
            NSLog(@"Solver: %@",cp);
            ORInt tot = 0;
            for(int k=0;k<n;k++)
               tot += p[k] * [cp min:x[k]];
            assert(tot == opt);
            NSLog(@"objective: %d == %d",tot,opt);
            for(int i=0;i<m;i++) {
               ORInt lhs = 0;
               for(int j=0;j<n;j++)
                  lhs += r[i][j] * [cp min:x[j]];
               assert(lhs <= b[i]);
               NSLog(@"C[%d] %d <= %d",i,lhs,b[i]);
            }            
         }];
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return res;
      }];
   }
   return 0;
}

