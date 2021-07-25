/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>
#import <objls/LSFactory.h>
#import <objls/LSConstraint.h>
#import <objls/LSSolver.h>

#import "ORCmdLineArgs.h"

void show(id<LSProgram> cp,id<ORIntVarMatrix> m)
{
   id<ORIntRange> R = [m range: 0];
   id<ORIntRange> C = [m range: 1];
   for(ORInt i = [R low] ; i <= [R up]; i++) {
      for(ORInt j = C.low ; j <= C.up; j++)
         printf("%d  ",[cp intValue:[m at: i : j]]);
      printf("\n");
   }
   printf("\n");
}

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         FILE* f = fopen("sudokuFile3.txt","r");
         int nb;
         int r, c, v;
         fscanf(f,"%d \n",&nb);
         printf("number of entries %d \n",nb);
         id<ORModel> mdl = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntRange> R = RANGE(mdl,1,9);
         id<ORIntVarMatrix> x = [ORFactory intVarMatrix: mdl range: R : R domain: R];
         for(ORInt i = 0; i < nb; i++) {
            fscanf(f,"%d%d%d",&r,&c,&v);
            [notes hard:[mdl  add: [[x at: r : c] eq:@(v)]]];
         }
         for(ORInt i = 1; i <= 9; i++)
            [mdl add: [ORFactory alldifferent: All(mdl,ORIntVar,j,R,[x at:i :j])] ];
         for(ORInt j = 1; j <= 9; j++)
            [mdl add: [ORFactory alldifferent: All(mdl,ORIntVar,i,R,[x at:i :j])]];
         for(ORInt i = 0; i <= 2; i++)
            for(ORInt j = 0; j <= 2; j++)
               [notes hard:[mdl add: [ORFactory alldifferent: All2(mdl, ORIntVar,
                                                                   r, RANGE(mdl,i*3+1,i*3+3),
                                                                   c, RANGE(mdl,j*3+1,j*3+3),
                                                                   [x at:r :c])]]];
         
         id<LSProgram> __block cp = [ORFactory createLSProgram:mdl annotation:notes];
         ORInt __block it = 0;
         ORInt __block tLen  = 10;
         ORInt __block found = NO;
         [cp solve:
          ^() {
             ORBounds xb = idRange([ORFactory flattenMatrix:x], (ORBounds){FDMAXINT,0});
             id<ORIntRange> xidr = RANGE(cp, xb.min, xb.max);
             id<ORIntMatrix> tabu = [ORFactory intMatrix:cp range:xidr :xidr using:^int(ORInt i, ORInt j) { return 0;}];
             id<ORSelector>  ms   = [ORFactory selectMin:cp];
             while ([cp getViolations] > 0) {
                [cp sweep:ms with:^ {
                   for(id<ORConstraint> c in [cp modelHard]) {
                      NSSet* cx = [c allVars];
                      for(id<ORIntVar> x1 in cx) {
                         for(id<ORIntVar> x2 in cx) {
                            if (x1 == x2) continue;
                            if (![cp legalSwap:x1 with:x2]) continue;
                            if ([tabu at:getId(x1) :getId(x2)] > it) continue;
                            ORInt delta = [cp deltaWhenSwap:x1 with:x2];
                            //printf("Delta for swap(%d,%d): %d\n",getId(x1),getId(x2),delta);
                            [ms neighbor:delta do:^{
                               printf("from %d swap(%d,%d) \tdelta = %d\t it=%d\n",[cp getViolations],getId(x1),getId(x2),delta,it);
                               [cp swap:x1 with:x2];
                               [tabu set:it+tLen at:getId(x1) :getId(x2)];
                               [tabu set:it+tLen at:getId(x2) :getId(x1)];
                               if (delta <  0 && tLen >= 10) tLen /= 2;
                               if (delta >= 0 && tLen < 20)  tLen++;
                            }];
                         }
                      }
                   }
                }];
                it++;
             }
             show(cp,x);
             found = YES;
          }
          ];
         
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         [ORFactory shutdown];
         struct ORResult res = REPORT(found, it, 0,0);
         return res;
      }];
   }
   return 0;
}

