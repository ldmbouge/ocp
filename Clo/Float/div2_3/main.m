#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

#define LARGE_NUMBER 4.0e+14
#define NBLOOPS 3


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVarArray> d = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"d"];
         id<ORFloatVarArray> nextValue = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"nextValue"];
         
         id<ORGroup> g = [args makeGroup:model];
         
         [g add:[d[0] eq:@(LARGE_NUMBER)]];
         
         for(ORInt i = 0; i < NBLOOPS; i++){
            [g add:[nextValue[i] lt:d[i]]];
            [g add:[nextValue[i] geq:@(1.f)]];
            [g add:[d[i+1] eq:[d[i] div:nextValue[i]]]];
         }
         
         [g add:[d[NBLOOPS] lt:@(1.f)]];
         
         [model add:g];
         //         NSLog(@"%@",model);
         id<CPProgram> cp = [args makeProgram:model];
         id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            found = true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
            }
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}


