//
//  objlsTests.m
//  objlsTests
//
//  Created by Laurent Michel on 12/10/13.
//
//

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>
#import <objls/LSFactory.h>
#import <objls/LSConstraint.h>
#import <objls/LSSolver.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
   [args measure:^struct ORResult(){
      ORInt n = [args size];
      //[ORStreamManager setRandomized];
      @autoreleasepool {
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> D = RANGE(model, 1, n);
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:D domain:D];
         [model add:[ORFactory alldifferent:x]];
         [model add:[ORFactory alldifferent:All(model, ORExpr, i, D, [x[i] plus:@(i)])]];
         [model add:[ORFactory alldifferent:All(model, ORExpr, i, D, [x[i] sub:@(i)])]];
         id<LSProgram> ls = [ORFactory createLSProgram:model annotation:nil];
         __block ORInt it = 0;
         
         [ls solve: ^{
            
            printf("Violations: %d \n",[ls violations]);
            for(ORInt i = 1; i <= n; i++) {
               printf("x[%d] = %d\n",i,[ls intValue:x[i]]);
               printf("violations[%d] = %d\n",i,[ls getVarViolations: x[i]]);
            }
            while ([ls violations] > 0 && it < 50 * n) {
               [ls selectMax:D orderedBy:^ORFloat(ORInt i) { return [ls getVarViolations:x[i]];} do:^(ORInt i) {
                  [ls selectMin: D orderedBy:^ORFloat(ORInt v) { return [ls deltaWhenAssign:x[i] to:v];} do:^(ORInt v) {
                     [ls label:x[i] with:v];
                  }];
               }];
               ++it;
            }
         }];
         id<ORSolution> b = [[ls solutionPool] best];
         if (b != nil) {
            NSLog(@"Found a solution in %d iter",it);
            id<ORIntArray> sv = [ORFactory intArray:ls range:x.range with:^ORInt(ORInt i) {return [b intValue:x[i]];}];
            NSLog(@"Sol: %@",sv);
         }
         struct ORResult r = REPORT(b!=nil, it, 0, 0);
         return r;
      }
   }];
}

