#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> z_0 = [ORFactory floatVar:model];
        id<ORFloatVar> y_0 = [ORFactory floatVar:model];
        id<ORFloatVar> x_0 = [ORFactory floatVar:model];
        id<ORFloatVar> r_0 = [ORFactory floatVar:model];
        [model add:[x_0 eq: @(1e8f)]];
        
        [model add:[y_0 eq: [x_0 plus: @(1.f)]]];
        
        
        [model add:[z_0 eq: [x_0 sub: @(1.f)]]];
        
        [model add:[r_0 eq: [y_0 sub: z_0]]];
        
        
        //assert(r == 0.f);
        [model add:[r_0 neq:@(0.0f)]];
        
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
