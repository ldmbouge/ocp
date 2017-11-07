#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 float ex8(float x3, float x0, float x2, float x1) {
	return (((x0 + x1) + x2) + x3);
 }

 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> res_0 = [ORFactory floatVar:model];
         
         id<ORFloatVar> x0_0 = [ORFactory floatVar:model low:-1e5f up:1.00001f];
         id<ORFloatVar> x1_0 = [ORFactory floatVar:model low:0.f up:1.f];
         id<ORFloatVar> x2_0 = [ORFactory floatVar:model low:0.f up:1.f];
         id<ORFloatVar> x3_0 = [ORFactory floatVar:model low:0.f up:1.f];
         
         [model add:[res_0 eq: [[[x0_0 plus: x1_0] plus: x2_0] plus: x3_0]]];
         
         
         
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
