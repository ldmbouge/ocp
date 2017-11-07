#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 float ex5(float x1, float x2) {
 return (((-12.0 * x1) - (7.0 * x2)) + (x2 * x2));
 }
 
 int main()
 {
 float x1,x2,res;
 x1 = DBETWEEN(0,2);
 x2 = DBETWEEN(0,3);
 assert(((-2 * ((x1 * x1) * (x1 * x1))) + 2) <= x2);
 res = ex5(x1,x2);
 return 0;
 }
 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> x2_0 = [ORFactory floatVar:model low:0.f up:2.f];
         id<ORFloatVar> x1_0 = [ORFactory floatVar:model low:0.f up:3.f];
         
         id<ORFloatVar> res_0 = [ORFactory floatVar:model];
         
         id<ORExpr> expr_1 = [ORFactory float:model value:7.0f];
         id<ORExpr> expr_3 = [ORFactory float:model value:2.f];
         id<ORExpr> expr_0 = [ORFactory float:model value:-12.0f];
         id<ORExpr> expr_2 = [ORFactory float:model value:-2.f];
         
         [model add:[res_0 eq: [[[expr_0 mul: x1_0] sub: [expr_1 mul: x2_0]] plus: [x2_0 mul: x2_0]]]];
         
         
         [model add:[x2_0 geq: [[expr_2 mul: [[x1_0 mul: x1_0] mul: [x1_0 mul: x1_0]]] plus: expr_3]]];
         
         
         
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
