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
         id<ORFloatVar> t = [ORFactory floatVar:model name:@"t"];
         id<ORFloatVar> x = [ORFactory floatVar:model low:1.e3f up:10e10f name:@"x"];
         id<ORFloatVar> y = [ORFactory floatVar:model low:1.f up:4e8f name:@"y"];
         id<ORFloatVar> z = [ORFactory floatVar:model low:1.f up:4e8f name:@"z"];
//         id<ORFloatVar> z2 = [ORFactory floatVar:model low:1.0f up:40000.0f name:@"z2"];
//         id<ORFloatVar> z3 = [ORFactory floatVar:model low:1.0f up:40000.0f name:@"z3"];
         
         id<ORFloatVar> w = [ORFactory floatVar:model low:-5000.0f up:40000.0f name:@"w"];
         id<ORFloatVar> a = [ORFactory floatVar:model low:-5000.0f up:40000.0f name:@"a"];
         
//         [model add:[t eq: [[[[x plus:y] plus:z] plus:z2] plus:z3]]];
         [model add:[t eq: [[x plus:y] plus:z]]];
         [model add:[t eq:x]];
         
         [model add:[w geq:[a plus: y]]];
//         [model add:[t eq:@(1e8)]];
         
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         NSLog(@"Model : %@",model);
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            
            
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
            }
//            check_solution([p floatValue:x],[p floatValue:y],[p floatValue:z],[p floatValue:t],[p floatValue:w],[p floatValue:a]);
         } withTimeLimit:[args timeOut]];
         struct ORResult r = REPORT(found, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}
