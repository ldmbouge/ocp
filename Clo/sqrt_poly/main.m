#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> I_0 = [ORFactory floatVar:model low:1.f up:3.f];
        id<ORFloatVar> S_0 = [ORFactory floatVar:model];
        id<ORFloatVar> S_1 = [ORFactory floatVar:model];
        id<ORFloatVar> S_2 = [ORFactory floatVar:model];
        id<ORExpr> c_0 = [I_0 geq: @(2.f)];
        id<ORIntVar> b_if0 = [ORFactory boolVar:model];
        id<ORIntVar> b_else0 = [ORFactory boolVar:model];
        id<ORExpr> sqrt2_0 = [ORFactory float:model value:1.414213538169860839843750f];
        id<ORExpr> expr_0 = [ORFactory float:model value:1.f];
        id<ORExpr> expr_1 = [ORFactory float:model value:0.5f];
        id<ORExpr> expr_2 = [ORFactory float:model value:0.125f];
      
        id<ORExpr> expr_3 = [ORFactory float:model value:1.f];
        id<ORExpr> expr_4 = [ORFactory float:model value:0.5f];
        id<ORExpr> expr_5 = [ORFactory float:model value:0.125f];
        
        [model add:[c_0 eq:b_if0]];
        [model add:[[c_0 neg] eq:b_else0]];
        
        
        id<ORGroup> g_0 = [ORFactory group:model guard:b_if0];
        {
            [g_0 add:[S_0 eq: [sqrt2_0 mul:[expr_0 plus:[[[I_0 div:@(2.0f)] sub:@(1.0f)] mul:[expr_1 sub:[expr_2 mul:[[I_0 div:@(2.0f)] sub:@(1.0f)]]]]]]]];
        }
        id<ORGroup> g_1 = [ORFactory group:model guard:b_else0];
        {
            [g_1 add:[S_1 eq:[expr_3 plus:[[I_0 sub:@(-1.0f)] mul:[expr_4 plus:[[I_0 sub:@(1.0f)] mul:[expr_5 plus:[[I_0 sub:@(-1.0f)] mul:@(0.0625f)]]]]]]]];
        }
        [model add:[S_2 ssa:S_1 with:S_0]];
        [model add:g_0];
        
        //assert(S >= 1. && S <= 2.);
        [model add:[[S_2 lt:@(1.0f)] lor:[S_2 gt:@(2.0f)]]];
        
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
