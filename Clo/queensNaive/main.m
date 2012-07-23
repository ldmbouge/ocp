/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPSolver.h"
#import "objcp/CP.h"
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
   int n = 5;
   CPRange R = (CPRange){0,n-1};
   id<CP> cp = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
   [CPFactory intArray:cp range: R with: ^CPInt(CPInt i) { return i; }]; 
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];

   //id<CPHeuristic> h = [CPFactory createIBS:cp];
   [cp solveAll: 
    ^() {
       for(CPUInt i =0;i < n; i++) {
          for(CPUInt j=i+1;j< n;j++) {
             id<CPIntVar> xi = [x at: i];
             id<CPIntVar> xj = [x at: j];
             [cp add: [CPFactory notEqual:xi  to:xj plus:0]];
             [cp add: [CPFactory notEqual:xi  to:xj plus:i-j]];
             [cp add: [CPFactory notEqual:xi  to:xj plus:j-i]];
          }
       }       
    }   
          using: 
    ^() {
       //[CPLabel array: x ];// orderedBy: ^CPInt(CPInt i) { return [[x at:i] domsize];}];
      //[CPLabel heuristic:h];
       NSLog(@"LEVEL START: %d",[[cp tracer] level]);
       for(CPInt i=0;i<n;i++) {
          while (![x[i] bound]) {
             CPInt min = [x[i] min];
             [cp try:^{
                NSLog(@"%@x[%d]==%d -- | %d |",indent(i),i,min,[[cp tracer] level]);
                [cp label:x[i] with:min];
             } or:^{
                NSLog(@"%@x[%d]!=%d -- | %d |",indent(i),i,min,[[cp tracer] level]);
                [cp diff:x[i] with:min];
             }];
          }
       }
/*       [cp forrange:R suchThat:^bool(ORInt i ) { return ![x[i] bound];}
          orderedBy:^ORInt(ORInt i) { return i;}
                 do:^(ORInt i) {
                    [cp tryall:R suchThat:^bool(ORInt v) { return [x[i] member:v];}
                            in:^(ORInt v) {
             NSLog(@"%@x[%d]==%d -- | %d |",indent(i),i,v,[[cp tracer] level]);
             [cp label:x[i] with:v];
          }];*/
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

