#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
           id<ORModel> model = [ORFactory createModel];
           id<ORFloatVar> x_0 = [ORFactory floatVar:model low:5.0 up:nextafterf(5.f, +INFINITY)];
           id<ORFloatVar> y_0 = [ORFactory floatVar:model];
           id<ORFloatVar> y_1 = [ORFactory floatVar:model];
           id<ORFloatVar> y_2 = [ORFactory floatVar:model];
           
           id<ORExpr> expr_0 = [ORFactory float:model value:5.f];
           id<ORExpr> expr_1 = [ORFactory float:model value:2.f];
           id<ORExpr> expr_2 = [ORFactory float:model value:0.f];
           
           id<ORExpr> c_0 = [x_0 gt: expr_0];
           id<ORIntVar> b_if0 = [ORFactory boolVar:model];
           id<ORIntVar> b_else0 = [ORFactory boolVar:model];
           
           //      +(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x eqi: (ORFloat) i
           //      [model add:[ORFactory floatReify:model boolean:b_if0 with:x_0 gti:5.0f]];
           //      [model add:[ORFactory floatReify:model boolean:b_else0 with:x_0 leqi:5.0f]];
           [model add:[c_0  eq:b_if0]];
           [model add:[[b_if0 neg] eq:b_else0]];
           id<ORGroup> g_0 = [ORFactory group:model guard:b_if0];
           {
              [g_0 add:[y_1 eq: expr_1]];
           }
           id<ORGroup> g_1 = [ORFactory group:model guard:b_else0];
           {
              [g_1 add:[y_2 eq: expr_2]];
           }
           [model add:[ORFactory phi:model on_boolean:b_if0 var:y_0 with:y_1 or:y_2]];
           //      [model add:[ORFactory phi:model on:c_0 var:y_0 with:y_1 or:y_2]];
           [model add:g_0];
           [model add:g_1];
           
           NSLog(@"%@",model);
           id<ORFloatVarArray> vars = [ORFactory floatVarArray:model range:RANGE(model, 0, 1) ];
           vars[0] = x_0;
           vars[1] = y_0;
           id<CPProgram> cp = [ORFactory createCPProgram:model];
//                 id<ORFloatVarArray> vars = [model floatVars];
         
            __block bool found = false;
            [cp solveAll:^() {
                [args launchHeuristic:cp restricted:vars];
                for(id<ORFloatVar> v in vars)
                    NSLog(@"%@ (bound %s) = %16.16e\n ",v,[cp bound:v] ? "YES" : "NO",[cp floatValue:v]);
                found=true;
            }];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
