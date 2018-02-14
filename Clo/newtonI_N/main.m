#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#define NR 1

#if NR == 1
#define VAL 0.2f
#elif NR == 2
#define VAL 0.4f
#elif NR == 3
#define VAL 0.6f
#elif NR == 4
#define VAL 0.8f
#elif NR == 5
#define VAL 1.0f
#elif NR == 6
#define VAL 1.2f
#elif NR == 7
#define VAL 1.4f
#elif NR == 8
#define VAL 2.0f
#endif
/*
 float f(float x)
 {
 return x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
 }
 
 float fp(float x)
 {
 return 1 - (x*x)/2.0f + (x*x*x*x)/24.0f + (x*x*x*x*x*x)/720.0f;
 }
 
 
 __VERIFIER_assume(IN > -0.2f && IN < 0.2f);
 
 float x = IN - f(IN)/fp(IN);
 */

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         ORInt n = 13;
         id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, n)];
         id<ORFloatVarArray> f_x = [ORFactory floatVarArray:model range:RANGE(model, 0, n)];
         id<ORFloatVarArray> fp_x = [ORFactory floatVarArray:model range:RANGE(model, 0, n)];
         
         id<ORExpr> fc = [ORFactory float:model value:1.0f];
         
         [model add:[x[0] leq:@(VAL)]];
         [model add:[x[0] geq:@(-VAL)]];
         
         for(ORInt i = 0; i < n; i++){
         [model add:[f_x[i] eq:[[[x[i] sub:[[[x[i] mul:x[i]] mul:x[i]] div:@(6.0f)]] plus:[[[[[x[i] mul:x[i]] mul:x[i]] mul:x[i]] mul:x[i]] div:@(120.0f)]]
                             plus:[[[[[[[x[i] mul:x[i]] mul:x[i]] mul:x[i]] mul:x[i]] mul:x[i]] mul:x[i]] div:@(5040.0f)]]]];
         [model add:[fp_x[i] eq:[[[fc sub:[[x[i] mul:x[i]] div:@(2.0f)]] plus:[[[[x[i] mul:x[i]] mul:x[i]] mul:x[i]] div:@(24.0f)]]
                              plus:[[[[[[x[i] mul:x[i]] mul:x[i]] mul:x[i]] mul:x[i]] mul:x[i]] div:@(720.0f)]]]];
         
         [model add:[x[i+1] eq:[x[i] sub:[f_x[i] div:fp_x[i]]]]];
         }
         
         
         [model add:[x[n] geq:@(0.1f)]];
         
         
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
//         NSLog(@"%@", model);
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
            }
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}
