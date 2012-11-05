/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORFoundation/ORFactory.h"
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>
#import <objcp/CPLabel.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORConcretizer.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,0,19);
      id<ORIntRange> D = RANGE(mdl,0,9);
            
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl  range:R domain: D];
      id<ORIntVarArray> c = [ORFactory intVarArray:mdl range:RANGE(mdl,0,8) domain: D];
      id<ORIntArray> lb = [ORFactory intArray:mdl range:D value:2];
      [mdl add:[ORFactory cardinality  :x low:lb up:lb]];
      
      [mdl add: [[x[0] mul:x[3]]             eq:[x[6] plus:[c[0] muli:10]]]];
      [mdl add: [[[x[1] mul:x[3]] plus:c[0]] eq:[x[7] plus:[c[1] muli:10]]]];
      [mdl add: [[[x[2] mul:x[3]] plus:c[1]] eq:x[8]]];
      
      [mdl add: [[x[0] mul:x[4]]             eq:[x[9] plus:[c[2]  muli:10]]]];
      [mdl add: [[[x[1] mul:x[4]] plus:c[2]] eq:[x[10] plus:[c[3] muli:10]]]];
      [mdl add: [[[x[2] mul:x[4]] plus:c[3]] eq:x[11]]];
      
      [mdl add: [[x[0] mul:x[5]]             eq:[x[12] plus:[c[4] muli:10]]]];
      [mdl add: [[[x[1] mul:x[5]] plus:c[4]] eq:[x[13] plus:[c[5] muli:10]]]];
      [mdl add: [[[x[2] mul:x[5]] plus:c[5]] eq:x[14]]];
      
      [mdl add: [x[6]             eq:x[15]]];
      [mdl add: [[x[7] plus:x[9]] eq:[x[16] plus:[c[6] muli:10]]]];
      
      id<ORIntVar>* px  = (id<ORIntVar>[]){x[8],x[10],x[12],c[6]};
      id<ORIntVar>* ppx = (id<ORIntVar>[]){x[11],x[13],c[7]};
      id<ORExpr> lhs1 = Sum(mdl, i, RANGE(mdl, 0, 3), px[i]);
      id<ORExpr> lhs2 = Sum(mdl,i,RANGE(mdl,0,2),ppx[i]);
      [mdl add: [lhs1              eq:[x[17] plus:[c[7] muli:10]]]];
      [mdl add: [lhs2              eq:[x[18] plus:[c[8] muli:10]]]];
      [mdl add: [[x[14] plus:c[8]] eq:x[19]]];

      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<CPHeuristic> h = [ORFactory createFF:cp];
      
      [cp solve: ^{
         [cp labelHeuristic:h];
         NSLog(@"Solution: %@",x);
         NSLog(@"Solver: %@",cp);
      }];
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

