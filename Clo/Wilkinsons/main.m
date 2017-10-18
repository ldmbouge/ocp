#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 f(x, y) = (1-x)^2 + 100(y-x^2)^2 + 1
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            ORInt n = 4;
            if(n<1) {
                @throw [[ORExecutionError alloc] initORExecutionError: "Erreur n < 1"];
            }
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, n) low:-1.f up:INFINITY];
            id<ORFloatVar> p = [ORFactory floatVar:model];
            id<ORFloatVar> res = [ORFactory floatVar:model];
            
            id<ORExpr> cst = x[0];
            id<ORExpr> cst2 = p;
            
            for(int i = 1; i<n ;i++){
                ORFloat i_f = (ORFloat)i;
                cst = [cst mul:[x[i] plus:@(i_f)]];
            }
            for(int i = 0; i<(n-1);i++){
                cst2 = [cst2 mul:x[i]];
            }
            [model add:[res eq:[cst plus:cst2]]];
            
//            [model add:[p eq:@(2e-23f)]];
            [model add:[res eq:@(0.0f)]];
            
            
            id<ORFloatVarArray> vars = [model floatVars];
            //NSLog(@"%@",model);
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                
                
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                }
            } withTimeLimit:[args timeOut]];
            NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
        
    }
    return 0;
}
