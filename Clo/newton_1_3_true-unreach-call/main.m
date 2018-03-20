#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#define NR 3

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

float f(float x)
{
   return x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
}

float fp(float x)
{
   return 1 - (x*x)/2.0f + (x*x*x*x)/24.0f + (x*x*x*x*x*x)/720.0f;
}

void check_solution(float IN, float res){
   if(IN < -VAL || IN > VAL) printf("ERREUR : pas le bon range\n");
   float result = IN - f(IN)/fp(IN);
   if(res != result) printf("ERREUR %16.16e != %16.16e\n",res,result);
   else if (res < 0.1f) printf("ERREUR %16.16e < 0.1",res);
   else printf("result is ok\n");
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:-VAL up:VAL];
         id<ORFloatVar> r_0 = [ORFactory floatVar:model];
         id<ORFloatVar> f_x = [ORFactory floatVar:model];
         id<ORFloatVar> fp_x = [ORFactory floatVar:model];
         
         
         id<ORExpr> fc = [ORFactory float:model value:1.0f];
         id<ORGroup> g = [args makeGroup:model];
         
         [g add:[f_x eq:[[[x sub:[[[x mul:x] mul:x] div:@(6.0f)]] plus:[[[[[x mul:x] mul:x] mul:x] mul:x] div:@(120.0f)]]
                         plus:[[[[[[[x mul:x] mul:x] mul:x] mul:x] mul:x] mul:x] div:@(5040.0f)]]]];
         
         
         [g add:[fp_x eq:[[[fc sub:[[x mul:x] div:@(2.0f)]] plus:[[[[x mul:x] mul:x] mul:x] div:@(24.0f)]]
                          plus:[[[[[[x mul:x] mul:x] mul:x] mul:x] mul:x] div:@(720.0f)]]]];
         
         [g add:[r_0 eq:[x sub:[f_x div:fp_x]]]];
         
         
         [g add:[r_0 geq:@(0.1f)]];
         [model add:g];
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         
         //           NSLog(@"%@", model);
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            found = true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
            }
            check_solution([p floatValue:vars[0]], [p floatValue:vars[1]]);
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}


