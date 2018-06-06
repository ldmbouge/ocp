//
//  main.m
//  square10
//
//  Created by Zitoun on 06/07/2017.
//
//

#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
#include <fenv.h>

#define VAL 1.398f

void check_solution(float IN, float res){
   float x = IN;
   
   float result =
   1.0f + 0.5f*x - 0.125f*x*x + 0.0625f*x*x*x - 0.0390625f*x*x*x*x;
   if(IN < 0.0f || IN > 1.f) printf("Erreur : Borne incorrecte\n");
   if(res != result) printf("ERREUR : %16.16e != %16.16e\n",res,result);
   if(!(result >= 0.0f && result < VAL)) printf("resultat OK\n");
   else printf("ERREUR :resultat erronee\n");
   
}
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> IN = [ORFactory floatVar:model low:0.0f up:1.f];
         id<ORFloatVar> result = [ORFactory floatVar:model];
         
         id<ORExpr> fc = [ORFactory float:model value:1.0f];
         id<ORExpr> fc2 = [ORFactory float:model value:0.5f];
         id<ORExpr> fc3 = [ORFactory float:model value:0.125f];
         id<ORExpr> fc4 = [ORFactory float:model value:0.0625f];
         id<ORExpr> fc5 = [ORFactory float:model value:0.0390625f];
         id<ORGroup> g = [args makeGroup:model];
         
         [model add:[IN lt:@(1.0f)]];
         
         [g add:[result eq:[[[[fc plus:[fc2 mul:IN]] sub: [[fc3 mul:IN ] mul:IN]] plus: [[[fc4 mul:IN] mul:IN] mul:IN]] sub:[[[[fc5 mul:IN] mul:IN] mul:IN] mul:IN]]]];
         
         [g add:[[result lt:@(0.0f)] lor: [result geq:@(VAL)]]];
         [model add:g];

//         NSLog(@"%@",model);
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
            check_solution([p floatValue:vars[0]], [p floatValue:vars[1]]);
         } withTimeLimit:[args timeOut]];
         
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
         
      }];
      
      
   }
   return 0;
}

