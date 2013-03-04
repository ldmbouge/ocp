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

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}

int main(int argc, const char * argv[])
{
   mallocWatch();
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      [ORStreamManager setRandomized];
      id<ORModel> model = [ORFactory createModel];
      ORInt n = argc >= 2 ? atoi(argv[1]) : 7;
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
            [model add:[[z at:i :j] eq: [[[[[x at:i :j] subi: 1] muli:n] plus: [y at:i :j]] subi: 1]] annotation:DomainConsistency];
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
         id<ORBasicModel> bm = [[cp engine] model];
         NSLog(@"BASIC: %@",bm);
         __block ORInt d = 0;
         [cp forall:[av range] suchThat:^bool(ORInt i) { return ![av[i] bound];} orderedBy:^ORInt(ORInt i) { return [av[i] domsize];} do:^(ORInt i) {
            [cp tryall:[av[i] domain] suchThat:^bool(ORInt j) {
               return [av[i] member:j];
            } in:^(ORInt j) {
               [cp label:av[i] with:j];
            } onFailure:^(ORInt j) {
               [cp diff:av[i] with:j];
            }];
            d = d + 1;
         }];
         [cp labelHeuristic:h];
         //[cp labelArray:av];
         @autoreleasepool {
            NSLog(@"x=");
            for(ORInt i=0;i<=n-1;i++) {
               NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
               [buf appendString:@"\t|"];
               for(ORInt j=0;j<=n-1;j++) {
                  [buf appendFormat:@"%2d ",[[x at:i :j] value]];
               }
               [buf appendString:@"|"];
               NSLog(@"%@",buf);
            }
            NSLog(@"y=");
            for(ORInt i=0;i<=n-1;i++) {
               NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
               [buf appendString:@"\t|"];
               for(ORInt j=0;j<=n-1;j++) {
                  [buf appendFormat:@"%2d ",[[y at:i :j] value]];
               }
               [buf appendString:@"|"];
               NSLog(@"%@",buf);
            }
            
            NSLog(@"z=");
            for(ORInt i=0;i<=n-1;i++) {
               NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
               [buf appendString:@"\t|"];
               for(ORInt j=0;j<=n-1;j++) {
                  [buf appendFormat:@"%2d ",[[z at:i :j] value]];
               }
               [buf appendString:@"|"];
               NSLog(@"%@",buf);
            }
            
         }
      }];
       
      ORLong endTime = [ORRuntimeMonitor wctime];      
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   NSLog(@"malloc: %@",mallocReport());
   return 0;
}

