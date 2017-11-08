#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 double ex4(double x, double y) {
	return ((x + y) / (x - y));
 }
 */
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:0.f up:1.f];
         id<ORFloatVar> y = [ORFactory floatVar:model low:-1.f up:-0.1f];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         
         [model add:[res eq:[[x plus:y] div:[x sub:y]]]];
         
         //         ORFloat c = 8.81975174f - 2.42721237e-5f;
         ORFloat c = 8.81975174f - 5.3f;
         //         [model add:[res gt:@(c)]];
         [model add:[res lt:@(.6f)]];
         [model add:[res gt:@(0.f)]];
         
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
