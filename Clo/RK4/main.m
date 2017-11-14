#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 From: Nasrine Damouche, Matthieu Martel, Alexandre Chapoutot. Intra-procedural Optimization of the Numerical Accuracy of Programs. Formal Methods for Industrial Critical Systems, 9128, Springer Verlag, 2015, Lecture Notes in Computer Science, 978-3-319-19457-8. (page 14, fig 9)
 yn = [-10.1,10.1]; t = 0.0; k = 1.2;
 c = 100.1; h = 0.1;
 while (t < 1.) do {
 k1 = (k*(c-yn))*(c-yn) ;
 k2 = (k*(c-(yn+((0.5*h)*k1))))
 *(c-(yn+((0.5*h)*k1)));
 k3 = (k*(c-(yn+((0.5*h)*k2))))
 *(c-(yn+((0.5*h)*k2)));
 k4 = (k*(c-(yn+(h*k3))))
 *(c-(yn+(h*k3)));
 yn+1 = yn+((1/6*h)*(((k1+(2.0*k2))
 +(2.0*k3))+k4));
 t = (t + h) }
 
 while (t < 1.0) do {
 TMP_7 = (1.2 * (100.099 - yn)) ;
 TMP_8 = (100.099 - yn) ;
 TMP_13 = (1.2*(100.099-(yn+(0.05*((1.2
 * (100.099-(yn+(0.05*(TMP_7*TMP_8)))))
 * (100.099-(yn+(0.05*((1.2*TMP_8)
 * (100.099-yn)))))))))) ;
 TMP_14 = (100.099-(yn+(0.05*((1.2*(100.099
 - (yn+(0.05*(TMP_7*TMP_8)))))*(100.099
 - (yn+(0.05*((1.2*TMP_8)*(100.099-yn));
 TMP_18 = (yn+(0.05*((1.2*(100.099-(yn+(0.05
 * (TMP_7*TMP_8)))))*(100.099-(yn+(0.05
 * ((1.2*TMP_8)*(100.099-yn))))))));
 TMP_28 = ((1.2*(100.099-(yn+(0.05*(TMP_7
 * TMP_8)))))*(100.099-(yn+(0.05*((1.2
 * TMP_8)*(100.099-yn))))));
 TMP_38 = ((TMP_14*TMP_13)*0.1) + yn ;
 TMP_40 = 0.1*((1.2*TMP_14)*(100.099-TMP_18));
 yn_plus_1 = (yn+(0.016666667*((((TMP_7*TMP_8)
 + (2.0*TMP_28))+(2.0*(TMP_13*TMP_14)))
 +((1.2*(100.099-TMP_38))*(100.099-(yn
 +TMP_40)))))); + [...] ;
 t = (t + 0.1) }
  */

#define NBLOOPS 4


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> diff = [ORFactory floatVar:model];
         
         /* Input */
         id<ORFloatVar> y_init = [ORFactory floatVar:model low:-10.1f up:10.1f];
         
         /* Constant */
         id<ORExpr> c = [ORFactory float:model value:100.1f];
         id<ORExpr> k = [ORFactory float:model value:1.2f];
         id<ORExpr> h = [ORFactory float:model value:0.1f];
         
         id<ORExpr> expr_0 = [ORFactory float:model value:6.f];
         id<ORExpr> expr_1 = [ORFactory float:model value:2.0f];
         id<ORExpr> expr_2 = [ORFactory float:model value:0.5f];
         id<ORExpr> expr_3 = [ORFactory float:model value:1.f];
         
         id<ORExpr> e2_0 = [ORFactory float:model value:100.099f];
         id<ORExpr> e4_0 = [ORFactory float:model value:0.016666667f];
         id<ORExpr> e_0 = [ORFactory float:model value:0.05f];
         
         
         id<ORFloatVarArray> k1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> k2 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> k3 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> k4 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> yn = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         
         id<ORFloatVarArray> TMP_7 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_8 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_13 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_14 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_18 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_28 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_38 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> TMP_40 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         id<ORFloatVarArray> yn_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS)];
         
         [model add:[yn[0] eq:y_init]];
         [model add:[yn_opt[0] eq:y_init]];
         
         for (ORUInt n = 0; n < NBLOOPS; n++) {
            
            [model add:[k1[n] eq: [[k mul: [c sub: yn[n]]] mul: [c sub: yn[n]]]]];
            
            [model add:[k2[n] eq: [[k mul: [c sub: [yn[n] plus: [[expr_2 mul: h] mul: k1[n]]]]] mul: [c sub: [yn[n] plus: [[expr_2 mul: h] mul: k1[n]]]]]]];
            
            [model add:[k3[n] eq: [[k mul: [c sub: [yn[n] plus: [[expr_2 mul: h] mul: k2[n]]]]] mul: [c sub: [yn[n] plus: [[expr_2 mul: h] mul: k2[n]]]]]]];
            
            [model add:[k4[n] eq: [[k mul: [c sub: [yn[n] plus: [h mul: k3[n]]]]] mul: [c sub: [yn[n] plus: [h mul: k3[n]]]]]]];
            
            [model add:[yn[n+1] eq: [yn[n+1] plus: [[[expr_3 div: expr_0] mul: h] mul: [[[k1[n] plus: [expr_1 mul: k2[n]]] plus: [expr_1 mul: k3[n]]] plus: k4[n]]]]]];
            
            
            [model add:[TMP_7[n] eq: [k mul: [e2_0 sub: yn_opt[n]]]]];
            [model add:[TMP_8[n] eq: [e2_0 sub: yn_opt[n]]]];
            [model add:[TMP_13[n] eq: [k mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [[k mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [TMP_7[n] mul: TMP_8[n]]]]]] mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [[k mul: TMP_8[n]] mul: [e2_0 sub: yn_opt[n]]]]]]]]]]]]];
            [model add:[TMP_14[n] eq: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [[k mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [TMP_7[n] mul: TMP_8[n]]]]]] mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [[k mul: TMP_8[n]] mul: [e2_0 sub: yn_opt[n]]]]]]]]]]]];
            [model add:[TMP_18[n] eq: [yn_opt[n] plus: [e_0 mul: [[k mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [TMP_7[n] mul: TMP_8[n]]]]]] mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [[k mul: TMP_8[n]] mul: [e2_0 sub: yn_opt[n]]]]]]]]]]];
            [model add:[TMP_28[n] eq: [[k mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [TMP_7[n] mul: TMP_8[n]]]]]] mul: [e2_0 sub: [yn_opt[n] plus: [e_0 mul: [[k mul: TMP_8[n]] mul: [e2_0 sub: yn_opt[n]]]]]]]]];
            [model add:[TMP_38[n] eq: [[[TMP_14[n] mul: TMP_13[n]] mul: h] plus: yn_opt[n]]]];
            [model add:[TMP_40[n] eq: [h mul: [[k mul: TMP_14[n]] mul: [e2_0 sub: TMP_18[n]]]]]];
            [model add:[yn_opt[n+1] eq: [yn_opt[n] plus: [e4_0 mul: [[[[TMP_7[n] mul: TMP_8[n]] plus: [expr_1 mul: TMP_28[n]]] plus: [expr_1 mul: [TMP_13[n] mul: TMP_14[n]]]] plus: [[k mul: [e2_0 sub: TMP_38[n]]] mul: [e2_0 sub: [yn_opt[n] plus: TMP_40[n]]]]]]]]];
         

         }
         
         //         model.add(diff = *(m[NBLOOPS]) - *(m_opt[NBLOOPS]));
         //         model.add(diff*diff > 0.0622f);
         
         [model add:[diff eq:[yn[NBLOOPS] sub:yn_opt[NBLOOPS]]]];
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
