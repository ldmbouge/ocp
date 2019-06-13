#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> c_0 = [ORFactory floatVar:model];
         id<ORFloatVar> a_0 = [ORFactory floatVar:model];
         id<ORFloatVar> disc_0 = [ORFactory floatVar:model];
         id<ORFloatVar> b_0 = [ORFactory floatVar:model];
         id<ORGroup> g = [args makeGroup:model];
         [g add:[disc_0 eq: [[b_0 mul: b_0] sub: [[a_0 mul:@(4.0f)] mul: c_0]]]];
         
         //assert(!(a == 0 && b == 0));
         [g add:[a_0 eq:@(0.0f)]];
         [g add:[b_0 eq:@(0.0f)]];
         [model add:g];
         
         
         id<CPProgram> cp = [args makeProgram:model];
         id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
         __block bool found = false;
         
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
         } withTimeLimit:[args timeOut]];
         struct ORResult r = REPORT(found,[[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}

