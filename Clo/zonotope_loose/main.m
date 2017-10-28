#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> y_0 = [ORFactory floatVar:model];
        id<ORFloatVar> y_1 = [ORFactory floatVar:model];
        id<ORFloatVar> y_2 = [ORFactory floatVar:model];
        id<ORFloatVar> y_3 = [ORFactory floatVar:model];
        id<ORFloatVar> x_0 = [ORFactory floatVar:model low:0.f up:10.f];
        [model add:[y_0 eq: [[x_0 mul: x_0] sub: x_0]]];
    
        
        //assert(y >= 0. && y <= 105.);
        [model add:[y_3 geq:@(0.f)]];
        [model add:[y_3 leq:@(105.0f)]];
        
        id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> p = [args makeProgram:model];
            [p solve:^{
                
                [args launchHeuristic:p restricted:vars];
                
                for(id<ORFloatVar> v in vars)
                    NSLog(@"%@ : %f (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                
                
            }];
            struct ORResult r = REPORT(1, [[p explorer] nbFailures],[[p explorer] nbChoices], [[p engine] nbPropagation]);
            return r;
        }];

    }
    return 0;
}
