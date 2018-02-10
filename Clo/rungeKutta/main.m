#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
/*
 yn = [ 10.1,10.1]; t = 0.0; k = 1.2; c = 100.1;
 h=0.1;
 while(t < 1.0) do {
 k1 = (k * ( c − yn )) * ( c − yn ) ;
 k2 = (k * ( c − (yn + ((0.5 * h) * k1)))) * (c − (yn + ((0. 5 * h) * k1)));
 k3 = (k * (c − (yn + ((0.5 * h) * k2)))) * (c − (yn + ((0.5 * h ) * k2)));
 k4 = (k * (c − (yn + (h * k3)))) * (c − (yn + (h * k3)));
 yn+1 = yn + ((1/6 * h) * (((k1 + (2.0 * k2)) + (2.0 * k3)) + k4));
 }

 while ( t < 1.0) do {
 TMP_7 = (1.2 * (100.099 − yn)) ;
 TMP_8 = (100.099 − yn) ;
 TMP_13 = (1.2 * (100.099 − (yn + (0.05 * ((1.2 * (100.099 − (yn + (0.05 * (TMP_7 * TMP_8))))) * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn))))))))));
 TMP_14 = (100.099 − (yn + (0.05 * ((1.2 * (100.099 − (yn + (0.05 * (TMP_7 * TMP_8))))) * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn));
 TMP_18 = (yn + (0.05 * ((1.2 * (100.099 − ( yn + (0.05 * (TMP_7 * TMP_8))))) * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn)))))))) ;
 TMP_28 = ((1.2 * (100.099 − ( yn + (0.05 * (TMP_7 * TMP_8))))) * (100. 099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn))))));
 TMP_38 = ((TMP_14 * TMP_13) * 0.1) + yn;
 TMP_40 = 0.1 * ((1.2 * TMP_14) * (100.099 − TMP_18));
 yn+1 = (yn + (0.016666667 * ((((TMP_7 * TMP_8) + (2.0 * TMP_28)) + (2.0 * (TMP_13 * TMP_14))) + ((1.2 * (100.099 − TMP_38)) * (100.099 − ( yn + TMP_40))))));
 }
 */
#define NBLOOPS 2

void checksolution()//float yi, float yi_opt, float yl, float yl_opt, float diff)
{
   float k = 1.2f;
   float c = 100.1f;
   float h = 0.1f;
   float k1 = 0.0f;
   float k2 = 0.0f;
   float k3 = 0.0f;
   float k4 = 0.0f;
   float ynext = 0.0f;
   float ynext_opt = 0.0f;
   float TMP_7, TMP_8, TMP_13,TMP_14, TMP_18, TMP_28, TMP_38, TMP_40;
   int nb=0;
   for(float y0 = -10.1f; y0 <= 10.1f; y0=nextafterf(y0, +INFINITY)){
      for(float y1 = -10.1f; y1 <= 10.1f; y1=nextafterf(y1, +INFINITY)){
//         printf ("%16.16e %16.16e\n", yi, yi_opt);
         float yi=y0; float  yi_opt = y1;
         nb++;
         for(int i = 0; i < NBLOOPS; i++){
            k1 = k * (c - yi) * (c - yi);
            k2 = k * (c -(yi + (0.5f * h * k1))) * (c - (yi + (0.5f * h * k1)));
            k3 = (k * (c - (yi + ((0.5f * h) * k2)))) * (c - (yi + ((0.5f * h) * k2)));
            k4 = (k * (c - (yi + (h * k3)))) * (c - (yi + (h * k3)));
            ynext = yi + ((1/6.f * h) * (((k1 + (2.0f * k2)) + (2.0f * k3)) + k4));
            yi = ynext;
   
            TMP_7 = (k * (100.099f - yi_opt)) ;
            TMP_8 = (100.099f - yi_opt) ;
            TMP_13 = (k * (100.099f - (yi_opt + (0.05f * ((k * (100.099f - (yi_opt + (0.05f * (TMP_7 * TMP_8))))) * (100.099f - (yi_opt + (0.05f * ((k * TMP_8) * (100.099f - yi_opt))))))))));
            TMP_14 = (100.099f - (yi_opt + (0.05f * ((k * (100.099f - (yi_opt + (0.05f * (TMP_7 * TMP_8))))) * (100.099f - (yi_opt + (0.05f * ((k * TMP_8) * (100.099f - yi_opt)))))))));
            TMP_18 = (yi_opt + (0.05f * ((k * (100.099f - (yi_opt + (0.05f * (TMP_7 * TMP_8))))) * (100.099f - (yi_opt + (0.05f * ((k * TMP_8) * (100.099f - yi_opt)))))))) ;
            TMP_28 = ((k * (100.099f - (yi_opt + (0.05f * (TMP_7 * TMP_8))))) * (100.099f - (yi_opt + (0.05f * ((k * TMP_8) * (100.099f - yi_opt))))));
            TMP_38 = ((TMP_14 * TMP_13) * 0.1f) + yi_opt;
            TMP_40 = 0.1f * ((k * TMP_14) * (100.099f - TMP_18));
            ynext_opt = (yi_opt + (0.016666667f * ((((TMP_7 * TMP_8) + (2.0f * TMP_28)) + (2.0f * (TMP_13 * TMP_14))) + ((k * (100.099f - TMP_38)) * (100.099f - (yi_opt + TMP_40))))));
      
            yi_opt = ynext_opt;
            }
         if(ynext != ynext_opt) {
            printf ("YES\n");
            printf ("yn : %16.16e yn_opt : %16.16e diff: %16.16e\n",ynext,ynext_opt,ynext - ynext_opt );
            printf ("yi : %16.16e yi_opt : %16.16e\n",y0,y1);
            break;
         }
      }
   }
   printf("%d",nb);
//   if(ynext != yl)
//      printf ("y n'est pas correct\n");
//   if(ynext_opt != yl_opt)
//      printf ("y_opt n'est pas correct\n");
//   if(ynext - ynext_opt == 0.0f)
//      printf ("Différence égale à 0\n");
//   if(ynext - ynext_opt != diff)
//      printf ("L'Erreur n'est pas correct %16.16e != %16.16e\n", ynext - ynext_opt, diff);
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORGroup> g = [args makeGroup:model];
         
         fesetround(FE_TONEAREST);
         id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
         
         id<ORExpr> c = [ORFactory float:model value:100.1f];
         id<ORExpr> c0 = [ORFactory float:model value:100.099f];
         id<ORExpr> c1 = [ORFactory float:model value:0.5f];
         id<ORExpr> c2 = [ORFactory float:model value:0.05f];
         id<ORExpr> k = [ORFactory float:model value:1.2f];
         id<ORExpr> h = [ORFactory float:model value:0.1f];
         id<ORExpr> d = [ORFactory float:model value:(1/6.f)];
         id<ORExpr> m = [ORFactory float:model value:2.0f];
         id<ORExpr> q = [ORFactory float:model value:0.016666667f];
         
         
         
         
         //xc0, xc1 ,xc0_opt, xc1_opt, yc, y, u
         id<ORFloatVarArray> k1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"k1"];
         id<ORFloatVarArray> k2 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"k2"];
         id<ORFloatVarArray> k3 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"k3"];
         id<ORFloatVarArray> k4 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"k4"];
         id<ORFloatVarArray> y = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"yn"];
         
         id<ORFloatVarArray> TMP_7 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_7"];
         id<ORFloatVarArray> TMP_8 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_8"];
         id<ORFloatVarArray> TMP_13 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_13"];
         id<ORFloatVarArray> TMP_14 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_14"];
         id<ORFloatVarArray> TMP_18 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_18"];
         id<ORFloatVarArray> TMP_28 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_28"];
         id<ORFloatVarArray> TMP_38 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_38"];
         id<ORFloatVarArray> TMP_40 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"TMP_40"];
         id<ORFloatVarArray> y_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"yn_opt"];
         
         [g add:[y[0] geq:@(-10.1f)]];
         [g add:[y[0] leq:@(10.1f)]];
         [g add:[y_opt[0] geq:@(-10.1f)]];
         [g add:[y_opt[0] leq:@(10.1f)]];
         
         
         
         for (ORUInt n = 0; n < NBLOOPS; n++) {
//            k1 = (k * ( c − yn )) * ( c − yn ) ;
//            k2 = (k * ( c − (yn + ((0.5 * h) * k1)))) * (c − (yn + ((0. 5 * h) * k1)));
//            k3 = (k * (c − (yn + ((0.5 * h) * k2)))) * (c − (yn + ((0.5 * h ) * k2)));
//            k4 = (k * (c − (yn + (h * k3)))) * (c − (yn + (h * k3)));
//            yn+1 = yn + ((1/6 * h) * (((k1 + (2.0 * k2)) + (2.0 * k3)) + k4));
            [g add:[k1[n] eq:[[k mul:[c sub: y[n]]] mul: [c sub:y[n]]]]];
            [g add:[k2[n] eq:[[k mul:[c sub:[y[n] plus:[[c1 mul:h] mul:k1[n]]]]] mul: [c sub:[y[n] plus:[[c1 mul:h] mul:k1[n]]]]]]];
            [g add:[k3[n] eq:[[k mul:[c sub:[y[n] plus:[[c1 mul:h] mul:k2[n]]]]] mul: [c sub:[y[n] plus:[[c1 mul:h] mul:k2[n]]]]]]];
            [g add:[k4[n] eq:[[k mul:[c sub:[y[n] plus:[h mul:k3[n]]]]] mul:[c sub:[y[n] plus:[h mul:k3[n]]]]]]];
            [g add:[y[n+1] eq:[y[n] plus:[[d mul:h] mul:[[[k1[n] plus:[m mul:k2[n]]] plus:[m mul:k3[n]]] plus:k4[n]]]]]];
            
//               TMP_7 = (1.2 * (100.099 − yn)) ;
//               TMP_8 = (100.099 − yn) ;
//               TMP_13 = (1.2 * (100.099 − (yn + (0.05 * ((1.2 * (100.099 − (yn + (0.05 * (TMP_7 * TMP_8))))) * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn))))))))));
//               TMP_14 = (100.099 − (yn + (0.05 * ((1.2 * (100.099 − (yn + (0.05 * (TMP_7 * TMP_8))))) * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn));
//               TMP_18 = (yn + (0.05 * ((1.2 * (100.099 − ( yn + (0.05 * (TMP_7 * TMP_8))))) * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn)))))))) ;
//               TMP_28 = ((1.2 * (100.099 − ( yn + (0.05 * (TMP_7 * TMP_8))))) * (100. 099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn))))));
//               TMP_38 = ((TMP_14 * TMP_13) * 0.1) + yn;
//               TMP_40 = 0.1 * ((1.2 * TMP_14) * (100.099 − TMP_18));
//                yn+1 = (yn + (0.016666667 * ((((TMP_7 * TMP_8) + (2.0 * TMP_28)) + (2.0 * (TMP_13 * TMP_14))) + ((1.2 * (100.099 − TMP_38)) * (100.099 − ( yn + TMP_40))))));
            
            
            [g add:[TMP_7[n] eq:[k mul: [c0 sub: y_opt[n]]]]];
            [g add:[TMP_8[n] eq:[c0 sub: y_opt[n]]]];
            [g add:[TMP_13[n] eq:[k mul:[c0 sub:[y_opt[n] plus:[c2 mul:[[k mul:[c0 sub:[y_opt[n] plus:[c2 mul:[TMP_7[n] mul:TMP_8[n]]]]]] mul:[c0 sub:[y_opt[n] plus:[c2 mul:[[k mul:TMP_8[n]] mul:[c0 sub:y_opt[n]]]]]]]]]]]]];

            [g add:[TMP_14[n] eq:[c0 sub: [y_opt[n] plus: [c2 mul: [[k mul: [c0 sub: [y_opt[n] plus: [c2 mul: [TMP_7[n] mul: TMP_8[n]]]]]] mul: [c0 sub: [y_opt[n] plus: [c2 mul: [[k mul: TMP_8[n]] mul: [c0 sub: y_opt[n]]]]]]]]]]]];
            [g add:[TMP_18[n] eq:[y_opt[n] plus: [c2 mul: [[k mul: [c0 sub: [ y_opt[n] plus: [c2 mul: [TMP_7[n] mul: TMP_8[n]]]]]] mul: [c0 sub: [y_opt[n] plus:[c2 mul: [[k mul: TMP_8[n]] mul: [c0 sub: y_opt[n]]]]]]]]]]];
            [g add:[TMP_28[n] eq:[[k mul: [c0 sub: [y_opt[n] plus: [c2 mul: [TMP_7[n] mul: TMP_8[n]]]]]] mul: [c0 sub: [y_opt[n] plus: [c2 mul: [[k mul: TMP_8[n]] mul: [c0 sub: y_opt[n]]]]]]]]];
            [g add:[TMP_38[n] eq:[[[TMP_14[n] mul: TMP_13[n]] mul:h] plus: y_opt[n]]]];
            [g add:[TMP_40[n] eq:[h mul: [[k mul: TMP_14[n]] mul: [c0 sub: TMP_18[n]]]]]];
            [g add:[y_opt[n+1] eq: [y_opt[n] plus: [q mul: [[[[TMP_7[n] mul: TMP_8[n]] plus: [m mul: TMP_28[n]]] plus: [m mul: [TMP_13[n] mul: TMP_14[n]]]] plus: [[k mul: [c0 sub: TMP_38[n]]] mul: [c0 sub: [y_opt[n] plus: TMP_40[n]]]]]]]]];

         }
         
         [g add:[diff eq:[y[NBLOOPS] sub:y_opt[NBLOOPS]]]];
         [g add:[[diff mul:diff] gt:@(0.0f)]];
         [model add:g];
         
//         NSLog(@"%@", model);
//         NSLog(@"---");
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         checksolution();
         fesetround(FE_TONEAREST);
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               id<CPFloatVar> cv = [cp concretize:v];
               found &= [p bound: v];
               NSLog(@"%@ = %16.16e (%s)",v,[cv value], [p bound:v] ? "YES" : "NO");
            }
//            checksolution([p floatValue:y[0]], [p floatValue:y_opt[0]], [p floatValue:y[NBLOOPS]],[p floatValue:y_opt[NBLOOPS]], [p floatValue:diff]);
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}

