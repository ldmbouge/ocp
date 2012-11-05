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
#import <objcp/CPLabel.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORConcretizer.h>
#import <objcp/CPError.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      int n = 8;
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORIntRange> D = RANGE(mdl,0,n-1);
      id<ORIntRange> SD = RANGE(mdl,1,n-1);
      
      id<ORInteger> nbSolutions = [ORFactory integer: mdl value:0];
      id<ORIntVarArray> sx = [ORFactory intVarArray: mdl range:R domain: D];
      id<ORIntVarArray> dx = [ORFactory intVarArray: mdl range:SD domain: SD];
      
      [mdl add:[ORFactory alldifferent:sx note:DomainConsistency]];
      for(ORUInt i=SD.low;i<=SD.up;i++) {
         [mdl add:[dx[i] eq:[[sx[i+1] sub:sx[i]] abs]] annotation: DomainConsistency];
      }
      [mdl add:[ORFactory alldifferent:dx note:DomainConsistency]];
      [mdl add:[sx[1]   leq:sx[2]]];
      [mdl add:[dx[n-1] leq:dx[1]]];
      
      //NSLog(@"MODEL: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      //id<CPHeuristic> h = [CPFactory createWDeg:cp restricted:sx];
      //id<CPHeuristic> h = [CPFactory createIBS:cp restricted:sx];
      id<CPHeuristic> h = [ORFactory createFF:cp restricted:sx];

      [cp solveAll: ^{
         [cp labelHeuristic:h];
         [cp labelArray:sx orderedBy:^ORFloat(ORInt i) {
            return [[sx at:i] domsize];
         }];
         [nbSolutions incr];
         NSLog(@"Solution: %@",sx);
      }];
      NSLog(@"#solutions: %@",nbSolutions);
      NSLog(@"Solver: %@",cp);
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

