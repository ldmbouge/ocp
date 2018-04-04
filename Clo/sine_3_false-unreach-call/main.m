#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
#include <fenv.h>

#define VAL 1.001f
/**
 
 def sineTaylor(x: Real): Real = {
 require(−2.0 < x && x < 2.0)
 x − (x∗x∗x)/6.0 + (x∗x∗x∗x∗x)/120.0 − (x∗x∗x∗x∗x∗x∗x)/5040.0
 } ensuring(res => −1.0 < res && res < 1.0 && res +/− 1e−14)
 
 
 **/


void checksolution(float IN,float res){
   if(!(IN >= -1.57079632679f && IN <= 1.57079632679f)) printf("IN n'est pas dans le bon range\n");
   float x = IN;
   
   float result = x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
   if(res != result) printf("Erreur %16.16e != %16.16e\n",res,result);
   else if(res <= VAL && res >= -VAL) printf("Erreur resultat incorrect\n");
   else printf("resultat oK\n");
}


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> x = [ORFactory floatVar:model low:-1.57079632f up:1.57079632f];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         
         id<ORGroup> g = [args makeGroup:model];
         [g add:[res eq:[[[x sub:
                           [[x mul:[x mul:x]] div:@(6.0f)]] plus:
                          [[x mul:[x mul:[x mul:[x mul:x]]]] div:@(120.0f)]] plus:
                         [[x mul:[x mul:[x mul:[x mul:[x mul:[x mul:x]]]]]] div:@(5040.0f)]]]];
         
         [g add:[[res lt:@(-VAL)] lor:[res gt:@(VAL)]]];
         
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
            checksolution([p floatValue:vars[0]], [p floatValue:vars[1]]);
         } withTimeLimit:[args timeOut]];
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}

