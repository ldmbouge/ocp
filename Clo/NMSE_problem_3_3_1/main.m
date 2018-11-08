#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 float ex5(float x) {
	return ((1.0 / (x + 1.0)) - (1.0 / x));
 }
 
 int main()
 {
 float x,res;
 x != 0;
 res = ex5(x)
 return 0;
 }
 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> res_0 = [ORFactory floatVar:model];
         id<ORFloatVar> x_0 = [ORFactory floatVar:model];
         id<ORExpr> expr_0 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_1 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_2 = [ORFactory float:model value:1.0f];
         
         [model add:[res_0 eq: [[expr_0 div: [x_0 plus: expr_1]] sub: [expr_2 div: x_0]]]];

         
         [model add:[x_0 eq:@(0.f)]];
         [model add:[res_0 geq:@(1e5f)]];
         
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