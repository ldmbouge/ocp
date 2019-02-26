//
//  sine.m
//  ORUtilities
//
//  Created by Remy Garcia on 11/04/2018.
//

#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
#include <fenv.h>

#define VAL 1.0
void checksolution(float IN,float res){
   if(!(IN >= -1.57079632679f && IN <= 1.57079632679f)) printf("IN n'est pas dans le bon range\n");
   float x = IN;
   
   float result = x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
   if(res != result) printf("Erreur %16.16e != %16.16e\n",res,result);
//   else if(res < VAL && res > -VAL) printf("Erreur resultat incorrect\n");
   else printf("resultat oK\n");
}




int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         //normalisation transform constraints as Integer ones
         //should not happen !
         
      id<ORModel> model = [ORFactory createModel];
      id<ORDoubleVar> x = [ORFactory doubleVar:model low:-1.57079632679 up:1.57079632679 name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:model name:@"z"];
      
      id<ORGroup> g = [args makeGroup:model];
      
      [g add:[z eq: [[[x sub: [ [[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]] sub: [[[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0)]]]];
      
      
      [g add:[z lt: @(VAL)]];
//      [g add:[z gt: @(-VAL)]];
      
      [model add:g];
      id<ORDoubleVarArray> vars = [model doubleVars];
      id<CPProgram> cp = [args makeProgram:model];
         id<ORDisabledVarArray> nvars = [ORFactory disabledFloatVarArray:vars engine:[cp engine]];
      __block bool found = false;
      
      [cp solve:^{
            [cp lexicalOrderedSearch:nvars do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplitD:i withVars:x];
            }];
         NSLog(@"Valeurs solutions : \n");
         found=true;
         for(id<ORFloatVar> v in nvars){
            found &= [cp bound: v];
            NSLog(@"%@ : %20.20e (%s) %@",v,[cp floatValue:v],[cp bound:v] ? "YES" : "NO",[cp concretize:v]);
         }
      }];
         
         struct ORResult r = REPORT(1, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
         
      }];
      
      
   }
   return 0;
}

