#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> R10x = [ORFactory floatVar:model low:1e3f up:1e4f];
        id<ORFloatVar> R11x = [ORFactory floatVar:model low:1e3f up:1e4f];
        id<ORFloatVar> R12x = [ORFactory floatVar:model low:0.0f up:1.f];
        id<ORFloatVar> R10y = [ORFactory floatVar:model low:0.0f up:1.f];
        id<ORFloatVar> R11y = [ORFactory floatVar:model low:1e3f up:1e4f];
        id<ORFloatVar> R12y = [ORFactory floatVar:model low:0.0f up:1.f];
        id<ORFloatVar> R20 = [ORFactory floatVar:model low:1e3f up:1e4f];
        id<ORFloatVar> R21 = [ORFactory floatVar:model low:1e3f up:1e4f];
        id<ORFloatVar> R22 = [ORFactory floatVar:model low:0.0f up:1.f];
        id<ORFloatVar> res = [ORFactory floatVar:model];
        
        [model add:[R20 eq: @(2.25f)]];
        [model add:[R21 eq: @(1.1f)]];
        [model add:[R22 eq: @(0.0f)]];
        
        
        [model add:[R10x eq: @(0.0f)]];
        [model add:[R11x eq: @(5.0f)]];
        [model add:[R12x eq: @(25.0f)]];
        
        
        [model add:[R10y eq: @(0.0f)]];
        [model add:[R11y eq: [R11x mul:R20]]];
        [model add:[R12y eq: [[R11y plus:[R12x sub:R11x]] mul:R21]]];
        
        
        float v = 1000000000.00999999046325683594;
        id<ORExpr> fc = [ORFactory float:model value:v];
        [model add:[res gt:fc]];
        
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
