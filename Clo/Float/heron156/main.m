#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"


#define eps 1.0e-5f


float check_solution(float a, float b, float c, float c_s, float c_aire) {
   float aire = 0.0, s;
   
   if ((a < 5.0f) || (10.0f < a)) printf("a is out of bounds:  %16.16e  %16.16e  %16.16e  %16.16e\n", a, b, c, c_aire);
   if ((b < 0.0f) || (5.0f < b))  printf("b is out of bounds: %16.16e\n", b);
   if ((c < 0.0f) || (5.0f < c))  printf("c is out of bounds: %16.16e\n", c);
   
   if (a <= 0) printf("assume a > 0 not fulfilled.\n");
   if (b <= 0) printf("assume b > 0 not fulfilled.\n");
   if (c <= 0) printf("assume c > 0 not fulfilled.\n");
   
   if (b >= a+c) printf("assume a+c > b not fulfilled.\n");
   if (c >= a+b) printf("assume a+b > c not fulfilled.\n");
   if (a >= b+c) printf("assume b+c > a not fulfilled.\n");
   
   if (b > a) printf("assume a > b not fulfilled.\n");
   if (c > b) printf("assume b > c not fulfilled.\n");
   
   s = (a+b+c)/2.0f;
   aire = s*(s-a)*(s-b)*(s-c);
   
   if (s != c_s) printf("s not correct: got %16.16e, computed %16.16e\n", c_s, s); else printf("s correct.\n");
   if (aire != c_aire) printf("aire not correct: got %16.16e, computed %16.16e\n", c_aire, aire); else printf("aire correct.\n");
   if (aire > 156.25f + eps) printf("aire is not <= 156.25f + %e.\n", eps);
   
   return aire;
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> a = [ORFactory floatVar:model low:5.0f up:10.0f name:@"a"];
      id<ORFloatVar> b = [ORFactory floatVar:model low:0.0f up:5.0f name:@"b"];
      id<ORFloatVar> c = [ORFactory floatVar:model low:0.0f up:5.0f name:@"c"];
      id<ORFloatVar> s = [ORFactory floatVar:model name:@"s"];
      id<ORFloatVar> squared_area = [ORFactory floatVar:model name:@"squared_area"];
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
      
      [toadd addObject:[a gt:@(0.0f)]];
      [toadd addObject:[b gt:@(0.0f)]];
      [toadd addObject:[c gt:@(0.0f)]];
      
      [toadd addObject:[[a plus:c] gt:b]];
      [toadd addObject:[[a plus:b] gt:c]];
      [toadd addObject:[[b plus:c] gt:a]];
      
      
      [toadd addObject:[a gt:b]];
      [toadd addObject:[b gt:c]];
      
      [toadd addObject:[s eq: [[[a plus:b] plus:c] div:@(2.0f)]]];
      [toadd addObject:[squared_area eq: [[[s mul:[s sub:a]] mul:[s sub:b]] mul:[s sub:c]]]];
      
      float v = 156.25f;
      id<ORExpr> fc = [ORFactory float:model value:v];
      [toadd addObject:[squared_area gt:[fc plus:@(1e-5f)]]];
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      NSLog(@"%@",model);
      id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
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
               [_options printOccurences:_model with:cp];
               [_options printMaxGOccurences:_model with:cp n:5];
               [_options printMaxLOccurences:_model with:cp n:5];
            }
            [cp solveOn:^(id<CPCommonProgram> p) {
               [args launchHeuristic:cp restricted:vars];
               [args printSolution:model with:p];
               check_solution([p floatValue:a], [p floatValue:b], [p floatValue:c], [p floatValue:s], [p floatValue:squared_area]);
               isSat = [args checkAllbound:model with:cp];
               NSLog(@"Depth : %d",[[cp tracer] level]);
            } withTimeLimit:[args timeOut]];
         }
         
         struct ORResult r = FULLREPORT(isSat, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation],[[cp engine] nbStaticRewrites],[[cp engine] nbDynRewrites],[[model variables] count], [[model constraints] count]);
         printf("%s\n",(isSat)?"sat":"unsat");
         return r;
      }];
      return 0;
   }
}
