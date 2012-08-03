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
      id<CP> cp = [CPFactory createSolver];
      id<ORIntRange> R = RANGE(cp,0,19);
      id<ORIntRange> D = RANGE(cp,0,9);
            
      id<CPIntVarArray> x = [CPFactory intVarArray: cp range:R domain: D];         
      id<CPIntVarArray> c = [CPFactory intVarArray:cp range:RANGE(cp,0,8) domain: D];
      id<CPHeuristic> h = [CPFactory createFF:cp];
      [cp solve: ^{
         id<CPIntArray> lb = [CPFactory intArray:cp range:D value:2];
         [cp add:[CPFactory cardinality:x low:lb up:lb consistency:ValueConsistency]];

         [cp add:[x[0] mul:x[3]]             equal:[x[6] plus:[c[0] muli:10]]];
         [cp add:[[x[1] mul:x[3]] plus:c[0]] equal:[x[7] plus:[c[1] muli:10]]];
         [cp add:[[x[2] mul:x[3]] plus:c[1]] equal:x[8]];
         
         [cp add:[x[0] mul:x[4]]             equal:[x[9] plus:[c[2]  muli:10]]];
         [cp add:[[x[1] mul:x[4]] plus:c[2]] equal:[x[10] plus:[c[3] muli:10]]];
         [cp add:[[x[2] mul:x[4]] plus:c[3]] equal:x[11]];
         
         [cp add:[x[0] mul:x[5]]             equal:[x[12] plus:[c[4] muli:10]]];
         [cp add:[[x[1] mul:x[5]] plus:c[4]] equal:[x[13] plus:[c[5] muli:10]]];
         [cp add:[[x[2] mul:x[5]] plus:c[5]] equal:x[14]];
         
         [cp add:x[6]             equal:x[15]];
         [cp add:[x[7] plus:x[9]] equal:[x[16] plus:[c[6] muli:10]]];
         
         id<CPExpr> lhs1 = [CPFactory dotProduct:(id<CPIntVar>[]){x[8],x[10],x[12],c[6],nil} by:(int[]){1,1,1,1}];
         id<CPExpr> lhs2 = [CPFactory dotProduct:(id<CPIntVar>[]){x[11],x[13],c[7],nil} by:(int[]){1,1,1}];
         
         [cp add:lhs1              equal:[x[17] plus:[c[7] muli:10]]];
         [cp add:lhs2              equal:[x[18] plus:[c[8] muli:10]]];
         [cp add:[x[14] plus:c[8]] equal:x[19]];
         
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

