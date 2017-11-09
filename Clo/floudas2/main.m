#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 float ex4(float x1, float x2) {
 return (-x1 - x2);
 }
 
 int main()
 {
 float x1,x2,res;
 x1 = DBETWEEN(0,3);
 x2 = DBETWEEN(0,4);
 res = ex4(x1,x2);
 return 0;
 }
 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> x2_0 = [ORFactory floatVar:model low:0.f up:3.f];
         id<ORFloatVar> x1_0 = [ORFactory floatVar:model low:0.f up:4.f];
         id<ORFloatVar> res_0 = [ORFactory floatVar:model];
         
         id<ORExpr> expr_0 = [ORFactory float:model value:0.0f];
         
         [model add:[res_0 eq: [[expr_0 sub:x1_0] sub: x2_0]]];

         
         [model add:[res_0 leq:@(1.f)]];
         [model add:[res_0 geq:@(-1.f)]];
         
         
         //         [model add:[res gt:@(6.f)]];
         //         [model add:[res lt:@(7.48875938e2f)]];
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
