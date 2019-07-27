#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x0 = [ORFactory floatVar:model];
         id<ORFloatVar> h = [ORFactory floatVar:model low:1e-6f up:1e-3f];
         id<ORFloatVar> x1 = [ORFactory floatVar:model];
         id<ORFloatVar> x2 = [ORFactory floatVar:model];
         id<ORFloatVar> fx1 = [ORFactory floatVar:model];
         id<ORFloatVar> fx2 = [ORFactory floatVar:model];
         id<ORFloatVar> res = [ORFactory floatVar:model];
         id<ORGroup> g =[args makeGroup:model];
         //x0 = 13
         [toadd addObject:[x0 eq:@(13.0f)]];
         //x1 = x0 + h
         [toadd addObject:[x1 eq:[x0 plus:h]]];
         //x2 = x0 - h
         [toadd addObject:[x2 eq:[x0 sub:h]]];
         //fx1 = x1*x1
         [toadd addObject:[fx1 eq:[x1 mul:x1]]];
         
         //fx2 = x2*x2
         [toadd addObject:[fx2 eq:[x2 mul:x2]]];
         
         //res = (fx1 - fx2) / (2.0*h)
         [toadd addObject:[ res eq:[[fx1 sub:fx2] div:[h mul:@(2.0f)]]]];
         
         //res > 26.0f + 10.0f
         float v = 26.0f;
         id<ORExpr> fc = [ORFactory float:model value:v];
         [toadd addObject:[res gt:[fc sub:@(10.0f)]]];
         
         id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
         
         [ORCmdLineArgs defaultRunner:args model:model program:cp];
   }
   return 0;
}

