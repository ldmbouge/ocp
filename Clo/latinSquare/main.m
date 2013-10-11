/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         
         id<ORModel> model = [ORFactory createModel];
         ORInt n = [args size];
         id<ORIntRange> R = RANGE(model,0,n-1);
         id<ORIntRange> D = RANGE(model,1,n);
         id<ORIntRange> R2 = RANGE(model,0,n*n-1);
         id<ORIntVarMatrix> x = [ORFactory intVarMatrix:model range:R :R domain:D];
         id<ORIntVarMatrix> y = [ORFactory intVarMatrix:model range:R :R domain:D];
         id<ORIntVarMatrix> z = [ORFactory intVarMatrix:model range:R :R domain:R2];
         
         id<ORIntArray> m1 = [ORFactory intArray:model range:R2 with:^ORInt(ORInt i) { return 1 + i % n;}];
         id<ORIntArray> m2 = [ORFactory intArray:model range:R2 with:^ORInt(ORInt i) { return 1 + i / n;}];
         
         for(ORInt i=0;i <= n - 1;i++) {
            for(ORInt j=0; j <= n-1; j++) {
               [model add:[[m2  elt:[z at:i :j]] eq: [x at:i :j]] annotation:DomainConsistency];
               [model add:[[m1  elt:[z at:i :j]] eq: [y at:i :j]] annotation:DomainConsistency];
               [model add:[[z at:i :j] eq: [[[[[x at:i :j] sub: @1] mul:@(n)] plus: [y at:i :j]] sub: @1]] annotation:DomainConsistency];
            }
         }
         
         for(ORInt i=0;i <= n-1 ; i++) {
            [model add:[ORFactory alldifferent:All(model, ORIntVar, j, R, [x at:i :j]) annotation:DomainConsistency]];
            [model add:[ORFactory alldifferent:All(model, ORIntVar, j, R, [x at:j :i]) annotation:DomainConsistency]];
            [model add:[ORFactory alldifferent:All(model, ORIntVar, j, R, [y at:i :j]) annotation:DomainConsistency]];
            [model add:[ORFactory alldifferent:All(model, ORIntVar, j, R, [y at:j :i]) annotation:DomainConsistency]];
         }
         [model add:[ORFactory alldifferent:All2(model, ORIntVar, i, R, j, R, [z at:i :j]) annotation:DomainConsistency]];
         
         for(ORInt i=1;i<=n-1;i++)
            [model add:[ORFactory lex:All(model, ORIntVar, j, R, [x at:i :j]) leq:All(model, ORIntVar, j, R, [y at:i-1 :j])]];
         
         //NSLog(@"initial: %@",model);
         
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         id<ORIntVarArray> av = All2(model, ORIntVar, i, R, j, R, [z at:i :j]);
         id<CPHeuristic> h = [cp createFF:av];
         [cp solve:^{
            //NSLog(@"BASIC: %@",[[cp engine] model]);
            __block ORInt d = 0;
//            [cp forall:[av range] suchThat:^bool(ORInt i) { return ![cp bound:av[i]];} orderedBy:^ORInt(ORInt i) { return [cp domsize:av[i]];}
//                    do:^(ORInt i) {
//               [cp tryall:[av[i] domain] suchThat:^bool(ORInt j) { return [cp member:j in:av[i]];} in:^(ORInt j) {
//                  [cp label:av[i] with:j];
//               } onFailure:^(ORInt j) {
//                  [cp diff:av[i] with:j];
//               }];
//               d = d + 1;
//            }];
            //[cp labelHeuristic:h];
            //[cp labelArrayFF:av];
            //[cp labelArray:av];
            id* gamma = [cp gamma];
            for(ORInt k=av.low;k <= av.up;k++) {
               ORInt i = -1;
               ORInt sd = FDMAXINT;
               for(ORInt j=av.low; j <= av.up;j++) {
                  if ([cp bound:av[j]]) continue;
                  if ([cp domsize:av[j]] < sd) {
                     sd = [cp domsize:av[j]];
                     i = j;
                  }
               }
               if (i==-1) break;
               while(![cp bound:av[i]]) {
                  ORInt v = [cp min:av[i]];
                  [cp try:^{
                     [cp label:av[i] with:v];
//                     for(ORInt k=av.range.low;k <= av.range.up;k++) {
//                        id<CPIntVar> cav = gamma[av[k].getId];
//                        printf("%s , ",[[cav description] cStringUsingEncoding:NSASCIIStringEncoding]);
//                     }
//                     printf("\n");
                  } or:^{
                     [cp diff:av[i] with:v];
                  }];
               }
            }
            @autoreleasepool {
               NSLog(@"x=");
               for(ORInt i=0;i<=n-1;i++) {
                  NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
                  [buf appendString:@"\t|"];
                  for(ORInt j=0;j<=n-1;j++) {
                     [buf appendFormat:@"%2d ",[cp intValue:[x at:i :j]]];
                  }
                  [buf appendString:@"|"];
                  NSLog(@"%@",buf);
               }
               NSLog(@"y=");
               for(ORInt i=0;i<=n-1;i++) {
                  NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
                  [buf appendString:@"\t|"];
                  for(ORInt j=0;j<=n-1;j++) {
                     [buf appendFormat:@"%2d ",[cp intValue:[y at:i :j]]];
                  }
                  [buf appendString:@"|"];
                  NSLog(@"%@",buf);
               }
               
               NSLog(@"z=");
               for(ORInt i=0;i<=n-1;i++) {
                  NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
                  [buf appendString:@"\t|"];
                  for(ORInt j=0;j<=n-1;j++) {
                     [buf appendFormat:@"%2d ",[cp intValue:[z at:i :j]]];
                  }
                  [buf appendString:@"|"];
                  NSLog(@"%@",buf);
               }
            }
         }];         
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

