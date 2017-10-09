//
//  main.m
//  square10
//
//  Created by Zitoun on 06/07/2017.
//
//

#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

/*int main(float IN)
 {
 float result;
 
 @ assume IN >= 0.0f && IN < 1.0f; @

result = 1.0f + 0.5f*IN - 0.125f*IN*IN + 0.0625f*IN*IN*IN
- 0.0390625f*IN*IN*IN*IN;

//@ assert result >= 0.0f;
//@ assert result < 1.39f;

return 0;
}
*/

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVar> IN = [ORFactory floatVar:model low:0.0f up:1.f];
            id<ORFloatVar> result = [ORFactory floatVar:model];
            
            
            
            id<ORExpr> fc = [ORFactory float:model value:1.0f];
            id<ORExpr> fc2 = [ORFactory float:model value:0.5f];
            id<ORExpr> fc3 = [ORFactory float:model value:0.125f];
            id<ORExpr> fc4 = [ORFactory float:model value:0.0625f];
            id<ORExpr> fc5 = [ORFactory float:model value:0.0390625f];
            
            [model add:[IN lt:@(1.0f)]];
            
            [model add:[[[[fc plus:[fc2 mul:IN]] sub: [[fc3 mul:IN ] mul:IN]] plus: [[[fc4 mul:IN] mul:IN] mul:IN]] sub:[[[[fc5 mul:IN] mul:IN] mul:IN] mul:IN]]];
            
            [model add:[result lt:@(1.39f)]];
            [model add:[result geq:@(0.0f)]];
            
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            [cp solveOn:^(id<CPCommonProgram> p) {
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                NSLog(@"Valeurs solutions : \n");
                for(id<ORFloatVar> v in vars){
                    //  found &= [p bound: v];
                    NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
                }
            } withTimeLimit:[args timeOut]];
            
            struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
            
        }];
      
    
    }
    return 0;
}
