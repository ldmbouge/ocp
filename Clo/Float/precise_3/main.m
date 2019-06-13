#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:10.0 up:10.0 name:@"x"];
         id<ORFloatVar> y = [ORFactory floatVar:model low:0.4 up:0.4 name:@"y"];
         id<ORFloatVar> z = [ORFactory floatVar:model name:@"z"];
         
         
         id<ORGroup> g = [args makeGroup:model];
         
         
         [g add:[z eq:[x mul:y]]];
         
         [g add:[[z lt:@(3.39999)] lor:[z gt:@(4.00001)]]];
         [model add:g];
         
         //            [model add:[res lt:fc]];
         
         id<CPProgram> cp = [args makeProgram:model];
         id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
         NSLog(@"%@",[cp concretize:g]);
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
         
         struct ORResult r = REPORT(1, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
         
      }];
      
      
   }
   return 0;
}

