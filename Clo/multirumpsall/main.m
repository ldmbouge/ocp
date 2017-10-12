#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVarArray> y = [ORFactory floatVarArray:model range:RANGE(model, 0, 26)];
            id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, 4)];
            id<ORFloatVar> r_0 = [ORFactory floatVar:model];
            
            
            [model add:[r_0 eq: [[[[[[[[[y[0] mul: @(333.75f)] mul: y[1]] mul: y[2]] mul:y[3]] mul:y[4]] mul: y[5]] plus:
                                   [[x[0] mul: x[1]] mul: [[[[[[[x[2] mul: @(11.0f)] mul: x[3]] mul:y[6]] mul:y[7]] sub: [[[[[y[8] mul:y[9]] mul:y[10]] mul:y[11]] mul:y[12]] mul:y[13]]] sub: [[[[y[14] mul: @(121.0f)] mul:y[15]] mul:y[16]] mul:y[17]]] sub: @(2.0f)]]]
                                  plus: [[[[[[[[y[18] mul: @(5.5f)] mul:y[19]] mul:y[20]] mul:y[21]] mul:y[22]] mul:y[23]] mul: y[24]] mul:y[25]]]
                                 plus: [x[4] div: [y[26] mul: @(2.f)]]]]];
            
            //assert((r >= 0));
            [model add:[r_0 geq:@(0.0f)]];
            
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
