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
#import <ORProgram/CPFirstFail.h>


int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
       
      id<ORIntRange> Digit = RANGE(model,1,9);
      id<ORIntVarArray> ad = [ORFactory intVarArray:model range:RANGE(model,1,9) domain:Digit];
      id<ORIntVar> A = ad[1];
      id<ORIntVar> B = ad[2];
      id<ORIntVar> C = ad[3];
      id<ORIntVar> D = ad[4];
      id<ORIntVar> E = ad[5];
      id<ORIntVar> F = ad[6];
      id<ORIntVar> G = ad[7];
      id<ORIntVar> H = ad[8];
      id<ORIntVar> I = ad[9];
      id<ORIntVarArray> denom = [ORFactory intVarArray:model range:RANGE(model,1,3) domain:RANGE(model,0,100)];
      id<ORIntVar> rhs = [ORFactory intVar:model domain:RANGE(model,0,1000000)];
      [model add:[ORFactory alldifferent:ad]];
      [model add:[denom[1] eq: [[B muli:10] plus: C]]];
      [model add:[denom[2] eq: [[E muli:10] plus: F]]];
      [model add:[denom[3] eq: [[H muli:10] plus: I]]];
      [model add:[rhs eq: Prod(model, k, RANGE(model,1,3), denom[k])]];
      [model add:[[[[[A mul:denom[2]] mul: denom[3]] plus:
                    [[D mul: denom[1]] mul:denom[3]]] plus:
                   [[G mul: denom[1]] mul:denom[2]]] eq: rhs]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solveAll:^{
         [cp forall:[ad range] suchThat:^bool(ORInt i) { return ![ad[i] bound];} orderedBy:^ORInt(ORInt i) { return [ad[i] domsize];} do:^(ORInt i) {
            [cp tryall:Digit suchThat:^bool(ORInt d) { return [ad[i] member:d];} in:^(ORInt d) {
               [cp label:ad[i] with:d];
            } onFailure:^(ORInt d) {
               [cp diff:ad[i] with:d];
            }];
         }];
         @autoreleasepool {
            NSLog(@"Got a solution: %@",ad);
         }
      }];

      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

