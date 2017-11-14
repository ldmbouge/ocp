#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 From: Nasrine Damouche, Matthieu Martel, Alexandre Chapoutot. Intra-procedural Optimization of the Numerical Accuracy of Programs. Formal Methods for Industrial Critical Systems, 9128, Springer Verlag, 2015, Lecture Notes in Computer Science, 978-3-319-19457-8. (page 14, fig 9)
 
	sl = [0.52,0.53];
	sr = 0.785398163397;
	theta = 0.0;
	t = 0.0;
	x = 0.0;
	y = 0.0;
	inv_l = 0.1;
	c = 12.34;
	while (t < 100.0) do {
 delta_dl = (c * sl) ;
 delta_dr = (c * sr) ;
 delta_d = ((delta_dl + delta_dr) * 0.5) ;
 delta_theta = ((delta_dr - delta_dl) * inv_l) ;
 arg = (theta + (delta_theta * 0.5)) ;
 cos = (1.0 - ((arg * arg) * 0.5)) + ((((arg * arg)* arg)* arg) / 24.0);
 x = (x + (delta_d * cos)) ;
 sin = (arg - (((arg * arg)* arg)/6.0))
 + (((((arg * arg)* arg)* arg)* arg)/120.0);
 y = (y + (delta_d * sin));
 theta = (theta + delta_theta) ;
 t = (t + 0.1)
 }
 
 while (t < 100.0) do {
 TMP_6 = (0.1 * (0.5 * (9.691813336318980 - (12.34 * sl)))) ;
 TMP_23 = ((theta + (((9.691813336318980 - (sl * 12.34)) * 0.1) * 0.5))
 * (theta + (((9.691813336318980 - (sl * 12.34)) * 0.1) * 0.5))) ;
 TMP_25 = ((theta + TMP_6)*(theta + TMP_6))*(theta + (((9.691813336318980
 - (sl * 12.34)) * 0.1) * 0.5)) ;
 TMP_26 = (theta + TMP_6) ;
 x = ((0.5 * (((1.0 - (TMP_23 * 0.5)) + ((TMP_25 * TMP_26) / 24.0))
 * ((12.34 * sl) + 9.691813336318980))) + x) ;
 TMP_27 = ((TMP_26 * TMP_26) * (theta + (((9.691813336318980
 - (sl * 12.34)) * 0.1) * 0.5))) ;
 TMP_29 = (((TMP_26 * TMP_26) * TMP_26) * (theta + (((9.691813336318980
 - (sl * 12.34)) * 0.1) * 0.5))) ;
 y = (((9.691813336318980 + (12.34 * sl)) * (((TMP_26 - (TMP_27 / 6.0))
 + ((TMP_29 * TMP_26) / 120.0)) * 0.5)) + y) ;
 theta = (theta + (0.1 * (9.691813336318980 - (12.34 * sl)))) ;
 t = t + 0.1 ; }
 */

#define NBLOOPS 4


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> diff = [ORFactory floatVar:model];
         /* Input */
         id<ORFloatVar> sl = [ORFactory floatVar:model low:0.52f up:0.53f];
         
         /* Constant */
         id<ORExpr> sr = [ORFactory float:model value:0.785398163397f];
         id<ORExpr> inv_l = [ORFactory float:model value:0.1f];
         id<ORExpr> c = [ORFactory float:model value:12.34f];
         id<ORExpr> expr_1 = [ORFactory float:model value:1.f];
         id<ORExpr> expr_2 = [ORFactory float:model value:0.1f];
         id<ORExpr> expr_3 = [ORFactory float:model value:0.5f];
         id<ORExpr> expr_4 = [ORFactory float:model value:9.691813336318980f];
         
         id<ORFloatVar> delta_dl = [ORFactory floatVar:model];
         id<ORFloatVar> delta_dr = [ORFactory floatVar:model];
         id<ORFloatVar> delta_d = [ORFactory floatVar:model];
         id<ORFloatVar> delta_theta = [ORFactory floatVar:model];
         
         id<ORFloatVar> TMP_6 = [ORFactory floatVar:model];
         
         id<ORFloatVarArray> arg = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> cos = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> sin = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> y = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> theta = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         
         id<ORFloatVarArray> TMP_23 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_25 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_26 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_27 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_29 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         
         id<ORFloatVarArray> x_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> y_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> theta_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         
         
         [model add:[theta[0] eq:@(0.0f)]];
         [model add:[x[0] eq:@(0.0f)]];
         [model add:[y[0] eq:@(0.0f)]];
         
         [model add:[theta_opt[0] eq:@(0.0f)]];
         [model add:[x_opt[0] eq:@(0.0f)]];
         [model add:[y_opt[0] eq:@(0.0f)]];
         
         [model add:[delta_dl eq:[c mul:sl]]];
         [model add:[delta_dr eq:[c mul:sr]]];
         [model add:[delta_d eq:[[delta_dl plus:delta_dr] mul:@(0.5f)]]];
         [model add:[delta_theta eq:[[delta_dr plus:delta_dl] mul:inv_l]]];
         
         
//         TMP_6 = (0.1 * (0.5 * (9.691813336318980 - (12.34 * sl)))) ;
         [model add:[TMP_6 eq:[expr_2 mul:[expr_3 mul:[expr_4 sub:[c mul: sl]]]]]];
         
         for (ORUInt n = 0; n < NBLOOPS; n++) {
            
            [model add:[arg[n] eq:[theta[n] plus:[delta_theta mul:@(0.5f)]]]];
            [model add:[cos[n] eq:[[expr_1 sub:[[arg[n] mul:arg[n]] mul:@(0.5f)]] plus:[[[[arg[n] mul:arg[n]] mul:arg[n]] mul:arg[n]] div:@(24.0f)]]]];
            [model add:[x[n+1] eq:[x[n] plus:[delta_d mul:cos[n]]]]];
            //sin = (arg - (((arg * arg)* arg)/6.0))+ (((((arg * arg)* arg)* arg)* arg)/120.0);
            [model add:[sin[n] eq:[arg[n] sub:[[[[arg[n] mul:arg[n]] mul:arg[n]] div:@(6.0f)] plus:[[[[[arg[n] mul:arg[n]] mul:arg[n]] mul:arg[n]] mul:arg[n]] div:@(120.f)]]]]];
            [model add:[y[n+1] eq:[y[n] plus:[delta_d mul:sin[n]]]]];
//            theta = (theta + delta_theta) ;
            [model add:[theta[n+1] eq:[theta[n] plus:delta_theta]]];
            
//            TMP_23 = ((theta + (((9.691813336318980 - (sl * 12.34)) * 0.1) * 0.5)) * (theta + (((9.691813336318980 - (sl * 12.34)) * 0.1) * 0.5))) ;
            [model add:[TMP_23[n] eq:[[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:expr_2] mul:@(0.5)]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:@(0.1)] mul:@(0.5)]]]]];
            
//            TMP_25 = ((theta + TMP_6)*(theta + TMP_6))*(theta + (((9.691813336318980 - (sl * 12.34)) * 0.1) * 0.5)) ;
            [model add:[TMP_25[n] eq:[[[theta_opt[n] plus:TMP_6] mul:[theta_opt[n] plus:TMP_6]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:@(0.1)] mul:@(0.5)]]]]];
            [model add:[TMP_26[n] eq:[theta_opt[n] plus:TMP_6]]];
            [model add:[x_opt[n+1] eq:[[expr_3 mul:[[[expr_1 sub:[TMP_23[n] mul:@(0.5)]] plus:[[TMP_25[n] mul:TMP_26[n]] div:@(24.0)]] mul:[[c mul: sl] plus:expr_4]]] plus:x_opt[n]]]];
            [model add:[TMP_27[n] eq:[[TMP_26[n] mul: TMP_26[n]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:@(0.1)] mul: @(0.5)]]]]];
            [model add:[TMP_29[n] eq:[[[TMP_26[n] mul: TMP_26[n]] mul: TMP_26[n]] mul:[theta_opt[n] plus:[[[expr_4 sub:[sl mul:c]] mul:@(0.1)] mul:@(0.5)]]]]];
            
            [model add:[y_opt[n+1] eq:[[[expr_4 plus:[c mul: sl]] mul:[[[TMP_26[n] sub: [TMP_27[n] div:@(6.0)]] plus:[[TMP_29[n] mul: TMP_26[n]] div: @(120.0)]] mul: @(0.5)]] plus: y_opt[n]]]] ;
            [model add:[theta_opt[n+1] eq:[theta_opt[n] plus:[expr_2 mul:[expr_4 sub:[c mul: sl]]]]]];
          
         }
         
         //         model.add(diff = *(m[NBLOOPS]) - *(m_opt[NBLOOPS]));
         //         model.add(diff*diff > 0.0622f);
         
         [model add:[diff eq:[x[NBLOOPS] sub:x_opt[NBLOOPS]]]];
         [model add:[[diff mul:diff] gt:@(0.0622f)]];
         
         //         NSLog(@"%@", model);
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         
         [cp solveOn:^(id<CPCommonProgram> p) {
            
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               id<CPFloatVar> cv = [cp concretize:v];
               found &= [p bound: v];
               //               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
               
               NSLog(@"%@",cv);
            }
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}
