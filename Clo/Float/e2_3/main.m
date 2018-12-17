#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

#define p1 1.0e+9f
#define p2 1.0e-8f
#define p3 1.0e-7f
//should be with double but error
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:-1e20 up:1e20 name:@"x"];
         
         //         id<ORDoubleVar> y = [ORFactory doubleVar:model name:@"y"];
                  id<ORFloatVar> p4 = [ORFactory floatVar:model low:-1.0 up:1.0 name:@"p4"];
         
         id<ORGroup> g = [args makeGroup:model];
         
         
         [g add:[x leq:@(p1)]];
         [g add:[[x plus:p4] gt: @(p1)]];
         [g add:[p4 eq:@(1.0e-7)]];
         
         [model add:g];
         
         //            [model add:[res lt:fc]];
         
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
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

