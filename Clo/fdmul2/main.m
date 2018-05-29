/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/ORProgram.h>
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
      
      id<ORExpr> lhs1 = Sum(mdl,i,RANGE(mdl,0,2),[x[i] mul:@(ipow(10,i))]);
      [mdl add: [[lhs1 mul:x[3]] eq: Sum(mdl,i,RANGE(mdl,6,8),[x[i] mul:@(ipow(10,i-6))])]];
      [mdl add: [[lhs1 mul:x[4]] eq: Sum(mdl,i,RANGE(mdl,9,11),[x[i] mul:@(ipow(10,i-9))])]];
      [mdl add: [[lhs1 mul:x[5]] eq: Sum(mdl,i,RANGE(mdl,12,14),[x[i] mul:@(ipow(10,i-12))])]];
      int* coefs = (int[]){1,10,100,10,100,1000,100,1000,10000};
      [mdl add: [Sum(mdl,i,RANGE(mdl,1,5),[x[14+i] mul: @(ipow(10,i-1))]) eq: Sum(mdl,i,RANGE(mdl,6,14), [x[i] mul:@(coefs[i-6])])]];
      
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
            NSLog(@"Solution: %@",x);
            NSLog(@"        %d %d %d",[cp intValue:x[2]],[cp intValue:x[1]],[cp intValue:x[0]]);
            NSLog(@"        %d %d %d",[cp intValue:x[5]],[cp intValue:x[4]],[cp intValue:x[3]]);
            NSLog(@"* --------------");
            NSLog(@"        %d %d %d",[cp intValue:x[8]],[cp intValue:x[7]],[cp intValue:x[6]]);
            NSLog(@"      %d %d %d",[cp intValue:x[11]],[cp intValue:x[10]],[cp intValue:x[9]]);
            NSLog(@"    %d %d %d",[cp intValue:x[14]],[cp intValue:x[13]],[cp intValue:x[12]]);
            NSLog(@"    %d %d %d %d %d",[cp intValue:x[19]],[cp intValue:x[18]],[cp intValue:x[17]],[cp intValue:x[16]],[cp intValue:x[15]]);
            NSLog(@"Solver: %@",cp);
         } @catch(CPRemoveOnDenseDomainError* nsex) {
            NSLog(@"GOT AN REMOVE: %@",nsex);
            [nsex release];
         }
       }];
   }
   return 0;
}

