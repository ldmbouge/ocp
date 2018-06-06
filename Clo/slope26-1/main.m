#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

#define eps 1.0e-5f

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
   if (aire > eps) printf("aire is not < %e.\n", eps);
   
   return aire;
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x0 = [ORFactory floatVar:model];
         id<ORFloatVar> h = [ORFactory floatVar:model low:1e-9f up:1e-6f];
         id<ORFloatVar> x1 = [ORFactory floatVar:model];
         id<ORFloatVar> x2 = [ORFactory floatVar:model];
         id<ORFloatVar> fx1 = [ORFactory floatVar:model];
         id<ORFloatVar> fx2 = [ORFactory floatVar:model];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         id<ORGroup> g = [args makeGroup:model];
         //x0 = 13
         [g add:[x0 eq:@(13.0f)]];
         //x1 = x0 + h
         [g add:[x1 eq:[x0 plus:h]]];
         //x2 = x0 - h
         [g add:[x2 eq:[x0 sub:h]]];
         //fx1 = x1*x1
         [g add:[fx1 eq:[x1 mul:x1]]];
         
         //fx2 = x2*x2
         [g add:[fx2 eq:[x2 mul:x2]]];
         
         //res = (fx1 - fx2) / (2.0*h)
         [g add:[ res eq:[[fx1 sub:fx2] div:[h mul:@(2.0f)]]]];
         
         //res < 26.0f - 1.0f
         float v = 26.0f;
         id<ORExpr> fc = [ORFactory float:model value:v];
         [g add:[res lt:[fc sub:@(1.0f)]]];
         
         [model add:g];
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
            
            [args checkAbsorption:vars solver:cp];
         } withTimeLimit:[args timeOut]];
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}
