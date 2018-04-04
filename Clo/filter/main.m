/**
 Benchmark from SMTLIB Griggio
 **/
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

#define NBLOOPS 2
#define MAX_VALUE 2.14748e+09f
#define LARGE_NUMBER 4.0e+14

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
//         float P;
//         float X_;
//         float E_0;
//         float E_1;
//         float S_0;
//         float S_1;
         id<ORFloatVarArray> P = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"P"];
         id<ORFloatVarArray> X = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS+1) names:@"X"];
         id<ORFloatVarArray>E_0 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"E_0"];
         id<ORFloatVarArray>E_1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"E_1"];
         id<ORFloatVarArray>S_0 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"S_0"];
         id<ORFloatVarArray>S_1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"S_1"];
         id<ORGroup> g = [args makeGroup:model];
         //X_ = 0.2 * X_ + 5;
         [g add:[X[1] eq:[[X[0] mul:@(0.2f)] plus:@(5.f)]]];
         for (ORUInt n = 1; n < NBLOOPS; n++) {
//            X_ = 0.9 * X_ + 35;
            [g add:[X[n+1] eq:[[X[n] mul:@(0.9f)] plus:@(35.f)]]];
            //S_0 = X_;
            //         P = X_;
            //         E_0 = X_;
            if(n==1){
               [g add:[S_0[n-1] eq:X[n+1]]];
               [g add:[P[n-1] eq:X[n+1]]];
               [g add:[E_0[n-1] eq:X[n+1]]];
            }else{
//               P = ((((( 0.5 * X_)-(E_0 * 0.7))+(E_1 * 0.4))+(S_0 * 1.5))-(S_1 * 0.7));
               [g add:[P[n-1] eq:[[[[[X[n+1] mul:@(0.5f)] sub:[E_0[n] mul:@(0.7)]] plus:[E_1[n-1] mul:@(0.4f)]] plus:[S_0[n] mul:@(1.5f)]] sub:[S_1[n-1] mul:@(0.7f)]]]];
            }
            //         E_1 = E_0;
            //         E_0 = X_;
            //         S_1 = S_0;
            //         S_0 = P;
            [g add:[E_1[n-1] eq:E_0[n-1]]];
            [g add:[E_0[n] eq:X[n+1]]];
            [g add:[S_1[n-1] eq:S_0[n-1]]];
            [g add:[S_0[n] eq:P[n-1]]];
            //         assert(P >= -1327.05 && P <= 1327.05);
            [g add:[[P[n-1] lt:@(-1327.05f)] lor:[P[n] gt:@(1327.05f)]]];
         }
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

