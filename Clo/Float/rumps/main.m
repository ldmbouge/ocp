#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

void check(float x, float y, float r_c){
   float r;
   r = 333.75f * y*y*y*y*y*y + x*x * (11.0f * x*x*y*y - y*y*y*y*y*y - 121.0f * y*y*y*y - 2.0f) + 5.5f * y*y*y*y*y*y*y*y + x / (2.f * y);
   if(r != r_c){
      printf("Erreur dans le resultat\n");
   }else{
      printf("OK\n");
   }
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> y_0 = [ORFactory floatVar:model name:@"y_0"];
         id<ORFloatVar> r_0 = [ORFactory floatVar:model name:@"r_0"];
         id<ORFloatVar> x_0 = [ORFactory floatVar:model name:@"x_0"];
         
//         [model add:[x_0 eq: @(77617.f)]];
//         [model add:[y_0 eq: @(33096.f)]];
         
         
         [model add:[r_0 eq: [[[[[[[[[y_0 mul: @(333.75f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] plus: [[x_0 mul: x_0] mul: [[[[[[[x_0 mul: @(11.0f)] mul: x_0] mul: y_0] mul: y_0] sub: [[[[[y_0 mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] sub: [[[[y_0 mul: @(121.0f)] mul: y_0] mul: y_0] mul: y_0]] sub: @(2.0f)]]] plus: [[[[[[[[y_0 mul: @(5.5f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] plus: [x_0 div: [y_0 mul: @(2.f)]]]]];
         
         //assert((r >= 0));
         [model add:[r_0 geq:@(10e8f)]];
         
         //[model add:[[r_0 lt:@(0.0f)] lor:[r_0 gt:@(0.0f)]]];
         
         id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
         [ORCmdLineArgs defaultRunner:args model:model program:cp];
         
      
   }
   return 0;
}

