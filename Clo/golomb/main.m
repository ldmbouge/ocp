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
#import "ORCmdLineArgs.h"


int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         ORInt n = [args size];
         id<ORIntRange> R = RANGE(model,1,n);
         id<ORIntRange> D = RANGE(model,0,n*n);
         
         id<ORIntVarMatrix> d = [ORFactory intVarMatrix:model range:R :R domain:D];
         id<ORIntVarArray>  m = [ORFactory intVarArray:model range:R domain:D];
         //int length[15] = {0,0,1,3,6,11,17,25,34,44,55,72,85,106,127};
         [model minimize:m[n]];
         [model add:[m[1] eq:@0]];
         for(ORInt i=1;i<=n;i++)
            for(ORInt j=i+1;j <= n;j++)
               [model add:[[d at:i :j] eq: [m[j] sub: m[i]]]];
         
         for(ORInt j=1;j<=n;j++)
            [model add: [m[j] geq: @(j * (j-1) / 2)]];
         
         for(ORInt i=1;i<=n;i++)
            for(ORInt j=i+1;j <= n;j++)
               [model add:[[d at:i :j] geq: @((j-1-(i-1))*(j-1-(i-1)+1)/2)]];
         
         for(ORInt i=2;i<=n;i++)
            [model add:[m[i-1] leq: m[i]]];
         [model add:[m[2] leq: [d at:n-1 :n]]];
         id<ORIntVarArray> ad = [ORFactory intVarArray:model range:RANGE(model,0,n*(n-1)/2 - 1) with:^id<ORIntVar>(ORInt k) { return nil;}];
         ORInt k =0;
         for(ORInt i=1;i<=n;i++)
            for(ORInt j=i+1;j <= n;j++)
               [ad set:[d at: i : j] at:k++];
         [model add:[ORFactory alldifferent:ad annotation:DomainConsistency]];
         
         id<CPProgram> cp  = [args makeProgram:model];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:m];
         //id<ORIntVarArray> fd = [ORFactory flattenMatrix:d];
         [cp solve: ^{
            for(ORInt i=1;i<=n;i++) {
               if ([m[i] bound]) continue;
               [cp tryall:D suchThat:^bool(ORInt v) {
                  return [m[i] member:v];
               } in:^(ORInt v) {
                  [cp label:m[i] with:v];
               } onFailure:^(ORInt v) {
                  [cp diff:m[i] with:v];
               }];
            }
            //[cp labelHeuristic:h];
            //[cp once: ^{ [cp labelArray:fd];}];
            NSLog(@"Optimum: %d",[m[n] value]);
         }];         
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];      
   }
   return 0;
}

