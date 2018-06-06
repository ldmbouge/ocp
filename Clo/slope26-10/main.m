#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVar> x0 = [ORFactory floatVar:model];
            id<ORFloatVar> h = [ORFactory floatVar:model low:1e-6f up:1e-3f];
            id<ORFloatVar> x1 = [ORFactory floatVar:model];
            id<ORFloatVar> x2 = [ORFactory floatVar:model];
            id<ORFloatVar> fx1 = [ORFactory floatVar:model];
            id<ORFloatVar> fx2 = [ORFactory floatVar:model];
            id<ORFloatVar> res = [ORFactory floatVar:model];
           id<ORGroup> g = [args makeGroup:model];
            //x0 = 13
            [g add:[x0 eq:@(13.0f)]];
            //x1 = x0 + h
            [g add:[x1 eq:[x0 plus:h]]];
            //x2 = x0 - h
            [g add:[x2 eq:[x0 sub:h]]];
            //fx1 = x1*x1
            [g add:[fx1 eq:[x1 mul:x1]]];
            
            //fx2 = x2*x2
            [g add:[fx2 eq:[x2 mul:x2]]];
            
            //res = (fx1 - fx2) / (2.0*h)
            [g add:[ res eq:[[fx1 sub:fx2] div:[h mul:@(2.0f)]]]];
            
            //res < 26.0f - 10.0f
            float v = 26.0f;
            id<ORExpr> fc = [ORFactory float:model value:v];
            [g add:[res lt:[fc sub:@(10.0f)]]];
           [model add:g];
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
           
           __block bool found = false;
           [cp solveOn:^(id<CPCommonProgram> p) {
              [args printStats:g model:model program:cp];
              [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
              NSLog(@"Valeurs solutions : \n");
              found=true;
              for(id<ORFloatVar> v in vars){
                 found &= [p bound: v];
                 NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
              }
              
              [args checkAbsorption:vars solver:cp];
           } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
