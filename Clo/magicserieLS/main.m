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
   [ORStreamManager setRandomized];
   ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
   [args measure:^struct ORResult(){
      ORInt n = [args size];
      [ORStreamManager setRandomized];
      @autoreleasepool {
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
         id<ORIntVarArray> x = [ORFactory intVarArray: model range: R domain: R];
         for(ORInt i=0;i<n;i++)
            [model add: [Sum(model,j,R,[x[j] eq: @(i)]) eq: x[i] ]];
         [model add: [Sum(model,i,R,[x[i] mul: @(i)]) eq: @(n) ]];
         
         id<LSProgram> cp = [ORFactory createLSProgram: model annotation:nil];
         __block ORInt it = 0;
         ORInt* tabu = malloc(sizeof(ORInt)*n);
         for(ORInt k = 0;k < n;k++) tabu[k] = -1;
         [cp solve: ^{
            while ([cp violations] > 0 && it < 50 * n) {
               [cp selectMax:R suchThat:^ORBool(ORInt i) { return tabu[i] < it;}  orderedBy:^ORFloat(ORInt i) { return [cp getVarViolations:x[i]];} do:^(ORInt i) {
                  [cp selectMin:R  suchThat:^ORBool(ORInt v) { return [cp intValue:x[i]] != v;} orderedBy:^ORFloat(ORInt v) { return [cp deltaWhenAssign:x[i] to:v];} do:^(ORInt v) {
                     [cp label:x[i] with:v];
                     tabu[i] = it;
                  }];
               }];
               ++it;
            }
            if (it < 50 * n) {
               printf("Succeeds \n");
               for(ORInt i = 0; i < n; i++)
                  printf("%d ",[cp intValue:x[i]]);
               printf("\n");
            }
         }];
         id<ORSolution> b = [[cp solutionPool] best];
         if (b != nil) {
            NSLog(@"Found a solution in %d iter",it);
            id<ORIntArray> sv = [ORFactory intArray:cp range:x.range with:^ORInt(ORInt i) {return [b intValue:x[i]];}];
            NSLog(@"Sol: %@",sv);
         }
         struct ORResult r = REPORT(b!=nil, it, 0, 0);
         return r;
      }
   }];
}

