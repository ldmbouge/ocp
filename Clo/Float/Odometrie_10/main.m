#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

#define NBLOOPS 10

void checksolution(float sl){
  
  fesetround(FE_TONEAREST);
  float sr = 0.785398163397f;
  float theta = 0.0f;
  float x = 0.0f;
  float y = 0.0f;
  float inv_l = 0.1f;
  float c = 12.34f;
  float c2 = 9.691813336318980f;
  float delta_dl, delta_dr, delta_d, delta_theta, arg, cos, sin;
  float TMP_6, TMP_23, TMP_25, TMP_26, x_opt, y_opt, TMP_27, TMP_29, theta_opt;
  
  theta_opt = 0.0f;
  x_opt = 0.0f;
  y_opt = 0.0f;
  int nb = 0;
  
  delta_dl = (c * sl) ;
  delta_dr = (c * sr) ;
  delta_d = ((delta_dl + delta_dr) * 0.5f) ;
  delta_theta = ((delta_dr - delta_dl) * inv_l) ;
  arg = (theta + (delta_theta * 0.5f)) ;
  cos = (1.0f - ((arg * arg) * 0.5f)) + ((((arg * arg)* arg)* arg) / 24.0f);
  x = (x + (delta_d * cos)) ;
  sin = (arg - (((arg * arg)* arg)/6.0f)) + (((((arg * arg)* arg)* arg)* arg)/120.0f);
  y = (y + (delta_d * sin));
  theta = (theta + delta_theta) ;
  
  TMP_6 = (0.1f * (0.5f * (c2 - (c * sl)))) ;
  TMP_23 = ((theta_opt + (((c2 - (sl * c)) * 0.1f) * 0.5f)) * (theta_opt + (((c2 - (sl * c)) * 0.1f) * 0.5f))) ;
  TMP_25 = ((theta_opt + TMP_6)*(theta_opt + TMP_6))*(theta_opt + (((c2 - (sl * c)) * 0.1f) * 0.5f)) ;
  TMP_26 = (theta_opt + TMP_6) ;
  x_opt = ((0.5f * (((1.0f - (TMP_23 * 0.5f)) + ((TMP_25 * TMP_26) / 24.0f)) * ((c * sl) + c2))) + x_opt) ;
  TMP_27 = ((TMP_26 * TMP_26) * (theta_opt + (((c2 - (sl * c)) * 0.1f) * 0.5f))) ;
  TMP_29 = (((TMP_26 * TMP_26) * TMP_26) * (theta_opt + (((c2 - (sl * c)) * 0.1f) * 0.5f))) ;
  y_opt = (((c2 + (c * sl)) * (((TMP_26 - (TMP_27 / 6.0f)) + ((TMP_29 * TMP_26) / 120.0f)) * 0.5f)) + y_opt) ;
  theta_opt = (theta_opt + (0.1f * (c2 - (c * sl)))) ;
  if(y != y_opt) printf("(x) %16.16e != (x_opt) %16.16e\n", y, y_opt);
  //      else nb++;
  
  printf ("diff : %24.24e\n", y_opt - y);
  printf ("%d\n", nb);
}


int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
    id<ORModel> model = [ORFactory createModel];
    NSMutableArray* toadd = [[NSMutableArray alloc] init];
    
    fesetround(FE_TONEAREST);
    id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
    id<ORFloatVar> sl = [ORFactory floatVar:model low:0.52f up:0.53f name:@"sl"];
    
    /* Constant */
    id<ORExpr> sr = [ORFactory float:model value:0.785398163397f];
    id<ORExpr> inv_l = [ORFactory float:model value:0.1f];
    id<ORExpr> c = [ORFactory float:model value:12.34f];
    id<ORExpr> expr_1 = [ORFactory float:model value:1.f];
    id<ORExpr> expr_2 = [ORFactory float:model value:0.1f];
    id<ORExpr> expr_3 = [ORFactory float:model value:0.5f];
    id<ORExpr> expr_4 = [ORFactory float:model value:9.691813336318980f];
    
    id<ORFloatVar> delta_dl = [ORFactory floatVar:model name:@"delta_dl"];
    id<ORFloatVar> delta_dr = [ORFactory floatVar:model name:@"delta_dr"];
    id<ORFloatVar> delta_d = [ORFactory floatVar:model name:@"delta_d"];
    id<ORFloatVar> delta_theta = [ORFactory floatVar:model name:@"delta_theta"];
    
    id<ORFloatVar> TMP_6 = [ORFactory floatVar:model name:@"TMP_6"];
    
    id<ORFloatVarArray> arg = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"arg"];
    id<ORFloatVarArray> cos = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"cos"];
    id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"x"];
    id<ORFloatVarArray> sin = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"sin"];
    id<ORFloatVarArray> y = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"y"];
    id<ORFloatVarArray> theta = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"theta"];
    
    id<ORFloatVarArray> TMP_23 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_23"];
    id<ORFloatVarArray> TMP_25 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_25"];
    id<ORFloatVarArray> TMP_26 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_26"];
    id<ORFloatVarArray> TMP_27 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_27"];
    id<ORFloatVarArray> TMP_29 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_29"];
    
    id<ORFloatVarArray> x_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"x_opt"];
    id<ORFloatVarArray> y_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"y_opt"];
    id<ORFloatVarArray> theta_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"theta_opt"];
    
    
    [toadd addObject:[theta[0] set:@(0.0f)]];
    [toadd addObject:[x[0] set:@(0.0f)]];
    [toadd addObject:[y[0] set:@(0.0f)]];
    
    [toadd addObject:[theta_opt[0] set:@(0.0f)]];
    [toadd addObject:[x_opt[0] set:@(0.0f)]];
    [toadd addObject:[y_opt[0] set:@(0.0f)]];
    
    [toadd addObject:[delta_dl set:[c mul:sl]]];
    [toadd addObject:[delta_dr set:[c mul:sr]]];
    [toadd addObject:[delta_d set:[[delta_dl plus:delta_dr] mul:expr_3]]];
    [toadd addObject:[delta_theta set:[[delta_dr sub:delta_dl] mul:inv_l]]];
    
    [toadd addObject:[TMP_6 set:[expr_2 mul:[expr_3 mul:[expr_4 sub:[c mul: sl]]]]]];
    
    for (ORUInt n = 0; n < NBLOOPS; n++) {
      
      [toadd addObject:[arg[n] set:[theta[n] plus:[delta_theta mul:expr_3]]]];
      [toadd addObject:[cos[n] set:[[expr_1 sub:[[arg[n] mul:arg[n]] mul:expr_3]] plus:[[[[arg[n] mul:arg[n]] mul:arg[n]] mul:arg[n]] div:@(24.0f)]]]];
      [toadd addObject:[x[n+1] set:[x[n] plus:[delta_d mul:cos[n]]]]];
      [toadd addObject:[sin[n] set:[[arg[n] sub:[[[arg[n] mul:arg[n]] mul:arg[n]] div:@(6.0f)]] plus:[[[[[arg[n] mul:arg[n]] mul:arg[n]] mul:arg[n]] mul:arg[n]] div:@(120.f)]]]];
      
      [toadd addObject:[y[n+1] set:[y[n] plus:[delta_d mul:sin[n]]]]];
      [toadd addObject:[theta[n+1] set:[theta[n] plus:delta_theta]]];
      
      [toadd addObject:[TMP_23[n] set:[[theta_opt[n] plus:[[[expr_4 sub:[sl mul: c]] mul: expr_2] mul: expr_3]] mul: [theta_opt[n] plus: [[[expr_4 sub: [sl mul: c]] mul: expr_2] mul: expr_3]]]]];
      
      [toadd addObject:[TMP_25[n] set:[[[theta_opt[n] plus:TMP_6] mul:[theta_opt[n] plus:TMP_6]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:expr_2] mul:expr_3]]]]];
      [toadd addObject:[TMP_26[n] set:[theta_opt[n] plus:TMP_6]]];
      
      [toadd addObject:[x_opt[n+1] set:[[expr_3 mul:[[[expr_1 sub:[TMP_23[n] mul:expr_3]] plus:[[TMP_25[n] mul:TMP_26[n]] div:@(24.0f)]] mul:[[c mul: sl] plus:expr_4]]] plus:x_opt[n]]]];
      
      
      [toadd addObject:[TMP_27[n] set:[[TMP_26[n] mul: TMP_26[n]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:expr_2] mul: expr_3]]]]];
      
      
      [toadd addObject:[TMP_29[n] set:[[[TMP_26[n] mul: TMP_26[n]] mul: TMP_26[n]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:expr_2] mul:expr_3]]]]];
      
      
      [toadd addObject:[y_opt[n+1] set:[[[expr_4 plus:[c mul: sl]] mul:[[[TMP_26[n] sub: [TMP_27[n] div:@(6.0f)]] plus:[[TMP_29[n] mul: TMP_26[n]] div: @(120.0f)]] mul:expr_3]] plus: y_opt[n]]]] ;
      
      [toadd addObject:[theta_opt[n+1] set:[theta_opt[n] plus:[expr_2 mul:[expr_4 sub:[c mul: sl]]]]]];
      
    }
    
    [toadd addObject:[diff set:[y_opt[NBLOOPS] sub:y[NBLOOPS]]]];
    [toadd addObject:[[diff mul:diff] eq:@(0.0f)]];
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    
    
     [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[theta[0],x[0],y[0],theta_opt[0],x_opt[0],y_opt[0]]];
    
  }
  return 0;
}

