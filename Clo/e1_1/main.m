#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
//
//DECL
//
//float [-1, 1] x;
//EXPR
//--Expect result: UNSAT
//x * x + x < -0.25-1.0e-3;


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:-1.0f up:1.0f];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         
         
         
         id<ORExpr> fc = [ORFactory float:model value:-0.25f];
         id<ORExpr> fc2 = [ORFactory float:model value:1.0e-3];
         id<ORGroup> g = [args makeGroup:model];
         
         
         [g add:[res eq:[[x mul:x] plus:x]]];
         
         [g add:[res lt:[fc sub:fc2]]];
         [model add:g];
         
         //            [model add:[res lt:fc]];
         
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
         } withTimeLimit:[args timeOut]];
         
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
         
      }];
      
      
   }
   return 0;
}
