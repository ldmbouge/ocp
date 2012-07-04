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
      CPRange R = (CPRange){0,19};
      CPRange D = (CPRange){0,9};
      id<CP> cp = [CPFactory createSolver];      
      id<CPIntVarArray> x = [CPFactory intVarArray: cp range:R domain: D];         
      id<CPIntVarArray> c = [CPFactory intVarArray:cp range:(CPRange){0,8} domain: D];
      id<CPHeuristic> h = [CPFactory createFF:cp];
      [cp solve: ^{
         id<CPIntArray> lb = [CPFactory intArray:cp range:D value:2];
         [cp add:[CPFactory cardinality:x low:lb up:lb consistency:ValueConsistency]];

         [cp addRel:[[[x at:0] mul:[x at:3]]                 equal:[[x at:6] add:[[c at:0] muli:10]]]];
         [cp addRel:[[[[x at:1] mul:[x at:3]] add:[c at: 0]] equal:[[x at:7] add:[[c at:1] muli:10]]]];
         [cp addRel:[[[[x at:2] mul:[x at:3]] add:[c at: 1]] equal:[x at: 8]]];
         
         [cp addRel:[[[x at:0] mul:[x at:4]]                 equal:[[x at:9] add:[[c at:2]  muli:10]]]];
         [cp addRel:[[[[x at:1] mul:[x at:4]] add:[c at: 2]] equal:[[x at:10] add:[[c at:3] muli:10]]]];
         [cp addRel:[[[[x at:2] mul:[x at:4]] add:[c at: 3]] equal:[x at: 11]]];
         
         [cp addRel:[[[x at:0] mul:[x at:5]]                 equal:[[x at:12] add:[[c at:4] muli:10]]]];
         [cp addRel:[[[[x at:1] mul:[x at:5]] add:[c at: 4]] equal:[[x at:13] add:[[c at:5] muli:10]]]];
         [cp addRel:[[[[x at:2] mul:[x at:5]] add:[c at: 5]] equal:[x at: 14]]];
         
         [cp addRel:[[x at:6] equal:[x at:15]]];
         [cp addRel:[[[x at: 7] add:[x at: 9]] equal:[[x at:16] add:[[c at:6] muli:10]]]];
         
         id<ORExpr> lhs1 = [CPFactory dotProduct:(id<CPIntVar>[]){[x at:8],[x at:10],[x at:12],[c at:6],nil} by:(int[]){1,1,1,1}];
         id<ORExpr> lhs2 = [CPFactory dotProduct:(id<CPIntVar>[]){[x at:11],[x at:13],[c at:7],nil} by:(int[]){1,1,1}];
         
         [cp addRel:[lhs1 equal:[[x at:17] add:[[c at:7] muli:10]]]];
         [cp addRel:[lhs2 equal:[[x at:18] add:[[c at:8] muli:10]]]];
         [cp addRel:[[[x at:14] add:[c at:8]] equal:[x at:19]]];
         
         NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
         BOOL ok = [archive writeToFile:@"fdmul.CParchive" atomically:NO];
         NSLog(@"Writing ? %s",ok ? "OK" : "KO");
         
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

