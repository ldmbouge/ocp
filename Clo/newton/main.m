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
            id<ORFloatVar> x = [ORFactory floatVar:model];
            id<ORFloatVar> r_0 = [ORFactory floatVar:model];
            id<ORFloatVar> f_x = [ORFactory floatVar:model];
            id<ORFloatVar> fp_x = [ORFactory floatVar:model];
            
            
            id<ORExpr> fc = [ORFactory float:model value:1.0f];
            
            [model add:[x lt:@(0.0f)]];
            
            
            [model add:[f_x eq:[[[x sub:[[[x mul:x] mul:x] div:@(6.0f)]] plus:[[[[[x mul:x] mul:x] mul:x] mul:x] div:@(120.0f)]]
                  plus:[[[[[[[x mul:x] mul:x] mul:x] mul:x] mul:x] mul:x] div:@(5040.0f)]]]];
            
            
            [model add:[fp_x eq:[[[fc sub:[[x mul:x] div:@(2.0f)]] plus:[[[[x mul:x] mul:x] mul:x] div:@(24.0f)]]
                                plus:[[[[[[x mul:x] mul:x] mul:x] mul:x] mul:x] div:@(730.0f)]]]];
            
            [model add:[r_0 eq:[x sub:[f_x div:fp_x]]]];
            
            [model add:[r_0 geq:@(1.0f)]];
            
            
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
