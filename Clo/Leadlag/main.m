#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
/*
 y = [2.1,17.9]; xc0 = 0.0; xc1 = 0.0; yd = 5.0; Ac11 = 1.0; Bc0 = 1.0; Bc1 = 0.0; Cc0 = 564.48; Ac00 = 0.499; Ac01 =  0.05; Ac10 = 0.01;
 Cc1 = 0.0; Dc =  1280.0; t = 0.0;
 while(t < 5.0) do {
 yc = (y  - yd);
 if(yc <  1.0) { yc =  1.0; }
 if(1.0 < yc) { yc = 1.0; }
 xc0 = (Ac00 * xc0) + (Ac01 * xc1) + (Bc0 * yc);
 xc1 = (Ac10 * xc0) + (Ac11 * xc1) + (Bc1 * yc);
 u = (Cc0 * xc0) + (Cc1 * xc1) + (Dc * yc);
 t=(t+0.1); }
 
 y = [2.1,17.9]; t = 0.0; xc1 = 0.0; xc0 = 0.0;
 while(t < 5.0) do {
 yc = ( 5.0+y);
 if(yc <  1.0) { yc =  1.0; } if(1.0 < yc) { yc = 1.0; }
 u = (((Cc0 * xc0)+(0.0 * xc1))+( Dc * yc )); xc0 = ((( 0.05 * xc1)+(1.0 * yc))+(Ac00 * xc0)); xc1 = (((0.01 * xc0)+(0.0 * yc))+(1.0 * xc1));
 t=(t+0.1);
 }
 */
#define NBLOOPS 1

void checksolution()
{
   float xc0 = 0.0f; float xc1 = 0.0f; float Ac11 = 1.0f; float Bc0 = 1.0f; float Bc1 = 0.0f; float Cc0 = 564.48f;float Ac00 = 0.499f; float Ac01 = -0.05f;
   float Ac10 = 0.01f; float Cc1 = 0.0f; float Dc = -1280.0f; float yc;
   float u = 0.0f; float yd = 5.0f;
   float xc1_opt = 0.0f;float xc0_opt = 0.0f; float u_opt = 0.0f;

   for(float y = 2.1f; y <= 17.9f; y=nextafterf(y,+INFINITY)){
      yc = (y - yd);
      if(1.0f < yc) break;
      yc = -1.0f;
   xc0 = (Ac00 * xc0) + (Ac01 * xc1) + (Bc0 * yc);
   xc1 = (Ac10 * xc0) + (Ac11 * xc1) + (Bc1 * yc);
   u = (Cc0 * xc0) + (Cc1 * xc1) + (Dc * yc);
   
   u_opt = (((Cc0 * xc0_opt)+(0.0 * xc1_opt))+( Dc * yc ));
   xc0_opt = ((( 0.05 * xc1_opt)+(1.0 * yc))+(Ac00 * xc0_opt));
   xc1_opt = (((0.01 * xc0_opt)+(0.0 * yc))+(1.0 * xc1_opt));
   }
   printf("%16.16e\n",xc0-xc0_opt);
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORGroup> g = [args makeGroup:model];
         
         fesetround(FE_TONEAREST);
         id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
         id<ORFloatVar> y = [ORFactory floatVar:model low:2.1f up:17.9f name:@"y"];
         id<ORFloatVar> yc = [ORFactory floatVar:model name:@"yc"];
         
         //Cc1 = 0.0; Dc = -1280.0;Cc0 = 564.48;Ac00 = 0.499; Ac01 = -0.05; Ac10 = 0.01;
         id<ORExpr> Cc1 = [ORFactory float:model value:0.0f];
         id<ORExpr> Dc = [ORFactory float:model value:-1280.f];
         id<ORExpr> Cc0 = [ORFactory float:model value:564.48f];
         id<ORExpr> Ac00 = [ORFactory float:model value:0.499f];
         id<ORExpr> Ac01 = [ORFactory float:model value:-0.05f];
         id<ORExpr> Ac10 = [ORFactory float:model value:0.01f];
         id<ORExpr> Ac11 = [ORFactory float:model value:1.0f];
         id<ORExpr> Bc0 = [ORFactory float:model value:1.0f];
         id<ORExpr> Bc1 = [ORFactory float:model value:0.0f];
         id<ORExpr> yd = [ORFactory float:model value:5.0f];
         
         
         //xc0, xc1 ,xc0_opt, xc1_opt, yc, y, u
         id<ORFloatVarArray> xc0 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xc0"];
         id<ORFloatVarArray> xc1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xc1"];
         id<ORFloatVarArray> u = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"u"];
         
         id<ORFloatVarArray> xc0_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xc0_opt"];
         id<ORFloatVarArray> xc1_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xc1_opt"];
         id<ORFloatVarArray> u_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"u_opt"];
         
         [model add:[yc eq:@(1.0f)]];
         [model add:[[y sub:yd] gt:@(1.0f)]];
         
         [model add:[xc0[0] eq:@(0.0f)]];
         [model add:[xc1[0] eq:@(0.0f)]];
         [model add:[xc0_opt[0] eq:@(0.0f)]];
         [model add:[xc1_opt[0] eq:@(0.0f)]];
         
         
         for (ORUInt n = 0; n < NBLOOPS; n++) {
            
            [model add:[xc0[n+1] eq:[[[Ac00 mul: xc0[n]] plus: [Ac01 mul: xc1[n]]] plus:[Bc0 mul: yc]]]];
            [model add:[xc1[n+1] eq:[[[Ac10 mul: xc0[n]] plus: [Ac11 mul: xc1[n]]] plus:[Bc1 mul: yc]]]];
            [model add:[u[n] eq:[[[Cc0 mul: xc0[n]] plus: [Cc1 mul: xc1[n]]] plus:[Dc mul: yc]]]];
            
            [model add:[u_opt[n] eq:[[[Cc0 mul:xc0_opt[n]] plus:[Cc1 mul:xc1_opt[n]]] plus: [Dc mul: yc]]]];
            [model add:[xc0_opt[n+1] eq:[[[Ac01 mul:xc1_opt[n]] plus:[Ac11 mul:yc]] plus: [Ac00 mul: xc0_opt[n]]]]];
            [model add:[xc1_opt[n+1] eq:[[[Ac10 mul:xc0_opt[n]] plus:[Cc1 mul:yc]] plus: [Ac11 mul: xc1_opt[n]]]]];
            
         }
         
         [g add:[diff eq:[xc0_opt[NBLOOPS] sub:xc0[NBLOOPS]]]];
         [g add:[[diff mul:diff] gt:@(0.0f)]];
         [model add:g];
         
         NSLog(@"%@", model);
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         
         checksolution();
         fesetround(FE_TONEAREST);
         [cp solveOn:^(id<CPCommonProgram> p) {
            checksolution();
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               id<CPFloatVar> cv = [cp concretize:v];
               found &= [p bound: v];
               NSLog(@"%@ = %16.16e (%s)",v,[cv value], [p bound:v] ? "YES" : "NO");
            }
            NSLog(@"diff : %16.16f", [p floatValue:xc0_opt[1]] - [p floatValue:xc0[1]] );
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}
