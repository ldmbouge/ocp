#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVar> a = [ORFactory floatVar:model low:-1000000.0f up:1000000.0f];
            id<ORFloatVar> b = [ORFactory floatVar:model low:-1000000.0f up:1000000.0f];
            id<ORFloatVar> c = [ORFactory floatVar:model low:-1000000.0f up:1000000.0f];
            
            id<ORFloatVar> dist1 = [ORFactory floatVar:model];
            id<ORFloatVar> dist2 = [ORFactory floatVar:model];
            id<ORFloatVar> diffab = [ORFactory floatVar:model];
            id<ORFloatVar> diffac = [ORFactory floatVar:model];
            id<ORFloatVar> diffbc = [ORFactory floatVar:model];
            
            
            id<ORExpr> delta =  [ORFactory float:model value:0.03f];
            id<ORExpr> epsilon =  [ORFactory float:model value:300000000.f];
            
            id<ORExpr> infinity = [ORFactory infinityf:model];
            id<ORExpr> sub_infinity = [ORFactory float:model value:-INFINITY];
            
            [model add:[delta gt:@(0.0f)]];
            [model add:[epsilon gt:@(0.0f)]];
            
            [model add:[a geq:b]];
            [model add:[b geq:c]];
            [model add:[a geq:c]];
            
            
            [model add:[diffab leq:delta]];
            [model add:[diffac leq:delta]];
            [model add:[diffbc leq:delta]];
            
            [model add:[dist1 eq:[a mul:[b plus:c]]]];
            [model add:[dist2 eq:[[a mul:b] plus:[a mul:c]]]];
            
            [model add:[dist1 neq:infinity]];
            [model add:[dist1 neq:sub_infinity]];
            
            [model add:[dist2 neq:infinity]];
            [model add:[dist2 neq:sub_infinity]];
            
            [model add:[[dist1 sub:dist2] leq:epsilon]];
            
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                
                
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %20.20e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                }
            } withTimeLimit:[args timeOut]];
            NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
        
    }
    return 0;
}
