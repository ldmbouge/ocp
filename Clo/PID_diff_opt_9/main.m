#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 From: Nasrine Damouche, Matthieu Martel, Alexandre Chapoutot. Intra-procedural Optimization of the Numerical Accuracy of Programs. Formal Methods for Industrial Critical Systems, 9128, Springer Verlag, 2015, Lecture Notes in Computer Science, 978-3-319-19457-8. (page 14, fig 9)
 
 
 m = [4.5,9.0]; ki = 0.69006; kp = 9.4514; kd = 2.8454; t = 0.0; i = 0.0; c = 5.0; dt = 0.2; invdt = 5.0; e_old = 0.0;
 while (t < 20.0) do {
 e = c - m;
 p = kp * e ;
 i= i + ((ki * dt) * e);
 d = ((kd * invdt) * (e - e_old)) ;
 r = ((p + i) + d) ;
 m = m + (0.01 * r) ;
 e_old = e ;
 t = t + dt;
 }
 
 m = [4.5,9.0]; t = 0.0; e_old = 0.0; i = 0.0;
 while (t < 20.0) do {
 i = (i  + (0.138012 * (5.0 - m))) ;
 e_old = (5.0 - m) ;
 m = (m + (0.01 * ((((5.0 - m) * 9.4514) + i) + (((5.0 - m) - e_old) * 14.227)))) ;
 t = t + 0.2;
 }
 
 */

#define NBLOOPS 9


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORGroup> g = [args makeGroup:model];
         id<ORFloatVar> diff = [ORFactory floatVar:model];
         /* Input */
         id<ORFloatVar> m_init = [ORFactory floatVar:model low:4.5f up:9.0f];
         /* Constant */
         id<ORExpr> ki = [ORFactory float:model value:0.69006f];
         id<ORExpr> kp = [ORFactory float:model value:9.4514f];
         id<ORExpr> kd = [ORFactory float:model value:2.8454f];
         id<ORExpr> c = [ORFactory float:model value:5.0f];
         id<ORExpr> dt = [ORFactory float:model value:0.2f];
         id<ORExpr> invdt = [ORFactory float:model value:5.0f];
         
         id<ORExpr> expr = [ORFactory float:model value:0.01f];
         id<ORExpr> expr_1 = [ORFactory float:model value:0.138012f];
         
         id<ORFloatVarArray> e = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"e"];
         id<ORFloatVarArray> p = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"p"];
         id<ORFloatVarArray> i = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"i"];
         id<ORFloatVarArray> d = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"d"];
         id<ORFloatVarArray> r = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"r"];
         id<ORFloatVarArray> m = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"m"];
         id<ORFloatVarArray> e_old = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"e_old"];
         id<ORFloatVarArray> t = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"t"];
         id<ORFloatVarArray> m_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"m_opt"];
         id<ORFloatVarArray> t_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"t_opt"];
         id<ORFloatVarArray> e_old_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"e_old_opt"];
         id<ORFloatVarArray> i_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"i_opt"];
         
         //
         //         model.add(*(e[0]) = 0.0f);
         //         model.add(*(p[0]) = 0.0f);
         //         model.add(*(i[0]) = 0.0f);
         //         model.add(*(d[0]) = 0.0f);
         //         model.add(*(r[0]) = 0.0f);
         //         model.add(*(m[0]) = m_init);
         //         model.add(*(e_old[0]) = 0.0f);
         //         model.add(*(t[0]) = 0.0f);
         [g add:[e[0] eq:@(0.0f)]];
         [g add:[p[0] eq:@(0.0f)]];
         [g add:[i[0] eq:@(0.0f)]];
         [g add:[d[0] eq:@(0.0f)]];
         [g add:[r[0] eq:@(0.0f)]];
         [g add:[m[0] eq:m_init]];
         [g add:[e_old[0] eq:@(0.0f)]];
         [g add:[t[0] eq:@(0.0f)]];
         
         //         model.add(*(m_opt[0]) = m_init);
         //         model.add(*(t_opt[0]) = 0.0f);
         //         model.add(*(i_opt[0]) = 0.0f);
         //         model.add(*(e_old_opt[0]) = 0.0f);
         [g add:[m_opt[0] eq:m_init]];
         [g add:[t_opt[0] eq:@(0.0f)]];
         [g add:[i_opt[0] eq:@(0.0f)]];
         [g add:[e_old_opt[0] eq:@(0.0f)]];
         //
         
         //         model.add(e[n] = c - m[n-1]);
         //         model.add(p[n) = kp * e[n]);
         //         model.add(i[n] = i[n-1] + ((ki * dt) * e[n]));
         //         model.add(d[n] = ((kd * invdt) * (e[n] - e_old[n-1])));
         //         model.add(r[n] = ((p[n] + i[n]) + d[n]));
         //         model.add(m[n] = m[n-1] + (0.01f * r[n]));
         //         model.add(e_old[n] = *(e[n]));
         //         model.add(t[n] = *(t[n-1]) + dt);
         //
         //         model.add(i_opt[n] = (*(i_opt[n-1]) + (0.138012f * (5.0f - *(m_opt[n-1])))));
         //         model.add(e_old_opt[n] = (5.0f - *(m_opt[n-1])));
         //         model.add(m_opt[n] = (*(m_opt[n-1]) + (0.01f * ((((5.0f - *(m_opt[n-1])) * 9.4514f) + *(i_opt[n]))
         //                                                            + (((5.0f - *(m_opt[n-1])) - *(e_old_opt[n])) * 14.227f)))));
         //         model.add(t_opt[n] = t_opt[n-1] + 0.2f);
         
         
         for (ORUInt n = 1; n <= NBLOOPS; n++) {
            [g add:[e[n] eq:[c sub:m[n-1]]]];
            [g add:[p[n] eq:[kp mul:e[n]]]];
            [g add:[i[n] eq:[i[n-1] plus:[[ki mul:dt] mul:e[n]]]]];
            [g add:[d[n] eq:[[kd mul:invdt] mul:[e[n] sub:e_old[n-1]]]]];
            [g add:[r[n] eq:[[p[n] plus:i[n]] plus:d[n]]]];
            [g add:[m[n] eq:[m[n-1] plus:[expr mul:r[n]]]]];
            [g add:[e_old[n] eq:e[n]]];
            [g add:[t[n] eq:[t[n-1] plus:dt]]];
            
            [g add:[i_opt[n] eq:[i_opt[n-1] plus:[expr_1 mul:[c sub:m_opt[n-1]]]]]];
            [g add:[e_old_opt[n] eq:[c sub:m_opt[n-1]]]];
            [g add:[m_opt[n] eq:[m_opt[n-1] plus:[expr mul:[[[c sub:m_opt[n-1]] mul:kp] plus:i_opt[n]]]]]];
            
            [g add:[t_opt[n] eq:[t_opt[n-1] plus:dt]]];
         }
         
         //         model.add(diff = *(m[NBLOOPS]) - *(m_opt[NBLOOPS]));
         //         model.add(diff*diff > 0.0622f);
         
         [g add:[diff eq:[m[NBLOOPS] sub:m_opt[NBLOOPS]]]];
         [g add:[[diff mul:diff] gt:@(0.0622f)]];
         [model add:g];
         //         NSLog(@"%@", model);
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            found=true;
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


