#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
  float ex3(float x1, float x2, float x3, float x4, float x5, float x6) {
	return ((((((-25.0 * ((x1 - 2.0) * (x1 - 2.0))) - ((x2 - 2.0) * (x2 - 2.0))) - ((x3 - 1.0) * (x3 - 1.0))) - ((x4 - 4.0) * (x4 - 4.0))) - ((x5 - 1.0) * (x5 - 1.0))) - ((x6 - 4.0) * (x6 - 4.0)));
 }
 
 
 int main()
 {
 float x1,x2,x3,x4,x5,x6,res;
 x1 = DBETWEEN(0,6);
 x2 = DBETWEEN(0,6);
 x3 = DBETWEEN(1,5);
 x4 = DBETWEEN(0,6);
 x5 = DBETWEEN(0,6);
 x6 = DBETWEEN(0,10);
 res = ex3(x1,x2,x3,x4,x5,x6);
 return 0;
 }


 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> x6_0 = [ORFactory floatVar:model];
         id<ORFloatVar> x4_0 = [ORFactory floatVar:model];
         id<ORFloatVar> x5_0 = [ORFactory floatVar:model];
         id<ORFloatVar> x2_0 = [ORFactory floatVar:model];
         id<ORFloatVar> x1_0 = [ORFactory floatVar:model];
         id<ORFloatVar> res_0 = [ORFactory floatVar:model];
         id<ORFloatVar> x3_0 = [ORFactory floatVar:model];
         
         id<ORExpr> expr_8 = [ORFactory float:model value:4.0f];
         id<ORExpr> expr_4 = [ORFactory float:model value:2.0f];
         id<ORExpr> expr_6 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_10 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_5 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_11 = [ORFactory float:model value:4.0f];
         id<ORExpr> expr_9 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_12 = [ORFactory float:model value:4.0f];
         id<ORExpr> expr_1 = [ORFactory float:model value:2.0f];
         id<ORExpr> expr_3 = [ORFactory float:model value:2.0f];
         id<ORExpr> expr_7 = [ORFactory float:model value:4.0f];
         id<ORExpr> expr_2 = [ORFactory float:model value:2.0f];
         id<ORExpr> expr_0 = [ORFactory float:model value:-25.0f];
         
         [model add:[res_0 eq: [[[[[[expr_0 mul: [[x1_0 sub: expr_1] mul: [x1_0 sub: expr_2]]] sub: [[x2_0 sub: expr_3] mul: [x2_0 sub: expr_4]]] sub: [[x3_0 sub: expr_5] mul: [x3_0 sub: expr_6]]] sub: [[x4_0 sub: expr_7] mul: [x4_0 sub: expr_8]]] sub: [[x5_0 sub: expr_9] mul: [x5_0 sub: expr_10]]] sub: [[x6_0 sub: expr_11] mul: [x6_0 sub: expr_12]]]]];

         
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
