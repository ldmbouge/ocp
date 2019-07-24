#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x = [ORFactory floatVar:model low:-10.0f up:10.0f name:@"x"];
      id<ORFloatVar> y = [ORFactory floatVar:model name:@"y"];
      id<ORFloatVar> z = [ORFactory floatVar:model name:@"z"];
      
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
   
      [toadd addObject:[y eq:[[x mul:x] sub:@(2.f)]]];
      
      [toadd addObject:[y eq:@(0.0f)]]; /* */
      
      [toadd addObject:[z eq:[@(1.f) div:y]]];
      
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
      NSLog(@"%@",model);
      __block ORBool isSat;
      [args measure:^struct ORResult(){
         ORBool hascycle = NO;
         if([args cycleDetection]){
            hascycle = [args isCycle:model];
            NSLog(@"%s",(hascycle)?"YES":"NO");
         }
         isSat = false;
         if(!hascycle){
            id<ORIntArray> locc = [VariableLocalOccCollector collect:[model constraints] with:[model variables] tracker:model];
            [(CPCoreSolver*)cp setLOcc:locc];
            if([args occDetails]){
               [args printOccurences:_model with:cp restricted:vars];
               //               [_options printMaxGOccurences:_model with:cp n:5];
               //               [_options printMaxLOccurences:_model with:cp n:5];
            }
            [cp solveOn:^(id<CPCommonProgram> p) {
               [args launchHeuristic:cp restricted:vars];
               isSat = [args checkAllbound:model with:cp];
               [args printSolution:model with:cp];
            } withTimeLimit:[args timeOut]];
         }
         
         struct ORResult r = FULLREPORT(isSat, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation],[[cp engine] nbStaticRewrites],[[cp engine] nbDynRewrites],[[model variables] count], [[model constraints] count]);
         printf("%s\n",(isSat)?"sat":"unsat");
         return r;
      }];
      return 0;
   }
}


