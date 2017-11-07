#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 
 double ex5(double w1, double a1, double a0, double w0, double w2, double a2, double m0, double m2, double m1) {
	double v2 = ((w2 * (0.0 - m2)) * (-3.0 * ((1.0 * (a2 / w2)) * (a2 / w2))));
	double v1 = ((w1 * (0.0 - m1)) * (-3.0 * ((1.0 * (a1 / w1)) * (a1 / w1))));
	double v0 = ((w0 * (0.0 - m0)) * (-3.0 * ((1.0 * (a0 / w0)) * (a0 / w0))));
	return (0.0 + ((v0 * 1.0) + ((v1 * 1.0) + ((v2 * 1.0) + 0.0))));
 }
 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         id<ORFloatVar> m2_0 = [ORFactory floatVar:model low:-1.f up:1.f];
         id<ORFloatVar> m1_0 = [ORFactory floatVar:model low:-1.f up:1.f];
         id<ORFloatVar> v2_0 = [ORFactory floatVar:model low:-1.f up:1.f];
         id<ORFloatVar> v0_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
         id<ORFloatVar> a1_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
         id<ORFloatVar> a2_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
         id<ORFloatVar> m0_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
         id<ORFloatVar> w2_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
         id<ORFloatVar> a0_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
         id<ORFloatVar> w1_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
         id<ORFloatVar> w0_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
         id<ORFloatVar> v1_0 = [ORFactory floatVar:model low:0.00001f up:1.f];
       
         id<ORExpr> expr_8 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_6 = [ORFactory float:model value:0.0f];
         id<ORExpr> expr_13 = [ORFactory float:model value:0.0f];
         id<ORExpr> expr_10 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_5 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_11 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_9 = [ORFactory float:model value:0.0f];
         id<ORExpr> expr_12 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_0 = [ORFactory float:model value:0.0f];
         id<ORExpr> expr_3 = [ORFactory float:model value:0.0f];
         id<ORExpr> expr_2 = [ORFactory float:model value:1.0f];
         id<ORExpr> expr_4 = [ORFactory float:model value:-3.0f];
         id<ORExpr> expr_1 = [ORFactory float:model value:-3.0f];
         id<ORExpr> expr_7 = [ORFactory float:model value:-3.0f];
         
         [model add:[v2_0 eq: [[w2_0 mul: [expr_0 sub: m2_0]] mul: [expr_1 mul: [[expr_2 mul: [a2_0 div: w2_0]] mul: [a2_0 div: w2_0]]]]]];
         
         
         [model add:[v1_0 eq: [[w1_0 mul: [expr_3 sub: m1_0]] mul: [expr_4 mul: [[expr_5 mul: [a1_0 div: w1_0]] mul: [a1_0 div: w1_0]]]]]];
         
         
         [model add:[v0_0 eq: [[w0_0 mul: [expr_6 sub: m0_0]] mul: [expr_7 mul: [[expr_8 mul: [a0_0 div: w0_0]] mul: [a0_0 div: w0_0]]]]]];
         
         
         [model add:[res eq: [expr_9 plus: [[v0_0 mul: expr_10] plus: [[v1_0 mul: expr_11] plus: [[v2_0 mul: expr_12] plus: expr_13]]]]]];

         
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
