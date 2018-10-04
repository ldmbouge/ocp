#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

#define p1 1.0e+9
#define p2 1.0e-8
#define p3 1.0e-7

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
//         id<ORFloatVar> x = [ORFactory floatVar:model name:@"x"];
//         id<ORFloatVar> p = [ORFactory floatVar:model name:@"p4"];
         id<ORDoubleVar> x = [ORFactory doubleVar:model name:@"x"];
         id<ORDoubleVar> p = [ORFactory doubleVar:model name:@"p4"];
         id<ORGroup> g = [args makeGroup:model];
         
         [g add:[x geq:@(-1e20)]];
         [g add:[x leq:@(1e20)]];
         [g add:[p geq:@(-1.0)]];
         [g add:[p leq:@(1.0)]];
         
         [g add:[x leq:@(p1)]];
         [g add:[[x plus:@(p3)] gt:@(p1)]];
         
         [g add:[x plus:@(p2)]];
         
//         [g add:[p eq:@(1.0e-7)]];
         
         [model add:g];
         id<CPProgram> cp = [args makeProgram:model];
         NSLog(@"%@",g);
         id<ORVarArray> dv = [model doubleVars];
                  id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:dv engine:[cp engine]];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
//            [args launchHeuristic:((id<CPProgram>)p) restricted:dv];
                        [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> d) {
                           [cp floatSplitD:i call:s withVars:d];
                        }];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORVar> v in dv){
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
