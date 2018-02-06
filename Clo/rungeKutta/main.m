#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
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

void checksolution()
{
  
//   printf("%16.16e\n",xc0-xc0_opt);
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
        
         
         
         for (ORUInt n = 0; n < NBLOOPS; n++) {
//            k1 = k * (c - yn) * (c - yn);
//            k2 = k * (c -(yn + (0.5 * h * k1))) * (c - (yn + (0.5 * h * k1)));
//            yn+1 = yn + h * k2;
//            yn = yn+1;
            [model add:[k1[n] eq:[[k mul:[c sub: y[n]]] mul: [c sub:y[n]]]]];
            [model add:[k2[n] eq:[[k mul:[c sub:[y[n] plus:[[c1 mul:h] mul:k1[n]]]]] mul: [c sub:[y[n] plus:[[c1 mul:h] mul:k1[n]]]]]]];
            [model add:[y[n+1] eq:[[y[n] plus:h] mul:k2[n]]]];
            
//            yn+1 = (yn + (( 1.2 * (10.1 -  ((((1.2 * (10.1 -  yn)) * (10.1 - yn))
//                                             * 0.005) + yn))) * (10.1 -  ((((1.2 * (10.1 -  yn)) * (10.1 -  yn))
//                                                                           * 0.005) + yn))));
            [model add:[y[n+1] eq:[y[n] plus:[[k mul:[c3 sub:[[[[k mul:[c3 sub:y[n]]] mul:[c3 sub:y[n]]] mul:c4] plus:y[n]]]] mul:[c3 sub:[[[[k mul:[c3 sub:y[n]]] mul:[c3 sub:y[n]]] mul:c4] plus:y[n]]]]]]];
            
         }
         
         [g add:[diff eq:[y[NBLOOPS] sub:y_opt[NBLOOPS]]]];
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
            NSLog(@"diff : %16.16f", [p floatValue:y_opt[1]] - [p floatValue:y[1]] );
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}

