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
      [args measure:^struct ORResult(){
         
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
         
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            
            
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
            }
            check([p floatValue:x_0],[p floatValue:y_0],[p floatValue:r_0]);
         } withTimeLimit:[args timeOut]];
         struct ORResult r = REPORT(found, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}

