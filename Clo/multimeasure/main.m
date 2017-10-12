#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 f(x, y) = (1-x)^2 + 100(y-x^2)^2 + 1
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            ORInt n = 1;
            if(n<1) {
                @throw [[ORExecutionError alloc] initORExecutionError: "Erreur n < 1"];
            }
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, n) low:-1.f up:1.f];
            id<ORFloatVar> res = [ORFactory floatVar:model];
            
            id<ORExpr> fc = [ORFactory float:model value:1.0f];
            
            
            id<ORExpr> fc2 = [ORFactory float:model value:100.0f];
            
            id<ORExpr> cst = [[[fc sub:x[0]] mul:[fc sub:x[0]]] plus:[[fc2 mul:[x[1] sub:[x[0] mul:x[0]]]] mul:[x[1] sub:[x[0] mul:x[0]]]]];
            
            for(int i = 1; n>1 && i < [x count]-1;i++){
                cst = [cst plus:[[[[fc sub:x[i]] mul:[fc sub:x[i]]] plus:[[fc2 mul:[x[i+1] sub:[x[i] mul:x[i]]]] mul:[x[i+1] sub:[x[i] mul:x[i]]]]] plus:@(1.0f)]];
            }
            
            [model add:[res eq:cst]];
            //            [model add:[res eq:[[[fc sub:x] mul:[fc sub:x]] plus:[[fc2 mul:[y sub:[x mul:x]]] mul:[y sub:[x mul:x]]]]]];
            
            
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
