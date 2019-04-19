#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

void check_solution(float x, float y, float z, float t, float w, float a){
   if (x != t || w < a + y)
      NSLog(@"Error");
   else NSLog(@"oK");
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
//         id<ORDoubleVar> t = [ORFactory doubleVar:model name:@"t"];
//         id<ORFloatVar> x = [ORFactory floatVar :model low:1.e3f up:10e10f name:@"x"];
//         id<ORDoubleVar> x = [ORFactory doubleVar:model low:-10e10f up:-1.e3f name:@"x"];
         id<ORFloatVar> x = [ORFactory floatVar:model low:0.0f up:1.0f  name:@"x"];
         id<ORFloatVar> z = [ORFactory floatVar:model name:@"z"];
         id<ORGroup> g = [ORFactory group:model type:Group3B];
//         [model add:[t eq: [[x plus:@(1.0)] mul:[x plus:@(1.0)]]]];
         [g add:[z eq: [[[[@(1.0f) plus: [@(0.5f) mul: x]] sub: [[@(0.125f) mul: x] mul: x]] plus: [[[@(0.0625f) mul: x] mul: x] mul: x]] sub: [[[[@(0.0390625f) mul: x] mul: x] mul: x] mul: x]]]];
         [model add:g];
         id<ORVarArray> vars = [model FPVars];
         id<CPProgram> cp = [args makeProgram:model];
         NSLog(@"Model : %@",model);
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            
            
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %16.16e (%s)",v,[p doubleValue:v],[p bound:v] ? "YES" : "NO");
            }
//            check_solution([p floatValue:x],[p floatValue:y],[p floatValue:z],[p floatValue:t],[p floatValue:w],[p floatValue:a]);
         } withTimeLimit:[args timeOut]];
         struct ORResult r = REPORT(found, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}
