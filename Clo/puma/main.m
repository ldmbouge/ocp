#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 Variable:
 x : array[1..8] in [-1..1] start 1;
 Body:
 solve system all
 constraint tr[i in [1,4]]: x[2*i-1]^2 + x[2*i]^2 = 1;
 0.004731*x[1]*x[3] - 0.3578*x[2]*x[3]-0.1238*x[1]-0.001637*x[2]-0.9338*x[4]+x[7]-0.3571 = 0;
 0.2238*x[1]*x[3] + 0.7623*x[2]*x[3] + 0.2638*x[1] - 0.07745*x[2] - 0.6734*x[4] - 0.6022 = 0;
 x[6]*x[8] + 0.3578*x[1] + 0.004731*x[2] = 0;
 -0.7623*x[1] + 0.2238*x[2] + 0.3461 = 0;
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            ORInt n = 7;
            if(n<1) {
                @throw [[ORExecutionError alloc] initORExecutionError: "Erreur n < 1"];
            }
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, n) low:-0.5f up:1.f];
            id<ORFloatVarArray> tr = [ORFactory floatVarArray:model range:RANGE(model, 0, 3)];
            id<ORExpr> tmp;
            // constraint tr[i in [1,4]]: x[2*i-1]^2 + x[2*i]^2 = 1;
            for(int i = 0; i < [tr count]; i++){
                tmp = [[x[2*i] mul:x[2*i]] plus:[x[2*i+1] mul:x[2*i+1]]];
                [model add: [tmp eq:@(1.0f)]];
            }
            //0.004731*x[1]*x[3] - 0.3578*x[2]*x[3]-0.1238*x[1]-0.001637*x[2]-0.9338*x[4]+x[7]-0.3571 = 0;
            tmp = [[[[[[[[x[0] mul:@(0.004731f)] mul:x[2]] sub:[x[1] mul:@(0.3578f)]] mul:x[2]] sub:[x[0] mul:@(0.1238f)]] sub:[x[1] mul:@(0.001637f)]] sub:[x[3] mul:@(0.9338f)]] plus:x[7]];
            [model add:[tmp eq:@(0.3571f)]];
            
//            0.2238*x[1]*x[3] + 0.7623*x[2]*x[3] + 0.2638*x[1] - 0.07745*x[2] - 0.6734*x[4] - 0.6022 = 0;
            tmp = [[[[[[x[0] mul:@(0.2238f)] mul:x[2]] plus:[[x[1] mul:@(0.7623)] mul:x[2]]] plus:[x[0] mul:@(0.2638f)]] sub:[x[1] mul:@(0.07745f)]] sub:[x[3] mul:@(0.6734f)]];
            [model add:[tmp eq:@(0.6022f)]];
                   
//            x[6]*x[8] + 0.3578*x[1] + 0.004731*x[2] = 0;
            tmp = [[[x[5] mul:x[7]] plus:[x[0] mul:@(0.3578f)]] plus:[x[1] mul:@(0.004731f)]];
            [model add:[tmp eq:@(0.0f)]];
            
            //            -0.7623*x[1] + 0.2238*x[2] + 0.3461 = 0;
            tmp = [[x[0] mul:@(0.7623f)] plus:[x[1] mul:@(0.2238f)]];
            [model add:[tmp eq:@(0.3461f)]];
            
            
            id<ORFloatVarArray> vars = [model floatVars];
            NSLog(@"%@",model);
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
