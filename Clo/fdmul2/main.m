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
#import "objcp/CPError.h"

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
      id<CPIntVarArray> x = ALL(CPIntVar, i, R, [CPFactory intVar:cp bounds:D]);
//      id<CPIntVarArray> x = [CPFactory intVarArray: cp range: R domain: D];
      id<CPHeuristic> h = [CPFactory createFF:cp];
      [cp solve: ^{
         id<CPIntArray> lb = [CPFactory intArray:cp range:D value:2];
         [cp add:[CPFactory cardinality:x low:lb up:lb consistency:ValueConsistency]];
         
         id<CPExpr> lhs1 = SUM(i,RANGE(0,2),[x[i] muli:ipow(10,i)]);
         [cp add:[lhs1 mul:x[3]] equal: SUM(i,RANGE(6,8),[x[i] muli:ipow(10,i-6)])];
         [cp add:[lhs1 mul:x[4]] equal: SUM(i,RANGE(9,11),[x[i] muli:ipow(10,i-9)])];
         [cp add:[lhs1 mul:x[5]] equal: SUM(i,RANGE(12,14),[x[i] muli:ipow(10,i-12)])];
         int* coefs = (int[]){1,10,100,10,100,1000,100,1000,10000};
         [cp add: SUM(i,RANGE(1,5),[x[14+i] muli: ipow(10,i-1)]) equal: SUM(i,RANGE(6,14), [x[i] muli:coefs[i-6]])];

         NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
         BOOL ok = [archive writeToFile:@"fdmul2.CParchive" atomically:NO];
         NSLog(@"Writing ? %s",ok ? "OK" : "KO");
         
      } using:^{
         @try {
            [CPLabel heuristic:h];
         } @catch(NSException* nsex) {
            NSLog(@"GOT AN NSException: %@",nsex);
         }
         @catch(CPRemoveOnDenseDomainError* ex) {
            NSLog(@"GOT A BAD ERROR: %@",ex);
         }
         NSLog(@"Solution: %@",x);
         NSLog(@"        %d %d %d",[x[2] min],[x[1] min],[x[0] min]);
         NSLog(@"        %d %d %d",[x[5] min],[x[4] min],[x[3] min]);
         NSLog(@"* --------------");
         NSLog(@"        %d %d %d",[x[8] min],[x[7] min],[x[6] min]);
         NSLog(@"      %d %d %d",[x[11] min],[x[10] min],[x[9] min]);
         NSLog(@"    %d %d %d",[x[14] min],[x[13] min],[x[12] min]);
         NSLog(@"    %d %d %d %d %d",[x[19] min],[x[18] min],[x[17] min],[x[16] min],[x[15] min]);
         NSLog(@"Solver: %@",cp);
       }];
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

