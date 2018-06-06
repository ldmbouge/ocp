#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#define NR 8

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
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:-VAL up:VAL];
         id<ORFloatVar> r_0 = [ORFactory floatVar:model];
         id<ORFloatVar> f_x = [ORFactory floatVar:model];
         id<ORFloatVar> fp_x = [ORFactory floatVar:model];
         
         id<ORFloatVar> x2 = [ORFactory floatVar:model];
         id<ORFloatVar> f_x2 = [ORFactory floatVar:model];
         id<ORFloatVar> fp_x2 = [ORFactory floatVar:model];
         
         
         
         id<ORExpr> fc = [ORFactory float:model value:1.0f];
         id<ORGroup> g = [args makeGroup:model];
         
         [g add:[f_x eq:[[[x sub:[[[x mul:x] mul:x] div:@(6.0f)]] plus:[[[[[x mul:x] mul:x] mul:x] mul:x] div:@(120.0f)]]
                         plus:[[[[[[[x mul:x] mul:x] mul:x] mul:x] mul:x] mul:x] div:@(5040.0f)]]]];
         
         
         [g add:[fp_x eq:[[[fc sub:[[x mul:x] div:@(2.0f)]] plus:[[[[x mul:x] mul:x] mul:x] div:@(24.0f)]]
                          plus:[[[[[[x mul:x] mul:x] mul:x] mul:x] mul:x] div:@(720.0f)]]]];
         
         [g add:[x2 eq:[x sub:[f_x div:fp_x]]]];
         
         [g add:[f_x2 eq:[[[x2 sub:[[[x2 mul:x2] mul:x2] div:@(6.0f)]] plus:[[[[[x2 mul:x2] mul:x2] mul:x2] mul:x2] div:@(120.0f)]]
                          plus:[[[[[[[x2 mul:x2] mul:x2] mul:x2] mul:x2] mul:x2] mul:x2] div:@(5040.0f)]]]];
         
         
         [g add:[fp_x2 eq:[[[fc sub:[[x2 mul:x2] div:@(2.0f)]] plus:[[[[x2 mul:x2] mul:x2] mul:x2] div:@(24.0f)]]
                           plus:[[[[[[x2 mul:x2] mul:x2] mul:x2] mul:x2] mul:x2] div:@(720.0f)]]]];
         
         [g add:[r_0 eq:[x2 sub:[f_x2 div:fp_x2]]]];
         
         [g add:[r_0 geq:@(0.1f)]];
         
         [model add:g];
         //         NSLog(@"%@",model);
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            NSLog(@"%@",[p concretize:g]);
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            found = true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
            }
            
            [args checkAbsorption:vars solver:cp];
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}



