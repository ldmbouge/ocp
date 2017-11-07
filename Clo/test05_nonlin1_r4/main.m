#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 
 double ex6(double x) {
	double r1 = (x - 1.0);
	double r2 = (x * x);
	return (r1 / (r2 - 1.0));
 }

 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];

         id<ORFloatVar> r2_0 = [ORFactory floatVar:model];
         id<ORFloatVar> x_0 = [ORFactory floatVar:model low:1.00001f up:1.f];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         id<ORFloatVar> r1_0 = [ORFactory floatVar:model];
         id<ORExpr> expr_0 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_1 = [ORFactory float:model value:1.0f];
         
         [model add:[r1_0 eq: [x_0 sub: expr_0]]];
         
         [model add:[r2_0 eq: [x_0 mul: x_0]]];
         
         [model add:[res eq: [r1_0 div: [r2_0 sub: expr_1]]]];

         
         
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
