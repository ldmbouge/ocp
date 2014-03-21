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
         id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,n+1)];
         for(ORInt i=0;i<n;i++)
            ca[i] = [model add: [Sum(model,j,R,[x[j] eq: @(i)]) eq: x[i] ]];
         ca[n] = [model add: [Sum(model,i,R,[x[i] mul: @(i)]) eq: @(n) ]];  // We can't query constraints yet. The TAU map is not build by flatten.
//         [model add: [Sum(model,i,R,[x[i] mul: @(i)]) eq: @(n) ]];
         ca[n+1] = [model add: [Sum(model,i,R,[x[i] mul: @(i-1)]) eq: @0 ]];
         
         id<LSProgram> cp = [ORFactory createLSProgram: model annotation:nil];
         __block ORInt itt=0;
         ORInt* tabu = malloc(sizeof(ORInt)*n);
         for(ORInt k = 0;k < n;k++) tabu[k] = -1;
         [cp solve: ^{
            while ([cp violations] > 0) {
               for(ORInt k = 0;k < n;k++) tabu[k] = -1;
               for(id<ORIntVar> xi in x)
                  [cp label:xi with:0];
               __block ORInt it = 0;
               while ([cp violations] > 0 && it < 50 * n) {

//                  id<ORIntArray> sv = [ORFactory intArray:cp range:x.range with:^ORInt(ORInt i) {return [cp intValue:x[i]];}];
//                  NSLog(@"SV: %@",sv);
//                  @autoreleasepool {
//                     for(ORInt k = 0;k  <= ca.range.up;k++) {
//                        NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
//                        [buf appendFormat:@"cstr[%2d].viols() = [",k];
//                        for(ORInt i = R.low;i  <= R.up;i++) {
//                           [buf appendFormat:@"%2d",[cp getVarViolations:x[i] forConstraint:ca[k]]];
//                           if (i < R.up)
//                              [buf appendString:@"," ];
//                           else [buf appendString:@"]"];
//                        }
//                        NSLog(@"%@",buf);
//                     }
//                  }
//                  for(ORInt i = R.low;i  <= R.up;i++) {
//                     NSLog(@"\tviol(x[%d]) = %d",i,[cp getVarViolations:x[i]]);
//                  }

                  [cp selectMax:R suchThat:^ORBool(ORInt i) { return tabu[i] < it;}  orderedBy:^ORFloat(ORInt i) { return [cp getVarViolations:x[i]];} do:^(ORInt i) {
                     
//                     @autoreleasepool {
//                        for(ORInt k = 0;k  <= ca.range.up;k++) {
//                           NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
//                           [buf appendFormat:@"cstr[%2d].DELTA() = [",k];
//                           for(ORInt v = R.low;v  <= R.up;v++) {
//                              [buf appendFormat:@"%2d",[cp deltaWhenAssign:x[i] to:v inConstraint:ca[k]]];
//                              if (v < R.up)
//                                 [buf appendString:@"," ];
//                              else [buf appendString:@"]"];
//                           }
//                           NSLog(@"DELTA: %@",buf);
//                        }
//                        for(ORInt v = R.low;v  <= R.up;v++) {
//                           NSLog(@"\tDELTA(x[%d] to %d) = %d",i,v,[cp deltaWhenAssign:x[i] to:v]);
//                        }
//                     }
                     
                     [cp selectMin:R  suchThat:^ORBool(ORInt v) { return [cp intValue:x[i]] != v;} orderedBy:^ORFloat(ORInt v) { return [cp deltaWhenAssign:x[i] to:v];} do:^(ORInt v) {
                        [cp label:x[i] with:v];
                        tabu[i] = it + 3;
                     }];
                  }];
                  ++it;
               }
               NSLog(@"(%d)",[cp violations]);
               itt += it;
            }
            printf("Succeeds \n");
            for(ORInt i = 0; i < n; i++)
               printf("%d ",[cp intValue:x[i]]);
            printf("\n");
         }];
         id<ORSolution> b = [[cp solutionPool] best];
         if (b != nil) {
            NSLog(@"Found a solution in %d iter",itt);
            id<ORIntArray> sv = [ORFactory intArray:cp range:x.range with:^ORInt(ORInt i) {return [b intValue:x[i]];}];
            NSLog(@"Sol: %@",sv);
         }
         struct ORResult r = REPORT(b!=nil, itt, 0, 0);
         return r;
      }
   }];
}

