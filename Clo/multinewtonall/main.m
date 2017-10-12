#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 float f(float x)
 {
 return x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
 }
 
 float fp(float x)
 {
 return 1 - (x*x)/2.0f + (x*x*x*x)/24.0f + (x*x*x*x*x*x)/720.0f;
 }
 
 
 __VERIFIER_assume(IN > -0.2f && IN < 0.2f);
 
 float x = IN - f(IN)/fp(IN);
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, 15)];
            id<ORFloatVarArray> y = [ORFactory floatVarArray:model range:RANGE(model, 0, 11) low:0.f up:1e6f];
            id<ORFloatVar> z = [ORFactory floatVar:model];
            id<ORFloatVar> r_0 = [ORFactory floatVar:model];
            id<ORFloatVar> f_x = [ORFactory floatVar:model];
            id<ORFloatVar> fp_x = [ORFactory floatVar:model];
            
            
            id<ORExpr> fc = [ORFactory float:model value:1.0f];
            
            
            
            [model add:[f_x eq:[[[x[0] sub:[[[x[1] mul:x[2]] mul:x[3]] div:@(6.0f)]] plus:[[[[[x[4] mul:x[5]] mul:x[6]] mul:x[7]] mul:x[8]] div:@(120.0f)]]
                                plus:[[[[[[[x[9] mul:x[10]] mul:x[11]] mul:x[12]] mul:x[13]] mul:x[14]] mul:x[15]] div:@(5040.0f)]]]];
            
            
            [model add:[fp_x eq:[[[fc sub:[[y[0] mul:y[1]] div:@(2.0f)]] plus:[[[[y[2] mul:y[3]] mul:y[4]] mul:y[5]] div:@(24.0f)]]
                                 plus:[[[[[[y[6] mul:y[7]] mul:y[8]] mul:y[9]] mul:y[10]] mul:y[11]] div:@(730.0f)]]]];
            
            [model add:[r_0 eq:[z sub:[f_x div:fp_x]]]];
            
            [model add:[r_0 eq:@(1.0f)]];
            
            
            id<ORFloatVarArray> vars = [model floatVars];
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
