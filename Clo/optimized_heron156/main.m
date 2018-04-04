#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>
float check_solution(float a, float b, float c, float c_aire) {
   float aire = 0.0;
   unsigned int *aptr, *bptr, *cptr,*sqptr;
   aptr = (unsigned int *)&(a);
   bptr = (unsigned int *)&(b);
   cptr = (unsigned int *)&(c);
   sqptr = (unsigned int *)&(c_aire);
   
   printf("Hexa values \na = %20.20e [%4X]\nb =  %20.20e [%4X]\nc =  %20.20e [%4X]\nsquared_area = %20.20e [%4X]\n", a, *aptr, b , *bptr, c, *cptr, c_aire, *sqptr);
   
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
   
   aire = (((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))/16.0f);
   
   if (aire != c_aire) printf("aire not correct: got %16.16e, computed %16.16e\n", c_aire, aire); else printf("aire correct.\n");
   if (aire > (156.25f + 1e-5)) printf("aire is not < (156.25f + 1e-5).\n") ;// else printf("aire is not < %e.\n", eps);
   
   return aire;
}
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> a = [ORFactory floatVar:model low:5.0f up:10.0f];
         id<ORFloatVar> b = [ORFactory floatVar:model low:0.0f up:5.0f];
         id<ORFloatVar> c = [ORFactory floatVar:model low:0.0f up:5.0f];
         id<ORFloatVar> squared_area = [ORFactory floatVar:model];
         id<ORGroup> g = [args makeGroup:model];
         [g add:[a gt:@(0.0f)]];
         [g add:[b gt:@(0.0f)]];
         [g add:[c gt:@(0.0f)]];
         
         [g add:[[a plus:c] gt:b]];
         [g add:[[a plus:b] gt:c]];
         [g add:[[b plus:c] gt:a]];
         
         
         [g add:[a gt:b]];
         [g add:[b gt:c]];
         
         //squared_area = (((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))/16.0f)
         [g add:[squared_area eq:[[
                                       [[
                                         [a plus:[b plus:c]]
                                         mul:[c sub:[a sub:b]]]
                                        mul:[c plus:[a sub:b]]]
                                       mul:[a plus:[b sub:c]]]
                                      div:@(16.0f)]
                     ]];
         
         float v = 156.25f;
         id<ORExpr> fc = [ORFactory float:model value:v];
         [g add:[squared_area gt:[fc plus:@(1e-5f)]]];
         [model add:g];
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         NSLog(@"%@",[cp concretize:g]);
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            found=true;
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
