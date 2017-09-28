#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            
            id<ORModel> model = [ORFactory createModel];
            
           id<ORFloatVar> x = [ORFactory floatVar:model low:1.e6f up:1e30f];
            id<ORFloatVar> x2 = [ORFactory floatVar:model low:1e-15f up:1e-6f];
           id<ORFloatVar> res = [ORFactory floatVar:model];
            
            id<ORExpr> fc = [ORFactory float:model value:1.0f];
            id<ORExpr> fc2 = [ORFactory float:model value:1.0f];
            
           // [model add: [x eq:@(1e7f)]];
           // [model add: [x2 eq:@(1e-7f)]];
            //((1.0−10^−7)−1.0)∗10^7
            [model add:[res eq:[[[fc sub:x2] sub:fc2] mul:x]]];
            
            //res > -1
            [model add:[res eq:@(-1.19209289550781250000f)]];
            
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            //__block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                NSLog(@"Valeurs solutions : \n");
                for(id<ORFloatVar> v in vars){
                  //  found &= [p bound: v];
                    NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
                }
            } withTimeLimit:[args timeOut]];
         
            struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
