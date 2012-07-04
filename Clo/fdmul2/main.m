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

CPInt ipow(CPInt b,CPInt e)
{
   CPInt r = 1;
   while (e--)
      r *= b;
   return r;
}
int main(int argc, const char * argv[])
{
   @autoreleasepool {
      CPRange R = (CPRange){0,19};
      CPRange D = (CPRange){0,9};
      id<CP> cp = [CPFactory createSolver];      
      id<CPIntVarArray> x = [CPFactory intVarArray: cp range: R domain: D];         
      id<CPHeuristic> h = [CPFactory createIBS:cp];
      [cp solve: ^{
         id<CPIntArray> lb = [CPFactory intArray:cp range:D value:2];
         [cp add:[CPFactory cardinality:x low:lb up:lb consistency:ValueConsistency]];
         
         id<CPExpr> lhs1 = [CPFactory dotProduct:(id<CPIntVar>[]){[x at:0],[x at:1],[x at:2],nil} by:(int[]){1,10,100}];
         id<CPExpr> rhs1 = [CPFactory dotProduct:(id<CPIntVar>[]){[x at:6],[x at:7],[x at:8],nil} by:(int[]){1,10,100}];
         id<CPExpr> rhs2 = [CPFactory dotProduct:(id<CPIntVar>[]){[x at:9],[x at:10],[x at:11],nil} by:(int[]){1,10,100}];
         id<CPExpr> rhs3 = [CPFactory dotProduct:(id<CPIntVar>[]){[x at:12],[x at:13],[x at:14],nil} by:(int[]){1,10,100}];
         [cp addRel:[[lhs1 mul:[x at:3]] equal:rhs1]];
         [cp addRel:[[lhs1 mul:[x at:4]] equal:rhs2]];
         [cp addRel:[[lhs1 mul:[x at:5]] equal:rhs3]];
         id<CPExpr> lhs4 = [CPFactory sum:cp range:(CPRange){1,5} filteredBy:nil
                                       of:^id<CPExpr>(CPInt i) {
                                          return [[x at:14+i] muli: ipow(10,i-1)];
                                       }];
         /*id<CPExpr> lhs4b = [CPFactory dotProduct:(id<CPIntVar>[]){[x at:15],[x at:16],[x at:17],[x at:18],[x at:19],nil} 
                                              by:(int[]){1,10,100,1000,10000}];*/
         
         id<CPExpr> rhs4 = [CPFactory dotProduct:(id<CPIntVar>[]){[x at:6],[x at:7],[x at:8],[x at:9],[x at:10],[x at:11],[x at:12],[x at:13],[x at:14],nil}
                                              by:(int[]){1,10,100,10,100,1000,100,1000,10000}];
         [cp addRel:[lhs4 equal:rhs4]];

         //NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
         //BOOL ok = [archive writeToFile:@"fdmul2.CParchive" atomically:NO];
         //NSLog(@"Writing ? %s",ok ? "OK" : "KO");
         
      } using:^{
         [CPLabel heuristic:h];
         NSLog(@"Solution: %@",x);
         NSLog(@"Solver: %@",cp);
       }];
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

