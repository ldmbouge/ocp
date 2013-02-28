/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>
#import <objcp/CPError.h>

ORInt ipow(ORInt b,ORInt e)
{
   ORInt r = 1;
   while (e--)
      r *= b;
   return r;
}
int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,0,19);
      id<ORIntRange> D = RANGE(mdl,0,9);
     
      id<ORIntVarArray> x = [ORFactory intVarArray: mdl range: R domain: D];
      
      id<ORIntArray> lb = [ORFactory intArray:mdl range:D value:2];
      [mdl add:[ORFactory cardinality:x low:lb up:lb]];
      
      id<ORExpr> lhs1 = Sum(mdl,i,RANGE(mdl,0,2),[x[i] muli:ipow(10,i)]);
      [mdl add: [[lhs1 mul:x[3]] eq: Sum(mdl,i,RANGE(mdl,6,8),[x[i] muli:ipow(10,i-6)])]];
      [mdl add: [[lhs1 mul:x[4]] eq: Sum(mdl,i,RANGE(mdl,9,11),[x[i] muli:ipow(10,i-9)])]];
      [mdl add: [[lhs1 mul:x[5]] eq: Sum(mdl,i,RANGE(mdl,12,14),[x[i] muli:ipow(10,i-12)])]];
      int* coefs = (int[]){1,10,100,10,100,1000,100,1000,10000};
      [mdl add: [Sum(mdl,i,RANGE(mdl,1,5),[x[14+i] muli: ipow(10,i-1)]) eq: Sum(mdl,i,RANGE(mdl,6,14), [x[i] muli:coefs[i-6]])]];
      
      /*
      NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:mdl];
      BOOL ok = [archive writeToFile:@"fdmul2.CParchive" atomically:NO];
      NSLog(@"Writing ? %s",ok ? "OK" : "KO");
       */
      
      id<CPProgram>   cp = [ORFactory createCPProgram:mdl];
      id<CPHeuristic> h = [cp createFF];

      [cp solve: ^{
         @try {
            [cp labelHeuristic:h];
         } @catch(CPRemoveOnDenseDomainError* nsex) {
            NSLog(@"GOT AN REMOVE: %@",nsex);
            [nsex release];
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
      [ORFactory shutdown];
   }
   return 0;
}

