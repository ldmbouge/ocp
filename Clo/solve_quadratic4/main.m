#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> c_0 = [ORFactory floatVar:model];
        id<ORFloatVar> a_0 = [ORFactory floatVar:model];
        id<ORFloatVar> disc_0 = [ORFactory floatVar:model];
        id<ORFloatVar> b_0 = [ORFactory floatVar:model];
        [model add:[disc_0 eq: [[b_0 mul: b_0] sub: [[a_0 mul: @(4.0f)] mul: c_0]]]];
        
        //assert(!(a != 0 && b == 0 && disc == 0));
        [model add:[a_0 neq:@(0.0f)]];
        [model add:[b_0 eq:@(0.0f)]];
        [model add:[disc_0 eq:@(0.0f)]];
        
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                
                
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %f (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                }
                
            } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];

    }
    return 0;
}
