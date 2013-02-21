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
#include <malloc/malloc.h>

  
int main(int argc, const char * argv[])
{
   mallocWatch();
   
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      int n = argc >= 2 ? atoi(argv[1]) : 8;
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORIntRange> D = RANGE(mdl,0,n-1);
      id<ORIntRange> SD = RANGE(mdl,1,n-1);
      
      id<ORInteger> nbSolutions = [ORFactory integer: mdl value:0];
      id<ORIntVarArray> sx = [ORFactory intVarArray: mdl range:R domain: D];
      id<ORIntVarArray> dx = [ORFactory intVarArray: mdl range:SD domain: SD];
      
      [mdl add:[ORFactory alldifferent:sx annotation:DomainConsistency]];
      for(ORUInt i=SD.low;i<=SD.up;i++) {
         [mdl add:[dx[i] eq:[[sx[i+1] sub:sx[i]] abs]] annotation: DomainConsistency];
      }
      [mdl add:[ORFactory alldifferent:dx annotation:DomainConsistency]];
      [mdl add:[sx[1]   leq:sx[2]]];
      [mdl add:[dx[n-1] leq:dx[1]]];
      
      //NSLog(@"MODEL: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      //id<CPHeuristic> h = [CPFactory createWDeg:cp restricted:sx];
      //id<CPHeuristic> h = [CPFactory createIBS:cp restricted:sx];
      id<CPHeuristic> h = [ORFactory createFF:cp restricted:sx];

      [cp solve: ^{
         [cp labelHeuristic:h];
         [cp labelArray:sx orderedBy:^ORFloat(ORInt i) {
            return [[sx at:i] domsize];
         }];
         [nbSolutions incr];
         id<ORIntArray> a = [ORFactory intArray:cp range: R  with:^ORInt(ORInt i) {
            return [sx[i] value];
         }];
         NSLog(@"Solution: %@",a);
      }];
      NSLog(@"#solutions: %@",nbSolutions);
      NSLog(@"Solver: %@",cp);
      //malloc_zone_print(malloc_default_zone(),NO);
      [cp release];
      [ORFactory shutdown];
      NSLog(@"malloc: %@",mallocReport());
   }
   return 0;
}

