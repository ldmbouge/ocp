#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>
/*
 from : Zumkeller, Roland Formal Global Optimisation with Taylor Models
 float ex10(float x1, float x2, float x3, float x4, float x5, float x6) {
 return ((((((((x1 * x4) * (((((-x1 + x2) + x3) - x4) + x5) + x6)) + ((x2 * x5) * (((((x1 - x2) + x3) + x4) - x5) + x6))) + ((x3 * x6) * (((((x1 + x2) - x3) + x4) + x5) - x6))) - ((x2 * x3) * x4)) - ((x1 * x3) * x5)) - ((x1 * x2) * x6)) - ((x4 * x5) * x6));
 }
 
 
 int main()
 {
 float x1,x2,x3,x4,x5,x6,res;
 x1 = DBETWEEN(4,6.36);
 x2 = DBETWEEN(4,6.36);
 x3 = DBETWEEN(4,6.36);
 x4 = DBETWEEN(4,6.36);
 x5 = DBETWEEN(4,6.36);
 x6 = DBETWEEN(4,6.36);
 res = ex10(x1,x2,x3,x4,x5,x6);
 return 0;
 }
 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> x1_0 = [ORFactory floatVar:model low:4.f up:6.36f];
         id<ORFloatVar> x2_0 = [ORFactory floatVar:model low:4.f up:6.36f];
         id<ORFloatVar> x3_0 = [ORFactory floatVar:model low:4.f up:6.36f];
         id<ORFloatVar> x4_0 = [ORFactory floatVar:model low:4.f up:6.36f];
         id<ORFloatVar> x5_0 = [ORFactory floatVar:model low:4.f up:6.36f];
         id<ORFloatVar> x6_0 = [ORFactory floatVar:model low:4.f up:6.36f];
         id<ORFloatVar> res_0 = [ORFactory floatVar:model];
         
         id<ORExpr> expr_unop = [ORFactory float:model value:0.f];
         id<ORGroup> g = [args makeGroup:model];
         
         [g add:[res_0 eq: [[[[[[[[x1_0 mul: x4_0] mul: [[[[[[expr_unop sub:x1_0] plus: x2_0] plus: x3_0] sub: x4_0] plus: x5_0] plus: x6_0]] plus: [[x2_0 mul: x5_0] mul: [[[[[x1_0 sub: x2_0] plus: x3_0] plus: x4_0] sub: x5_0] plus: x6_0]]] plus: [[x3_0 mul: x6_0] mul: [[[[[x1_0 plus: x2_0] sub: x3_0] plus: x4_0] plus: x5_0] sub: x6_0]]] sub: [[x2_0 mul: x3_0] mul: x4_0]] sub: [[x1_0 mul: x3_0] mul: x5_0]] sub: [[x1_0 mul: x2_0] mul: x6_0]] sub: [[x4_0 mul: x5_0] mul: x6_0]]]];
         
         
         
         //         [model add:[res_0 lt:@(-668.0f)]];
         //         [model add:[res_0 lt:@(-9.999999403953552246e-01f)]];
         [g add:[res_0 lt:@(-6.68e2f)]];
         [model add:g];
         
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
        
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            found=true;
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
