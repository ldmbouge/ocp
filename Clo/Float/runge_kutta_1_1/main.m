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
#define NBLOOPS 1

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
    id<ORModel> model = [ORFactory createModel];
    NSMutableArray* toadd = [[NSMutableArray alloc] init];
    
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
    
    [toadd addObject:[y[0] geq:@(-10.1f)]];
    [toadd addObject:[y[0] leq:@(10.1f)]];
    [toadd addObject:[y_opt[0] geq:@(-10.1f)]];
    [toadd addObject:[y_opt[0] leq:@(10.1f)]];
    
    [toadd addObject:[y[0] set:y_opt[0]]];
    
    for (ORUInt n = 0; n < NBLOOPS; n++) {
      //            k1 = k * (c - yn) * (c - yn);
      //            k2 = k * (c -(yn + (0.5 * h * k1))) * (c - (yn + (0.5 * h * k1)));
      //            yn+1 = yn + h * k2;
      //            yn = yn+1;
      [toadd addObject:[k1[n] set:[[k mul:[c sub: y[n]]] mul: [c sub:y[n]]]]];
      [toadd addObject:[k2[n] set:[[k mul:[c sub:[y[n] plus:[[c1 mul:h] mul:k1[n]]]]] mul: [c sub:[y[n] plus:[[c1 mul:h] mul:k1[n]]]]]]];
      [toadd addObject:[y[n+1] set:[y[n] plus:[h mul:k2[n]]]]];
      
      //            yn+1 = (yn + (( 1.2 * (10.1 -  ((((1.2 * (10.1 -  yn)) * (10.1 - yn))
      //                                             * 0.005) + yn))) * (10.1 -  ((((1.2 * (10.1 -  yn)) * (10.1 -  yn))
      //                                                                           * 0.005) + yn))));
      [toadd addObject:[y_opt[n+1] set:[y_opt[n] plus:[[k mul:[c3 sub:[[[[k mul:[c3 sub:y_opt[n]]] mul:[c3 sub:y_opt[n]]] mul:c4] plus:y_opt[n]]]] mul:[c3 sub:[[[[k mul:[c3 sub:y_opt[n]]] mul:[c3 sub:y_opt[n]]] mul:c4] plus:y_opt[n]]]]]]];
      
    }
    
    [toadd addObject:[diff set:[y[NBLOOPS] sub:y_opt[NBLOOPS]]]];
    [toadd addObject:[[diff mul:diff] gt:@(0.0f)]];
    
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[y[0],y_opt[0]]];
    
  }
  return 0;
}

