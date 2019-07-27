#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

#define LARGE_NUMBER 4.0e+14
#define NBLOOPS 40


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVarArray> d = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"d"];
         id<ORFloatVarArray> nextValue = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"nextValue"];
         
       NSMutableArray* toadd = [[NSMutableArray alloc] init];
         
         [toadd addObject:[d[0] eq:@(LARGE_NUMBER)]];
         
         for(ORInt i = 0; i < NBLOOPS; i++){
            [toadd addObject:[nextValue[i] lt:@(2.14748e+09f)]];
            [toadd addObject:[nextValue[i] geq:@(1.f)]];
            [toadd addObject:[d[i+1] eq:[d[i] div:nextValue[i]]]];
         }
         
         [toadd addObject:[d[NBLOOPS] lt:@(1.f)]];
         
         
         //         NSLog(@"%@",model);
         id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
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


