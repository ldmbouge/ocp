#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            id<ORModel> model = [ORFactory createModel];
//            id<ORIntVar> __retres_0 = [ORFactory intVar:model value:0];
            id<ORFloatVar> y_0 = [ORFactory floatVar:model];
            id<ORFloatVar> y_1 = [ORFactory floatVar:model];
            id<ORFloatVar> y_2 = [ORFactory floatVar:model];
            id<ORFloatVar> x_0 = [ORFactory floatVar:model];
            id<ORFloatVar> x_i = [ORFactory intVar:model value:1];
//            [model add:[[x_i eq: @(1)] lor:[x_i neq: @(1)]]];
//            [model add:[[x_0 eq: @(4.f)] lor:[x_0 neq: @(1.f)]]];
//            [model add:[x_0 eq: @(1e7f)]];
//            [model add:[y_0 eq:[x_0 plus:@(2.0f)]]];
            
            id<ORExpr> c_0 = [x_0 eq: @(1e7f)];
//            id<ORExpr> c_0 = [x_i eq: @(1)];
            id<ORIntVar> b_if0 = [ORFactory boolVar:model];
            id<ORIntVar> b_else0 = [ORFactory boolVar:model];
            [model add:[c_0 eq:b_if0]];
            [model add:[[c_0 neg] eq:b_else0]];
//            id<ORGroup> g_0 = [ORFactory group:model guard:b_if0];
//            {
//                [g_0 add:[y_0 eq: @(2.f)]];
//            }
//            id<ORGroup> g_1 = [ORFactory group:model guard:b_else0];
//            {
//                [g_1 add:[y_1 eq: @(1.f)]];
//            }
            [ORFactory phi:model on:c_0 var:y_2 with:y_0 or:y_1];
//            [model add:g_0];
//            
            
//            [model add:[__retres_0 eq: @(0)]];
            
            
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                [args launchHeuristic:(id<CPProgram>)p restricted:vars];
                for(id<ORFloatVar> v in vars)
                    printf("%16.16e\n ",[p floatValue:v]);
                found=true;
            } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
