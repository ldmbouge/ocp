#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

#define eps (156.25 + 1.0e-5f)

float check_solution(float a, float b, float c, float c_aire) {
   float aire = 0.0;
   unsigned int* aptr, * bptr, *cptr, *sqptr;
   
   aptr = (unsigned int *)&a;
   bptr = (unsigned int *)&b;
   cptr = (unsigned int *)&c;
   sqptr = (unsigned int *)&c_aire;
   printf("Hexa values \na = %20.20e [%4X]\nb =  %20.20e [%4X]\nc =  %20.20e [%4X]\nsquared_area = %20.20e [%4X]\n", a, *aptr, b , *bptr, c, *cptr, c_aire, *sqptr);
   
   
   if ((a < 5.0f) || (10.0f < a)) {
      printf("a is out of bounds:  %16.16e  %16.16e  %16.16e  %16.16e\n", a, b, c, c_aire);
      exit(0);
   }
   if ((b < 0.0f) || (5.0f < b)) {
      printf("b is out of bounds: %16.16e\n", b);
      exit(0);
   }
   if ((c < 0.0f) || (5.0f < c)) {
      printf("c is out of bounds: %16.16e\n", c);
      exit(0);
   }
   if (a <= 0)  {
      printf("assume a > 0 not fulfilled.\n");
      exit(0);
   }
   if (b <= 0) {
      printf("assume b > 0 not fulfilled.\n");
      exit(0);
   }
   if (c <= 0)  {
      printf("assume c > 0 not fulfilled.\n");
      exit(0);
   }
   if (b >= a+c)  {
      printf("assume a+c > b not fulfilled.\n");
      exit(0);
   }
   if (c >= a+b)  {
      printf("assume a+b > c not fulfilled.\n");
      exit(0);
   }
   if (a >= b+c)   {
      printf("assume b+c > a not fulfilled.\n");
      exit(0);
   }
   
   if (b > a)   {
      printf("assume a > b not fulfilled.\n");
      exit(0);
   }
   if (c > b)   {
      printf("assume b > c not fulfilled.\n");
      exit(0);
   }
   
   aire = (((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))/16.0f);
   
   if (aire != c_aire) printf("aire not correct: got %16.16e, computed %16.16e\n", c_aire, aire); else printf("aire correct.\n");
   if (aire < eps) printf("aire is not < %e.\n", eps);
   
   return aire;
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> a = [ORFactory floatVar:model low:5.0f up:10.0f name:@"a"];
      id<ORFloatVar> b = [ORFactory floatVar:model low:0.0f up:5.0f name:@"b"];
      id<ORFloatVar> c = [ORFactory floatVar:model low:0.0f up:5.0f name:@"c"];
      id<ORFloatVar> squared_area = [ORFactory floatVar:model  name:@"squared_area"];
      
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
      //         id<ORGroup> g = [args makeGroup:model];
      [toadd addObject:[a gt:@(0.0f)]];
      [toadd addObject:[b gt:@(0.0f)]];
      [toadd addObject:[c gt:@(0.0f)]];
      
      [toadd addObject:[[a plus:c] gt:b]];
      [toadd addObject:[[a plus:b] gt:c]];
      [toadd addObject:[[b plus:c] gt:a]];
      
      
      [toadd addObject:[a gt:b]];
      [toadd addObject:[b gt:c]];
      
      //squared_area = (((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))/16.0f)
      [toadd addObject:[squared_area eq:[[
                                          [[
                                            [a plus:[b plus:c]]
                                            mul:[c sub:[a sub:b]]]
                                           mul:[c plus:[a sub:b]]]
                                          mul:[a plus:[b sub:c]]]
                                         div:@(16.0f)]
                        ]];
      
      [toadd addObject:[squared_area gt:@(eps)]]; /* */
      
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
            [cp solveOn:^(id<CPCommonProgram> p) {
               [args launchHeuristic:cp restricted:vars];
               //               check_solution([p floatValue:a], [p floatValue:b], [p floatValue:c], [p floatValue:s], [p floatValue:squared_area]);
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


