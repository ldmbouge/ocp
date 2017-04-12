#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> x_0 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_0 = [ORFactory floatVar:model];
        id<ORFloatVar> nu_0 = [ORFactory floatVar:model];
        [model add:[x2_0 eq: [x_0 mul: x_0]]];
        
        
        //assert(!(nu > 30 && x2 < 10 * nu));
        [model add:[nu_0 gt:@(30.f)]];
        [model add:[x2_0 lt:[nu_0 mul:@(10.f)]]];
        
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                
                
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                for(id<ORFloatVar> v in vars)
                    NSLog(@"%@ : %f (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                
                found=true;
                
            } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
