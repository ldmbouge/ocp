#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> c_0 = [ORFactory floatVar:model];
        id<ORFloatVar> r_0 = [ORFactory floatVar:model];
        id<ORFloatVar> a_0 = [ORFactory floatVar:model];
        id<ORFloatVar> Q_0 = [ORFactory floatVar:model];
        id<ORFloatVar> R2_0 = [ORFactory floatVar:model];
        id<ORFloatVar> CR2_0 = [ORFactory floatVar:model];
        id<ORFloatVar> CQ3_0 = [ORFactory floatVar:model];
        id<ORFloatVar> Q3_0 = [ORFactory floatVar:model];
        id<ORFloatVar> R_0 = [ORFactory floatVar:model];
        id<ORFloatVar> q_0 = [ORFactory floatVar:model];
        id<ORFloatVar> b_0 = [ORFactory floatVar:model];
        [model add:[q_0 eq: [[a_0 mul: a_0] sub: [b_0 mul:@(3.f)]]]];
        
        [model add:[r_0 eq: [[[[[a_0 mul:@(2.f)] mul: a_0] mul: a_0] sub: [[a_0 mul:@(9.f)] mul: b_0]] plus: [c_0 mul:@(27.f)]]]];
        
        
        [model add:[Q_0 eq: [q_0 div:@(9.f)]]];
        
        [model add:[R_0 eq: [r_0 div:@(54.f)]]];
        
        
        [model add:[Q3_0 eq: [[Q_0 mul:Q_0] mul:Q_0]]];
        
        [model add:[R2_0 eq: [R_0 mul:R_0]]];
        
        
        [model add:[CR2_0 eq: [[r_0 mul:@(729.f)] mul: r_0]]];
        
        [model add:[CQ3_0 eq: [[[q_0 mul:@(2916.f)] mul: q_0] mul: q_0]]];
        
        //assert(!(R > 0 && Q != 0 && CR2 == CQ3));
        [model add:[R_0 gt:@(0.0f)]];
        [model add:[Q_0 neq:@(0.0f)]];
        [model add:[CR2_0 eq:CQ3_0]];
        
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                
                
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %f (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                }
                
            } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];

    }
    return 0;
}
