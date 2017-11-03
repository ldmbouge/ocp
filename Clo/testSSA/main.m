#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            id<ORModel> model = [ORFactory createModel];
//            id<ORIntVar> __retres_0 = [ORFactory intVar:model value:0];
//            id<ORFloatVar> y_0 = [ORFactory floatVar:model];
//            id<ORFloatVar> y_1 = [ORFactory floatVar:model];
//            id<ORFloatVar> y_2 = [ORFactory floatVar:model];
            //            id<ORFloatVar> x_0 = [ORFactory floatVar:model];
//            id<ORIntVar> z = [ORFactory intVar:model domain:RANGE(model, 0, 10) ];
//            id<ORIntVar> a = [ORFactory intVar:model domain:RANGE(model, 0, 10) ];
//            id<ORIntVar> b = [ORFactory intVar:model domain:RANGE(model, 0, 10) ];
            id<ORFloatVar> zf = [ORFactory floatVar:model low:5.f up:10.f];
            id<ORFloatVar> af = [ORFactory floatVar:model low:0.2f up:0.4f];
            id<ORFloatVar> bf = [ORFactory floatVar:model low:0.2f up:0.4f];
//            [model add:[[x_i eq: @(1)] lor:[x_i neq: @(1)]]];
//            [model add:[[x_0 eq: @(4.f)] lor:[x_0 neq: @(1.f)]]];
//            [model add:[x_0 eq: @(1e7f)]];
//            [model add:[y_0 eq:[x_0 plus:@(2.0f)]]];
            
//            [model add: [[[a plus:b] geq:z] lor: [z geq:@(1)]]];
//            [model add: [[[af plus:bf] geq:z] lor: [z geq:@(20.f)]]];
           [model add:[[af plus:bf] geq:zf]];
//            [model add:[af geq:@(1.0f)]];
//            [model add:[bf geq:@(5.0f)]];
//            [model add:[zf geq:@(9.0f)]];
//            id<ORExpr> c_0 = [x_0 eq: @(1e7f)];
//            id<ORExpr> c_0 = [x_i eq: @(1)];
//            id<ORIntVar> b_if0 = [ORFactory boolVar:model];
//            id<ORIntVar> b_else0 = [ORFactory boolVar:model];
//            [model add:[c_0 eq:b_if0]];
//            [model add:[[c_0 neg] eq:b_else0]];
//            id<ORGroup> g_0 = [ORFactory group:model guard:b_if0];
//            {
//                [g_0 add:[y_0 eq: @(2.f)]];
//            }
//            id<ORGroup> g_1 = [ORFactory group:model guard:b_else0];
//            {
//                [g_1 add:[y_1 eq: @(1.f)]];
//            }
//            [ORFactory phi:model on:c_0 var:y_2 with:y_0 or:y_1];
//            [model add:g_0];
//            
            
//            [model add:[__retres_0 eq: @(0)]];
            
            
            id<ORFloatVarArray> vars = [model floatVars];
            NSLog(@"%@",model);
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                [args launchHeuristic:(id<CPProgram>)p restricted:vars];
                for(id<ORFloatVar> v in vars)
                    NSLog(@"%@ (bound %s) = %16.16e\n ",v,[p bound:v] ? "YES" : "NO",[p floatValue:v]);
                found=true;
            } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
