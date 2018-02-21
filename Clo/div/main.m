//
//  main.m
//  div
//
//  Created by Zitoun on 12/02/2018.
//
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

#define LARGE_NUMBER 4.0e+14
#define NBLOOPS 120

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORGroup> g = [args makeGroup:model];
         
         fesetround(FE_TONEAREST);
         id<ORFloatVarArray> d = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"d"];
         id<ORFloatVarArray> nextvalues = [ORFactory floatVarArray:model range:RANGE(model, 0, 0) names:@"nextvalues"];
         
         [g add:[d[0] eq:@(LARGE_NUMBER)]];
         for (int i = 0; i < NBLOOPS; i++){
            [g add:[nextvalues[0] geq:@(1.f)]];
            [g add:[nextvalues[0] gt:@(2.14748e+09f)]];
            [g add:[d[i+1] eq:[d[i] div:nextvalues[0]]]];
         }
         
         [g add:[d[NBLOOPS] lt:@(1.f)]];
         [model add:g];
         
         //         NSLog(@"%@", model);
         //         NSLog(@"---");
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         //         checksolution();
         fesetround(FE_TONEAREST);
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               id<CPFloatVar> cv = [cp concretize:v];
               found &= [p bound: v];
               NSLog(@"%@ = %16.16e (%s)",v,[cv value], [p bound:v] ? "YES" : "NO");
            }
            //            checksolution([p floatValue:y[0]], [p floatValue:y_opt[0]], [p floatValue:y[NBLOOPS]],[p floatValue:y_opt[NBLOOPS]], [p floatValue:diff]);
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}

