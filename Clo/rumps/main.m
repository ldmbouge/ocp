#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> y_0 = [ORFactory floatVar:model];
        id<ORFloatVar> r_0 = [ORFactory floatVar:model];
        id<ORFloatVar> x_0 = [ORFactory floatVar:model];
        //[model add:[x_0 eq: @(77617.f)]];
        
        //[model add:[y_0 eq: @(33096.f)]];
        
        
        [model add:[r_0 eq: [[[[[[[[[y_0 mul: @(333.75f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] plus: [[x_0 mul: x_0] mul: [[[[[[[x_0 mul: @(11.0f)] mul: x_0] mul: y_0] mul: y_0] sub: [[[[[y_0 mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] sub: [[[[y_0 mul: @(121.0f)] mul: y_0] mul: y_0] mul: y_0]] sub: @(2.0f)]]] plus: [[[[[[[[y_0 mul: @(5.5f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] plus: [x_0 div: [y_0 mul: @(2.f)]]]]];
        
        //assert((r >= 0));
        [model add:[r_0 geq:@(10e8f)]];
            
            //[model add:[[r_0 lt:@(0.0f)] lor:[r_0 gt:@(0.0f)]]];
        
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
