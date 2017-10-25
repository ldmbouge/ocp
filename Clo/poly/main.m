#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 
 int main(void)
 {
 float x,y,z;
 
 x = __BUILTIN_DAED_FBETWEEN(0,1);
 y = (x-1)*(x-1)*(x-1)*(x-1);
 z = x*x*x*x - 4*x*x*x + 6*x*x - 4*x + 1;
 }
*/

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVar> z = [ORFactory floatVar:model];
            id<ORFloatVar> y = [ORFactory floatVar:model];
            id<ORFloatVar> x = [ORFactory floatVar:model low:0.f up:1.f];
            
            [model add:[y eq:[[[[x sub:@(1.f)] mul:[x sub:@(1.f)]] mul:[x sub:@(1.f)]] mul:[x sub:@(1.0f)]]]];
            
            [model add:[z eq:[[[[[[[x mul:x] mul:x] mul:x] sub:
                              [[[[x mul:@(4.f)] mul:x] mul:x] mul:x]] plus:
                              [[x mul:@(6.0f)] mul:x]] sub:
                              [x mul:@(4.f)]] plus:
                              @(1.f)]]];
            
            [model add:[y gt:z]];
            
            
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
