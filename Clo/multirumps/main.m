#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            id<ORModel> model = [ORFactory createModel];
            //multirumps
            id<ORFloatVarArray> y = [ORFactory floatVarArray:model range:RANGE(model, 0, 5)];
//            id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, 2) low:0.f up:1e2f];
            id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, 2)];
            id<ORFloatVar> r_0 = [ORFactory floatVar:model];
            
            
            [model add:[r_0 eq: [[[[[[[[[y[0] mul: @(333.75f)] mul: y[0]] mul: y[0]] mul:y[0]] mul:y[0]] mul: y[0]] plus:
                                   [[x[0] mul: x[0]] mul: [[[[[[[x[1] mul: @(11.0f)] mul: x[1]] mul:y[1]] mul:y[1]] sub: [[[[[y[2] mul:y[2]] mul:y[2]] mul:y[2]] mul:y[2]] mul:y[2]]] sub: [[[[y[3] mul: @(121.0f)] mul:y[3]] mul:y[3]] mul:y[3]]] sub: @(2.0f)]]]
                                  plus: [[[[[[[[y[4] mul: @(5.5f)] mul:y[4]] mul:y[4]] mul:y[4]] mul:y[4]] mul:y[4]] mul: y[4]] mul:y[4]]]
                                  plus: [x[2] div: [y[5] mul: @(2.f)]]]]];
            
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
