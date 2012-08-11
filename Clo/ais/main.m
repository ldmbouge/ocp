/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "ORFoundation/ORFactory.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

void labelFF(id<CPSolver> cp,id<ORIntVarArray> x)
{
   id<ORIntRange> R = RANGE(cp,[x low],[x up]);
   [ORControl forall: R
            suchThat: ^bool(int i) { return ![[x at:i] bound];}
           orderedBy: ^int(int i)  { return [[x at:i] domsize];}
                  do: ^(int i)     { [CPLabel var: [x at:i]]; }
    ];
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<CPSolver> cp = [CPFactory createSolver];  
      int n = 8;
      id<ORIntRange> R = RANGE(cp,1,n);
      id<ORIntRange> D = RANGE(cp,0,n-1);
      id<ORIntRange> SD = RANGE(cp,1,n-1);
      
      id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
      id<ORIntVarArray> sx = [CPFactory intVarArray: cp range:R domain: D];         
      id<ORIntVarArray> dx = [CPFactory intVarArray: cp range:SD domain: SD];         
      //id<CPHeuristic> h = [CPFactory createWDeg:cp restricted:sx];
      //id<CPHeuristic> h = [CPFactory createIBS:cp restricted:sx];
      id<CPHeuristic> h = [CPFactory createFF:cp restricted:sx];
      [cp add:[CPFactory alldifferent:sx consistency:DomainConsistency]];
      for(CPUInt i=SD.low;i<=SD.up;i++) {
         [cp add:[[dx at:i] eq:[CPFactory exprAbs:[[sx at:i+1] sub:[sx at:i]]]] consistency: DomainConsistency];
      }
      [cp add:[CPFactory alldifferent:dx consistency:DomainConsistency]];
      [cp add:[CPFactory less:[sx at:1] to:[sx at:2]]];
      [cp add:[CPFactory less:[dx at:n-1] to:[dx at:1]]];
      [cp solve: ^{
         [CPLabel heuristic:h];
         [CPLabel array:sx orderedBy:^ORInt(ORInt i) {
            return [[sx at:i] domsize];
         }];
         [nbSolutions incr];
         //NSLog(@"Solution: %@",sx);
      }];
      NSLog(@"#solutions: %@",nbSolutions);
      NSLog(@"Solver: %@",cp);
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

