#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

#define NBLOOPS 100

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
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORGroup> g = [args makeGroup:model];
         
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
         
         
         [g add:[theta[0] eq:@(0.0f)]];
         [g add:[x[0] eq:@(0.0f)]];
         [g add:[y[0] eq:@(0.0f)]];
         
         [g add:[theta_opt[0] eq:@(0.0f)]];
         [g add:[x_opt[0] eq:@(0.0f)]];
         [g add:[y_opt[0] eq:@(0.0f)]];
         
         [g add:[delta_dl eq:[c mul:sl]]];
         [g add:[delta_dr eq:[c mul:sr]]];
         [g add:[delta_d eq:[[delta_dl plus:delta_dr] mul:expr_3]]];
         [g add:[delta_theta eq:[[delta_dr sub:delta_dl] mul:inv_l]]];
         
         [g add:[TMP_6 eq:[expr_2 mul:[expr_3 mul:[expr_4 sub:[c mul: sl]]]]]];
         
         for (ORUInt n = 0; n < NBLOOPS; n++) {
            
            [g add:[arg[n] eq:[theta[n] plus:[delta_theta mul:expr_3]]]];
            [g add:[cos[n] eq:[[expr_1 sub:[[arg[n] mul:arg[n]] mul:expr_3]] plus:[[[[arg[n] mul:arg[n]] mul:arg[n]] mul:arg[n]] div:@(24.0f)]]]];
            [g add:[x[n+1] eq:[x[n] plus:[delta_d mul:cos[n]]]]];
            [g add:[sin[n] eq:[[arg[n] sub:[[[arg[n] mul:arg[n]] mul:arg[n]] div:@(6.0f)]] plus:[[[[[arg[n] mul:arg[n]] mul:arg[n]] mul:arg[n]] mul:arg[n]] div:@(120.f)]]]];
            
            [g add:[y[n+1] eq:[y[n] plus:[delta_d mul:sin[n]]]]];
            [g add:[theta[n+1] eq:[theta[n] plus:delta_theta]]];
            
            [g add:[TMP_23[n] eq:[[theta_opt[n] plus:[[[expr_4 sub:[sl mul: c]] mul: expr_2] mul: expr_3]] mul: [theta_opt[n] plus: [[[expr_4 sub: [sl mul: c]] mul: expr_2] mul: expr_3]]]]];
            
            [g add:[TMP_25[n] eq:[[[theta_opt[n] plus:TMP_6] mul:[theta_opt[n] plus:TMP_6]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:expr_2] mul:expr_3]]]]];
            [g add:[TMP_26[n] eq:[theta_opt[n] plus:TMP_6]]];
            
            [g add:[x_opt[n+1] eq:[[expr_3 mul:[[[expr_1 sub:[TMP_23[n] mul:expr_3]] plus:[[TMP_25[n] mul:TMP_26[n]] div:@(24.0f)]] mul:[[c mul: sl] plus:expr_4]]] plus:x_opt[n]]]];
            
            
            [g add:[TMP_27[n] eq:[[TMP_26[n] mul: TMP_26[n]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:expr_2] mul: expr_3]]]]];
            
            
            [g add:[TMP_29[n] eq:[[[TMP_26[n] mul: TMP_26[n]] mul: TMP_26[n]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:expr_2] mul:expr_3]]]]];
            
            
            [g add:[y_opt[n+1] eq:[[[expr_4 plus:[c mul: sl]] mul:[[[TMP_26[n] sub: [TMP_27[n] div:@(6.0f)]] plus:[[TMP_29[n] mul: TMP_26[n]] div: @(120.0f)]] mul:expr_3]] plus: y_opt[n]]]] ;
            
            [g add:[theta_opt[n+1] eq:[theta_opt[n] plus:[expr_2 mul:[expr_4 sub:[c mul: sl]]]]]];
            
         }
         
         [g add:[diff eq:[y_opt[NBLOOPS] sub:y[NBLOOPS]]]];
         [g add:[[diff mul:diff] eq:@(0.0f)]];
         [model add:g];
         
         NSLog(@"%@", model);
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
            NSLog(@"diff : %16.16f", [p floatValue:y_opt[1]] - [p floatValue:y[1]] );
            
            [args checkAbsorption:vars solver:cp];
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}
