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
         id<ORDoubleVar> t = [ORFactory doubleVar:model name:@"t"];
//         id<ORFloatVar> x = [ORFactory floatVar :model low:1.e3f up:10e10f name:@"x"];
         id<ORDoubleVar> x = [ORFactory doubleVar:model low:-10e10f up:-1.e3f name:@"x"];
         
         [model add:[t eq: [x mul:x]]];
         
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
