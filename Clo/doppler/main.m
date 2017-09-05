#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
/**
 
 
 def doppler(u: Real, v: Real, T: Real): Real = {
 require(−100 < u && u < 100 && 20 < v && v < 20000 &&
 −30 < T && T < 50)
 val t1 = 331.4 + 0.6 ∗ T
 (− (t1) ∗v) / ((t1 + u)∗(t1 + u)) } ensuring(res ⇒ res +/− 1e−12)
 
 **/
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            
            id<ORModel> model = [ORFactory createModel];
            
            id<ORFloatVar> u = [ORFactory floatVar:model low:-100.0f up:100.0f];
            id<ORFloatVar> v = [ORFactory floatVar:model low:20.0f up:20000.0f];
            id<ORFloatVar> t = [ORFactory floatVar:model low:-30.0f up:50.0f];
            id<ORFloatVar> t1 = [ORFactory floatVar:model];
            id<ORFloatVar> res = [ORFactory floatVar:model];
            
            id<ORExpr> fc = [ORFactory float:model value:331.4f];
            
            [model add:[t1 eq:[fc plus:[t mul:@(0.6f)]]]];
            
            [model add:[res eq:[[[x sub:
                                  [[x mul:[x mul:x]] div:@(6.0f)]] plus:
                                 [[x mul:[x mul:[x mul:[x mul:x]]]] div:@(120.0f)]] sub:
                                [[x mul:[x mul:[x mul::[x mul::[x mul:[x mul:x]]]]]] div:@(5040.0f)]]]]
            
            
            [model add:[res gt:@(-1.0f)]]
            [model add:[res lt:@(1.0f)]]
            
            
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                NSLog(@"Valeurs solutions : \n");
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
                }
            } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
