#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 float ex2(float x0, float x2, float x1) {
	float p0 = ((x0 + x1) - x2);
	float p1 = ((x1 + x2) - x0);
	float p2 = ((x2 + x0) - x1);
	return ((p0 + p1) + p2);
 }
*/
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x0 = [ORFactory floatVar:model low:1.001 up:2];
         id<ORFloatVar> x1 = [ORFactory floatVar:model low:1.001 up:2];
         id<ORFloatVar> x2 = [ORFactory floatVar:model low:1.001 up:2];
         id<ORFloatVar> p0 = [ORFactory floatVar:model];
         id<ORFloatVar> p1 = [ORFactory floatVar:model];
         id<ORFloatVar> p2 = [ORFactory floatVar:model];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         
         [model add:[p0 eq:[[x0 plus:x1] sub:x2]]];
         [model add:[p1 eq:[[x1 plus:x2] sub:x0]]];
         [model add:[p2 eq:[[x2 plus:x0] sub:x2]]];
         
         [model add:[res eq:[[p0 plus:p1] plus:p2]]];
         
//         float v = 1.36503327f;
//         id<ORExpr> fc = [ORFactory float:model value:v];
//         [model add:[res gt:[fc plus:@(1.65814304e-2f)]]];
         [model add:[res gt:@(6.f)]];
         [model add:[res lt:@(7.48875938e2f)]];
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
