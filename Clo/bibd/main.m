/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORFactory.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

void show(id<CPIntVarMatrix> M)
{
   id<ORIntRange> r0 = [M range:0];
   id<ORIntRange> r1 = [M range:1];
   for(CPInt i = r0.low ; i <= r0.up;i++) {
      for(CPInt j = r1.low ; j <= r1.up;j++) {
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
      CPInt a = 12;
      CPInt instances[14][3] = {
         {7,3,1},{6,3,2},{8,4,3},{7,3,20},{7,3,30},
         {7,3,40},{7,3,45},{7,3,50},{7,3,55},{7,3,60},
         {7,3,300},{8,4,5},{8,4,6},{8,4,7}
      };
      CPInt v = instances[a][0],k = instances[a][1],l = instances[a][2];
      CPInt b = (v*(v-1)*l)/(k*(k-1));
      CPInt r = l*(v-1)/(k-1);
      
      id<CP> cp = [CPFactory createSolver];
      id<ORIntRange> Rows = RANGE(cp,1,v);
      id<ORIntRange> Cols = RANGE(cp,1,b);
     
      id<CPIntVarMatrix> M = [CPFactory boolVarMatrix:cp range:Rows :Cols];
               
      [cp solve:^{
         for(CPInt i=Rows.low;i<=Rows.up;i++)
            [cp add: SUM(x, Cols, [M at:i :x]) eqi:r];
         for(CPInt i=Cols.low;i<=Cols.up;i++)
            [cp add: SUM(x, Rows, [M at:x :i]) eqi:k];
         for(CPInt i=Rows.low;i<=Rows.up;i++)
            for(CPInt j=i+1;j <= v;j++)
               [cp add: SUM(x,Cols,[[M at:i :x] and: [M at:j :x]]) eqi:l];
         for(CPInt i=1;i <= v-1;i++) {
            [cp add: [CPFactory lex:ALL(CPIntVar, j, Cols, [M at:i+1 :j])
                                leq:ALL(CPIntVar, j, Cols, [M at:i   :j])]];
         }
         for(CPInt j=1;j <= b-1;j++) {
            [cp add: [CPFactory lex:ALL(CPIntVar, i, Rows, [M at:i :j+1])
                                leq:ALL(CPIntVar, i, Rows, [M at:i :j])]];
         }
      } using:^{
         NSLog(@"Start...");
         [CPLabel array:[CPFactory flattenMatrix:M]];
         NSLog(@"V=%d K=%d L=%d B=%d R=%d",v,k,l,b,r);
         show(M);
      }];
      NSLog(@"Solver: %@",cp);
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}
/*
explore<m> {
   
   forall(i in 1..v-1)
   m.post(lexleq(all(j in Cols) M[i+1,j],all(j in Cols) M[i,j]));
   forall(j in 1..b-1)
   m.post(lexleq(all(i in Rows) M[i,j+1],all(i in Rows) M[i,j]));
   
} using {
   
   show(M);
   cout << "searching...." << endl;
   var<CP>{int}[] x = m.getIntVariables();
   range R = x.rng();
   forall(i in R: !x[i].bound())
   label(x[i]);
   
}
*/

