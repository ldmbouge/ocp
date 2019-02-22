#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

#define NBLOOPS 409

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVarArray> f = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"f"];
         id<ORFloatVarArray> z = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"z"];
         id<ORGroup> g = [args makeGroup:model];
         [g add:[z[0] eq:@(1.)]];
         [g add:[f[0] eq:@(1.0e-10)]];
         for (ORUInt n = 0; n < NBLOOPS; n++) {
            if(n == 10){
               [g add:[f[n+1] eq:[[f[n] plus:z[n]] mul:[f[n] plus:z[n]]]]];
            }else{
               [g add:[f[n+1] eq:f[n]]];
            }
            [g add:[z[n+1] eq:[z[n] mul:@(10.)]]];
         }
         [g add:[f[NBLOOPS] gt:@(1.0e-20)]];
         [model add:g];
         id<CPProgram> cp = [args makeProgram:model];
         NSLog(@"%@",g);
         id<ORVarArray> dv = [model floatVars];
//         id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:dv engine:[cp engine]];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:dv];
//            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> d) {
//               [cp floatSplitD:i call:s withVars:d];
//            }];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORFloatVar> v in dv){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p doubleValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
         } withTimeLimit:[args timeOut]];
         
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}

