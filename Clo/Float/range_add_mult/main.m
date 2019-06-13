//
//  range_add_mult.m
//  Clo
//
//  Created by Rémy Garcia on 05/09/2018.
//
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:0.0f up:180.0f name:@"x"];
         id<ORFloatVar> y = [ORFactory floatVar:model low:-180.0f up:0.0f name:@"y"];
         id<ORFloatVar> z = [ORFactory floatVar:model low:0.0f up:1.0f name:@"z"];
         id<ORFloatVar> res = [ORFactory floatVar:model name:@"r"];
         
         id<ORGroup> g = [args makeGroup:model];
         
         
         [g add:[[x plus: y] geq: @(0.0f)]];
         
         [g add:[res eq: [x plus: [y mul: z]]]];
         
         [g add:[res lt: @(0.0f)]];
//         [g add:[[res lt: @(0.0f)] lor: [res gt: @(360.0f)]]];
         
         [model add:g];
         NSLog(@"%@",g);
         id<CPProgram> cp = [args makeProgram:model];
         id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
         __block bool found = false;
         
         fesetround(FE_TONEAREST);
         [cp solveOn:^(id<CPCommonProgram> p) {
            
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
            
         } withTimeLimit:[args timeOut]];
         
         struct ORResult r = REPORT(found, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}
