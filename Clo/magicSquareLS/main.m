/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSelector.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>
#import <objls/LSFactory.h>
#import <objls/LSConstraint.h>
#import <objls/LSSolver.h>


#import "ORCmdLineArgs.h"

void printSquare(id<LSProgram> p,id<ORIntVarMatrix> m)
{
   assert([m arity] == 2);
   printf("matrix is:\n");
   [[m range:0] enumerateWithBlock:^(ORInt i) {
      [[m range:1] enumerateWithBlock:^(ORInt j) {
         printf("%3d ",[p intValue:[m at:i :j]]);
      }];
      printf("\n");
   }];
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORInt n = [args size];
         id<ORModel> model = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntRange>  R = RANGE(model,1,n);
         id<ORIntRange>  D = RANGE(model,1,n*n);
         ORInt T = n * (n*n + 1)/2;
         id<ORIntVarMatrix> s = [ORFactory intVarMatrix:model range:R :R domain:D];
         [notes dc:[model add:[ORFactory alldifferent:All2(model, ORIntVar, i, R, j, R, [s at:i :j])]]];
         for(ORInt i=1;i <= n;i++) {
            [model add:[Sum(model, j, R, [s at:i :j]) eq: @(T)]];
            [model add:[Sum(model, j, R, [s at:j :i]) eq: @(T)]];
         }
         [model add:[Sum(model, i, R, [s at:i :i]) eq: @(T)]];
         [model add:[Sum(model, i, R, [s at:i :n-i+1]) eq: @(T)]];

         // Symmetry breaking is _BAD_ for LS!
//         for(ORInt i=1;i<=n-1;i++) {
//            [model add:[[s at:i :i]     lt:[s at:i+1 :i+1]]];
//            [model add:[[s at:i :n-i+1] lt:[s at:i+1 :n-i]]];
//         }
//         [model add:[[s at:1 :1] lt: [s at: 1 :n]]];
//         [model add:[[s at:1 :1] lt: [s at: n :1]]];
         
         id<LSProgram> cp = [ORFactory createLSProgram:model annotation:nil];
         __block ORInt it = 0;
         [cp solve: ^{
            id<ORIntMatrix> tabu = [ORFactory intMatrix:cp range:R :R using:^int(ORInt i, ORInt j) { return -1;}];
            ORInt __block tLen = 2;
            id<ORRandomPermutation> p = [ORFactory randomPermutation:D];
            for(ORInt i=1;i <= n;i++)
               for(ORInt j=1;j <= n;j++)
                  [cp label:[s at:i :j] with:[p next]];
            NSLog(@"viol ? : %d",[cp getViolations]);
            printSquare(cp, s);
            
            id<ORSelector> S = [ORFactory selectMin:cp];
            while ([cp getViolations] > 0) {
               [cp sweep:S with: ^ {
                  for(ORInt i=R.low,u = R.up;i <= u;i++) {
                     for(ORInt j=R.low; j <= u;j++) {
                        id<ORIntVar> alpha = [s at:i :j];
                        if (!([cp getVarViolations:alpha] > 0 && [tabu at:i :j] <= it)) continue;
                        for(ORInt i1=R.low;i1 <= u;i1++) {
                           for(ORInt j1=R.low;j1 <= u;j1++) {
                              if (!([tabu at:i1 :j1] <= it && (i != i1 || j != j1))) continue;
                              ORFloat delta = (ORFloat)[cp deltaWhenSwap:alpha with:[s at:i1 :j1]];
                              [S neighbor:delta do:^{
                                 [cp swap:alpha with:[s at:i1 :j1]];
                                 [tabu set:it + tLen at:i :j];
                                 [tabu set:it + tLen at:i1 :j1];
                                 printf("(%d)",[cp getViolations]);fflush(stdout);
                                 if (delta < 0 && tLen >= 5) tLen /= 2;
                                 if (delta >=0 && tLen <= n*2) tLen *= 2;
                              }];
                           }
                        }
                     }
                  }
                }];
               it++;
            }
            printf("\n");
            printSquare(cp, s);
//            for(ORInt i=1;i<n;i++)
//               for(ORInt j=1;j<n;j++)
//                  NSLog(@"viol(s[%d,%d] = %d",i,j,[cp getVarViolations:[s at:i :j]]);
         }];
         ORBool found = [cp getViolations] == 0;

         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult r = REPORT(found, it, 0, 0);
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}

