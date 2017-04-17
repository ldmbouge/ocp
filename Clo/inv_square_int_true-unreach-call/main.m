#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> z_0 = [ORFactory floatVar:model];
        id<ORFloatVar> y_0 = [ORFactory floatVar:model];
        id<ORFloatVar> x_0 = [ORFactory floatVar:model low:-10.0f up:10.0f];
        id<ORExpr> expr_0 = [ORFactory float:model value:1.f];
        [model add:[y_0 eq: [[x_0 mul: x_0] sub: @(2.f)]]];
        
        //assert(y != 0.f);
        [model add:[y_0 eq:@(0.0f)]];
        
        [model add:[z_0 eq: [expr_0 div: y_0]]];
        
        id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                
                
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                for(id<ORFloatVar> v in vars)
                    NSLog(@"%@ : %f (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                
                found=true;
                
            } withTimeLimit:[args timeOut]];
            NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
