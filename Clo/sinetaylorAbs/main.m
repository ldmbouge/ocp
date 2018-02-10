#import <ORProgram/ORProgram.h>
#import <objcp/CPFloatVarI.h>
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
           
           
           id<ORFloatVar> y = [ORFactory floatVar:model low:300.f up:1.e5f name:@"y"];
           id<ORFloatVar> tmp = [ORFactory floatVar:model name:@"tmp"];
           id<ORFloatVar> tmp2 = [ORFactory floatVar:model name:@"tmp2"];
           id<ORFloatVar> tmp3 = [ORFactory floatVar:model name:@"tmp3"];
           id<ORFloatVar> tmp4 = [ORFactory floatVar:model name:@"tmp4"];
           id<ORFloatVar> tmp5 = [ORFactory floatVar:model  name:@"tmp5"];
           id<ORFloatVar> tmp6 = [ORFactory floatVar:model  name:@"tmp6"];
           id<ORFloatVar> res = [ORFactory floatVar:model name:@"res"];
           id<ORFloatVar> x = [ORFactory floatVar:model low:-5.f up:1.e10f  name:@"y"];
           
           [model add:[tmp eq:[x div:@(2.0f)]]];
           [model add:[tmp2 eq:[res div:@(10.0f)]]];
           [model add:[tmp3 eq:[x div:@(10.0f)]]];
           
           [model add:[tmp4 eq:[tmp2 mul:[y mul:y]]]];
           [model add:[tmp5 eq:[tmp3 mul:[[y mul:y] mul:y]]]];
           [model add:[tmp6 eq:[[tmp3 mul:tmp2] mul:y]]];
           
           [model add:[res eq:[x plus:y]]];
           [model add:[res eq:x]];
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
           fesetround(FE_TONEAREST);
           NSLog(@"%@",model);
           __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                NSLog(@"Valeurs solutions : \n");
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
                }
            } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(0, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
