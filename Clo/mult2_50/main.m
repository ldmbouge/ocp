#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

#define NBLOOPS 50
#define SMALL_NUMBER 1.0e-2f
#define STARTING_NUMBER 2.0f
#define MINIMUM_NUMBER 1.0e-1f

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVarArray> nextvalues = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"nextvalues"];
         id<ORFloatVarArray> m = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"m"];
         id<ORGroup> g = [args makeGroup:model];
         [g add:[m[0] eq:@(STARTING_NUMBER)]];
         for (ORUInt n = 0; n < NBLOOPS; n++) {
            [g add:[nextvalues[n] gt:@(MINIMUM_NUMBER)]];
            [g add:[nextvalues[n] lt:@(1.f)]];
            [g add:[m[n+1] eq:[m[n] mul:nextvalues[n]]]];
         }
         [g add:[m[NBLOOPS] lt:@(SMALL_NUMBER)]];
         [model add:g];
         id<CPProgram> cp = [args makeProgram:model];
         NSLog(@"%@",g);
         id<ORFloatVarArray> vars = [model floatVars];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            
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
