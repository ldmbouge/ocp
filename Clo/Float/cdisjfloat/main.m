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
      id<ORFloatVar> r_1 = [ORFactory floatVar:model name:@"r_1"];
      id<ORFloatVar> r_2 = [ORFactory floatVar:model name:@"r_2"];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model name:@"x_0"];
      
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
      
      
      [toadd addObject:[r_0 eq: [[[[[[[[[y_0 mul: @(333.75f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] plus: [[x_0 mul: x_0] mul: [[[[[[[x_0 mul: @(11.0f)] mul: x_0] mul: y_0] mul: y_0] sub: [[[[[y_0 mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] sub: [[[[y_0 mul: @(121.0f)] mul: y_0] mul: y_0] mul: y_0]] sub: @(2.0f)]]] plus: [[[[[[[[y_0 mul: @(5.5f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] plus: [x_0 div: [y_0 mul: @(2.f)]]]]];
      
      //assert((r >= 0));
      [toadd addObject:[r_0 geq:@(10e8f)]];
      [toadd addObject:[r_0 leq:@(30e8f)]];
      
      // if  version 1
      /*
       [toadd addObject:[[[r_0 geq:@(10e8f)] land: [r_1 eq:@(3.0f)]] lor:
       [[r_0 lt:@(10e8f)] land: [r_1 eq:@(2.0f)]]]];
       */
      
       // if version 2
       {
       id<ORGroup> CT  = [args makeGroup:model];
       id<ORGroup> NCE = [args makeGroup:model];
       
       [CT add:[r_0 geq:@(10e8f)]];
       [CT add:[r_1 eq:@(3.0f)]];
       
       [NCE add:[r_0 lt:@(10e8f)]];
       [NCE add:[r_1 eq:@(2.0f)]];
       
       [toadd addObject:[ORFactory cdisj:model clauses:@[CT,NCE]]];
       }
       
      // if version 3
      {
         id<ORExpr> ifCond  = [r_0 geq:@(10e8f)];
         id<ORIntVar> thenGuard = [ORFactory boolVar:model];
         id<ORIntVar> elseGuard = [ORFactory boolVar:model];
         [toadd addObject: [ifCond eq: thenGuard]];
         [toadd addObject: [[ifCond neg] eq: elseGuard]];
         
         id<ORGroup> thenGroup = [ORFactory group:model guard:thenGuard];
         [thenGroup add: [r_1 eq:@(3.0f)]];
         [toadd addObject:thenGroup];
         
         id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
         [elseGroup add: [r_1 eq:@(2.0f)]];
         [toadd addObject:elseGroup];
      }
      
      
      [toadd addObject:[r_2 eq:[r_1 mul: @(2.0f)]]];
      
      //[model add:[[r_0 lt:@(0.0f)] lor:[r_0 gt:@(0.0f)]]];
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[x_0, y_0]];
      
      
   }
   return 0;
}

