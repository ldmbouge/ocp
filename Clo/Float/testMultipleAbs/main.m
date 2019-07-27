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
      
         id<ORModel> model = [ORFactory createModel];
//         id<ORDoubleVar> t = [ORFactory doubleVar:model name:@"t"];
//         id<ORFloatVar> x = [ORFactory floatVar :model low:1.e3f up:10e10f name:@"x"];
//         id<ORDoubleVar> x = [ORFactory doubleVar:model low:-10e10f up:-1.e3f name:@"x"];
         id<ORFloatVar> x = [ORFactory floatVar:model low:0.0f up:1.0f  name:@"x"];
         id<ORFloatVar> z = [ORFactory floatVar:model name:@"z"];
         id<ORGroup> g = [ORFactory group:model type:Group3B];
//         [model add:[t eq: [[x plus:@(1.0)] mul:[x plus:@(1.0)]]]];
         [toadd addObject:[z eq: [[[[@(1.0f) plus: [@(0.5f) mul: x]] sub: [[@(0.125f) mul: x] mul: x]] plus: [[[@(0.0625f) mul: x] mul: x] mul: x]] sub: [[[[@(0.0390625f) mul: x] mul: x] mul: x] mul: x]]]];
         
         id<ORVarArray> vars = [model FPVars];
         id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp];
      
      
   }
   return 0;
}
