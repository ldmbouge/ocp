#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
//
//DECL
//
//float [-1, 1] x;
//EXPR
//--Expect result: UNSAT
//x * x + x < -0.25-1.0e-3;


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:-1.0f up:1.0f];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         
         
         
         id<ORExpr> fc = [ORFactory float:model value:-0.25f];
         id<ORExpr> fc2 = [ORFactory float:model value:1.0e-3];
       NSMutableArray* toadd = [[NSMutableArray alloc] init];
         
         
         [toadd addObject:[res eq:[[x mul:x] plus:x]]];
         
         [toadd addObject:[res lt:[fc sub:fc2]]];
         
         
         //            [model add:[res lt:fc]];
         
         id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
         
         [ORCmdLineArgs defaultRunner:args model:model program:cp];
         
   }
   return 0;
}

