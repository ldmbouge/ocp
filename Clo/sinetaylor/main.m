#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
/**
 
 def sineTaylor(x: Real): Real = {
 require(−2.0 < x && x < 2.0)
 x − (x∗x∗x)/6.0 + (x∗x∗x∗x∗x)/120.0 − (x∗x∗x∗x∗x∗x∗x)/5040.0
 } ensuring(res => −1.0 < res && res < 1.0 && res +/− 1e−14)
 

 **/
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            
            id<ORModel> model = [ORFactory createModel];
            
            id<ORFloatVar> x = [ORFactory floatVar:model low:-2.0f up:2.0f];
            id<ORFloatVar> res = [ORFactory floatVar:model];
            
            [model add:[res eq:[[[x sub:
                                 [[x mul:[x mul:x]] div:@(6.0f)]] plus:
                                 [[x mul:[x mul:[x mul:[x mul:x]]]] div:@(120.0f)]] sub:
                                [[x mul:[x mul:[x mul:[x mul:[x mul:[x mul:x]]]]]] div:@(5040.0f)]]]];
            
            
            [model add:[res gt:@(-1.0f)]];
            [model add:[res lt:@(1.0f)]];
            
            
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
