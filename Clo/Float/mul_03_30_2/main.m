#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVar> a = [ORFactory floatVar:model low:-20.0 up:20.0 name:@"a"];
         id<ORFloatVar> b = [ORFactory floatVar:model low:-10.0 up:10.0 name:@"b"];
         id<ORFloatVar> c = [ORFactory floatVar:model low:-10.0 up:10.0 name:@"c"];
         
         id<ORFloatVar> assoc1 = [ORFactory floatVar:model name:@"assoc1"];
         id<ORFloatVar> assoc2 = [ORFactory floatVar:model name:@"asooc2"];
         id<ORFloatVar> diffab = [ORFactory floatVar:model name:@"diffab"];
         id<ORFloatVar> diffac = [ORFactory floatVar:model name:@"diffac"];
         id<ORFloatVar> diffbc = [ORFactory floatVar:model name:@"diffbc"];
         
         
         //         id<ORFloatVar> delta = [ORFactory floatVar:model low:0.3f up:0.3f];
         id<ORExpr> epsilon =  [ORFactory float:model value:30.f];
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
         
         [toadd addObject:[diffab set:[a sub:b]]];
         [toadd addObject:[diffac set:[a sub:c]]];
         [toadd addObject:[diffbc set:[b sub:c]]];
         [toadd addObject:[assoc1 set:[[a mul:b] mul:c]]];
         [toadd addObject:[assoc2 set:[a mul:[b mul:c]]]];
         
         [toadd addObject:[assoc1 neq:infinity]];
         [toadd addObject:[assoc1 neq:sub_infinity]];
         //
         [toadd addObject:[assoc2 neq:infinity]];
         [toadd addObject:[assoc2 neq:sub_infinity]];
         
         
         [toadd addObject:[[assoc1 sub:assoc2] gt:epsilon]];
         
         
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[a,b,c]];
      
   }
   return 0;
}

