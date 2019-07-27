#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> a = [ORFactory floatVar:model low:-1000.0f up:1000.0f name:@"a"];
         id<ORFloatVar> b = [ORFactory floatVar:model low:-1000.0f up:1000.0f name:@"b"];
         id<ORFloatVar> c = [ORFactory floatVar:model low:-1000.0f up:1000.0f name:@"c"];
         
         id<ORFloatVar> assoc1 = [ORFactory floatVar:model name:@"assoc1"];
         id<ORFloatVar> assoc2 = [ORFactory floatVar:model name:@"asooc2"];
         id<ORFloatVar> diffab = [ORFactory floatVar:model name:@"diffab"];
         id<ORFloatVar> diffac = [ORFactory floatVar:model name:@"diffac"];
         id<ORFloatVar> diffbc = [ORFactory floatVar:model name:@"diffbc"];
         
         
         //         id<ORFloatVar> delta = [ORFactory floatVar:model low:0.3f up:0.3f];
         id<ORExpr> epsilon =  [ORFactory float:model value:3000.f];
         id<ORExpr> delta =  [ORFactory float:model value:0.3f];
         
         
         id<ORExpr> infinity = [ORFactory infinityf:model];
         id<ORExpr> sub_infinity = [ORFactory float:model value:-INFINITY];
       NSMutableArray* toadd = [[NSMutableArray alloc] init];
         
         [toadd addObject:[delta gt:@(0.0f)]];
         [toadd addObject:[epsilon gt:@(0.0f)]];
         
         [toadd addObject:[a geq:b]];
         [toadd addObject:[b geq:c]];
         
         
         [toadd addObject:[diffab leq:delta]];
         [toadd addObject:[diffac leq:delta]];
         [toadd addObject:[diffbc leq:delta]];
         
         [toadd addObject:[diffab eq:[a sub:b]]];
         [toadd addObject:[diffac eq:[a sub:c]]];
         [toadd addObject:[diffbc eq:[b sub:c]]];
         [toadd addObject:[assoc1 eq:[[a mul:b] mul:c]]];
         [toadd addObject:[assoc2 eq:[a mul:[b mul:c]]]];
         
         [toadd addObject:[assoc1 neq:infinity]];
         [toadd addObject:[assoc1 neq:sub_infinity]];
         //
         [toadd addObject:[assoc2 neq:infinity]];
         [toadd addObject:[assoc2 neq:sub_infinity]];
         
         
         [toadd addObject:[[assoc1 sub:assoc2] gt:epsilon]];
         
         
         
         id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
         id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
         __block bool found = false;
         fesetround(FE_TONEAREST);
         
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
            }
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}

