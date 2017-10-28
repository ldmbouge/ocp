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
