#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> z_0 = [ORFactory floatVar:model];
        id<ORFloatVar> y_0 = [ORFactory floatVar:model];
        id<ORFloatVar> x_0 = [ORFactory floatVar:model low:-1.0f up:1.0f];
        id<ORExpr> expr_0 = [ORFactory float:model value:1.f];
        id<ORExpr> c_0 = [x_0 neq: @(0.0f)];
        id<ORIntVar> b_if0 = [ORFactory boolVar:model];
        id<ORIntVar> b_else0 = [ORFactory boolVar:model];
        [model add:[c_0 eq:b_if0]];
        [model add:[[c_0 neg] eq:b_else0]];
        id<ORGroup> g_0 = [ORFactory group:model guard:b_if0];
        {
            [g_0 add:[y_0 eq: [x_0 mul: x_0]]];
            //assert(y != 0.f);
            [model add:[y_0 eq:@(0.0f)]];
            [g_0 add:[z_0 eq: [expr_0 div: y_0]]];
        }
        [model add:g_0];
        
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
