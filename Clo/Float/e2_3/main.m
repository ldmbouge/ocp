#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

#define p1 1.0e+9f
#define p2 1.0e-8f
#define p3 1.0e-7f
//should be with double but error
int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
    
    id<ORModel> model = [ORFactory createModel];
    id<ORFloatVar> x = [ORFactory floatVar:model low:-1e20 up:1e20 name:@"x"];
    
    //         id<ORDoubleVar> y = [ORFactory doubleVar:model name:@"y"];
    id<ORFloatVar> p4 = [ORFactory floatVar:model low:-1.0 up:1.0 name:@"p4"];
    
    NSMutableArray* toadd = [[NSMutableArray alloc] init];
    
    
    [toadd addObject:[x leq:@(p1)]];
    [toadd addObject:[[x plus:p4] gt: @(p1)]];
    [toadd addObject:[p4 set:@(1.0e-7)]];
    
    
    
    //            [model add:[res lt:fc]];
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    
    [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[x]];
    
    
  }
  return 0;
}

