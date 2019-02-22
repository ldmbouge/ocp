/**
 benchmark originaly comming from SMTLIB and modified to be SAT
 **/
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

#define NBLOOPS 150
#define LARGE_NUMBER 4.0e+14

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVarArray> nextvalues = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"nextvalues"];
         id<ORFloatVarArray> d = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"d"];
         id<ORGroup> g = [args makeGroup:model];
         [g add:[d[0] eq:@(LARGE_NUMBER)]];
         for (ORUInt n = 0; n < NBLOOPS; n++) {
            [g add:[nextvalues[n] geq:d[n]]];
            [g add:[d[n+1] eq:[d[n] div:nextvalues[n]]]];
         }
         [g add:[d[NBLOOPS] lt:@(1.0f)]];
         [model add:g];
         id<CPProgram> cp = [args makeProgram:model];
         NSLog(@"%@",g);
         id<ORFloatVarArray> vars = [model floatVars];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
         } withTimeLimit:[args timeOut]];
         
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}



