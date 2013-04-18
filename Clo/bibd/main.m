/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>

#import "ORCmdLineArgs.h"

void show(id<ORIntVarMatrix> M)
{
   id<ORIntRange> r0 = [M range:0];
   id<ORIntRange> r1 = [M range:1];
   for(ORInt i = r0.low ; i <= r0.up;i++) {
      for(ORInt j = r1.low ; j <= r1.up;j++) {
         if ([[M at:i :j] bound])
            printf("%d ",[[M at:i :j] min]);
         else printf("? ");
      }
      printf("\n");
   }
   printf("\n");
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORInt a = [args size];
         ORInt instances[14][3] = {
            {7,3,1},{6,3,2},{8,4,3},{7,3,20},{7,3,30},
            {7,3,40},{7,3,45},{7,3,50},{7,3,55},{7,3,60},
            {7,3,300},{8,4,5},{8,4,6},{8,4,7}
         };
         ORInt v = instances[a][0],k = instances[a][1],l = instances[a][2];
         ORInt b = (v*(v-1)*l)/(k*(k-1));
         ORInt r = l*(v-1)/(k-1);

         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> Rows = RANGE(mdl,1,v);
         id<ORIntRange> Cols = RANGE(mdl,1,b);

         id<ORIntVarMatrix> M = [ORFactory boolVarMatrix:mdl range:Rows :Cols];
         for(ORInt i=Rows.low;i<=Rows.up;i++)
            [mdl add: [Sum(mdl,x, Cols, [M at:i :x]) eq:@(r)]];
         for(ORInt i=Cols.low;i<=Cols.up;i++)
            [mdl add: [Sum(mdl,x, Rows, [M at:x :i]) eq:@(k)]];
         for(ORInt i=Rows.low;i<=Rows.up;i++)
            for(ORInt j=i+1;j <= v;j++)
//               [mdl add: [Sum(mdl,x,Cols,[[M at:i :x] mul: [M at:j :x]]) eq:@(l)]];
               [mdl add: [Sum(mdl,x,Cols,[[[[M at:i :x] neg] or: [[M at:j :x] neg]] neg]) eq:@(l)]];
         for(ORInt i=1;i <= v-1;i++) {
            [mdl add: [ORFactory lex:All(mdl,ORIntVar, j, Cols, [M at:i+1 :j])
                                 leq:All(mdl,ORIntVar, j, Cols, [M at:i   :j])]];
         }
         for(ORInt j=1;j <= b-1;j++) {
            [mdl add: [ORFactory lex:All(mdl,ORIntVar, i, Rows, [M at:i :j+1])
                                 leq:All(mdl,ORIntVar, i, Rows, [M at:i :j])]];
         }

         id<CPProgram> cp =  [args makeProgram:mdl];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:[ORFactory flattenMatrix:M]];
         [cp solve:^{
            NSLog(@"Start... %@",[[cp engine] model]);
            id<ORIntVarArray> flat =[ORFactory flattenMatrix:M];
            //[cp labelHeuristic:h];
            [cp labelArray:flat orderedBy:^ORFloat(ORInt i) { return [flat[i] domsize];}];
            //[cp labelArray:[ORFactory flattenMatrix:M]];
            NSLog(@"V=%d K=%d L=%d B=%d R=%d",v,k,l,b,r);
            show(M);
         }];
         NSLog(@"Solver: %@",cp);
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}
