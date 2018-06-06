#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>
/*
 yn = [ 10.1,10.1]; t = 0.0; k = 1.2; c = 100.1;
 while(t < 1.0) do {
 k1 = k * (c - yn) * (c - yn);
 k2 = k * (c -(yn + (0.5 * h * k1))) * (c - (yn + (0.5 * h * k1)));
 yn+1 = yn + h * k2;
 yn = yn+1;
 }
 
 while(t < 1.0) do {
 yn+1 = (yn + (( 1.2 * (10.1 -  ((((1.2 * (10.1 -  yn)) * (10.1 - yn))
 * 0.005) + yn))) * (10.1 -  ((((1.2 * (10.1 -  yn)) * (10.1 -  yn))
 * 0.005) + yn))));
 yn = yn+1;
 }
 */
#define NBLOOPS 3

void checksolution(float yi, float yi_opt, float yl, float yl_opt, float diff)
{
   float k = 1.2f;
   float c = 100.1f;
   float h = 0.1f;
   float k1 = 0.0f;
   float k2 = 0.0f;
   float ynext = 0.0f;
   float ynext_opt = 0.0f;
   
   for(int i = 0; i < NBLOOPS; i++){
      k1 = k * (c - yi) * (c - yi);
      k2 = k * (c -(yi + (0.5f * h * k1))) * (c - (yi + (0.5f * h * k1)));
      ynext = yi + h * k2;
      yi = ynext;
      
      ynext_opt = (yi_opt + ((k * (10.1f -  ((((k * (10.1f -  yi_opt)) * (10.1f - yi_opt)) * 0.005f) + yi_opt))) * (10.1f -  ((((k * (10.1f -  yi_opt)) * (10.1f - yi_opt)) * 0.005f) + yi_opt))));
      yi_opt = ynext_opt;
   }
   if(ynext != yl)
      printf ("y n'est pas correct");
   if(ynext_opt != yl_opt)
      printf ("y_opt n'est pas correct");
   if(ynext - ynext_opt == 0.0f)
      printf ("Différence égale à 0\n");
   if(ynext - ynext_opt != diff)
      printf ("L'Erreur n'est pas correct %16.16e != %16.16e\n", ynext - ynext_opt, diff);
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORGroup> g = [args makeGroup:model];
         
         fesetround(FE_TONEAREST);
         id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
         
         //Cc1 = 0.0; Dc = -1280.0;Cc0 = 564.48;Ac00 = 0.499; Ac01 = -0.05; Ac10 = 0.01;
         id<ORExpr> c = [ORFactory float:model value:100.1f];
         id<ORExpr> c1 = [ORFactory float:model value:0.5f];
         id<ORExpr> k = [ORFactory float:model value:1.2f];
         id<ORExpr> c3 = [ORFactory float:model value:10.1f];
         id<ORExpr> c4 = [ORFactory float:model value:0.005f];
         id<ORExpr> h = [ORFactory float:model value:0.1f];
         
         
         //xc0, xc1 ,xc0_opt, xc1_opt, yc, y, u
         id<ORFloatVarArray> k1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"k1"];
         id<ORFloatVarArray> k2 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"k2"];
         id<ORFloatVarArray> y = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"yn"];
         
         id<ORFloatVarArray> y_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"yn_opt"];
         
         [g add:[y[0] geq:@(-10.1f)]];
         [g add:[y[0] leq:@(10.1f)]];
         [g add:[y_opt[0] geq:@(-10.1f)]];
         [g add:[y_opt[0] leq:@(10.1f)]];
         
         
         
         for (ORUInt n = 0; n < NBLOOPS; n++) {
            //            k1 = k * (c - yn) * (c - yn);
            //            k2 = k * (c -(yn + (0.5 * h * k1))) * (c - (yn + (0.5 * h * k1)));
            //            yn+1 = yn + h * k2;
            //            yn = yn+1;
            [g add:[k1[n] eq:[[k mul:[c sub: y[n]]] mul: [c sub:y[n]]]]];
            [g add:[k2[n] eq:[[k mul:[c sub:[y[n] plus:[[c1 mul:h] mul:k1[n]]]]] mul: [c sub:[y[n] plus:[[c1 mul:h] mul:k1[n]]]]]]];
            [g add:[y[n+1] eq:[y[n] plus:[h mul:k2[n]]]]];
            
            //            yn+1 = (yn + (( 1.2 * (10.1 -  ((((1.2 * (10.1 -  yn)) * (10.1 - yn))
            //                                             * 0.005) + yn))) * (10.1 -  ((((1.2 * (10.1 -  yn)) * (10.1 -  yn))
            //                                                                           * 0.005) + yn))));
            [g add:[y_opt[n+1] eq:[y_opt[n] plus:[[k mul:[c3 sub:[[[[k mul:[c3 sub:y_opt[n]]] mul:[c3 sub:y_opt[n]]] mul:c4] plus:y_opt[n]]]] mul:[c3 sub:[[[[k mul:[c3 sub:y_opt[n]]] mul:[c3 sub:y_opt[n]]] mul:c4] plus:y_opt[n]]]]]]];
            
         }
         
         [g add:[diff eq:[y[NBLOOPS] sub:y_opt[NBLOOPS]]]];
         [g add:[[diff mul:diff] gt:@(0.0f)]];
         [model add:g];
         
//         NSLog(@"%@", model);
         
         NSLog(@"%d", [g size]);
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         
         fesetround(FE_TONEAREST);
         [cp solveOn:^(id<CPCommonProgram> p) {
            found = true;
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               id<CPFloatVar> cv = [cp concretize:v];
               found &= [p bound: v];
               NSLog(@"%@ = %16.16e (%s)",v,[cv value], [p bound:v] ? "YES" : "NO");
            }
            [args checkAbsorption:vars solver:cp];
            checksolution([p floatValue:y[0]], [p floatValue:y_opt[0]], [p floatValue:y[NBLOOPS]],[p floatValue:y_opt[NBLOOPS]], [p floatValue:diff]);
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}
