#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
test02_sum8
 double ex3(double x3, double x4, double x0, double x5, double x2, double x7, double x6, double x1) {
	return (((((((x0 + x1) + x2) + x3) + x4) + x5) + x6) + x7);
 }
 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x0 = [ORFactory floatVar:model low:1.f up:2.f];
         id<ORFloatVar> x1 = [ORFactory floatVar:model low:1.f up:2.f];
         id<ORFloatVar> x2 = [ORFactory floatVar:model low:1.f up:2.f];
         id<ORFloatVar> x3 = [ORFactory floatVar:model low:1.f up:2.f];
         id<ORFloatVar> x4 = [ORFactory floatVar:model low:1.f up:2.f];
         id<ORFloatVar> x5 = [ORFactory floatVar:model low:1.f up:2.f];
         id<ORFloatVar> x6 = [ORFactory floatVar:model low:1.f up:2.f];
         id<ORFloatVar> x7 = [ORFactory floatVar:model low:1.f up:2.f];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         
         [model add:[res eq:[[[[[[[x0 plus:x1] plus:x2] plus:x3] plus:x4] plus:x5] plus:x6] plus:x7]]];
         
         //         float v = 1.36503327f;
         //         id<ORExpr> fc = [ORFactory float:model value:v];
         ORFloat c = 1.600000000000000000e+02;
//         ORFloat c2 = 8.008000373840332031e+00;
                  [model add:[res lt:@(c)]];
//         [model add:[res lt:@(c2)]];
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
