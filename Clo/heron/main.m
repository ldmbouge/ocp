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
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> a = [ORFactory floatVar:model low:5.0f up:10.0f];
         id<ORFloatVar> b = [ORFactory floatVar:model low:0.0f up:5.0f];
         id<ORFloatVar> c = [ORFactory floatVar:model low:0.0f up:5.0f];
         id<ORFloatVar> s = [ORFactory floatVar:model];
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
         
         
         [g add:[s eq: [[[a plus:b] plus:c] div:@(2.0f)]]];
         [g add:[squared_area eq: [[[s mul:[s sub:a]] mul:[s sub:b]] mul:[s sub:c]]]];
         
         [g add:[squared_area lt:@(1e-5f)]]; /* */
         [model add:g];
         //           NSLog(@"%@",model);
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
            check_solution([p floatValue:a], [p floatValue:b], [p floatValue:c], [p floatValue:s], [p floatValue:squared_area]);
         } withTimeLimit:[args timeOut]];
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}
