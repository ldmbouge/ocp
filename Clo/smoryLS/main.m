/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objls/LSFactory.h>
#import <objls/LSConstraint.h>
#import <objls/LSSolver.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntRange> Digit = RANGE(model,0,9);
         id<ORIntVar> S = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> E = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> N = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> D = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> M = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> O = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> R = [ORFactory intVar:model domain:Digit];
         id<ORIntVar> Y = [ORFactory intVar:model domain:Digit];
         id<ORIntVarArray> x = (id)[ORFactory idArray:model array:@[S,E,N,D,M,O,R,Y]];
         [model add:[ORFactory alldifferent:x]];
         [model add:[M neq:@0]];
         [model add:[S neq:@0]];
         id<ORIntArray>    c1 = [ORFactory intArray:model array:@[@1000,@100,@10,@1]];
         id<ORIntArray>    c2 = [ORFactory intArray:model array:@[@10000,@1000,@100,@10,@1]];
         id<ORIntVarArray> e1 = (id)[ORFactory idArray:model array:@[S,E,N,D]];
         id<ORIntVarArray> e2 = (id)[ORFactory idArray:model array:@[M,O,R,E]];
         id<ORIntVarArray> e3 = (id)[ORFactory idArray:model array:@[M,O,N,E,Y]];
         [model add:[[Sum(model, i, RANGE(model,0,3),[e1[i] mul:@([c1 at:i])]) plus:
                      Sum(model, i, RANGE(model,0,3),[e2[i] mul:@([c1 at:i])])] eq:
                     Sum(model, i, RANGE(model,0,4),[e3[i] mul:@([c2 at:i])])]
          ];
         NSArray* ca = [model constraints];
         id<ORIntRange> car = RANGE(model,0,(ORInt)[ca count] - 1);
         id<LSProgram> cp = [ORFactory createLSProgram:model annotation:notes];
         __block BOOL found = NO;
         __block ORInt it = 0;
         [cp solve:^{
	     printf("VIOL: %d\n",cp.getViolations);
	     for(int k=0;k < ca.count;k++) {
	       printf("\tviol(ca[%d]) = %d\n",k,[cp getCstrViolations:ca[k]]);
	     }
	     id<ORUniformDistribution> d = [ORFactory uniformDistribution:cp range:Digit];
            for(id<ORIntVar> xi in x)
               [cp label:xi with:[d next]];
            ORBounds b = idRange(x,(ORBounds){FDMAXINT,0});
            id<ORIntArray> tabu = [ORFactory intArray:cp range:RANGE(cp,b.min,b.max) with:^ORInt(ORInt k) {return -1;}];
            id<ORSelector> sw = [ORFactory selectMin:cp];
            while([cp getViolations] > 0) {
	      printf("VIOL: %d\n",cp.getViolations);
	      for(int k=0;k < ca.count;k++) {
		printf("\tviol(ca[%d]) = %d\n",k,[cp getCstrViolations:ca[k]]);
	      }
	      [cp selectRandom:car suchThat:^ORBool(ORInt i) { return [cp getCstrViolations:ca[i]] > 0;} do:^(ORInt i) {
		    id<ORConstraint> ci = ca[i];
		    [cp sweep:sw with:^{
			for(id<ORIntVar> xv in [ci allVars]) {
			  if ([tabu at:getId(xv)] > it) continue;
			  for(ORInt val = xv.domain.low; val <= xv.domain.up; val++) {
			    if ([cp deltaWhenAssign:xv to:val inConstraint:ci] >= 0) continue;
			    [sw neighbor:[cp deltaWhenAssign:xv to:val] do:^{
				  [cp label:xv with:val];
				  [tabu set:it+5 at:getId(xv)];
				  printf("(%d)",[cp getViolations]);fflush(stdout);
				}];
			  }
			}
		      }];
		  }];
               it++;
            }
            if ([cp intValue:M] == 0) {
               NSLog(@"Debug here...");
            }
            id<ORIntArray> sx = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) { return [cp intValue:x[i]];}];
            printf("\n");
            NSLog(@"Sol: %@",sx);
            found = YES;
         }];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(found, it,0,0);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

