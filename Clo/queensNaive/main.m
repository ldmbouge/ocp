/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORConcretizer.h>

#import "objcp/CPConstraint.h"
#import "objcp/CPEngine.h"
#import "objcp/CPSolver.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

NSString* indent(int t)
{
   NSMutableString* tab = [NSMutableString stringWithCapacity:64];
   for(int i=0;i<t;i++)
      [tab appendString:@"   "];
   return tab;
}
int main (int argc, const char * argv[])
{
   int n = 8;
   id<ORModel> mdl = [ORFactory createModel];
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   id<ORIntRange> R = RANGE(mdl,0,n-1);
   id<ORInteger> nbSolutions = [ORFactory integer: mdl value:0];
   id<ORIntVarArray> x = [ORFactory intVarArray:mdl range:R domain: R];
   for(ORUInt i =0;i < n; i++) {
      for(ORUInt j=i+1;j< n;j++) {
         [mdl add: [x[i] neq:[x[j] plusi:0]]];
         [mdl add: [x[i] neq:[x[j] plusi:(i-j)]]];
         [mdl add: [x[i] neq:[x[j] plusi:(j-i)]]];
      }
   }
   id<ORModel> fm = [flat apply:mdl];
   NSLog(@"initial model: %@",mdl);
   NSLog(@"flat    model: %@",fm);
   id<CPSolver> cp = [ORFactory createCPProgram:fm];
   id<CPHeuristic> h = [CPFactory createIBS:cp];
   [cp solveAll:
    ^() {
      [CPLabel array: x ];
      [CPLabel heuristic:h];
       NSLog(@"LEVEL START: %d",[[cp tracer] level]);
       for(ORInt i=0;i<n;i++) {
          while (![x[i] bound]) {
             ORInt min = [x[i] min];
             [cp try:^{
                NSLog(@"%@x[%d]==%d -- | %d |",indent(i),i,min,[[cp tracer] level]);
                [cp label:x[i] with:min];
             } or:^{
                NSLog(@"%@x[%d]!=%d -- | %d |",indent(i),i,min,[[cp tracer] level]);
                [cp diff:x[i] with:min];
                //[cp add:[x[i] neqi: min]];
             }];
          }
       }
       NSLog(@"%@sol [%d]: %@ THREAD: %p || %d ||\n",indent(n),[nbSolutions value],x,[NSThread currentThread],[[cp tracer] level]);
      [nbSolutions incr];
    }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   
   
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   //[h release];
   [cp release];   
   [CPFactory shutdown];
   return 0;
}

