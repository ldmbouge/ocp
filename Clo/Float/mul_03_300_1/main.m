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
         id<ORExpr> epsilon =  [ORFactory float:model value:300.f];
         id<ORExpr> delta =  [ORFactory float:model value:0.3f];
         
         
         id<ORExpr> infinity = [ORFactory infinityf:model];
         id<ORExpr> sub_infinity = [ORFactory float:model value:-INFINITY];
         id<ORGroup> g = [args makeGroup:model];
         
         [g add:[delta gt:@(0.0f)]];
         [g add:[epsilon gt:@(0.0f)]];
         
         [g add:[a geq:b]];
         [g add:[b geq:c]];
         
         
         [g add:[diffab leq:delta]];
         [g add:[diffac leq:delta]];
         [g add:[diffbc leq:delta]];
         
         [g add:[diffab eq:[a sub:b]]];
         [g add:[diffac eq:[a sub:c]]];
         [g add:[diffbc eq:[b sub:c]]];
         [g add:[assoc1 eq:[[a mul:b] mul:c]]];
         [g add:[assoc2 eq:[a mul:[b mul:c]]]];
         
         [g add:[assoc1 neq:infinity]];
         [g add:[assoc1 neq:sub_infinity]];
         //
         [g add:[assoc2 neq:infinity]];
         [g add:[assoc2 neq:sub_infinity]];
         
         
         [g add:[[assoc1 sub:assoc2] gt:epsilon]];
         
         [model add:g];
         
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
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

